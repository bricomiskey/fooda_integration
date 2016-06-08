module Fooda

  class OrdersApi < BaseApi

    def self.create(params)
      api = "#{host}#{version_1}/orders"
      call(:post, api, "#{name.underscore}.#{__method__}", params)
    end

  end

end
