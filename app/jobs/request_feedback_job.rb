class RequestFeedbackJob < ApplicationJob
  queue_as :default
  #self.queue_adapter = :resque

  def perform(knowledge_basis, question)
    user_session = question.user_session

    yes = I18n.translate("yes", locale: knowledge_basis.language_code)
    no = I18n.translate("no", locale: knowledge_basis.language_code)

    # connected through Facebook
    if user_session.questioner_name
      options = [
        { title: yes,
          payload: "{ \"question_id\": #{question.id}, \"useful\": true }"
        },
        { title: no,
          payload: "{ \"question_id\": #{question.id}, \"useful\": false }"
        }
      ]
      Facebook::Api::send_buttons(knowledge_basis.access_token, user_session.questioner_id, knowledge_basis.feedback_question, options)

    # anonymous connection via widget  
    else
      stream_id = "chat_channel_#{user_session.questioner_id}"
      ActionCable.server.broadcast(stream_id, data: {question_id: question.id, message: knowledge_basis.feedback_question, options: [{label: yes, useful: true}, {label: no, useful: false}]}, type: "buttons")
    end
  end
end
