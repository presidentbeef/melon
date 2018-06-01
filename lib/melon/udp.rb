require_relative '../melon'
require_relative 'udp/remote_storage'
require_relative 'udp/storage_server'

module Melon
  @udp_servers = []

  def self.with_udp local_storage: Melon::LocalStorage.new, host: "localhost", port: 8484
    @udp_servers << Melon::UDP::StorageServer.new(local_storage, host: host, port: port)
    Melon::UDP::Paradigm.new(local_storage)
  end

  def self.stop_udp
    @udp_servers.each(&:stop)
  end

  module UDP
    class Paradigm < Melon::Paradigm
      def add_remote host: "localhost", port: 8484
        self.add_server Melon::UDP::RemoteStorage.new(host: host, port: port)
      end
    end
  end
end
