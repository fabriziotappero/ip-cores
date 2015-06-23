###############################################################
#   
#  File:      soc_def.rb
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
#     This class represents a System-on-chip and derives
#     the functionallity from Component.
#     The two important fields are
#       - @cores: holds all core-instances
#       - cons:   holds all connections
#     In addition, the field @static is used to store
#     static parameters, which are set for cores used in this SOC.
#
###############################################################

module SOCMaker
class SOCDef < Component
  include ERR
  include YAML_EXT

  attr_accessor :cores
  attr_accessor :cons
  attr_accessor :static
  def initialize( name, id, toplevel, optional = {} )
    
    init_with( { 'name'     => name, 
                 'id'       => id,
                 'toplevel' => toplevel }.merge( optional ) )
               
  end

  def encode_with( coder )
    super coder
    %w[ cores cons static ].
      each { |v| coder[ v ] = instance_variable_get "@#{v}" }
  end

  def init_with( coder )
    super coder
    @cores  = coder[ 'cores'  ] || {}
    @static = coder[ 'static' ] || {}
    @cons   = coder[ 'cons'   ] || {}
  end


  def consistency_check
    super
    @cores.values.each do |inst|
      inst.consistency_check
    end
  end




  # SOCMaker::logger.error( "instantiation #{inst_name} is already in use" )
  def inst_in_use?( inst_name )
       @cores[ inst_name.to_sym ] != nil or
       @cons[ inst_name.to_sym ]  != nil
  end

  def rm( inst_name )

    if @cores[ inst_name.to_sym ] != nil 
      # TODO: remove also all related connections
      @cores.delete( inst_name.to_sym )
    elsif @cons[ inst_name.to_sym ]  != nil
      @cons.delete( inst_name.to_sym )
    else
      return false
    end
    return true
  end


  def add_core( id, inst_name )
  
    return false if inst_in_use?( inst_name )
  
    # check, if the core exits in our library
    #  if not: an error will be raised
    SOCMaker::lib.get_core( id )
      
    @cores[ inst_name.to_sym ] = SOCMaker::CoreInst.new( id )
  end


  def ifc_in_use?( inst_name, ifc_name )

    # go through all connections and check,
    # that non of the interfaces we want to connect is used
    @cons.each do |_con_name, con_def|
      return true if con_def[ :mapping ][ 0 ][ inst_name.to_sym] == ifc_name.to_sym 
      return true if con_def[ :mapping ][ 1 ][ inst_name.to_sym] == ifc_name.to_sym 
    end
    return false

  end


  def port_length( ifc_name, port_name, inst )
    if @cores[ inst.to_sym ] != nil
      return @cores[ inst ].port_length( ifc_name, port_name )
    else
      return nil
    end 
  end

  def core_definition( inst )
      if @cores[ inst.to_sym ] != nil
        return @cores[ inst.to_sym ].defn
      elsif inst == @toplevel
        return self
      else
        return nil
      end
  end

  


  #def add_to_connection( inst1, ifc1_name, inst2, ifc2_name, con_name )
  def add_to_connection( *args )

    if args.size == 4
      inst1     = @toplevel
      ifc1_name = args[ 0 ]
      inst2     = args[ 1 ]
      ifc2_name = args[ 2 ]
      con_name  = args[ 3 ]
    elsif args.size == 5
      inst1     = args[ 0 ]
      ifc1_name = args[ 1 ]
      inst2     = args[ 2 ]
      ifc2_name = args[ 3 ]
      con_name  = args[ 4 ]
    else
      perr_if( true, "FATAL: wrong number of arguments (#{args.size}) for add_to_connection (3 or 4)" )
    end


    perr_if( @cons[ con_name.to_sym ]  == nil, "Connection instance #{con_name} not found" )
    @cons[ con_name.to_sym ][:mapping][0][ inst1.to_sym ] = ifc1_name.to_sym
    @cons[ con_name.to_sym ][:mapping][1][ inst2.to_sym ] = ifc2_name.to_sym
  end



  #def add_connection( inst1, ifc1_name, inst2, ifc2_name, con_name )
  def add_connection( *args )

    if args.size == 4 
      inst1     = @toplevel
      ifc1_name = args[ 0 ]
      inst2     = args[ 1 ]
      ifc2_name = args[ 2 ]
      con_name  = args[ 3 ]
    elsif args.size == 5
      inst1     = args[ 0 ]
      ifc1_name = args[ 1 ]
      inst2     = args[ 2 ]
      ifc2_name = args[ 3 ]
      con_name  = args[ 4 ]
    else
      perr_if( true, "FATAL: wrong number of arguments (#{args.size}) for add_connection (3 or 4)" )
    end

    if @cores[ con_name.to_sym ] != nil
      return nil
    elsif @cons[ con_name.to_sym ]  != nil
      return add_to_connection( inst1, ifc1_name, inst2, ifc2_name, con_name )
    end
   

    [ [ inst1, ifc1_name ], 
      [ inst2, ifc2_name ] ].each do |sub_arr|
       perr_if( ifc_in_use?( sub_arr[ 0 ], sub_arr[ 1 ] ), 
           "Interface #{sub_arr[ 1 ]} of instance '#{sub_arr[ 0 ]}' is already in use " )
    end


    core_def_1 = core_definition( inst1 )
    core_def_2 = core_definition( inst2 )
 
    perr_if( !core_def_1, "Can't find core #{inst1}" )
    perr_if( !core_def_2, "Can't find core #{inst2}" )


    [ [ core_def_1, ifc1_name ], 
      [ core_def_2, ifc2_name ] ].each do |sub_arr|
        perr_if( sub_arr[ 0 ].interfaces[ sub_arr[ 1 ].to_sym ] == nil,
          "Interface '#{sub_arr[ 1 ]}' dosn't exist in core '#{sub_arr[0].name}' \n" +
          "The following interfaces do exist:  '#{sub_arr[0].interfaces.keys}'"  )
    end
  
    # check id of the ifcs which will be connected
    perr_if( core_def_1.interfaces[ ifc1_name.to_sym ].id !=
             core_def_2.interfaces[ ifc2_name.to_sym ].id, 
          "Can't connect #{
             core_def_1.interfaces[ ifc1_name.to_sym ].id} with #{
             core_def_2.interfaces[ ifc2_name.to_sym ].id} " )
 
    @cons[ con_name.to_sym ] = { 
          :rule    => "or", 
          :mapping => [ { inst1.to_sym => ifc1_name.to_sym }, 
                        { inst2.to_sym => ifc2_name.to_sym } ] }
    return false 
  end

  def set_param( instance, param, value )

    # get instance
    core_inst = @cores[ instance.to_sym ]
    perr_if( core_inst == nil,
      "Can't find '#{instance}' in SOC" )

    # get the core-definition
    core_def = SOCMaker::lib.get_core( core_inst.type  )

    # check if parameter exist
    if core_def.inst_parameters[ param.to_sym ] != nil 
      core_inst.params[ param.to_sym ] = value
    else
      perr_if( true,
        "Parameter '#{param}' not found in '#{core_def.name}'" )
    end

  end

  def get_param( instance, param )

    # get instance
    core_inst = @cores[ instance.to_sym ]
    perr_if( core_inst == nil,
      "Can't find '#{instance}' in SOC" )
    param_val = core_inst.params[ param.to_sym ]
    perr_if( param_val == nil,
      "Can't find parameter '#{param}' in '#{instance}'" )
    return param_val
  end


  def set_sparam( core, param, value )
    
    #get instance

    # check, if we are instantiating this core
    perr_if( @cores.select{ |name,inst| inst.type == core }.size == 0,
      "Core '#{core}' is not instantiated in this SOC" )
    
    # get the core-definition
    core_def = SOCMaker::lib.get_core( core )

    # check if parameter exist
    perr_if( core_def.static_parameters.select{ |f,p| p.parameters[ param.to_sym ] != nil }.size == 0,
        "Parameter '#{param}' not found in '#{core_def.name}'" )

    @static[ core.to_sym ] ||= {}
    @static[ core.to_sym ][ param.to_sym ] = value
  end

  def get_sparam( core, param )
    perr_if( @static[ core.to_sym ] == nil,
      "Core '#{core}' does not exist in this SOC" )

    perr_if( @static[ core.to_sym ][ param.to_sym ] == nil,
      "Parameter '#{param}' does not exist for core '#{core}'" )
    
    return @static[ core.to_sym ][ param.to_sym ]
  end


  def copy_files
    
    SOCMaker::logger.proc( "START of copying all HDL files" )


    #
    # Create a unique list of cores and 
    # for every core, create a directory and copy files
    #
    @cores.values.uniq{|x| x.type }.each do |core_inst; core_def, dst_dir|

      core_def = SOCMaker::lib.get_core( core_inst.type )

      # create destination directory name and ensure, that it is exist
      dst_dir  = Component.get_and_ensure_dst_dir!( core_def.dir_name )

      # copy each file into destination dir
      core_def.hdlfiles.each do |file, val|
        file_path = File.join( core_def.dir, val.path )
        dst_path = File.join( dst_dir, val.path )
        SOCMaker::logger.proc( "copy #{file_path} to #{ dst_path} " )
        FileUtils.mkdir_p(File.dirname(dst_path))
        FileUtils.cp( file_path, dst_path )
      end


      #
      # handle the static parameters
      #   (search and replace in pakckage/include files)
      core_def.static_parameters.each do |file, sparam|
  
        token_val_map = {}
        sparam.parameters.each do |n,sparam_entry|
          
          if  @static[ core_inst.type.to_sym ]      != nil and
              @static[ core_inst.type.to_sym ][ n ] != nil
            # use value defined in soc-spec
            tmp = @static[ core_inst.type.to_sym ][ n ]
          else
            # use default value from core-spec
            tmp =  sparam_entry.default
          end

          if sparam_entry.type == "enum"
            token_val_map[ sparam_entry.token ] = sparam_entry.choice[ tmp ]
          elsif sparam_entry.type == "bool"
            if tmp == true
              token_val_map[ sparam_entry.token ] = sparam_entry.choice
            else
              token_val_map[ sparam_entry.token ] = ""
            end
          else
            token_val_map[ sparam_entry.token ] = tmp
          end


        end
 
        # create file paths
        src_path = File.join( core_def.dir, sparam.path )
        dst_dir  = Component::get_and_ensure_dst_dir!( core_def.dir_name )
        dst_path = File.join( dst_dir, sparam.file_dst )
                   
 
        # process each line of input file
        # and replace tokens by value via 
        # regular expression
        File.open( dst_path, 'w' ) do |dst_f|
          File.open( src_path ) do |src_f|
            SOCMaker::logger.proc( "create #{dst_path} from #{ src_path} " )
            while line = src_f.gets
              token_val_map.each { |token, val| line = line.sub( Regexp.new( '\b' + token.to_s + '\b' ), val.to_s ) }
              dst_f.puts line
            end
          end
        end
        


      end

    end


    SOCMaker::logger.proc( "END of copying all HDL files" )
  end



  def ==(o)
    o.class   == self.class   &&
    o.cores   == self.cores   &&
    o.cons    == self.cons    &&
    o.static  == self.static  &&
    super( o )
  end


  def to_s

    tmp = "_________ SOC #{@name}: _______\n"     + 
          super                                   +
          "\n__connections__\n"                     

    @cons.each do |_con_name, con_def|
      tmp += "#{_con_name}: #{con_def}\n"
    end 

    tmp += "\n__cores__\n" 
    @cores.each do |inst_name, inst|
      tmp += "#{inst_name}:\n#{inst}\n"
    end 
    tmp += "'''''''''''''''''''''''''''''''''''\n"
    return tmp
  end


end # class SOCSpec
end # module SOCMaker


# vim: noai:ts=2:sw=2
