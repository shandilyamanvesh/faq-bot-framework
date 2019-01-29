class CreatePlaceholders < ActiveRecord::Migration[5.1]
  def change
    create_table :placeholders do |t|
      t.string :name
      t.integer :knowledge_basis_id
      t.timestamps
    end

    create_table :answers_placeholders, id: false do |t|
      t.belongs_to :answer, index: true
      t.belongs_to :placeholder, index: true
    end
  end
end