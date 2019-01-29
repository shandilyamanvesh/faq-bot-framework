class AddLanguageCodeToKnowledgeBases < ActiveRecord::Migration[5.1]
  def up
  	add_column :knowledge_bases, :language_code, :string
  end

  def down
  	remove_column :knowledge_bases, :language_code
  end
end
