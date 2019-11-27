class AddDataSourceToKnowledgeBases < ActiveRecord::Migration[5.2]
  def change
  	add_column :knowledge_bases, :data_model, :string, :null => false
  end
end
