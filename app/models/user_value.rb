class UserValue < ApplicationRecord
  DATA_TYPES = ['string', 'bool', 'regex', 'city', 'country']
  
	belongs_to :knowledge_basis
	validates :name, presence: true, uniqueness: { scope: :knowledge_basis_id }
	validates :data_type, presence: true
  validates :regular_expression, presence: true, if: Proc.new{|uv| uv.data_type == "regex" } 
	validate :valid_regex, if: :regular_expression_changed?
	has_many :placeholders, as: :replaceable

	def is_valid?(value)

		case data_type
    when "string"
      return value.present?
    when "bool"
      [I18n.translate("yes", locale: knowledge_basis.language_code).downcase, I18n.translate("no", locale: knowledge_basis.language_code).downcase].include?(value.downcase)
    when "regex"
      !value.match(regular_expression.to_s).nil?
    when "city"
      Geocoder.search(value)[0].types.include?("locality") rescue false
    when "country"
      Geocoder.search(value)[0].types.include?("country") rescue false
    end
	end

  # safe, async update method
  def update_user_value(value, user_session)

    # execute delayed due to api call dependency
    if ["city", "country"].include?(data_type)
      DelayedUserValueUpdateJob.perform_later self, value, user_session
    
    # no dependency, execute immediately
    else
      set(value, user_session)
    end
  end

  # blocking update method – use update_user_value instead
  def set(value, user_session)
    # store provided user data in user session if valid
    if is_valid?(value)
      user_session.set_user_data(name, value)
    end
    
    q = user_session.most_recent_question
    q.send_response_to_user
  end

  private

	def valid_regex
    Regexp.new(self.regular_expression)
    rescue => exception
    errors.add(:regular_expression, exception)
	end
end
