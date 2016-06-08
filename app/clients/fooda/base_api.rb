module Fooda

  class BaseApi
    include HTTParty

    def self.call(method, api, name, options)
      LoggerFactory.logger.info({event: name, endpoint: api}.merge(options.except(:event)))
      response = send(method, api, {body: options})
      Hashie::Mash.new(JSON.parse(response.body)).merge(code: response.code)
    end

    def self.headers(options={})
      options.merge({'accept' => 'json', 'content_type' => 'application/json'})
    end

    def self.host
      Settings[Rails.env][:fooda_api_uri]
    end

    def self.version
      Settings[Rails.env][:fooda_api_version]
    end

    def self.version_1
      Settings[Rails.env][:fooda_api_version_1]
    end

    def self.version_2
      Settings[Rails.env][:fooda_api_version_2]
    end
  end

end
