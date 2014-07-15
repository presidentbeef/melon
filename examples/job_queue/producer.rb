require "melon"
require_relative "adder"

melon = Melon.with_zmq
print "Worker remote port: "
melon.add_remote gets.strip.to_i

print "Integers to add: "
numbers = gets.split(/[^0-9]/).map(&:to_i)
job = Adder.new(*numbers)

melon.store [job]
result = melon.take [job.id, Integer]

puts "Result: #{result[1]}"
