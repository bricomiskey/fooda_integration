module Fooda

  class SelectMenusApi < BaseApi

    def self.get_menu(event_id, vendor_id, params)
      api = "#{host}#{version_1}/select/events/#{event_id}/vendors/#{vendor_id}/menu"
      call(:get, api, "#{name.underscore}.#{__method__}", params)
    end

  end

end
