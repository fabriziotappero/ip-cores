#!/usr/bin/env ruby
###############################################################
#   
#  File:      soc_maker_cli.rb
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
#     Command-line interface for accessing the SOC-Maker functionallity
#
#     The following commands are available:
#       - new         -> create a new soc file
#       - open        -> open soc file
#       - list        -> list library
#       - add         -> add core to soc
#       - parameter   -> set/get parameter
#       - sparameter  -> set/get static parameter
#       - connect     -> connect cores
#       - delete      -> delete core or connection
#       - save        -> save soc
#       - generate    -> generate soc
#       - quit        -> quit this CLI
#       - exit        -> same than quit
#       - help        -> print some help
#     
#     Please use the help command to get more information about
#     each command and its parameters.
#     
#     This CLI is a wrapper around SOCMaker::SOCDef.
#
#
#######
#
# TODO: add commands for
#       - selecting the coder 
#         (at the moment, only VHDL is supported)
#       
#       - refreshing the lib
#
#
###############################################################
require 'readline'
require 'optparse'


module SOCMaker
class Cli

  private_class_method :new
  def Cli.instance
      @@inst = new if @@inst == nil
      return @@inst
  end

  FMSG      = ' -> failed '



  #########################################
  #
  # command implementations:
  #   -> a usage string and
  #      a function for every command
  #

  #
  # New
  #
  NEW_USAGE = 
  "  > new <<name>> <<id>> <<toplevel>>   # opens a system-on-chip file
         - <<name>>     : the SOC name
         - <<id>>       : the SOC id
         - <<toplevel>> : the toplevel name
  "
  def do_new( args )
    if args.size != 3
      puts "three arguments are required:\nusage:\n#{NEW_USAGE}"
    else
      @soc = SOCMaker::SOCDef.new( args[0], args[1], args[2] ) 
      SOCMaker::lib.add_core( @soc )
      @soc_inst = SOCMaker::CoreInst.new( "#{args[0]}#{args[1]}" )
      #puts FMSG if @soc.load_soc( args[ 0 ] ) == nil
    end
  end



  #
  # Open
  #
  OPEN_USAGE =
  "  > open <<file>>    # opens a system-on-chip file
         - <<file>>    : system-on-chip definition in in YAML format

  "
  def do_open( args )
    if args.size != 1
      puts "only one argument is required:\nusage:\n#{OPEN_USAGE}"
    else
      puts "loading #{args[0]}"
      @soc = SOCMaker::from_f( args[0] ) 
      SOCMaker::lib.add_core( @soc )
      @soc_inst = SOCMaker::CoreInst.new( "#{@soc.version.to_s}" )
      #puts FMSG if @soc.load_soc( args[ 0 ] ) == nil
    end
  end


  #
  # List
  #
  LIST_USAGE = 
  "  > list             # prints list of cores and interfaces,
                          which are in the library

  "
  def do_list( args )
    puts SOCMaker::lib
  end


  #
  # Add
  #
  ADD_USAGE = 
  "  > add <<id>> <<name>>    
                        # adds an ip-core from the library to the SOC
        - <<id>>      : id of the IP core
        - <<name>>    : instanciation name

  "
  def do_add( args )
    if args.size != 2
      puts "two arguments are required:\nusage:\n#{ADD_USAGE}"
    else
      puts FMSG if @soc.add_core( args[ 0 ], args[ 1 ] ) == nil
    end
  end


  #
  # Set/Get Parameter
  #
  PARAMETER_USAGE = 
  "  > prameter <<instance>> <<parameter>> <<value>>
                        # modifies a parameter of an instance
       - <<instance>>   : the instance name of the core
       - <<parameter>>  : the instance parameter name 
       - <<value>>      : the value which is set (optional). The current 
                          value is printed, if omitted
  "
  def do_parameter( args )
    if args.size == 2 
      puts FMSG if @soc.get_param( args[ 0 ], args[ 1 ] ) == nil
    elsif args.size == 3
      puts FMSG if @soc.set_param( args[ 0 ], args[ 1 ], args[ 2 ] ) == nil
    else
      puts "two or three arguments required:\nusage:\n#{PARAMETER_USAGE}"
    end
  end


  #
  # Set/Get Static Parameter
  #
  SPARAMETER_USAGE = 
  "  > sprameter <<core>> <<parameter>> <<value>>
                        # modifies the static parameter of a core
       - <<core>>       : the name of the core
       - <<parameter>>  : the static parameter name 
       - <<value>>      : the value which is set (optional). The current 
                          value is printed, if omitted
  "
  def do_sparameter( args )
    if args.size == 2 
      puts FMSG if @soc.get_sparam( args[ 0 ], args[ 1 ] ) == nil
    elsif args.size == 3
      puts FMSG if @soc.set_sparam( args[ 0 ], args[ 1 ], args[ 2 ] ) == nil
    else
      puts "two or three arguments required:\nusage:\n#{SPARAMETER_USAGE}"
    end
  end


  #
  # Connect
  #
  CONNECT_USAGE = 
  "  > connect <<core1>> <<ifc1>> <<core2>> <<ifc2>> <<name>>
                        # connects two cores
        - <<core1>>     : instance name of the first core
        - <<core2>>     : instance name of the second core
        - <<ifc1>>      : interface name of the first core
        - <<ifc2>>      : interface name of the second core
        - <<name>>      : connection name

  "      
  def do_connect( args )
    if args.size != 5
      puts "five arguments are required:\nusage:\n#{CONNECT_USAGE}"
    else
      puts FMSG if @soc.add_connection( args[ 0 ], args[ 1 ], args[ 2 ], args[ 3 ], args[ 4 ] )
    end
  end


  #
  # Delete
  #
  DELETE_USAGE = 
  "  > delete <<core/connection>>
                        # removes a core or a connection
        - <<core/conection> : the core or connection, which is removed

  "
  def do_delete( args )
    if args.size != 1 
      puts "five arguments are required:\nusage:\n#{DELETE_USAGE}"
    else
      puts FMSG if @soc.rm( args[ 0 ] ) == nil
    end
  end


  #
  # Save
  #
  SAVE_USAGE = 
  "  > save <<file>>    # saves system-on-chip definition in YAML format to file
        - <<file>>     : optional destination file, when omitted: the 
                         original file-path is used
                         
  "
  def do_save( args )
    if args.size > 1
      puts "zero or one argument is required:\nusage:\n#{SAVE_USAGE}"
    else
      p args
      puts FMSG if @soc.save_yaml( args ) == nil
    end
  end


  #
  # Generate
  #
  GENERATE_USAGE = 
  "  > generate         # generates a synthesizable system-on-chip implementation

  "
  def do_generate( args )
    if args.size != 0
      puts "no arguments are required:\nusage:\n#{GENERATE_USAGE}"
    else
      @soc_inst.gen_toplevel
      @soc.copy_files
    end
  end



  PRINT_USAGE = 
  "  > print            # prints SOC information

  "
  def do_print( args )
    if args.size != 0
      puts "no arguments are required:\nusage:\n#{PRINT_USAGE}"
    else
      puts @soc
    end
  end


  #
  # Quit
  #
  QUIT_USAGE = 
  "  > quit             # the same than exit

  "
  def do_quit( args )
    do_exit( args )
  end


  #
  # Exit
  #
  EXIT_USAGE = 
  "  > exit             # exits this tool

  "
  def do_exit( args )
    puts "... bye bye!"
    exit 0
  end


  #
  # Help
  #
  HELP_USAGE = 
  "  > help             # prints some help information

  "
  def do_help( args )
    puts "The following commands are available:\n\n"
    @commands.each { |c| eval "puts  #{c.upcase}_USAGE" }
  end


  SET_USAGE = 
  "  > set              # not implemented yet

  "
  def do_set( args )
    puts "NOT IMPLEMENTED, YET"
  end

  GET_USAGE = 
  "  > get              # not implemented yet

  "
  def do_get( args )
    puts "NOT IMPLEMENTED, YET"
  end

  #  end command implementations
  #
  #################################



  @soc      = nil
  @soc_inst = nil

  def initialize
   
    # appreviation map
    @appr_map = { 'n' => "new",
                  'o' => "open",
                  'q' => "quit",
                  'h' => "help",
                  'l' => "list", 
                  'a' => "add",
                  'g' => "generate",
                  's' => "save",
                  'p' => "parameter",
                  'd' => "delete",
                  'c' => "connect",
                  'i' => "print",
                  'x' => "exit"
                  }
   
    # all available commands
    @commands = %w[ new open list add parameter sparameter  
                    delete connect save help quit exit 
                    generate print set get ]

    comp = proc { |s| (@commands + Dir.entries( Dir.pwd )).grep( /^#{Regexp.escape(s)}/ ) }
    Readline.completion_append_character = " "
    Readline.completion_proc = comp

  end

  def run

    ##
    # process user commands
    #
    while buf = Readline.readline( "> ", true )
      process_cmd buf
    end
  end

  def process_cmd( c )

      # remove the comments and split each line
      match = SOCMaker::conf[ :COMMENT_REGEX ].match( c )
      cmd_arr = match[1].split( ' ' )

      # process the command, if there is one
      if cmd_arr.size > 0 
        cmd     = ""
        if cmd_arr[ 0 ].size == 1 and @appr_map[ cmd_arr[ 0 ] ] != nil
          cmd = @appr_map[ cmd_arr[ 0 ] ] 
        else
          cmd = cmd_arr[ 0 ] 
        end

        if @commands.include?( cmd )
          cmd_str = "do_#{cmd}( cmd_arr[ 1..-1] )"  
          puts "evaluating >>#{cmd_str}<< "
          eval( cmd_str ) 
        #TODO this is for linux only
        elsif system( "which #{cmd} > /dev/null 2>&1" )
          system( c )
        else
          puts "Command #{cmd} not available"
        end
       #begin
       #rescue 
       #  puts "evaluating >>#{cmd_str}<< failed"
       #end
      end
  end

  @@inst = nil 


end
end


# vim: noai:ts=2:sw=2

