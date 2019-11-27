class CreateTasks < ActiveRecord::Migration[5.2]
  def change
    create_table :tasks do |t|
    	t.string :name
    	t.string :code
    	t.json :properties

      t.timestamps
    end
  end
end
