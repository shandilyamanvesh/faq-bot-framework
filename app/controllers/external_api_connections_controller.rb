class ExternalApiConnectionsController < ApplicationController
  before_action :find_knowledge_basis

  def index
    @external_api_connections = ExternalApiConnection.all.order("name DESC")
  end

  def new
    @external_api_connection = ExternalApiConnection.new
  end

  def create
    @external_api_connection = ExternalApiConnection.create(external_api_connection_params)
    if @external_api_connection.save
    	redirect_to knowledge_basis_answers_path(@knowledge_basis, tab: "external_api_connections"), notice: "Sucessfully created API connection '#{@external_api_connection.name}'"
    else
    	render 'edit'
    end
  end

  def edit
    @external_api_connection = ExternalApiConnection.find(params[:id])
  end

  def update
    @external_api_connection = ExternalApiConnection.find(params[:id])

    respond_to do |format|
      format.html {
        if @external_api_connection.update(external_api_connection_params)
            redirect_to knowledge_basis_answers_path(@external_api_connection.knowledge_basis, tab: "external_api_connections"), notice: "Sucessfully updated API connection '#{@external_api_connection.name}'"
        else
          @tab = "external_api_connection"
          render 'edit'
        end
      }
      format.js {
        if @external_api_connection.update(external_api_connection_params)
          render "placeholders_modal_success"
        else
          render "placeholders_modal_errors"
        end
      }
    end
  end

  def destroy
    @external_api_connection = ExternalApiConnection.find(params[:id])
    @external_api_connection.destroy

    redirect_to knowledge_basis_answers_path(@knowledge_basis, tab: "external_api_connections"), notice: "Sucessfully deleted external API connection '#{@external_api_connection.name}'"
  end

  private
  def external_api_connection_params
    params.require(:external_api_connection).permit(:name, :url, :response_template, :knowledge_basis_id, :oauth2_token_url, :oauth2_scope, :oauth2_client_id, :oauth2_client_secret, placeholders_attributes: [:id, :replaceable_type, :replaceable_id])
  end

  def find_knowledge_basis
    @knowledge_basis = current_user.knowledge_bases.find(params[:knowledge_basis_id])
  end
end
