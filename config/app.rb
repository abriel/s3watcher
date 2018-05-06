require 'bundler/setup'
Bundler.require

OTR::ActiveRecord.configure_from_file!(
  File.join(File.dirname(File.expand_path(__FILE__)), 'database.yml')
)
