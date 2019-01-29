class AddAlertLevelDefault < ActiveRecord::Migration[5.1]
  def change
  	change_column :custom_loggers, :alert_level, :integer, default: 0
  end
end
