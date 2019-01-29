class AddIndicesToCustomLoggers < ActiveRecord::Migration[5.1]
  def change
  	add_index :custom_loggers, :completed_at
  	add_index :custom_loggers, :started_at
  	add_index :custom_loggers, :created_at
  	add_index :custom_loggers, :namespace
  end
end
