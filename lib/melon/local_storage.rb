module Melon
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

    def store message
      tsync do
        @takable << StoredMessage.new(@pid, next_id, message)
      end
    end

    def write message
      @rmutex.write_sync do
        @readable << StoredMessage.new(@pid, next_id, message)
      end
    end

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

    def fetch id
      each_unread([]) do |m|
        if m.id == id
          return m
        end
      end

      nil
    end

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

    def each_unread read
      @rmutex.read_sync do
        @readable.each do |m|
          unless read.include? m.id
            yield m
          end
        end
      end
    end

    def tsync
      @tmutex.synchronize do
        yield
      end
    end

    def next_id
      @imutex.synchronize do
        @mid += 1
      end
    end
  end

  class RWLock
    def initialize
      @size = 10
      @writing = false
      @write_lock = Mutex.new
      @q = SizedQueue.new(@size)
    end

    def read_sync
      wait_on_writes # queue reads if writer is waiting

      @q.push true

      begin
        yield
      ensure
        @q.pop
      end
    end

    def write_sync
      @write_lock.synchronize do
        @writing = true
        rs = @q.length
        @size.times { @q.push true }
        yield
        @writing = false
        @q.clear
      end
    end

    def wait_on_writes
      @write_lock.lock
      @write_lock.unlock
    end
  end
end
