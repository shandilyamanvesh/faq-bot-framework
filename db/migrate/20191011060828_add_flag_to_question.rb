class AddFlagToQuestion < ActiveRecord::Migration[5.2]
  def change
  	add_column :questions, :flag, :string
  end
end
