require 'spec_helper'
feature "Creepin::Routine" do
  
  before :all do
    
    Creepin.class_eval do
  
      def self.load_paths
        [File.expand_path('../../creepers/routines/', __FILE__)]
      end
    
    end
    
    Creepin.setup do |config|
      
    end
    
  end
  
  scenario "it should have a creeper defined" do
    
    (defined? BrandRoutineCreeper).should == "constant"
  
  end
  
  
  
end