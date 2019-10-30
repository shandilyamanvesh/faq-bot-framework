class QuestionsController < ApplicationController
  before_action :find_knowledge_basis

  skip_before_action :verify_authenticity_token, only: [:update, :create]

  def index
    all_questions = @knowledge_basis.questions.not_training.order("questions.created_at ASC")

    @unmatched_count = all_questions.unmatched.count
    @matched_count = all_questions.matched.count

    all_questions = all_questions.matched if params[:filter] == "matched"
    all_questions = all_questions.unmatched if params[:filter] == "unmatched"

    @questions = all_questions.page(params[:page])
    
    @question = @knowledge_basis.questions.build
  end

  def create
    respond_to do |format|
      format.js {
        @question = Question.new(question_params)
        stream_id = "chat_channel_#{@question.user_session.questioner_id}"
        ActionCable.server.broadcast(stream_id, message: @question.text, type: "question")
        @question.save
      }
    end
  end

  def update
    @question = @knowledge_basis.questions.find(params[:id])

    if @question.update(question_params)
      redirect_to knowledge_basis_questions_path(@knowledge_basis), notice: "Sucessfully assigned question to #{view_context.link_to('existing answer', edit_knowledge_basis_answer_url(@knowledge_basis.id, @question.answer, tab: 'training'))}", flash: { html_safe: true }
    else
      render 'index'
    end
  end

  def destroy
    @question = @knowledge_basis.questions.find(params[:id])
    text = @question.text
    @question.destroy
  
    redirect_to knowledge_basis_questions_url(@knowledge_basis), notice: "Sucessfully deleted '#{text}'"
  end

  private

  def question_params
    params.require(:question).permit(:text, :answer_id, :probability, :created_by, :confirmed_at, :user_session_id, :knowledge_basis_id, :flag, answer_attributes: [:id, :_destroy])
  end

  def find_knowledge_basis
    @knowledge_basis = KnowledgeBasis.find(params[:knowledge_basis_id])
  end
end
