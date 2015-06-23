###############################################################
#   
#  File:      soc_def_spec.rb
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
#     Test spec. for SOCMaker::SOCDef
#
#
#
###############################################################
require_relative( 'spec_helper' )


describe SOCMaker::SOCDef, "structure verification for loading a core-definition" do

  # not implemented at the moment

  # test for invalid path
  # it "should raise an error if a non-existing path is given" do
  #   expect { SOCMaker::from_f( 'blabla.txt' ) }.
  #       to raise_error( IOError )
  # end




  #
  # A yaml example, which contains 
  #   - a full definition
  #   - an interface with one port
  #   - one hdl file
  #   - one instance parameter
  #   - one static parameter
  # 
  FULL_SOC_YAML = '''SOCM_SOC
name: my_soc
description: A test SOC
id: my_soc,rel2
date: 1.1.2014
license: LGPL
licensefile: 
toplevel: soc_top
author: Christian Haettich
authormail: feddischson@opencores.org
repocmd: svn co http://some-address/
'''


SOC_YAML_WITH_CORE = '''SOCM_SOC
name: my_soc
description: A test SOC
id: my_soc,rel2
date: 1.1.2014
license: LGPL
licensefile: 
author: Christian Haettich
authormail: feddischson@opencores.org
repocmd: svn co http://some-address/
toplevel: soc_top
cores:
  :inst1: SOCM_INST
    type: mycorerel1
'''






  # process all valid YAMLs
  #  each should result in a CoreDef
  it 'should return a class of type SOCDef when loading a full soc-def' do
    SOCMaker::from_s( FULL_SOC_YAML ).class.should == SOCMaker::SOCDef
  end

  it "should rise an error if soc is loaded with a core, which is not in our library" do
    SOCMaker::lib.clear
    expect { SOCMaker::from_s( SOC_YAML_WITH_CORE ).consistency_check }.
      to raise_error( SOCMaker::ERR::LibError )
  end


  it "should return an SOC-object if soc is loaded with a core, which is in our library" do
    file = { "file.vhd".to_sym => SOCMaker::HDLFile.new( "./file.vhd" ) }
    core = SOCMaker::CoreDef.new( "mycore", "rel1", file, "top" )
    SOCMaker::lib.add_core( core )
    soc = SOCMaker::from_s( SOC_YAML_WITH_CORE ) 
    soc.class.should be SOCMaker::SOCDef
  end

end


