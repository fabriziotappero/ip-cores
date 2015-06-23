###############################################################
#   
#  File:      ifc_port.rb
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
#     The class represents an interface port within 
#     SOCMaker::IfcDef (see ifc_def.rb).
#     It is used to make a relation between the naming
#     of IfcDef and IfcSpc.
#     The two data fiels are
#        - defn (mandatory: must be the name of the port, defined in IfcSpc)
#        - len (optional, default is 1)
#
###############
#
# TODO
#     - Add test-code
#     - Rename defn to something more meaningful
#
###############################################################

module SOCMaker
class IfcPort 
  include ERR
  attr_accessor :defn
  attr_accessor :len
  

  def initialize( defn, len = 1 )
    init_with( 'defn' => defn,
               'len'  => len )
  end
  def encode_with( coder )
    %w[ defn len ].
          each { |v| coder[ v ] = instance_variable_get "@#{v}" }
  end
  def init_with( coder )

    serr_if( coder[ 'defn' ] == nil, 
      'no relation to interface-definition is given for an interface port (nil)',
      field: "defn" )
    @defn = coder[ 'defn' ]

    verr_if( !@defn.is_a?( String ),
      'Relation to interface definition is not of type string',
      instance: @defn.to_s,
      field:    "defn")

    verr_if( @defn.size == 0, 
      'Relation to interface definition has zero length',
      instance: @defn.to_s,
      field:    "defn")

    @len = coder[ 'len' ] || 1

    verr_if( !( @len.is_a?( Fixnum ) || @len.is_a?( String ) ),
      'Length is not a fixnum',
      instance: @defn.to_s,
      field:    "defn")
  end
 
 

  def ==(o)
    o.class  == self.class   && 
    o.defn   == self.defn    &&
    o.len    == self.len 
  end 


end
end
