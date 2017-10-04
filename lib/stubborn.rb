require "stubborn/version"
require 'fileutils'
require 'slim'
require 'pathname'

STUBBORN_ROOT = File.expand_path('../..', __FILE__)

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
    begin
      require './stubborn_helper'
    rescue LoadError
    end

    locals = {}
    result = Slim::Template.new("index.slim", pretty: true).render(self, locals)
    Pathname('site/index.html').write(result)
  end
  
  def self.run_server
    doc_root = File.expand_path('site', Dir.pwd)
    Kernel.exec("ruby -run -e httpd #{doc_root} -p 9393")
  end
end
