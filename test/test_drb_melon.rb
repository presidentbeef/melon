require 'melon/drb'

class TestDRbMelon < Minitest::Test
  def teardown
    Melon.stop_drb
    ::DRb.stop_service
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
    m1.store ["hello", "world"]
    msg1 = m2.take [String, "world"]
    msg2 = m2.take [String, "world"]
    msg3 = m2.take [String, "world"], false

    assert_equal ["hello", "world"], msg1
    assert_equal ["hello", "world"], msg2
    assert_nil msg3
  end

  def test_store_take_all
    m1 = Melon.with_drb port: 8489
    m2 = Melon.with_drb port: 8580

    m2.add_remote Melon::DRb::RemoteStorage.new(port: 8489)
    m1.add_remote Melon::DRb::RemoteStorage.new(port: 8580)

    m1.store ["hello", "world"]
    m1.store ["hello", "world"]
    msgs1 = m2.take_all [String, "world"]
    msgs2 = m1.take_all [String, "world"], false

    assert_equal [["hello", "world"], ["hello", "world"]], msgs1
    assert msgs2.empty?
  end

  def test_write_read
    m1 = Melon.with_drb port: 8486
    m2 = Melon.with_drb port: 8587

    m2.add_remote Melon::DRb::RemoteStorage.new(port: 8486)
    m1.add_remote Melon::DRb::RemoteStorage.new(port: 8587)

    m1.write ["hello", "world"]

    msg1 = m2.read [String, "world"]
    msg2 = m1.read [String, "world"]

    assert_equal ["hello", "world"], msg1
    assert_equal ["hello", "world"], msg2
  end

  def test_write_read_all
    m1 = Melon.with_drb port: 8488
    m2 = Melon.with_drb port: 8589

    m2.add_remote Melon::DRb::RemoteStorage.new(port: 8488)
    m1.add_remote Melon::DRb::RemoteStorage.new(port: 8589)

    m1.write ["hello", "world"]
    m2.write ["hello", "everyone"]

    msgs1 = m2.read_all ["hello", String]
    msgs2 = m1.read_all ["hello", String]

    assert msgs1.include? ["hello", "world"]
    assert msgs2.include? ["hello", "world"]
    assert msgs1.include? ["hello", "everyone"]
    assert msgs2.include? ["hello", "everyone"]
  end
end
