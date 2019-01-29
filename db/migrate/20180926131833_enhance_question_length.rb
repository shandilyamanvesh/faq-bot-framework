class EnhanceQuestionLength < ActiveRecord::Migration[5.2]
  def change
    change_column :questions, :text, :text
  end
end
