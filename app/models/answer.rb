class Answer < ApplicationRecord
	belongs_to :user, optional: true
	belongs_to :knowledge_basis
	has_many :questions, inverse_of: :answer, dependent: :destroy
  has_many :answer_placeholder_embeddings
	has_many :placeholders, through: :answer_placeholder_embeddings, dependent: :destroy
  has_many :user_sessions
	
	scope :training_questions, -> {questions.training}

	validates :text, presence: true
	validates_length_of :text, maximum: 640, message: "Facebook does not allow messages larger than 640 characters"

	accepts_nested_attributes_for :questions, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :placeholders, allow_destroy: true

  before_save :update_placeholders, if: :text_changed?

  # destroy placeholder(s) that are not associated to any other answers
	before_destroy {|record| record.placeholders.select{|p| p.answers.count == 1}.map{|p| p.destroy} }

	def to_s
    text
	end

  def enriched(user_session)
    response = text
    placeholders.each do |p|
      response.gsub!("[[#{p.name}]]", p.value(user_session).to_s)
    end
    response
  end

  def missing_api_data_names(user_session)
    placeholders.where(["replaceable_type = ?", "ExternalApiConnection"]).map(&:name).uniq - (user_session.data || {}).keys.sort
  end

	def self.to_csv
    CSV.generate(col_sep: ";") do |csv|
      all.each do |answer|
      	answer.questions.each do |question|
          csv << [question.text, answer.text]
        end
      end
    end
  end

  def update_placeholders
    placeholder_names = text.scan(/\[\[(\w+?)\]\]/).flatten.uniq
    
    # cleanup outdated placeholder associations
    placeholder_names.blank? ? placeholders.destroy_all : placeholders.where("name NOT IN (?)", placeholder_names).destroy_all

    # create newly added placeholders
    (placeholder_names - placeholders.map(&:name)).each do |placeholder_name|
      if (p = Placeholder.where(name: placeholder_name, knowledge_basis: knowledge_basis).first)
        placeholders << p
      else
        placeholders.build(name: placeholder_name, knowledge_basis: knowledge_basis)
      end
    end
  end

  def contains_unmatched_placeholders?
    placeholders.map{|p| p.replaceable.blank?}.include?(true)
  end
end
