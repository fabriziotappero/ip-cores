###############################################################
#   
#  File:      parameter.rb
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
#     A small classes, used to group information
#     and to verify, auto-correct and auto-complete
#     this information:
#     This class represents an instance parameter for 
#     a core with the following values:
#        - type (mandatory)
#        - default
#        - min
#        - max 
#        - visible 
#        - editable
#        - description
#     Most of the fields are reserved for future implementations.
#
###############################################################


module SOCMaker
class Parameter 
  include ERR
  attr_accessor :type
  attr_accessor :default
  attr_accessor :min
  attr_accessor :max
  attr_accessor :visible
  attr_accessor :editable
  attr_accessor :description
  attr_accessor :choice

  def initialize( type, optional = {} )
    init_with( { 'type' => type }.merge( optional ) )
  end

  def encode_with( coder )
    %w[ type default min max
        visible editable description ].
          each { |v| coder[ v ] = instance_variable_get "@#{v}" }
  end
  def init_with( coder )
    
    serr_if( coder[ 'type' ] == nil, 
      'no parameter type specified',
      field: "type" )
    @type = coder[ 'type' ]
    verr_if( !@type.is_a?( String ),
      "Parameter type is not defined with string",
      field: "parameter" )
    verr_if( @type.size == 0,
      "Parameter type string has zero length",
      field: "parameter" )

    @default      = coder[ 'default'     ] || 0
    @min          = coder[ 'min'         ] || 0
    @max          = coder[ 'max'         ] || 0
    @visible      = coder[ 'visible'     ] || true
    @editable     = coder[ 'editable'    ] || false
    @description  = coder[ 'description' ] || ''
    @choice       = coder[ 'choice'      ] || []
  end
  

  def ==(o)
    o.class         == self.class       && 
      o.type        == self.type        &&
      o.default     == self.default     &&
      o.min         == self.min         &&
      o.max         == self.max         &&
      o.visible     == self.visible     &&
      o.editable    == self.editable    &&
      o.description == self.description &&
      o.choice      == self.choice
  end


end
end

