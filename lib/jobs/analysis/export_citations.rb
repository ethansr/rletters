# -*- encoding : utf-8 -*-
require 'zip/zip'

module Jobs
  module Analysis
  
    # Export a dataset in a given citation format
    #
    # This job fetches the contents of the dataset and offers them to the
    # user for download as bibliographic data.
    class ExportCitations < Jobs::Analysis::Base
      # @return [Symbol] the export format (see +Document.serializers+)
      attr_accessor :format
    
      # Export the dataset
      #
      # @api public
      # @return [undefined]
      # @example Start a job for exporting a datset as JSON
      #   Delayed::Job.enqueue Jobs::Analysis::ExportCitations.new(
      #     :user_id => @user.to_param, 
      #     :dataset_id => dataset.to_param,
      #     :format => :json)
      def perform
        # Fetch the user based on ID
        user = User.find(user_id)
        raise ArgumentError, 'User ID is not valid' unless user
      
        # Fetch the dataset based on ID
        dataset = user.datasets.find(dataset_id)
        raise ArgumentError, 'Dataset ID is not valid' unless dataset
            
        # Check that the format is valid
        raise ArgumentError, 'Format is not specified' if format.nil?
        raise ArgumentError, 'Format is not valid' unless Document.serializers.has_key? format.to_sym
        serializer = Document.serializers[format.to_sym]
      
        # Make a new analysis task
        task = dataset.analysis_tasks.create(:name => "Export as #{format.to_s.upcase}")
      
        # Make a zip file for the output
        # Pack all those files into a ZIP
        task.result_file = Download.create_file('export.zip') do |file|
          begin
            Zip::ZipOutputStream.open(file.path) do |zos|
              # find_each will take care of batching logic for us
              dataset.entries.find_each do |e|
                begin
                  doc = Document.find e.shasum
                  zos.put_next_entry "#{doc.shasum}.#{format.to_s}"
                  zos.print serializer[:method].call(doc)
                rescue ActiveRecord::RecordNotFound
                  # FIXME: Would like to have a way to report a warning if 
                  # this isn't found!  Should be rare, but still.
                  next
                end
              end
            
            end
          ensure
            file.close
          end
        end
      
        # Make sure the task is saved, setting 'finished_at'
        task.finished_at = DateTime.current
        task.save
      end
    end

  end
end
