class AddOffTopicFlag < ActiveRecord::Migration[5.1]
  def change
  	add_column :answers, :off_topic, :boolean, default: false
  end
end
