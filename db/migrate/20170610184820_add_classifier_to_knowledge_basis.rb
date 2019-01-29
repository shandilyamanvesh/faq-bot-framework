class AddClassifierToKnowledgeBasis < ActiveRecord::Migration[5.1]
  def change
  	add_column :knowledge_bases, :classifier, :string, default: :fast_text
  	add_index :knowledge_bases, :classifier
  end
end
