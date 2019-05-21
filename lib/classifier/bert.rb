# frozen_string_literal: true

module Classifier
  # bert classifier
  module Bert
    # require utils
    require "fileutils"
    require "open3"
    require "json"

    BASE_DIR = Rails.configuration.classifiers['bert_base_dir']
    TRAINFILE_DIR = Rails.configuration.classifiers['bert_trainfile_dir']

    def self.train(knowledge_basis)
      training_file_path = "#{TRAINFILE_DIR}/train.tsv"
      File.delete(training_file_path) if File.exists? training_file_path

      File.open(training_file_path, 'w') do |file|
        knowledge_basis.questions.training.each.with_index do |q, index|
          file.write "#{index + 1}\t#{q.answer.text}\t#{q.text}\n"
        end
      end
      so, se, s = Open3.capture3("python3 #{BASE_DIR}/train_classifier.py")
      raise se unless s.success?
    end
  
    def self.predict(knowledge_basis, sentence)
      answer_id = nil
      probability = nil
      if knowledge_basis && sentence
        str, s = Open3.capture2("python3 #{BASE_DIR}/predict_classifier.py --bulk_predict=false --sentence=#{sentence.downcase}")

        if s.success?
          str = str.split("\n").last
          answer, probability = str.split('|')
          answer_id = Answer.where(text: answer).first.id
        end
      end

      return answer_id, probability.to_f
    end

    def self.reset(knowledge_basis)
      true
    end

    private

    def parse_json(json_str)
      JSON.parse(json_str).deep_symbolize_keys
    rescue StandardError
      []
    end
  end
end
