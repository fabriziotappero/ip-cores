###############################################################
#   
#  File:      core_def_spec.rb
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
#     Test specification for SOCMaker::CoreDef
#
#
#
#
###############################################################
require_relative( 'spec_helper' )







describe SOCMaker::CoreDef, "structure verification for loading a core-definition" do

  valid_yamls = []
  invalid_v_yamls = []
  invalid_s_yamls = []


  #
  # A yaml example, which contains 
  #   - a full definition
  #   - an interface with one port
  #   - one hdl file
  #   - one instance parameter
  #   - one static parameter
  # 
  FULL_YAML = '''SOCM_CORE
name: core_A
description: A test IP-core
id: core_A,rel1
date: 1.1.2014
license: LGPL
licensefile: 
author: Christian Haettich
authormail: feddischson@opencores.org
vccmd: svn co http://some-address/
toplevel: core_a
interfaces:
  :ifc01: SOCM_IFC
    name: core_AB_ifc
    dir: 0
    id: core_AB_ifc,1
    ports:
      :sig_con1a: SOCM_PORT
         defn: sig_a
         len:  param1
hdlfiles:
   :core_a.vhd: SOCM_HDL_FILE
      use_syn: true
      use_sys_sim: true
      use_mod_sim: true
      type: vhdl
      path: ./core_a.vhd
inst_parameters:
  :param1: SOCM_PARAM
    type: integer
    default: 8
    min: 0
    max: 10
    visible: true
    editable: true
    description: More setup
static_parameters:
  :core_a_pkg.vhd.src: SOCM_SPARAM
    path: ./core_a.pkg.src
    file_dst: core_a_pkg.vhd
    parameters: 
      :p1: SOCM_SENTRY
        token: TOK1
        type: integer
        min:  0
        max:  100
        visible: true
        editable: true
        default: 3
        description: Some setup
'''
  valid_yamls << {  desc: 'should return a class of type CoreDef when loading a full core-def',
                    yaml: FULL_YAML }



  # minimalistic def with one vhdl file
  MIN_YAML1 = '''SOCM_CORE
name: core_A
id: core_A,rel1
toplevel: top_A
hdlfiles: 
   :core_a.vhd: SOCM_HDL_FILE
      path: ./core_a.vhd
'''
  valid_yamls << {  desc: 'should return a class of type CoreDef when loading a minimal core-def',
                    yaml: MIN_YAML1 }


  # minimalistic def with one 
  # vhdl and one verilog file
  MIN_YAML2 = '''SOCM_CORE
name: core_A
id: core_A,rel1
toplevel: top_A
hdlfiles:
   :core_a.vhd: SOCM_HDL_FILE
      path: ./core_a.vhd
   :core_b.v: SOCM_HDL_FILE
      path: ./core_b.v
'''
  valid_yamls << {  desc: 'should return a class of type CoreDef when loading a core-def with two files',
                    yaml: MIN_YAML2 }






#    # def with version.size == 0
#    F_YAML_VERSION = '''SOCM_CORE
#  name: core_A
#  version: ''
#  toplevel: top_A
#  hdlfiles:
#     :core_a.vhd: SOCM_HDL_FILE
#        path: ./core_a.vhd
#  '''
#    invalid_s_yamls << {  desc: 'should raise an error if version is a string with length 0',
#                          yaml: F_YAML_VERSION }


