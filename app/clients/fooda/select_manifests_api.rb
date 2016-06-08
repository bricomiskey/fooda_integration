module Fooda

  class SelectManifestsApi < BaseApi

    def self.create(params)
      api = "#{host}#{version_2}/select_manifests"
      call(:post, api, "#{name.underscore}.#{__method__}", params)
    end

    def self._get(id, params)
      api = "#{host}#{version_2}/select_manifests/#{id}"
      call(:get, api, "#{name.underscore}.#{__method__}", params)
    end

    def self._send(id, params)
      api = "#{host}#{version_2}/select_manifests/#{id}/send"
      call(:put, api, "#{name.underscore}.#{__method__}", params)
    end

  end

end
