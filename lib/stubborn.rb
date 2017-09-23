require "stubborn/version"

module Stubborn
  def self.run_cli(argv)
    command = argv.shift
  
    if command == 'new'
      new_project(argv.shift)
    elsif command == 'build'
      build_project
    elsif command == 'server'
      run_server
    else
      print "No such command: '#{command}'\n"
    end
  end
  
  def self.new_project(project_directory)
    project_template = File.expand_path('templates/project', STUBBORN_ROOT)
    FileUtils.cp_r(project_template, project_directory)
  end
  
  def self.build_project
    locals = {}
    result = Slim::Template.new("index.slim").render(nil, locals)
    Pathname('site/index.html').write(result)
  end
  
  def self.run_server
    Kernel.exec('ruby -run -e httpd ./site -p 9393')
  end
end
