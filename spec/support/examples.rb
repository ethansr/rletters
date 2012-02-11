# -*- encoding : utf-8 -*-

module Examples
  def self.stub_with(site, example)
    WebMock.stub_request(:any, site).to_return(*load(example))
  end
  
  private
  
  def self.load(example)
    # Convert everything to an array
    if example.is_a? Array
      examples = example
    else
      examples = [ example ]
    end
    
    # Load the example files
    examples.map { |e| IO.read(Rails.root.join('spec', 'support', 'examples', e.to_s + '.txt')) }
  end
end
