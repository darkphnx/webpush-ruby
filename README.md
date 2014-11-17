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

```ruby
require 'viaduct/webpush'

Viaduct::WebPush.token = 'your-token'
Viaduct::WebPush.secret = 'your-secret'

# Sending a single message
Viaduct::WebPush['test-channel'].trigger('say-hello', {
  :name => 'Adam'
})

# Sending a message to multiple channels
Viaduct::WebPush::Channel.multi_trigger(['channel1', 'channel2'], 'say-hello', {
  :name => 'Adam'
})
```
