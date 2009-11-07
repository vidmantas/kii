rails_root = File.expand_path("#{File.dirname(__FILE__)}../../../")

namespace :kii do
  desc "Prepares the environment so that the application can boot."
  task :install => ["install:require_database_config", "install:prepare", :environment, "install:require_unconfigured", "install:basic"] do
  end
  
  namespace :install do
    task :basic do
      say "Creating database"
      Rake::Task["db:create"].invoke
      Rake::Task["db:migrate"].invoke
      
      say  "Creating home page"
      Page.create!({
        :title => Kii::CONFIG[:home_page].titleize,
        :revision_attributes => {
          :body => File.read("#{Rails.root}/lib/kii/default_homepage"),
          :remote_ip => "0.0.0.0",
          :referrer => "/"
        }
      })
    end
    
    task :prepare do
      require 'fileutils'
      
      say "Creating config files"
      FileUtils.cp("#{rails_root}/config/kii.sample.yml", "#{rails_root}/config/kii.yml")
    end
    
    task :require_database_config do
      unless File.file?("#{rails_root}/config/database.yml")
        say "Please create a database config in config/database.yml before running this task."
        exit
      end
    end
    
    task :require_unconfigured do
      if Page.find_by_permalink(Kii::CONFIG[:home_page])
        say "Kii is already installed!"
        exit
      end
    end
  end
  
  # desc "Installs without running the pre installation tasks."
  # task :basic_install => [:require_database_config] do
  #   say "Migrating the database"
  #   Rake::Task["db:create"].invoke
  #   Rake::Task["db:migrate"].invoke
  #   
  #   if Page.find_by_permalink(Kii::CONFIG[:home_page])
  #     say "Kii is already installed!"
  #     exit
  #   end
  #   
  #   say "Creating home page"
  #   Page.create!({
  #     :title => Kii::CONFIG[:home_page].titleize,
  #     :revision_attributes => {
  #       :body => File.read("#{Rails.root}/lib/kii/default_homepage"),
  #       :remote_ip => "0.0.0.0",
  #       :referrer => "/"
  #     }
  #   })
  # end
  # 
  # desc "Runs the pre-installation"
  # task :pre_install => [:require_database_config] do
  #   require 'fileutils'
  #   
  #   say "Creating config files"
  #   FileUtils.cp("#{rails_root}/config/kii.sample.yml", "#{rails_root}/config/kii.yml")
  # end
  # 
  # task :require_database_config do
  #   unless File.file?(File.join(rails_root, "config", "database.yml"))
  #     say "Please create a database config in config/database.yml before running this task."
  #     exit
  #   end
  # end
  
  def say(this)
    puts ">> #{this}"
  end
end
