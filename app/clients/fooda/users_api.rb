module Fooda

  class UsersApi < BaseApi

    def self.create(params)
      api = "#{host}#{version_2}/users"
      call(:post, api, "#{name.underscore}.#{__method__}", params)
    end

    def self.create_credit_card(params)
      api = "#{host}#{version_1}/users/credit_cards"
      call(:post, api, "#{name.underscore}.#{__method__}", params)
    end

    def self.get_by(params)
      api = "#{host}#{version_2}/users/by"
      call(:get, api, "#{name.underscore}.#{__method__}", params)
    end

    def self.get_credit_cards(params)
      api = "#{host}#{version_1}/users/credit_cards"
      call(:get, api, "#{name.underscore}.#{__method__}", params)
    end

  end

end
