module Fooda

  class BaseApi
    include HTTParty

    def self.call(method, api, name, options)
      LoggerFactory.logger.info({event: name, endpoint: api}.merge(options.except(:event)))
      response = send(method, api, {body: options})
      Hashie::Mash.new(JSON.parse(response.body)).merge(code: response.code)
    end

    def self.headers(options={})
      options.merge(content_type: :json, accept: :json)
    end

    def self.host
      Settings[Rails.env][:fooda_api_uri]
    end

    def self.version
      Settings[Rails.env][:fooda_api_version]
    end

  end

end
