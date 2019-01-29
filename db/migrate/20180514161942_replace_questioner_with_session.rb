class ReplaceQuestionerWithSession < ActiveRecord::Migration[5.1]
  def change
  	add_column :questions, :user_session_id, :integer
  	add_index :questions, :user_session_id

  	Question.where("questioner_id IS NOT NULL").each do |q|
  		session = UserSession.find_or_create_by(questioner_id: q.questioner_id, knowledge_basis_id: q.knowledge_basis_id)
  		session.questioner_name = q.questioner_name
  		session.save
  		q.user_session_id = session.id
  		q.save
  	end

  	remove_column :questions, :questioner_id
  	remove_column :questions, :questioner_name
    remove_column :questions, :knowledge_basis_id
  end
end
