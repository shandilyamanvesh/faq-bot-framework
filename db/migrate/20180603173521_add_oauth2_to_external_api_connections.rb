class AddOauth2ToExternalApiConnections < ActiveRecord::Migration[5.2]
  def change
  	add_column :external_api_connections, :oauth2_token_url, :string
  	add_column :external_api_connections, :oauth2_scope, :string
  	add_column :external_api_connections, :oauth2_client_id, :string
  	add_column :external_api_connections, :encrypted_oauth2_client_secret, :string
  	add_column :external_api_connections, :encrypted_oauth2_client_secret_iv, :string
  end
end
