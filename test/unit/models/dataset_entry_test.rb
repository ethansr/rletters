# -*- encoding : utf-8 -*-
require 'test_helper'

class DatasetEntryTest < ActiveSupport::TestCase
  test "dataset entry with no shasum should be invalid" do
    entry = DatasetEntry.new
    assert !entry.valid?
  end

  test "dataset entry with short shasum should be invalid" do
    entry = DatasetEntry.new({ :shasum => "notanshasum" })
    assert !entry.valid?
  end

  test "dataset entry with bad shasum should be invalid" do
    entry = DatasetEntry.new({ :shasum => "1234567890thisisbad!" })
    assert !entry.valid?
  end

  test "minimal dataset entry should be valid" do
    entry = DatasetEntry.new({ :shasum => "00972c5123877961056b21aea4177d0dc69c7318" })
    assert entry.valid?
  end
end
