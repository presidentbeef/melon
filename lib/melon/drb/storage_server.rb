require 'drb/drb'

module Melon
  module DRb
    class StorageServer
      def initialize storage, host: "localhost", port: 8484
        @storage = storage

        begin
          @uri = "druby://#{host}:#{port}"

          ::DRb.start_service(@uri, self)
        rescue Errno::EADDRINUSE
          port += 1
          retry
        end

        warn "Started Melon server on #@uri"
      end

      def stop
        if server = ::DRb.fetch_server(@uri)
          server.stop_service
          server.thread.join
        end
      end

      def alive?
        if server = ::DRb.fetch_server(@uri)
          server.alive?
        else
          false
        end
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
