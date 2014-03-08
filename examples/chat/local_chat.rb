require_relative '../../lib/melon'
require_relative 'chat'

print "Name: "
name = gets.strip

chat = Chat.new name

loop do
  print "Remote port: "
  chat.add_remote gets.strip.to_i

  print "Add another (y/n)? "
  break unless gets.downcase.start_with? "y"
end

chat.start
