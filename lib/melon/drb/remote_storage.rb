require 'drb/drb'

module Melon
  module DRb
    class RemoteStorage
      def initialize host: "localhost", port: 8484
        uri = "druby://#{host}:#{port}"
        @storage = DRbObject.new_with_uri(uri)
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
