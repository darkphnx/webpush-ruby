require 'logger'
require 'websocket'
require 'viaduct/web_push/web_socket/raw_socket'
require 'viaduct/web_push/web_socket/connection'
require 'viaduct/web_push/web_socket/channel'

module Viaduct
  module WebPush
    module WebSocket

      class HandshakeError < StandardError; end

      class << self

        attr_writer :logger
        attr_writer :endpoint

        #
        # Initialize a websocket connection for sending and receiving messages
        # 
        def connection(options={})
          @connection ||= Connection.new(options)
        end

        #
        # Return the endpoint for the websocket server
        # 
        def endpoint
          @endpoint ||= "wss://#{Viaduct::WebPush.webpush_host}/vwp/socket/#{Viaduct::WebPush.token}"
        end 


        def logger
          @logger ||= Logger.new(STDOUT)
        end
      
      end
    end
  end
end
