class Quaternion
  def initialize
    @beta0 = 1
    @beta1 = 0
    @beta2 = 0
    @beta3 = 0
  end

  def set(beta1, beta2, beta3)
    @beta0 = Math.sqrt(1 - beta1**2 + beta2**2 + beta3**2)
    @beta1 = beta1
    @beta2 = beta2
    @beta3 = beta3
  end

  def setAngleAxis(axis, angle)
    axis = axis.normalize()
    @beta0 = Math.cos(angle / 2.0)
    @beta1 = axis[0] * Math.sin(angle / 2.0)
    @beta2 = axis[1] * Math.sin(angle / 2.0)
    @beta3 = axis[2] * Math.sin(angle / 2.0)
  end

  def print
    puts "(#{@beta0}, #{@beta1}, #{@beta2}, #{@beta3})"
  end
end