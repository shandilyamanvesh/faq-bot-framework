class AddTrainingValueToKnowledgeBases < ActiveRecord::Migration[5.2]
  def change
  	add_column :knowledge_bases, :training, :boolean, :default => false
  end
end
