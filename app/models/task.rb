class Task < ApplicationRecord
  has_many :knowledge_basis

  validate :json_format

  def json_format
    return if properties.nil? || properties.empty?
    errors.add(:properties,"Json format is not correct.") unless properties.is_json?
  end
end
