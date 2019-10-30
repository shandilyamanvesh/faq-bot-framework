class ChangeDefaultValueToTrain < ActiveRecord::Migration[5.2]
  def change
  	change_column :questions, :flag, :string, :null => false, :default => "train"
  end
end
