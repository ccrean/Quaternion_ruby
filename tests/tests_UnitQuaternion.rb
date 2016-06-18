require 'test/unit'
require 'matrix'
require_relative '../UnitQuaternion'

class TestUnitQuaternion < Test::Unit::TestCase

  def setup
    @quats = [ ::UnitQuaternion.new(1,2,3,4),
               ::UnitQuaternion.new(0.1, 0.01, 2.3, 4),
               ::UnitQuaternion.new(1234.4134, 689.6124, 134.124, 0.5),
               ::UnitQuaternion.new(1,1,1,1),
             ]
    @angles = [ 2*Math::PI, Math::PI, Math::PI/2, Math::PI/4,
                0.5,  0.25, 0.1234, ]
    @axes = [ Vector[ 1, 1, 1 ], Vector[ 1, 0, 0 ], Vector[ 0, 1, 0 ],
              Vector[ 0, 0, 1 ], Vector[ 1, 2, 3 ], ]
  end

  def test_initialize
    q = ::UnitQuaternion.new(0.1, 0.1, 0.1)
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
    q.set(0.1, 0.1, 0.1)
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

    for angle, axis in @angles.product(@axes)
      q = ::UnitQuaternion.fromAngleAxis(angle, axis)
      a, ax = q.getAngleAxis()
      assert_in_delta(angle, a, 1e-14)
      assert_in_delta((ax - axis.normalize()).norm(), 0, 1e-13)
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

  def test_setRollPitchYawXYZ
    roll = -Math::PI/2
    pitch = -Math::PI/2
    yaw = -Math::PI/2
    q = ::UnitQuaternion.new
    q.setRollPitchYawXYZ(roll, pitch, yaw)

    q2 = ::UnitQuaternion.fromAngleAxis(-Math::PI/2, Vector[0, 1, 0])

    assert_in_delta(q.get()[0], q2.get()[0], 1e-15)
    assert_in_delta((q.get()[1] - q2.get()[1]).norm(), 0, 1e-15)

    q = ::UnitQuaternion.fromRollPitchYawXYZ(Math::PI/2, 0, 0)
    q2 = ::UnitQuaternion.fromAngleAxis(Math::PI/2, Vector[1, 0, 0])
    assert_in_delta((q - q2).norm(), 0, 1e-15)

    q = ::UnitQuaternion.fromRollPitchYawXYZ(0, Math::PI/2, 0)
    q2 = ::UnitQuaternion.fromAngleAxis(Math::PI/2, Vector[0, 1, 0])
    assert_in_delta((q - q2).norm(), 0, 1e-15)

    q = ::UnitQuaternion.fromRollPitchYawXYZ(0, 0, Math::PI/2)
    q2 = ::UnitQuaternion.fromAngleAxis(Math::PI/2, Vector[0, 0, 1])
    assert_in_delta((q - q2).norm(), 0, 1e-15)
  end

  def test_getRollPitchYawXYZ
    angles = [ [0.1, 0, 0], [0, 0.1, 0], [0, 0, 0.1], [0, -Math::PI/2, 0] ]

    for roll, pitch, yaw in angles
      q = ::UnitQuaternion.fromRollPitchYawXYZ(roll, pitch, yaw)
      
      r, p, y = q.getRollPitchYawXYZ()

      assert_in_delta(roll, r, 1e-15)
      assert_in_delta(pitch, p, 1e-15)
      assert_in_delta(yaw, y, 1e-15)
    end
  end

  def test_inverse
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
end
