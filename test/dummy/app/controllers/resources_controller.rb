class ResourcesController < ApplicationController

  def index
    @resources = Fake.all
    respond_to do |format|
      format.html { render :index }
      format.json { render json: @resources }
      format.xml  { render xml: @resources }
    end
  end

  def show
    @resource = Fake.find params[:id]
    respond_to do |format|
      format.html { render :show }
      format.json { render json: @resource }
      format.xml  { render xml: @resource }
    end
  end

  def create
    @resource = Fake.new params.require(:resource).permit(:id, :name)
    if @resource.save
      head 201
    else
      respond_to do |format|
        format.html { render :errors, status: 422 }
        format.json { render json: @resource.errors, status: 422 }
        format.xml  { render xml: @resource.errors, status: 422 }
      end
    end
  end

end
