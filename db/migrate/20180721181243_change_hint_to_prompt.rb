class ChangeHintToPrompt < ActiveRecord::Migration[5.2]
  def change
    rename_column :user_values, :hint, :prompt
  end
end
