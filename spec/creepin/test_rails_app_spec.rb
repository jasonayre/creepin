require 'spec_helper'

feature "test_app" do 
    # background do
    #   Capybara.app = TestRailsApp::Application
    # end
    
    before :each do

      Capybara.register_driver :selenium_firefox do |app|
        client = Selenium::WebDriver::Remote::Http::Default.new
        client.timeout = 3 # <= Page Load Timeout value in seconds
        Capybara::Selenium::Driver.new(app, :browser => :firefox, :http_client => client)
      end

      Capybara.current_driver = :selenium_firefox
      Capybara.app_host = 'http://localhost:3000'
      Capybara.default_wait_time = 3
    end
    
    scenario "test the test application itself" do

      visit("/")
      # puts page.inspect
      page.visit "/categories"
      # page.should_not have_content("nixon")
      page.should have_content("Listing categories")
      page.reset_session!
      # page
      # page.visit "/posts"
      # page.should have_content("I am test")    
    end
    
    TEST_DATA[:categories].each do |category|
      scenario "user visits categories page sees category list containing category" do
        page.visit('/categories')
        page.should have_content("Listing categories")
        page.should have_content(category)
      end
    end
    
    TEST_DATA[:brands].each do |brand|
      scenario "user visits brands page sees brand list containing brand" do
        page.visit('/brands')
        page.should have_content("Listing brands")
        page.should have_content(brand)
      end
    end

end