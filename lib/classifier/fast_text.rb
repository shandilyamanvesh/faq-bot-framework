module Classifier
  module FastText
    require "fileutils"
    require "open3"

    CLASSIFIERS_DIR = Rails.configuration.classifiers['classifiers_dir']
    PRETRAINED_VECTORS_DIR = Rails.configuration.classifiers['pretrained_vectors_dir']
    FAST_TEXT_DIR = Rails.configuration.classifiers['fast_text_path']

    FileUtils.mkdir_p CLASSIFIERS_DIR
    FileUtils.mkdir_p PRETRAINED_VECTORS_DIR

    def self.train(knowledge_basis)
      training_file_path = "#{CLASSIFIERS_DIR}/#{knowledge_basis.id}_training.txt"
      model_file_path = "#{CLASSIFIERS_DIR}/#{knowledge_basis.id}_model"
      pretrained_vectors_file_path = "#{PRETRAINED_VECTORS_DIR}/wiki.#{knowledge_basis.language_code}.vec"

      # writing training data to file
      File.open(training_file_path, 'w') do |file|
        knowledge_basis.questions.training.each do |q|
          file.write "__label__#{q.answer_id} #{q.text.downcase}\n"
        end
      end

      begin
        stdout, stderr, status = Open3.capture3("#{FAST_TEXT_DIR}/fasttext supervised -dim 300 -pretrainedVectors #{pretrained_vectors_file_path} -input #{training_file_path} -output #{model_file_path}")
        
        raise stderr unless status.success?
        # set flag to make it available for training
        knowledge_basis.update(training: false)
      ensure
        File.delete(training_file_path) if File.exists? training_file_path # cleanup - remove training file
      end
    end

    def self.predict(knowledge_basis, text)
      model_file_path = "#{CLASSIFIERS_DIR}/#{knowledge_basis.id}_model.bin"

      if File.exists? model_file_path
      
        o, s = Open3.capture2("#{FAST_TEXT_DIR}/fasttext predict-prob #{model_file_path} -", stdin_data: text.downcase)
        
        label, probability = o.split(" ")
        answer_id = label.to_s[9..-1] # strip __label__
        answer_id = answer_id.to_i unless answer_id.nil?
      else
        answer_id = nil
        probability = nil
      end
  
      return answer_id, probability.to_f
    end

    def self.reset(knowledge_basis)
      model_file_path = "#{CLASSIFIERS_DIR}/#{knowledge_basis.id}_model.bin"
      File.delete(model_file_path) if File.exists? model_file_path # cleanup - remove model
    end
  end
end
