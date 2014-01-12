require 'thread'
require 'set'

class Whiteboard
  attr_reader :board, :next_id

  def initialize &block
    @add_figure_callback = block
    @mutex = Mutex.new
    @pending = []
    @my_figures = Set.new
    @board = []
    @next_id = 0
    @out_of_order = 0
    @my_id = rand(2**32)
    @max_time = 0
  end

  def out_of_order?
    lists = Hash.new
    @board.each do |fig|
      lists[fig[:seq].first] ||= []
      lists[fig[:seq].first] << fig
    end

    ooo = 0

    lists.each do |id, l|
      ooo += count_swaps(l) { |f| f[:seq].last }
    end

    return ooo, @out_of_order
  end

  def create_figure figure, auto_add = false
    @mutex.synchronize do
      figure[:time] = (Time.now.to_f * 1000).to_i
      if @board.length > 0
        figure[:id] = @board.last[:id] + 1
      else
        figure[:id] = 0
      end

      figure[:seq] = [@my_id, @next_id]
      @next_id += 1
    end

    if auto_add
      add_figure figure
    end

    figure
  end

  def add_figure figure
    @mutex.synchronize do
      insert_figure figure
    end
  end

  def includes? figure_id
    @mutex.synchronize do
      @board.find do |f|
        f[:id] == figure_id
      end
    end
  end

  def add_rectangle figure
    add_local_figure create_figure(figure.merge(:type => :rectangle))
  end

  def add_line figure
    add_local_figure create_figure(figure.merge(:type => :line))
  end

  def add_circle figure
    add_local_figure create_figure(figure.merge(:type => :circle))
  end

  def add_text figure
    add_local_figure create_figure(figure.merge(:type => :text))
  end

  def add_local_figure figure
    @add_figure_callback.call figure
  end

  def add_remote_figure figure
    @add_figure_callback.call figure
  end

  private

  def insert_figure figure
    if @my_id == figure[:seq].first
      if @my_figures.include? figure[:seq].last
        return
      else
        @my_figures << figure[:seq].last
      end
    end

    delay = (Time.now.to_f * 1000) - figure[:time]
    if delay > @max_time
      @max_time = delay
      puts delay
    end

    id = figure[:id]
    index = @board.rindex do |f|
      f[:id] <= id
    end

    if index
      if index != @board.length - 1
        # id is earlier, so it's out of order
        @out_of_order += 1
        #puts "Last ID is #{@board.last[:id]} and this is #{figure[:id]} and index is #{index} out of #{@board.length}"
      end

      @board.insert(index + 1, figure)
    else
      unless @board.empty?
        # id is earlier than an id already seen
        #puts "Last ID is #{@board.last[:id]} and this is #{figure[:id]}"
        @out_of_order += 1
      end

      @board.unshift figure
    end
  end

  private

  def count_swaps list, &sort_block
    swaps = 0

    # Get a sorted list for comparison
    sorted = list.sort_by &sort_block

    # Check each elements against where they should be,
    # swapping them if necessary and counting the swaps.
    list.each_with_index do |element, index|
      next if element == sorted[index]
      swaps += 1

      # Find where the element should be and swap it into position
      should_be = list.find_index(sorted[index])
      list[index], list[should_be] = list[should_be], list[index]
    end

    swaps
  end
end
