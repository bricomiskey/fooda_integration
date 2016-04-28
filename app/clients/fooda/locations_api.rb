module Fooda

  class LocationsApi < BaseApi

    def self.create(params)
      api = "#{host}#{version}/locations"
      call(:post, api, "#{name.underscore}.#{__method__}", params)
    end

    def self.get_by(params)
      api = "#{host}#{version}/locations/by"
      call(:get, api, "#{name.underscore}.#{__method__}", params)
    end

  end

end
