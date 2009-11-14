rails_root = File.expand_path("#{File.dirname(__FILE__)}../../../")

namespace :kii do
  desc "Prepares the environment so that the application can boot."
  task :install => ["install:require_database_config", "db:create", "db:migrate", :environment, "install:basic"] do
  end
  
  namespace :install do
    task :basic do
      say "Creating database"
      if Page.find_by_permalink(Configuration[:home_page])
        say "Kii is already installed!"
        exit
      end
      
      say  "Creating home page"
      Page.create!({
        :title => Configuration[:home_page].titleize,
        :revision_attributes => {
          :body => File.read("#{Rails.root}/lib/kii/default_homepage"),
          :remote_ip => "0.0.0.0",
          :referrer => "/"
        }
      })
      
      say "Finished!"
    end
    
    task :require_database_config do
      unless File.file?("#{rails_root}/config/database.yml")
        say "Please create a database config in config/database.yml before running this task."
        exit
      end
    end
  end
  
  def say(this)
    puts ">> #{this}"
  end
end
