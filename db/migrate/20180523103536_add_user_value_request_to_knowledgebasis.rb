class AddUserValueRequestToKnowledgebasis < ActiveRecord::Migration[5.1]
  def change
  	add_column :knowledge_bases, :request_for_user_value_message, :string, default: "What is your [[user_value]]?"
  end
end
