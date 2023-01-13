# frozen_string_literal: true
require "thor"
require "fileutils"

require_relative "put_rake/version"
#require_relative "put_rake/cli"
# 

module PutRake
  class Error < StandardError; end
  # Your code goes here...
  class CLI < Thor
    package_name 'put_rake'
    map "-v" => :version
    map "--version" => :version

    desc "version", "show version"

    def version
      print "put_rake #{VERSION}"
    end

    desc "for [EXT]", "put Rakefile for [EXT]"
    method_option :force, :type => :boolean, :default => false,
                  :aliases => "-f", :desc => "forcely replace"
    method_option :add, :type => :boolean, :default => false,
                  :aliases => "-a", :desc => "add on the Rakefile"
    def for(*args)
      gem_template_dir = File.join(File.dirname(__FILE__), 'templates')
      file = "Rakefile_#{args[0]}"
      if File.exists?("./Rakefile")
        if options[:force]
          comm = "cp #{File.join(gem_template_dir,file)} ./Rakefile"
        elsif options[:add]
          comm = "cat #{File.join(gem_template_dir,file)} >> ./Rakefile"
        else
          comm = "echo 'Rakefile exists. -f(orce) or -a(dd) available.'"
        end
      else
        comm = "cp #{File.join(gem_template_dir,file)} ./Rakefile"
      end
      puts comm
      system comm
    end

    desc "list", "list available Rakefiles"
    def list
      gem_template_dir = File.join(File.dirname(__FILE__), 'templates')
      files = File.join(gem_template_dir,'*')
      Dir.glob(files).each do |file|
        puts File.basename(file)
      end
    end

  end
end
