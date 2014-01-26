require_relative '../../../tnp/old_style/ps/ps'
require_relative 'lib/whiteboard'
require_relative 'lib/figure'

class PSWhiteboard < Whiteboard
  def initialize port = nil, &block
    @ps = PS.new port
    @ps.subscribe "whiteboard" do |figure|
      add_figure eval(figure)
    end

    super &block
  end

  def add_remote addr, port
    @ps.add_neighbor "127.0.0.1", port
  end

  def add_local_figure figure
    super
    @ps.publish "whiteboard", figure
  end

  def wait
    @ps.wait_for_subscriber
  end
end
