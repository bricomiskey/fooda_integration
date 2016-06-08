module Fooda

  class AccountsApi < BaseApi

    def self.add_user(id, params)
      api = "#{host}#{version}/accounts/#{id}/users"
      call(:post, api, "#{name.underscore}.#{__method__}", params)
    end

    def self.create(params)
      api = "#{host}#{version}/accounts"
      call(:post, api, "#{name.underscore}.#{__method__}", params)
    end

    def self.get_by(params)
      api = "#{host}#{version}/accounts/by"
      call(:get, api, "#{name.underscore}.#{__method__}", params)
    end

  end

end
