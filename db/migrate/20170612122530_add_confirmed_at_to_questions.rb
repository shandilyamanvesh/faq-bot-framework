class AddConfirmedAtToQuestions < ActiveRecord::Migration[5.1]
  def change
  	add_column :questions, :confirmed_at, :datetime
  end
end
