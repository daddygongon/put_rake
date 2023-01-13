# frozen_string_literal: true
require "thor"
require "fileutils"

require_relative "put_rake/version"
#require_relative "put_rake/cli"
# https://github.com/rails/thor/wiki

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

    desc "path", "show Rakefile template path"

    def path
      additional_path = ENV["PUT_RAKE_PATH"].split(":")
      @gem_template_dirs = [
        File.join(File.dirname(__FILE__), 'templates'),additional_path
      ].flatten
      puts"Rakefile template paths : #{@gem_template_dirs.join(",")}"
    end

    desc "add PATH", "add Rakefile template PATH"

    def add(*args)
      add = args[0]
      puts "Additional template paths are obtained from ENV['PUT_RAKE_PATH']."
      puts "Add default paths, put 'setenv PUT_RAKE_PATH ...' on ~/.config/fish/fishconfig.fish."
      p additional_path = [ENV["PUT_RAKE_PATH"].split(":"), add].join(":")
      p comm = "setenv #{additional_path}"
      system comm
    end

    desc "for [EXT]", "put Rakefile for [EXT]"
    method_option :force, :type => :boolean, :default => false,
                  :aliases => "-f", :desc => "forcely replace"
    # method_option :force => false, :aliases => "-f", :desc => "forcely replace"
    method_option :add, :type => :boolean, :default => false,
                  :aliases => "-a", :desc => "add to the Rakefile"
    def for(*args)
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
      path()
      #      gem_template_dir = File.join(File.dirname(__FILE__), 'templates')
      @gem_template_dirs.each do |gem_template_dir|
        files = File.join(gem_template_dir,'*')
        Dir.glob(files).each do |file|
          puts File.basename(file)
        end
      end
    end

  end
end
