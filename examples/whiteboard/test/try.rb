require '../melon_whiteboard'

mwb = MelonWhiteboard.new(ARGV.pop) do; end

ARGV.each do |port|
  mwb.add_remote port.to_i
end

sleep rand 3

t = Thread.new do
  loop do
    mwb.add_remote_figures
  end
end

print "Send? "
x = ($stdin.gets.chomp == "y")

if x
  100.times do
    mwb.add_local_figure(mwb.create_figure({type: :point, x: 1, y: 0}, true))
    sleep(rand(3) + 2)
  end
end


print "waiting for you"
$stdin.gets
p mwb.out_of_order?
exit!
