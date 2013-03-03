require "rake/testtask"

task :default => [:test]
task :spec => :test
Rake::TestTask.new do |t|
  t.verbose, t.pattern = true, "test/**/*_test.rb"
end
