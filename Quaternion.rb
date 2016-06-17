require 'matrix'

class Quaternion

  def initialize
    # initializes a quaternion from the vaules of the Euler parameters
    @beta0 = 1
    @beta_s = Vector[0, 0, 0]
  end

  def set(beta1, beta2, beta3)
    # sets Euler parameters
    @beta0 = Math.sqrt(1 - (beta1**2 + beta2**2 + beta3**2))
    @beta_s = Vector[beta1, beta2, beta3]
  end

  def get
    # returns Euler parameters
    return @beta0, @beta_s
  end

  def setAngleAxis(angle, axis)
    # sets the quaternion based on the angle-axis representation of a
    # rotation
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

  def setRollPitchYaw(roll, pitch, yaw)
    # sets the quaternion from the roll, pitch, and yaw angles
  end

  def getRollPitchYaw
    # returns the roll, pitch, and yaw angles corresponding to this
    # quaternion
  end

  def getRotationMatrix
    # returns the rotation matrix corresponding to this quaternion
  end

  def transform(vec)
    # transforms vec by applying the rotation represented by this quaternion,
    # and returns the result
  end

  def print
    puts "(#{@beta0}, #{@beta1}, #{@beta2}, #{@beta3})"
  end
end
