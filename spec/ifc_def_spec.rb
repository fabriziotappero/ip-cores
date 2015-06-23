###############################################################
#   
#  File:      ifc_spc_spec.rb
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
#     Test specification for SOCMaker::IfcDef
#
#
#
#
###############################################################
require_relative( 'spec_helper' )

describe SOCMaker::IfcDef, "verification" do

  tmp_port = SOCMaker::IfcPort.new( "abc" )

  it "should return a SOCMaker::IfcDef object when creating with new" do
    s = SOCMaker::IfcDef.new( "myifc", "myifc,v1", 1, { test: tmp_port  } )
    s.class.should be SOCMaker::IfcDef
  end

  it "should raise an error if the name is not a string" do
     expect{ SOCMaker::IfcDef.new( 4, "myifc,v1", 1, { test: tmp_port  } )  }.
        to raise_error( SOCMaker::ERR::ValueError )
  end
 
  it "should raise an error if the direction is neither 0 nor 1 " do
     expect{ SOCMaker::IfcDef.new( "myifc", "myifc,v1", 4, { test: tmp_port  } )  }.
        to raise_error( SOCMaker::ERR::ValueError )
  end


  it "should raise an error if no ports are given " do
     expect{ SOCMaker::IfcDef.new( "myifc", "myifc,v1", 4, { } )  }.
        to raise_error( SOCMaker::ERR::StructureError )
  end


  it "should raise an error if a ports is nil " do
     expect{ SOCMaker::IfcDef.new( "myifc", "myifc,v1", 4, { a_port: nil} )  }.
        to raise_error( SOCMaker::ERR::StructureError )
  end

  it "should raise an error if a ports is not of type SOCMaker::IfcPort " do
     expect{ SOCMaker::IfcDef.new( "myifc", "myifc,v1", 4, { a_port: "string-type"} )  }.
        to raise_error( SOCMaker::ERR::StructureError )
  end

  it "should raise an error if no ports are given (nil)" do
     expect{ SOCMaker::IfcDef.new( "myifc", "myifc,v1", 4, nil )  }.
        to raise_error( SOCMaker::ERR::StructureError )
  end

end

describe SOCMaker::IfcDef, "object handling, en-decoding:" do
  tmp_port = SOCMaker::IfcPort.new( "abc" )

  it "should return false for two non-equal objects" do
    o1 = SOCMaker::IfcDef.new( "myifc", "myifc,v1", 1, { test: tmp_port  } )
    o2 = Marshal::load(Marshal.dump(o1))
    o2.id = "myifc,v2"
    ( o2 == o1 ).should be == false
  end

  it "should be possible to encode and decode a interface definition" do
    o1 = SOCMaker::IfcDef.new( "myifc", "myifc,v1", 1, { test: tmp_port  } )
    yaml_str = o1.to_yaml
    o2 = YAML::load( yaml_str )
    o1.should be == o2
  end





end


# vim: noai:ts=2:sw=2

