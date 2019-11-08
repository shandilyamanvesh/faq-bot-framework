class AddKnowledgeBasesToTask < ActiveRecord::Migration[5.2]
  def change
  	add_reference :knowledge_bases,:task , foreign_key: true
  end
end
