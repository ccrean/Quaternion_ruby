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
