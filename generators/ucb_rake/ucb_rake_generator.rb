class UcbRakeGenerator < Rails::Generator::Base
  
  def initialize(*runtime_args)
    super
  end
  
  def manifest
    record do |m|
      m.directory(File.join('config', 'initializers'))
      m.template('ucb_rake.rb', File.join('config', 'initializers', 'ucb_rake.rb'))

      m.directory(File.join('config'))
      m.template('war_deployer.yml', File.join('config', 'war_deployer.yml'))
    end
  end
    
  protected
  
  def banner
    %{Copies ucb_rake.rb to config/initializers/}
  end
  
end
