class DatasetsController < ApplicationController
  before_filter :login_required

  def index
    # FIXME: only this user's datasets
    @datasets = Dataset.all
  end

  def show
    # FIXME: check the user has access to this dataset
    @dataset = Dataset.find(params[:id])
  end

  def create
    @dataset = Dataset.new(params[:dataset])

    respond_to do |format|
      if @dataset.save
        redirect_to @dataset, :notice => 'Dataset was successfully created.'
      else
        redirect_to search_path, :error => 'Could not save dataset!'
      end
    end
  end

  def destroy
    # FIXME: check the user has access to this dataset
    @dataset = Dataset.find(params[:id])
    @dataset.destroy

    redirect_to datasets_url
  end
end
