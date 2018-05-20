require_relative 'drb/remote_storage'
require_relative 'drb/storage_server'

module Melon
  @local_drb_servers = []

  def self.with_drb local_storage: Melon::LocalStorage.new, host: "localhost", port: 8484
    Melon::DRb::StorageServer.new(local_storage, host: host, port: port)
    Melon::Paradigm.new(local_storage)
  end

  def self.stop_all_drb
    @local_drb_servers.each(&:stop_service)
    @local_drb_servers.clear
  end

  def self.local_drb_servers
    @local_drb_servers
  end
end
