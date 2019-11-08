class TasksController < ApplicationController
  def index
    @tasks = Task.all
  end

  def new
    @tasks = Task.new
  end

  def show
    @task =Task.find(params[:id])
  end

  def create
    @task = Task.new(task_params)
    if @task.save
      redirect_to tasks_path, notice: "The task added"
    else
      flash[:error]= @task.errors.full_messages.join("\n")
      render 'edit'
    end
  rescue ActiveRecord::RecordNotUnique
    flash[:error]= @task.errors.full_messages.join("\n") +
      "\n You're using same code."
    render 'edit'
  end

  def update
    @task = Task.find(params[:id])
    if @task.update(task_params)
      redirect_to tasks_path, notice:  "The task updated"
    else
      flash[:error]= @task.errors.full_messages.join("\n")
      render 'edit'
    end
  rescue ActiveRecord::RecordNotUnique
    flash[:error]= @task.errors.full_messages.join("\n") +
      "\n You're using same code."
    render 'edit'
  end

  def destroy
    @task = Task.find(params[:id])
    @task.destroy
    redirect_to tasks_path, notice:  "The task deleted"
  rescue StandardError
    flash[:error]= @task.errors.full_messages.join("\n") +
      "\n This task  can't deleted it might be associated with other knowlege basis"
    redirect_to tasks_path
  end

  def edit
    @task = Task.find(params[:id])
    # @task = Task.all
  end

  private
  def task_params
    params.require(:task).permit(:name,:code,:properties)
  end
end
