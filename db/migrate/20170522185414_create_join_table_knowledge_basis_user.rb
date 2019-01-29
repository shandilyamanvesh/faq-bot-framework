class CreateJoinTableKnowledgeBasisUser < ActiveRecord::Migration[5.1]
  def change
    create_join_table :knowledge_bases, :users do |t|
      t.index [:knowledge_basis_id, :user_id]
      t.index [:user_id, :knowledge_basis_id]
    end
  end
end
