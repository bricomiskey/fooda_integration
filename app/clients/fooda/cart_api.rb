module Fooda

  class CartApi < BaseApi

    def self.add_item(params)
      api = "#{host}#{version_1}/cart/items"
      call(:post, api, "#{name.underscore}.#{__method__}", params)
    end

    def self.get_items(params)
      api = "#{host}#{version_1}/cart/items"
      call(:get, api, "#{name.underscore}.#{__method__}", params)
    end

    def self.get_price(params)
      api = "#{host}#{version_1}/cart/price"
      call(:get, api, "#{name.underscore}.#{__method__}", params)
    end

  end

end
