module Fooda

  class PingApi < BaseApi

    def self.ping(params={})
      api = "#{host}#{version_2}/ping"
      call(:get, api, "#{name.underscore}.#{__method__}", params)
    end

  end

end
