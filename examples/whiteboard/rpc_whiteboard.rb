require_relative '../../../tnp/old_style/rpc/rpc'
require_relative 'lib/whiteboard'
require_relative 'lib/figure'

class RPCWhiteboard < Whiteboard
  def initialize addr, port = nil, &block
    @rpc = RPC.new addr, port
    @rpc.export self

    super &block
  end

  def add_remote port, addr
    @rpc.add_neighbor port, addr 
  end

  def add_local_figure figure
    super
    wbs = @rpc.find_all 'RPCWhiteboard'
    wbs.add_figure figure
  end
end
