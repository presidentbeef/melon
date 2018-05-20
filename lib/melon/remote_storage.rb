module Melon
  # RemoteStorage is the client-side component that proxies local requests to
  # the remove Melon::StorageServer.
  class RemoteStorage
    include Logit

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
