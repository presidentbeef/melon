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
end
