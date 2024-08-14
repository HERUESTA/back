require_relative "application"
Rails.application.initialize!

Rails.application.configure do

  config.hosts << "api"
end
