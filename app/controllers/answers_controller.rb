class AnswersController < ApplicationController
  load_and_authorize_resource :only => [:import]

  before_action :find_knowledge_basis

  def index
    @answers = @knowledge_basis.answers
  end

  def edit
    @tab = params[:tab]
    @answer = @knowledge_basis.answers.find(params[:id])
  
  end

  def new
   
    @tab = params[:tab]
    @answer = @knowledge_basis.answers.build(created_by: current_user.id)
  
    unless params.has_key?(:question_ids) && (@questions = @knowledge_basis.questions.where(id: params[:question_ids])).count > 0
      @answer.questions.build(confirmed_at: DateTime.now)
    end
  end

  def create

    
    question_ids = answer_params[:questions_attributes].to_h.map { |k,v| v[:id] }
    question_ids.reject!(&:blank?)
    @answer = Answer.new(answer_params.merge({ question_ids: question_ids }))
     if @answer.save

      redirect_url = if question_ids.present?
        knowledge_basis_questions_url(@answer.knowledge_basis)
      else
        knowledge_basis_answers_url(@answer.knowledge_basis)
      end
      redirect_to redirect_url, notice: "Sucessfully created a #{view_context.link_to('new answer', edit_knowledge_basis_answer_url(@answer.knowledge_basis, @answer, tab: 'training'))}", flash: { html_safe: true }
    else
      render 'new'
    end
  else
    

  end
   
  

  def update
    @answer = Answer.find(params[:id])

    respond_to do |format|
      format.html {
        if @answer.update(answer_params)
            redirect_to knowledge_basis_answers_path(@answer.knowledge_basis), notice: "Sucessfully updated the #{view_context.link_to('answer', edit_knowledge_basis_answer_url(@answer.knowledge_basis, @answer))}", flash: { html_safe: true }
        else
          @tab = "training"
          render 'edit'
        end
      }
      format.js {
        if @answer.update(answer_params)
          render "placeholders_modal_success"
        else
          render "placeholders_modal_errors"
        end
      }
    end
  end

  def destroy
    answer = Answer.find(params[:id])
    name = answer.text
    answer.destroy
    redirect_to knowledge_basis_answers_path(@knowledge_basis), notice: "Sucessfully deleted answer '#{name}'"
  end

  def import
    if (params[:knowledge_basis][:file].blank?) == true
      redirect_to knowledge_basis_answers_path ,:flash => { :error => "Please select a file for upload." }
    else
      # condition for import and C-import
      uploaded_type =params[:knowledge_basis][:popup_radio]
      if params[:knowledge_basis][:popup_radio]== "2"
        # flash[:notice] = 'you have deleted old answers set.'
        @knowledge_basis.answers.destroy_all
      end
      # normal import
      uploaded_io = params[:knowledge_basis][:file]
      File.open(Rails.root.join('tmp',uploaded_io.original_filename), 'wb') do |file|
        file.write(uploaded_io.read)
      end
      ImportJob.perform_now @knowledge_basis.id, uploaded_io.original_filename, current_user.id
      redirect_to knowledge_basis_answers_path(@knowledge_basis), notice: "Import scheduled, please wait"
    end
  end

  def export
    filename = "dump_#{@knowledge_basis.to_identifier}_#{Time.now.to_i}.csv"

    respond_to do |format|
      format.csv { 
        send_data @knowledge_basis.answers.to_csv,
        filename: filename,
        type: 'text/csv; charset=utf-8' 
      }
    end
  end

  private
  def answer_params
    params.require(:answer).permit(:text, :knowledge_basis_id, :created_by, :off_topic, questions_attributes: [:id, :text, :answer_id, :knowledge_basis_id, :flag, :user_session_id, :assigned_by, :confirmed_at, :probability, :_destroy], placeholders_attributes: [:id, :replaceable_type, :replaceable_id])

  end

  def find_knowledge_basis
    @knowledge_basis = current_user.knowledge_bases.find(params[:knowledge_basis_id])
  end
end
