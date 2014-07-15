require "melon"
require_relative "adder"

melon = Melon.with_zmq
print "Producer remote port: "
melon.add_remote gets.strip.to_i

loop do
  job = melon.take([Adder])[0]
  result = job.execute
  melon.store [job.id, result]
end
