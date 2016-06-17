require 'test/unit'
require 'matrix'
require_relative 'Quaternion'

q = Quaternion.new
q.print()

class TestQuaternion < Test::Unit::TestCase

  def test_set
    q = ::Quaternion.new
    q.set(0.1, 0.1, 0.1)
    q_ret = q.get()
    assert_equal(Vector[0.9848857801796105, 0.1, 0.1, 0.1], q_ret)
    assert_equal(1, q_ret[0]**2 + q_ret[1]**2 + q_ret[2]**2 + q_ret[3]**2)
  end

end
