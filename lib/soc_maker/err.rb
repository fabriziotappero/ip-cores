###############################################################
#   
#  File:      err.rb
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
#     Error definitions and functions, which are used via mixins.
#
#
###############################################################


module SOCMaker

  #
  # This sub-module contains some error-functionallity,
  # which is used in different classes via mixins.
  #
  # serr_if  means  raise Structure ERRor IF ...
  # verr_if  means  raise Value ERRor IF ...
  # lerr_if  means  raise Library ERRor IF ...
  # perr_if  mean   raise Processing ERRor IF
  module ERR
    class YAMLParseError < RuntimeError
    end

    class StructureError < RuntimeError
      attr :name
      attr :field
      def initialize( name, field, message )
        super message
        @name   = name
        @field  = field
       # p message
        SOCMaker::logger.error( "StructureError raised: " + message + " (#{name},#{field})" )
      end
      def to_s
        "#{super} -> #{@name}:#{@field}"
      end
    end

    class LibError < RuntimeError
      attr :name
      def initialize( requested, message )
        super message
        @name = requested
        SOCMaker::logger.error( "LibError raised: " + message + " (#{requested})" )
      end
      def to_s
        "#{super} -> #{@name}:#{@field}"
      end
    end

    class ProcessingError < RuntimeError
      def initialize( message )
        super message
        SOCMaker::logger.error( "ProcessingError raised: " + message )
      end
    end

    class ValueError < RuntimeError
      attr :name
      attr :field
      def initialize( name, field, message )
        super message
        @name = name
        @field = field
        SOCMaker::logger.error( "ValueError raised: " + message + " (#{name},#{field})" )
      end
      def to_s
        "#{super} -> #{@name}:#{@field}"
      end
    end



    def serr_if( res, msg, o={} )
      o = { instance: '??', field: '??' }.merge( o )
      if !!( res )
        raise  StructureError.new( o[:instance], o[:field], msg ) 
      end
    end
 
    def verr_if( res, msg, o={})
      o = { instance: '??', field: '??' }.merge( o )
      if !!( res )
        raise ValueError.new( o[:instance], o[:field], msg )
      end
    end
 
    def lerr_if( res, msg, o={})
      o = { requested: '??' }.merge( o )
      if !!( res )
        raise LibError.new( o[:requested], msg )
      end
    end
 
    def perr_if( res, msg )
      if !!( res )
        raise ProcessingError.new( msg )
      end
    end

  end # module ERR

end # module SOCMaker
