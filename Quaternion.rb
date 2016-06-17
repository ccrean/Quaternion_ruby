require 'matrix'

class Quaternion
  def initialize
    @beta0 = 1
    @beta1 = 0
    @beta2 = 0
    @beta3 = 0
  end

  def set(beta1, beta2, beta3)
    @beta0 = Math.sqrt(1 - (beta1**2 + beta2**2 + beta3**2))
    @beta1 = beta1
    @beta2 = beta2
    @beta3 = beta3
  end

  def get
    return Vector[@beta0, @beta1, @beta2, @beta3]
  end

  def setAngleAxis(angle, axis)
    axis = axis.normalize()
    @beta0 = Math.cos(angle / 2.0)
    @beta1 = axis[0] * Math.sin(angle / 2.0)
    @beta2 = axis[1] * Math.sin(angle / 2.0)
    @beta3 = axis[2] * Math.sin(angle / 2.0)
  end

  def getAngleAxis
    angle = 2*Math.acos(@beta0)
    axis = [0,0,0]
    axis[0] = @beta1 / Math.sin(angle/2)
    axis[1] = @beta2 / Math.sin(angle/2)
    axis[2] = @beta3 / Math.sin(angle/2)
    return angle, Vector.elements(axis)
  end

  def print
    puts "(#{@beta0}, #{@beta1}, #{@beta2}, #{@beta3})"
  end
end
