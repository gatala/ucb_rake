# These tasks allow you to quickly deploy a rails app that has been built as a
# .war archive to JBoss or Tomcat.

require 'fileutils'

namespace :war do
  task :parse_args do
    if ARGV[1]
      APP_WAR = ARGV[1]
    else
      war_guess = File.basename(Dir.getwd)
      APP_WAR = "#{war_guess}.war"      
      puts "Guessing war to be #{APP_WAR}"
    end
  end
  
  task :build_tmp_war do
    FileUtils.mkdir("tmp.war")
    FileUtils.mv(APP_WAR, "tmp.war")
  end
  
  desc "Extracts war file into a directory <app>.war/ (used for JBoss deployment)"
  task :extract => [:parse_args, :warble, :build_tmp_war] do
    pwd = Dir.getwd
    Dir.chdir("tmp.war")
    `jar xvf #{APP_WAR}`
    Dir.chdir("WEB-INF/lib")
    Dir['*'].each do |f|
      next if f !~ /\.jar/
      dest = File.basename(f, ".jar")
      FileUtils.mkdir(dest)
      FileUtils.mv(f, dest)
      Dir.chdir(dest)
      `jar xvf #{f}`
      Dir.chdir("../")
      FileUtils.mv(dest, f)      
    end
    Dir.chdir(pwd)
    FileUtils.mv("tmp.war", APP_WAR)
  end

  task :warble do
    if !File.exists?(APP_WAR)
      `warble`
    end
  end
  
  namespace :deploy do
    task :default => [:extract] do
      if !File.exists?(APP_WAR)
        puts "#{APP_WAR} not found"
        system.exit(1)
      end
    end
    
    desc "Build war file and deploy to jboss"
    task :jboss => [:default] do
      if !JBOSS_HOME
        puts "JBOSS_HOME not configured in #{Rails.root}/config/war_deployer.rb"
        `mv sample_app.war #{JBOSS_HOME}/server/default/deploy/sample_app.war`
      end
    end
    
    desc "Build war file and deploy to tomcat"    
    task :tomcat => [:parse_args, :warble] do
      if !TOMCAT_HOME
        puts "TOMCAT_HOME not configured in #{Rails.root}/config/war_deployer.rb"
      end
      `mv sample_app.war #{TOMCAT_HOME}/webapps/sample_app.war`
    end
  end
end
