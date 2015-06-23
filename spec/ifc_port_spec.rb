###############################################################
#   
#  File:      ifc_port_spec.rb
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
#     Test specification for SOCMaker::IfcPort
#
#
#
#
###############################################################
require_relative( 'spec_helper' )




describe SOCMaker::IfcPort, "verification" do

  it "should return an object of type SOCMaker::IfcPort when creating it with new" do
    o = SOCMaker::IfcPort.new( "abc", 1 )
    o.class.should be SOCMaker::IfcPort
  end

  it "should raise an error if the definition reference is nil" do
    expect{ SOCMaker::IfcPort.new( nil, 1 ) }.
    to raise_error( SOCMaker::ERR::StructureError )
  end

  it "should raise an error if the definition reference is an empty string" do
    expect{ SOCMaker::IfcPort.new( "", 1 ) }.
    to raise_error( SOCMaker::ERR::ValueError )
  end

  it "should raise an error if the length is neither a fixnum nor a string" do
    expect{ SOCMaker::IfcPort.new( "abc", {} ) }.
    to raise_error( SOCMaker::ERR::ValueError )
  end
end

describe SOCMaker::IfcPort, "object handling, en-decoding:" do

  it "should return false for two non-equal objects" do
    o1 = SOCMaker::IfcPort.new( "abc", 1 )
    o2 = Marshal::load(Marshal.dump(o1))
    o2.len = 4
    ( o2 == o1 ).should be == false
  end

  it "should be possible to encode and decode a interface definition" do
    o1 = SOCMaker::IfcPort.new( "abc", 1 )
    yaml_str = o1.to_yaml
    o2 = YAML::load( yaml_str )
    o1.should be == o2
  end

end


# vim: noai:ts=2:sw=2


