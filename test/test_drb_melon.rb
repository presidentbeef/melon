require_relative 'test_helper'
require 'melon/drb'

class TestDRbMelon < Minitest::Test
  include CoreMelonTests

  def teardown
    Melon.stop_drb
    ::DRb.stop_service
  end

  def make_melon port: nil
    if port
      Melon.with_drb port: port
    else
      Melon.with_drb
    end
  end
end
