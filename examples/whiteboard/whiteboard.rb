require 'thread'

class Whiteboard
  attr_reader :board, :next_id

  def initialize use_buffer = true
    @use_buffer = use_buffer
    @mutex = Mutex.new
    @pending = []
    @board = []
    @next_id = 0

    start_buffer if @use_buffer
  end

  def create_figure figure, auto_add = true
    @mutex.synchronize do
      figure[:id] = @next_id
      @next_id += 1
    end

    if auto_add
      add_figure figure
    end

    figure
  end

  def add_figure figure
    @mutex.synchronize do
      if @board.empty? or includes_previous? figure
        insert_figure figure
      elsif @use_buffer
        @pending << figure
      else
        insert_figure figure
      end
    end
  end

  def includes? figure_id
    @mutex.synchronize do
      @board.find do |f|
        f[:id] == figure_id
      end
    end
  end

  def clear_buffer
    @mutex.synchronize do
      @pending.sort_by {|f| f[:id] }.each do |f|
        insert_figure f
      end

      @pending.clear
    end
  end

  def stop
    if @buffer_thread
      @buffer_thread.kill
    end
  end

  private

  # Starts a thread that empties the buffer every 10 seconds
  def start_buffer
    @buffer_thread = Thread.new do
      loop do
        sleep 10
        clear_buffer
      end
    end
  end

  def includes_previous? figure
    prev = figure[:id] - 1
    @board.reverse_each do |f|
      if f[:id] == prev
        return true
      end
    end

    false
  end

  def insert_figure figure
    id = figure[:id]
    index = @board.rindex do |f|
      f[:id] <= id
    end

    if index
      @board.insert(index + 1, figure)
    else
      @board.unshift figure
    end

    if figure[:id] >= next_id
      @next_id = figure[:id] + 1
    end
  end
end
