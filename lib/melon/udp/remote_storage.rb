require 'socket'

module Melon
  module UDP
    class RemoteStorage
      def initialize host: "localhost", port: 8484
        @socket = UDPSocket.new
        @socket.connect host, port
      end

      def send_msg action, template, read_msgs = nil
        msg = {
          action: action,
          template: template
        }

        msg[:read_msgs] = read_msgs if read_msgs

        @socket.send Marshal.dump(msg), 0

        reply, _ = @socket.recvfrom(6500)
        Marshal.load reply
      end

      def find_unread template, read_msgs
        send_msg :find_unread, template, read_msgs
      end

      def find_all_unread template, read_msgs
        send_msg :find_all_unread, template, read_msgs
      end

      def find_and_take template
        send_msg :find_and_take, template
      end

      def take_all template
        send_msg :take_all, template
      end
    end
  end
end
