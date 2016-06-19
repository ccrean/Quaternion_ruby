require 'matrix'
require_relative 'Quaternion'

class UnitQuaternion < Quaternion

  def initialize(*args)
    if args.length() == 4
      set(*args)
    elsif args.length() == 0
      super(1, 0, 0, 0)
    else
      raise(ArgumentError, "wrong number of arguments (must be 0 or 4)")
    end
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

  def set(w, x, y, z)
    # sets the values of the quaternion
    super(w, x, y, z)
    @beta0, @beta_s = normalized().get()
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
    result.set(@beta0, *(-1*@beta_s))
    return result
  end
end
