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
    q = UnitQuaternion.new()
    q.setAngleAxis(angle, axis)
    return q
  end

  def self.fromEuler(theta1, theta2, theta3, axes)
    q = UnitQuaternion.new()
    q.setEuler(theta1, theta2, theta3, axes)
    return q
  end

  def self.fromRotationMatrix(mat)
    q = UnitQuaternion.new()
    q.setRotationMatrix(mat)
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
    
    # if sin(theta/2) = 0, then theta = 2*n*PI, where n is any integer,
    # which means that the object has performed a complete rotation, and
    # any axis will do
    if Math.sin(angle/2).abs() < 1e-15
      axis = Vector[1, 0, 0]
    else
      axis = @beta_s / Math.sin(angle/2)
    end
    return angle, axis
  end

  def setEuler(theta1, theta2, theta3, axes)
    if axes.length() != 3
      raise(ArgumentError, "Must specify exactly 3 axes")
    end
    quats = Array.new(3)
    theta = [theta1, theta2, theta3]
    for i in 0..2
      if axes.upcase()[i] == 'X'
        quats[i] = UnitQuaternion.fromAngleAxis(theta[i], Vector[1, 0, 0])
      elsif axes.upcase()[i] == 'Y'
        quats[i] = UnitQuaternion.fromAngleAxis(theta[i], Vector[0, 1, 0])
      elsif axes.upcase()[i] == 'Z'
        quats[i] = UnitQuaternion.fromAngleAxis(theta[i], Vector[0, 0, 1])
      else
        raise(ArgumentError, "Axes can only be X/x, Y/y, or Z/z")
      end
    end
    if axes == axes.upcase()
      @beta0, @beta_s = (quats[2] * quats[1] * quats[0]).get()
    elsif axes == axes.downcase()
      @beta0, @beta_s = (quats[0] * quats[1] * quats[2]).get()
    else
      raise(ArgumentError, "Axes must be either all uppercase or all " +
            "lowercase")
    end
  end

  def getEuler(axes)
    # Returns the Euler angles about the specified axes.  The axes should
    # be specified as a string, and can be any permutation (with
    # replacement) of 'X', 'Y', and 'Z', as long as no letter is adjacent
    # to itself (for example, 'XYX' is valid, but 'XXY' is not).
    # If the axes are uppercase, this function returns the angles about
    # the global axes.  If they are lowercase, this function returns the
    # angles about the body-fixed axes.
    #
    # This method implements Shoemake's algorithm for finding the Euler
    # angles from a rotation matrix, found in Graphics Gems IV (pg. 222).

    if axes.length() != 3
      raise(ArgumentError, "Exactly 3 axes must be specified in order to " +
            "calculate the Euler angles")
    end

    if axes == axes.upcase()
      # get angles about global axes
      static = true
    elsif axes == axes.downcase()
      # get angles about body-fixes axes
      static = false
      axes = axes.reverse()
    else
      raise(ArgumentError, "Axes must either be all uppercase or all " +
            "lowercase")
    end

    axes = axes.upcase()
    if axes[0] == axes[2]
      same = true
    end

    if not ('XYZ'.include?(axes[0]) and 'XYZ'.include?(axes[1]) and
            'XYZ'.include?(axes[2]) )
      raise(ArgumentError, 'Axes can only be X/x, Y/y, or Z/z')
    end

    if axes.include?('XX') or axes.include?('YY') or
        axes.include?('ZZ')
      raise(ArgumentError, "Cannot rotate about the same axis twice in " +
            "succession")
    end

    # true if the axes specify a right-handed coordinate system, false
    # otherwise
    rh = isRightHanded(axes.upcase())

    p_mat_rows = Array.new()
    unused = [ 'X', 'Y', 'Z' ]
    axes[0..1].each_char() do |a|
      if a == 'X'
        p_mat_rows << getUnitVector(a)
      elsif a == 'Y'
        p_mat_rows << getUnitVector(a)
      elsif a == 'Z'
        p_mat_rows << getUnitVector(a)
      end
      unused.delete(a)
    end
    p_mat_rows << getUnitVector(unused[0])
    
    p_mat = Matrix.rows(p_mat_rows)
    rot_mat = p_mat * getRotationMatrix() * p_mat.transpose()
    # puts "R = ", getRotationMatrix()
    # puts "P = ", p_mat
    # puts "R' = ", rot_mat
    # print("rh = ", rh, "\n")

    theta1, theta2, theta3 = parseMatrix(rot_mat, same)

    # print("theta1 = ", theta1, "\ntheta2 = ", theta2, "\ntheta3 = ",
    #       theta3, "\n")
      
    if not static
      theta1, theta3 = theta3, theta1
    end

    if not rh
      theta1, theta2, theta3 = -theta1, -theta2, -theta3
    end

    return theta1, theta2, theta3
  end

  def setRotationMatrix(mat)
    if mat.row_size() != 3 or mat.column_size() != 3
      raise(ArgumentError, "Rotation matrix must be 3x3")
    end
    tol = 1e-15
    if not isOrthonormalMatrix(mat, tol)
      raise(ArgumentError, "Matrix is not orthonormal (to within " +
            tol.to_s(), ")")
    end
    theta1, theta2, theta3 = parseMatrix(mat, false)
    setEuler(theta1, theta2, theta3, 'XYZ')
  end

  def getRotationMatrix
    # returns the rotation matrix corresponding to this quaternion
    return Matrix[ [ @beta0**2 + @beta_s[0]**2 - @beta_s[1]**2 - @beta_s[2]**2,
                     2*(@beta_s[0]*@beta_s[1] - @beta0*@beta_s[2]),
                     2*(@beta_s[0]*@beta_s[2] + @beta0*@beta_s[1]) ],
                   [ 2*(@beta_s[0]*@beta_s[1] + @beta0*@beta_s[2]),
                     @beta0**2 - @beta_s[0]**2 + @beta_s[1]**2 - @beta_s[2]**2,
                     2*(@beta_s[1]*@beta_s[2] - @beta0*@beta_s[0]) ],
                   [ 2*(@beta_s[0]*@beta_s[2] - @beta0*@beta_s[1]),
                     2*(@beta0*@beta_s[0] + @beta_s[1]*@beta_s[2]),
                     @beta0**2 - @beta_s[0]**2 - @beta_s[1]**2 + @beta_s[2]**2 ] ]
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

  private
  def isRightHanded(axes)
    if axes.length() != 3
      raise(ArgumentError, "Only 3 axes permitted")
    end
    axes == axes.upcase()
    if axes[0..1] == "XY" or axes[0..1] == "YZ" or axes[0..1] == "ZX"
      return true
    else
      return false
    end
  end

  def getUnitVector(axis)
    axis = axis.upcase()
    if axis == 'X'
      return Vector[1, 0, 0]
    elsif axis == 'Y'
      return Vector[0, 1, 0]
    elsif axis == 'Z'
      return Vector[0, 0, 1]
    else
      raise(ArgumentError, "Axis can only be X/x, Y/y, or Z/z")
    end
  end

  def parseMatrix(rot_mat, same)
    # Extracts the Euler angles corresponding to the given matrix.  If
    # same = false, this method returns the angles about the global X,
    # Y, and Z axes (in that order).  If same = true, this method
    # returns the Euler angles about the global X, Y, and X axes (in
    # that order).
    tol = 1e-15
    if same
      # print("rot_mat = ", rot_mat, "\n")
      begin
        theta2 = Math.acos(rot_mat[0,0])
      rescue Math::DomainError
        # the value of rot_mat[0,0] may be off slightly due to truncation
        # error
        # puts("rot_mat[0,0] = " + rot_mat[0,0].to_s + ".  Rounding.")
        if rot_mat[0,0] > 0
          theta2 = 0
        else
          theta2 = Math::PI
        end
      end
      # print("theta2 = ", theta2, "\n")
      if Math.sin(theta2).abs() < Math.sqrt(tol)
        # if sin(theta2) is 0, then the first and third axes are
        # either parallel or antiparallel, so we can only find the sum
        # theta3 + theta1, not the individual angles.  Here, we choose
        # theta3 = 0 and solve for theta1.
        # print("sin(theta2) too small.\n")
        theta3 = 0
        y = rot_mat[2,1]
        x = rot_mat[1,1]
        # print("x = ", x, ", y = ", y, "\n")
        # if y.abs() < 1e-15
        #   y = 0
        # end
        # if x.abs() < 1e-15
        #   x = 0
        # end
        sign = Math.cos(theta2) <=> 0
        # print("x = ", x, ", y = ", y, "\n")
        # print("sign = ", sign, "\n")
        theta1 = Math.atan2(sign * y, x)
      else
        sign = Math.sin(theta2) <=> 0
        theta1 = Math.atan2(sign * rot_mat[0,1], sign * rot_mat[0,2])
        theta3 = Math.atan2(sign * rot_mat[1,0], -sign * rot_mat[2,0])
      end
    else
      begin
        theta2 = Math.asin(-rot_mat[2,0])
      rescue Math::DomainError
        # the value of rot_mat[2,0] may be off slightly due to truncation
        # error
        # puts("rot_mat[2,0] = " + rot_mat[2,0].to_s + ".  Rounding.")
        if -rot_mat[2,0] > 0
          theta2 = Math::PI/2
        else
          theta2 = -Math::PI/2
        end
      end
      # print("theta2 = ", theta2, "\n")
      # print("cos(theta2) = ", Math.cos(theta2), "\n")
      # print("rh = ", rh, "\n")
      # print("static = ", static, "\n")
      # print("axes = ", axes, "\n")
      if Math.cos(theta2).abs() < Math.sqrt(tol)
        # if cos(theta2) is 0, then the first and third axes are
        # either parallel or antiparallel, so we can only find the sum
        # theta3 + theta1.  Here, we choose theta3 = 0 and solve for
        # theta1.
        y = -rot_mat[1,2]
        x = rot_mat[0,2]
        # if y.abs() < 1e-15
        #   y = 0
        # end
        # if x.abs() < 1e-15
        #   x = 0
        # end
        sign = Math.sin(theta2) <=> 0
        # print("x = ", sign * x, ", y = ", y, "\n")
        # print("x_alt = ", rot_mat[1,1], ", y_alt = ", rot_mat[0,1] * sign,
        #       "\n")
        theta1 = Math.atan2(y, sign * x)
        theta3 = 0
      else
        sign = Math.cos(theta2) <=> 0
        # print("rot_mat[2,1] = ", rot_mat[2,1], ", rot_mat[2,2] = ",
        #       rot_mat[2,2], ", sign = ", sign, "\n")
        # print("rot_mat[1,0] = ", rot_mat[1,0], ", rot_mat[0,0] = ",
        #       rot_mat[0,0], ", sign = ", sign, "\n")
        theta1 = Math.atan2(sign * rot_mat[2,1], sign * rot_mat[2,2])
        theta3 = Math.atan2(sign * rot_mat[1,0], sign * rot_mat[0,0])
      end
    end

    return theta1, theta2, theta3
  end

  def isOrthonormalMatrix(mat, tol)
    # Determines if mat is orthonormal.  That is, determines whether
    # mat.transpose() * mat is equal to the identity matrix (to within
    # tol).

    n_rows = mat.row_size()
    n_cols = mat.column_size()
    if (n_rows != n_cols)
      return false
    end
    result = mat.transpose() * mat
    for i in (0...n_rows)
      for j in (0...n_cols)
        if i == j
          if result[i,j] - 1.abs() > tol
            return false
          end
        else
          if result[i,j] > tol
            return false
          end
        end
      end
    end
    return true
  end
end
