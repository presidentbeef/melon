require '../ps_whiteboard'

mwb = PSWhiteboard.new(ARGV.pop) do; end

ARGV.each do |port|
  mwb.add_remote port.to_i
end

print "Send? "
x = ($stdin.gets.chomp == "y")

if x
  mwb.wait
  100.times do
    mwb.add_local_figure(mwb.create_figure({type: :point, x: 1, y: 0}, true))
    sleep(rand(3))
  end
  puts "done sending"
end

puts "waiting for you"
STDIN.gets
puts "done"
p mwb.out_of_order?
exit!
