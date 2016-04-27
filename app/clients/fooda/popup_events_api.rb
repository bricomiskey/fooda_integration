module Fooda

  class PopupEventsApi < BaseApi

    def self.create(params)
      api = "#{host}#{version}/popup_events"
      call(:post, api, "popup_events.api.client.#{__method__}", params)
    end

  end

end
