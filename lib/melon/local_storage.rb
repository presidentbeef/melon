require 'rwlock'
require 'securerandom'
require_relative 'stored_message'

module Melon
  # Melon::LocalStorage provides thread-safe operations on the Melon storage space.
  class LocalStorage
    def initialize
      @tmutex = Mutex.new
      @rmutex = RWLock.new
      @imutex = Mutex.new
      @mid = 0
      @pid = SecureRandom.random_number(2**17) + 2**17 #keep low
      @takable = []
      @readable = []
    end

    # Stores a take-only message
    def store message
      tsync do
        @takable << StoredMessage.new(@pid, next_id, message)
      end
    end

    # Stores a read-only message
    def write message
      @rmutex.write_sync do
        @readable << StoredMessage.new(@pid, next_id, message)
      end
    end

    # Removes and returns a single matching take-only message
    def find_and_take template
      message = nil

      tsync do
        index = nil

        @takable.each_with_index do |m, i|
          if m =~ template
            index = i
            message = m
            break
          end
        end

        @takable.delete_at index if index
      end

      message
    end

    # Removes and returns a single take-only message by ID
    def take id
      message = nil

      tsync do
        index = nil

        @takable.each_with_index do |m, i|
          if m.id == id
            index = i
            message = m
            break
          end
        end

        @takable.delete_at index if index
      end

      message
    end

    # Removes and returns all matching take-only messages
    def take_all template
      messages = []

      tsync do
        indexes = []

        @takable.each_with_index do |m, i|
          if m =~ template
            indexes << i
            messages << m
          end
        end

        indexes.each do |i|
          @takable[i] = nil
        end

        @takable.compact! if indexes.any?
      end

      messages
    end

    # Returns the read-only message with the given ID
    def fetch id
      each_unread([]) do |m|
        if m.id == id
          return m
        end
      end

      nil
    end

    # Finds first matching unread message.
    #
    # If `fetch` is `true`, returns the actual message. If `false`, returns
    # the message ID.
    def find_unread template, read, fetch = true
      each_unread(read) do |m|
        if m =~ template
          if fetch
            return m
          else
            return m.id
          end
        end
      end

      nil
    end

    # Returns all unread messages matching the given template
    def find_all_unread template, read
      results = []

      each_unread(read) do |m|
        if m =~ template
          results << m
        end
      end

      results
    end

    def gc
    end

    private

    # Iterates over each unread message. Achieves thread-safety using the
    # readers-writer lock
    def each_unread read
      @rmutex.read_sync do
        @readable.each do |m|
          unless read.include? m.id
            yield m
          end
        end
      end
    end

    # Lock thread for the take-able message list
    def tsync
      @tmutex.synchronize do
        yield
      end
    end

    # Set and return next message ID (thread-safe)
    def next_id
      @imutex.synchronize do
        @mid += 1
      end
    end
  end
end
