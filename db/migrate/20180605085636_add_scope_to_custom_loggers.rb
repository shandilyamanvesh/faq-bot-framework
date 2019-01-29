class AddScopeToCustomLoggers < ActiveRecord::Migration[5.2]
  def change
  	rename_column :custom_loggers, :message, :scope
  	add_column :custom_loggers, :message, :string
  end
end
