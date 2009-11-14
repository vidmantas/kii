class Configuration < ActiveRecord::Base
  class KeyNotFound < RuntimeError; end
  
  after_update :clear_cache

  # Reads config values. `Config["the_key"]`
  def self.[](key)
    Rails.cache.read("config::#{key}") || store_in_cache(key)
  end
  
  def self.store_in_cache(key)
    found_key = find_by_key(key)
    
    if found_key
      Rails.cache.write("config::#{key}", found_key.value)
      return Rails.cache.read("config::#{key}")
    else
      raise KeyNotFound, "Configuration key `#{key}' was not found."
    end
  end
  
  private
  
  def clear_cache
    Rails.cache.write("config:#{self.key}", nil)
  end
end
