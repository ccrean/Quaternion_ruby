# Quaternion

This package provides a Quaternion class, along with a UnitQuaternion
class that is designed to be used to represent rotations.

## Installation

This package is not available through any gem repository (yet).  Install it using:

$ sudo rake install

## Usage

The Quaternion and UnitQuaternion classes must be included separately
in your program, using the following lines:

require 'Quaternion'

require 'UnitQuaternion'

Note that requiring UnitQuaternion will automatically give you access
to the Quaternion class as well, but not the other way around.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
