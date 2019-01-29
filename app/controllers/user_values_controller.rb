class UserValuesController < ApplicationController
	before_action :find_knowledge_basis

	def new
    @user_value = UserValue.new(data_type: "string")
  end

  def create
    @user_value = UserValue.create(user_value_params)
    if @user_value.save
    	redirect_to knowledge_basis_answers_path(@knowledge_basis, tab: "user_values"), notice: "Sucessfully created '#{@user_value.name}'"
    else
    	render 'edit'
    end
  end

  def edit
    @user_value = UserValue.find(params[:id])
  end

  def update
    @user_value = UserValue.find(params[:id])
    if @user_value.update(user_value_params)
      redirect_to knowledge_basis_answers_path(@knowledge_basis, tab: "user_values"), notice: "Sucessfully updated '#{@user_value.name}'"
    else
      render 'edit'
    end
  end

	def destroy
	  @user_value = UserValue.find(params[:id])
    @user_value.destroy

    redirect_to knowledge_basis_answers_path(@knowledge_basis, tab: "user_values"), notice: "Sucessfully deleted global value #{@user_value.name}"
	end

  private
  def user_value_params
    params.require(:user_value).permit(:name, :data_type, :regular_expression, :prompt, :knowledge_basis_id)
  end

  def find_knowledge_basis
    @knowledge_basis = current_user.knowledge_bases.find(params[:knowledge_basis_id])
  end

end
