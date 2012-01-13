# -*- encoding : utf-8 -*-

module SolrExamples
  def self.load(example)
    file_name = Rails.root.join('spec', 'support', 'examples', example.to_s + '.rb')
    code = IO.read(file_name)
    hash = eval(code)
    hash
  end
  
  # Stub out the Solr connection with the contents of an example file
  def self.stub(example)
    # Convert everything to an array
    if example.is_a? Array
      examples = example
    else
      examples = [ example ]
    end
    
    # Load the example files
    examples.map! { |e| load(e) }
    
    # Make sure to stub everywhere that extends SolrHelpers!
    # FIXME: Can we somehow just stub the SolrHelpers method?!
    Document.stub(:get_solr_response).and_return(*examples)
    InfoController.stub(:get_solr_response).and_return(*examples)
    Jobs::CreateDataset.stub(:get_solr_response).and_return(*examples)
  end
end

module ResponseExamples
  def self.load(example)
    file_name = Rails.root.join('spec', 'support', 'examples', example.to_s + '.txt')
    IO.read(file_name)
  end
end
