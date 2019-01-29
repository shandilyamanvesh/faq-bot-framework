class CreateAnswers < ActiveRecord::Migration[5.1]
  def change
    create_table :answers do |t|
      t.integer :knowledge_basis_id
      t.text :text
      t.integer :created_by
      t.timestamps
    end

    add_index :answers, :knowledge_basis_id
    add_index :answers, :created_by
  end
end
