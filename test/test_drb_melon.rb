require 'melon/drb'

class TestDRbMelon < Minitest::Test
  def teardown
    Melon.stop_all_drb
  end

  def test_sanity
    assert_kind_of Melon::Paradigm, Melon.with_drb
  end

  def test_store_take
    m1 = Melon.with_drb port: 8484
    m2 = Melon.with_drb port: 8585

    m2.add_remote Melon::DRb::RemoteStorage.new(port: 8484)
    m1.add_remote Melon::DRb::RemoteStorage.new(port: 8585)

    m1.store ["hello", "world"]
    msg = m2.take [String, "world"]

    assert_equal ["hello", "world"], msg
  end

  def test_write_read
    m1 = Melon.with_drb port: 8484
    m2 = Melon.with_drb port: 8585

    m2.add_remote Melon::DRb::RemoteStorage.new(port: 8484)
    m1.add_remote Melon::DRb::RemoteStorage.new(port: 8585)

    m1.write ["hello", "world"]

    msg1 = m1.read [String, "world"]
    msg2 = m2.read [String, "world"]

    assert_equal ["hello", "world"], msg1
    assert_equal ["hello", "world"], msg2
  end
end
