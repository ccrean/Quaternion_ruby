require 'matrix'

class Quaternion

  def initialize(w, x, y, z)
    @beta0 = w
    @beta_s = Vector[x,y,z]
  end

  def set(w, x, y, z)
    @beta0 = w
    @beta_s = Vector[x,y,z]
  end

  def get
    # returns the values in the quaternion
    return @beta0, @beta_s
  end

  def norm
    # returns the magnitude of the quaternion
    return Math.sqrt(@beta0**2 + @beta_s.norm()**2)
  end

  def conjugate
    # returns the conjugate of the quaternion
    return Quaternion.new(@beta0, *(-1*@beta_s))
  end

  def inverse
    # returns the multiplicative inverse of the quaterion
    return self.conjugate() / self.norm() ** 2
  end

  def +(q)
    # adds two quaternions
    beta0, beta_s = q.get()
    return Quaternion.new(@beta0 + beta0, *(@beta_s + beta_s))
  end

  def -(q)
    # subtracts two quaternions
    beta0, beta_s = q.get()
    return Quaternion.new(@beta0 - beta0, *(@beta_s - beta_s))
  end

  def /(s)
    # divides a quaternion by a scalar
    return Quaternion.new(@beta0 / s, *(@beta_s / s))
  end

  def *(q)
    # multiplies q by a scalar or another quaternion
    if q.is_a?(Numeric)
      return Quaternion.new(@beta0 * q, *(@beta_s * q))
    elsif q.is_a?(Quaternion)
      q_beta0, q_beta_s = q.get()
      beta0 = @beta0 * q_beta0 - @beta_s.inner_product(q_beta_s)
      beta_s =  @beta0 * q_beta_s + q_beta0 * @beta_s +
        cross_product(@beta_s, q_beta_s)
      result = Quaternion.new(beta0, *beta_s)
      return result
    end
  end

  def print
    puts "(#{@beta0}, #{@beta_s})"
  end

  private
  def cross_product(v1, v2)
    # returns the cross product of vectors v1 and v2
    return Vector[ v1[1]*v2[2] - v1[2]*v2[1],
                   v1[2]*v2[0] - v1[0]*v2[2],
                   v1[0]*v2[1] - v1[1]*v2[0] ]
  end

end
