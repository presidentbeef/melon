require_relative 'test_helper'

class TestStoredMessage < Minitest::Test
  def test_creation
    m = ["hello", "world"]
    s = Melon::StoredMessage.new(1, 2, m)
    
    assert_kind_of Integer, s.id
    assert_equal ["hello", "world"], s.message
    refute_equal m.object_id, s.message.object_id 
  end

  def test_matching
    m = ["hello", "world"]
    s = Melon::StoredMessage.new(1, 2, m)

    assert_match s, [String, String]
    assert_match s, ["hello", String]
    assert_match s, [String, "world"]
    assert_match s, m
    assert_match s, [Object, Object]
    refute_match s, [Integer, "world"]
    refute_match s, [Class, String]
  end
end
