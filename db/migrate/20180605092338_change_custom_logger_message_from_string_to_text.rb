class ChangeCustomLoggerMessageFromStringToText < ActiveRecord::Migration[5.2]
  def change
  	  change_column :custom_loggers, :message, :text
  end
end
