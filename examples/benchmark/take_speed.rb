require 'benchmark'
require_relative '../../lib/melon'
$stdout.sync = true

melon = Melon.with_zmq 9998

messages = []

SIZE = ARGV[0].to_i

msg = " " * 1024

SIZE.times do |i|
  messages << [i, msg]
end

Benchmark.bm do |t|
  t.report("Store!") do
    messages.each do |m|
      melon.store m
    end
  end

  t.report("Take!") do
    template = [Integer, String]

    SIZE.times do
      melon.take template
    end
  end
end

exit!
