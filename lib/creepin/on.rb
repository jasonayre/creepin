module Creepin
  
  class On
    
    def initialize(name, &block)
      @config = {}
      @name = name
      instance_eval(&block)
    end
        
    def collection(*options, &block)
      Creepin::Collection.new(@name, *options, &block)
    end
        
    def resource(*options, &block)
      Creepin::Resource.new(@name, *options, &block)
    end
    
    def routine(*options, &block)
      Creepin::Routine.new(@name, *options, &block)
    end
      
  end
  
end