# Class for sending messages to viaduct via the HTTP API

module Viaduct
  module WebPush
    class Channel

      def initialize(name)
        @name = name
      end

      #
      # Trigger an event on this channel
      #
      def trigger(event, data = {})
        self.class.trigger(@name, event, data)
      end

      #
      # Trigger a single even on a given channel
      #
      def self.trigger(channel, event, data = {})
        WebPush.request('trigger', {:channel => channel, :event => event, :data => data.to_json})
      end


      #
      # Trigger an event on multiple channels simultaneously
      #
      def self.multi_trigger(channels, event, data = {})
        raise Error, "`channels` must an arrayof strings" unless channels.all? { |c| c.is_a?(String) }
        WebPush.request('trigger', {:channel => channels.join(','), :event => event, :data => data.to_json})
      end

      #
      # Generate a HMAC signature for private channels
      #
      def self.generate_signature(session_id, channel)
        OpenSSL::HMAC.hexdigest(OpenSSL::Digest::SHA256.new, WebPush.secret, "#{session_id}:#{channel}")
      end

    end
  end
end
