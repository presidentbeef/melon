require 'minitest'
require 'minitest/autorun'
require 'minitest/pride'
require_relative '../lib/melon'

module CoreMelonTests
  @port = 8000

  def self.port
    @port += 1
  end

  def test_sanity
    assert_kind_of Melon::Paradigm, make_melon
  end

  def port1
    @port1 ||= CoreMelonTests.port
  end

  def port2
    @port2 ||= CoreMelonTests.port
  end

  def test_store_take
    m1 = make_melon port: port1
    m2 = make_melon port: port2

    m2.add_remote port: port1
    m1.add_remote port: port2

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
    m1 = make_melon port: port1
    m2 = make_melon port: port2

    m2.add_remote port: port1
    m1.add_remote port: port2

    m1.store ["hello", "world"]
    m1.store ["hello", "world"]
    msgs1 = m2.take_all [String, "world"]
    msgs2 = m1.take_all [String, "world"], false

    assert_equal [["hello", "world"], ["hello", "world"]], msgs1
    assert msgs2.empty?
  end

  def test_write_read
    m1 = make_melon port: port1
    m2 = make_melon port: port2

    m2.add_remote port: port1
    m1.add_remote port: port2

    m1.write ["hello", "world"]

    msg1 = m2.read [String, "world"]
    msg2 = m1.read [String, "world"]

    assert_equal ["hello", "world"], msg1
    assert_equal ["hello", "world"], msg2
  end

  def test_write_read_all
    m1 = make_melon port: port1
    m2 = make_melon port: port2

    m2.add_remote port: port1
    m1.add_remote port: port2

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
