class Chat
  def initialize name
    @name = name
    @melon = Melon.with_zmq
  end

  def chat message
    @melon.write [@name, message]
  end

  def read_messages
    @melon.read_all [String, String]
  end

  def print_messages messages
    messages.each do |name, message|
      unless name == @name
        puts "\n<#{name}> #{message}"
      end
    end
  end

  def monitor
    Thread.new do
      loop do
        print_messages read_messages
      end
    end
  end

  def start
    monitor

    loop do
      print "? "
      message = gets.strip

      unless message.empty?
        chat message
      end
    end
  end

  def add_remote port
    @melon.add_remote port
  end
end
