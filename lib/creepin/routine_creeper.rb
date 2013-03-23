module Creepin

  class RoutineCreeper
  
    attr_accessor :collected_attributes_hash, :requested_url, :loaded_resource
  
    def initialize(loaded_resource, params = {})
      @params ||= {}
      @params = params if params.present?
      @loaded_resource = loaded_resource
      @collected_attributes_hash = {}
            
    end
  
    # def run_after_crawl_callbacks
    #   transmit
    # end
  
    # def transmit
    #   if url_attribute?
    #     @response = HTTParty.get(loaded_resource.send(url_attribute))
    #     @requested_url = loaded_resource.send(url_attribute)
    #   else
    #     @request_params ||= {:query => default_params.merge!(@params) }
    #     @response = HTTParty.get(base_url, @request_params)
    #     @requested_url = full_request_url(base_url, @request_params)           
    #   end
    # 
    #   crawl_finished
    # end
  
    def url_attribute?
      respond_to?(:url_attribute)
    end
  
    def build_request_params(param_string)
      params_hash = Rack::Utils.parse_query(param_string.split('?').pop)
      @request_params = { :query => params_hash.with_indifferent_access } if params_hash.present?
    end
  
    def full_request_url(base_url, request_params)
      base_url + request_params[:query].map{|k,v| "#{k}=#{v}"}.join("&").insert(0, '?')
    end
  
    def parse_response
      @response_html = Nokogiri::HTML::Document.parse(@response.body)
      load_response_resource
      map_response_resource if response_resource?
    end
  
    def load_response_resource
      @response_resource = @response_html.document.at_css(selector)
    end
  
    def map_response_resource

      element_mappings.each_pair do |attribute, block|
        value = instance_exec(@response_resource, &block)
        collected_attributes_hash[attribute] = value
      end
    
      resource = save_resource(collected_attributes_hash, loaded_resource)
    
    end
  
    def response_resource?
      @response_resource.present? ? true : false
    end
      
    def load_resource(collected_attributes_hash, resource_klass)
      if resource_load_strategy?
        resource_load_strategy.call(collected_attributes_hash, resource_klass)
      else
        resource_klass.new(collected_attributes_hash)
      end
    end
      
    def save_resource(collected_attributes_hash, resource)
      if resource_save_strategy?
        resource_save_strategy.call(collected_attributes_hash, resource)
      else
        collected_attributes_hash.each_pair{|k,v| resource.send("#{k}=", v) }
        resource.save unless skip_resource_save?
        resource
      end
    end
      
    def resource_save_strategy?
      respond_to?(:resource_save_strategy)
    end
      
    def skip_resource_save?
      respond_to?(:skip_resource_save)
    end
  
  end

end