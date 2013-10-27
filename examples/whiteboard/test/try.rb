require '../melon_whiteboard'

mwb = MelonWhiteboard.new do; end

print "Other port: "
mwb.add_remote gets.strip.to_i

t = Thread.new do
  loop do
    mwb.add_remote_figures
  end
end

10.times do |i|
  mwb.add_local_figure type: :point, x: 1, y: 0, id: i
  sleep 10
  puts mwb.board.length
end
