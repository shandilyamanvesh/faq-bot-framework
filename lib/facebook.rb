module Facebook
  module Api
    FACEBOOK_API_URL = "https://graph.facebook.com/v2.6/"
    
    def self.send_message(access_token, facebook_user_id, message)
      query = {
        "access_token": access_token
      }
      headers = {
          "Content-Type": "application/json"
      }
      data = {
          "recipient": {
              "id": facebook_user_id
          },
          "message": {
              "text": message
          }
      }

      params = {
        "query": query,
        "headers": headers,
        "body": data
      }

      response = HTTParty.post("#{FACEBOOK_API_URL}me/messages", params)
      return response.code      
    end

    def self.send_buttons(access_token, facebook_user_id, message, options)
      query = {
        "access_token": access_token
      }
      headers = {
          "Content-Type": "application/json"
      }

      buttons = []
    
      options.each do |o|

        buttons.append({
          type: "postback",
          title: o[:title],
          payload: o[:payload]
        })
      end

      data = {
        "recipient": {
            "id": facebook_user_id
        },
        "message": {
          "attachment": {
            "type": "template",
            "payload": {
                "template_type": "button",
                "text": message,
                "buttons": buttons.to_json
            }
          }
        }
      }


      params = {
        "query": query,
        "headers": headers,
        "body": data
      }

      response = HTTParty.post("#{FACEBOOK_API_URL}me/messages", params)
      return response.code
    end

    def self.send_quick_replies(access_token, facebook_user_id, message, options)
      query = {
        "access_token": access_token
      }
      headers = {
          "Content-Type": "application/json"
      }

      quick_replies = []
    
      options.each do |o|

        quick_replies.append({
          content_type: "text",
          title: o[:title],
          payload: o[:payload]
        })
      end

      data = {
        "recipient": {
            "id": facebook_user_id
        },
        "message": {
          "text": message,
          "quick_replies": quick_replies.to_json
        }
      }


      params = {
        "query": query,
        "headers": headers,
        "body": data
      }

      response = HTTParty.post("#{FACEBOOK_API_URL}me/messages", params)
      return response.code
    end

    def self.request_username(access_token, facebook_user_id)
      response = HTTParty.get("#{FACEBOOK_API_URL}#{facebook_user_id}?fields=first_name,last_name&access_token=#{access_token}")
      if response.code == 200
      	body = JSON.parse(response.body)
        return "#{body['first_name']} #{body['last_name']}"
      end
    end
  end
end