###############################################################
#   
#  File:      ypp.rb
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
#       YAML Pre-Processor:
#       We use it only in a static way, no objects are created 
#       (private ctor).
#       There are two methods:
#         - SOCMaker::YPP::to_yaml( a_string )
#         - SOCMaker::YPP::from_yaml( a_string )
#
#       The function to_yaml replaces our custom tags (like SOCM_CORE)
#       with YAML object identifiers (like '--- ruby/object::SOCMaker::CoreDef')
#
#       The function from_yaml does the inverse to to_yaml: it replaces the 
#       object identifiers with our custom tags.
#
#       See also SOCMaker::Conf YPP_LUT YPP_INV_LUT and YPP_INV_REGEX,
#       these are the lookup tables and regular expressions used for this 
#       processing
#
#   Goal:
#     This is used to have a nicer YAML file and without the need of writing
#     loong object identifier lines.
#
#
#
#
#
###############################################################



module SOCMaker
class YPP 


  #TODO  map should work some how
  class << self


    #
    # This function does the pre-processing and 
    # replaces our custom tags with yaml-tags, like
    #   --- !ruby/object:SOCMaker:: ....
    # In addition, if a block is given, the string 
    # is separated into substrings and each sub-string is passed to
    # the block. This allows to process YAML strings, which contain multiple
    # objects. Each object is passed (as yaml string) to the block.
    #
    def to_yaml( string )
     
      SOCMaker::conf[ :YPP_LUT ].each do |r, repl|
        string = string.gsub r, repl
      end
      if block_given?
        strings = split_with_match( string, SOCMaker::conf[ :YPP_SPLIT_REGEX ] ) if string != nil
        strings.each{ |x| yield( x ) }
      end
      return string
    end



    def from_yaml( string )
      string.gsub SOCMaker::conf[ :YPP_INV_REGEX ] do |words|

         # if there is a white-space at the beginning ($1 != nil), we keep
         # the white-space, if there is no white-space we won't keep it
         ws = $1.nil? ? "" : " "
         SOCMaker::conf[ :YPP_INV_LUT ].has_key?( $2 ) ?  ws + SOCMaker::conf[ :YPP_INV_LUT ][ $2 ] : words
      end
    end

  def split_with_match(string, regex)
    indices = []
    strings = []
    return [] if string == nil or string.size == 0
    string.scan( regex ) { |c| indices << $~.offset(0)[0] }
    return [] if indices.size == 0
    indices = [ indices, indices[ 1..-1].map{ |x| x-1 } << string.size-1 ]
    indices[0].zip( indices[1] ).each{ |x| strings<< string[ x[0]..x[1] ] }
    return strings
  end


  end

  private
  def initialize
  end


end # CoreDef
end # SOCMaker

# vim: noai:ts=2:sw=2
