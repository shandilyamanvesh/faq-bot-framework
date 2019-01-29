class CreateExternalApiConnections < ActiveRecord::Migration[5.2]
  def change
    create_table :external_api_connections do |t|
      t.string :name
      t.string :url
      t.string :formatted_response
      t.integer :knowledge_basis_id

      t.timestamps
    end
  end
end