#    # def with name.size == 0
#    F_YAML_NAME = '''SOCM_CORE
#  name: ''
#  version: rel1
#  toplevel: top_A
#  hdlfiles:
#     :core_a.vhd: SOCM_HDL_FILE
#        path: ./core_a.vhd
#  '''
#    invalid_s_yamls << {  desc: 'should raise an error if name is a string with length 0',
#                          yaml: F_YAML_NAME }







  # def with toplevel.size == 0
  F_YAML_TOPLEVEL = '''SOCM_CORE
name: core_A
id: core_A,rel1
toplevel: ''
hdlfiles:
   :core_a.vhd: SOCM_HDL_FILE
      path: ./core_a.vhd
'''
  invalid_s_yamls << {  desc: 'should raise an error if toplevel is a string with length 0',
                        yaml: F_YAML_TOPLEVEL }



  # def with hdlfiles.class != Hash
  F_YAML_FILE_HASH = '''SOCM_CORE
name: core_A
id: core_A,rel1
toplevel: top_A
hdlfiles:
   - test1.vhd
   - test2.vhd
'''
  invalid_s_yamls << {  desc: 'should raise an error if hdlfiles is not a hash',
                        yaml: F_YAML_FILE_HASH }




  # minimal setup with one interface
  MIN_YAML_IFC = '''SOCM_CORE
name: core_A
id: core_A,rel1
toplevel: top_A
hdlfiles:
   :core_a.vhd: SOCM_HDL_FILE
      path: ./core_a.vhd
interfaces:
  :ifc01: SOCM_IFC
    name: a_ifc_def
    dir: 0
    id: a_ifc_def,1
    ports:
      :sig_con1a: SOCM_PORT
         defn: sig_a
'''
  valid_yamls << { desc: 'should return a class of type CoreDef when loading a minimal core-def with a minimal interface',
                   yaml: MIN_YAML_IFC }





  # minimal setup with one instance parameter
  MIN_YAML_INSTP = '''SOCM_CORE
name: core_A
id: core_A,rel1
toplevel: top_A
hdlfiles:
   :core_a.vhd: SOCM_HDL_FILE
      path: ./core_a.vhd
inst_parameters: 
  :param1: SOCM_PARAM
    type: integer
'''
  valid_yamls << {  desc: 'should return a class of type CoreDef when loading a minimal core-def (with instance param.)',
                    yaml: MIN_YAML_INSTP }


  # empty hash for param1
  F_YAML_INSTP_EMPTY = '''SOCM_CORE
name: core_A
id: core_A,rel1
toplevel: top_A
hdlfiles:
   :core_a.vhd: SOCM_HDL_FILE
      path: ./core_a.vhd
inst_parameters:
  :param1: SOCM_PARAM
'''
  invalid_s_yamls << {  desc: 'should raise an error if an instance param. is empty',
                        yaml: F_YAML_INSTP_EMPTY }

  # minimal def with one static parameter
  MIN_YAML_STATIC = '''SOCM_CORE
name: core_A
id: core_A,rel1
toplevel: top_A
hdlfiles:
   :core_a.vhd: SOCM_HDL_FILE
      path: ./core_a.vhd
static_parameters:
  :a_file.vhd.src: SOCM_SPARAM
    file_dst: a_file.vhd
    path: ./core_a.vhd
    parameters:
      :p1:  SOCM_SENTRY
        type: integer
        token: T1
'''
  valid_yamls << {  desc: 'should return a class of type CoreDef when loading a minimal core-def (with static param.)', 
                    yaml: MIN_YAML_STATIC }



  # empty static parameter
  F_YAML_STATIC_EMPTY = '''SOCM_CORE
name: core_A
id: core_A,rel1
toplevel: top_A
hdlfiles:
   :core_a.vhd: SOCM_HDL_FILE
      path: ./core_a.vhd
static_parameters:
  :a_file.vhd: SOCM_SPARAM
'''
  invalid_s_yamls << {  desc: 'should raise an error if a static parameters is empty',
                        yaml: F_YAML_STATIC_EMPTY }



  # removed: not implemented at the moment

