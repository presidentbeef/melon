require 'thread'
require_relative 'melon/logit'
require_relative 'melon/paradigm'
require_relative 'melon/local_storage'

Thread.abort_on_exception = true

module Melon 
  def self.start storage_server_class
    local = LocalStorage.new
    storage_server_class.new(local)
    Melon::Paradigm.new(local)
  end
end
