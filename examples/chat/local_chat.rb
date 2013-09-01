require_relative '../../lib/melon'

melon = Melon.with_zmq

print "Name: "
name = gets.strip

loop do
  print "Remote port: "
  melon.add_remote gets.strip.to_i

  print "Add another (y/n)? "
  break unless gets.downcase.start_with? "y"
end

template = [String, String]

t = Thread.new do
  loop do
    messages = melon.read_all(template)
  
    messages.each do |m|
      puts "\n[#{m.first}] #{m.last}" unless m.first == name
    end
  end
end

loop do

  print "? "
  message = gets.strip

  unless message.empty?
    melon.write [name, message]
  end
end
