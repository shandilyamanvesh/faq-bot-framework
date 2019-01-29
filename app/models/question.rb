class Question < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :answer, optional: true
  belongs_to :user_session, optional: true
  belongs_to :knowledge_basis

  validates :text, presence: true
  #validates :user_session_id, presence: true

  scope :matched, -> { joins(:knowledge_basis).not_training.where("probability > knowledge_bases.threshold") }
  scope :unmatched, -> { joins(:knowledge_basis).not_training.where("probability IS NULL OR probability <= knowledge_bases.threshold") }
  scope :training, -> { where("confirmed_at IS NOT NULL") }
  scope :not_training, -> { where("confirmed_at IS NULL") }
  scope :unanswered, -> { where(answer: nil) }
  scope :answered, -> { where.not(answer: nil) }
  scope :reply_time_between, -> (minutes_min, minutes_max) { where(["CEIL((TIME_TO_SEC(TIMEDIFF(replied_at, created_at))) / 60) > ? AND CEIL((TIME_TO_SEC(TIMEDIFF(replied_at, created_at))) / 60) <= ?", minutes_min, minutes_max]) }

  # try to auto-match appropriate answer at arrival
  before_validation :find_matching_answer, if: Proc.new { |q| q.answer.blank? }, on: :create
  after_create :render_new_question_for_backend_users
  after_create :send_waiting_message, if: ->(q){ q.answer_id.blank? && q.knowledge_basis.waiting_message.present? } 
  # send response to user - both, on instant auto-matching and on delayed manual matching
  after_save :send_response_to_user, if: ->(q){ q.user_session.present? && q.saved_change_to_answer_id? && q.answer_id.present? } 

  def matched?
    answer_id.present?
  end

  def newer_question_exists?
    user_session.questions.order(created_at: :desc).limit(1).pluck(:created_at).first > (created_at || DateTime.now)
  end

  def confirm!
    update_attributes(confirmed_at: DateTime.now)
    # hide question on dashboard
    users = (knowledge_basis.users + User.admin).uniq
    users.each do |u| 
      KnowledgeBasisInfoChannel.broadcast_to(u, 
        knowledge_basis_id: knowledge_basis.id, 
        matched_questions_count: knowledge_basis.reload.questions.not_training.matched.count, 
        unmatched_questions_count: knowledge_basis.reload.questions.not_training.unmatched.count, 
        target: "#question_#{id}"
      ) 
    end
  end

  def reject!
    update_attributes(confirmed_at: nil, answer: nil, probability: nil)
  end

  def find_matching_answer
    answer_id, probability = knowledge_basis.predict(text)

    if probability > knowledge_basis.threshold && knowledge_basis.answers.exists?(answer_id)
    	self.probability = probability
      self.answer_id = answer_id
    end
  end

  def send_response_to_user
    stream_id = "chat_channel_#{user_session.questioner_id}"

    # set or confirm active answer session
    user_session.update_attributes(answer: answer)

    # all user data placeholder values available if any
    if (missing_user_data_names = user_session.missing_user_data_names).blank?
      # outstanding api data placeholder values
      if (missing_api_data_names = answer.missing_api_data_names(user_session)).present?
        # identify api connection
        missing_api_data_name = missing_api_data_names.first
        eac = answer.placeholders.where(["name = ?", missing_api_data_name]).first.replaceable
        ExternalApiConnectionJob.perform_later(eac, user_session, missing_api_data_name)
      else
        # clear active answer session if any
        user_session.update_attributes(answer: nil)
        
        # connected through Facebook
        if user_session.questioner_name
          # quote original question if user asked another question in the meantime
          if newer_question_exists?
            Facebook::Api::send_message(knowledge_basis.access_token, user_session.questioner_id, "« " + text + " »")
          end
          Facebook::Api::send_message(knowledge_basis.access_token, user_session.questioner_id, answer.enriched(user_session))
          
          update_column(:replied_at, DateTime.now)
      
        # anonymous connection via widget
        else
          ActionCable.server.broadcast(stream_id, message: answer.enriched(user_session), type: "answer")
        end
    
        # for auto-matched replies, ask for feedback
        if knowledge_basis.feedback_question.present? && self.saved_change_to_id? && !answer.off_topic?
          RequestFeedbackJob.set(wait: 5.seconds).perform_later knowledge_basis, self
        end
      end

    # placeholder values missing
    else
      missing_user_value = user_session.missing_user_values.first
      prompt_for_user_data = missing_user_value.prompt unless missing_user_value.prompt.blank?
      prompt_for_user_data ||= knowledge_basis.request_for_user_value_message.gsub(/\[\[\w+?\]\]/, missing_user_data_names.first)

      # connected through Facebook
      if user_session.questioner_name
        Facebook::Api::send_message(knowledge_basis.access_token, user_session.questioner_id, prompt_for_user_data)
      # anonymous connection via widget
      else
        ActionCable.server.broadcast(stream_id, message: prompt_for_user_data, type: "answer")
      end
      
    end
  end

  private

  def send_waiting_message
    # connected through Facebook
    if user_session.questioner_name
      Facebook::Api::send_message(knowledge_basis.access_token, user_session.questioner_id, knowledge_basis.waiting_message)

    # anonymous connection via widget
    else
      stream_id = "chat_channel_#{user_session.questioner_id}"
      ActionCable.server.broadcast(stream_id, message: knowledge_basis.waiting_message, type: "answer")
    end
  end

  # notify all backend users of respective knowledge basis about the new question
  def render_new_question_for_backend_users

    (knowledge_basis.users + User.admin).uniq.map{ |u| KnowledgeBasisInfoChannel.broadcast_to(u, 
      knowledge_basis_id: knowledge_basis.id, 
      matched_questions_count: knowledge_basis.questions.not_training.matched.count, 
      unmatched_questions_count: knowledge_basis.questions.not_training.unmatched.count, 
      target: (matched? ? "#matched_questions" : "#unmatched_questions"), 
      # render the new question
      partial: ApplicationController.renderer.render(stream: false, partial: 'questions/card', 
        locals: { q: self, knowledge_basis: knowledge_basis, user: u}
        )
      ) 
    }
  end

  def self.to_csv
    attributes = %w{created_at replied_at confirmed_at}

    CSV.generate(headers: true) do |csv|
      csv << attributes

      all.each do |user|
        csv << attributes.map{ |attr| user.send(attr) }
      end
    end
  end
end
