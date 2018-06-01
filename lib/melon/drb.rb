require_relative '../melon'
require_relative 'drb/remote_storage'
require_relative 'drb/storage_server'

module Melon
  @drb_servers = []

  def self.with_drb local_storage: Melon::LocalStorage.new, host: "localhost", port: 8484
    @drb_servers << Melon::DRb::StorageServer.new(local_storage, host: host, port: port)
    Melon::DRb::Paradigm.new(local_storage)
  end

  def self.stop_drb
    @drb_servers.each(&:stop)
  end

  module DRb
    class Paradigm < ::Melon::Paradigm
      def add_remote host: "localhost", port: 8484
        self.add_server Melon::DRb::RemoteStorage.new(host: host, port: port)
      end
    end
  end
end
