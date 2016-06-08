Settings.use :config_block

Settings.finally do |c|
  begin
    Settings[Rails.env] ||= {}

    Settings[Rails.env][:fooda_api_client_log_path] = "#{Rails.root}/log/#{ENV['FOODA_API_CLIENT_LOG']}"
    Settings[Rails.env][:fooda_api_uri] = "http://#{ENV['FOODA_API_HOST']}:#{ENV['FOODA_API_PORT']}"
    Settings[Rails.env][:fooda_api_version] = ENV['FOODA_API_VERSION']
    Settings[Rails.env][:fooda_api_version_1] = ENV['FOODA_API_VERSION_1']
    Settings[Rails.env][:fooda_api_version_2] = ENV['FOODA_API_VERSION_2']
  rescue => e
  end
end

Settings.resolve!
