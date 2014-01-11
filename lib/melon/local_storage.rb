require 'rwlock'

module Melon
  class LocalStorage
    # Create a new local storage with a random ID.
    # Local stores are generally not used directly.
    def initialize
      @tmutex = Mutex.new
      @rmutex = RWLock.new
      @imutex = Mutex.new
      @mid = 0
      @pid = SecureRandom.random_number(2**17) + 2**17 #keep low
      @takable = []
      @readable = []
    end

    # Store a message.
    def store message
      tsync do
        @takable << StoredMessage.new(@pid, next_id, message)
      end
    end

    # Write a message.
    def write message
      @rmutex.write_sync do
        @readable << StoredMessage.new(@pid, next_id, message)
      end
    end

    # Find and remove a matching message.
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

    # Take a message with the given ID.
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

    # Take all messages matching the given template.
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

    # Returns message with the given ID.
    def fetch id
      each_unread([]) do |m|
        if m.id == id
          return m
        end
      end

      nil
    end

    # Find unread message matching the given template. If _fetch_ is false,
    # only returns the ID.
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

    # Find all unread messages matching the given template.
    def find_all_unread template, read
      results = []

      each_unread(read) do |m|
        if m =~ template
          results << m
        end
      end

      results
    end

    # Does nothing! Yet.
    def gc
    end

    private

    # Synchronizes access to unread messages.
    def each_unread read
      @rmutex.read_sync do
        @readable.each do |m|
          unless read.include? m.id
            yield m
          end
        end
      end
    end

    # Synchronizes access to untaken messages.
    def tsync
      @tmutex.synchronize do
        yield
      end
    end

    # Returns the next ID.
    def next_id
      @imutex.synchronize do
        @mid += 1
      end
    end
  end


end
