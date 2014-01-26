require '../rpc_whiteboard'

mwb = RPCWhiteboard.new("127.0.0.1", ARGV.pop) do; end

ARGV.each do |port|
  mwb.add_remote port.to_i, "127.0.0.1"
end

print "Send? "
x = ($stdin.gets.chomp == "y")

if x
  100.times do |i|
    puts "Getting read to send #{i}"
    mwb.add_local_figure(mwb.create_figure({type: :point, x: 1, y: 0}, true))
    puts "sending #{i}"
    sleep(rand(3))
  end
  puts "done sending"
end

puts "waiting for you"
STDIN.gets
puts "done"
p mwb.out_of_order?
exit!
