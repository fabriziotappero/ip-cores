###############################################################
#   
#  File:      core_inst_spec.rb
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


describe SOCMaker::CoreInst, "structure and auto-completion functionallity" do


  it "should raise an error, if parameters are not given as hash" do
     file = { "file.vhd".to_sym => SOCMaker::HDLFile.new( "./file.vhd" ) }
     core = SOCMaker::CoreDef.new( "mycore", "rel1", file, "top" )
     SOCMaker::lib.add_core( core )
     expect{  SOCMaker::CoreInst.new( "mycorerel1", "not a hash"  ) }.
     to raise_error( SOCMaker::ERR::StructureError )
     SOCMaker::lib.rm_core( core )
  end


  it "should raise an error, if parameters are given, which doesn't exist in the definition" do
     file = { "file.vhd".to_sym => SOCMaker::HDLFile.new( "./file.vhd" ) }
     core = SOCMaker::CoreDef.new( "My Core", "mycore,rel1", file, "top" )
     SOCMaker::lib.add_core( core )
     expect{
         inst = SOCMaker::CoreInst.new( "mycore,rel1", { "aparameter".to_sym => 4 } )
         inst.consistency_check }.
     to raise_error( SOCMaker::ERR::ValueError )
     SOCMaker::lib.rm_core( core )

  end

  it "should auto-complete generics with default values" do
     
     # create core with one file and one instance parameter
     file = { "file.vhd".to_sym => SOCMaker::HDLFile.new( "./file.vhd" ) }
     parameters = { "param1".to_sym => SOCMaker::Parameter.new( "integer" )  }
     core = SOCMaker::CoreDef.new( "My Core", "mycore,rel1", file, "top" )
     core.inst_parameters = parameters
     SOCMaker::lib.add_core( core )

     inst = SOCMaker::CoreInst.new( "mycore,rel1", {}  )
     inst.consistency_check
     inst.params[ :param1 ].should be == 0
     SOCMaker::lib.rm_core( core )
  end

end

#describe SOCMaker::CoreDef, "HDL interaction" do

#   it 'should return true and false for implements_port?, when a port is implemented and
#       not implemented' do
#      file       = { "file.vhd".to_sym => SOCMaker::HDLFile.new( "./file.vhd" ) }
#      core       = SOCMaker::CoreDef.new( "My Core", "mycore,rel1", file, "top" )
#      ifc_spc    = SOCMaker::IfcSpc.new( "a_ifc", "v1", "ports" => { p1: 1, p2: 0 } )
#      ifc        = SOCMaker::IfcDef.new( "a_ifc", "v1", 1, { p1: SOCMaker::IfcPort.new( "p1", 1 ) } )
#      core.interfaces[ :i1 ] = ifc
#      SOCMaker::lib.add_core( core )
#      SOCMaker::lib.add_ifc( ifc_spc ) 

#      o1 = SOCMaker::CoreInst.new( "mycore,rel1", {}  )
#      o1.consistency_check
#      o1.implements_port?( 'i1', 'p1' ).should be == true
#      o1.implements_port?( 'i1', 'p2' ).should be == false
#    end
#end

