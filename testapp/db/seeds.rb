category_names = %w[watches shoes hoodies pants].each do |name|
  category = Category.create!(name: name)
end

brand_names = %w[nixon element matix dc].each do |name|
  brand = Brand.create!(name: name)
end

Brand.all.each do |brand|
  Category.all.each do |category|
    
    50.times do |n|
      
      product = Product.create!(name: "test product #{n}", brand: brand, category: category)
  
    end
    
  end
end
