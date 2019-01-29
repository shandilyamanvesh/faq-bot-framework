class AddCssToWidget < ActiveRecord::Migration[5.1]
  def change
  	add_column :knowledge_bases, :widget_css, :text
  end
end