describe SOCMaker::CoreDef, "object handling, en-decoding:" do

  it "should be possible to encode and decode a core instance" do
    file = { "file.vhd".to_sym => SOCMaker::HDLFile.new( "./file.vhd" ) }
    parameters = { "param1".to_sym => SOCMaker::Parameter.new( "integer" )  }
    core = SOCMaker::CoreDef.new( "My Core", "mycore,rel1", file, "top" )
    core.inst_parameters = parameters
    SOCMaker::lib.add_core( core )

    o1 = SOCMaker::CoreInst.new( "mycore,rel1", {}  )
    yaml_str = o1.to_yaml
    o2 = YAML::load( yaml_str )
    o1.should be == o2
  end

  it "should return false for two non-equal objects" do
    file = { "file.vhd".to_sym => SOCMaker::HDLFile.new( "./file.vhd" ) }
    parameters = { "param1".to_sym => SOCMaker::Parameter.new( "integer" )  }
    core = SOCMaker::CoreDef.new( "My Core", "mycore,rel1", file, "top" )
    core.inst_parameters = parameters
    SOCMaker::lib.add_core( core )

    o1 = SOCMaker::CoreInst.new( "mycore,rel1" )
    o1.consistency_check
    o2 = Marshal::load(Marshal.dump(o1))
    o2.type << "X"
    ( o2 == o1 ).should be == false
    o2 = Marshal::load(Marshal.dump(o1))
    o2.params[ :param1 ] = 1
    ( o2 == o1 ).should be == false
  end

   it "should call coder functions for each core-def. (stub-version)" do
 
     SOCMaker::lib.clear
     soc = SOCMaker::SOCDef.new( "test_soc", "test_soc,v1", "my_soc_top" )


     coder = double()
   
     added_cores = {}
     coder.stub( :add_core_component ) do |name_arg, def_arg|
       added_cores[ name_arg.to_sym ] = def_arg
     end
   
     added_instances = {} 
     coder.stub( :add_core_instance ) do |name_arg, inst_arg|
       added_instances[ name_arg.to_sym ] = inst_arg
     end
   
     coder.stub( :get_hdl_code ){ |arg_coder| }
   
     coder.stub( :is_a? ){ SOCMaker::VHDLCoder }
   
     coder.stub( :filename ){ |x| x + ".vhd" }

     coder.stub( :add_ifc_default_assignment )

     coder.stub( :add_ifc_connection )


     added_cons = {}
    
     dir_path = ""
     FileUtils.stub( :mkdir_p ) { |arg| dir_path = arg }
     SOCMaker::conf[ :build_dir ] = 'a'
     SOCMaker::conf[ :hdl_dir   ] = 'b'
     dir_path_ref = "a/b"
   
   
   
   
     file = { "file.vhd".to_sym => SOCMaker::HDLFile.new( "./file.vhd" ) }
     core_a = SOCMaker::CoreDef.new( "core_a", "core_a,v1", file, "top" )
     core_b = SOCMaker::CoreDef.new( "core_b", "core_b,v1", file, "top" )
     SOCMaker::lib.add_core( core_a ) 
     SOCMaker::lib.add_core( core_b ) 
   
     ifc_spc = SOCMaker::IfcSpc.new( "myifc", "myifc,v1", 'ports' => { port_a: { dir: 1}, port_b: { dir: 0 } } )
     SOCMaker::lib.add_ifc( ifc_spc )
     ifc_def_1 = SOCMaker::IfcDef.new( "myifc", "myifc,v1", 0, { a: SOCMaker::IfcPort.new( "port_a", 1 ), 
                                                                 b: SOCMaker::IfcPort.new( "port_b", 1 ) } )
     
     ifc_def_0 = SOCMaker::IfcDef.new( "myifc", "myifc,v1", 1, { a: SOCMaker::IfcPort.new( "port_a", 1 ), 
                                                                 b: SOCMaker::IfcPort.new( "port_b", 1 ) } )
   
   
     core_a.interfaces[ :ifc_a ] = ifc_def_0
     core_a.interfaces[ :ifc_b ] = ifc_def_1
     core_b.interfaces[ :ifc_a ] = ifc_def_0
     core_b.interfaces[ :ifc_b ] = ifc_def_1
   
   
     i1 = SOCMaker::CoreInst.new( "core_a,v1" )
     i2 = SOCMaker::CoreInst.new( "core_a,v1" )
     i3 = SOCMaker::CoreInst.new( "core_b,v1" )
     i4 = SOCMaker::CoreInst.new( "core_b,v1" )
   
     soc.cores[ :inst_a ] = i1 
     soc.cores[ :inst_b ] = i2 
     soc.cores[ :inst_c ] = i3 
     soc.cores[ :inst_d ] = i4 
     soc.consistency_check
     soc.add_connection(  "inst_a", "ifc_a", "inst_b", "ifc_b", "a_new_con" )
    

     SOCMaker::lib.add_core( soc )
     soc_inst = SOCMaker::CoreInst.new( 'test_soc,v1' )
     soc_inst.consistency_check

     soc_inst.stub( :gen_toplevel_con ) do |name_arg,
                                        rule_arg,
                                        m0_arg,
                                        m1_arg |
       added_cons[ name_arg.to_sym ] = { rule: rule_arg, 
                                         m0: m0_arg, m1: m1_arg }
     end


   
     # file writing stub
     file_mock = double()
     file_mock.stub( :write )
     File.should_receive(:open).and_yield(file_mock)
   
     soc_inst.gen_toplevel( coder );
     added_cores.should be == { "core_a,v1".to_sym => core_a, "core_b,v1".to_sym => core_b }
     added_instances.should be == { inst_a: i1, inst_b: i2, inst_c: i3, inst_d: i4 }
     added_cons.should be == { a_new_con: { rule: "or", m0: {inst_a: :ifc_a}, m1: {inst_b: :ifc_b } } }
     dir_path.should be == dir_path_ref
   end




   it "should create valid vhdl output with our test library" do
   
     SOCMaker::conf[ :build_dir ] = 'spec/tmp_build2'
     SOCMaker::conf[ :hdl_dir   ] = 'b'
     coder = SOCMaker::VHDLCoder.new
     SOCMaker::lib.refresh( './spec/test_soc_lib' )
     soc = SOCMaker::from_f( './spec/test_soc.yaml' );
     SOCMaker::lib.add_core( soc )
     soc_inst = SOCMaker::CoreInst.new( 'test_soc,v1' )
     soc_inst.consistency_check
     soc_inst.gen_toplevel( coder );
     soc.copy_files
    #p soc.cons
    #puts soc.to_yaml
   end

end

# vim: noai:ts=2:sw=2
