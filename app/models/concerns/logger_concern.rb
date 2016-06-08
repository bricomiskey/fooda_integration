module LoggerConcern

  extend ActiveSupport::Concern

  def log(s)
    logger.info(s)
  end

  def logger
    @logger ||= Logger.new(STDOUT)
  end

end
