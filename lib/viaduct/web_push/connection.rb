module Viaduct
  module WebPush
    class Connection

      attr_reader :connected, :session_id, :channels, :authenticated

      def initialize(options={})
        @options = options

        @connected = false
        @authenticated = false
        @session_id = nil
        @channels = {}
        @logger = WebPush.logger

        # Set up global vwp events
        @global_channel = subscribe(nil)

        # On connect, store data from the payload, send vwp:subscribe events
        # for each channel that's already been addded
        @global_channel.bind 'vwp:connected' do |data|
          @logger.info "Connected to vwp"

          @global_channel.subscribed = true
          @session_id = data["session_id"]
          @connected = true

          register_subscriptions
        end

        # If we're sending messages we need to authenticate after we've connected to vwp
        if @options[:authenticate]
          @global_channel.bind 'vwp:connected' do
            authenticate
          end
          @global_channel.bind 'vwp:authenticated' do 
            @logger.info "Authenticated with vwp"
            @authenticated = true
          end
        end

        # When we've successfully subscribed to a channel set the subscribed bit to true on the channel
        @global_channel.bind 'vwp:subscribed' do |data|
          channel_id = data['channel']
          @channels[channel_id].subscribed = true
          @logger.info "Subscribed to vwp #{data['channel_name']}"
        end
      end

      def [](channel_name)
        @channels[channel_name]
      end

      #
      # Create a new channel object and send a vwp:subscribe event if we're
      # already connected to vwp
      # 
      def subscribe(channel_name)
        @channels[channel_name] ||= Channel.new(channel_name, self)
        @channels[channel_name].register if @connected 
        @channels[channel_name]
      end

      #
      # Create a new thread and connect to vwp in it.
      # Create an event loop for the thread which will dispatch incoming messages
      # 
      def connect
        return if @websocket
        @logger.debug "Connecting..."

        Thread.abort_on_exception = true
        @websocket_thread = Thread.new do
          @websocket = WebSocket.new
          loop do
            @websocket.receive.each do |message|
              data = JSON.parse(message)
              @logger.debug data
              dispatch(data)
            end
          end
        end

        self
      end

      #
      # Disconnect the websocket server and reset all variables, set all channels
      # as unsubscribed
      # 
      def disconnect
        @websocket.disconnect
        @websocket = nil
        @websocket_thread.kill
        @websocket_thread = nil
        @connected = false
        @session_id = nil
        @channels.each {|name, chan| chan.subscribed = false }
        @logger.info "Disconnected from vwp"
      end

      #
      # Build a vwp message and send it via the websocket
      # 
      def trigger(channel_name, event, data)
        payload = JSON.generate({
          "event" => "vwp:send",
          "data" => {
            "channel" => channel_name,
            "event" => event,
            "data" => data
          }
        })

        @websocket.send_data(payload)
        true
      end

      #
      # Send a vwp:subscribe message via the websocket. The socket name and signature
      # are calculated by the Channel
      #
      def register_subscription(channel_name, signature)
        payload = JSON.generate({"event" => "vwp:subscribe", "data" => {
          "channel" => channel_name,
          "signature" => signature
        }})
        @websocket.send_data(payload)
      end

      def inspect
        String.new.tap do |s|
          s << "#<#{self.class.name}:#{self.object_id} "
          s << [:connected, :session_id, :channels].map do |attrib|
            "#{attrib}: #{self.send(attrib).inspect}"
          end.join(', ')
          s << ">"
        end
      end

      protected

      #
      # Process some payload data and dispatch the message to the relevant
      # channel. The channel will then dispatch the data to the correct binding.
      # 
      def dispatch(payload_data)
        event = payload_data['event']
        channel = payload_data['channel']
        data = payload_data['data']

        if @channels[channel]
          @channels[channel].dispatch(event, data)
        end
      end

      # Send a vwp:subscribe message for every channel
      def register_subscriptions
        @channels.each do |name, chan|
          chan.register
        end
      end

      #
      # Send a vwp:authenticate message that we need if we're going to be sending data
      # on the websocket.
      # 
      def authenticate
        @logger.debug "Authenticating..."

        payload = JSON.generate({"event" => "vwp:authenticate", "data" => {
          "secret" => Viaduct::WebPush.secret
        }})
        @websocket.send_data(payload)
      end

    end
  end
end
