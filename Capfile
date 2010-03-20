set :application, "rbtorrent"
set :user, "www-data"
set :use_sudo, false
 
set :scm, :git
set :repository, "git@github.com:narbsy/rbtorrent.git"
set :deploy_via, :export
set :deploy_to, "/var/www/#{application}"
 
role :app, "www.narbsy.com"
 
set :runner, user
set :admin_runner, user
 
namespace :deploy do
  task :start, :roles => [:app] do
    run "cd #{deploy_to}/current && nohup thin -C thin/production_config.yml -R config.ru start"
  end
 
  task :stop, :roles => [:app] do
    run "cd #{deploy_to}/current && nohup thin -C thin/production_config.yml -R config.ru stop"
  end
 
  task :restart, :roles => [:web, :app] do
    deploy.stop
    deploy.start
  end
 
  # This will make sure that Capistrano doesn't try to run rake:migrate (this is not a Rails project!)
  task :cold do
    deploy.update
    deploy.start
  end
end
 
namespace :acoplet do
  task :log do
    run "cat #{deploy_to}/current/log/thin.log"
  end
end


