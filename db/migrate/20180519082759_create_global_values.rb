class CreateGlobalValues < ActiveRecord::Migration[5.1]
  def change
    create_table :global_values do |t|
      t.string :name
      t.string :value
      t.integer :knowledge_basis_id
      t.timestamps
    end
  end
end
