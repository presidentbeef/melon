class TestLocalStorage < Minitest::Test
  def setup
    @ls = Melon::LocalStorage.new
  end

  def test_find_and_take
    blah = [1, 2, 3]
    @ls.store blah

    message = @ls.find_and_take([Integer, Integer, 3])

    assert_instance_of Melon::StoredMessage, message
    assert_equal blah, message.message
  end

  def test_take_all
    msg1 = [1, 2, 3]
    msg2 = [2, 3, 4]
    msg3 = [3, 4, 5]

    @ls.store msg1
    @ls.store msg2
    @ls.store msg3

    msgs = @ls.take_all [Integer, Integer, Integer]

    assert_equal 3, msgs.length

    actual = msgs.map(&:message)

    assert actual.include? msg1
    assert actual.include? msg2
    assert actual.include? msg3

    none = @ls.take_all  [Integer, Integer, Integer]

    assert none.empty?
  end

  def test_find_unread_fetch
    msg1 = [1, 2, 3]
    msg2 = [2, 3, 4]
    template = [Integer, Integer, Integer]
    read_msgs = DumbNumbSet.new

    @ls.write msg1
    @ls.write msg2

    read1 = @ls.find_unread(template, read_msgs, :fetch)
    read_msgs << read1.id

    read2 = @ls.find_unread(template, read_msgs, :fetch)
    read_msgs << read2.id

    read3 = @ls.find_unread(template, read_msgs, :fetch)

    assert_nil read3
    assert_equal 2, read_msgs.to_a.length

    assert_instance_of Melon::StoredMessage, read1
    assert_instance_of Melon::StoredMessage, read2

    assert_equal msg1, read1.message
    assert_equal msg2, read2.message
  end

  def test_find_unread_no_fetch
    msg1 = [1, 2, 3]
    msg2 = [2, 3, 4]
    template = [Integer, Integer, Integer]
    read_msgs = DumbNumbSet.new

    @ls.write msg1
    @ls.write msg2

    read1 = @ls.find_unread(template, read_msgs, false)
    read_msgs << read1

    read2 = @ls.find_unread(template, read_msgs, false)
    read_msgs << read2

    read3 = @ls.find_unread(template, read_msgs, false)

    assert_nil read3
    assert_equal 2, read_msgs.to_a.length

    assert_kind_of Integer, read1
    assert_kind_of Integer, read2
  end

  def test_fetch
    msg1 = [1, 2, 3]
    msg2 = [2, 3, 4]
    template = [Integer, Integer, Integer]
    read_msgs = DumbNumbSet.new

    @ls.write msg1
    @ls.write msg2

    read1 = @ls.find_unread(template, read_msgs, false)
    read_msgs << read1

    read2 = @ls.find_unread(template, read_msgs, false)
    read_msgs << read2

    assert_kind_of Integer, read1
    assert_kind_of Integer, read2

    rmsg1 = @ls.fetch read1
    rmsg2 = @ls.fetch read2

    assert_instance_of Melon::StoredMessage, rmsg1
    assert_instance_of Melon::StoredMessage, rmsg2

    assert_equal msg1, rmsg1.message
    assert_equal msg2, rmsg2.message
  end

  def test_find_all_unread
    msg1 = [1, 2, 3]
    msg2 = [2, 3, 4]
    template = [Integer, Integer, Integer]
    read_msgs = DumbNumbSet.new

    @ls.write msg1
    @ls.write msg2

    msgs = @ls.find_all_unread(template, read_msgs)
    msgs.each { |m| read_msgs << m.id }

    rest = @ls.find_all_unread(template, read_msgs)

    assert rest.empty?
    assert_equal 2, read_msgs.to_a.length

    assert_instance_of Melon::StoredMessage, msgs[0]
    assert_instance_of Melon::StoredMessage, msgs[1]

    assert_equal msg1, msgs[0].message
    assert_equal msg2, msgs[1].message
  end
end
