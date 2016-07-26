require 'rubygems'
require 'rubygems/command.rb'
require 'rubygems/dependency_installer.rb'

begin
  Gem::Command.build_args = ARGV
rescue NoMethodError

end

inst = Gem::DependencyInstaller.new

begin
  if RUBY_PLATFORM[/darwin/]
    inst.install "dnssd", "2.0"
  end
rescue
  exit(1)
end

# Create dummy Rakefile to indicate success
f = File.open(File.join(File.dirname(__FILE__), "Rakefile"), "w")
f.write("task :default\n")
f.close
