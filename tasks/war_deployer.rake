# These tasks allow you to quickly deploy a rails app that has been built as a
# .war archive to JBoss or Tomcat.

require 'fileutils'

CONFIG_FILE = "#{Rails.root}/config/initializers/ucb_rake.rb"

namespace :war do
  task :init do
    if !File.exists?(CONFIG_FILE)
      puts "ucb_rake not initialized, run: script/generate ucb_rake"
      exit(1)
    else
      require "#{Rails.root}/config/initializers/ucb_rake"
    end
    
    if ARGV[1]
      APP_WAR = ARGV[1]
    else
      war_guess = File.basename(Dir.getwd)
      APP_WAR = "#{war_guess}.war"      
      puts "APP_WAR => #{APP_WAR}"
    end
  end
  
  task :build_tmp_war do
    FileUtils.mkdir("tmp.war")
    FileUtils.mv(APP_WAR, "tmp.war")
  end
  
  desc "Extracts war file into a directory <app>.war/ (used for JBoss deployment)"
  task :extract => [:init, :warble, :build_tmp_war] do
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
    task :env => [:init] do
      puts "TOMCAT_HOME => #{TOMCAT_HOME}" if defined?(TOMCAT_HOME)
      puts "JBOSS_HOME => #{JBOSS_HOME}" if defined?(JBOSS_HOME)
    end
    
    task :default => [:extract] do
      if !File.exists?(APP_WAR)
        puts "#{APP_WAR} not found"
        system.exit(1)
      end
    end
    
    desc "Build war file and deploy to jboss"
    task :jboss => [:default] do
      if !defined?(JBOSS_HOME)
        puts "JBOSS_HOME not configured. See: #{CONFIG_FILE}"
        exit(1)
      end
      FileUtils.mv("sample_app.war ", "#{JBOSS_HOME}/server/default/deploy/sample_app.war")
    end
    
    desc "Build war file and deploy to tomcat"    
    task :tomcat => [:init, :warble] do
      if !defined?(TOMCAT_HOME)
        puts "TOMCAT_HOME not configured. See: #{CONFIG_FILE}"
        exit(1)
      end
      FileUtils.mv("sample_app.war", "#{TOMCAT_HOME}/webapps/sample_app.war")
    end
  end
end
