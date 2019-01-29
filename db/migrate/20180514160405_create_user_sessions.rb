class CreateUserSessions < ActiveRecord::Migration[5.1]
  def change
    create_table :user_sessions do |t|
      t.string :questioner_id
      t.string :questioner_name
      t.integer :knowledge_basis_id
      t.text :data

      t.timestamps
    end

    add_index :user_sessions, [:questioner_id, :knowledge_basis_id], unique: true
  end
end