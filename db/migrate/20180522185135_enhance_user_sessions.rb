class EnhanceUserSessions < ActiveRecord::Migration[5.1]
  def change
  	add_column :user_sessions, :answer_id, :integer
  	UserSession.update_all(data: {})
  end
end
