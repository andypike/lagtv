require "bundler/capistrano"

desc "Run on UAT server" 
task :uat do 
  server "50.116.25.171", :web, :app, :db, primary: true
  set :environment, "uat"
end 

desc "Run on LIVE server" 
task :live do 
  server "198.58.101.4", :web, :app, :db, primary: true
  set :environment, "live"
end 

set :application, "lagtv"
set :user, "root"
set :deploy_to, "/home/apps/#{application}"
set :deploy_via, :remote_cache
set :use_sudo, false
set :bundle_without, [:darwin, :development, :test]

set :scm, "git"
set :repository, "https://andypike@github.com/andypike/#{application}.git"
set :branch, "master"

default_run_options[:pty] = true
ssh_options[:forward_agent] = true

after "deploy", "deploy:cleanup" # keep only the last 5 releases
after "deploy", "deploy:migrate"

namespace :deploy do
  %w[start stop restart].each do |command|
    desc "#{command} unicorn server"
    task command, roles: :app, except: {no_release: true} do
      run "/etc/init.d/unicorn_#{application} #{command}"
    end
  end

  task :setup_config, roles: :app do
    sudo "ln -nfs #{current_path}/config/nginx_#{environment}.conf /etc/nginx/sites-enabled/#{application}"
    sudo "ln -nfs #{current_path}/config/unicorn_init.sh /etc/init.d/unicorn_#{application}"
    run "mkdir -p #{shared_path}/config"
    run "mkdir -p #{shared_path}/uploads"
    run "mkdir -p #{shared_path}/backups"
    put File.read("config/database.example.yml"), "#{shared_path}/config/database.yml"
    put File.read("config/newrelic.example.yml"), "#{shared_path}/config/newrelic.yml"
    put File.read("config/application.example.yml"), "#{shared_path}/config/application.yml"
    puts "Now edit the config files in #{shared_path}."
  end
  after "deploy:setup", "deploy:setup_config"

  task :symlink_config, roles: :app do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    run "ln -nfs #{shared_path}/config/newrelic.yml #{release_path}/config/newrelic.yml"
    run "ln -nfs #{shared_path}/config/application.yml #{release_path}/config/application.yml"
    run "ln -fs #{shared_path}/uploads #{release_path}/public/uploads"
    run "ln -fs #{shared_path}/backups #{release_path}/backups"
  end
  after "deploy:finalize_update", "deploy:symlink_config"

  desc "Make sure local git is in sync with remote."
  task :check_revision, roles: :web do
    unless `git rev-parse HEAD` == `git rev-parse origin/master`
      puts "WARNING: HEAD is not the same as origin/master"
      puts "Run `git push` to sync changes."
      exit
    end
  end
  before "deploy", "deploy:check_revision"

  desc "reload the database with seed data"
  task :seed do
    run "cd #{current_path}; bundle exec rake db:seed RAILS_ENV=production"
  end

  desc "Use whenever to update the crontab"
  task :whenever do
    run "cd #{current_path}; bundle exec whenever --update-crontab"
  end  

  desc "Start resque queues"
  task :start_resque do
    run "cd #{current_path}; RAILS_ENV=production QUEUE=group_email bundle exec rake environment resque:work"
  end
end

# $ cap uat rails:console
namespace :rails do
  desc "Open the rails console on one of the remote servers"
  task :console, :roles => :app do
    hostname = find_servers_for_task(current_task).first
    exec "ssh -l #{user} #{hostname} -t 'source ~/.profile && #{current_path}/script/rails c production'"
  end
end

# https://gist.github.com/1271350
namespace :backup do
  desc "Backup the database"
  task :db, :roles => :db do
    timestamp = Time.now.utc.strftime('%Y%m%d%H%M%S')
    run "cd #{current_path}; pg_dump -U lagtv #{application}_production -h localhost -f backups/#{timestamp}.sql"
    run "tar -cvzpf backups/#{timestamp}_db_backup.tar.gz backups/#{timestamp}.sql"
  end

  # desc "Backup the database and download the script"
  # task :download, :roles => :app do
  #   db
  #   timestamp = Time.now.utc.strftime('%Y%m%d%H%M%S') 
  #   run "mkdir -p backups"
  #   run "cd #{current_path}; tar -cvzpf #{timestamp}_backup.tar.gz backups"
  #   get "#{current_path}/#{timestamp}_backup.tar.gz", "#{timestamp}_backup.tar.gz"
  # end
end