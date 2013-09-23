require_relative '../../lib/melon'
require_relative 'lib/whiteboard'
require_relative 'lib/figure'

class MelonWhiteboard < Whiteboard
  attr_reader :wb

  def initialize port = nil
    @melon = Melon.with_zmq(port)
    @wb = Board.new
  end

  def add_remote port
    @melon.add_remote port
  end

  def add_local_figure figure
    @melon.write [figure]
  end

  def add_remote_figures
    figures = @melon.read_all [Figure]

    figures.each do |figure|
      @wb.add_figure figure[0]
    end
  end
end
