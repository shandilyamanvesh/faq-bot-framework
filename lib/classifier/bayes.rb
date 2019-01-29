module Classifier
  module Bayes

    def self.train(knowledge_basis)
      classifier = ClassifierReborn::Bayes.new knowledge_basis.answers.map{|a| a.id}, enable_stemmer: false
  
      knowledge_basis.questions.training.each do |q|
        classifier.train q.answer_id, q.text
      end
  
      classifier_snapshot = Marshal.dump classifier
      Redis.current.set knowledge_basis.id, classifier_snapshot
    end
  
    def self.predict(knowledge_basis, text)
      if (data = Redis.current.get knowledge_basis.id).present? # trained classifier exists
        trained_classifier = Marshal.load data
  
        answer_id, score = trained_classifier.classify_with_score(text)
        probability = 10**score * 100.0
        return answer_id, probability
      end
    end

    def self.reset(knowledge_basis)
      Redis.current.del knowledge_basis.id
    end
  end
end
