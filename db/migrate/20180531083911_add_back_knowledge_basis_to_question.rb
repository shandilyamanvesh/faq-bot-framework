class AddBackKnowledgeBasisToQuestion < ActiveRecord::Migration[5.2]
  def change
  	add_column :questions, :knowledge_basis_id, :integer
  	Answer.all.each do |a|
  		a.questions.each do |q|
  		  q.update_attributes(knowledge_basis_id: a.knowledge_basis_id)
  		end
  	end
  end
end
