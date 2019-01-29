class CreateKnowledgeBases < ActiveRecord::Migration[5.1]
  def change
    create_table :knowledge_bases do |t|
      t.string :name
      t.string :welcome_message
      t.string :verify_token
      t.string :access_token
      t.timestamps
    end
  end
end
