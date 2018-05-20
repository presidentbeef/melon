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

    def add_remote remote_storage
      add_server remote_storage
    end

    def add_server server
      @servers << server
    end

    def store message
      @local.store message
    end

    def write message
      @local.write message
    end

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

    def each_server
      begin
        @servers.shuffle.each do |s|
          yield s
        end
      end
    end
  end
end
