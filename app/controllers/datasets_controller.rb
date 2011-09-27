# -*- encoding : utf-8 -*-
class DatasetsController < ApplicationController
  before_filter :login_required

  def index
    @datasets = session[:user].datasets
  end

  def show
    @dataset = session[:user].datasets.find(params[:id])
    raise ActiveRecord::RecordNotFound unless @dataset
  end

  def create
    @dataset = session[:user].datasets.build(params[:dataset])

    if @dataset.save
      redirect_to @dataset, :notice => 'Dataset was successfully created.'
    else
      redirect_to search_path, :error => 'Could not save dataset!'
    end
  end

  def destroy
    @dataset = session[:user].datasets.find(params[:id])
    raise ActiveRecord::RecordNotFound unless @dataset

    @dataset.destroy

    redirect_to datasets_url
  end
end
