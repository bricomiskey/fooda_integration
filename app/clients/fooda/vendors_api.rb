module Fooda

  class VendorsApi < BaseApi

    def self.change_state(id, event, params)
      api = "#{host}#{version}/vendors/#{id}/event/#{event}"
      call(:put, api, "#{name.underscore}.#{__method__}", params)
    end

    def self.create(params)
      api = "#{host}#{version}/vendors"
      call(:post, api, "#{name.underscore}.#{__method__}", params)
    end

    def self.get_by(params)
      api = "#{host}#{version}/vendors/by"
      call(:get, api, "#{name.underscore}.#{__method__}", params)
    end

    def self.update(id, params)
      api = "#{host}#{version}/vendors/#{id}"
      call(:put, api, "#{name.underscore}.#{__method__}", params)
    end
  end

end
