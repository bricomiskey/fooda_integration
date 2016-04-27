Settings.use :config_block

Settings.finally do |c|
  begin
    Settings[Rails.env] ||= {}

    Settings[Rails.env][:fooda_api_client_log_path] = "#{Rails.root}/log/#{ENV['FOODA_API_CLIENT_LOG']}"
    Settings[Rails.env][:fooda_api_uri] = "http://#{ENV['FOODA_API_HOST']}:#{ENV['FOODA_API_PORT']}"
    Settings[Rails.env][:fooda_api_version] = ENV['FOODA_API_VERSION']
  rescue => e
  end
end

Settings.resolve!
