require 'json'
require 'uri'
require 'net/https'
require 'viaduct/web_push/channel'

module Viaduct
  module WebPush

    class Error < StandardError; end

    class << self

      #
      # Return the host for the VWP service
      # 
      def webpush_host
        @webpush_host ||= 'webpush.viaduct.io'
      end

      #
      # Return the endpoint for API request
      #
      def endpoint
        @endpoint ||= "https://#{self.webpush_host}/vwp/api"
      end

      #
      # Return the application token
      #
      def token
        @token || ENV['WEBPUSH_TOKEN'] || raise(Error, "Must set `Viaduct::WebPush.token` to an application token")
      end

      #
      # Return the application secret
      #
      def secret
        @secret || ENV['WEBPUSH_SECRET'] || raise(Error, "Must set `Viaduct::WebPush.secret` to an application secret")
      end

      #
      # Allow some configuration to be overridden/set
      #
      attr_writer :webpush_host
      attr_writer :endpoint
      attr_writer :token
      attr_writer :secret

      #
      # Initialize a new channel with the given name (caching it for future use)
      #
      def [](name)
        @channels ||= {}
        @channels[name] ||= Channel.new(name)
      end


      #
      # Make an HTTP request to the WebPush API
      #
      def request(action, params = {})
        uri = URI.parse(self.endpoint + "/#{action}")
        request = Net::HTTP::Post.new(uri.path)
        request.set_form_data(params.merge(:token => self.token, :secret => self.secret))
        http = Net::HTTP.new(uri.host, uri.port)
        if uri.scheme == 'https'
          http.use_ssl = true
        end
        Timeout.timeout(5) do
          result = http.request(request)
          result.is_a?(Net::HTTPSuccess)
        end
      rescue Exception, Timeout::Error => e
        raise Error, "An error occurred while sending data to the WebPush HTTP API. #{e.to_s}"
      end

    end
  end
end
