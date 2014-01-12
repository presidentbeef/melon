require '../melon_whiteboard'

mwb = MelonWhiteboard.new {}

ARGV.each do |port|
  mwb.add_remote port.to_i
end

sleep rand 3

t = Thread.new do
  loop do
    mwb.add_remote_figures
  end
end

x = ($stdin.gets.chomp == "y")

30.times do
  mwb.add_local_figure(mwb.create_figure({type: :point, x: 1, y: 0}, true)) if x
  sleep(rand(3) + 2)
  p mwb.out_of_order
end

t.join unless x

puts "done"
