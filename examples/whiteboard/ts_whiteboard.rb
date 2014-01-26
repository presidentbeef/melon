require_relative '../../../tnp/old_style/ts/tuple_space'
require_relative 'lib/whiteboard'
require_relative 'lib/figure'

class TSWhiteboard < Whiteboard
  def initialize port = nil, &block
    @ts = Tuplespace.with_zmq port
    @seen = Set.new
    super &block
  end

  def add_remote port
    @ts.add_remote port
  end

  def add_local_figure figure
    super
    @ts.out [figure[:id],
      figure[:type].to_s,
      figure[:x],
      figure[:y],
      figure[:seq][0],
      figure[:seq][1],
      figure[:time]
    ]
  end

  def add_remote_figures
    figs = @ts.bulk_rd [Integer, String, Integer, Integer, Integer, Integer, Integer]

    figs.each do |fig|
      seq = [fig[4], fig[5]]
      unless @seen.include? seq
        @seen << seq
        add_figure :id => fig[0], :type => fig[1].to_sym, :x => fig[2], :y => fig[3], :seq => seq,  :time => fig[6]
      end
    end
  end
end
