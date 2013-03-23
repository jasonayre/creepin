Creepin::On.new "category" do
  
  collection do

    base_url 'http://localhost:3000/'
    selector '#main_content .collection_member'
    resource_class 'CategoryMock'
    
    resource_load_strategy do |attributes_hash, resource_klass|
      resource = resource_klass.new(attributes_hash)
      # if resource.present?
      #   attributes_hash.each_pair{|k,v| resource.send("#{k}=", v) }
      # else
      #   resource = resource_klass.new(attributes_hash)
      # end
      
    end
    
  end
  
  resource do
    
    selector '#main_content'
    url_attribute :external_url
    
    # define_element_mapping :price do |ele|
    #   ele.at_css('#actualPriceValue b').text if ele.at_css('#actualPriceValue b').present?
    # end
    # 
    # define_element_mapping :description do |ele|
    #   ele.at_css('#productDescription .productDescriptionWrapper').text if ele.at_css('#productDescription .productDescriptionWrapper').present?
    # end
    # 
    # define_element_mapping :model_number do |ele|
    #   if ele.at_css("#techSpecSoftlines").present?
    #     ele.at_css("#techSpecSoftlines").search("td").each do |node|
    #       node.next_element.text.strip if node.text == 'Part Number'
    #     end
    #   end
    # end
    
  end
  
end
