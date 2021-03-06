class Configuration < ActiveRecord::Base
  class KeyNotFound < RuntimeError; end
  DEFAULTS = {
    "public_write" => true,
    "public_registration" => true,
    "site_name" => "Go, Kii!",
    "template" => "default",
    "home_page" => "Home"
  }.with_indifferent_access
  
  TEMPLATES = Pathname.glob(Rails.root + "app/templates/*").select(&:directory?).map {|p| p.basename.to_s }
  
  after_update :reset_cache

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
    key = key.to_s
    value = value.nil? ? find_by_key(key).try(:value) || DEFAULTS[key] : value

    if value.nil?
      raise KeyNotFound, "Configuration key `#{key}' was not found."
    else
      Rails.cache.write("config::#{key}", value)
    end
  end
  
  private
  
  def reset_cache
    Rails.cache.write("config::#{self.key}", self.value)
  end
end
