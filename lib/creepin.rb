require "creepin/version"
require 'aasm'
require 'uri'
require 'active_support'
require 'rack'
require 'httparty'
require 'nokogiri'
require 'capybara'
require 'capybara/dsl'
require 'creepin/collection_creeper'
require 'creepin/collection'
require 'creepin/resource_creeper'
require 'creepin/resource'
require 'creepin/routine_creeper'
require 'creepin/routine'
require 'creepin/on'

module Creepin
  # Your code goes here...
  @@loaded = false
  def self.setup(&block)
    load!
    instance_eval(&block)
  end
  
  def self.load!
    # No work to do if we've already loaded
    return false if loaded?

    # Load files
    files_in_load_path.each{|file| load file }
    @@loaded = true
  end
  
  def self.loaded?
    @@loaded
  end
  
  def self.append_load_paths(paths)
    @@appended_load_paths.merge(paths)
  end
  
  def self.load_paths
    [File.expand_path('app/creepers', Rails.root)]
  end
  
  def self.files_in_load_path
    load_paths.flatten.compact.uniq.collect{|path| Dir["#{path}/**/*.rb"] }.flatten
  end
  
end
