require 'matrix'
require_relative 'Quaternion'

class UnitQuaternion < Quaternion

  def initialize
    # initializes a quaternion from the vaules of the Euler parameters
    super(1, 0, 0, 0)
  end

  def self.fromAngleAxis(angle, axis)
    # intializes a quaternion from the angle-axis representation of a
    # rotation
    q = UnitQuaternion.new
    q.setAngleAxis(angle, axis)
    return q
  end

  def self.fromRollPitchYawXYZ(roll, pitch, yaw)
    # initializes a quaternion from roll, pitch, and yaw angles (about the
    # x, y, and z axes, respectively)
    q = UnitQuaternion.new
    q.setRollPitchYawXYZ(roll, pitch, yaw)
    return q
  end

  def set(beta1, beta2, beta3)
    # sets Euler parameters
    if (beta1**2 + beta2**2 + beta3**2) > 1
      raise(ArgumentError, "The sum of the squares of the arguments must " +
            "be less than or equal to 1")
    end
    @beta0 = Math.sqrt(1 - (beta1**2 + beta2**2 + beta3**2))
    @beta_s = Vector[beta1, beta2, beta3]
  end

  def setAngleAxis(angle, axis)
    # sets the quaternion based on the angle-axis representation of a
    # rotation
    if axis == Vector[0,0,0]
      raise(ArgumentError, "Axis must not be the zero vector")
    end
    if axis.size() != 3
      raise(ArgumentError, "Axis must be a 3-dimensional vector")
    end
    axis = axis.normalize()
    @beta0 = Math.cos(angle / 2.0)
    beta1 = axis[0] * Math.sin(angle / 2.0)
    beta2 = axis[1] * Math.sin(angle / 2.0)
    beta3 = axis[2] * Math.sin(angle / 2.0)
    @beta_s = Vector[beta1, beta2, beta3]
  end

  def getAngleAxis
    # return the angle-axis representation of the rotation contained in
    # this quaternion
    angle = 2*Math.acos(@beta0)
    axis = @beta_s / Math.sin(angle/2)
    return angle, axis
  end

  def setRollPitchYawXYZ(roll, pitch, yaw)
    # sets the quaternion from the roll, pitch, and yaw angles
    q_roll = UnitQuaternion.fromAngleAxis(roll, Vector[1,0,0])
    q_pitch = UnitQuaternion.fromAngleAxis(pitch, Vector[0,1,0])
    q_yaw = UnitQuaternion.fromAngleAxis(yaw, Vector[0,0,1])
    result = q_roll * q_pitch * q_yaw
    @beta0, @beta_s = result.get()
  end

  def getRollPitchYawXYZ
    # returns the roll, pitch, and yaw angles corresponding to this
    # quaternion
    roll = Math.atan2(2*(@beta0*@beta_s[0] + @beta_s[1]*@beta_s[2]),
                      1 - 2*(@beta_s[0]**2 + @beta_s[1]**2))
    pitch = Math.asin(2*(@beta0*@beta_s[1] - @beta_s[2]*@beta_s[0]))
    yaw = Math.atan2(2*(@beta0*@beta_s[2] + @beta_s[0]*@beta_s[1]),
                     1 - 2*(@beta_s[1]**2 + @beta_s[2]**2))
    return roll, pitch, yaw
  end

  def getRotationMatrix
    # returns the rotation matrix corresponding to this quaternion
    return Matrix[ [ 1 - 2*@beta_s[1]**2 - 2*@beta_s[2]**2,
                     2*(@beta_s[0]*@beta_s[1] - @beta0*@beta_s[2]),
                     2*(@beta_s[0]*@beta_s[2] + @beta0*@beta_s[1]) ],
                   [ 2*(@beta_s[0]*@beta_s[1] + @beta0*@beta_s[2]),
                     1 - 2*@beta_s[0]**2 - 2*@beta_s[2]**2,
                     2*(@beta_s[1]*@beta_s[2] - @beta0*@beta_s[0]) ],
                   [ 2*(@beta_s[0]*@beta_s[2] - @beta0*@beta_s[1]),
                     2*(@beta0*@beta_s[0] + @beta_s[1]*@beta_s[2]),
                     1 - 2*@beta_s[0]**2 - 2*@beta_s[1]**2 ] ]
  end

  def transform(vec)
    # transforms vec by applying the rotation represented by this
    # quaternion, and returns the result
    return getRotationMatrix() * vec
  end

  def inverse
    # returns the inverse of the quaternion
    result = UnitQuaternion.new
    result.set(*(-1*@beta_s))
    return result
  end

  def *(q)
    # multiplies two quaternions and returns the result
    q_beta0, q_beta_s = q.get()
    beta0 = @beta0 * q_beta0 - @beta_s.inner_product(q_beta_s)
    beta_s =  @beta0 * q_beta_s + q_beta0 * @beta_s +
      cross_product(@beta_s, q_beta_s)
    result = UnitQuaternion.new
    result.set(beta_s[0], beta_s[1], beta_s[2])
    return result
  end
end
