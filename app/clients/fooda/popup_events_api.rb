module Fooda

  class PopupEventsApi < BaseApi

    def self.change_state(id, event, params)
      api = "#{host}#{version}/popup_events/#{id}/event/#{event}"
      call(:put, api, "#{name.underscore}.#{__method__}", params)
    end

    def self.create(params)
      api = "#{host}#{version}/popup_events"
      call(:post, api, "#{name.underscore}.#{__method__}", params)
    end

    def self.get_by(params)
      api = "#{host}#{version}/popup_events/by"
      call(:get, api, "#{name.underscore}.#{__method__}", params)
    end

  end

end
