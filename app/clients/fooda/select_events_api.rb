module Fooda

  class SelectEventsApi < BaseApi

    def self.create(params)
      api = "#{host}#{version}/select_events"
      call(:post, api, "#{name.underscore}.#{__method__}", params)
    end

    def self.get_by(params)
      api = "#{host}#{version}/select_events/by"
      call(:get, api, "#{name.underscore}.#{__method__}", params)
    end

    def self.search(params)
      api = "#{host}#{version}/select_events/search"
      call(:get, api, "#{name.underscore}.#{__method__}", params)
    end

    def self.update(id, params)
      api = "#{host}#{version}/select_events/#{id}"
      call(:put, api, "#{name.underscore}.#{__method__}", params)
    end

  end

end
