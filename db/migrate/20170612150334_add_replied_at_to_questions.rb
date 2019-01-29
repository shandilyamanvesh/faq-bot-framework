class AddRepliedAtToQuestions < ActiveRecord::Migration[5.1]
  def up
  	add_column :questions, :replied_at, :datetime
  end

  def down
  	remove_column :questions, :replied_at
  end
end
