###############################################################
#   
#  File:      sparameter_spec.rb
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
#     Test specification for SOCMaker::SParameter and
#                            SOCMaker::SParameterEntry
#
#
#
#
###############################################################
require_relative( 'spec_helper' )




describe SOCMaker::Parameter, "verification" do
  
  F_YAML_STATIC_NO_TOKEN = '''SOCM_CORE
name: core_A
version: rel1
toplevel: top_A
hdlfiles:
   :core_a.vhd: SOCM_HDL_FILE
      :path: ./core_a.vhd
static_parameters: 
  :a_file.vhd.src: SOCM_SPARAM
    path: ./core_a.vhd
    file_dst: a_file.vhd
    parameters:
      :p1:  SOCM_SENTRY
        min: 4
        type: integer
'''

  F_YAML_STATIC_NO_PATH = '''SOCM_CORE
name: core_A
version: rel1
toplevel: top_A
hdlfiles:
   :core_a.vhd: SOCM_HDL_FILE
      :path: ./core_a.vhd
static_parameters: 
  :a_file.vhd.src: SOCM_SPARAM
    file_dst: a_file.vhd
    parameters:
      :p1:  SOCM_SENTRY
        min: 4
        token: ABC
        type: integer
'''

  F_YAML_STATIC_NO_TYPE = '''SOCM_CORE
name: core_A
version: rel1
toplevel: top_A
hdlfiles:
   :core_a.vhd: SOCM_HDL_FILE
      :path: ./core_a.vhd
static_parameters: 
  :a_file.vhd.src: SOCM_SPARAM
    file_dst: a_file.vhd
    path: ./core_a.vhd
    parameters:
      :p1:  SOCM_SENTRY
        min: 4
        token: ABC
'''

  # missing file_dst in static parameter
  F_YAML_STATIC_NO_DST1 = '''SOCM_CORE
name: core_A
version: rel1
toplevel: top_A
hdlfiles:
   :core_a.vhd: SOCM_HDL_FILE
      :path: ./core_a.vhd
static_parameters:
  :a_file.vhd: SOCM_SPARAM
    parameters:
      :p1: SOCM_SENTRY
        type: integer
        token: T1
'''
  # no parameter entry
  F_YAML_STATIC_NO_SENTRY = '''SOCM_CORE
name: core_A
version: rel1
toplevel: top_A
hdlfiles:
   :core_a.vhd: SOCM_HDL_FILE
      path: ./core_a.vhd
static_parameters:
  :a_file.vhd.src: SOCM_SPARAM
    file_dst: a_file_xyz.vhd
    path: ./core_a.vhd
    parameters:
      :p1: SOCM_SENTRY
'''




  it "should return an object of type SOCMaker::SParameter when creating it with new" do
    o = SOCMaker::SParameter.new( "./path/to/file.src", "./path/to/file.dst" )
    o.class.should be SOCMaker::SParameter
    o.parameters.class.should be Hash
  end

  it "should raise an error if the destination path has zero length" do
    expect{ SOCMaker::SParameter.new( "./path/to/file.src", "" ) }.
      to raise_error( SOCMaker::ERR::ValueError )
  end

  it "should raise an error if the destination path is nil" do
    expect{ SOCMaker::SParameter.new( "./path/to/file.src", nil ) }.
      to raise_error( SOCMaker::ERR::StructureError )
  end

  it "should raise an error if the destination path is not a string" do
    expect{ SOCMaker::SParameter.new( "./path/to/file.src", 4 ) }.
      to raise_error( SOCMaker::ERR::ValueError )
  end


  it "should raise an error if the src path has zero length" do
    expect{ SOCMaker::SParameter.new( "", "./path/to/file.dst" ) }.
      to raise_error( SOCMaker::ERR::ValueError )
  end

  it "should raise an error if the src path is nil" do
    expect{ SOCMaker::SParameter.new( nil, "./path/to/file.dst" ) }.
      to raise_error( SOCMaker::ERR::StructureError )
  end

  it "should raise an error if the src path is not a string" do
    expect{ SOCMaker::SParameter.new( 4,"./path/to/file.dst" ) }.
      to raise_error( SOCMaker::ERR::ValueError )
  end


  it "should raise an error if the path is not defined" do
    expect{ SOCMaker::from_s( F_YAML_STATIC_NO_PATH  ) }.
      to raise_error( SOCMaker::ERR::StructureError )
  end

  it "should raise an error if the token is not defined" do
    expect{ SOCMaker::from_s( F_YAML_STATIC_NO_TOKEN  ) }.
      to raise_error( SOCMaker::ERR::StructureError )
  end

  it "should raise an error if the type is not defined" do
    expect{ SOCMaker::from_s( F_YAML_STATIC_NO_TYPE  ) }.
      to raise_error( SOCMaker::ERR::StructureError )
  end


  it "should raise an error if the destination is not defined" do
    expect{ SOCMaker::from_s( F_YAML_STATIC_NO_DST1  ) }.
      to raise_error( SOCMaker::ERR::StructureError )
  end

  it "should return an object of type SOCMaker::SParameterentry when creating it with new" do
    o = SOCMaker::SParameterEntry.new( "type", "mytoken" )
    o.class.should be SOCMaker::SParameterEntry
  end

  it "should raise an error if token is nil" do
    expect{ SOCMaker::SParameterEntry.new( "type", nil ) }.
      to raise_error( SOCMaker::ERR::StructureError )
  end

  it "should raise an error if token is an empty string" do
    expect{ SOCMaker::SParameterEntry.new( "type", "" ) }.
      to raise_error( SOCMaker::ERR::ValueError )
  end

  it "should raise an error if token is not a string" do
    expect{ SOCMaker::SParameterEntry.new( "type", 4 ) }.
      to raise_error( SOCMaker::ERR::ValueError )
  end

  it "should raise an error if an entry is not provided" do
    expect{ SOCMaker::from_s( F_YAML_STATIC_NO_SENTRY  ) }.
      to raise_error( SOCMaker::ERR::StructureError )
  end


end

describe SOCMaker::SParameter, "object handling, en-decoding:" do


  it "should be possible to encode and decode a static parameter" do
    o1 = SOCMaker::SParameter.new( 
          "./path/to/file.src", 
          "./path/to/file.dst",
          'parameters' => { p1: SOCMaker::SParameterEntry.new( "file.src", "file.dst" ) } )

    yaml_str = o1.to_yaml
    o2 = YAML::load( yaml_str )
    o1.should be == o2
  end

  it "should return false for two non-equal objects" do
    o1 = SOCMaker::SParameterEntry.new( 
        "./path/to/file.src", 
        "./path/to/file.dst" )
    o2 = Marshal::load(Marshal.dump(o1))
    o2.min = 4
    ( o2 == o1 ).should be == false
  end

  it "should be possible to encode and decode a static parameter entry" do
    o1 = SOCMaker::SParameterEntry.new( 
        "./path/to/file.src", 
        "./path/to/file.dst",
          'default'       => 0,
          'min'           => 0,
          'max'           => 3,
          'visible'       => true,
          'editable'      => false,
          'description'   => "test description" )
    yaml_str = o1.to_yaml
    o2 = YAML::load( yaml_str )
    o1.should be == o2
  end


end


# vim: noai:ts=2:sw=2

