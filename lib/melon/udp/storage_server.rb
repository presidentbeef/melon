require 'socket' 

Thread.abort_on_exception = true

module Melon
  module UDP
    class StorageServer
      def initialize storage, host: "localhost", port: 8484
        @storage = storage

        begin
          @thread = Thread.new do
            Socket.udp_server_loop(host, port) do |msg, sender|
              handle_message msg, sender
            end
          end
        rescue Errno::EADDRINUSE
          port += 1
          retry
        end

        warn "Started Melon server on #{host} #{port}"
      end

      def stop
        @thread.kill
      end

      def handle_message msg, sender
        m = Marshal.load msg
        template = m[:template]
        read_msgs = m[:read_msgs]

        reply = case m[:action]
                when :find_unread
                  find_unread template, read_msgs
                when :find_all_unread
                  find_all_unread template, read_msgs
                when :find_and_take
                  find_and_take template
                when :take_all
                  take_all template
                else
                  warn "Unknown message: #{m.inspect}"
                  { error: "Unknown message: #{m.inspect}" }
                end

        sender.reply Marshal.dump(reply)
      end

      def find_unread template, read_msgs
        @storage.find_unread template, read_msgs
      end

      def find_all_unread template, read_msgs
        @storage.find_all_unread template, read_msgs
      end

      def find_and_take template
        @storage.find_and_take template
      end

      def take_all template
        @storage.take_all template
      end
    end
  end
end
