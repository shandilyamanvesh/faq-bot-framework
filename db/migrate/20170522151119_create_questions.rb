class CreateQuestions < ActiveRecord::Migration[5.1]
  def change
    create_table :questions do |t|
      t.string :text
      t.integer :knowledge_basis_id
      t.string :questioner_id
      t.string :questioner_name
      t.integer :answer_id
      t.float :confidence, default: 0.0
      t.integer :assigned_by

      t.timestamps
    end

    add_index :questions, :knowledge_basis_id
    add_index :questions, :questioner_id
    add_index :questions, :answer_id
    add_index :questions, :confidence
    add_index :questions, :assigned_by
  end
end
