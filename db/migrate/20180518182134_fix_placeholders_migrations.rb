class FixPlaceholdersMigrations < ActiveRecord::Migration[5.1]
  def change
    rename_table :answers_placeholders, :placeholder_embeddings
    add_index :placeholder_embeddings, [:answer_id, :placeholder_id], unique: true
  end
end
