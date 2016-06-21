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

  def self.fromEuler(theta1, theta2, theta3, axes)
    q = UnitQuaternion.new()
    q.setEuler(theta1, theta2, theta3, axes)
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

    if axes[0..1].count('X') > 1 or axes[0..1].count('Y') > 1 or
        axes[0..1].count('Z') > 1 or axes[1..2].count('X') > 1 or
        axes[1..2].count('Y') > 1 or axes[1..2].count('Z') > 1
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
    rot_mat = p_mat.transpose() * getRotationMatrix() * p_mat
    puts "R = ", getRotationMatrix()
    puts "P = ", p_mat
    puts "R' = ", rot_mat
    print("rh = ", rh, "\n")

    if same
      begin
        theta2 = Math.acos(rot_mat[0,0])
      rescue Math::DomainError
        # the value of rot_mat[0,0] may be off slightly due to truncation
        # error
        puts("rot_mat[0,0] = " + rot_mat[0,0].to_s + ".  Rounding.")
        if rot_mat[0,0].abs() > 0
          theta2 = 0
        else
          theta2 = Math::PI
        end
      end
      if Math.sin(theta2).abs() < 1e-15
        # if sin(theta2) is 0, then the first and third axes are
        # either parallel or antiparallel, so we can only find the sum
        # theta3 + theta1, not the individual angles.  Here, we choose
        # theta3 = 0 and solve for theta1.
        theta3 = 0
        y = rot_mat[2,1]
        x = -rot_mat[1,1]
        if y.abs() < 1e-15
          y = 0
        end
        if x.abs() < 1e-15
          x = 0
        end
        sign = Math.cos(theta2) <=> 0
        theta1 = Math.atan2(y, sign * x)
      else
        sign = sin(theta2) <=> 0
        theta1 = Math.atan2(sign * rot_mat[0,1], sign * rot_mat[0,2])
        theta3 = Math.atan2(sign * rot_mat[1,0], -sign * rot_mat[2,0])
      end
    else
      begin
        theta2 = Math.asin(-rot_mat[2,0])
      rescue Math::DomainError
        # the value of rot_mat[2,0] may be off slightly due to truncation
        # error
        puts("rot_mat[2,0] = " + rot_mat[2,0].to_s + ".  Rounding.")
        if -rot_mat[2,0] > 0
          theta2 = Math::PI/2
        else
          theta2 = -Math::PI/2
        end
      end
      print("theta2 = ", theta2, "\n")
      print("cos(theta2) = ", Math.cos(theta2), "\n")
      if Math.cos(theta2).abs() < 1e-15
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
        print("x = ", sign * x, ", y = ", y, "\n")
        print("x_alt = ", rot_mat[1,1], ", y_alt = ", rot_mat[0,1] * sign,
              "\n")
        theta1 = Math.atan2(y, sign * x)
        theta3 = 0
      else
        sign = Math.cos(theta2) <=> 0
        print("rot_mat[2,1] = ", rot_mat[2,1], ", rot_mat[2,2] = ",
              rot_mat[2,2], ", sign = ", sign, "\n")
        print("rot_mat[1,0] = ", rot_mat[1,0], ", rot_mat[0,0] = ",
              rot_mat[0,0], ", sign = ", sign, "\n")
        theta1 = Math.atan2(sign * rot_mat[2,1], sign * rot_mat[2,2])
        theta3 = Math.atan2(sign * rot_mat[1,0], sign * rot_mat[0,0])
      end
    end
    print("theta1 = ", theta1, "\ntheta2 = ", theta2, "\ntheta3 = ",
          theta3, "\n")
      
    if not static
      theta1, theta3 = theta3, theta1
    end

    if not rh
      theta1, theta2, theta3 = -theta1, -theta2, -theta3
    end

    return theta1, theta2, theta3
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
    # roll = Math.atan2(2*(@beta0*@beta_s[0] + @beta_s[1]*@beta_s[2]),
    #                   1 - 2*(@beta_s[0]**2 + @beta_s[1]**2))
    # pitch = Math.asin(2*(@beta0*@beta_s[1] - @beta_s[2]*@beta_s[0]))
    # yaw = Math.atan2(2*(@beta0*@beta_s[2] + @beta_s[0]*@beta_s[1]),
    #                  1 - 2*(@beta_s[1]**2 + @beta_s[2]**2))
    yaw = Math.atan2(-2*(@beta_s[0]*@beta_s[1] - @beta0*@beta_s[2]),
                     1 - 2*(@beta_s[1]**2 + @beta_s[2]**2))
    pitch = Math.asin(2*(@beta0*@beta_s[1] + @beta_s[2]*@beta_s[0]))
    roll = Math.atan2(-2*(@beta_s[1]*@beta_s[2] - @beta0*@beta_s[0]),
                      1 - 2*(@beta_s[0]**2 + @beta_s[1]**2))
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
end
