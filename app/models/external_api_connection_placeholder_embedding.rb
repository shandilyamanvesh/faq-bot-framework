class ExternalApiConnectionPlaceholderEmbedding < ApplicationRecord
	belongs_to :placeholder
	belongs_to :external_api_connection

	before_destroy :destroy_orphaned_placeholders

    private
	def destroy_orphaned_placeholders
	  placeholder.destroy if placeholder.answers.count == 1 and placeholder.external_api_connections.count == 0
	end
end