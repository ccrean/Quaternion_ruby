# Name: tests.rb
# Description: Runs all test cases for both the Quaternion and
#              UnitQuaternion class, and produces code coverage information.
# Author: Cory Crean
# E-mail: cory.crean@gmail.com
# Copyright (c) 2016, Cory Crean

require 'simplecov'
SimpleCov.start
require 'test/unit'
require_relative 'tests_Quaternion'
require_relative 'tests_UnitQuaternion'
