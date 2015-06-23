###############################################################
#   
#  File:      spec_helper.rb
#
#  Author:    Christian Hättich
#
#  Project:   System-On-Chip Maker
#
#  Target:    Linux / Windows / Mac
#
#  Language:  ruby
#
#
###############################################################
#
#
#   Copyright (C) 2014  Christian Hättich  - feddischson [ at ] opencores.org
#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#
###############################################################
#
#   Description:
#     This little helper is included in all specifications.
#     We initialise the SOCMaker module 
#        - without loading the library
#        - with logging to NULL
#     In addition, we enable warnings and colors.
#
#
###############################################################
require 'rubygems'
require 'rspec'
require 'simplecov'
SimpleCov.start
require 'soc_maker'

RSpec.configure do |config|


  SOCMaker::load(    skip_refresh: true,                       # no loading of a lib
                     logger_out: File.open(File::NULL, "w")    # no logger output
                     )
  config.warnings      = true
  config.color         = true

  # == Mock Framework
  #
  # RSpec uses it's own mocking framework by default. If you prefer to
  # use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_framework = :mocha
  # config.mock_framework = :flexmock
  # config.mock_framework = :rr
end










