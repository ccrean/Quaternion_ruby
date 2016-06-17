require 'test/unit'
require 'matrix'
require_relative 'Quaternion'

class TestQuaternion < Test::Unit::TestCase

  def test_set
    q = ::Quaternion.new
    q.set(0.1, 0.1, 0.1)
    beta0, beta_s = q.get()
    assert_equal(0.9848857801796105, beta0)
    assert_equal(Vector[0.1, 0.1, 0.1], beta_s)
    assert_equal(1, beta0**2 + beta_s.norm()**2)
  end

  def test_setAngleAxis
    axis = Vector[1, 0, 0]
    angle = Math::PI/2
    q = ::Quaternion.fromAngleAxis(angle, axis)
    beta0, beta_s = q.get()
    assert_equal(Math.cos(angle/2.0), beta0)
    assert_equal(axis[0]*Math.sin(angle/2.0), beta_s[0])
    assert_equal(axis[1]*Math.sin(angle/2.0), beta_s[1])
    assert_equal(axis[2]*Math.sin(angle/2.0), beta_s[2])
  end

  def test_getAngleAxis
    axis = Vector[1, 2, 3]
    angle = 0.4321
    q = ::Quaternion.fromAngleAxis(angle, axis)
    result_angle, result_axis = q.getAngleAxis()

    assert_operator((axis.normalize() - result_axis).norm(), :<, 1e-15)
    assert_in_delta(angle, result_angle, 1e-15)
  end

  def test_multiply_inverse
    axis1 = Vector[1, 2, 3]
    angle1 = 1.123
    q1 = ::Quaternion.fromAngleAxis(angle1, axis1)

    axis2 = Vector[1, 2, 3]
    angle2 = -1.123
    q2 = ::Quaternion.fromAngleAxis(angle2, axis2)

    q3 = q1 * q2
    beta0, beta_s = q3.get()
    assert_in_delta(1, beta0, 1e-15)
    assert_in_delta(0, beta_s.norm(), 1e-15)
  end

  def test_multiply
    axis1 = Vector[3, 1, 6]
    angle1 = 1.32
    q1 = ::Quaternion.fromAngleAxis(angle1, axis1)

    axis2 = Vector[1, 1, 1]
    angle2 = Math::PI/4
    q2 = ::Quaternion.fromAngleAxis(angle2, axis2)

    q_result = q2*q1
    q_result_mat = q_result.getRotationMatrix()
    
    mat_result = q2.getRotationMatrix() * q1.getRotationMatrix()
    
    for i in 0..2
      assert_operator((q_result_mat.row(i) - mat_result.row(i)).norm(),
                      :<, 1e-15)
    end
  end

  def test_transform
    axis = Vector[1,1,1]
    angle = 2*Math::PI/3
    q1 = ::Quaternion.fromAngleAxis(angle, axis)

    v = Vector[1,0,0]
    v_rot = q1.transform(v)
    expected = Vector[0,1,0]

    assert_operator((v_rot - expected).norm(), :<, 1e-15)
  end

end
