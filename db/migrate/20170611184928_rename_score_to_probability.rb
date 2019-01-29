class RenameScoreToProbability < ActiveRecord::Migration[5.1]
  def up
  	rename_column :questions, :score, :probability
  end

  def down
  	rename_column :questions, :probability, :score
  end
end
