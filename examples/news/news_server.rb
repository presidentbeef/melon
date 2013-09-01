require "../../lib/melon"

melon = Melon.with_zmq

topics = ["Politics", "Sports", "Business", "Technology", "International"]

i = 0

loop do
  topic = topics.sample
  message = [topic, "#{topic} news item #{i+=1}"]
  p message
  melon.write message 
  sleep rand(2)
end
