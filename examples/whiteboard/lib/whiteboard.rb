require_relative 'board'

class Whiteboard
  def initialize
    @wb = Board.new
  end

  def create_figure figure
    @wb.create_figure figure
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
    raise NotImplementedError
  end

  def add_remote_figure figure
    raise NotImplementedError
  end
end
