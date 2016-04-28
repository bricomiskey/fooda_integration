module Fooda

  class PopupEventsApi < BaseApi

    def self.change_state(id, event)
      api = "#{host}#{version}/popup_events/#{id}/event/#{event}"
      call(:put, api, "#{name.underscore}.#{__method__}", {})
    end

    def self.create(params)
      api = "#{host}#{version}/popup_events"
      call(:post, api, "#{name.underscore}.#{__method__}", params)
    end

  end

end
