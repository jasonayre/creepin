require 'spec_helper'
feature "Creepin::On" do
  
  before :all do
    
    Creepin.class_eval do
  
      def self.load_paths
        [File.expand_path('../../creepers/', __FILE__)]
      end
    
    end
    
    Creepin.setup do |config|
    end
    
    class BrandMock
      attr_accessor :name
    end
    
    class CategoryMock
      attr_accessor :name
    end
    
    class ProductMock
      attr_accessor :name, :category, :brand
    end
    
  end
  
  scenario "it should have created a brand collection creeper" do    
    (defined? BrandCollectionCreeper).should == "constant"
  end
  
  scenario "it should have created a brand resource creeper" do
    (defined? BrandResourceCreeper).should == "constant"
  end
  
  scenario "it should have created a product collection creeper" do    
    (defined? ProductCollectionCreeper).should == "constant"
  end
  
  scenario "it should have created a product resource creeper" do
    (defined? ProductResourceCreeper).should == "constant"
  end
  
  scenario "it should have created a category collection creeper" do    
    (defined? CategoryCollectionCreeper).should == "constant"
  end
  
  scenario "it should have created a category resource creeper" do
    (defined? CategoryResourceCreeper).should == "constant"
  end
  
  context "Brand collection creeper" do
    
    before :all do
      puts "doing something brand specific"
    end
    
  end
  
  
  
  
end
