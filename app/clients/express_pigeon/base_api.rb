module ExpressPigeon

  class BaseApi
    include HTTParty

    default_options.update(verify: false)

    def self.call(method, api, name, options)
      LoggerFactory.logger.info({event: name, endpoint: api}.merge(options.except(:event)))
      response = send(method, api, {body: options, headers: headers})

      json = JSON.parse(response.body)
      if json.is_a?(Array)
        json.map{ |o|   Hashie::Mash.new(o) }
      else
        Hashie::Mash.new(json).merge(code: response.code)
      end
    end

    def self.headers(options={})
      options.merge({'accept' => 'json', 'content_type' => 'application/json', 'X-auth-key' => '4f480ec3-6b4b-4d98-8113-6433b86ad15f'})
    end

    def self.uri
      Settings[Rails.env][:express_pigeon_api_uri]
    end
  end

end
