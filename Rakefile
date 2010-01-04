#!/usr/bin/env ruby
$:.unshift(File.expand_path(File.join(File.dirname(__FILE__), 'lib')))
require 'rubygems'
require 'quantity'
require 'spec'
require 'spec/rake/spectask'
require 'yard'


desc "Run specs"
Spec::Rake::SpecTask.new('spec') do |t|
  #t.spec_files = FileList['spec/unit.spec','spec/dimension.spec','spec/quantity.spec']
  t.spec_files = FileList['spec/dimension.spec', 'spec/unit.spec', 'spec/systems.spec']
  t.spec_opts = ["-cfn"]
end

desc "specs with backtrace"
Spec::Rake::SpecTask.new('tracespec') do |t|
  #t.spec_files = FileList['spec/unit.spec','spec/dimension.spec','spec/quantity.spec']
  t.spec_files = FileList['spec/dimension.spec', 'spec/unit.spec', 'spec/systems.spec']
  t.spec_opts = ["-bcfn"]
end

desc "package yardocs"
YARD::Rake::YardocTask.new('yard') do |t|
  # see .yardopts for the action
end

