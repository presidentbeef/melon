require_relative 'test_helper'
require 'melon/udp'

class TestUDPMelon < Minitest::Test
  include CoreMelonTests

  def teardown
    Melon.stop_udp
  end

  def make_melon port: nil
    if port
      Melon.with_udp port: port
    else
      Melon.with_udp
    end
  end
end
