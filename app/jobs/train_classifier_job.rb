class TrainClassifierJob < ApplicationJob
  queue_as :default
  #self.queue_adapter = :resque

  after_enqueue do |job|
    stream_id = "classifier_info_channel_#{arguments.second}"
    ActionCable.server.broadcast(stream_id, message: "training_scheduled")
  end

  after_perform do |job|
    stream_id = "classifier_info_channel_#{arguments.second}"
    ActionCable.server.broadcast(stream_id, message: "training_completed")
  end

  def perform(knowledge_basis, current_user_id)
    stream_id = "classifier_info_channel_#{current_user_id}"
    ActionCable.server.broadcast(stream_id, message: "training_started")

    CustomLogger.log("Training classifier", namespace: "Classifier") do |logger|
      logger.add_object(knowledge_basis)
      begin
        knowledge_basis.train_classifier
      rescue Exception => e
        logger.add_error e
        logger.set_alert_level 2
      end
    end
  end

  def self.active?
    CustomLogger.unfinished.where(namespace: "Classifier").exists?    #TODO: distinguish by knowledge basis
  end
end
