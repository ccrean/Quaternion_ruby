require 'test/unit'
require 'matrix'
require_relative '../Quaternion'

class TestQuaternion < Test::Unit::TestCase

  def test_initialize
    q = ::Quaternion.new(1,1,1,1)
    beta0, beta_s = q.get()

    assert_equal(1, beta0)
    assert_equal(Vector[1,1,1], beta_s)
  end

  def test_set
    q = ::Quaternion.new(0,0,0,0)
    beta0, beta_s = q.get()
    assert_equal(0, beta0)
    assert_equal(Vector[0,0,0], beta_s)

    q.set(1,2,3,4)
    beta0, beta_s = q.get()
    assert_equal(1, beta0)
    assert_equal(Vector[2,3,4], beta_s)
  end

end
