require_relative '../../lib/melon'

unless ARGV[2]
  abort "news_reader.rb ADDRESS PORT TOPIC"
end

address = ARGV[0]
port = ARGV[1]
topic = ARGV[2]

melon = Melon.with_zmq
melon.add_remote port, address

template = [topic, String]

loop do
  puts melon.read_all template
end
