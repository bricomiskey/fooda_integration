module Fooda

  class MarketsApi < BaseApi

    def self.create(params)
      api = "#{host}#{version}/markets"
      call(:post, api, "markets.api.client.#{__method__}", params)
    end

    def self.get_by(params)
      api = "#{host}#{version}/markets/by"
      call(:get, api, "markets.api.client.#{__method__}", params)
    end

  end

end
