require_relative '../../../tnp/old_style/ps/ps'
require_relative 'lib/whiteboard'
require_relative 'lib/figure'

class PSWhiteboard < Whiteboard
  def initialize port, addr, &block
    @ps = PS.new port, addr
    @ps.subscribe "whiteboard" do |figure|
      add_figure eval(figure)
      add_figure Marshal.load(figure)
    end

    super &block
  end

  def add_remote addr, port
    @ps.add_neighbor addr, port
  end

  def add_local_figure figure
    super
    @ps.publish "whiteboard", Marshal.dump(figure)
  end

  def wait
    @ps.wait_for_subscriber
  end
end
