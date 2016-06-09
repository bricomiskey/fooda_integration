module ExpressPigeon

  class CampaignsApi < BaseApi

    def self._get(id, params={})
      api = "#{uri}/campaigns/#{id}"
      call(:get, api, "#{name.underscore}.#{__method__}", params)
    end

    def self.list(params={})
      api = "#{uri}/campaigns"
      call(:get, api, "#{name.underscore}.#{__method__}", params)
    end

  end

end
