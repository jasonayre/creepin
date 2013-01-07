module Creepin
  class CollectionCreeper
  
    attr_accessor :stats, :total_records, :total_pages, :loaded_collection, :started_at, :finished_at, :requested_urls
  
    def initialize(params = {})
      @params ||= {}
      @params = params if params.present?
      @total_records ||= 0
      @total_pages ||= 0
      @loaded_collection ||= []
      @requested_urls ||= []
    end
  
    def run_after_crawl_callbacks
      transmit
    end
  
    def run_after_crawl_finished_callbacks
      parse_response
      after_crawl_finished_callbacks.each{ |callback| callback.call(self) } if after_crawl_finished_callbacks?
      crawl_next
    end
  
    def run_after_collection_loaded_callbacks
      after_collection_loaded_callbacks.each{ |callback| callback.call(self) } if after_collection_loaded_callbacks?
    end
  
    def after_crawl_finished_callbacks?
      (respond_to?(:after_crawl_finished_callbacks) && !after_crawl_finished_callbacks.empty?) ? true : false
    end
  
    def before_crawl_finished_callbacks?
      (respond_to?(:before_crawl_finished_callbacks) && !before_crawl_finished_callbacks.empty?) ? true : false
    end
  
    def after_collection_loaded_callbacks?
      (respond_to?(:after_collection_loaded_callbacks) && !after_collection_loaded_callbacks.empty?) ? true : false
    end
  
    def crawl_next_page
      if next_page?
        crawl
      else
        collection_loaded
      end
    end
  
    def transmit
      @request_params ||=  (default_params? ? {:query => default_params.merge(@params) } : {:query => @params } )
      @response = HTTParty.get(base_url, @request_params)
      @requested_urls << full_request_url(base_url, @request_params)
      @total_pages += 1
      crawl_finished
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
      load_response_collection
      map_response_collection if response_collection?
    end
  
    def load_response_collection
      @response_collection = @response_html.document.css(selector)
    end
  
    def response_collection?
      @response_collection.present?
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
        resource.save unless skip_resource_save?
      end
    end
  
    def skip_resource_save?
      respond_to?(:skip_resource_save)
    end
  
    def resource_load_strategy?
      respond_to?(:resource_load_strategy)
    end

    def resource_save_strategy?
      respond_to?(:resource_save_strategy)
    end
  
    def default_params?
      respond_to?(:default_params)
    end
  
    def map_response_collection
      @response_collection.each do |ele|
        collected_attributes_hash = {}
        element_mappings.each_pair do |attribute, block|
          value = instance_exec(ele, &block)
          collected_attributes_hash[attribute] = value
        end
        resource = load_resource(collected_attributes_hash, resource_class.constantize)
        @total_records += 1
        resource = save_resource(collected_attributes_hash, resource)
        loaded_collection << resource
      end
    end
  
    def next_page?
      return false if next_page_selector.nil?
      if next_page_selector.is_a?(Proc)
        next_page_url = instance_exec(@response_html.document, &next_page_selector)
        build_request_params(next_page_url) if next_page_url.present?
        @has_next_page = next_page_url.present?
      else
        next_page_url = @response_html.document.at_css(next_page_selector)
        build_request_params(next_page_url) if next_page_url.present?
        @has_next_page = next_page_url.present?
      end
      @has_next_page
    end
  
  end
end
