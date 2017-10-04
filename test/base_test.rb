require 'tmpdir'
require 'timeout'
require 'open3'
require 'faraday'
require 'pathname'
require 'minitest/autorun'

$LOAD_PATH.unshift('./lib')
require 'stubborn'

class BaseTest < Minitest::Test
  DEBUG = false
  STUBBORN_EXECUTABLE = File.expand_path('bin/stubborn', Dir.pwd)
  
  def current_command
    @current_command
  end
  
  def current_command=(wait_thr)
    @current_command = wait_thr
  end
  
  def stubborn(*command, &block)
    begin
      Timeout::timeout(15) do
        command = "#{'STUBBORN_DEBUG=true' if DEBUG} #{STUBBORN_EXECUTABLE}#{" #{command.join(' ')}" unless command.empty?}"
        
        if block_given?
          print "#{command}\n" if DEBUG
          
          return_from_block = nil
          Open3.popen3(command) do |i, o, e, wt|
            self.current_command = wt
            return_from_block = block.call(i, o, e, wt)
            Process.kill('KILL', wt.pid)
            self.current_command = nil
          end
          
          return_from_block
        else
          `#{command}`
        end
      end
    rescue Timeout::Error => e
      unless self.current_command.nil?
        Process.kill("KILL", self.current_command.pid)
      end
      
      raise e
    end
  end
  
  def get(path = '/')
    res = nil
  
    until res do
      begin
        res = Faraday.get("http://localhost:9393#{path}")
      rescue
        sleep 1
      end
    end
    
    res
  end
  
  def within_project_directory
    Dir.mktmpdir do |dirname|
      Dir.chdir(dirname)
      Proc.new.call(dirname)
    end
  end
end