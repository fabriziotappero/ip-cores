###############################################################
#   
#  File:      hdl_file.rb
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
#     A small classes, used to group information
#     and to verify, auto-correct and auto-complete
#     this information:
#     The class represents an high-level-description (HDL) file.
#     The two supported file-types are *.vhdl and *.v, whose information
#     is stored in @type ('verilog' or 'vhdl').
#     A @path is mandatory and defines, where the file is located.
#     In addition, is is used for auto-detecting the file-type (if not given).
#     There are three flags:
#           - use_syn      (use in synthesis)
#           - use_sys_sim  (use in system simulation)
#           - use_mod_sim  (use in module simulation)
#     These flags are not used at the moment and reserved for 
#     future implementation.
#
#
###############################################################

module SOCMaker
class HDLFile
  include ERR
  attr_accessor :path 
  attr_accessor :use_syn 
  attr_accessor :use_sys_sim 
  attr_accessor :use_mod_sim
  attr_accessor :type

  def initialize( path, optional = {} )
    init_with( { 'path' => path }.merge( optional ) )
  end

  def encode_with( coder )
    %w[ path use_syn use_sys_sim use_mod_sim type ].
      each { |v| coder[ v ] = instance_variable_get "@#{v}" }
  end

  def init_with( coder )

    serr_if( !( coder.is_a?( Hash         ) || 
                coder.is_a?( Psych::Coder ) ), 
      'coder is not given as Hash neither as Psych::Coder' )

    # check path
    serr_if( coder[ 'path' ] == nil, 'no filepath specified' )
    @path = coder[ 'path' ]
    verr_if( !@path.is_a?( String ), 'path must be of type string' )

    # auto-complete to 'true'
    @use_syn      = coder[ 'use_syn'     ] || true
    @use_sys_sim  = coder[ 'use_sys_sim' ] || true
    @use_mod_sim  = coder[ 'use_mod_sim' ] || true

    # ensure, that the thee use... fields are boolean
    verr_if( !!@use_syn     != @use_syn,     'use_syn field must be true of false'      )
    verr_if( !!@use_sys_sim != @use_sys_sim, 'use_sys_sim field must be true of false'  )
    verr_if( !!@use_mod_sim != @use_mod_sim, 'use_mod_sim field must be true of false'  )
    
    # if the file-type is not given, we try to auto-detect it
    #   *.vhd  ->  vhdl
    #   *.v    ->  verilog
    #   (see conf[ :vhdl_file_regex ] and 
    #        conf[ :verilog_file_regex ] )
    if  coder[ 'type' ] == nil 
      if @path =~ SOCMaker::conf[ :vhdl_file_regex ]
        SOCMaker::logger.warn "Auto-detected vhdl file type for #{ @path }"
        @type = 'vhdl'
      elsif @path =~ SOCMaker::conf[ :verilog_file_regex ]
        SOCMaker::logger.warn "Auto-detected verilog file type for #{ @path }"
        @type = 'verilog'
      else
        verr_if( true, 'Cant auto-detect file type for "' + path + '"' )
      end
    else
      # if the file-type is given, ensure, that it is either 'vhdl' or 'verilog'
      verr_if( !SOCMaker::conf[ :hdl_type_regex ].match( coder[ 'type' ] ),
        "The type must be 'vhdl' or 'verilog'",
        instance: @path,
        field:    'type' )
      @type = coder[ 'type' ]
    end

  end



  def ==(o)
    o.class           == self.class         &&
    o.path            == self.path          &&
    o.use_syn         == self.use_syn       &&
    o.use_sys_sim     == self.use_sys_sim   &&
    o.use_mod_sim     == self.use_mod_sim   &&
    o.type            == self.type         
  end

end
end

# vim: noai:ts=2:sw=2

