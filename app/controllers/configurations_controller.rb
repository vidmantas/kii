require "ostruct"
class ConfigurationsController < ApplicationController
  before_filter :require_admin
  
  def show
    # Fooling form_for. Building an object that has
    # all the config keys as attributes.
    @configuration = OpenStruct.new
    
    Configuration::DEFAULTS.each {|key, value|
      @configuration.send("#{key}=", Configuration[key])
    }
  end
  
  def update
    params[:configuration].each do |key, value|
      c = Configuration.find_or_create_by_key(key)
      c.value = value
      c.save
    end
    
    flash[:success] = "Configuration successfully updated!"
    redirect_to configuration_path
  end
end
