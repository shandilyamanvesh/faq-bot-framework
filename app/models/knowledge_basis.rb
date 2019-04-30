class KnowledgeBasis < ApplicationRecord
	has_and_belongs_to_many :users
	has_many :answers, dependent: :destroy
  has_many :user_sessions, dependent: :destroy
	has_many :questions, dependent: :destroy
  has_many :placeholders, dependent: :destroy
  has_many :global_values, dependent: :destroy
  has_many :user_values, dependent: :destroy
  has_many :external_api_connections, dependent: :destroy

	validates :name, presence: true, uniqueness: true
  validates :hash_id, presence: true, uniqueness: true

  before_validation :set_hash_id, on: :create

	CLASSIFIERS = [["fastText", :fast_text], ["Bayesian", :bayes], ["Bert", :bert]]

	def reset_classifier
      case classifier
      when "fast_text"
        Classifier::FastText::reset(self)
      when "bayes"
        Classifier::Bayes::reset(self)
      when "bert"
        Classifier::Bert::reset(self)
      end
	end

  def train_classifier
    case classifier
    when "fast_text"
      Classifier::FastText::train(self)
    when "bayes"
      Classifier::Bayes::train(self)
    when "bert"
      Classifier::Bert::train(self)
    end
  end

  def predict(text)
    answer_id, probability = case classifier
    when "fast_text"
      Classifier::FastText::predict(self, text)
    when "bayes"
      Classifier::Bayes::predict(self, text)
    when "bert"
      Classifier::Bert::predict(self)
    end

    return answer_id, probability
  end

  def destroy_all_pending_questions
    questions.not_training.destroy_all
  end

  def to_identifier
    name.downcase.gsub(/[^0-9A-Z]/i, '_')
  end

  private

  def set_hash_id
    self.hash_id = SecureRandom.urlsafe_base64
  end
end
