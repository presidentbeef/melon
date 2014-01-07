module Melon
  class Paradigm
    include Logit

    # Create a new ZMQ context or create a new one.
    def self.zmq
      @zmq ||= ZMQ::Context.new(1)
    end

    # Create a new instance of MELON with the provided _local_ storage server.
    def initialize local
      @servers = []
      @local = local
      @read = DumbNumbSet.new
      @delay = 1

      add_server @local
    end

    # Creates a new RemoteStorage instance and adds it to the list of servers.
    def add_remote port, address = "localhost"
      add_server RemoteStorage.new(Paradigm.zmq, address, port)
    end

    # Adds an existing RemoteStorage instance to the list of servers.
    # Typically Paradigm#add_remote is used instead of this.
    def add_server server
      @servers << server
    end

    # Store a message in the Melon message store. "Stored" messages may only be
    # accessed via Paradigm#take or Paradigm#take_all. A "stored" message may
    # only ever be "taken" once.
    def store message
      @local.store message
    end

    # Write a message to the Melon message store. "Written" messages may only
    # be read with Paradigm#read or Paradigm#read_all. Messages stored with
    # Paradigm#write may only be read, never taken or explicitly removed
    # from the message store.
    def write message
      @local.write message
    end

    # Nondestructively reads a message matching the given template from the
    # message store. Only  messages written with Paradigm#write may be read with
    # Paradigm#read.
    #
    # If a matching message is not found, behavior is determined by the _block_
    # argument. If _block_ is true, the method call will continue polling for a
    # matching message. If _block_ is false, the call will return `nil`.
    #
    # A template is an array of either classes or literal values.
    # Templates are matched against messages of the same length and matching
    # values. A class will match any value of that class or a subclass.
    # Literal values must match exactly (using `==`).
    #
    # Note that a message may only be read once by a given process. Each time
    # Paradigm#read is called, it will return a different, unread message.
    def read template, block = true
      loop do
        each_server do |s|
          if res = (s.find_unread template, @read)
            @read << res.id
            return res.message
          end
        end

        if block
          sleep @delay
        else
          break
        end
      end

      nil
    end

    # Removes a message matching the given template from the message store.
    # Only messages stored with Paradigm#store may be removed with with this
    # method.
    #
    # If a matching message is not found, behavior is determined by the
    # _block_ argument. If _block_ is true, the method call will continue
    # polling for a matching message. If _block_ is false, the call will return
    # `nil`.
    #
    # Note that a message may only ever be "taken" once. Paradigm#take is an
    # atomic operation in that sense.
    #
    # See Paradigm#read for information about templates.
    def take template, block = true
      loop do
        each_server do |s|
          if res = s.find_and_take(template)
            return res.message
          end
        end

        if block
          sleep @delay
        else
          break
        end
      end

      nil
    end

    # Reads all available messages matching the provided template and returns
    # them in an array. Only returns messages not previously read by the
    # current process via Paradigm#read or Paradigm#read_all.
    #
    # If no matching messages are found, behavior is determined by the _block_
    # argument. If _block_ is true, the method call will continue polling for
    # matching messages. If _block_ is false, the call will return an empty
    # array.
    def read_all template, block = true
      results = []

      loop do
        each_server do |s|
          debug s.class
          results.concat(s.find_all_unread template, @read)
        end

        if results.empty? and block
          sleep @delay
        else
          break
        end
      end

      @read.merge results.map(&:id)
      results.map(&:message)
    end

    # Takes all available messages matching the provided template and returns
    # them in an array. Messages "taken" from the message store are removed
    # and can only be "taken" once.
    #
    # If no matching messages are found, behavior is determined by the _block_
    # argument. If _block_ is true, the method call will continue polling for
    # matching messages. If _block_ is false, the call will return an empty
    # array.
    def take_all template, block = true
      results = []

      loop do
        each_server do |s|
          results.concat(s.take_all template)
        end

        if results.empty? and block
          sleep @delay
        else
          break
        end
      end

      results.map(&:message)
    end

    private

    # Yields each server in random order.
    def each_server
      begin
        @servers.shuffle.each do |s|
          yield s
        end
      end
    end
  end
end
