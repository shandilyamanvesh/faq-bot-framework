class AnswerPlaceholderEmbedding < ApplicationRecord
	belongs_to :placeholder
	belongs_to :answer

	before_destroy :destroy_orphaned_placeholders

    private
	def destroy_orphaned_placeholders
	  placeholder.destroy if placeholder.answers.count == 1
	end
end