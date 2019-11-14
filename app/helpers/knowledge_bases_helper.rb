module KnowledgeBasesHelper
  require 'httparty'
  require 'rest-client'

  def data_sources
    login_payload = {
      email: Rails.configuration.email,
      password: Rails.configuration.password
    }.to_json

    login_response = RestClient.post(
      Rails.configuration.slack_druid_sign_in_api_url,
      login_payload,
      content_type: 'json'
    )

    headers = {
      client: login_response.headers[:client],
      expiry: login_response.headers[:expiry],
      token_type: login_response.headers[:token_type],
      uid: login_response.headers[:uid],
      access_token: login_response.headers[:access_token],
      content_type: 'application/json'
    }

    data_response = RestClient::Request.execute(
      method: :get,
      url: Rails.configuration.slack_druid_data_model_api_url,
      headers: headers
    ).body

    data_response = JSON.parse(data_response) || {}

    data_sources = data_response['dataSources'] || []

    data_sources.map do |d|
      {
        name: d['name'],
        code: d['code']
      }
    end.compact
  rescue StandardError
    []
  end
end
