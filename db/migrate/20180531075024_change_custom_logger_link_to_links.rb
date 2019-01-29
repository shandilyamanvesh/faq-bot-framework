class ChangeCustomLoggerLinkToLinks < ActiveRecord::Migration[5.2]
  def change
  	rename_column :custom_loggers, :link, :links
  end
end
