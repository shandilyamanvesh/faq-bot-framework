class ChatChannel < ApplicationCable::Channel

  def subscribed
    stream_from "chat_channel_#{self.uuid}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  # handle regular message
  def ask(data) 
    user_session = UserSession.find_or_create_by!(questioner_id: self.uuid, knowledge_basis_id: data['knowledge_basis_id'])

    # active answer session (expected user input is a user value, not a question)
    if user_session.active_answer_session?
      ActionCable.server.broadcast("chat_channel_#{self.uuid}", message: data['message'], user_session_id: user_session.id, type: "question")

      # validate and update user value if valid
      user_value = user_session.missing_user_values.first
      user_value.update_user_value(data['message'], user_session)

    # new question
    else
  	  q = Question.new(text: data['message'], user_session: user_session, knowledge_basis_id: data['knowledge_basis_id'])
      ActionCable.server.broadcast("chat_channel_#{self.uuid}", message: data['message'], user_session_id: user_session.id, type: "question")
      q.save
    end
    
  end

  # handle feedback loop
  def feedback(data) 
    if (question = Question.where(id: data['question_id']).first)
      data['useful'] == true ? question.confirm! : question.reject!
    end
  end
end
