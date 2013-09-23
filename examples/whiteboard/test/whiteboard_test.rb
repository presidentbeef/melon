require 'minitest/autorun'
require_relative '../whiteboard'

class WhiteboardTest < Minitest::Unit::TestCase
  def setup
    @wb = Whiteboard.new
  end

  def teardown
    @wb.stop
  end

  def test_add_figure
    figure = { :id => 1 }
    @wb.add_figure figure
    assert @wb.includes? figure[:id]
  end

  def test_ordering_with_no_buffer
    @wb = Whiteboard.new(false)

    (1..15).to_a.shuffle.each do |i|
      @wb.add_figure :id => i
    end

    last = 0
    @wb.board.each do |f|
      last += 1
      assert_equal last, f[:id]
    end
  end

  def test_ordering_with_buffer
    (1..15).to_a.shuffle.each do |i|
      @wb.add_figure :id => i
    end

    @wb.clear_buffer

    last = 0
    @wb.board.each do |f|
      last += 1
      assert_equal last, f[:id]
    end

    assert_equal 15, @wb.board.length
    assert_equal 16, @wb.next_id
  end

  def test_random_ordering_with_buffer
    20.times do |i|
      @wb.add_figure :id => rand(100)
    end

    @wb.clear_buffer

    last = nil
    @wb.board.each do |f|
      if last.nil?
        last = f[:id]
      else
        assert f[:id] >= last
        last = f[:id]
      end
    end

    next_id = last + 1
    assert_equal next_id, @wb.next_id
  end

  def test_create_figure
    assert_equal 0, @wb.next_id
    @wb.create_figure x: 1, y: 2
    assert @wb.includes? 0
    assert_equal 1, @wb.next_id
  end
end
