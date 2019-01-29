class AddThresholdToKnowledgeBasis < ActiveRecord::Migration[5.1]
  def change
  	add_column :knowledge_bases, :threshold, :float, default: 0.2
  end
end
