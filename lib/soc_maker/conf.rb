###############################################################
#   
#  File:      conf.rb
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
#     This class holds all the configuration and is 
#     realized as singleton.
#     The instance can be accessed via Conf::instance
#     The configuration is splitted into two parts:
#       @data     -> user-configurable 
#       @data_ro  -> read-only
#
#
#
######
#
# TODO
#     - functionallity to modify @data
#
###############################################################


module SOCMaker
class Conf
  include YAML_EXT 
  include ERR

  private_class_method :new
  def Conf.instance
      @@inst = new if @@inst == nil
      return @@inst
  end
    
  def initialize( optional = {} )

  
      init_with( optional.merge( { 'data' => {
        # the name of this application/tool
        :app_name         => 'SOC-Maker',

        # the name of the tool's commandline interface
        :app_cli_name     => 'SOC-Maker CLI',

        # array of core search paths
        :cores_search_path => [ './' ],

        # VHDL include directive
        :vhdl_include     => "library ieee;\nuse ieee.std_logic_1164.ALL;",

        # build directory, where the whole synthese and build process 
        # happens
        :build_dir        =>  'build',

        # the folder inside build_dir, where all the vhdl source is placed
        :hdl_dir          =>  'hdl',
        
        # synthesis directory inside build_dir
        :syn_dir          =>  'syn',

        # simulation directory inside build_dir
        :sim_dir          =>  'sim'
      
        } } ) )
  end
  def encoder_with( coder )
    coder[ 'data' ] = @data
  end
  def init_with( coder )

    serr_if( coder[ 'data' ] == nil,
      "No configuration data provided",
      field: 'data' )
    @data = coder[ 'data' ]

    %w[ app_name vhdl_include 
        build_dir hdl_dir
        syn_dir sim_dir ].each do |d|
      serr_if( @data[ d.to_sym ] == nil,
        "Data field '#{d}' is not provided",
        field: 'data' )

      verr_if( !@data[ d.to_sym ].is_a?( String ), 
        "Data field '#{d}' is not of type String",
        field: 'data' )

      verr_if( @data[ d.to_sym ].size == 0, 
        "Data field '#{d}' is not of type String",
        field: 'data' )
    end
  

    @data_ro = { 

      :yaml_classes     => [  SOCMaker::CoreDef, 
                              SOCMaker::SOCDef, 
                              SOCMaker::IfcSpc, 
                              SOCMaker::LibInc, 
                              SOCMaker::Conf, 
                              SOCMaker::CoreInst ],

      # Regular expression, which is evaluatted to detect values like
      #    eval function_name
      # The function_name is used for further processing
      :eval_regex       =>  /eval +([a-zA-Z_1-9]+)/,

      # Regular expression to check, if it is VHDL or verilog
      :hdl_type_regex   => /(\bvhdl\b)|(\bverilog\b)/,

      #
      # Regular expression for vhdl file detection 
      #
      :vhdl_file_regex    =>  /\A\S+\.vhd\Z/,

      #
      # Regular expression for verilog file detection
      #
      :verilog_file_regex =>  /\A\S+\.v\Z/,

      
      #
      # Regular expression to match names starting with non-number
      #
      :length_regex     =>  /\A[^0-9]+.*\Z/,

      #
      # Regular expression to match a component's name (core-name or SOC-name)
      # (Obsolete)
      #
      :name_regex       =>  /^[a-zA-Z]+[a-zA-Z0-9_\-]*$/,


      :YPP_LUT          => {
                /\bSOCM_CONF\b/     =>  '--- !ruby/object:SOCMaker::Conf',
                /\bSOCM_CORE\b/     =>  '--- !ruby/object:SOCMaker::CoreDef',
                /\bSOCM_SOC\b/      =>  '--- !ruby/object:SOCMaker::SOCDef',
                /\bSOCM_IFC_SPC\b/  =>  '--- !ruby/object:SOCMaker::IfcSpc',
                /\bSOCM_INCLUDE\b/  =>  '--- !ruby/object:SOCMaker::LibInc',
                /\bSOCM_INST\b/     =>  '!ruby/object:SOCMaker::CoreInst',
                /\bSOCM_IFC\b/      =>  '!ruby/object:SOCMaker::IfcDef',
                /\bSOCM_PORT\b/     =>  '!ruby/object:SOCMaker::IfcPort',
                /\bSOCM_HDL_FILE\b/ =>  '!ruby/object:SOCMaker::HDLFile',
                /\bSOCM_PARAM\b/    =>  '!ruby/object:SOCMaker::Parameter',
                /\bSOCM_SPARAM\b/   =>  '!ruby/object:SOCMaker::SParameter',
                /\bSOCM_SENTRY\b/   =>  '!ruby/object:SOCMaker::SParameterEntry'
              },
      #
      # $1 provides the white spaces
      # $2 the name
      #
      :YPP_INV_REGEX      => /(\s)*-{0,3}\s*!ruby\/object:SOCMaker::([a-zA-Z]+)/,  

      :YPP_INV_LUT        => {
                'Conf'            => 'SOCM_CONF',
                'CoreDef'         => 'SOCM_CORE',
                'SOCDef'          => 'SOCM_SOC',
                'CoreInst'        => 'SOCM_INST',
                'IfcSpc'          => 'SOCM_IFC_SPC',
                'IfcDef'          => 'SOCM_IFC',
                'IfcPort'         => 'SOCM_PORT',
                'HDLFile'         => 'SOCM_HDL_FILE',
                'Parameter'       => 'SOCM_PARAM',
                'SParameter'      => 'SOCM_SPARAM',
                'SParameterEntry' => 'SOCM_SENTRY',
                'LibInc'          => 'SOCM_INCLUDE'
              },

      # used to split yaml files 
      #
      :YPP_SPLIT_REGEX    => /^\s*---\s*!ruby\/(object|object):SOCMaker/,


      :COMMENT_REGEX      => /([^#]*)(#.*)?/,

      :EMPTY_CMD_REGEX    => /(\s*)(.*)/,

      :LIC =>        
"""
Copyright (C) 2014  Christian Haettich  - feddischson [ at ] opencores.org

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
"""


    }
  end

  def [](y)
    @data.merge( @data_ro )[y]
  end

  def []=(y, value)
    @data[y] = value
  end
  @@inst = nil 


end

end 


# vim: noai:ts=2:sw=2
