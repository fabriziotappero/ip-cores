###############################################################
#   
#  File:      core_def.rb
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
########
module SOCMaker


#########
#
# This class represents a core definition.
# It is one of the central classes and holds data,
# which is used to describe and instanciate this core.
# In general, instances of this class desribe a core,
# it's interface and parameters as well as the files,
# which are required for synthesis/simulation.
#
# In addition to this core, there exist SOCMaker::CoreInst,
# which represents a concret instanciation of a definition.
#
class CoreDef  < Component
  include ERR
  include YAML_EXT

  attr_accessor :hdlfiles 


  #
  # Constructor
  # The four attributes are required, and all other attributes
  # can be given as a optinal hash
  #
  # *name*:: Name of this component
  # *id*:: Id of this component
  # *hdl_files*:: Hash of HDL files
  # *toplevel*:: Toplevel name
  # *optional*:: Non-mandatory values, which can be set during initialization. 
  #            
  #
  def initialize( name, id, hdl_files, toplevel, optional = {} )
    init_with( { 'name'      => name,
                 'id'        => id,
                 'hdlfiles'  => hdl_files,
                 'toplevel'  => toplevel }.merge( optional ) )
  end   

  # 
  # Encoder function (to yaml)
  #
  # +coder+:: An instance of the Psych::Coder to encode this class to a YAML file
  #
  def encode_with( coder )
    super coder
    coder[ 'hdlfiles' ] = @hdlfiles
  end

  #
  # Initialization function (from yaml)
  #
  # +coder+:: An instance of the Psych::Coder to init this class from a YAML file
  #
  #
  def init_with( coder )
    super( coder )

    @hdlfiles = coder[ 'hdlfiles' ] || {}
    serr_if( !@hdlfiles.is_a?( Hash ),
      'HDL file def. != Hash',
      instance: @name, 
      field:    'hdlfiles' )

    @hdlfiles.each do |file_name, defn |
      serr_if( defn == nil,
            'HDL file not defined', 
            instance:   @name+":"+file_name.to_s )
  
      serr_if( !defn.is_a?( SOCMaker::HDLFile ),
            'HDL file not SOCMaker::HDLFile (use SOCM_HDL_FILE)', 
            instance: @name+":"+file_name.to_s )
    end

  end



  #
  # Loop over all generic values of the core
  # and yield the block with the
  # - generic name
  # - generic type
  # - the default value
  # - is-last value
  #
  #
  def generics
    @inst_parameters.each_with_index do |(name, val), i|
      yield( name.to_s, val.type, val.default, i == @inst_parameters.size-1 )
    end
  end


  #
  # this is a core_def and doesn't have
  # sub-cores
  def get_core_def( inst )
    perr_if( nil, "We don't have sub-cores" )
    return nil
  end


  #
  # Nothing implemented, yet.
  #
  def consistency_check
    super
  end


  #
  # Equality operator
  #
  def ==(o)
    o.class         == self.class       && 
    o.hdlfiles      == self.hdlfiles    &&
    super( o )
  end

  #
  # Returns a string describing this instance
  #
  def to_s
    super 
  end


end # class CoreDef
end # module SOCMaker
  

# vim: noai:ts=2:sw=2
