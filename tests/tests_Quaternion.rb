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

end
