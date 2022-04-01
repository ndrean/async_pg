# frozen_string_literal: true

require 'sequel'
require 'pg'

DB = Sequel.connect('postgres://postgres@localhost/notify_test')

puts 'Listening for DB events...'
DB.listen(:events, loop: true) do |_channel, _pid, payload|
  puts payload
end

# ruby test1.rb