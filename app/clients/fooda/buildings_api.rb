module Fooda

  class BuildingsApi < BaseApi

    def self.change_state(id, event)
      api = "#{host}#{version}/buildings/#{id}/event/#{event}"
      call(:put, api, "buildings.api.client.#{__method__}", {})
    end

    def self.create(params)
      api = "#{host}#{version}/buildings"
      call(:post, api, "buildings.api.client.#{__method__}", params)
    end

    def self.get_by(params)
      api = "#{host}#{version}/buildings/by"
      call(:get, api, "buildings.api.client.#{__method__}", params)
    end

  end

end
