class AddRegexDataTypeToUserValues < ActiveRecord::Migration[5.2]
  def change
  	add_column :user_values, :regular_expression, :string
  	add_column :user_values, :hint, :string
  end
end
