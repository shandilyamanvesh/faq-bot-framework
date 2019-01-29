class ChangeConfidenceToScore < ActiveRecord::Migration[5.1]
  def up
  	rename_column :questions, :confidence, :score
  	change_column_default :questions, :score, nil
  end

  def down
  	rename_column :questions, :score, :confidence
  	change_column_default :questions, :confidence, 0.0
  end
end
