require "melon/drb"
require_relative "adder"

melon = Melon.with_drb
print "Producer remote port: "
melon.add_remote port: gets.strip.to_i

loop do
  job = melon.take([Adder])[0]
  result = job.execute
  melon.store [job.id, result]
end
