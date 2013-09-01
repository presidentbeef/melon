require "benchmark"
require_relative "../../lib/melon"

def random_string
  ('a'..'z').to_a.sample(rand 20).join
end

melon = Melon.with_zmq

SIZE = ARGV[0].to_i

msg = "*" * 1024

Benchmark.bm do |t|
  t.report("Write!") do
    SIZE.times do |i|
      melon.write [i, msg] 
    end

  end

  t.report("Read!") do
    template = [Integer, String]

    SIZE.times do
      melon.read template
    end
  end
end

exit!
