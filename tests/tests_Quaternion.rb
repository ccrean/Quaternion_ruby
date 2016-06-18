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

  def test_norm
    q = ::Quaternion.new(1, 0, 0, 0)
    assert_equal(1, q.norm())

    q = ::Quaternion.new(1, 2, 3, 4)
    assert_equal(Math.sqrt(1**2 + 2**2 + 3**2 + 4**2), q.norm())
  end

  def test_conjugate
    q = ::Quaternion.new(1, 1, 3, 1)
    q_c = q.conjugate()
    beta0, beta_s = q_c.get()
    assert_equal(1, beta0)
    assert_equal(Vector[-1,-3,-1], beta_s)
  end

  def test_inverse
    quats = [ ::Quaternion.new(1,2,3,4),
              ::Quaternion.new(0.1, 0.01, 2.3, 4),
              ::Quaternion.new(1234.4134, 689.6124, 134.124, 0.5) ]
    for q in quats
      q_inv = q.inverse()
      q_result = q * q_inv
      beta0, beta_s = q_result.get()
      assert_in_delta(1, beta0, 1e-15)
      assert_in_delta(beta_s.norm(), 0, 1e-15)
    end
  end
end
