###############################################################
#   
#  File:      soc_lib_spec.rb
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


describe SOCMaker::Lib do



  it "should return a SOCMaker::Lib when creating with new" do
    lib = SOCMaker::Lib.new()
    lib.class.should be SOCMaker::Lib
  end

  describe "loading functionality" do
  
    before( :each )do
       @lib = SOCMaker::Lib.new
    end
    
    describe "path loading" do
      it "should call process_include for each path given as argument" do
        paths_res = []
        @lib.stub( :process_include ) do |arg|
           paths_res << arg 
        end
        paths = [ "first_path", "second_path" ]
        @lib.refresh( paths )
        paths_res.should be == paths
      end
      
      it "should cal process_include for each path from config, if no argument is given" do
        paths_res = []
        @lib.stub( :process_include ) do |arg|
           paths_res << arg 
        end
        paths = [ "first_path", "second_path" ]
        SOCMaker::conf[ :cores_search_path ] = paths
        @lib.refresh( )
        paths_res.should be == paths
      end
    
    end
    
    describe "folder processing" do
      it "should raise an LibError if a folder is included twice" do
        expect do
          @lib.process_include( "./empty_soc_lib_folder" ) 
          @lib.process_include( "./empty_soc_lib_folder" ) 
        end.
        to raise_error( SOCMaker::ERR::LibError )
      end
    end
    

    describe "yaml include loading" do
      it "should return add two objects" do
      
        obs = []
        @lib.stub( :get_all_yaml_in_str ) do |arg|
           "SOCM_INCLUDE\ndirs:\n- folder_a\n- folder_b\n- folder_c\nSOCM_INCLUDE\ndirs:\n- folder_d\n- folder_e\n- folder_f\n" 
        end
        @lib.stub( :add_include ) do |arg|
           obs << arg
        end
        @lib.refresh( [ "some_path" ] )
        obs.should be == [ SOCMaker::LibInc.new( 'dirs' => ["folder_a", "folder_b", "folder_c"] ), 
                           SOCMaker::LibInc.new( 'dirs' => ["folder_d", "folder_e", "folder_f"] ) ]
      end
    end


    describe "library access" do
      it "should be possible to add, get and remove a core" do
        file = { "file.vhd".to_sym => SOCMaker::HDLFile.new( "./file.vhd" ) }
        c = SOCMaker::CoreDef.new( "A core", "acore,v1", file, "top" )
        @lib.add_core( c )
        @lib.get_core( "acore,v1" ).should be == c
        @lib.rm_core( c )
        expect { @lib.get_core( "acore,v1" ) }.
          to raise_error( SOCMaker::ERR::LibError ) 
      end

      it "should be possible to add, get and remove an interface" do
        i = SOCMaker::IfcSpc.new( "My Interface", "myifc,v2" )

        # removing with instance
        @lib.add_ifc( i )
        @lib.get_ifc( "myifc,v2" ).should be == i
        @lib.rm_ifc( i )

        expect { @lib.get_ifc( "myifc,v2" ) }. 
          to raise_error( SOCMaker::ERR::LibError ) 

        # removing with id
        @lib.add_ifc( i )
        @lib.get_ifc( "myifc,v2" ).should be == i
        @lib.rm_ifc( i.id )

        expect { @lib.get_ifc( "myifc,v2" ) }. 
          to raise_error( SOCMaker::ERR::LibError ) 

      end

      it "should process all folders in add_include" do
        all_folders = ["folder_a", "folder_b", "folder_c" ]
        i = SOCMaker::LibInc.new( 'dirs' => all_folders  )
        all_folders_res = []
        @lib.stub( :process_include ) do |arg|
          all_folders_res << arg
        end
        @lib.add_include( i, "./" )
        all_folders.each_with_index do |f,index|
          File.expand_path( File.join( "./", f ) ).should be == all_folders_res[ index ]
        end
      end

      it "should load all elements from our test library" do
        @lib.refresh( './spec/test_soc_lib' )
        core_A      = @lib.get_core( "core_A,rel1"  )
        core_B      = @lib.get_core( "core_B,rel1"  )
        core_AB_ifc = @lib.get_ifc( "core_AB_ifc,1" )
        core_A.class.should       be SOCMaker::CoreDef
        core_B.class.should       be SOCMaker::CoreDef
        core_AB_ifc.class.should  be SOCMaker::IfcSpc 
        core_A.static_parameters.size.should be == 3
      end

    end
  
  end

end

# vim: noai:ts=2:sw=2

