class BaseData

  attr_reader :logger

  def initialize(options={})
    @logger = Logger.new(STDOUT)
  end

  def log(s)
    @logger.info(s)
  end

end
