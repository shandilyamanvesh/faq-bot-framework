class AddPropertiesFieldToKnowledgeBases < ActiveRecord::Migration[5.2]
  def change
  	add_column :knowledge_bases, :properties, :json
  end
end
