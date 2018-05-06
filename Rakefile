require 'bundler/setup'
load 'tasks/otr-activerecord.rake'
require_relative 'lib/s3watcher/tasks'

namespace :db do
  task :environment do
    require_relative 'config/app'
  end
end

namespace :s3watcher do
  task :environment do
    require_relative 'config/app'
    require_relative 'app/models'
    ActiveRecord::Base.logger.level = Logger::INFO
  end
end
