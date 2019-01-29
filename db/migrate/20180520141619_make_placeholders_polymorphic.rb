class MakePlaceholdersPolymorphic < ActiveRecord::Migration[5.1]
  def change
  	add_column :placeholders, :replaceable_type, :string
  	add_column :placeholders, :replaceable_id, :integer
  	add_index :placeholders, [ :replaceable_type, :replaceable_id]
  end
end
