###############################################################
#   
#  File:      lib_inc.rb
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
#     A small class, which represents a library-include information.
#     The influde directories are stored in @dirs
#
#
###############################################################
module SOCMaker
class LibInc
  include ERR
  include YAML_EXT

  attr_accessor :dirs

  def initialize( opts = {} )
    init_with( opts )
  end

  def encode_with( coder )
    %w[ dirs ].
      each { |v| coder[ v ] = instance_variable_get "@#{v}" }
  end

  def init_with( coder )
    serr_if( !( coder.is_a?( Hash         ) || 
                coder.is_a?( Psych::Coder ) ), 
      'coder is not given as Hash neither as Psych::Coder' )
    serr_if( coder[ 'dirs' ] == nil, 
      'no dirs are given' )

    @dirs = coder[ 'dirs' ] 

    verr_if( !@dirs.is_a?( Array ),       
      'dirs must be of type array' )
    verr_if( @dirs.size == 0, 
      'there must be at least one dir-entry')
    
    @dirs.each do |f|
      verr_if( !f.is_a?( String ),
        "The dir must be defined as string",
        field:    'dirs' )
      verr_if( f.size == 0,
        "The path string has zero length",
        field: 'dirs' )
    end
  end 


  def ==(o)
    o.class == self.class && o.dirs == self.dirs
  end

end
end

# vim: noai:ts=2:sw=2


