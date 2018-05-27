require 'melon/drb'

unless ARGV[2]
  abort "news_reader.rb HOST PORT TOPIC"
end

host = ARGV[0]
port = ARGV[1]
topic = ARGV[2]

melon = Melon.with_drb
melon.add_remote port: port, host: host

template = [topic, String]

loop do
  puts melon.read_all template
end
