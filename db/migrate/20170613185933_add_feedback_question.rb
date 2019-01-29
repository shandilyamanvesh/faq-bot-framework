class AddFeedbackQuestion < ActiveRecord::Migration[5.1]
  def change
  	add_column :knowledge_bases, :feedback_question, :string, default: "Was this answer helpful?"
  end
end
