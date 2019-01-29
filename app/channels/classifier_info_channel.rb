class ClassifierInfoChannel < ApplicationCable::Channel
  def subscribed
  	reject and return if current_user.blank?
    stream_from "classifier_info_channel_#{current_user.id}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
