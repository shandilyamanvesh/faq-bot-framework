class DelayedUserValueUpdateJob < ApplicationJob
  queue_as :default

  def perform(user_value, value, user_session)
    CustomLogger.log("Validate #{user_value.data_type} user input and update user value", namespace: "DelayedUserValueUpdate") do |logger|
      logger.add(value)
      begin
        # validation requires external API call
        user_value.set(value, user_session)  
      rescue Exception => e
      end
    end
  end
end
