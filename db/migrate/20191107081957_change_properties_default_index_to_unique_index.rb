class ChangePropertiesDefaultIndexToUniqueIndex < ActiveRecord::Migration[5.2]
  def change
  	add_index :tasks, :code, :unique => true
  end
end
