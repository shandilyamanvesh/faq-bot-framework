class ChangeFormattedResponseToResponseTemplate < ActiveRecord::Migration[5.2]
  def change
  	rename_column :external_api_connections, :formatted_response, :response_template
  end
end
