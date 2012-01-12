# -*- encoding : utf-8 -*-
require 'spec_helper'

describe DatasetEntry do
  
  describe '#valid?' do
    context 'when no shasum is specified' do
      before(:each) do
        @entry = DatasetEntry.new
      end
      
      it "isn't valid" do
        @entry.should_not be_valid
      end
    end
    
    context "when a short shasum is specified" do
      before(:each) do
        @entry = DatasetEntry.new({ :shasum => 'notanshasum' })
      end
      
      it "isn't valid" do
        @entry.should_not be_valid
      end
    end
    
    context "when an invalid shasum is specified" do
      before(:each) do
        @entry = DatasetEntry.new({ :shasum => '1234567890thisisbad!' })
      end
      
      it "isn't valid" do
        @entry.should_not be_valid
      end
    end
    
    context "when a good shasum is specified" do
      before(:each) do
        @entry = DatasetEntry.new({ :shasum => "00972c5123877961056b21aea4177d0dc69c7318" })
      end
      
      it "is valid" do
        @entry.should be_valid
      end
    end
  end

end
