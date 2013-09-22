require 'thread'

class Whiteboard
  def initialize
    @mutex = Mutex.new
    @pending = []
    @board = []
    @next_id = 0
  end

  def add_figure figure
    @mutex.synchronize do
      if figure[:previous]
        if index = find_figure(figure[:previous])
          insert_figure figure, index
        else
          @pending << figure
        end
      else
        @board << figure
      end

      if figure[:id] > @next_id
        @next_id = figure[:id] + 1
      end
    end
  end

  private

  def find_figure figure_id
    index = @board.rindex do |figure|
      figure[:id] == figure_id
    end

    index &&= index + 1
  end

  def insert_figure figure, index
    if index == @board.length
      @board << figure
    else
      @board.insert index, figure
    end
  end
end
