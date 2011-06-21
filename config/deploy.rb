before("deploy:setup") { set :use_sudo, false }


set :application, "MtgTradeSnitch"
set :repository, "git@github.com:JvrBaena/MtgTradeSnitch.git"
set :use_sudo, false
set :deploy_to, "/var/www/#{application}"
set :scm, :git
set :user, "deploy"
set :branch, 'master'

set :domain, "mtgtrader.flowersinspace.com"
ssh_options[:port] = 33121
role :app, domain
role :web, domain
role :db, domain, :primary => true
set :branch, 'master'
default_run_options[:pty] = true



namespace :deploy do
  task :start, :roles => :app do
    run "touch #{current_release}/tmp/restart.txt"
  end

  task :stop, :roles => :app do
    # Do nothing.
  end

  desc "Restart Application"
  task :restart, :roles => :app do
    run "touch #{current_release}/tmp/restart.txt"
  end

  desc "Run bundler task to bundle app"
  task :bundle, :roles => :app do
    # run "cd #{current_release} && bundle install --path #{deploy_to}/shared/bundle --without test:development"
    # run "cd #{current_release} && bundle install --without test:development"
  end

  desc "Updates the symlink for config files to the just deployed release."
  task :symlink_configs do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    run "ln -nfs #{shared_path}/public/system #{release_path}/public/system"
  end

  task :bootstrap do
    # run "cd #{release_path}; RAILS_ENV=production rake db:migrate"
    # run "cd #{release_path}; RAILS_ENV=production ./script/delayed_job restart"
    # uncomment if you run BigTuna in BigTuna so that it gets build automatically
    # you will need to set up valid hook name in project config
    # run "curl --request POST --silent http://bigtuna.your.site/hooks/build/bigtuna"
  end
end



namespace :db do
  desc "Create database yaml in shared path"
  task :default do
    db_config = ERB.new <<-EOF
    base: &base
      adapter: mysql2
      username: root
      password:
      encoding: utf8
      socket: /var/run/mysqld/mysqld.sock

    development:
      database: #{application}_development
      <<: *base

    pre:
      database: #{application}_pre
      <<: *base

    production:
      database: #{application}_production
      <<: *base

    sandbox:
      production



    EOF

    run "mkdir -p #{shared_path}/config"
    put db_config.result, "#{shared_path}/config/database.yml"
  end


  desc "Crea un backup de la base de datos antes de correr migraciones"
  task 'backup' do
    run "mkdir -p #{current_path}/db/backups"
    run "mysqldump -u root  #{application}_production | gzip > #{current_path}/db/backups/#{application}_production_#{Time.now.strftime '%Y%m%dT%:%H%M%S'}.gzip"
  end


  desc "Make symlink for database yaml"
  task :symlink do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    run "ln -nfs #{shared_path}/public/system #{release_path}/public/system"
  end

  desc "Crea la base de datos de inicio"
  task :seed, :roles => :db do
    run("cd #{current_path}; RAILS_ENV=production rake db:seed")
  end
end

namespace :bundler do
  task :create_symlink, :roles => :app do
    shared_dir = File.join(shared_path, 'bundle')
    release_dir = File.join(current_release, '.bundle')
    run("mkdir -p #{shared_dir} && ln -s #{shared_dir} #{release_dir}")
  end

  task :bundle_new_release, :roles => :app do
    bundler.create_symlink
    run "cd #{release_path} && bundle install --without test"
  end
end

after 'deploy:update_code', 'bundler:bundle_new_release'

before "deploy:setup", :db
after "deploy:update_code", "deploy:bundle"
after "deploy:finalize_update", "deploy:symlink_configs"
before "deploy:restart", "deploy:bootstrap"
