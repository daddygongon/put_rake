# frozen_string_literal: true
require "thor"
require "fileutils"
require 'command_line/global'

require_relative "put_rake/version"
#require_relative "put_rake/cli"
# https://github.com/rails/thor/wiki

module PutRake
  class Error < StandardError; end

  # Your code goes here...
  class CLI < Thor
    package_name "put_rake"
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
        File.join(File.dirname(__FILE__), "templates"), additional_path,
      ].flatten
      puts "* Rakefile template paths\n  #{@gem_template_dirs.join("\n  ")}"
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
      list()
      @file_path = @rake_file_path.collect do |path|
        path if File.basename(path) == file
      end.compact!
      if @file_path.size != 1 #check multiple name
        comment = <<~"HEREDOC"
Multiple file name #{args}: edit source Rakefile name first.\n
#{@file_path.join("\n")}
HEREDOC
        puts comment
        exit
      end
      @file_path = @file_path[0]
      if File.exists?("./Rakefile") # check exist and -a -f
        if options[:force]
          comm = "cp #{@file_path} ./Rakefile"
        elsif options[:add]
          comm = "cat #{@file_path} >> ./Rakefile"
        else
          comm = "echo 'Rakefile exists. -f(orce) or -a(dd) option is available.'"
        end
      else
        comm = "cp #{@file_path} ./Rakefile"
      end
      puts comm
      system comm
    end

    desc "list", "list available Rakefiles"

    def list
      path()
      @rake_file_path = []
      puts "* Available Rakefiles"
      puts "%20s: %s" % ["EXT", "some description"]
      @gem_template_dirs.each do |gem_template_dir|
        puts "** #{gem_template_dir}"
        files = File.join(gem_template_dir, "*")
        Dir.glob(files).each do |file|
          next if file[-1] == "~"
          @rake_file_path << file
          key = file.match(/Rakefile_(.*)/)[1]
          res = command_line "rake -T -f #{file}"
          command = res.stdout.split("\n")[0]
          if command
            puts "%20s: %s" % [key, command.scan(/#.+/)[0]]
          else
            puts "%20s: %s" % [key, File.basename(file)]
          end
        end
      end
    end
  end
end
