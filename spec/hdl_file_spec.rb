###############################################################
#   
#  File:      hdl_file_spec.rb
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
#     Test specification for SOCMaker::HDLFile
#
#
#
###############################################################
require_relative( 'spec_helper' )




describe SOCMaker::HDLFile, "HDL file loading" do
  
  #
  # core definition with no info about the HDL file
  F_MIN_YAML_FIlE_NIL = '''SOCM_CORE
  name: core_A
  version: rel1
  toplevel: top_A
  hdlfiles:
     :a_file.v: SOCM_HDL_FILE
  '''
  
  F_YAML_FILE_TYPE = '''SOCM_CORE
  name: core_A
  version: rel1
  toplevel: top_A
  hdlfiles:
     :core_a.vhd: SOCM_HDL_FILE
        path: ./core_a.vhd
        type: xhdl
  '''


  it "should return a HDLFile object if new is called" do
     o = SOCMaker::HDLFile.new( "./path/to/file.vhd" )
     o.class.should be == SOCMaker::HDLFile
  end
  
  
  it "should raise an error, if an invalid file type is provided" do
     expect { SOCMaker::HDLFile.new( "./path/to/invalid_file.vhx" ) }.
     to raise_error( SOCMaker::ERR::ValueError )
  end

  it "should raise an error, if no path is given (empty string)" do
     expect { SOCMaker::HDLFile.new( "" ) }.
     to raise_error( SOCMaker::ERR::ValueError )
  end

  it "should raise an error, if no path is given (nil)" do
     expect { SOCMaker::HDLFile.new( nil ) }.
     to raise_error( SOCMaker::ERR::StructureError )
  end

  it "should raise an error, if path is not a string" do
     expect { SOCMaker::HDLFile.new( 3 ) }.
     to raise_error( SOCMaker::ERR::ValueError )
  end
   
  it "should raise an error, if the HDL file info is nil" do
     expect { SOCMaker::from_s( F_MIN_YAML_FIlE_NIL ) }.
     to raise_error( SOCMaker::ERR::StructureError )
  end
   
  it "should raise an error, if an invalid file type is given" do
     expect { SOCMaker::from_s( F_YAML_FILE_TYPE ) }.
     to raise_error( SOCMaker::ERR::ValueError )
  end
  
  it "should raise an error, if use_syn is not boolean" do
     expect { SOCMaker::HDLFile.new( "./path/to/file.vhd", "use_syn" => "not boolean" ) }.
     to raise_error( SOCMaker::ERR::ValueError )
  end
  
  it "should raise an error, if use_sys_sim is not boolean" do
     expect { SOCMaker::HDLFile.new( "./path/to/file.vhd", "use_sys_sim" => "not boolean" ) }.
     to raise_error( SOCMaker::ERR::ValueError )
  end
  
  it "should raise an error, if use_mod_sim is not boolean" do
     expect { SOCMaker::HDLFile.new( "./path/to/file.vhd", "use_mod_sim" => "not boolean" ) }.
     to raise_error( SOCMaker::ERR::ValueError )
  end

  it "should auto-detect verilog files" do
     o = SOCMaker::HDLFile.new( "./path/to/file.v" )
     o.type.should be == "verilog"
  end

  it "should auto-detect vhdl files" do
     o = SOCMaker::HDLFile.new( "./path/to/file.vhd" )
     o.type.should be == "vhdl"
  end

  it "should auto-complete the three flags use_syn use_sys_sim use_mod_sim" do
     o = SOCMaker::HDLFile.new( "./path/to/file.vhd" )
     o.use_syn.should be     == true
     o.use_mod_sim.should be == true
     o.use_sys_sim.should be == true
  end

  %w[ use_syn use_sys_sim use_mod_sim  ].each do |m|
    it "should raise an error if #{m} is not false or true" do
      expect { SOCMaker::HDLFile.new( "./path/to/file.vhd", { m => 4 } ) }.
      to raise_error( SOCMaker::ERR::ValueError )
    end
  end

  it "should return false for two non-equal objects" do
    o1 = SOCMaker::HDLFile.new( "./path/to/file.vhd" )
    o2 = Marshal::load(Marshal.dump(o1))
    o2.use_syn = !o2.use_syn
    ( o2 == o1 ).should be == false
  end
     
  it "should be possible to encode and decode a HDL file object" do
    o1 = SOCMaker::HDLFile.new( "./path/to/file.vhd", 
        'use_syn' => false,
        'use_mod_sim' => false,
        'use_sys_sim' => false )
    yaml_str = o1.to_yaml
    o2 = YAML::load( yaml_str )
    o1.should be == o2
  end


                                      
end                                        


# vim: noai:ts=2:sw=2

