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
      url = "#{Rails.configuration.training_api_url}/Training?id=#{knowledge_basis.id}"

      RestClient.get(
        url,
        content_type: 'json'
      )
    rescue
    end

    def self.predict(knowledge_basis, sentence)
      predict_payload = {
        expression: sentence,
        knowledge_basis: knowledge_basis.id
      }.to_json

      url = "#{Rails.configuration.training_api_url}/Predict"

      response = RestClient.post(
        url,
        predict_payload,
        content_type: 'json'
      ).body

      response = parse_json(response) || {}

      answer_id = nil
      probability = response[:score].to_f
      if response && response[:prediction]
        answer_id = Answer.find_by(text: response[:prediction])&.id
      end

      return answer_id, probability
    rescue
    end

    def self.reset(knowledge_basis)
      true
    end

    private

    def self.parse_json(json_str)
      JSON.parse(json_str).deep_symbolize_keys
    rescue StandardError
      {}
    end
  end
end
