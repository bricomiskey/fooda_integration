module Fooda

  class TokensApi < BaseApi

    def self.create_client(params)
      api = "#{host}#{version_2}/tokens/client"
      call(:post, api, "#{name.underscore}.#{__method__}", params)
    end

    def self.get_client(params={})
      api = "#{host}#{version_2}/tokens/client"
      call(:get, api, "#{name.underscore}.#{__method__}", params)
    end

    def self.map(params)
      api = "#{host}#{version_2}/tokens/map"
      call(:get, api, "#{name.underscore}.#{__method__}", params)
    end

  end

end
