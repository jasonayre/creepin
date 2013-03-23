module Creepin
  class Collection
    
    def initialize(name, options={}, &block)
      @config = {}
      @request_params = {}
      
      instance_eval(&block)
      settings = @config.dup.merge(namespace: name)
      @request_params.merge(settings[:default_params]) if settings.has_key?(:default_params)
      @request_params.reverse_merge(options[:params]) if options.has_key?(:params)
      
      class_name = ActiveSupport::Inflector.camelize "#{name}CollectionCreeper"
      klass = Class.new CollectionCreeper
      dsl_methods = @config.keys
      @creeper_class = Object.const_set(class_name, klass)
      
      #seems to be a bug with AASM and inheritence, this should be in collection crawler file
      @creeper_class.class_eval do
        
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
          
          event :crawl_finished, :after => :run_after_crawl_finished_callbacks do
            transitions :from => :crawling, :to => :finished
          end
          
          event :crawl_next, :after => :crawl_next_page do
            transitions :from => :finished, :to => :waiting
          end
          
          event :collection_loaded, :after => :run_after_collection_loaded_callbacks do
            transitions :from => [:waiting, :finished], :to => :finished_and_loaded
          end
          
        end
        
        dsl_methods.each do |sym|
          define_method(sym.to_s) {
            settings[sym]
          }
        end
        
      end
      
      unless @config[:base_url].present?
        @creeper_class.class_eval do
          def base_url=(string)
            @config[:base_url] = string
          end
        
          def base_url
            @config[:base_url]
          end
        end
      end
      
    end
    
    def base_url(string)
      @config[:base_url] = string
    end
    
    def default_params(hash)
      @config[:default_params] = hash
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
    
    def next_page_selector(string='', &block)
      @config[:next_page_selector] = string unless string.nil?
      @config[:next_page_selector] = block if block
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
    
    def after(event_name, &block)
      @config["after_#{event_name.to_s}_callbacks".to_sym] ||= []
      @config["after_#{event_name.to_s}_callbacks".to_sym] << block
    end
    
  end
end