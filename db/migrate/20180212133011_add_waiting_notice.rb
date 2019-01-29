class AddWaitingNotice < ActiveRecord::Migration[5.1]
  def change
  	add_column :knowledge_bases, :waiting_message, :text
  end
end
