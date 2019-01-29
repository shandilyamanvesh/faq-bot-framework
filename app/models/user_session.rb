class UserSession < ApplicationRecord
	belongs_to :knowledge_basis
	has_many :questions, dependent: :destroy
	belongs_to :answer, optional: true

	validates :questioner_id, uniqueness: { scope: :knowledge_basis_id }
	serialize :data, JSON

  def active_answer_session?
    answer_id.present?
  end

  def most_recent_question
    questions.where("replied_at IS NULL").last
  end

	def add_user_data(value)
    user_value = missing_user_values.first
    if user_value.is_valid?(value)
      set_user_data(user_value.name, value)
      return true
    else
      return false
    end
  end

  def set_user_data(user_data_name, value)
    d = data || {}
    d[user_data_name.to_sym] = value
    update_attributes(data: d)
  end

  def missing_user_values
    user_values = answer.placeholders.where(["replaceable_type = ?", "UserValue"]).map(&:replaceable).uniq
    api_user_values = answer.placeholders.where(["replaceable_type = ?", "ExternalApiConnection"]).map(&:replaceable).map(&:placeholders).flatten.map(&:replaceable).reject(&:blank?).uniq
    (user_values + api_user_values).uniq.reject{|uv| (data || {}).keys.include?(uv.name)}.sort_by(&:name)
  end

  def missing_user_data_names
    missing_user_values.map(&:name)
  end

end
