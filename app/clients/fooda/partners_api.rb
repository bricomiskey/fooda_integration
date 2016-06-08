module Fooda
  class PartnersApi < BaseApi
    class << self
      def create(params)
        api = "#{host}#{version}/partners"
        call(:post, api, "partners.api.client.#{__method__}", params)
      end

      def get_by(params)
        api = "#{host}#{version}/partners/by"
        call(:get, api, "partners.api.client.#{__method__}", params)
      end
    end
  end
end
