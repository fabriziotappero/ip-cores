###############################################################
#   
#  File:      sparameter.rb
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
#     This class represents a static parameter, which is
#     only defined once within a system. Usually, these
#     static parameters are mapped into a vhdl package or 
#     verilog include file.
#     The following fields are defined:
#        - path (of the file, which is used as input)
#        - file_dst (output file destination)
#        - parameters (hash of SParameterEntry values)
#     At the moment, the token within the value of the parameter-hash 
#     is used as regular expression to replace this token 
#     in the input file by the key of the parameter-hash, and 
#     write the result to the destination file.
#
###############################################################


module SOCMaker
class SParameter 
  include ERR
  attr_accessor :path
  attr_accessor :file_dst
  attr_accessor :parameters

  def initialize( path, file_dst, optional = {} )
    init_with( { 'path' => path,
                 'file_dst' => file_dst }.merge( optional ) )
  end
  def encode_with( coder )
    %w[ path file_dst parameters ].
          each { |v| coder[ v ] = instance_variable_get "@#{v}" }
  end
  def init_with( coder )

    # path
    serr_if( coder[ 'path' ] == nil, 
      'no file path specified for static parameter',
      field: 'path'  )
    @path = coder[ 'path' ]
    verr_if( !@path.is_a?( String ),
      'file path specified for static parameter is not of type string',
      field: 'path'  )
    verr_if( @path.size == 0,
      'file path specified for static parameter has zero length',
      field: 'path'  )


    # file_dst (file-destination)
    serr_if( coder[ 'file_dst' ] == nil, 
      'no destination file directory given for static parameter',
      instance: @path,
      field:    'file_dst' )
    @file_dst = coder[ 'file_dst' ]
    verr_if( !@file_dst.is_a?( String ), 
      'destination file directory given for static parameter is not of type string',
      instance: @path,
      field:    'file_dst' )
    verr_if( @file_dst.size == 0,
      'file path specified for static parameter has zero length',
      field: 'path'  )


    @parameters = coder[ 'parameters' ] || {}
    @parameters.each do |name, param|
      serr_if( param == nil,
            'Static parameter entry not defined', 
            instance:   name.to_s )
    
      serr_if( !param.is_a?( SOCMaker::SParameterEntry ), 
            'Static parameter entry not SOCMaker::SParameterEntry (use SOCM_SENTRY)', 
            instance: name.to_s )
    end

  end

 

  def ==(o)
    o.class == self.class               && 
      o.parameters == self.parameters   &&
      o.file_dst   == self.file_dst     &&
      o.path       == self.path
  end



end
class SParameterEntry < Parameter
  attr_accessor :token

  def initialize( type, token, optional = {} )
    init_with( { 'type' => type,
                 'token' => token }.merge( optional ) )

  end
  def encode_with( coder )
    super coder
    coder[ 'token' ] = @token
  end
  def init_with( coder )
    super coder

    serr_if( coder[ 'token' ] == nil, 
      'no token specified',
      field: token)
    @token = coder[ 'token' ]
    verr_if( !@token.is_a?( String ), 'token is not a string' )
    verr_if( @token.size == 0, 'token has zero size' )
  end

  def ==(o)
    o.class == self.class   &&
    o.token  == self.token  &&
    super( o )
  end


end
end


# vim: noai:ts=2:sw=2
