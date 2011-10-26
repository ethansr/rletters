# -*- encoding : utf-8 -*-

# Display, modify, delete, and analyze datasets belonging to a given user
#
# This controller is responsible for the handling of the datasets which
# belong to a given user.  It displays the user's list of datasets, and
# handles the starting and management of the user's background analysis
# jobs.
#
# @see Dataset
class DatasetsController < ApplicationController
  before_filter :login_required

  # Show all of the current user's datasets
  # @api public
  # @return [undefined]
  def index
    @datasets = @user.datasets
  end

  # Show information about the requested dataset
  #
  # This action also includes links for users to perform various analysis
  # tasks on the dataset.
  #
  # @api public
  # @return [undefined]
  def show
    @dataset = @user.datasets.find(params[:id])
    raise ActiveRecord::RecordNotFound unless @dataset
  end

  # Show the form for creating a new dataset
  # @api public
  # @return [undefined]
  def new
    @dataset = @user.datasets.build
    render :layout => 'dialog'
  end
  
  # Show a confirmation box for deleting a dataset
  # @api public
  # @return [undefined]
  def delete
    @dataset = @user.datasets.find(params[:id])
    raise ActiveRecord::RecordNotFound unless @dataset
    render :layout => 'dialog'
  end
  
  # Create a new dataset in the database
  # @api public
  # @return [undefined]
  def create
    @dataset = @user.datasets.build(params[:dataset])
    if @dataset.save
      redirect_to @dataset, :notice => I18n.t('datasets.create.success')
    else
      redirect_to search_path, :error => I18n.t('datasets.create.failure')
    end
    
    solr_query = {}
    solr_query[:q] = params[:q]
    solr_query[:fq] = params[:fq]
    
    if params[:qt] == 'precise'
      solr_query[:qt] = 'dataset_precise'
    else
      solr_query[:qt] = 'dataset'
    end
    
    now = DateTime.current.to_formatted_s(:db)
    inserts = []

    @shasums = Document.find_all_by_solr_query(solr_query, :offset => 0, :limit => 500000)
    @shasums.each do |d|
      inserts.push "('#{d.shasum}', '#{@dataset.to_param}', '#{now}', '#{now}')"
    end
    sql = "INSERT INTO dataset_entries (`shasum`, `dataset_id`, `created_at`, `updated_at`) VALUES #{inserts.join(', ')}"
    ActiveRecord::Base.connection.execute(sql)
  end

  # Delete a dataset from the database
  # @api public
  # @return [undefined]
  def destroy
    @dataset = @user.datasets.find(params[:id])
    raise ActiveRecord::RecordNotFound unless @dataset

    redirect_to @dataset and return if params[:cancel]

    @dataset.destroy
    @user.datasets(true)

    redirect_to datasets_path
  end
end
