require 'drb/drb'

module Melon
  module DRb
    class StorageServer
      def initialize storage, host: "localhost", port: 8484
        @storage = storage
        @port = port

        uri = "druby://#{host}:#{port}"
        Melon.local_drb_servers << ::DRb.start_service(uri, self)
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