# #
# # test for invalid path
# it "should raise an error if a non-existing path is given" do
#   expect { SOCMaker::from_f( 'blabla.txt' ) }.
#       to raise_error( IOError )
# end
 

  it "should return a CoreDef object, if the object is created via new" do
    file = { "file.vhd".to_sym => SOCMaker::HDLFile.new( "./file.vhd" ) }
    c = SOCMaker::CoreDef.new( "acore", "acore,v1", file, "top" )
    c.class.should be == SOCMaker::CoreDef
  end 
  
  
  
  # process all valid YAMLs
  #  each should result in a CoreDef
  valid_yamls.each do |setup|
    it setup[:desc] do
      SOCMaker::from_s( setup[:yaml] ).class.should == SOCMaker::CoreDef
    end
  end
  
  # process all invalid YAMLs
  #  each should result in a StructureError
  invalid_s_yamls.each do |setup|
    it setup[:desc] do
      expect { SOCMaker::from_s( setup[ :yaml ] ) }.
        to raise_error( SOCMaker::ERR::StructureError ) 
    end
  end
  
  
  # process all invalid YAMLs
  #  each should result in a ValueError
  invalid_v_yamls.each do |setup|
    it setup[:desc] do
      expect { SOCMaker::from_s( setup[ :yaml ] ) }.
        to raise_error( SOCMaker::ERR::ValueError ) 
    end
  end
  
  #
  # remove some entries in the basic definition
  #   It is ok, when the first line is not available:
  #   In this case, we assume, that something unrelated
  #   to SOCMaker is loaded
  # 
  min_yaml_lines = MIN_YAML1.lines
  (1..min_yaml_lines.size-1).each do |i|
    min_yaml_lines.delete_at( i )
    inval_yaml = min_yaml_lines.join
    it 'should raise an error if loading of an invalid yaml is done (A)' do
      expect { SOCMaker::from_s( inval_yaml ) }.
        to raise_error
    end
    min_yaml_lines = MIN_YAML1.lines
  end
  
  # remove entries in the interface definition
  #
  min_yaml_lines = MIN_YAML_IFC.lines
  (9..min_yaml_lines.size-1).each do |i|
    min_yaml_lines.delete_at( i )
    inval_yaml = min_yaml_lines.join
    it 'should raise an error if loading of an invalid yaml is done (B)' do
      expect { SOCMaker::from_s( inval_yaml ) }.
        to raise_error
    end
    min_yaml_lines = MIN_YAML_IFC.lines
  end
 

 
  # auto-completion of basic info
  #
  it 'should return an CoreDef object with non-nil parameters, even if parameters are not specified' do
    tmp = SOCMaker::from_s( MIN_YAML2 )
    tmp.class.should be                 == SOCMaker::CoreDef
    tmp.vccmd.should_not be             == nil
    tmp.description.should_not be       == nil
    tmp.date.should_not be              == nil
    tmp.license.should_not be           == nil
    tmp.licensefile.should_not be       == nil
    tmp.author.should_not be            == nil
    tmp.authormail.should_not be        == nil
    tmp.vccmd.should_not be             == nil
    tmp.interfaces.should_not be        == nil
    tmp.functions.should_not be         == nil
    tmp.inst_parameters.should_not be   == nil
    tmp.static_parameters.should_not be == nil    
    
    tmp.hdlfiles[ 'core_a.vhd'.to_sym ].type        .should be == 'vhdl'
    tmp.hdlfiles[ 'core_b.v'.to_sym   ].type        .should be == 'verilog'
    tmp.hdlfiles[ 'core_a.vhd'.to_sym ].use_syn     .should be == true
    tmp.hdlfiles[ 'core_a.vhd'.to_sym ].use_sys_sim .should be == true
    tmp.hdlfiles[ 'core_a.vhd'.to_sym ].use_mod_sim .should be == true
  end
  
  # auto-completion of interface setups
  #
  it 'should auto-complete the field length to 1 when loading a minimal core-def with a minimal interface' do
    tmp = SOCMaker::from_s( MIN_YAML_IFC )
    tmp.interfaces[ :ifc01 ].ports[ :sig_con1a ].len.should == 1
  end
  
  # auto-completion of static-parameters
  # 
  it 'should auto-complete static parameter setup to non-nil values when loading a minimal core-def' do
    tmp = SOCMaker::from_s( MIN_YAML_STATIC )
    tmp.static_parameters[ :'a_file.vhd.src'].parameters[ :p1 ].default.should be     == 0
    tmp.static_parameters[ :'a_file.vhd.src'].parameters[ :p1 ].min.should be         == 0
    tmp.static_parameters[ :'a_file.vhd.src'].parameters[ :p1 ].max.should be         == 0
    tmp.static_parameters[ :'a_file.vhd.src'].parameters[ :p1 ].visible.should be     == true
    tmp.static_parameters[ :'a_file.vhd.src'].parameters[ :p1 ].editable.should be    == false
    tmp.static_parameters[ :'a_file.vhd.src'].parameters[ :p1 ].description.should be == ''
  end
  
  # auto-completion of instance-parameters
  #
  it 'should auto-complete inst. parameter setup to non-nil values when a minimal core-def' do
    tmp = SOCMaker::from_s( MIN_YAML_INSTP )
    tmp.inst_parameters[ :param1 ].min          .should be  == 0
    tmp.inst_parameters[ :param1 ].max          .should be  == 0
    tmp.inst_parameters[ :param1 ].default      .should be  == 0
    tmp.inst_parameters[ :param1 ].visible      .should be  == true
    tmp.inst_parameters[ :param1 ].editable     .should be  == false
    tmp.inst_parameters[ :param1 ].description  .should be  == ''
  end
  

  
  # This is a valid version which we manipulate and
  # test, if the manipulation is detected/corrected
