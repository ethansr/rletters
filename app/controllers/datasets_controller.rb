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
    Delayed::Job.enqueue Jobs::CreateDataset.new(@user.to_param, 
      params[:dataset][:name], params[:q], params[:fq], params[:qt])
    
    redirect_to datasets_path, :notice => I18n.t('datasets.create.building')
  end

  # Delete a dataset from the database
  # @api public
  # @return [undefined]
  def destroy
    @dataset = @user.datasets.find(params[:id])
    raise ActiveRecord::RecordNotFound unless @dataset
    redirect_to @dataset and return if params[:cancel]

    Delayed::Job.enqueue Jobs::DestroyDataset.new(@user.to_param, params[:id])

    redirect_to datasets_path
  end
  
  # Start an analysis task for this dataset
  #
  # This method dynamically determines the appropriate analysis job to start
  # and strts it.  It requires a dataset ID.
  #
  # @api public
  # @return [undefined]
  def start_job
    dataset = @user.datasets.find(params[:id])
    raise ActiveRecord::RecordNotFound unless dataset
    
    # This shouldn't be possible, but check it anyway
    job_name = params[:job_name]
    raise ActiveRecord::RecordNotFound unless job_name
    
    # These should be required by regular expression to begin with start_
    job_class_string = 'Jobs::' + job_name[6..-1]
    
    begin
      job_class = job_class_string.constantize
      raise ActiveRecord::RecordNotFound unless job_class.is_a?(Class)
    rescue NameError
      raise ActiveRecord::RecordNotFound
    end
    
    # Put the job parameters together out of the job hash
    job = job_class.new
    job[:user_id] = @user.to_param
    job[:dataset_id] = dataset.to_param
    
    if params[:job_params]
      params[:job_params].each do |k, v|
        job[k] = v
      end
    end
    
    # Enqueue the job
    Delayed::Job.enqueue job
    redirect_to dataset_path(dataset)
  end
  
  # Download a file from an analysis task
  #
  # This method sends a user a result file from an analysis task.  It requires
  # a dataset ID and a task ID.
  #
  # @api public
  # @return [undefined]
  def download
    dataset = @user.datasets.find(params[:id])
    raise ActiveRecord::RecordNotFound unless dataset
    task = dataset.analysis_tasks.find(params[:task_id])
    raise ActiveRecord::RecordNotFound unless task
    raise ActiveRecord::RecordNotFound unless task.result_file
    raise ActiveRecord::RecordNotFound unless File.exists?(task.result_file.filename)
    
    task.result_file.send_file(self)
  end
end
