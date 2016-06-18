require 'test/unit'
require 'matrix'
require_relative '../Quaternion'

class TestQuaternion < Test::Unit::TestCase

  def setup
    @quats = [ ::Quaternion.new(1,2,3,4),
               ::Quaternion.new(0.1, 0.01, 2.3, 4),
               ::Quaternion.new(1234.4134, 689.6124, 134.124, 0.5) ]
  end

  def test_initialize
    q = ::Quaternion.new(1,1,1,1)
    beta0, beta_s = q.get()
    assert_equal(1, beta0)
    assert_equal(Vector[1,1,1], beta_s)

    q = ::Quaternion.new
    beta0, beta_s = q.get()
    assert_equal(0, beta0)
    assert_equal(Vector[0,0,0], beta_s)

    vals = [ [ 1 ], [ 1, 2 ], [ 1, 2, 3, 4, 5 ], [ 1, 2, 3, 4, 5, 6 ] ]
    for v in vals
      assert_raise(ArgumentError) do
        q = ::Quaternion.new(*v)
      end
    end
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

    for q in @quats
      assert_in_delta(q.norm(), Math.sqrt((q*q.conjugate()).get[0]), 1e-15)
    end
  end

  def test_conjugate
    q = ::Quaternion.new(1, 1, 3, 1)
    q_c = q.conjugate()
    beta0, beta_s = q_c.get()
    assert_equal(1, beta0)
    assert_equal(Vector[-1,-3,-1], beta_s)
  end

  def test_inverse
    for q in @quats
      q_inv = q.inverse()
      q_result = q * q_inv
      beta0, beta_s = q_result.get()
      assert_in_delta(1, beta0, 1e-15)
      assert_in_delta(beta_s.norm(), 0, 1e-15)
    end
  end

  def test_add
    for q, q2 in @quats.zip(@quats)
      sum = q + q2
      assert_in_delta(sum.get()[0], q.get()[0] + q2.get()[0], 1e-15)
      assert_in_delta((sum.get()[1] - (q.get()[1] + q2.get()[1])).norm(),
                      1e-15)
    end
  end

  def test_subtract
    for q, q2 in @quats.zip(@quats)
      sum = q - q2
      assert_in_delta(sum.get()[0], q.get()[0] - q2.get()[0], 1e-15)
      assert_in_delta((sum.get()[1] - (q.get()[1] - q2.get()[1])).norm(),
                      1e-15)
    end
  end

  def test_normalize
    q = ::Quaternion.new(1,1,1,1)
    beta0, beta_s = q.normalize().get()
    assert_in_delta(0.5, beta0, 1e-15)
    assert_in_delta((Vector[0.5,0.5,0.5] - beta_s).norm(), 0, 1e-15)
  end
end
