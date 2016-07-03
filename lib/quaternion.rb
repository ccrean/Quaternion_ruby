# Author:: Cory Crean (mailto:cory.crean@gmail.com)
# Copyright:: Copyright (c) 2016 Cory Crean
# License:: BSD
#
# A basic quaternion class, which implements standard operations such
# as addition, subtraction, multiplication, scalar division,
# inversion, conjugation, etc.

require 'matrix'

class Quaternion

  # Create new quaternion from 4 values.  If no arguments are
  # provided, creates the zero quaternion.
  def initialize(*args)
    if args.length() == 4
      set(*args)
    elsif args.length() == 0
      set(0, 0, 0, 0)
    else
      raise(ArgumentError, "wrong number of arguments (must be 0 or 4)")
    end
  end

  # Set the quaternion's values.
  # 
  # Params:
  # +w+:: the real part of the quaterion
  # +x+:: the i-component
  # +y+:: the j-component
  # +z+:: the k-component
  def set(w, x, y, z)
    @beta0 = w
    @beta_s = Vector[x,y,z]
  end

  # Returns the quaternion's values as a scalar and a vector.
  def get
    return @beta0, @beta_s
  end

  # Returns the magnitude of the quaternion.
  def norm
    return Math.sqrt(@beta0**2 + @beta_s.norm()**2)
  end

  # Returns the conjugate of the quaternion.
  def conjugate
    return Quaternion.new(@beta0, *(-1*@beta_s))
  end

  # Returns the multiplicative inverse of the quaterion.
  def inverse
    return self.conjugate() / self.norm() ** 2
  end

  # Returns a normalized quaternion.  q.normalized() is equivalent to
  # q/q.norm().
  def normalized
    return self / norm()
  end

  # Returns the sum of two quaternions.
  def +(q)
    beta0, beta_s = q.get()
    return Quaternion.new(@beta0 + beta0, *(@beta_s + beta_s))
  end

  # Returns the difference of two quaternions.
  def -(q)
    beta0, beta_s = q.get()
    return Quaternion.new(@beta0 - beta0, *(@beta_s - beta_s))
  end

  # Returns the additive inverse of the quaternion.
  def -@
    Quaternion.new(-@beta0, -@beta_s[0], -@beta_s[1], -@beta_s[2])
  end

  # Returns the result of dividing the quaternion by a scalar.
  def /(s)
    return Quaternion.new(@beta0 / s, *(@beta_s / s))
  end

  # Returns the result of multiplying the quaternion by a scalar or
  # another quaternion.
  def *(q)
    if q.is_a?(Numeric)
      return Quaternion.new(@beta0 * q, *(@beta_s * q))
    elsif q.is_a?(Quaternion)
      q_beta0, q_beta_s = q.get()
      beta0 = @beta0 * q_beta0 - @beta_s.inner_product(q_beta_s)
      beta_s =  @beta0 * q_beta_s + q_beta0 * @beta_s +
        cross_product(@beta_s, q_beta_s)
      result = self.class.new(beta0, *beta_s)
      return result
    end
  end

  # Returns true if two quaternions are equal (meaning that their
  # corresponding entries are equal to each other) and false otherwise.
  def ==(q)
    if get() == q.get()
      return true
    else
      return false
    end
  end

  # Returns the string representation of the quaternion.
  def to_s
    return "(" + @beta0.to_s + ", " + @beta_s.to_s + ")"
  end

  def coerce(other)
    return self, other
  end

  private
  def cross_product(v1, v2)
    # returns the cross product of vectors v1 and v2.
    return Vector[ v1[1]*v2[2] - v1[2]*v2[1],
                   v1[2]*v2[0] - v1[0]*v2[2],
                   v1[0]*v2[1] - v1[1]*v2[0] ]
  end

end
