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
    return Matrix[ [ 1 - 2*@beta_s[1]**2 - 2*@beta_s[2]**2,
                     2*(@beta_s[0]*@beta_s[1] - @beta0*@beta_s[2]),
                     2*(@beta0*@beta_s[1] + @beta_s[0]*@beta_s[2]) ],
                   [ 2*(@beta_s[0]*@beta_s[2] + @beta_s[0]*@beta_2[2]),
                     1 - 2*@beta_s[0]**2 - 2*@beta_s[2]**2,
                     2*(@beta_s[1]*@beta_s[2] - @beta0*@beta_s[0]) ],
                   [ 2*(@beta_s[0]*@beta_s[2] - @beta0*@beta_s[1]),
                     2*(@beta0*@beta_s[0] - @beta_s[1]*@beta_s[2]),
                     1 - 2*@beta_s[0]**2 - 2*@beta_s[1]**2 ] ]
  end

  def transform(vec)
    # transforms vec by applying the rotation represented by this quaternion,
    # and returns the result
  end

  def *(q)
    q_beta0, q_beta_s = q.get()
    beta0 = @beta0 * q_beta0 - @beta_s.inner_product(q_beta_s)
    beta_s =  @beta0 * q_beta_s + q_beta0 * @beta_s +
      cross_product(@beta_s, q_beta_s)
    result = Quaternion.new
    result.set(beta_s[0], beta_s[1], beta_s[2])
    return result
  end

  def print
    puts "(#{@beta0}, #{@beta1}, #{@beta2}, #{@beta3})"
  end

  private
  def cross_product(v1, v2)
    # returns the cross product of vectors v1 and v2
    return Vector[ v1[1]*v2[2] - v1[2]*v2[1],
                   v1[2]*v2[0] - v1[0]*v2[2],
                   v1[0]*v2[1] - v1[1]*v2[0] ]
  end
end
