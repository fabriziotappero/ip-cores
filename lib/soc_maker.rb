###############################################################
#   
#  File:      soc_maker.rb
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
#     This part of the SOCMaker module contains
#       - initialization of
#         - logger
#         - configuration
#         - library
#         (see SOCMaker::load)
#       - creating objects from YAML files/strings
#         (see from_f, from_s)
#       - creating YAML files from objects
#         (see SOCMaker::YAML_EXT::write_yaml)
#   
#
#
###############################################################
require 'logger'
require 'yaml'
require 'digest/md5'
require 'fileutils'


# from
# http://stackoverflow.com/questions/2281490/how-to-add-a-custom-log-level-to-logger-in-ruby
class Logger
  def self.custom_level(tag)
    SEV_LABEL << tag 
    idx = SEV_LABEL.size - 1 

    define_method(tag.downcase.gsub(/\W+/, '_').to_sym) do |progname, &block|
      add(idx, nil, progname, &block)
    end 
  end 
  # add processing log level
  custom_level 'PROC'
end




module SOCMaker

  
  class << self
    public
    attr_accessor :logger
    attr_accessor :conf
    attr_accessor :lib
    def load( options={} )
      options = { skip_refresh: false, logger_out: STDOUT }.merge( options )
      @conf   = Conf::instance
      @logger = Logger.new(options[ :logger_out ] )
      @lib    = Lib.new()
      @logger.progname = @conf[ :app_name ]
      @lib.refresh( options[ :libpath ] ) unless options[ :skip_refresh ]
    end

    #
    # loading from from a YAML string
    # 
    def from_s( s )
      
      objs = []
      SOCMaker::YPP.to_yaml( s ) do |yaml_obj_str|

        begin
          YAML::load( yaml_obj_str )
          o = YAML::load( yaml_obj_str )

          # ensure, that we load only our classes
          if SOCMaker::conf[ :yaml_classes ].include?( o.class )
            #o.verify
            objs << o
          else
            SOCMaker::logger.warn( "Tried to load something, which does not belong to #{SOCMaker::conf[ :app_name ]}" )
          end
        rescue ArgumentError, Psych::SyntaxError => e
          SOCMaker::logger.error( 'YAML loading failed, invalid YAML syntax?' )
          SOCMaker::logger.error( ">>> #{e.to_s} <<<" )
          raise ERR::YAMLParseError
        else
        end
      end

      if block_given?
        objs.each{ |o| yield(o) }
      end
      return ( objs.size >1 ? objs : objs[0] )
    end
    
    # Path argument can be an array of paths
    # or a file (wildcards are allowed)
    # loading from a YAML file
    def from_f( path )

      path = Dir[ path ].sort if path.is_a?( String )

      SOCMaker::logger.warn( "No file(s) found to load" ) if path.size == 0

      yaml_str = ""
      path.each do |file|
        SOCMaker::logger.info "reading:" + file
        yaml_str << File.read( file )
      end
      o = from_s( yaml_str )
      o.dir = File.dirname( path.first )
      return o
    end
    
  end


  
  #
  # small module to extend classes,
  # which need to be written as yaml 
  # output
  module YAML_EXT 

    # we remember always, were we've loaded a yaml file
    attr_accessor :dir

    def save_yaml( args )
      path =  args.size==0 ? @spec_path : args.first
      File.open( path, 'w') {|f| f.write SOCMaker::YPP.from_yaml( YAML.dump( self ) ) } 
    end
  end 






  # :stopdoc:
  LIBPATH = ::File.expand_path('..', __FILE__) + ::File::SEPARATOR
  PATH = ::File.dirname(LIBPATH) + ::File::SEPARATOR
  VERSION = ::File.read(PATH + 'version.txt').strip
  # :startdoc:

  # Returns the library path for the module. If any arguments are given,
  # they will be joined to the end of the libray path using
  # <tt>File.join</tt>.
  #
  def self.libpath( *args )
    rv =  args.empty? ? LIBPATH : ::File.join(LIBPATH, args.flatten)
    if block_given?
      begin
        $LOAD_PATH.unshift LIBPATH
        rv = yield
      ensure
        $LOAD_PATH.shift
      end
    end
    return rv
  end

  # Returns the lpath for the module. If any arguments are given,
  # they will be joined to the end of the path using
  # <tt>File.join</tt>.
  #
  def self.path( *args )
    rv = args.empty? ? PATH : ::File.join(PATH, args.flatten)
    if block_given?
      begin
        $LOAD_PATH.unshift PATH
        rv = yield
      ensure
        $LOAD_PATH.shift
      end
    end
    return rv
  end

  def self.require_all_libs
    file  = ::File.basename(__FILE__, '.*')
    dir = ::File.dirname(__FILE__)
    %w[ err         ypp         
        lib_inc     component
        core_def    core_inst 
        hdl_file    ifc_def
        ifc_port    ifc_spc
        soc_def     parameter 
        sparameter  hdl_coder
        lib  cli conf].each { |rb| require ::File.expand_path(
                  ::File.join( dir, file, rb ) )  }
  end

end  # module SOCMaker

SOCMaker.require_all_libs

# vim: noai:ts=2:sw=2
