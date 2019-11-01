class KnowledgeBasesController < ApplicationController
  include Facebook
  
  # expose Facebook webhook 
  skip_before_action :authenticate_user!, only: [:webhook, :receive_message, :widget]
  load_and_authorize_resource except: [:webhook, :receive_message, :widget]
  skip_before_action :verify_authenticity_token, only: [:webhook, :receive_message, :widget]

  skip_authorization_check only: [:index, :edit, :update, :webhook, :receive_message, :widget]

  before_action :find_knowledge_basis, only: [:edit, :update, :destroy, :train, :reset, :clear_dashboard, :export, :receive_message]

  after_action :allow_iframe, only: :widget

  def index
    @knowledge_bases = current_user.role == "admin" ? KnowledgeBasis.all : current_user.knowledge_bases

    if current_user.role != "admin" && @knowledge_bases.present?
      redirect_to knowledge_basis_answers_path(@knowledge_bases.first) 
    end
  end

  def edit
  end

  def new
    @knowledge_basis = KnowledgeBasis.new
  end

  def create
    @knowledge_basis = KnowledgeBasis.create(knowledge_basis_params)
    if @knowledge_basis.errors.any?
      flash[:error]= @knowledge_basis.errors.full_messages.join("\n")
      render 'edit'
    elsif @knowledge_basis.save
      redirect_to knowledge_bases_url, notice: "Sucessfully created '#{@knowledge_basis.name}'"
    else
      render 'edit'
    end
  end	

  def update
    if @knowledge_basis.update(knowledge_basis_params)
      # classifier changed
      if @knowledge_basis.classifier_previously_changed?
        #reset old classifier
        case @knowledge_basis.classifier_previous_change.first
        when "fast_text"
          Classifier::FastText::reset(@knowledge_basis)
        when "bayes"
          Classifier::Bayes::reset(@knowledge_basis)
        when "bert"
          Classifier::Bert::reset(@knowledge_basis)
        end
        #retrain new classifier
        TrainClassifierJob.perform_later @knowledge_basis, current_user.id
      end
      if @knowledge_basis.threshold_previously_changed?
        old_threshold = @knowledge_basis.threshold_previous_change.first
        new_threshold = @knowledge_basis.threshold_previous_change.last

        # threshold was lowered
        if [old_threshold, new_threshold].max == old_threshold
          @knowledge_basis.questions.not_training.unmatched.each do |q| 
            q.find_matching_answer
            q.save
          end
        # threshold was increased
        else
          # reset answers for non-confirmed questions below the new threshold
          @knowledge_basis.questions.not_training.where(["probability < ?", new_threshold]).update_all(answer_id: nil, probability: nil)
        end
      end
      redirect_to knowledge_basis_answers_path(@knowledge_basis), notice: "Sucessfully updated '#{@knowledge_basis.name}'"
    else
      flash[:error]= @knowledge_basis.errors.full_messages.join("\n")
      render 'edit'
    end
  end

  def destroy
    name = @knowledge_basis.name
    @knowledge_basis.reset_classifier
    @knowledge_basis.destroy

    redirect_to knowledge_bases_url, notice: "Sucessfully deleted '#{name}'"
  end

  def clear_dashboard
    @knowledge_basis.destroy_all_pending_questions
    redirect_to knowledge_basis_questions_url(@knowledge_basis), notice: "Sucessfully deleted all pending questions"
  end

  def reset
    @knowledge_basis.answers.destroy_all
    @knowledge_basis.questions.destroy_all
    @knowledge_basis.reset_classifier
    redirect_to knowledge_basis_answers_url(@knowledge_basis), notice: "Sucessfully reset knowledge basis"
  end

  def train
    TrainClassifierJob.perform_later @knowledge_basis, current_user.id
  end

  def webhook
    @knowledge_basis = KnowledgeBasis.find(params[:knowledge_basis_id])
    
    render plain: "Not found", status: 404 and return if (@knowledge_basis.blank? || !@knowledge_basis.allow_facebook_messenger_access)
    if params["hub.mode"] == "subscribe" && params["hub.challenge"]
      if params["hub.verify_token"] == @knowledge_basis.verify_token
        render plain: params["hub.challenge"], status: 200
      else
        render plain: "Verification token mismatch", status: 403
      end
    end
  end

  # Facebook connection
  def receive_message

    if params[:entry]
      messaging_events = params[:entry][0][:messaging]
      messaging_events.each do |event|

        sender_id = event[:sender][:id]
        users = (@knowledge_basis.users + User.admin).uniq

        # handle regular message
        if (event[:message] && (text = event[:message][:text]) && event[:message][:is_echo].blank?)

          user_session = UserSession.find_or_create_by(questioner_id: sender_id, knowledge_basis: knowledge_basis)
          user_session.questioner_name ||= Facebook::Api::request_username(@knowledge_basis.access_token, sender_id)

          # active answer session (expected user input is a user value, not a question)
          if user_session.active_answer_session?

            # store provided user data in user session
            user_session.add_user_data(data['message'])   #TODO: add delayed update/validation step

            q = user_session.most_recent_question
            q.send_response_to_user

          # new question
          else
            @knowledge_basis.questions.create!(text: text, user_session: user_session, probability: nil)
          end
  
        # handle feedback loop
        elsif (event[:postback] && (payload = event[:postback][:payload]))
          json = JSON.parse(payload)
          question_id = json["question_id"].to_i
          useful = json["useful"]

          if (question = Question.where(id: question_id).first)
            if useful == true
              question.confirm!
            else
              question.reject!
            end
          end
  
        end
      end
    end
    render plain: "OK", status: 200
  end

  def widget
    @knowledge_basis = KnowledgeBasis.find_by_hash_id(params[:knowledge_basis_hash_id])
    render plain: "Not found", status: 404 and return if (@knowledge_basis.blank? || !@knowledge_basis.allow_anonymous_access)
    @question = @knowledge_basis.questions.build
    render :layout => false
  end

  def export
    respond_to do |format|
      format.csv { 
        send_data @knowledge_basis.questions.to_csv,
        filename: "logs_#{@knowledge_basis.to_identifier}_#{Time.now.to_i}.csv",
        type: 'text/csv; charset=utf-8' 
      }
    end
  end

  private
  def knowledge_basis_params
    params.require(:knowledge_basis).permit(:name, :verify_token, :access_token, :classifier, :threshold, :feedback_question, :language_code, :allow_anonymous_access, :widget_input_placeholder_text, :widget_submit_button_text, :allow_facebook_messenger_access, :widget_css, :properties,:waiting_message, :welcome_message, :request_for_user_value_message)
  end

  def find_knowledge_basis
    @knowledge_basis = current_user.knowledge_bases.find(params[:knowledge_basis_id] || params[:id])
  end

  def allow_iframe
    response.headers.except! 'X-Frame-Options'
  end
end