# frozen_string_literal: true

require 'sequel'
require 'pg'
require 'faye/websocket'
require 'rack'

DB = Sequel.connect('postgres://postgres@localhost/notify_test')

App = lambda do |env|
  if Faye::WebSocket.websocket?(env)
    ws = Faye::WebSocket.new(env)
    puts 'Listening for DB events...'
    DB.listen(:events, loop: true) do |_channel, _pid, payload|
      puts payload
      ws.send(payload)
      ws.rack_response
    end
  else
    # Normal HTTP request
    [200, { 'Content-Type' => 'text/html' }, [File.read('./index.html')]]
  end
end
