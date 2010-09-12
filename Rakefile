# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)
require 'rake'

namespace :deploy do
  desc "deploy all files to remote"
  task :all do
    require 'config/deployer.rb'
    deploy
  end

  desc "watches the directory for changes, deploying those"
  task :watch do
    require 'directory_watcher'
    require 'config/deployer.rb'
    # watch the files that we use, essentially. Use EventMachine so it doesn't poll.
    # supress the initial add events
    dw = DirectoryWatcher.new '.', :glob => '**/*.{rb,js,haml,sass,swf}', :scanner => :em, :pre_load => true
    dw.add_observer do |*args|
      # args.each { |e| puts e.last }
      files = args.select { |e| e[0] =~ /modified|added/ }.map { |e| e[1] }.uniq
      unless files.empty?
        deploy files
        puts "#{ Time.now }:\tRedeployed: #{ files.inspect }"
      end
    end

    # only scan every 5 seconds or so.
    # dw.interval = 5
    dw.start
    while true
      # need to specify stdin, else rake does some strange things
      input = $stdin.gets
      break if input.chomp == "exit"
    end
    puts "not watching anymore!"
  end
end


Rbtorrent::Application.load_tasks
