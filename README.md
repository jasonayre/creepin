# Creepin
 
Creepin provides a friendly ruby dsl for spidering and crawling websites. Not only does it simplify and give you are reusable pattern for crawling external sites, but it lets you map what you are crawling to an active record model or ruby object.

## Installation

Add this line to your application's Gemfile:

    gem 'creepin'
    
### Run the Example

    git clone https://github.com/jasonayre/creepin_example.github
    bundle install
    rake db:drop && rake db:create && rake db:migrate
    rails c
    creeper = AmazonProductCollectionCreeper.new({"field-keywords" => "nixon 51-30 watch"})
    creeper.crawl
    
#### Why? When there are so many apis that are publicly accessible and easy to use
    
I wrote this gem for a project I am working on that involces mining data from multiple sites, the main one which has very strict api usage rules, uses Oauth, and only provides data for logged in Oauth users who have a valid token. Many apis have been trending this way, and I for one am not a fan of it. Mashing up data is much less useful when it is restricted to client side api calls which cannot be handled through background proceses.
    
###  How to use

Just like a real world creeper, you need something to creep on. Therefore, the creeper dsl begins with a declaration such as this.

    Creepin::On.new 'amazon_product' do
    
    end
    
#### Important
    
You also need an initializer right now, pointless but necessary at the moment with current gem version. Make sure thi is in your initializers directory.
    
    require 'creepin'
    Creepin.setup do |config|
  
    end
    
The idea is, you map each creeper, to a particular resource, on a particular site. For instance. if you were building a site that aggregates product data, you would have an ebay_product, amazon_product, creeper file.

Each of these files implements at least one, or two dsl methods. Collection, and resource. Within each method you define a selector which will then narrow down the returned html document response. Nokogiri is used to load he response, so all of the element mappings return a nokogiri collection of elements.

To load a collection, you need to provide a nokogiri at_css selector call, which will return a collection of nokogiri elements, which you can then map to your model, or objects. The object class name is specified with resource_class method. Although it is convenient to provide the actual model you are mapping to.

    collection do

      base_url 'http://www.amazon.com/s'
      selector '#main .rslt'
      resource_class 'Product'
      
    end
    
Each collection and resource method specified in the dsl, will create one class, which you can then use for your actual creeping.

    AmazonProductCollectionCreeper
    AmazonResourceCreeper

You load the CollectionCreeper by passing a hash of paramaters which is passed to the url you are crawling. E.X.
    
    creeper = AmazonProductCollectionCreeper.new({"field-keywords" => "nixon 51-30 watch"})
    
You specify the base url, plus the search or whatever it is, uri segment. Basically everything before the ?, in the base_url method.
    
    base_url "http://www.amazon.com/s"
    
You then initialize the crawl via

    creeper.crawl
    
You can use the next_page_selector method, to specify the element containing a link to the next page of results, and the creeper will automatically crawl through each set of results, until it reaches the end. Ex.
    
    next_page_selector do |doc|
      doc.at_css('#pagnNextLink')[:href] if doc.at_css('#pagnNextLink').present?
    end
    
Note that when using nokogiri, if you are calling things like [:href] to grab the elements attributes, you need to provide a boolean based on the existence of the element itself or else it will throw an error.

Put your creepers into the app/creepers directory. 
    
#### Details / Key Methods

You can define a resource load strategy, and a resource save strategy. This is so you can lookup a record if it already exists, to update the record. rather than create a new record. (or set the attributes of the object). Or just skip saving the resource altogether if it already exists, and you only have interest in adding new data, not updating existing.

    resource_load_strategy do |attributes_hash, resource_klass|
      resource = resource_klass.where(:external_id => attributes_hash[:external_id]).first
      if resource.present?
        attributes_hash.each_pair{|k,v| resource.send("#{k}=", v) }
      else
        resource = resource_klass.new(attributes_hash)
      end
      resource
    end
    
If you dont provide a load strategy, it will be loaded and setup via
    
    resource_class.new
    
You can define a resource save strategy, which will be called after the resource is loaded. I.E, if you only want to save new data:
    
    resource_save_strategy do |attributes_hash, resource|
      if resource.new_record?
        resource.save
      else
        resource
      end
      resource
    end
    
Otherwise it will by default try and save the resource with resource.save. You can also skip the save by specifying 
    
    skip_resource_save true
    
Thats all the documentation for now, follow the examples to figure out the rest.

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install creepin

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
