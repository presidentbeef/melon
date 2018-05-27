require 'dumb_numb_set'
require_relative 'local_storage'

module Melon
  class Paradigm
    include Logit

    def initialize local = Melon::LocalStorage.new
      @servers = []
      @local = local
      @read = DumbNumbSet.new
      @delay = 1

      add_server @local
    end

    # Adds a remote server
    def add_remote remote_storage
      raise NotImplementedError
    end

    # Adds a storage server
    def add_server server
      @servers << server
    end

    # Store a take-only message locally
    def store message
      @local.store message
    end

    # Write a read-only message locally
    def write message
      @local.write message
    end

    # Read a read-only message from any server (including local).
    # Blocks by default if no messages are available.
    #
    # If `block` is set to `false`, `nil` will be returned if no matching
    # messages are found.
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

    # Take a take-only message from any server (including local).
    # Blocks by default if no messages are available.
    #
    # If `block` is set to `false`, `nil` will be returned if no matching
    # messages are found.
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

    # Reads all matching unread read-only message from any server (including local).
    # Blocks by default if no messages are available.
    #
    # If `block` is set to `false`, an empty array will be returned if no matching
    # messages are found.
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

    # Takes all matching take-only message from any server (including local).
    # Blocks by default if no messages are available.
    #
    # If `block` is set to `false`, an empty array will be returned if no matching
    # messages are found.
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

    # Iterates over each server in random order
    def each_server
      begin
        @servers.shuffle.each do |s|
          yield s
        end
      end
    end
  end
end
