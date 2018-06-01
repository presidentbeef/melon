require_relative 'test_helper'
require_relative '../lib/melon/paradigm'

class TestParadigm < Minitest::Test
  def setup
    @m = Melon::Paradigm.new(Melon::LocalStorage.new)
  end

  def test_store_take
    msg1 = [1, 2, "3"]
    template = [1, Integer, String]

    @m.store msg1
    taken = @m.take template
    none = @m.take template, false

    assert_equal msg1, taken
    assert_nil none
  end

  def test_write_read
    msg1 = [1, 2, "3"]
    template = [1, Integer, String]

    @m.write msg1
    read = @m.read template
    none = @m.read template, false

    assert_equal msg1, read
    assert_nil none
  end

  def test_multiple_readers
    storage = Melon::LocalStorage.new
    m1 = Melon::Paradigm.new(storage)
    m2 = Melon::Paradigm.new(storage)
    msg1 = [1, 2, "3"]
    msg2 = [1, 3, "blah"]
    template = [1, Integer, String]

    m1.write msg1
    m2.write msg2

    read11 = m1.read template
    read21 = m2.read template

    read12 = m1.read template
    read22 = m2.read template

    # Can't block on nothing
    read13 = m1.read template, false
    read23 = m2.read template, false
   
    assert_equal read11, msg1
    assert_equal read21, msg1

    assert_equal read12, msg2
    assert_equal read22, msg2

    assert_nil read13
    assert_nil read23
  end

  def test_multiple_takers
    storage = Melon::LocalStorage.new
    m1 = Melon::Paradigm.new(storage)
    m2 = Melon::Paradigm.new(storage)
    msg1 = [1, 2, "3"]
    msg2 = [1, 3, "blah"]
    template = [1, Integer, String]

    m1.store msg1
    m2.store msg2

    take11 = m1.take template
    take22 = m2.take template

    # Can't block on nothing
    take13 = m1.take template, false
    take23 = m2.take template, false
   
    assert_equal take11, msg1
    assert_equal take22, msg2

    assert_nil take13
    assert_nil take23
  end

  def test_take_all
    storage = Melon::LocalStorage.new
    m1 = Melon::Paradigm.new(storage)
    m2 = Melon::Paradigm.new(storage)
    msg1 = [1, 2, "3"]
    msg2 = [1, 3, "blah"]
    template = [1, Integer, String]

    m1.store msg1
    m2.store msg2

    take1 = m1.take_all template
    take2 = m2.take_all template, false

    assert take2.empty?
    assert_equal 2, take1.length
    assert take1.include? msg1
    assert take1.include? msg2
  end

  def test_read_all
    storage = Melon::LocalStorage.new
    m1 = Melon::Paradigm.new(storage)
    m2 = Melon::Paradigm.new(storage)
    msg1 = [1, 2, "3"]
    msg2 = [1, 3, "blah"]
    template = [1, Integer, String]

    m1.write msg1
    m2.write msg2

    read1 = m1.read_all template
    read2 = m2.read_all template
    read3 = m1.read_all template, false

    assert_equal 2, read1.length
    assert_equal 2, read2.length
    assert read3.empty?
  end

  def test_read_with_threads
    storage = Melon::LocalStorage.new
    m1 = m2 = nil

    t1 = Thread.new do
      m1 = Melon::Paradigm.new(storage)

      100.times do |i|
        m1.write [1, i]
      end
    end

    t2 = Thread.new do
      m2 = Melon::Paradigm.new(storage)

      100.times do |i|
        m2.write [2, i]
      end
    end

    t2.join
    t1.join

    msgs1 = nil
    msgs2 = nil

    t3 = Thread.new do
      msgs1 = m1.read_all [Integer, Integer]
    end

    t4 = Thread.new do
      msgs2 = m2.read_all [Integer, Integer]
    end

    t4.join
    t3.join

    assert_equal 200, msgs1.length
    assert_equal 200, msgs2.length

    assert msgs1.include? [2, 42]
    assert msgs2.include? [1, 42]
  end

  def test_read_write_with_threads
    storage = Melon::LocalStorage.new

    t1 = Thread.new do
      m1 = Melon::Paradigm.new(storage)
      msg = m1.read [Integer, Integer]

      assert_equal [1, 1], msg
    end

    t2 = Thread.new do
      Thread.pass
      m2 = Melon::Paradigm.new(storage)
      m2.write [1, 1]
    end

    t2.join
    t1.join
  end
end
