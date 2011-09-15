class Document
  # Make this class act like an ActiveRecord model, though it's
  # not backed by the database (it's in Solr)
  include ActiveModel::Validations
  include ActiveModel::Conversion
  include ActiveModel::Serialization
  extend ActiveModel::Naming
  extend ActiveModel::Translation

  def persisted?; false; end
  def readonly?; true; end

  def before_destroy; raise ActiveRecord::ReadOnlyRecord; end
  def self.delete_all; raise ActiveRecord::ReadOnlyRecord; end
  def delete; raise ActiveRecord::ReadOnlyRecord; end

  # How to act appropriately ActiveModel-y:
  #
  # - Add all the attributes using attr_reader
  # - Try to load from Solr using an initialize method that takes
  # an SHASUM.
  # - If it fails, set an error with 
  # `errors.add(:attribute, 'cannot be made of fail') if whatever`
  # - To do serialization, integrate it into the ActiveModel::Serializers
  # so it acts right.

  # These are all the attributes that come directly out of the
  # Solr schema
  attr_reader :shasum, :doi, :authors, :title, :journal, :year,
              :volume, :number, :pages, :fulltext

  # The shasum attribute is the only required one
  validates :shasum, :presence => true
  validates :shasum, :length => { :is => 20 }
  validates :shasum, :format => { :with => /\A[a-fA-F\d]+\z/, :message => "Invalid SHA1 checksum" }

  def initialize(attributes = {})
    attributes.each do |name, value|
      instance_variable_set("@#{name}".to_sym, value)
    end
  end

end
