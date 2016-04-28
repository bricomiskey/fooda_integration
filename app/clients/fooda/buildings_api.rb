module Fooda

  class BuildingsApi < BaseApi

    def self.change_state(id, event)
      api = "#{host}#{version}/buildings/#{id}/event/#{event}"
      call(:put, api, "#{name.underscore}.#{__method__}", {})
    end

    def self.create(params)
      api = "#{host}#{version}/buildings"
      call(:post, api, "#{name.underscore}.#{__method__}", params)
    end

    def self.get_by(params)
      api = "#{host}#{version}/buildings/by"
      call(:get, api, "#{name.underscore}.#{__method__}", params)
    end

  end

end
