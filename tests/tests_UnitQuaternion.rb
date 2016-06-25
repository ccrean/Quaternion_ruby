require 'test/unit'
require 'matrix'
require_relative '../lib/UnitQuaternion'

def areEqualMatrices(m1, m2, tol)
  m1.zip(m2).each() do |v1, v2|
    if (v1 - v2).abs() > tol
      print("Error = ", (v1 - v2).abs(), "\n")
      return false
    end
  end
  return true
end

def isIdentityMatrix(m, tol)
  for i, j in [0,1,2].product([0,1,2])
    if i == j
      if (m[i,j] - 1).abs > tol
        return false
      end
    else
      if m[i,j].abs > tol
        return false
      end
    end
  end
  return true
end

class TestUnitQuaternion < Test::Unit::TestCase

  def setup
    @quats = [ ::UnitQuaternion.new(1,2,3,4),
               ::UnitQuaternion.new(0.1, 0.01, 2.3, 4),
               ::UnitQuaternion.new(1234.4134, 689.6124, 134.124, 0.5),
               ::UnitQuaternion.new(1,1,1,1),
             ]
    @angles = [ 2*Math::PI, Math::PI, Math::PI/2, Math::PI/4,
                0.5,  0.25, 0.1234, 0, ]
    # @angles = (0..2*Math::PI).step(0.2).to_a
    # @angles << 2*Math::PI
    # for i in 1..8
    #   @angles << Math::PI/i
    # end
    @axes = [ Vector[ 1, 1, 1 ], Vector[ 1, 0, 0 ], Vector[ 0, 1, 0 ],
              Vector[ 0, 0, 1 ], Vector[ 1, 2, 3 ], ]
    # @euler = []
    # ['x', 'y', 'z'].permutation() do |s|
    #   @euler << s.join("")
    #   @euler << s.join("").upcase()
    # end
    @euler = ['XYZ', 'XZY', 'XYX', 'XZX', 'YXZ', 'YZX', 'YXY', 'YZY',
              'ZXY', 'ZYX', 'ZXZ', 'ZYZ', 'xyz', 'xzy', 'xyx', 'xzx',
              'yxz', 'yzx', 'yxy', 'yzy', 'zxy', 'zyx', 'zxz', 'zyz']
  end

  def test_initialize
    q = ::UnitQuaternion.new(0.9848857801796105, 0.1, 0.1, 0.1)
    beta0, beta_s = q.get()
    assert_equal(0.9848857801796105, beta0)
    assert_equal(Vector[0.1, 0.1, 0.1], beta_s)
    assert_equal(1, beta0**2 + beta_s.norm()**2)

    assert_raise(ArgumentError) do
      q = ::UnitQuaternion.new(1,1,1)
    end

    q = ::UnitQuaternion.new(1, 0, 0, 0)
    beta0, beta_s = q.get()
    assert_equal(1, beta0)
    assert_equal(Vector[0,0,0], beta_s)

    q = ::UnitQuaternion.new(1, 1, 1, 1)
    beta0, beta_s = q.get()
    assert_in_delta(0.5, beta0, 1e-15)
    assert_in_delta((Vector[0.5, 0.5, 0.5] - beta_s).norm(), 0, 1e-15)
  end

  def test_set
    q = ::UnitQuaternion.new
    q.set(0.9848857801796105, 0.1, 0.1, 0.1)
    beta0, beta_s = q.get()
    assert_equal(0.9848857801796105, beta0)
    assert_equal(Vector[0.1, 0.1, 0.1], beta_s)
    assert_equal(1, beta0**2 + beta_s.norm()**2)

    assert_raise(ArgumentError) do
      q.set(1,1,1)
    end

    q.set(1, 0, 0, 0)
    beta0, beta_s = q.get()
    assert_equal(1, beta0)
    assert_equal(Vector[0,0,0], beta_s)

    q.set(1, 1, 1, 1)
    beta0, beta_s = q.get()
    assert_in_delta(0.5, beta0, 1e-15)
    assert_in_delta((Vector[0.5, 0.5, 0.5] - beta_s).norm(), 0, 1e-15)
  end

  def test_setAngleAxis
    axis = Vector[1, 0, 0]
    angle = Math::PI/2
    q = ::UnitQuaternion.new
    q.setAngleAxis(angle, axis)
    beta0, beta_s = q.get()
    assert_equal(Math.cos(angle/2.0), beta0)
    assert_equal(axis[0]*Math.sin(angle/2.0), beta_s[0])
    assert_equal(axis[1]*Math.sin(angle/2.0), beta_s[1])
    assert_equal(axis[2]*Math.sin(angle/2.0), beta_s[2])

    for angle, axis in @angles.product(@axes)
      q = ::UnitQuaternion.new
      q.setAngleAxis(angle, axis)
      beta0, beta_s = q.get()
      assert_in_delta(Math.cos(angle/2), beta0, 1e-15)
      assert_in_delta((beta_s - axis.normalize()*Math.sin(angle/2)).norm(),
                      0, 1e-15)
    end

    q2 = ::UnitQuaternion.new
    assert_raise(ArgumentError) do
      q2.setAngleAxis(0, Vector[0,0,0])
    end
    assert_raise(ArgumentError) do
      q2.setAngleAxis(0, Vector[1,1,1,1])
    end
    assert_raise(ArgumentError) do
      q2 = ::UnitQuaternion.fromAngleAxis(0, Vector[0,0,0])
    end
    assert_raise(ArgumentError) do
      q2 = ::UnitQuaternion.fromAngleAxis(0, Vector[1,1,1,1])
    end
  end

  def test_getAngleAxis
    axis = Vector[1, 2, 3]
    angle = 0.4321
    q = ::UnitQuaternion.fromAngleAxis(angle, axis)
    result_angle, result_axis = q.getAngleAxis()

    assert_in_delta((axis.normalize() - result_axis).norm(), 0, 1e-15)
    assert_in_delta(angle, result_angle, 1e-15)

    # The angle-axis representation of a rotation is not unique.  We could
    # reverse the sign of both the angle and axis, or when the angle is a
    # multiple of 2*PI, any axis will do.  Therefore, we compare rotation
    # matrices instead of angles and axes.
    for angle, axis in @angles.product(@axes)
      q = ::UnitQuaternion.fromAngleAxis(angle, axis)
      a, ax = q.getAngleAxis()
      q2 = ::UnitQuaternion.fromAngleAxis(a, ax)
      assert(areEqualMatrices(q.getRotationMatrix(), q2.getRotationMatrix(),
                              1e-14))
    end
  end

  def test_multiply_inverse
    axis1 = Vector[1, 2, 3]
    angle1 = 1.123
    q1 = ::UnitQuaternion.fromAngleAxis(angle1, axis1)

    axis2 = Vector[1, 2, 3]
    angle2 = -1.123
    q2 = ::UnitQuaternion.fromAngleAxis(angle2, axis2)

    q3 = q1 * q2
    beta0, beta_s = q3.get()
    assert_in_delta(1, beta0, 1e-15)
    assert_in_delta(0, beta_s.norm(), 1e-15)

    for q in @quats
      q_inv = q.inverse()
      result = q * q_inv
      beta0, beta_s = result.get()
      assert_in_delta(1, beta0, 1e-15)
      assert_in_delta(0, beta_s.norm(), 1e-14)
    end
  end

  def test_multiply
    axis1 = Vector[3, 1, 6]
    angle1 = 1.32
    q1 = ::UnitQuaternion.fromAngleAxis(angle1, axis1)

    axis2 = Vector[1, 1, 1]
    angle2 = Math::PI/4
    q2 = ::UnitQuaternion.fromAngleAxis(angle2, axis2)

    q_result = q2*q1
    q_result_mat = q_result.getRotationMatrix()
    
    mat_result = q2.getRotationMatrix() * q1.getRotationMatrix()
    
    for i in 0..2
      assert_in_delta((q_result_mat.row(i) - mat_result.row(i)).norm(),
                      0, 1e-15)
    end

    for q1, q2 in @quats.product(@quats)
      q_result = q2 * q1
      q_result_mat = q_result.getRotationMatrix()
      mat_result = q2.getRotationMatrix() * q1.getRotationMatrix()

      for i in 0..2
        assert_in_delta((q_result_mat.row(i) - mat_result.row(i)).norm(),
                        0, 1e-14)
      end
    end
  end

  def test_transform
    axis = Vector[1,1,1]
    angle = 2*Math::PI/3
    q1 = ::UnitQuaternion.fromAngleAxis(angle, axis)

    v = Vector[1,0,0]
    v_rot = q1.transform(v)
    expected = Vector[0,1,0]

    assert_in_delta((v_rot - expected).norm(), 0, 1e-15)

    for q, v in @quats.product(@axes)
      v_rot = q.transform(v)
      v_expected = q.getRotationMatrix() * v
      assert_in_delta((v_rot - v_expected).norm(), 0, 1e-15)
    end
  end

  def test_inverse    
    angles = [ 0, Math::PI/4, 0.1234, Math::PI/2, 2 ]
    axes = [ Vector[1,1,1], Vector[1,2,3], Vector[0,0,1] ]
    for angle, axis in (angles + @angles).product(axes + @axes)
      q = ::UnitQuaternion.fromAngleAxis(angle, axis)
      q_inv = q.inverse()

      assert(isIdentityMatrix( q.getRotationMatrix() *
                               q_inv.getRotationMatrix(),
                               1e-15 )
             )

      result = q * q_inv
      beta0, beta_s = result.get()
      assert_in_delta(beta0, 1, 1e-15)
      assert_in_delta((beta_s - Vector[0,0,0]).norm(), 0, 1e-15)
    end
  end

  def test_Euler
    # If we generate a quaternion using Euler angles and then ask for
    # the Euler angles from that quaternion, we may get a different
    # answer, since the Euler angles are not unique.  However, if we
    # ask for the Euler angles from the first quaternion, then
    # generate a second quaternion using those same Euler angles, the
    # quaternions should be equal to each other.

    @angles.product(@angles, @angles) do | theta1, theta2, theta3 |
      q = UnitQuaternion.fromEuler(theta1, theta2, theta3, 'xyz')
      @euler.each do |e|
        q2 = UnitQuaternion.fromEuler(*q.getEuler(e), e)
        tol = 1e-7
        if not areEqualMatrices(q.getRotationMatrix(),
                                q2.getRotationMatrix(),
                                tol)
          puts q
          puts q2
          puts q.getRotationMatrix()
          puts q2.getRotationMatrix()
          puts theta1, theta2, theta3, e
          puts q.getEuler(e)
        end
        assert(areEqualMatrices(q.getRotationMatrix(),
                                q2.getRotationMatrix(), tol))
      end
    end

    q = UnitQuaternion.fromEuler(2 * Math::PI/2, 2 * Math::PI/2,
                                 2 * Math::PI/2, 'xyz')
    assert_in_delta((q - UnitQuaternion.new(-1,0,0,0)).norm(), 0, 1e-15)

    assert_raise(ArgumentError) { q.getEuler('xy') }
    assert_raise(ArgumentError) { q.getEuler('xYz') }
    assert_raise(ArgumentError) { q.getEuler('xxy') }
    assert_raise(ArgumentError) { q.getEuler('yyz') }
    assert_raise(ArgumentError) { q.getEuler('xzz') }
    assert_raise(ArgumentError) { q.getEuler('xzb') }
  end

  def test_rotationMatrix
    tol = 1e-7
    @angles.product(@angles, @angles) do | theta1, theta2, theta3 |
      q = ::UnitQuaternion.fromEuler(theta1, theta2, theta3, 'XYZ')

      q_from = ::UnitQuaternion.fromRotationMatrix(q.getRotationMatrix())
      q_set = ::UnitQuaternion.new()
      q_set.setRotationMatrix(q.getRotationMatrix())

      assert(areEqualMatrices(q.getRotationMatrix(),
                              q_from.getRotationMatrix(), tol))
      assert(areEqualMatrices(q.getRotationMatrix(),
                              q_set.getRotationMatrix(), tol))
    end
  end
end