# tmp = SOCMaker::from_s( FULL_YAML )
# 
# 
# 
# 
# it 'should raise an error if ifc-name is not a string' do
#   tmp.interfaces[ :ifc01 ].name  = 4
#   expect { SOCMaker::from_s( SOCMaker::YPP.from_yaml( tmp.to_yaml ) ) }.
#     to raise_error( SOCMaker::ERR::ValueError )
#   tmp.interfaces[ :ifc01 ].name = 'name'
# end
# 
# it 'should raise an error if ifc-dir is not 0 or 1' do
#   tmp.interfaces[ :ifc01 ].dir  = 4
#   expect { SOCMaker::from_s( SOCMaker::YPP.from_yaml( tmp.to_yaml ) ) }.
#     to raise_error( SOCMaker::ERR::ValueError )
#   
#   tmp.interfaces[ :ifc01 ].dir  = "test"
#   expect { SOCMaker::from_s( SOCMaker::YPP.from_yaml( tmp.to_yaml )  ) }.
#     to raise_error( SOCMaker::ERR::ValueError )
#   tmp.interfaces[ :ifc01 ].dir = 0
# end
# 
# it 'should convert an interface version from numerical to string' do
#   tmp.interfaces[ :ifc01 ].version = 4
#   tmp2 = SOCMaker::from_s( SOCMaker::YPP.from_yaml( tmp.to_yaml ) )
#   tmp2.interfaces[ :ifc01 ].version.class.should be == String
# end
 
end

describe SOCMaker::CoreDef, "object handling, en-decoding:" do

  it "should be possible to encode and decode a core definition" do
    file = { "file.vhd".to_sym => SOCMaker::HDLFile.new( "./file.vhd" ) }
    o1 = SOCMaker::CoreDef.new( "acore", "acore,v1", file, "top" )
    yaml_str = o1.to_yaml
    o2 = YAML::load( yaml_str )
    o1.should be == o2
  end

  it "should return false for two non-equal objects" do
    file = { "file.vhd".to_sym => SOCMaker::HDLFile.new( "./file.vhd" ) }
    o1 = SOCMaker::CoreDef.new( "acore", "acore,v1", file, "top" )
    o2 = Marshal::load(Marshal.dump(o1))
    o2.id = "acore,v2"
    ( o2 == o1 ).should be == false
    o2 = Marshal::load(Marshal.dump(o1))
    o2.hdlfiles[ "file.vhd".to_sym ].use_syn = false
    ( o2 == o1 ).should be == false
  end



# tmp = SOCMaker::from_s( FULL_YAML )
# tmp.save_def( "./test.yaml" ) 



end



# vim: noai:ts=2:sw=2
