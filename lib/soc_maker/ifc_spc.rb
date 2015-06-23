###############################################################
#   
#  File:      if_spec.rb
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
module SOCMaker
class IfcSpc
  include ERR
  include YAML_EXT

  attr_accessor :name
  attr_accessor :id
  attr_accessor :ports

  def initialize( name, id, optional = {} )
    init_with( { 'name' => name, 
                 'id' => id }.merge( optional ) )
  end
  def encode_with( coder )
    %w[ name id ports ].
          each { |v| coder[ v ] = instance_variable_get "@#{v}" }
  end
  def init_with( coder )

    verr_if( coder[ 'name' ] == nil, 
      "Name is not defined",
      field: "name" )
    @name = coder[ 'name' ]
    verr_if( !@name.is_a?( String ),
        "Name is not defined as string",
        field: "name" )
    verr_if( @name.size == 0,
        "Name has zero length",
        field: "name" )


    verr_if( coder[ 'id' ] == nil,
      "Id is not defined",
      field: "id" )
    @id = coder[ 'id' ]
    verr_if( !@id.is_a?( String ),
        "Version is not defined as string",
      instance: @name,
      field:    "id" )
    verr_if( @id.size == 0,
        "Version has zero length",
        field: "name" )

    @ports = coder[ 'ports' ] || {}
    @ports.each do |pname, port| 

      verr_if( !port.is_a?( Hash ),
        "Port field must be organized as a hash",
          instance: @name,
          field: "ports" )

      verr_if( !port.has_key?( :dir ), 
          "No port direction specified for #{pname}",
        instance: @name,
        field: "ports" )

      verr_if( !port[ :dir ].is_a?( Fixnum ) ||
              ( port[ :dir ] != 0 && port[ :dir ] != 1 ),
               "Port direction value for #{pname} is neither 0 nor 1",
               instance: @name,
               field:    "ports" )

      port[ :mandatory ] = true if !port.has_key?( :mandatory )
      port[ :default ]   ||= '0'

    end
    
  end


end
end


# vim: noai:ts=2:sw=2
