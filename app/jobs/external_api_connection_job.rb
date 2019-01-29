class ExternalApiConnectionJob < ApplicationJob
  queue_as :default

  def perform(external_api_connection, user_session, api_data_name)
    CustomLogger.log("Query API", namespace: "ExternalApiConnection") do |logger|
      logger.add_object(external_api_connection)
      logger.add_link(external_api_connection.enriched_url(user_session))

      begin
        # OAuth 2.0 authentification
        if external_api_connection.oauth_authenticated?
          token = external_api_connection.get_oauth2_token
          response = token.get(external_api_connection.url)
        # basic authentification
        else
          response = HTTParty.get(external_api_connection.enriched_url(user_session))
        end
        
        case response.code
        when 200

          user_session.set_user_data(api_data_name, response.body)
          q = user_session.most_recent_question
          q.send_response_to_user
          logger.add("API response: '#{response.body}'")
        else
          logger.add(response.to_s.truncate(60000))
          logger.set_alert_level 2
        end
        
      rescue Exception => e
        logger.add(response.to_s.truncate(60000))
        logger.add_error e
        logger.set_alert_level 2
      end
    end
  end
end
