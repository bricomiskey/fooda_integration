module Fooda

  class SelectScheduleApi < BaseApi

    def self.get_schedule(params)
      api = "#{host}#{version_1}/schedule"
      call(:get, api, "#{name.underscore}.#{__method__}", params)
    end

  end

end
