class AddWidgetLabels < ActiveRecord::Migration[5.1]
  def change
  	add_column :knowledge_bases, :widget_input_placeholder_text, :string, default: "Ask a question ..."
  	add_column :knowledge_bases, :widget_submit_button_text, :string, default: "Send"
  end
end
