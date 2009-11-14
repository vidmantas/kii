class Configuration < ActiveRecord::Base
  class KeyNotFound < RuntimeError; end
  DEFAULTS = {
    "public_write" => true,
    "public_registration" => true,
    "site_name" => "Go, Kii!",
    "template" => "default",
    "markup" => "default",
    "home_page" => "Home"
  }.with_indifferent_access
  
  TEMPLATES = Pathname.glob(Rails.root + "app/templates/*").select(&:directory?).map {|p| p.basename.to_s }
  MARKUPS = Pathname.glob(Rails.root + "lib/kii/markup/languages/*.rb").map {|p| p.basename(p.extname).to_s }
  
  after_update :clear_cache

  # Reads config values. `Config["the_key"]`
  def self.[](key)
    value = Rails.cache.read("config::#{key}")
    value.nil? ? store_in_cache(key) : value
  end
  
  # Only for tests
  def self.[]=(key, value)
    Rails.cache.delete("config::#{key}")
    store_in_cache(key, value)
  end
  
  def self.store_in_cache(key, value = nil)
    # Checking for nil since we want to use value if it's false.
    value = value.nil? ? find_by_key(key) || DEFAULTS[key] : value
    
    if value.nil?
      raise KeyNotFound, "Configuration key `#{key}' was not found."
    else
      Rails.cache.write("config::#{key}", value)
      return Rails.cache.read("config::#{key}")
    end
  end
  
  private
  
  def clear_cache
    Rails.cache.write("config:#{self.key}", nil)
  end
end
