###############################################################
#   
#  File:      ifc_def.rb
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
#     The class represents an interface definition:
#        - name of the interface (mandatory)
#        - a id (mandatory)
#        - a direction  (mandatry)
#        - ports (hash of type SOCMaker::IfcPort, mandatory)
#
#     Note: instances of this class are used withing core-definitions.
#           Different cores may use the same interface, but with a 
#           different naming of the ports. For this reason, the name+id
#           is used to identify, which interface specification (SOCMaker::IfcSpc)
#           is defined. The port-hash makes the relation between the core port-naming
#           and the IfcSpc port-naming.
#           TODO
#
###############################################################
  
module SOCMaker  
class IfcDef 
  include ERR
  attr_accessor :name
  attr_accessor :dir
  attr_accessor :id
  attr_accessor :ports

  def initialize( name, id, dir, ports )
    init_with( 'name'     => name,
               'dir'      => dir,
               'id'  => id,
               'ports'    => ports )
  end
  def encode_with( coder )
    %w[ name dir id ports ].
          each { |v| coder[ v ] = instance_variable_get "@#{v}" }
  end
  def init_with( coder )

    # name
    serr_if( coder[ 'name' ] == nil,
      'no name defined for this interface',
      field:    'name' )
    @name = coder[ 'name' ]
    verr_if( !@name.is_a?( String ),
      'Interface name is not defined as string', 
      instance: @name.to_s,
      field:    'name' )
    verr_if( @name.size == 0,
        "Name has zero length",
        field: "name" )

    # id
    serr_if( coder[ 'id' ] == nil,
      'id is not given for interface',
      instance: @name,
      field:    'id' )
    @id = coder[ 'id' ]
    serr_if( !@id.is_a?( String ),
      'Interface id is not defined as string',
      instance: @name,
      field:    'id' )
    verr_if( @id.size == 0,
        "Version has zero length",
        field: "name" )


    # ports
    serr_if( coder[ 'ports' ] == nil,
      "No ports are given for interface definition",
      field: 'ports' )
    @ports = coder[ 'ports' ]
    serr_if( !@ports.is_a?( Hash )  ||
              @ports.size == 0, 
      'no ports are given for this interface', 
      instance: @name,
      field:    'ports' )

    @ports.each do |name, port|
      serr_if( port == nil, 'no port definition found',
        instance: @name + name.to_s,
        field:    'ports' )

      serr_if( !port.is_a?( SOCMaker::IfcPort ), 
        'Port is not of type SocMaker::IfcPort (use SOCM_PORT)',
        instance: @name + name.to_s,
        field:    'ports' )

    end

    # direction
    serr_if( coder[ 'dir' ] == nil,
      'Interface direction is not given',
      instance: @name,
      field:    'dir' )
    @dir = coder[ 'dir' ]
    verr_if( @dir != 0 && @dir != 1, 
      'Interface direction must be 0 or 1',
      instance: @name,
      field:    'dir' )

  
  end



  def ==(o)
    o.class         == self.class       && 
    o.name          == self.name        &&
    o.dir           == self.dir         &&
    o.id       == self.id     &&
    o.ports         == self.ports       
  end


end # IFCDef
end # SOCMaker
