# Viaduct WebPush Ruby Client

This is a Ruby Client for the Viaduct WebPush service. The WebPush service
allows you to easily provide real-time messaging to your users in their browsers.

## Installation

Just add the `viaduct-webpush` gem to your `Gemfile` and run `bundle` to install
it.

```ruby
gem 'viaduct-webpush', :require => 'viaduct/webpush'
```

## Usage

### Configuration

```ruby
require 'viaduct/webpush'

Viaduct::WebPush.token = 'your-token'
Viaduct::WebPush.secret = 'your-secret'

# Additional configuration for websockets
require 'viaduct/webpush/websocket'
Viaduct::WebPush::WebSocket.logger = Your.logger # optional
```

### Sending Messages via the HTTP API

Sending messages via the HTTP API is ideal if you're sending low-frequency messages and when you don't need to receive any messages in return.

```ruby
# Sending a single message
Viaduct::WebPush['test-channel'].trigger('say-hello', {
  :name => 'Adam'
})

# Sending a message to multiple channels
Viaduct::WebPush::Channel.multi_trigger(['channel1', 'channel2'], 'say-hello', {
  :name => 'Adam'
})

# Generating a signature for private channels
Viaduct::WebPush::Channel.generate_signature(session_id, channel_name)
```

### Sending and Receiving via the Websockets API

If you want to receive data from Viaduct WebPush, or you plan on sending messages very frequently, you'll want to use the websockets API.

```ruby
# Ensure you've included the websockets classes
require 'viaduct/webpush/websocket'

# Connect to the VWP service
connection = Viaduct::WebPush::WebSocket.connection

# Subscribe to any channels you want to send/recieve on
channel1 = connection.subscribe('channel1')

# Bind a handler to a specific event that comes in on a channel
channel1.bind 'say-hello' do |received_data|
  puts received_data # deserialized JSON
end

# Send messages out on a channel
channel1.trigger('say-hello', {
  :name => "Adam"
})

# Disconnect from VWP when you're done
connection.disconnect

# Reconnect if you need to later
connection.connect
```

You can also choose not authenticate if you only want to receive messages, or not to automatically connect if you want to set up all of your bindings before connecting.

```ruby
# Do not authenticate, gives you a receive-only connection
connection = Viaduct::WebPush::WebSocket.connection(:authenticate => false)

# Do not automatically connect, set up your bindings first
connection = Viaduct::WebPush::WebSocket.connection(:autoconnect => false)

channel1 = connection.subscribe('channel1')
channel1.bind 'say-hello' do |received_data|
  puts received_data
end

connection.connect
```
