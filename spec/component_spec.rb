###############################################################
#   
#  File:      component.rb
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
#     Test specification for SOCMaker::Component
#
#
#
#
###############################################################
require_relative( 'spec_helper' )

describe SOCMaker::Component, "initialization" do


  it "should return a Component object, if the object is created with new" do
    c = SOCMaker::Component.new( "acore", "v1", "top" )
    c.class.should be == SOCMaker::Component
  end 


  # test the name
  it "should raise an error, if the name is nil" do
    expect{ SOCMaker::Component.new( nil, "v1", "top" ) }.
      to raise_error( SOCMaker::ERR::StructureError )
  end

  it "should raise an error, if the name has zero-length" do
    expect{ SOCMaker::Component.new( "", "v1", "top" ) }.
      to raise_error( SOCMaker::ERR::StructureError )
  end

  it "should raise an error, if the name is not of type string" do
    expect{ SOCMaker::Component.new( 3, "v1", "top" ) }.
      to raise_error( SOCMaker::ERR::ValueError )
  end

  # test the id
  it "should raise an error, if the id is nil" do
    expect{ SOCMaker::Component.new( "acore", nil, "top" ) }.
      to raise_error( SOCMaker::ERR::StructureError )
  end

  it "should raise an error, if the id has zero-length" do
    expect{ SOCMaker::Component.new( "acore", "", "top" ) }.
      to raise_error( SOCMaker::ERR::StructureError )
  end
 
  it "should raise an error, if the id is not of type string " do
    expect{ SOCMaker::Component.new( "acore", [ 1, 2, 3 ], "top" ) }.
      to raise_error( SOCMaker::ERR::ValueError )
  end


  %w[ description date license licensefile 
      author authormail vccmd ].each do |m|
    it "should auto-set #{m} to an empty string" do
      c = SOCMaker::Component.new( "acore", "v1", "top" )
      c.instance_variable_get( '@'+m ).class.should be == String
      c.instance_variable_get( '@'+m ).should be       == ""
    end
  end
  %w[ interfaces functions        
      inst_parameters 
      static_parameters ].each do |m|
    it "should auto-set #{m} to an empty Hash" do
      c = SOCMaker::Component.new( "acore", "v1", "top" )
      c.instance_variable_get( '@'+m ).class.should be == Hash
      c.instance_variable_get( '@'+m ).should be       == {}
    end
  end


  %w[ description date license licensefile 
      author authormail vccmd ].each do |m|
    it "should raise an error if #{m} is not a string" do
    # pass an numerical value
    expect{ SOCMaker::Component.new( "acore", "v1", "top", { m => 4 } ) }.
      to raise_error( SOCMaker::ERR::ValueError )
    end
  end

  %w[ interfaces functions        
      inst_parameters 
      static_parameters ].each do |m|
    it "should raise an error if #{m} is not a hash" do
      # pass an numerical value
      expect{ SOCMaker::Component.new( "acore", "v1", "top", { m => 4 } ) }.
        to raise_error( SOCMaker::ERR::ValueError )
    end
  end



  




  it 'should iterate over all generics (inst. parameters)' do


    p1 = SOCMaker::Parameter.new( "integer" )
    p2 = SOCMaker::Parameter.new( "string" )
    p3 = SOCMaker::Parameter.new( "integer" )
    p4 = SOCMaker::Parameter.new( "string" )

    c = SOCMaker::Component.new( "acore", "v1", "top",
      { 'inst_parameters' => { p1: p1, p2: p2, p3: p3, p4: p4 } } )

    a_name    = [];
    a_type    = [];
    a_default = [];
    a_is_last = [];
    c.generics do |name,type,default,is_last| 
      a_name    << name
      a_type    << type
      a_default << default
      a_is_last << is_last
    end
    a_name.should be == %w[ p1 p2 p3 p4 ]
    a_type.should be == %w[ integer string integer string ]
    a_default.should be == [ 0, 0, 0, 0 ]
    a_is_last.should be == [ false, false, false, true ]
  end

   


  it 'should iterate over all ports' do

    SOCMaker::lib.clear
    ifc_s1 = SOCMaker::IfcSpc.new( "Interface 1", "i1,v1", 'ports' => { p1:{dir:1}, p2:{dir:1}, p3:{dir:0} } )
    ifc_s2 = SOCMaker::IfcSpc.new( "Interface 2", "i2,v1", 'ports' => { x1:{dir:1}, x2:{dir:0} } )
    SOCMaker::lib.add_ifc( ifc_s1 )
    SOCMaker::lib.add_ifc( ifc_s2 )

    p1 = SOCMaker::IfcPort.new( "p1", 1 )
    p2 = SOCMaker::IfcPort.new( "p2", 2 )
    p3 = SOCMaker::IfcPort.new( "p3", 3 )
    x1 = SOCMaker::IfcPort.new( "x1", 1 )
    x2 = SOCMaker::IfcPort.new( "x2", 2 )

    ifc_d1 = SOCMaker::IfcDef.new( "i1", "i1,v1", 0, { m_p1: p1, m_p2: p2, m_p3: p3 } )
    ifc_d2 = SOCMaker::IfcDef.new( "i2", "i2,v1", 0, { m_x1: x1, m_x2: x2           } )

   
    c = SOCMaker::Component.new( "A core", "acore,v1", "top",
      { 'interfaces' =>  { i1: ifc_d1, i2: ifc_d2 } } )

    r_name    = []
    r_dir     = []
    r_len     = []
    r_is_last = []

    c.ports do |arg_name,arg_dir,arg_len,arg_default,arg_is_last|
      r_name    << arg_name
      r_dir     << arg_dir
      r_len     << arg_len
      r_is_last << arg_is_last
    end
    r_name.sort.should be == %w[ m_p1 m_p2 m_p3 m_x1 m_x2 ].sort
    r_dir.sort.should be  ==   [ 1, 1, 0, 1, 0 ].sort
    r_len.sort.should be  ==   [ 1, 2, 3, 1, 2 ].sort
    r_is_last.should be   == [ false, false, false, false, true ]


    #r_def     = []
    r_name    = []
    r_dir     = []

    c.ports( "i1" ) do |arg_name,arg_dir, arg_default, arg_is_last|
      #r_def     << arg_def
      r_name    << arg_name
      r_dir     << arg_dir
    end
    #r_def.should be == %w[ m_p1 m_p2 m_p3 ]
    r_name.should be == %w[ m_p1 m_p2 m_p3 ]
    r_dir.should be  ==   [ 1, 1, 0, ]
    
  end

end


describe SOCMaker::Component, "consistency_check" do


  it "should throw an error if an incomplete interface is used" do

    # three (auto) mandatory ports
    ifc_s1 = SOCMaker::IfcSpc.new( "i1", "v1", 'ports' => { p1: { dir: 1}, p2: {dir: 1}, p3: {dir:0} } )
    SOCMaker::lib.add_ifc( ifc_s1 )

    # interface implementaiton with only two of the three ports
    p1 = SOCMaker::IfcPort.new( "p1", 1 )
    p2 = SOCMaker::IfcPort.new( "p2", 2 )
    ifc_d1 = SOCMaker::IfcDef.new( "i1", "v1", 0, { m_p1: p1, m_p2: p2 } )
   
    c = SOCMaker::Component.new( "acore", "v1", "top",
      { 'interfaces' =>  { i1: ifc_d1 } } )


   expect{ c.consistency_check }.
     to raise_error( SOCMaker::ERR::ProcessingError )
    
  end

end

# vim: noai:ts=2:sw=2
