# -*- coding: utf-8 -*-
require "colorize"
require 'command_line/global'

Rake::TaskManager.record_task_metadata = true

task :default do
  Rake.application.options.show_tasks = :tasks
  Rake.application.options.show_task_pattern = //
  Rake.application.display_tasks_and_comments
end

namespace :some_name_space do
  desc "task description" #desc -> description
  task :task_name do # any name on task_name
    # your code goes here
  end
end
