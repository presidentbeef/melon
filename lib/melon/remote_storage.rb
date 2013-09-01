module Melon
  class RemoteStorage
    include Logit

    def initialize context, address, port
      @context = context
      @address = address
      @port = port
      redo_socket
    end

    def find_unread template, read
      debug "Finding unread..."
      if send_req :find_unread, :template => template, :read => read
        recv_res
      else
        nil
      end
    end

    def find_all_unread template, read
      debug "Finding all unread..."
      if send_req :find_all_unread, :template => template, :read => read
        recv_res []
      else
        []
      end
    end

    def find_and_take template
      debug "Taking one..."
      if send_req :find_and_take, :template => template
        recv_res
      else
        nil
      end
    end

    def take_all template
      debug "Taking all..."
      if send_req :take_all, :template => template
        recv_res []
      else
        []
      end
    end

    private

    def redo_socket
      debug "REDO SOCKET"
      @socket.close if @socket
      @socket = @context.socket ZMQ::REQ
      @socket.setsockopt ZMQ::SNDTIMEO, 1500
      @socket.setsockopt ZMQ::RCVTIMEO, 5000
      @socket.setsockopt ZMQ::LINGER, 0
      @socket.connect "tcp://#@address:#@port"
    end

    def send_req type, msg
      msg[:type] = type
      dmsg = Marshal.dump(msg)
      debug "Sending #{dmsg.bytesize} bytes"
      res = @socket.send_string(dmsg)
      if res == -1
        debug "Failed send (#@address:#@port): #{ZMQ::Util.error_string}"
        redo_socket
        nil
      else
        true
      end
    rescue => e
      redo_socket
      p e
      debug e.backtrace
      nil
    end

    def recv_res default = nil
      msg = ''
      res = @socket.recv_string(msg)
      if res != -1
        res = Marshal.load msg
        debug "Received #{res.inspect} (#{msg.bytesize} bytes)"
        res
      else
        debug "Failed recv (#@address:#@port): #{ZMQ::Util.error_string}"
        redo_socket
        default
      end
    rescue => e
      p e
      debug e.backtrace
      redo_socket
      default
    end
  end
end
