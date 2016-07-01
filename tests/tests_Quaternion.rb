# Name: tests_Quaternion.rb
# Description: Test cases for the Quaternion class.
# Author: Cory Crean
# E-mail: cory.crean@gmail.com
# Copyright (c) 2016, Cory Crean

require 'test/unit'
require 'matrix'
require_relative '../lib/Quaternion'

class TestQuaternion < Test::Unit::TestCase

  def setup
    @quats = [ ::Quaternion.new(1,2,3,4),
               ::Quaternion.new(0.1, 0.01, 2.3, 4),
               ::Quaternion.new(1234.4134, 689.6124, 134.124, 0.5),
               ::Quaternion.new(1,1,1,1),
             ]
    nums = (0..1).step(0.2).to_a + (2..10).step(2).to_a
    nums.product(nums, nums, nums).each() do |w, x, y, z|
      @quats << Quaternion.new(w, x, y, z)
    end
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

    assert_equal(0, ::Quaternion.new(0,0,0,0).norm())

    for q in @quats
      assert_in_delta(q.norm(), Math.sqrt((q*q.conjugate()).get[0]), 1e-14)
    end
  end

  def test_conjugate_multiply
    # tests the conjugate and * methods
    q = ::Quaternion.new(1, 1, 3, 1)
    q_c = q.conjugate()
    beta0, beta_s = q_c.get()
    assert_equal(1, beta0)
    assert_equal(Vector[-1,-3,-1], beta_s)

    for q in @quats
      assert_in_delta((q*q.conjugate()).get[1].norm(), 0, 1e-15)
    end
  end

  def test_inverse
    @quats.delete(Quaternion.new(0,0,0,0))
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

  def test_normalized
    q = ::Quaternion.new(1,1,1,1)
    beta0, beta_s = q.normalized().get()
    assert_in_delta(0.5, beta0, 1e-15)
    assert_in_delta((Vector[0.5,0.5,0.5] - beta_s).norm(), 0, 1e-15)

    @quats.delete(Quaternion.new(0,0,0,0))
    for q in @quats
      assert_in_delta(q.normalized().norm(), 1, 1e-15)
    end
  end

  def test_equality
    for q in @quats
      assert_equal(q, q)
    end

    assert(Quaternion.new(1,2,3,4) != Quaternion.new(4,3,2,1))
    assert(Quaternion.new(0,0,0,0) != Quaternion.new(1,1,1,1))
  end

  def test_scalarMult
    q = ::Quaternion.new(1,1,1,1)
    assert_equal(3 * q, Quaternion.new(3,3,3,3))
    assert_equal(1.111 * q, Quaternion.new(1.111, 1.111, 1.111, 1.111))
    assert_equal(q * 3, Quaternion.new(3,3,3,3))
    assert_equal(q * 1.111, Quaternion.new(1.111, 1.111, 1.111, 1.111))
  end

  def test_string
    q = Quaternion.new(1,1,1,1)
    assert_equal(q.to_s,
                 "(1, Vector[1, 1, 1])")

    q = Quaternion.new(1,2,3,4)
    assert_equal(q.to_s,
                 "(1, Vector[2, 3, 4])")
  end

  def test_unaryMinus
    for q in @quats
      beta0, beta_s = q.get()
      assert_equal(-q, Quaternion.new(-beta0, -beta_s[0], -beta_s[1], -beta_s[2]))
    end
  end
end
