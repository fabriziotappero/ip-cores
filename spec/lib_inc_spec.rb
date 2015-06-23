###############################################################
#   
#  File:      lib_inc_spec.rb
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

describe SOCMaker::LibInc, "structure verification for loading a library-include reference" do

   it "should return an object of type SOCMaker::LibInf when creating with new" do
      o = SOCMaker::LibInc.new( 'dirs' => [ 'a/dir/ectory' ] )
      o.class.should be SOCMaker::LibInc
   end

   it "should raise an error, if no paths are given" do
      expect{ SOCMaker::LibInc.new  }.
         to raise_error( SOCMaker::ERR::StructureError )
   end

   it "should raise an error, if nil is given as path" do
      expect{ SOCMaker::LibInc.new( 'dirs' => nil )  }.
         to raise_error( SOCMaker::ERR::StructureError )
   end

   it "should raise an error, if paths are not given as array" do
      expect{ SOCMaker::LibInc.new( 'dirs' => { p1: "1" } )  }.
         to raise_error( SOCMaker::ERR::ValueError )
   end

   it "should raise an error, a path is an empty string" do
      expect{ SOCMaker::LibInc.new( 'dirs' => ["valid/path", "" ] )  }.
         to raise_error( SOCMaker::ERR::ValueError )
   end

   it "should raise an error, a path is not a string" do
      expect{ SOCMaker::LibInc.new( 'dirs' => ["valid/path", 3 ] )  }.
         to raise_error( SOCMaker::ERR::ValueError )
   end
end

describe SOCMaker::LibInc, "object handling, en-decoding:" do

  it "should be possible to encode and decode a core instance" do
    o1 = SOCMaker::LibInc.new( 'dirs' => [ 'a/dir/ectory' ] )
    yaml_str = o1.to_yaml
    o2 = YAML::load( yaml_str )
    o1.should be == o2
  end

  it "should return false for two non-equal objects" do
    o1 = SOCMaker::LibInc.new( 'dirs' => [ 'a/dir/ectory' ] )
    o2 = Marshal::load(Marshal.dump(o1))
    o2.dirs[ 0 ] << "X"
    ( o2 == o1 ).should be == false
  end

end

