class KnowledgeBasisInfoChannel < ApplicationCable::Channel
  def subscribed
  	reject and return if current_user.blank?
  	stream_for current_user
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
