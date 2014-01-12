gem 'minitest'
require 'minitest/autorun'
require_relative '../lib/whiteboard'

class WhiteboardTest < Minitest::Test
  def setup
    @wb = Whiteboard.new
  end

  def test_add_figure
    figure = @wb.create_figure({})
    figure[:id] = 1
    @wb.add_figure figure
    assert @wb.includes? figure[:id]
    next_figure = @wb.create_figure({})
    assert_equal 2, next_figure[:id]
  end

  def test_ordering
    (1..15).to_a.shuffle.each do |i|
      fig = @wb.create_figure({}, false)
      fig[:id] = i
      @wb.add_figure fig
    end

    last = 0
    @wb.board.each do |f|
      last += 1
      assert_equal last, f[:id]
    end
  end

  def test_create_figure
    assert_equal 0, @wb.next_id
    @wb.create_figure x: 1, y: 2
    refute @wb.includes? 0
    assert_equal 1, @wb.next_id
  end

  def test_create_figure_auto_add
    assert_equal 0, @wb.next_id
    @wb.create_figure({x: 1, y: 2}, true)
    assert @wb.includes? 0
    assert_equal 1, @wb.next_id
  end
end
