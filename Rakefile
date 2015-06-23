require 'rspec/core/rake_task'
require 'rake/task'

begin
  require 'bones'
rescue LoadError
  abort '### Please install the "bones" gem ###'
end


task :default => :spec
task 'gem:release' => 'test:all'

Bones {
  name     'soc_maker'
  authors  'Christian Haettich'
  email    'feddischson [ at ] opencores.org'
  url      'https://github.com/feddischson/soc_maker'
}

RSpec::Core::RakeTask.new(:spec) do |c|
   c.ruby_opts="-w"
end

 
desc 'generate API documentation to doc/rdocs/index.html'
 
Rake::RDocTask.new do |rd|
  rd.rdoc_dir = 'doc/rdocs'
  rd.main = 'README.md'
  rd.rdoc_files.include 'README.md', 'LICENSE', "bin", "lib"
 
  rd.options << '--inline-source'
  rd.options << '--line-numbers'
  rd.options << '--all'
  rd.options << '--fileboxes'
  rd.options << '--diagram'
end
