module Kii
  class Template
    attr_reader :path
    
    def initialize(template_name)
      @path = "#{Rails.root}/app/templates/#{template_name}"
      
      # Makes Rails look for views in app/templates/[template name]/views
      # instead of app/views.
      ActionController::Base.view_paths = ["#{@path}/views"]
      
      # Handling template helpers
      helper_files = Dir["#{@path}/helpers/*.rb"]
      helper_files.each {|h| load h }
      
      run_template_init_file
    end
    
    def run_template_init_file
      init_file = "#{@path}/init.rb"
      
      # The init file is optional.
      if File.file?(init_file)
        code = File.read(init_file)
        # So that `self` in the init file is this instance.
        eval(code, binding, __FILE__, __LINE__)
      end
    end
  end
end