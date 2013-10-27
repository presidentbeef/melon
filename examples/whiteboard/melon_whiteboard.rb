require_relative '../../lib/melon'
require_relative 'lib/whiteboard'
require_relative 'lib/figure'

class MelonWhiteboard < Whiteboard
  def initialize
    super
    @melon = Melon.with_zmq
  end

  def add_remote port
    @melon.add_remote port
  end

  def add_local_figure figure
    super
    @melon.write [figure]
  end

  def add_remote_figures
    figures = @melon.read_all [Figure]

    figures.each do |figure|
      add_figure figure[0]
    end
  end
end
