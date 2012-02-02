# -*- encoding : utf-8 -*-

module Examples
  
  def self.load(example)
    File.new(Rails.root.join('spec', 'support', 'examples', example.to_s + '.txt'))
  end
  
  # Stub out the Solr connection with the contents of an example file or array
  def self.stub(example)
    # Convert everything to an array
    if example.is_a? Array
      examples = example
    else
      examples = [ example ]
    end
    
    # Load the example files
    examples.map! { |e| load(e) }

    # Stub out the Solr connection
    WebMock.stub_request(:any, /localhost/).to_return(*examples)
  end
end
