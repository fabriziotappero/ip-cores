###############################################################
#   
#  File:      ypp_spec.rb
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
#
#
#
#
###############################################################
require_relative( 'spec_helper' )





describe SOCMaker::YPP, "pre-processing to yaml" do

  [ "testSOCM_COREtest", 
    "test SOCM CORE test", 
    "SOCM CORE test", 
    "SOCM CORE",
    "SOCM_CORE3",
    "5SOCM_CORE test",
    "abc SOCM_CORE1 test" ].each do |w|
    it "should not replace our tokens in these examples" do
      SOCMaker::YPP.to_yaml( w ).should == w
    end
  end

  [ [ "test abcd SOCM_CORE xyz 234", "test abcd --- !ruby/object:SOCMaker::CoreDef xyz 234" ], 
    [ "abc\n\tSOCM_CORE\n\n\tabc\n", "abc\n\t--- !ruby/object:SOCMaker::CoreDef\n\n\tabc\n" ],
    [ "a b c SOCM_IFC_SPC x y z", "a b c --- !ruby/object:SOCMaker::IfcSpc x y z"       ],
    [ "a b c SOCM_IFC x y z", "a b c !ruby/object:SOCMaker::IfcDef x y z"       ],
    [ "a b c SOCM_PORT x y z", "a b c !ruby/object:SOCMaker::IfcPort x y z"     ],
    [ "a b c SOCM_HDL_FILE x y z", "a b c !ruby/object:SOCMaker::HDLFile x y z" ],
    [ "a b c SOCM_SENTRY x y z", "a b c !ruby/object:SOCMaker::SParameterEntry x y z" ],
    [ "a b c SOCM_INCLUDE x y z", "a b c --- !ruby/object:SOCMaker::LibInc x y z" ],
    [ "a b c SOCM_CONF x y z", "a b c --- !ruby/object:SOCMaker::Conf x y z" ]
     ].each do |w|
    it "should replace a single token" do
      SOCMaker::YPP.to_yaml( w[0] ).should == w[1]
    end
  end


  [ [ "a b SOCM_CORE 234\n\tSOCM_SOC ab\n\t", 
      "a b --- !ruby/object:SOCMaker::CoreDef 234\n\t--- !ruby/object:SOCMaker::SOCDef ab\n\t" ],
    [ " a b SOCM_CORE SOCM_SOC SOCM_CORE\n\tSOCM_CORE abc",
      " a b --- !ruby/object:SOCMaker::CoreDef --- !ruby/object:SOCMaker::SOCDef --- !ruby/object:SOCMaker::CoreDef\n\t--- !ruby/object:SOCMaker::CoreDef abc" ] ].each do |w|
    it "should replace multiple tokens" do
      SOCMaker::YPP.to_yaml( w[0] ).should == w[1]
    end
  end

end


describe SOCMaker::YPP, "post-processing from yaml" do
 
  %w[ CoreDef
      SOCDef
      IfcSpc ].each do |w|
    it "should replace a YAML object string part" do
      tmp = "--- !ruby/object:SOCMaker::" + w + "\nsomemoretext"
      SOCMaker::YPP.from_yaml( tmp ).should ==  SOCMaker::conf[ :YPP_INV_LUT ][ w ] + "\nsomemoretext"
    end
  end

  %w[ Conf
      IfcDef
      IfcPort
      HDLFile
      Parameter
      SParameter
      SParameterEntry
      LibInc ].each do |w|
    it "should replace a YAML object string part" do
      tmp = "!ruby/object:SOCMaker::" + w + "\nsomemoretext"
      SOCMaker::YPP.from_yaml( tmp ).should == SOCMaker::conf[ :YPP_INV_LUT ][ w ] + "\nsomemoretext"
    end
  end

end

describe SOCMaker::YPP, "multiple ojbects from yaml" do

  tmp = """SOCM_CORE
a
b
c
d
SOCM_INCLUDE
e
f
g
"""
  it "should pass to strings to a block" do
    cnt = 0
    result = []
    SOCMaker::YPP.to_yaml( tmp ) do |substr|
      cnt+=1 
      result << substr
    end
    result[ 0 ].should be == """--- !ruby/object:SOCMaker::CoreDef
a
b
c
d
"""
    result[ 1 ].should be == """--- !ruby/object:SOCMaker::LibInc
e
f
g
"""
    cnt.should be == 2
  end

end


# vim: noai:ts=2:sw=2
