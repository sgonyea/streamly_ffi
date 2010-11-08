# encoding: UTF-8

require 'rake/gempackagetask'

gemspec = eval File.read('streamly.gemspec')

# Gem packaging tasks
Rake::GemPackageTask.new(gemspec) do |pkg|
  pkg.need_zip = false
  pkg.need_tar = false
end

task :gem => :gemspec

desc %{Build the gemspec file.}
task :gemspec do
  gemspec.validate
end

desc %{Release the gem to RubyGems.org}
task :release => :gem do
  system "gem push pkg/#{gemspec.name}-#{gemspec.version}.gem"
end

require 'rspec/core'
require 'rspec/core/rake_task'

desc "Run all examples with RCov"
Rspec::Core::RakeTask.new('spec:rcov') do |t|
#Spec::Rake::SpecTask.new('spec:rcov') do |t|
  t.pattern   = ["spec/requests/**/*_spec.rb", "spec/**/server.rb"]
  t.rcov      = true
  t.rcov_opts = lambda do
    IO.readlines("spec/rcov.opts").map {|line|
      line.chomp.split " "
    }.flatten
  end
end
Rspec::Core::RakeTask.new(:spec) do |t|
#Spec::Rake::SpecTask.new('spec') do |t|
  t.pattern   = ["spec/**/server.rb", "spec/requests/**/*_spec.rb"]
#  t.opts  << '--options' << 'spec/spec.opts'
end