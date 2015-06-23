###############################################################
#   
#  File:      parameter_spec.rb
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
#     Test specification for SOCMaker::Parameter
#
#
#
#
###############################################################
require_relative( 'spec_helper' )




describe SOCMaker::Parameter, "verification" do

  # type is missing for param1
  F_YAML_INSTP_TYPE = '''SOCM_CORE
name: core_A
version: rel1
toplevel: top_A
hdlfiles:
   :core_a.vhd: SOCM_HDL_FILE
      :path: ./core_a.vhd
inst_parameters:
  :param1: SOCM_PARAM
    :min: 0
'''


  it "should return an object of type SOCMaker::Parameter when creating it with new" do
    o = SOCMaker::Parameter.new( "integer" )
    o.class.should be SOCMaker::Parameter
  end


  it "should raise an error if the type is not a string" do
    expect{ SOCMaker::Parameter.new( 3 ) }.
    to raise_error( SOCMaker::ERR::ValueError )
  end

  it "should raise an error if the type is a string with zero length" do
    expect{ SOCMaker::Parameter.new( "" ) }.
    to raise_error( SOCMaker::ERR::ValueError )
  end

  it "should raise an error if the type is nil" do
    expect{ SOCMaker::Parameter.new( "" ) }.
    to raise_error( SOCMaker::ERR::ValueError )
  end

  it 'should raise an error if the type value of an instance param. is empty' do
    expect{ SOCMaker::from_s( F_YAML_INSTP_TYPE ) }.
    to raise_error( SOCMaker::ERR::StructureError )
  end
  
end


# vim: noai:ts=2:sw=2



