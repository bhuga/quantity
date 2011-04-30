#!/usr/bin/env ruby
$:.unshift(File.expand_path(File.join(File.dirname(__FILE__), 'lib')))
require 'quantity'

require "rubygems"
require "bundler"
Bundler::GemHelper.install_tasks

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require 'spec'
require 'spec/rake/spectask'
require 'yard'

desc "Run specs"
Spec::Rake::SpecTask.new('spec') do |t|
  t.spec_files = FileList['spec/quantity.spec']
  t.spec_opts = ["-cfn"]
end

desc "Run unit specs"
Spec::Rake::SpecTask.new('unit') do |t|
  t.spec_files = FileList['spec/dimension.spec', 'spec/unit.spec', 'spec/systems.spec']
  t.spec_opts = ["-cfn"]
end

desc "specs with backtrace"
Spec::Rake::SpecTask.new('tracespec') do |t|
  t.spec_files = FileList['spec/quantity.spec']
  t.spec_opts = ["-bcfn"]
end

desc "unit specs with backtrace"
Spec::Rake::SpecTask.new('traceunit') do |t|
  t.spec_files = FileList['spec/dimension.spec', 'spec/unit.spec', 'spec/systems.spec']
  t.spec_opts = ["-bcfn"]
end

desc "package yardocs"
YARD::Rake::YardocTask.new('yard') do |t|
  # see .yardopts for the action
end
