# -*- encoding : utf-8 -*-

module SolrExamples
  def self.load(example)
    file_name = Rails.root.join('test', 'examples', example.to_s + '.rb')
    code = IO.read(file_name)
    hash = eval(code)
    hash
  end
end

module ResponseExamples
  def self.load(example)
    file_name = Rails.root.join('test', 'examples', example.to_s + '.txt')
    IO.read(file_name)
  end
end