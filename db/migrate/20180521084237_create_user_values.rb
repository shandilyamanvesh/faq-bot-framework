class CreateUserValues < ActiveRecord::Migration[5.1]
  def change
    create_table :user_values do |t|
      t.string :name
      t.string :data_type
      t.integer :knowledge_basis_id
      t.timestamps
    end
  end
end
