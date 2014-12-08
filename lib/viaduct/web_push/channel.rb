module Viaduct
  module WebPush
    class Channel

      attr_accessor :subscribed, :name, :bindings

      def initialize(name, connection)
        @name = name 
        @connection = connection
        @bindings = Hash.new([])
        @subscribed = false
      end

      #
      # Blank name indicates global channel
      # 
      def global?
        @name.nil?
      end

      #
      # Bind some code to an incoming message on this channel
      # 
      def bind(event, &block)
        @bindings[event] += [block]
      end

      #
      # Run the bindings for an event
      # 
      def dispatch(event, data)
        @bindings[event].each do |binding|
          binding.call(data)
        end
      end

      #
      # Send request subscription for this channel from VWP
      # 
      def register
        return if @subscibed || global?

        signature = self.class.generate_signature(@connection.session_id, @name)
        @connection.register_subscription(@name, signature)
      end

      #
      # Trigger an event on this channel
      #
      def trigger(event, data = {})
        @connection.trigger(@name, event, data)
      end

      def inspect
        String.new.tap do |s|
          s << "#<#{self.class.name}:#{self.object_id} "
          s << [:name, :subscribed].map do |attrib|
            "#{attrib}: #{self.send(attrib).inspect}"
          end.join(', ')
          s << ">"
        end
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
