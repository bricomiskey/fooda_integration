class LoggerFactory

  def self.logger
    @@logger ||= create
  end

  def self.create
    case Rails.env
    when /.*/
      LogStashLogger.new(
        type: :file,
        path: Settings[Rails.env][:fooda_api_client_log_path],
        sync: true
      )
    end
  end

end
