
module Creepin
  class Routine
    
    def initialize(name, options={}, &block)
      @config = {}
      @request_params = {}
      
      instance_eval(&block)
      settings = @config.dup.merge(namespace: name)
      @request_params.merge(settings[:default_params]) if settings.has_key?(:default_params)
      @request_params.reverse_merge(options[:params]) if options.has_key?(:params)
      
      class_name = ActiveSupport::Inflector.camelize "#{name}RoutineCreeper"
      klass = Class.new RoutineCreeper
      dsl_methods = @config.keys
      @creeper_class = Object.const_set(class_name, klass)
      
    end
    
  end
  
end