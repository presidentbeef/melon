module Melon
  # Melon::StoredMessage
  class StoredMessage
    attr_reader :id, :message

    # Create new StoredMessage, given a process ID, message ID, and the message itself.
    #
    # At this point, `message` should be an array.
    #
    # The process ID and message ID are combined into a single unique integer ID.
    def initialize pid, mid, message
      @id = map_id(pid, mid)
      @message = Marshal.load(Marshal.dump(message))
    end

    # Matches the stored message against a template.
    #
    # The template should be an array of values and classes.
    def =~ template
      return false if template.length != @message.length

      template.each_with_index do |t, i|
        if t.is_a? Class
          if not @message[i].is_a? t
            return false
          end
        elsif @message[i] != t
          return false
        end
      end

      true
    end

    private

    # Pairing function by Matthew Szudik
    # Produces unique integer for a pair of integers
    # http://szudzik.com/ElegantPairing.pdf
    def map_id pid, mid
      if mid >= pid
        (mid ** 2) + pid + mid
      else
        (pid ** 2) + mid
      end
    end
  end
end
