###############################################################
#   
#  File:      spc_lib.rb
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
#     This class represents the library, which holds all
#       - cores (core-definitions)
#       - interfaces (interface-specifications)
#
#
####
#
#
#
###############################################################

module SOCMaker
class Lib
  include ERR

  def initialize

    # will store all cores
    @cores_lib      = {}

    # will store all interfaces
    @ifc_lib      = {}

    # we remember paths, which we've already processed
    @path_lut = []

  end


  def clear
    @cores_lib.clear
    @ifc_lib.clear
    @path_lut.clear
  end


  # refreshes the core library:
  # it useses the global configuration entry cores_search_path,
  # which defines, where to search for inc_fname (defined in soc_maker_conf.rb) files.
  # For each directory, we call process_include
  def refresh( paths = nil )

    paths = [ paths ] if paths.is_a?( String )
    

    SOCMaker::logger.info  "START REFRESHING CORE LIBRARY"
    
    # clear the libs
    clear

    # use argument if given, otherwise config paths
    paths ||= SOCMaker::conf[ :cores_search_path ]


    paths.each do |dir|
      process_include dir
    end
    SOCMaker::logger.info  "DONE REFRESHING CORE LIBRARY"

  end



  def process_include( dir )

    #
    # this prevents the revursive call
    # from an infinite call
    #
    folder_sym = File.expand_path( dir ).to_sym
    lerr_if( @path_lut.include?( folder_sym ), 
        "double-include: infinite resursive search?" )
    @path_lut << folder_sym
  
    # get all yaml files in the directory
    SOCMaker::logger.info  "search for include in: " + dir
    

    SOCMaker::from_s( get_all_yaml_in_str( dir ) ) do |o|
      o.dir = dir
      case o
      when SOCMaker::LibInc
        add_include( o, dir )
      when SOCMaker::CoreDef
        add_core( o )
      when SOCMaker::SOCDef
        add_core( o )
      when SOCMaker::IfcSpc
        add_ifc( o )
      else
        #TODO add error
      end
    end

  end



  def get_all_yaml_in_str( dir )
    yaml_str = ""
    Dir[ File.join( dir, "*.yaml" ) ].sort.each do |yaml_file|
      SOCMaker::logger.info "reading:" + yaml_file
      yaml_str << File.read( yaml_file )
    end
    return yaml_str
  end



  # gets an SOCMaker::LibInc object and iterates
  # over all folders.
  # Note: this is moved from process_include to this extra function
  # to support test capability
  def add_include( soc_inc_object, dir )
    soc_inc_object.dirs.each { |d| process_include( File.expand_path( File.join( dir, d ) ) ) }
  end

  def add_core( core )
    # save core
    @cores_lib[ core.id ] = core
    
    SOCMaker::logger.info  "loaded "     + 
                            core.name     + 
                            ", id =  "   + 
                            core.id
  end

  def get_core( id )
    tmp = @cores_lib[ id ]
    check_nil( tmp, "Core with id '#{id}' does not exist" )
    return tmp
  end

  def rm_core( arg )
    
    if arg.is_a?( String )
      check_nil( @cores_lib[ arg ], "Core with id '#{arg}' does not exist" )
      @cores_lib.delete( arg )

    elsif arg.is_a?( SOCMaker::CoreDef )
      check_nil( @cores_lib[ arg.id ], "Core with id '#{arg.id}' does not exist" )
      @cores_lib.delete( arg.id )

    else
      raise SOCMaker::ERR::LibError.new( "", "FATAL: Can't remove interface" )
    end
  end




  def add_ifc( ifc )
    @ifc_lib[ ifc.id ] = ifc
  end

  def get_ifc( id )
    tmp = @ifc_lib[ id ]
    check_nil( tmp, "Interface with id '#{id}' does not exist" )
    return tmp
  end

  def rm_ifc( arg )

    if arg.is_a?( String )
      check_nil( @ifc_lib[ arg ], 
            "Interface with id '#{arg}' does not exist" )
      @ifc_lib.delete( arg )

    elsif arg.is_a?( SOCMaker::IfcSpc )
      check_nil( @ifc_lib[ arg.id ], 
            "Interface with id '#{arg.id}' does not exist" )
      @ifc_lib.delete( arg.id )

    else
      raise SOCMaker::ERR::LibError.new( "", "FATAL: Can't remove interface" )
    end

  end

  def to_s
      "IP-Core - lib: \n"             +
      @cores_lib.keys.to_s            +
      "\n\nIP-Interfaces - lib: \n"    +
      @ifc_lib.keys.to_s              
  end



  def check_nil( var, error_msg = "")
    if var == nil
      SOCMaker::logger.error error_msg
      raise SOCMaker::ERR::LibError.new( "", error_msg )
    end
  end



  #
  # get all interfaces in a list
  #
  # TODO untested: do we need this?
# def get_ifcs( core )
#   ifc_list = [];
#   core.interfaces.values.each do |ifc; ifc_tmp|
#     ifc_tmp = get_ifc( ifc[ :name ], ifc[ :version ] )
#     
#     # error handling
#     if ifc_tmp == nil
#       SOCMaker::logger.error  "Can't find #{ifc[ :name ]} version #{ifc[ :version ]} in SOC library"
#       raise NameError, "Can't find #{ifc[ :name ]} version #{ifc[ :version ]} in SOC library"
#     end
#
#     # add interface to list
#     ifc_list << ifc_tmp
#   end
#   return ifc_list
# end


  #
  # TODO add test code
  #
  def cores
    @cores_lib.each do |id,core|
      yield( id.to_s, core )
    end
  end
  

end #class Lib
end #Module SOCMaker

#
# vim: noai:ts=2:sw=2
