module Fooda

  class AccountsApi < BaseApi

    def self.create(params)
      api = "#{host}#{version}/accounts"
      call(:post, api, "accounts.api.client.#{__method__}", params)
    end

    def self.get_by(params)
      api = "#{host}#{version}/accounts/by"
      call(:get, api, "accounts.api.client.#{__method__}", params)
    end

  end

end
