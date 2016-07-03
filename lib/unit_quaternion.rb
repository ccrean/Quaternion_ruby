# Author:: Cory Crean (mailto:cory.crean@gmail.com)
# Copyright:: Copyright (c) 2016 Cory Crean
# License:: BSD
#
# A unit quaternion class, designed to represent spatial rotations.
# Can convert between common representations of spatial rotations,
# such as angle-axis, Euler angles, and rotation matrices.

require 'matrix'
require_relative 'quaternion'

class UnitQuaternion < Quaternion

  # Creates a new UnitQuaternion from 4 values.  If the resulting
  # quaternion does not have magnitude 1, it will be normalized.  If
  # no arguments are provided, creates the quaternion (1, 0, 0, 0).
  def initialize(*args)
    if args.length() == 4
      set(*args)
    elsif args.length() == 0
      super(1, 0, 0, 0)
    else
      raise(ArgumentError, "wrong number of arguments (must be 0 or 4)")
    end
  end

  # Initializes a quaternion from the angle-axis representation of a
  # rotation.  The sense of the rotation is determined according to
  # the right-hand rule.
  # 
  # Params:
  # +angle+:: A scalar representing the angle of the rotation (in radians)
  # +axis+:: A vector representing the axis of rotation (need not be a unit vector)
  def self.fromAngleAxis(angle, axis)
    q = UnitQuaternion.new()
    q.setAngleAxis(angle, axis)
    return q
  end

  # Initializes a quaternion from a set of 3 Euler angles.
  # 
  # Params:
  # +theta1+:: The angle of rotation about the first axis
  # +theta2+:: The angle of rotation about the second axis
  # +theta3+:: The angle of rotation about the third axis
  # +axes+:: A string of 3 letters ('X/x', 'Y/y', or 'Z/z') representing the three axes of rotation.  Must be all uppercase or all lowercase.  If the string is uppercase, the rotations are performed about the inertial axes.  If the string is lowercase, the rotations are performed about the body-fixed axes.  Repeated axes are allowed, but not in succession (for example, 'xyx' is fine, but 'xxy' is not allowed).
  def self.fromEuler(theta1, theta2, theta3, axes)
    q = UnitQuaternion.new()
    q.setEuler(theta1, theta2, theta3, axes)
    return q
  end

  # Initializes a quaternion from a rotation matrix.
  # 
  # Params:
  # +mat+:: A 3x3 orthonormal matrix.
  def self.fromRotationMatrix(mat)
    q = UnitQuaternion.new()
    q.setRotationMatrix(mat)
    return q
  end

  # Set the quaternion's values.  If the 4 arguments do not form an
  # unit quaternion, the resulting quaternion is normalized.
  # 
  # Params:
  # +w+:: the real part of the quaterion
  # +x+:: the i-component
  # +y+:: the j-component
  # +z+:: the k-component
  def set(w, x, y, z)
    super(w, x, y, z)
    @beta0, @beta_s = normalized().get()
  end

  # Sets the values of the quaternion from the angle-axis
  # representation of a rotation.  The sense of the rotation is
  # determined according to the right-hand rule.
  # 
  # Params:
  # +angle+:: A scalar representing the angle of the rotation (in radians)
  # +axis+:: A vector representing the axis of rotation (need not be a unit vector)
  def setAngleAxis(angle, axis)
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

  # Returns the angle-axis representation of the rotation represented
  # by the quaternion.
  # 
  # Returns:
  # +angle+:: A scalar representing the angle of rotation (in radians)
  # +axis+:: A unit vector representing the axis of rotation
  def getAngleAxis
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

  # Sets the values of the quaternion from a set of 3 Euler angles.
  # 
  # Params:
  # +theta1+:: The angle of rotation about the first axis
  # +theta2+:: The angle of rotation about the second axis
  # +theta3+:: The angle of rotation about the third axis
  # +axes+:: A string of 3 letters ('X/x', 'Y/y', or 'Z/z') representing the three axes of rotation.  Must be all uppercase or all lowercase.  If the string is uppercase, the rotations are performed about the inertial axes.  If the string is lowercase, the rotations are performed about the body-fixed axes.  Repeated axes are allowed, but not in succession (for example, 'xyx' is fine, but 'xxy' is not allowed).
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

  # Returns the Euler angles corresponding to this quaternion.
  # 
  # Params:
  # +axes+:: A string of 3 letters ('X/x', 'Y/y', or 'Z/z') representing the three axes of rotation.  Must be all uppercase or all lowercase.  If the string is uppercase, the rotations are performed about the inertial axes.  If the string is lowercase, the rotations are performed about the body-fixed axes.  Repeated axes are allowed, but not in succession (for example, 'xyx' is fine, but 'xxy' is not allowed).
  # 
  # Returns:
  # +theta1+:: The angle of rotation about the first axis
  # +theta2+:: The angle of rotation about the second axis
  # +theta3+:: The angle of rotation about the third axis
  def getEuler(axes)
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

    theta1, theta2, theta3 = parseMatrix(rot_mat, same)

    if not static
      theta1, theta3 = theta3, theta1
    end

    if not rh
      theta1, theta2, theta3 = -theta1, -theta2, -theta3
    end

    return theta1, theta2, theta3
  end

  # Sets the values of the quaternion from a rotation matrix.
  # 
  # Params:
  # +mat+:: A 3x3 orthonormal matrix.
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

  # Returns the rotation matrix corresponding to this quaternion.
  def getRotationMatrix
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

  # Transforms a vector by applying to it the rotation represented by
  # this quaternion, and returns the result.
  # 
  # Params:
  # +vec+:: A 3-D vector in the unrotated frame.
  def transform(vec)
    return getRotationMatrix() * vec
  end

  # Returns the inverse of the quaternion.
  def inverse
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
        if rot_mat[0,0] > 0
          theta2 = 0
        else
          theta2 = Math::PI
        end
      end
      if Math.sin(theta2).abs() < Math.sqrt(tol)
        # if sin(theta2) is 0, then the first and third axes are
        # either parallel or antiparallel, so we can only find the sum
        # theta3 + theta1, not the individual angles.  Here, we choose
        # theta3 = 0 and solve for theta1.
        theta3 = 0
        y = rot_mat[2,1]
        x = rot_mat[1,1]
        sign = Math.cos(theta2) <=> 0
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
        if -rot_mat[2,0] > 0
          theta2 = Math::PI/2
        else
          theta2 = -Math::PI/2
        end
      end
      if Math.cos(theta2).abs() < Math.sqrt(tol)
        # if cos(theta2) is 0, then the first and third axes are
        # either parallel or antiparallel, so we can only find the sum
        # theta3 + theta1.  Here, we choose theta3 = 0 and solve for
        # theta1.
        y = -rot_mat[1,2]
        x = rot_mat[0,2]
        sign = Math.sin(theta2) <=> 0
        theta1 = Math.atan2(y, sign * x)
        theta3 = 0
      else
        sign = Math.cos(theta2) <=> 0
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
