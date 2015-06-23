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
#     Test specification for SOCMaker::IfcSpc
#
#
#
#
###############################################################
require_relative( 'spec_helper' )




describe SOCMaker::IfcSpc, "verification" do

  IFC_YAML_VALID = """
SOCM_IFC_SPC
name: core_ifc
id: 'core_ifc,1'
ports:
  :sig_a: 
    :dir: 1
  :sig_b: 
    :dir: 1
  :sig_c: 
    :dir: 0
"""

  IFC_YAML_INVALID = """
SOCM_IFC_SPC
:name: core_ifc
:id: 'core_ifc,1'
:ports:
  :sig_a: '12'
  :sig_b: 1
  :sig_c: 0
"""

  IFC_YAML_INVALID2 = """
SOCM_IFC_SPC
:name: core_ifc
:id: 'core_ifc,1'
:ports:
  :sig_a:
  :sig_b: 1
  :sig_c: 0
"""

  it "should return a SOCMaker::IfcSpc object when creating with new" do
    s = SOCMaker::IfcSpc.new( "myifc", "v1" )
    s.class.should be SOCMaker::IfcSpc
  end
  
  it "should raise an error if the name is not a string" do
     expect{  SOCMaker::IfcSpc.new( 1234, "v1", { :p1 => "a-string" } ) }.
        to raise_error( SOCMaker::ERR::ValueError )
  end
  
  it "should raise an error if the name is an empty string" do
     expect{  SOCMaker::IfcSpc.new( "", "v1", { :p1 => "a-string" } ) }.
        to raise_error( SOCMaker::ERR::ValueError )
  end
  
  it "should raise an error if the id is not a string" do
     expect{  SOCMaker::IfcSpc.new( "myifc", 234, { :p1 => "a-string" } ) }.
        to raise_error( SOCMaker::ERR::ValueError )
  end
  
  it "should raise an error if the id is an a empty string" do
     expect{  SOCMaker::IfcSpc.new( "myifc", "", { :p1 => "a-string" } ) }.
        to raise_error( SOCMaker::ERR::ValueError )
  end
  
  
  it "should raise an error if a port direction is neither 0 nor 1" do
     expect{  SOCMaker::IfcSpc.new( "myifc", "myifc,v1", 'ports' => { :p1 => "a-string" } ) }.
        to raise_error( SOCMaker::ERR::ValueError )
  end
  
  it "should load from yaml" do
     c = SOCMaker::from_s( IFC_YAML_VALID )
     c.class.should be == SOCMaker::IfcSpc
  end
  
  
  it "should raise an error if a port direction is neither 0 nor 1" do
     expect{  SOCMaker::from_s( IFC_YAML_INVALID ) }.
        to raise_error( SOCMaker::ERR::ValueError )
  end

  it "should raise an error if a port direction is nil" do
     expect{  SOCMaker::from_s( IFC_YAML_INVALID2 ) }.
        to raise_error( SOCMaker::ERR::ValueError )
  end
 


end


# vim: noai:ts=2:sw=2
