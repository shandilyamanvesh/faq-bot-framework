class Placeholder < ApplicationRecord
	has_many :answer_placeholder_embeddings
	has_many :answers, through: :answer_placeholder_embeddings, dependent: :destroy
	has_many :external_api_connection_placeholder_embeddings
	has_many :external_api_connections, through: :external_api_connection_placeholder_embeddings, dependent: :destroy
	belongs_to :knowledge_basis
	belongs_to :replaceable, polymorphic: true, optional: true

	validates :name, presence: true, format: { with: /\A\w+\z/i, message: "please use word characters without spaces or symbols"}, uniqueness: { scope: :knowledge_basis }
	validates :knowledge_basis_id, presence: true
	validates :replaceable_id, presence: true, if: :replaceable_type?

	def value(user_session)
    case replaceable_type 
    when "GlobalValue"
		  replaceable.value
    when "UserValue"
      user_session.data[replaceable.name]
    when "ExternalApiConnection"
      replaceable.enriched_response(user_session.data[name])
    else
      nil
    end
	end
end