describe SOCMaker::SOCDef, "processing verification" do
    
    before( :each )do
      file = { "file.vhd".to_sym => SOCMaker::HDLFile.new( "./file.vhd" ) }
      core = SOCMaker::CoreDef.new( "My Core", "mycore,rel1", file, "top" )
      SOCMaker::lib.add_core( core )
      @soc = SOCMaker::SOCDef.new( "Test SOC", "test-soc,v1", "my_soc_top" )
    end

    describe "adding/removing cores, connections etc." do


      it "inst_in_use should return true, if there is already an core instance with that name" do
        @soc.cores[ :core_inst ] = SOCMaker::CoreInst.new( "mycorerel1" )
        @soc.inst_in_use?( "core_inst" ).should be == true
      end

      it "inst_in_use should return false, if there is no core instance with that name" do
        @soc.inst_in_use?( "core_inst" ).should be == false
      end

      it "inst_in_use should return true, if there is already an connection instance with that name" do
        @soc.cons[ :a_con ] = { rule: "or", mapping: [ { :core_a => :ifc_a }, { :core_b => :ifc_b } ] }
        @soc.inst_in_use?( "a_con" ).should be == true
      end



      it "removing a core instance should be possible" do
        @soc.cores[ :core_inst ] = SOCMaker::CoreInst.new( "mycorerel1" )
        @soc.inst_in_use?( "core_inst" ).should be == true
        @soc.rm( "core_inst" ).should be == true
        @soc.inst_in_use?( "core_inst" ).should be == false
      end


      it "removing a connection instance should be possible" do
        @soc.cons[ :a_con ] = { rule: "or", mapping: [ { :core_a => :ifc_a }, { :core_b => :ifc_b } ] }
        @soc.inst_in_use?( "a_con" ).should be == true
        @soc.rm( "a_con" ).should be == true
        @soc.inst_in_use?( "a_con" ).should be == false
      end

      it "should return false, when removing a non-existance instance" do
        @soc.rm( "a_con" ).should be == false
      end

      it "should return nil if a instance is added twice" do
        @soc.cores[ :core_inst ] = SOCMaker::CoreInst.new( "mycorerel1" )
        @soc.add_core(  "mycore,rel1", "core_inst" ).should be == false
      end

      it "should return non-nil value, if a instance is added once" do
        @soc.add_core(  "mycore,rel1", "core_inst" ).should_not be == false
      end

      # in one of the first version, we returned nil, but now this is 
      # used to extend a interface
      it "should not return nil if a connection is added twice" do
        @soc.cons[ :a_con ] = { rule: "or", mapping: [ { :core_a => :ifc_a }, { :core_b => :ifc_b } ] }
        @soc.add_connection(  "core_a", "ifc_a", "core_c", "ifc_b", "a_con" ).should_not be == nil
      end

      it "should raise a library error when adding an unknown core" do
        expect{ @soc.add_core( "some_unknown_core,v_xyz", "test" ) }.
          to raise_error( SOCMaker::ERR::LibError )
      end 

      it "should create a dir and return the absolute path for a core inside the build/hdl dir" do
        SOCMaker::conf[ :build_dir ] = "./spec/tmp_build"
        SOCMaker::conf[ :hdl_dir   ] = "hdl"
        path = File.expand_path "./spec/tmp_build/hdl/a_core"
        FileUtils.rmdir( path ) if File.directory?( path )
        res = SOCMaker::Component::get_and_ensure_dst_dir!( "a_core" )
        File.directory?( path ).should be == true
        res.should be == path
      end

      it "should return false, when an interface is not used" do
        # setup interface ifc_b and ifc_c, test for ifc_a
        a_con = { rule: "or", mapping: [ { :core_a => :ifc_b }, { :core_b => :ifc_c } ] }
        @soc.cons[ :my_con ] = a_con
        @soc.ifc_in_use?( "core_a", "ifc_a" ).should be == false
      end

      it "should return true, if an interface is used" do
        a_con = { rule: "or", mapping: [ { :core_a => :ifc_a }, { :core_b => :ifc_b } ] }
        @soc.cons[ :my_con ] = a_con
        @soc.ifc_in_use?( "core_a", "ifc_a" ).should be == true
      end


      it "should raise an SOCMaker::ERR::ProcessingError add_connection tries to add a interface, wich is already used" do
        a_con = { rule: "or", mapping: [ { :core_a => :ifc_a }, { :core_b => :ifc_b } ] }
        @soc.cons[ :my_con ] = a_con
        expect{ @soc.add_connection(  "core_a", "ifc_a", "core_b", "ifc_c", "a_new_con" ) }.
          to raise_error( SOCMaker::ERR::ProcessingError )
        expect{ @soc.add_connection(  "core_a", "ifc_a", "core_c", "ifc_b", "a_new_con" ) }.
          to raise_error( SOCMaker::ERR::ProcessingError )
      end

      it "should raise an SOCMaker::ERR::ProcessingError if a connection is added from a non-existing core instance" do
        expect{ @soc.add_connection(  "core_a", "ifc_a", "core_c", "ifc_b", "a_new_con" ) }.
          to raise_error( SOCMaker::ERR::ProcessingError )
      end

      it "should raise an ProcessingError if a interface doesn't exist" do
        @soc.cores[ :core_a ] = SOCMaker::CoreInst.new( "mycore,rel1" )
        @soc.cores[ :core_b ] = SOCMaker::CoreInst.new( "mycore,rel1" )
        expect{ @soc.add_connection(  "core_a", "ifc_a", "core_b", "ifc_c", "a_new_con" ) }.
          to raise_error( SOCMaker::ERR::ProcessingError )
      end


      it "should raise an ProcessingError if the ifc.-version is wrong" do

        ifc_spc1 = SOCMaker::IfcSpc.new( "myifc", "myifc,v1", 'ports' => { port_a: {dir:1}, port_b: {dir:0} } )
        ifc_spc2 = SOCMaker::IfcSpc.new( "myifc", "myifc,v2", 'ports' => { port_a: {dir:1}, port_b: {dir:0} } )
        ifc_def_1 = SOCMaker::IfcDef.new( "myifc", "myifc,v1", 0, { a: SOCMaker::IfcPort.new( "port_a", 1 ) } )
        ifc_def_0 = SOCMaker::IfcDef.new( "myifc", "myifc,v2", 1, { b: SOCMaker::IfcPort.new( "port_b", 1 ) } )
        file = { "file.vhd".to_sym => SOCMaker::HDLFile.new( "./file.vhd" ) }
        core_a = SOCMaker::CoreDef.new( "core_a", "core_a,v1", file, "top" )
        core_b = SOCMaker::CoreDef.new( "core_b", "core_a,v1", file, "top" )
        core_a.interfaces[ :ifc_a ] = ifc_def_0
        core_a.interfaces[ :ifc_b ] = ifc_def_1
        core_b.interfaces[ :ifc_a ] = ifc_def_0
        core_b.interfaces[ :ifc_b ] = ifc_def_1

        SOCMaker::lib.add_ifc( ifc_spc1 )
        SOCMaker::lib.add_ifc( ifc_spc2 )
        SOCMaker::lib.add_core( core_a ) 
        SOCMaker::lib.add_core( core_b ) 
        @soc.cores[ :core_a ] = SOCMaker::CoreInst.new( "core_a,v1" )
        @soc.cores[ :core_b ] = SOCMaker::CoreInst.new( "core_b,v1" )
        expect { @soc.add_connection(  "inst_a", "ifc_a", "inst_b", "ifc_b", "a_new_con" ) }.
          to raise_error( SOCMaker::ERR::ProcessingError )
      end




      it "should add a connection entry" do

        ifc_spc = SOCMaker::IfcSpc.new( "myifc", "myifc,v1", 'ports' => { port_a: {dir:1}, port_b: {dir:0} } )

        ifc_def_1 = SOCMaker::IfcDef.new( "myifc", "myifc,v1", 0, { a: SOCMaker::IfcPort.new( "port_a", 1 ), 
                                                                    b: SOCMaker::IfcPort.new( "port_b", 1 ) } )

        ifc_def_0 = SOCMaker::IfcDef.new( "myifc", "myifc,v1", 1, { a: SOCMaker::IfcPort.new( "port_a", 1 ), 
                                                                    b: SOCMaker::IfcPort.new( "port_b", 1 ) } )


        file = { "file.vhd".to_sym => SOCMaker::HDLFile.new( "./file.vhd" ) }
        core_a = SOCMaker::CoreDef.new( "core_a", "core_a,v1", file, "top" )
        core_b = SOCMaker::CoreDef.new( "core_b", "core_b,v1", file, "top" )
        core_a.interfaces[ :ifc_a ] = ifc_def_0
        core_a.interfaces[ :ifc_b ] = ifc_def_1
        core_b.interfaces[ :ifc_a ] = ifc_def_0
        core_b.interfaces[ :ifc_b ] = ifc_def_1

        SOCMaker::lib.add_ifc( ifc_spc )
        SOCMaker::lib.add_core( core_a ) 
        SOCMaker::lib.add_core( core_b ) 



        @soc.cores[ :inst_a ] = SOCMaker::CoreInst.new( "core_a,v1" )
        @soc.cores[ :inst_b ] = SOCMaker::CoreInst.new( "core_b,v1" )
        @soc.consistency_check
        @soc.add_connection(  "inst_a", "ifc_a", "inst_b", "ifc_b", "a_new_con" )
        @soc.cons[ :a_new_con ].should be == { rule:'or', mapping: [ {inst_a: :ifc_a},{inst_b: :ifc_b} ] }
      end




      it "should add a connection entry, which connects the toplevel's port" do

        ifc_spc = SOCMaker::IfcSpc.new( "myifc", "v1", 'ports' => { port_a: {dir:1}, port_b: {dir:0} } )

        ifc_def_1 = SOCMaker::IfcDef.new( "myifc", "v1", 0, { a: SOCMaker::IfcPort.new( "port_a", 1 ), 
                                                              b: SOCMaker::IfcPort.new( "port_b", 1 ) } )

        ifc_def_0 = SOCMaker::IfcDef.new( "myifc", "v1", 1, { a: SOCMaker::IfcPort.new( "port_a", 1 ), 
                                                              b: SOCMaker::IfcPort.new( "port_b", 1 ) } )

        file = { "file.vhd".to_sym => SOCMaker::HDLFile.new( "./file.vhd" ) }
        core_a = SOCMaker::CoreDef.new( "core_a", "core_a,v1", file, "top" )
        core_a.interfaces[ :ifc_a ] = ifc_def_0
        core_a.interfaces[ :ifc_b ] = ifc_def_1
 
        SOCMaker::lib.add_ifc( ifc_spc )
        SOCMaker::lib.add_core( core_a ) 
 

       SOCMaker::lib.add_core( @soc )
       @soc.interfaces[ :t1 ] = ifc_def_1
       @soc.cores[ :inst_a ] = SOCMaker::CoreInst.new( "core_a,v1" )
       @soc.consistency_check
       @soc.add_connection(  "inst_a", "ifc_a", @soc.id, "t1", "a_new_con" )
       @soc.cons[ :a_new_con ].should be == { rule:'or', mapping: [ {inst_a: :ifc_a},{ @soc.id.to_sym => :t1} ] }
     end



      it "should raise an error, if a parameter of unkonwn core is set" do
        expect{ @soc.set_param( "a_unknown_core", "p1", 1234 ) }.
          to raise_error( SOCMaker::ERR::ProcessingError )
      end

      it "should raise an error, if a parameter of unkonwn core is requested" do
        expect{ @soc.get_param( "a_unknown_core", "p1" ) }.
          to raise_error( SOCMaker::ERR::ProcessingError )
      end

      it "should raise an error, if a unknown parameter is set and requested" do
        file = { "file.vhd".to_sym => SOCMaker::HDLFile.new( "./file.vhd" ) }
        core_a = SOCMaker::CoreDef.new( "core_a", "v1", file, "top" )
        parameter = SOCMaker::Parameter.new( "integer" )
        core_a.inst_parameters[ :p1 ] = parameter
        SOCMaker::lib.add_core( core_a ) 
        @soc.cores[ :inst_a ] = SOCMaker::CoreInst.new( "core_a,v1" )
        expect{ @soc.set_param( "inst_a", "px", 1234 ) }.
          to raise_error( SOCMaker::ERR::ProcessingError )
        expect{ @soc.get_param( "inst_a", "px" ) }.
          to raise_error( SOCMaker::ERR::ProcessingError )
      end
  
      it "should set a parameter and provide a parameter" do
        file = { "file.vhd".to_sym => SOCMaker::HDLFile.new( "./file.vhd" ) }
        core_a = SOCMaker::CoreDef.new( "core_a", "core_a,v1", file, "top" )
        parameter = SOCMaker::Parameter.new( "integer" )
        core_a.inst_parameters[ :p1 ] = parameter
        SOCMaker::lib.add_core( core_a ) 
        @soc.cores[ :inst_a ] = SOCMaker::CoreInst.new( "core_a,v1" )
        @soc.set_param( "inst_a", "p1", 1234 )
        @soc.cores[ :inst_a ].params[ :p1 ].should be == 1234
        @soc.get_param( "inst_a", "p1" ).should be == 1234
      end



      it "should raise an error, if a static-parameter of unkonwn core is set" do
        expect{ @soc.set_sparam( "a_unknown_core", "p1", 1234 ) }.
          to raise_error( SOCMaker::ERR::ProcessingError )
      end

      it "should raise an error, if a statoc-parameter of unkonwn core is requested" do
        expect{ @soc.get_sparam( "a_unknown_core", "p1" ) }.
          to raise_error( SOCMaker::ERR::ProcessingError )
      end

      it "should an error, a static parameter doesn't exist" do

        file = { "file.vhd".to_sym => SOCMaker::HDLFile.new( "./file.vhd" ) }
        core_a = SOCMaker::CoreDef.new( "core_a", "core_a,v1", file, "top" )
        SOCMaker::lib.add_core( core_a ) 
        @soc.cores[ :inst_a ] = SOCMaker::CoreInst.new( "core_a,v1" )

        expect{ @soc.set_sparam( "core_a,v1", "p1", 1234 ) }.
          to raise_error( SOCMaker::ERR::ProcessingError )
        expect{ @soc.get_sparam( "core_a,v1", "p1" ) }.
          to raise_error( SOCMaker::ERR::ProcessingError )
      end

      it "should set a static-parameter and provide this static parameter" do

        file = { "file.vhd".to_sym => SOCMaker::HDLFile.new( "./file.vhd" ) }
        core_a = SOCMaker::CoreDef.new( "core_a", "core_a,v1", file, "top" )
        pentry = SOCMaker::SParameterEntry.new( "integer", "TOK" )
        parameter = SOCMaker::SParameter.new( "file/path.vhd.src", 
                                              "file/path.vhd", 
                                              'parameters' => { p1: pentry } )
        core_a.static_parameters[ :p1 ] = parameter
        SOCMaker::lib.add_core( core_a ) 
        @soc.cores[ :inst_a ] = SOCMaker::CoreInst.new( "core_a,v1" )

        @soc.set_sparam( "core_a,v1", "p1", 1234 )
        @soc.static[ "core_a,v1".to_sym ][ :p1 ].should be == 1234
        @soc.get_sparam( "core_a,v1", "p1" ).should be == 1234
      end







    end

  describe SOCMaker::SOCDef, "object handling, en-decoding:" do

    it "should be possible to encode and decode a core instance" do
      yaml_str = @soc.to_yaml
      o2 = YAML::load( yaml_str )
      @soc.should be == o2
    end

    it "should return false for two non-equal objects" do
      o2 = Marshal::load(Marshal.dump(@soc))
      o2.name << "X"
      ( o2 == @soc ).should be == false
    end

  end


end




# vim: noai:ts=2:sw=2
