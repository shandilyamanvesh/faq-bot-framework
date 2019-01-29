class CreateExternalApiConnectionPlaceholderEmbeddings < ActiveRecord::Migration[5.2]
  def change
    create_table :external_api_connection_placeholder_embeddings, id: false do |t|
      t.integer :external_api_connection_id
      t.integer :placeholder_id
    end

    add_index :external_api_connection_placeholder_embeddings, ["external_api_connection_id", "placeholder_id"], :unique => true, :name => 'api_placeholder_embeddings'
    
    remove_index :placeholder_embeddings, column: [:answer_id, :placeholder_id], name: :index_placeholder_embeddings_on_answer_id_and_placeholder_id
    rename_table :placeholder_embeddings, :answer_placeholder_embeddings
  end
end
