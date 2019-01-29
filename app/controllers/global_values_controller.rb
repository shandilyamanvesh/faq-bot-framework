class GlobalValuesController < ApplicationController

  before_action :find_knowledge_basis

	def new
    @global_value = GlobalValue.new
  end

  def create
    @global_value = GlobalValue.create(global_value_params)
    if @global_value.save
    	redirect_to knowledge_basis_answers_path(@knowledge_basis, tab: "global_values"), notice: "Sucessfully created '#{@global_value.name}'"
    else
    	render 'edit'
    end
  end

  def edit
    @global_value = GlobalValue.find(params[:id])
  end

  def update
    @global_value = GlobalValue.find(params[:id])
    if @global_value.update(global_value_params)
      redirect_to knowledge_basis_answers_path(@knowledge_basis, tab: "global_values"), notice: "Sucessfully updated '#{@global_value.name}'"
    else
      render 'edit'
    end
  end

	def destroy
		@global_value = GlobalValue.find(params[:id])
    @global_value.destroy

    redirect_to knowledge_basis_answers_path(@knowledge_basis, tab: "global_values"), notice: "Sucessfully deleted global value #{@global_value.name}"
	end

  private
  def global_value_params
    params.require(:global_value).permit(:name, :value, :knowledge_basis_id)
  end

  def find_knowledge_basis
    @knowledge_basis = current_user.knowledge_bases.find(params[:knowledge_basis_id])
  end
end
