module Fooda

  class VendorsApi < BaseApi

    def self.create(params)
      api = "#{host}#{version}/vendors"
      call(:post, api, "#{name.underscore}.#{__method__}", params)
    end

    def self.get_by(params)
      api = "#{host}#{version}/vendors/by"
      call(:get, api, "#{name.underscore}.#{__method__}", params)
    end

  end

end
