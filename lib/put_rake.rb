# frozen_string_literal: true
require "thor"
require "fileutils"
require "pp"
require "yaml"
require "command_line/global"

require_relative "put_rake/version"
#require_relative "put_rake/cli"
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
    def for(*args)
      gem_template_dir = File.join(File.dirname(__FILE__), 'templates')
      file = "Rakefile_#{args[0]}"
      if File.exists?("./Rakefile")
        puts "Rakefile exists."
      else
        comm = "cp #{File.join(gem_template_dir,file)} ./Rakefile"
        system comm
      end
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
