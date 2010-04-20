namespace :ucb do
  namespace :db do
    
    task :init do
      require 'ucb_ist_unix'
      
      unless UCB::Webfarm.webfarm?
        puts "This task should only be run from a webfarm account."
        exit(1)
      end
      
      RAILS_ENV = ENV['RAILS_ENV'] 
      if UCB::Webfarm.webfarm? && RAILS_ENV.nil?
        RAILS_ENV = UCB::Webfarm.rails_migration_environment
      end
    end
    
    desc "Run migrations with DDL credentials and updates app_user db permissions."
    task :migrate => ['init', 'rake:db:migrate'] do
      spec = ActiveRecord::Base.establish_connection
      conn = ActiveRecord::Base.connection
      case conn.adapter_name.downcase
      when 'postgresql' : conn.execute("select * from public.regenerate_app_permissions()") 
      # when 'mysql'   : # do mysql thing 
      when 'oci'  : conn.execute("begin dbadmn.ror_grants; end;")
      else
        puts "Database adapter #{conn.adapter_name} not supported"
        exit(1)
      end   
    end
    
  end
end
