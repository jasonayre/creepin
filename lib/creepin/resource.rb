module Creepin

  class Resource
    
    def initialize(name, options={}, &block)
      @config = {}
      @request_params = {}
      
      instance_eval(&block)
      settings = @config.dup.merge(namespace: name)
      @request_params.merge(settings[:default_params]) if settings.has_key?(:default_params)
      @request_params.reverse_merge(options[:params]) if options.has_key?(:params)
      @loaded_resource = options[:loaded_resource] if options.has_key?(:loaded_resource)
      
      class_name = ActiveSupport::Inflector.camelize "#{name}ResourceCreeper"
      klass = Class.new ResourceCreeper
      dsl_methods = @config.keys
      creeper_class = Object.const_set(class_name, klass)
      
      #seems to be a bug with AASM and inheritence, this should be in collection crawler file
      creeper_class.class_eval do
        
        include AASM
  
        aasm do
          state :waiting, :initial => true
          state :crawling
          state :parsing
          state :finished
          state :finished_and_loaded
          
          event :crawl, :after => :transmit do
            transitions :from => :waiting, :to => :crawling
          end
          
          event :crawl_finished, :after => :parse_response do
            transitions :from => :crawling, :to => :finished
          end
          
        end
        
        dsl_methods.each do |sym|
          define_method(sym.to_s) {
            settings[sym]
          }
        end
        
      end
      
    end
    
    def base_url(string)
      @config[:base_url] = string
    end
    
    def default_params(hash)
      @config[:default_params] = hash
    end
    
    def url_attribute(sym)
      @config[:url_attribute] = sym.to_sym
    end
    
    def selector(string)
      @config[:selector] = string
    end
    
    def define_element_mapping(attr_name, &block)
      @config[:element_mappings] ||= {}
      @config[:element_mappings][attr_name] = block
    end
    
    def resource_class(string)
      @config[:resource_class] = string
    end
    
    def skip_resource_save(bool)
      @config[:skip_resource_save] = bool.present? ? bool : false
    end
    
    def resource_load_strategy(*options, &block)
      @config[:resource_load_strategy] = Proc.new(*options, &block)
    end
    
    def resource_save_strategy(*options, &block)
      @config[:resource_save_strategy] = Proc.new(*options, &block)
    end
    
  end
	
end