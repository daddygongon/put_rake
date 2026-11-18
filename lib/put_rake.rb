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
      @gem_template_dirs = template_dirs
      puts "* Rakefile template paths\n  #{@gem_template_dirs.join("\n  ")}"
    end

    desc "add PATH", "How to add Rakefile template PATH"
    def add(*args)
      add = args[0]
      puts "Additional template paths are obtained from ENV['PUT_RAKE_PATH']."
      ENV["PUT_RAKE_PATH"] ||= ''
      p additional_path = [add, ENV["PUT_RAKE_PATH"].split(" ")].join(" ")
      puts "Add default paths, put 
\'setenv PUT_RAKE_PATH \'#{additional_path}\'\' 
on ~/.config/fish/fishconfig.fish."
#      p comm = "set -Ux PUT_RAKE_PATH \'#{additional_path}\'"
#      system comm
    end

    desc "for [EXT]", "put Rakefile for [EXT]"
    method_option :force, :type => :boolean, :default => false,
                          :aliases => "-f", :desc => "forcely replace"
    # method_option :force => false, :aliases => "-f", :desc => "forcely replace"
    method_option :add, :type => :boolean, :default => false,
                        :aliases => "-a", :desc => "add to the Rakefile"

    def for(*args)
      files = ["#{args[0]}.rake", "Rakefile_#{args[0]}"]
      list()
      @file_path = @rake_file_path.select do |path|
        files.include?(File.basename(path))
      end
      if @file_path.size != 1 #check multiple name
        comment = <<~"HEREDOC"
Multiple file name #{args}: edit source Rakefile name first.\n
#{@file_path.join("\n")}
HEREDOC
        puts comment
        exit
      end
      @file_path = @file_path[0]
      if File.exist?("./Rakefile") # check exist and -a -f
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

    desc "migrate", "rename legacy Rakefile_* templates to *.rake"
    method_option :dry_run, :type => :boolean, :default => false,
                            :aliases => "-n", :desc => "show changes without renaming"

    def migrate
      puts options[:dry_run] ? "* Template migration (dry run)" : "* Template migration"

      template_dirs.each do |template_dir|
        puts "** #{template_dir}"
        unless Dir.exist?(template_dir)
          puts "   skipped: directory does not exist"
          next
        end

        Dir.glob(File.join(template_dir, "Rakefile_*")).sort.each do |source|
          next unless File.file?(source)
          next if source.end_with?("~")

          key = legacy_template_key(source)
          destination = File.join(template_dir, "#{key}.rake")

          if File.exist?(destination)
            puts "   skipped: #{File.basename(source)} -> #{File.basename(destination)} (destination exists)"
          else
            puts "   #{File.basename(source)} -> #{File.basename(destination)}"
            FileUtils.mv(source, destination) unless options[:dry_run]
          end
        end
      end
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
          next unless File.file?(file)

          key = template_key(file)
          next unless key

          @rake_file_path << file
          res = command_line "rake -T -f #{file}"
          command = res.stdout.split("\n").collect do |line|
            line.include?(key) ? line : nil
          end
          if command.compact[0] != nil
            puts "%20s: %s" % [key, command.compact[0].scan(/#.+/)[0]]
          else
            puts "%20s: %s" % [key, File.basename(file)]
          end
        end
      end
    end

    no_commands do
      def template_dirs
        additional_paths = (ENV["PUT_RAKE_PATH"] || "").split(":").reject(&:empty?)
        [File.join(File.dirname(__FILE__), "templates"), *additional_paths].uniq
      end

      def legacy_template_key(file)
        File.basename(file).delete_prefix("Rakefile_")
      end

      def template_key(file)
        basename = File.basename(file)
        return legacy_template_key(file) if basename.start_with?("Rakefile_")
        return File.basename(file, ".rake") if File.extname(file) == ".rake"

        nil
      end
    end
  end
end
