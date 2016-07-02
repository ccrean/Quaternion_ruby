# Quaternion

This package provides a Quaternion class, along with a UnitQuaternion
class that is designed to be used to represent rotations.

## Installation

You can install this gem in either of the following ways:

$ sudo gem install unit_quaternion

or

$ sudo rake install

## Usage

To use the Quaternion and UnitQuaternion classes in your program,
include the following line:

require 'unit_quaternion'

You can perform basic quaternion operations, such as addition and multiplication:

q1 = Quaternion.new(1,2,3,4)
=> (1, Vector[2, 3, 4])

q2 = Quaternion.new(4,3,2,1)
=> (4, Vector[3, 2, 1])

q1 + q2
=> (5, Vector[5, 5, 5])

q1 * q2
=> (-12, Vector[6, 24, 12])

You can use the UnitQuaternion class to represent spatial rotations.
The following represents a rotation of PI/2 radians about the x-axis:

qx = UnitQuaternion.fromAngleAxis(Math::PI/2, Vector[1, 0, 0])
=> (0.7071067811865476, Vector[0.7071067811865475, 0.0, 0.0])

The following represents a rotation of PI/2 radians about the y-axis:

qy = UnitQuaternion.fromAngleAxis(Math::PI/2, Vector[0, 1, 0])
=> (0.7071067811865476, Vector[0.0, 0.7071067811865475, 0.0])

You can use quaternion multiplication to compose rotations.  If we
want to find the quaternion describing a rotation about the body-fixed
x-axis, followed by a rotation about the body-fixed y-axis, we would
do the following:

q = qx * qy
=> (0.5000000000000001, Vector[0.5, 0.5, 0.4999999999999999])

Notice that this is the same as:

q = UnitQuaternion.fromEuler(Math::PI/2, Math::PI/2, 0, 'xyz')
=> (0.5000000000000001, Vector[0.5, 0.5, 0.4999999999999999])

If we want to find the quaternion describing a rotation the inertial
x-axis, followed by a rotation about the inertial y-axis, we would do
the following:

q = qy * qx
=> (0.5000000000000001, Vector[0.5, 0.5, -0.4999999999999999])

Notice that this is the same as:

q = UnitQuaternion.fromEuler(Math::PI/2, Math::PI/2, 0, 'XYZ')
=> (0.5000000000000001, Vector[0.5, 0.5, -0.4999999999999999])

Additionally, you can use the method fromRotationMatrix to set the
values of the quaternion from an orthonormal 3x3 matrix.  Finally, you
can use the methods getAngleAxis, getEuler, and getRotationMatrix to
find any of the corresponding representations of a spatial rotation
from a given quaternion.

The transform method takes a vector as an argument and returns the
result of rotating that vector through the rotation described by the
quaternion.  For example:

q = UnitQuaternion.fromAngleAxis(Math::PI/2, Vector[0, 0, 1])
=> (0.7071067811865476, Vector[0.0, 0.0, 0.7071067811865475])

v = Vector[1, 0, 0]
=> Vector[1, 0, 0]

q.transform(v)
=> Vector[2.220446049250313e-16, 1.0, 0.0]

gives the result of rotating the vector (1, 0, 0) through PI/2 radians
about the z-axis.

The inverse method returns the inverse of a given Quaternion.  If we
have a UnitQuaternion q representing a rotation of theta radians about
the axis n, then q.inverse() represents a rotation of -theta about n
or, equivalently, a rotation of theta about -n.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
