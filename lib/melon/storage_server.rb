module Melon
  class StorageServer
    include Logit

    attr_reader :port

    def initialize storage, context, port = nil
      @storage = storage
      @context = context
      @port = port || (rand(1000) + 1024)
      setup_sockets
      setup_workers
      debug "Waiting for connections at #@port"
    end

    def start
      Thread.new do
        ZMQ::Device.new(ZMQ::QUEUE, @server_socket, @workers)
      end
    end

    def handle_pub_request type, sender, msg
      debug "#{type} from #{sender}: #{msg.inspect}"
    end

    def handle_server_request socket, msg
      msg = Marshal.load msg

      resp = case msg[:type]
             when :find_unread
               @storage.find_unread msg[:template], msg[:read]
             when :find_all_unread
               @storage.find_all_unread msg[:template], msg[:read]
             when :find_and_take
               @storage.find_and_take msg[:template]
             when :take_all
               @storage.take_all msg[:template]
             else
               false
             end

      if not resp == false
        socket.send_string Marshal.dump(resp)
        debug "Sent response! #{resp.inspect}"
      else
        socket.send_string Marshal.dump([])
        debug "Did not understand message! #{msg.inspect}"
      end
    end

    private

    def setup_sockets
      @server_socket = @context.socket ZMQ::ROUTER
      @server_socket.bind "tcp://*:#@port"
      @workers = @context.socket ZMQ::DEALER
      @workers.bind "inproc://workers"
    end

    def setup_workers
      5.times do
        Thread.new do
          receiver = @context.socket ZMQ::REP
          receiver.connect "inproc://workers"

          loop do
            receiver.recv_string(msg = '')
            handle_server_request(receiver, msg)
          end
        end
      end
    end
  end
end
