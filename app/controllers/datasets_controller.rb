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
    
    if params[:clear_failed]
      if @dataset.analysis_tasks.failed.count > 0
        @dataset.analsysis_tasks.failed.destroy_all
        flash[:notice] = t('.deleted')
      else
        flash[:notice] = t('.no_failed')
      end
    end
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
    Delayed::Job.enqueue Jobs::CreateDataset.new(
      :user_id => @user.to_param,
      :name => params[:dataset][:name],
      :q => params[:q],
      :fq => params[:fq],
      :qt => params[:qt])
    
    redirect_to datasets_path, :notice => I18n.t('datasets.create.building')
  end

  # Delete a dataset from the database
  # @api public
  # @return [undefined]
  def destroy
    @dataset = @user.datasets.find(params[:id])
    raise ActiveRecord::RecordNotFound unless @dataset
    redirect_to @dataset and return if params[:cancel]

    Delayed::Job.enqueue Jobs::DestroyDataset.new(
      :user_id => @user.to_param,
      :dataset_id => params[:id])

    redirect_to datasets_path
  end
  
  # Start an analysis task for this dataset
  #
  # This method dynamically determines the appropriate analysis job to start
  # and strts it.  It requires a dataset ID.
  #
  # @api public
  # @return [undefined]
  def job_start
    dataset = @user.datasets.find(params[:id])
    raise ActiveRecord::RecordNotFound unless dataset
    
    # These should be required by regular expression to begin with start_
    klass = job_class(params[:job_name][6..-1])
    
    # Put the job parameters together out of the job hash
    job_params = {}
    if params[:job_params]
      job_params = params[:job_params].to_hash
      job_params.symbolize_keys!
    end
    job_params[:user_id] = @user.to_param
    job_params[:dataset_id] = dataset.to_param
    
    # Enqueue the job
    Delayed::Job.enqueue klass.new(job_params)
    redirect_to dataset_path(dataset)
  end
  
  # Show a view from an analysis job
  #
  # Analysis jobs are packaged with some of their own views.  This controller
  # action renders one of those views directly.
  #
  # @api public
  # @return [undefined]
  def job_view
    dataset = @user.datasets.find(params[:id])
    raise ActiveRecord::RecordNotFound unless dataset
    
    klass = job_class(params[:job_name])
    raise ActiveRecord::RecordNotFound unless params[:job_view]
    
    render :file => klass.job_view_path(params[:job_view]), :locals => { :dataset => dataset }
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
  
  private
  
  # Convert a class name (as a string) to a job class
  #
  # This function appends the 'Jobs::Analysis' modules and makes sure that
  # the given class exists.  It will throw an exception on failure.
  #
  # @api private
  # @param [String] class_name the class to look up
  # @return [Class] the class object
  # @example Get a job class
  #   job_class('ExportCitations')
  #   => Jobs::Analysis::ExportCitations
  def job_class(class_name)
    # Never let the 'Base' class match
    class_name = 'Jobs::Analysis::' + class_name
    raise ActiveRecord::RecordNotFound if class_name == 'Jobs::Analysis::Base'
    
    begin
      klass = class_name.constantize
      raise ActiveRecord::RecordNotFound unless klass.is_a?(Class)
    rescue NameError
      raise ActiveRecord::RecordNotFound
    end
    
    klass
  end
end
