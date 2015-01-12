module Viaduct
  module WebPush
    module WebSocket
      class RawSocket

        WAIT_EXCEPTIONS  = [Errno::EWOULDBLOCK, Errno::EAGAIN, IO::WaitReadable]

        #
        # Open an SSL connection and perform the HTTP upgrade/websockets handhsake procedure
        # 
        def initialize
          @handshake = ::WebSocket::Handshake::Client.new(:url => Viaduct::WebPush::WebSocket.endpoint)
          @connection = TCPSocket.new(@handshake.host, @handshake.port || 443)

          ssl_ctx = OpenSSL::SSL::SSLContext.new
          ssl_ctx.verify_mode = OpenSSL::SSL::VERIFY_PEER
          ssl_ctx.cert_store = OpenSSL::SSL::SSLContext::DEFAULT_CERT_STORE

          ssl = OpenSSL::SSL::SSLSocket.new(@connection, ssl_ctx)
          ssl.sync_close = true
          ssl.connect

          @connection = ssl

          @connection.write @handshake.to_s
          @connection.flush

          while line = @connection.gets
            @handshake << line
            break if @handshake.finished?
          end

          raise HandshakeError unless @handshake.valid?
        end

        #
        # Send a websocket frame out on the connection
        # 
        def send_data(message, type=:text)
          frame = ::WebSocket::Frame::Outgoing::Client.new(:version => @handshake.version, :data => message, :type => type)
          @connection.write frame.to_s
          @connection.flush
        end

        #
        # Read data from the socket and wait with IO#select
        # 
        def receive
          frame = ::WebSocket::Frame::Incoming::Server.new(:version => @handshake.version)

          begin
            data = @connection.read_nonblock(1024)
          rescue *WAIT_EXCEPTIONS
            IO.select([@connection])
            retry
          end
          frame << data

          messages = []
          while message = frame.next
            messages << message.to_s
          end

          messages
        end

        #
        # Close the connection
        # 
        def disconnect
          @connection.close
        end
      end

    end
  end
end
