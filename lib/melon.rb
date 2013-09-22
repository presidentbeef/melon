require 'thread'
require 'securerandom'
require 'dumb_numb_set'
require 'ffi-rzmq'
require_relative 'melon/logit'
require_relative 'melon/paradigm'
require_relative 'melon/local_storage'
require_relative 'melon/storage_server'
require_relative 'melon/remote_storage'
require_relative 'melon/stored_message'

Thread.abort_on_exception = true

module Melon 
  def self.with_zmq port = nil
    local = LocalStorage.new
    server = StorageServer.new(local, Melon::Paradigm.zmq, port)
    server.start
    $stderr.puts "Local server started on #{server.port}"
    Melon::Paradigm.new(local)
  end
end