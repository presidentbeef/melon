module Melon
  # StorageServer is the server-side component that proxies remote requests to
  # the local Melon::LocalStorage
  class StorageServer
    include Logit

    def initialize storage
      @storage = storage
    end

    def find_unread template, read_msgs
      raise NotImplementedError
    end

    def find_all_unread template, read_msgs
      raise NotImplementedError
    end

    def find_and_take template
      raise NotImplementedError
    end

    def take_all template
      raise NotImplementedError
    end
  end
end
