###############################################################
#   
#  File:      core_inst.rb
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


module SOCMaker

######
#
# This class represents a core instantiation within
# a SOC. It contains a parameter-hash (@params),
# which is used to define, which parameters are set to which values.
# The type field is used to identify the SOCMaker::CoreDef
# and the field @defn is initialized as reference to 
# the corresponding CoreDef instance.
class CoreInst
  include ERR
 


  attr_accessor :defn
  attr_accessor :type
  attr_accessor :params 

  #
  # Constructor
  # There is one mandatory attributes and an optional one.
  #
  # *type*::    The id of the core-definition, which is instanciated
  # *params*::  Instanciation parameters
  #
  def initialize(  type, params = {} )
    init_with(  'type'   => type,
                'params' => params  )

  end

  # 
  # Encoder function (to yaml)
  #
  # +coder+:: An instance of the Psych::Coder to encode this class to a YAML file
  #
  def encode_with( coder )
    %w[ type params ].
      each { |v| coder[ v ] = instance_variable_get "@#{v}" }
  end

  #
  # Initialization function (from yaml)
  #
  # +coder+:: An instance of the Psych::Coder to init this class from a YAML file
  #
  #
  def init_with( coder )

    serr_if( coder[ 'type' ] == nil,
      "no type is provided for a core instance",
      field: "type" )

    @type = coder[ 'type' ]

    @params = coder[ 'params' ] || {} 
    serr_if( !@params.is_a?( Hash ), 'Parameters are not given as hash',
      field: 'params' )

  end




  #
  # Runs a consistency check and creates an internal 
  # hash, which contains all evaluated ports.
  # Because the core-definition may contain variable port sizes, 
  # which depend on the instance, these sizes need to be evaluated.
  # This is also done here and the result is stored in @_ifcs_evaluated.
  #
  #
  def consistency_check

    @defn = SOCMaker::lib.get_core( @type )
    
    
    # check, if the instance parameters in the core definition
    @params.each do |param_name, value|
      verr_if(  @defn.inst_parameters[ param_name ] == nil, 
                "Parameter not found: " + param_name.to_s, 
        field: 'params' )
    end

    ## auto-complete parameters with default values
    @defn.inst_parameters.each do |param_name, param|
    
      # auto-complete to default values
      @params[ param_name ] ||= param.default
    end

    @_ifcs_evaluated ||= {}
    @defn.interfaces.keys.each do |ifc_name|
      @_ifcs_evaluated[ ifc_name ] = {}
      @defn.ports( ifc_name.to_s ) do |port_name, port_dir, port_len, default, is_last |
        if port_len.is_a?( String )
          param_match = SOCMaker::conf[ :length_regex ].match( port_len ) 
          
          if param_match and @params[ port_len.to_sym ] != nil
            tmp =@params[ port_len.to_sym ]
            tmp = tmp.to_i if tmp.is_a?( String )
            @_ifcs_evaluated[ ifc_name ][ port_name.to_sym ] = { len: tmp, dir: port_dir, default: default }
          else
            SOCMaker::logger.error( "Failed to evaluate #{port_len} for port #{port_name}" )
          end
        else 
          @_ifcs_evaluated[ ifc_name ][ port_name.to_sym ] = { len: port_len, dir: port_dir, default: default }
        end 
      end
    end
 
    @defn.consistency_check
  end    




  #
  # Generate toplevel hdl file for this instance.
  # This assumes, that this instance represents a SOC with
  # further instances.
  #
  #
  # +coder+:: An instance of the SOCMaker::HDLCoder, which is used to 
  #           create the auto-generated HDL (optional).
  #           If no coder is given, a SOCMaker::VHDLCoder is used.
  #
  #
  def gen_toplevel( coder = VHDLCoder.new )


    #
    # Get filename
    #
    file_name = coder.filename( @defn.dir_name )

    SOCMaker::logger.proc( "START of creating top-level '" + file_name + "'" )


    #
    # Create a unique list of cores and 
    # add for each core a component statement (vhdl only).
    # Even if there are multiple instances of a core,
    # we need to decalre it only once
    #
    @defn.cores.values.uniq{|x| x.type }.each do |inst; spec|
 
      spec = SOCMaker::lib.get_core( inst.type  )
      SOCMaker::lib.check_nil( spec, "Can't find #{ inst.type } in SOC library" )
 
      coder.add_core_component( inst.type, spec )
    end

    #
    # Instanciate each core
    #
    @defn.cores.each do |inst_name, inst|
      coder.add_core_instance( inst_name.to_s, inst )
    end


    # Iterate over all connections:
    #  - create signal instances
    #  - add assignments
    #
    @defn.cons.each do |con_name, con_def|
      gen_toplevel_con(   con_name.to_s, 
                          con_def[ :rule ], 
                          con_def[ :mapping ][0], 
                          con_def[ :mapping ][1],
                          coder  )
 
    end
 
    assign_unused_to_default( coder )

    # 
    # Write content to the file
    #
    SOCMaker::logger.proc( "writing top-level" )
    file_dir  = File.join( SOCMaker::conf[ :build_dir ], 
                           SOCMaker::conf[ :hdl_dir   ] ) 
    ::FileUtils.mkdir_p file_dir
    File.open( File.join( file_dir, file_name ), 'w' ) do |f| 
      f.write( coder.get_hdl_code( self, @defn.toplevel ) )
    end
    SOCMaker::logger.proc( "END of creating top-level hdl code for #{@defn.name}" )

  end



  #
  # Iterate over all ports and call the block with
  #   - port-name 
  #   - port length
  #   - default value
  #   - is-last value
  #
  #  If no argument is given, all ports of this instance are processed.
  #  If arguments are given, each argument is supposed to the name of
  #  a interface. All specified interfaces with all ports are processed.
  #
  # +args+::  Optional list of interface names
  #   
  #
  def ports( *args )

    if args.size == 0
      ifc_sel = @_ifcs_evaluated
    else
      ifc_sel = @_ifcs_evaluated.select{ |k,v| args.include?( k.to_s ) }
    end

    ifc_sel.values.each_with_index do |ifc, i_ifc|
      ifc.each_with_index do |(port_name, port_def), i_port|
        yield(  port_name.to_s, 
                port_def[ :dir ], 
                port_def[ :len ], 
                port_def[ :default ], 
                i_port==ifc.size-1 && i_ifc == ifc_sel.size-1 )
      end
    end
  end

  #
  # Iterate over all generics and call the block with
  #   - generic-name
  #   - generic-type
  #   - the value
  #   - is-last information
  #
  def generics
    @defn.generics do |name, type, default_value, is_last|
      value = @params[ name.to_sym ];
      value = value
      value = default_value if value == nil
      yield( name.to_s, type, value, is_last )
    end
  end







  #
  # Returns a port, identified by the interface and port name
  # 
  #  +ifc_name+::       name of the interface
  #  +port_spec_name+:: name of the port
  # 
  def port( ifc_name, port_spec_name )
    tmp = @defn.interfaces[ ifc_name.to_sym ].
        ports.select{ |key,hash| hash.defn == port_spec_name.to_s }.
        keys.first.to_s
    return [ tmp, @_ifcs_evaluated[ ifc_name.to_sym ][ tmp.to_sym ] ]
  end

  #
  # Returns the length of a port within an interface.
  # If no instance is given, we know that it is 
  # a toplevel interface. 
  # Otherwise we check for this and we do a recursive call.
  # If this port is within a interface of a core, we 
  # pass the call to the core-definition of this instance, which
  # knows all cores.
  #
  # +ifc_name+::        name of the interface
  # +port_spec_name+::  name of the port
  # +inst+::            name of the instance (optional), default is nil
  #
  def port_length( ifc_name, port_spec_name, inst = nil )
    if inst == nil
      tmp = @defn.interfaces[ ifc_name.to_sym ].
          ports.select{ |key,hash| hash.defn == port_spec_name.to_s }.
          keys.first.to_s
      return tmp.size == 0 ? 0 : @_ifcs_evaluated[ ifc_name.to_sym ][ tmp.to_sym ][ :len ]
    else
      if inst == @defn.toplevel.to_sym
        return port_length( ifc_name, port_spec_name )
      else
        return @defn.port_length( ifc_name, port_spec_name, inst )
      end
    end
  end

  #
  # Returns the core definition for an instance (identified by its name)
  # 
  # +inst+:: name of the instance
  #
  def core_definition( inst )
      if inst == @defn.name 
        return @defn
      else
        tmp = @defn.core_definition( inst )
        perr_if( tmp == nil, "#Processing error: {inst} not found by core_definition" )
        return tmp
      end
  end

  #
  # Returns a core instance, identified by its name.
  # If it is not a sub-core, we return our self 
  #
  # +inst+::  name of the instance
  #
  def core_instance( inst )
    if @defn.cores[ inst ] != nil
      return @defn.cores[ inst ]
    else
      return self
    end
  end






  #
  # Returns a string describing this instance
  #
  def to_s
    "type:     #{type}\n"   +
    "params:   #{params}\n" 
  end

  #
  # Equality operator
  #
  def ==(o)
    o.class     == self.class   && 
    o.type      == self.type    &&
    o.params    == self.params
  end






  #
  # Assign default values for unused interfaces.
  # This is just a helper function and is used by gen_toplevel
  #
  # +coder+:: A HDL coder, which is used to create the auto-generated HDL.
  #
  def assign_unused_to_default( coder )
    


    # iterate over all instances
    # and check all interfaces
    @defn.cores.each do |inst_name, inst|

      inst.defn.interfaces.each do |ifc_name, ifc|
         
        #
        # Get the interface specification by using the 1st source entry
        # and searching for the core-definition.
        # 
        if !@defn.ifc_in_use?( inst_name, ifc_name )
          coder.add_ifc_default_assignment(  inst, inst_name, ifc_name )
        end
      end
    end
  end

  #
  # This function is called during the toplevel generation
  # for each connection.
  #  
  # +name+::   The name of the connection
  # +rule+::   The combination rule (obsolete/unused)
  # +src+::    Source hash with instance name as key and interface name as value
  # +dst+::    Destination hash with instance name as key and interface name as value
  # +coder+::  The HDL coder which is used
  #
  def gen_toplevel_con( name, rule, src, dst, coder )

    src_inst            = {};
    dst_inst            = {};

    #
    # Get the interface specification by using the 1st source entry
    # and searching for the core-definition.
    # 
    ifc_spec = SOCMaker::lib.get_ifc( 
      core_definition( src.keys.first.to_s ).interfaces[ src.values.first ].id )
 

    #
    # Get the maximum required signal length 
    #
    # For each signal in the interface specification, 
    # we create a list. The list has an entry for each source 
    # and destination signal, which defines the length.
    #
    # In the second step, the maximum in each list is extracted.
    #
    length_tmp  = {};
    ifc_spec.ports.keys.each do |_name|
      length_tmp[ _name ] = []
      dst.each do |inst_name, ifc_name|
        length_tmp[ _name ] << port_length( ifc_name, _name, inst_name )
      end 
      src.each do |inst_name, ifc_name|
        length_tmp[ _name ] << port_length( ifc_name, _name, inst_name )
      end 
    end
    max_length = Hash[ length_tmp.map{ |key, arr| [ key, arr.max ] } ]


    #
    # Prepare a hash for all sources and destinations, where
    # the instance name is the key and the core-instance is 
    # the value.
    #
    src.keys.each do |inst_name|
      src_inst[ inst_name ] = core_instance( inst_name )
    end
    dst.keys.each do |inst_name|
      dst_inst[ inst_name ] = core_instance( inst_name )
    end

    #
    # create the declaraion and assignments
    #
    coder.add_ifc_connection( ifc_spec, name, max_length, src_inst, dst_inst, src, dst )

  end










  private :assign_unused_to_default, :gen_toplevel_con



end # CoreInst
end # SOCMaker



# vim: noai:ts=2:sw=2
