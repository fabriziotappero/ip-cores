###############################################################
#   
#  File:      component.rb
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
########
#
# TODO 
#
#
###############################################################



module SOCMaker



######
#
# This class represents an abstract component.
# It is one of the central classes and holds data,
# which is used to describe a core or System-On-Chip (SOC).
# 
#
class Component 
  include ERR
  include YAML_EXT


  # name of the core  (mandatory)
  attr_accessor :name

  # ID of the core  (mandatory)
  attr_accessor :id
  
  # toplevel name (mandatory)
  attr_accessor :toplevel

  # description of this core
  attr_accessor :description
  
  # creation date
  attr_accessor :date

  # license of this core
  attr_accessor :license

  # location of the license file
  attr_accessor :licensefile

  # author of this core
  attr_accessor :author

  # author-mail of this core
  attr_accessor :authormail
 
  # a version control command, which is used to download the files
  attr_accessor :vccmd

  # interfaces which are implemented see SOCMaker::IfcSpc
  attr_accessor :interfaces

  attr_accessor :functions

  # hash of instantiation parameters see SOCMaker::Parameter
  attr_accessor :inst_parameters

  # hash of static parameters see SOCMaker::SParameter
  attr_accessor :static_parameters


  #
  # Constructor
  # The three attributes are required, and all other attributes
  # can be given as a optinal hash
  #
  # *name*:: Name of this component
  # *id*:: Id of this component
  # *toplevel*:: Toplevel name of this component
  # *optional*:: Non-mandatory values, which can be set during initialization. 
  #            
  #
  def initialize( name, id, toplevel, optional = {} )
    init_with( { 'name'      => name, 
                 'id'        => id, 
                 'toplevel'  => toplevel }.merge( optional ) )
  end   

  # 
  # Encoder function (to yaml)
  #
  # +coder+:: An instance of the Psych::Coder to encode this class to a YAML file
  #
  def encode_with( coder )
    %w[ name id description date license licensefile 
        author authormail vccmd toplevel interfaces 
        functions inst_parameters static_parameters ].
          each { |v| coder[ v ] = instance_variable_get "@#{v}" }
  end

  #
  # Initialization function (from yaml)
  #
  # +coder+:: An instance of the Psych::Coder to init this class from a YAML file
  #
  #
  def init_with( coder )

    serr_if( coder[ 'name' ] == nil, 
      'Name not defined',                
      field:    'name'    )
    @name = coder[ 'name' ]
    verr_if( !@name.is_a?( String ),
      'The name must be of type string', 
      field:    'name'         )
    serr_if( @name.size  == 0,      
      'Name not defined (size == 0)',    
      field:    'name'    )
  
    serr_if( coder[ 'id' ] == nil, 
      'Id not defined',             
      instance: @name, 
      field:    'id' )
    @id = coder[ 'id' ]
    serr_if( @id.size == 0,      
      'Id not defined (size == 0)', 
      instance: @name, 
      field:    'id' )

    verr_if( !@id.is_a?( String ),
      'The name must be of type string or numeric', 
      field:    'name'         )



    serr_if( coder[ 'toplevel' ] == nil,  
      'Toplevel not defined',
      instance: @name, 
      field:    'toplevel' )
    @toplevel = coder[ 'toplevel' ]
    verr_if( !@toplevel.is_a?( String ),
      "toplevel must be of type string",
      instance: @name, 
      field:    "toplevel" )
    serr_if( @toplevel.size  == 0,    
      'Toplevel not defined (size == 0 )',
      instance: @name, 
      field:    'toplevel' )




    # set non-nil values
    #  -> we don't need to check for nil in the rest of the 
    #     processing
    @description       = coder[ 'description'       ] || ""
    @date              = coder[ 'date'              ] || ""
    @license           = coder[ 'license'           ] || ""
    @licensefile       = coder[ 'licensefile'       ] || ""
    @author            = coder[ 'author'            ] || ""
    @authormail        = coder[ 'authormail'        ] || ""
    @vccmd             = coder[ 'vccmd'             ] || ""
    @interfaces        = coder[ 'interfaces'        ] || {}
    @functions         = coder[ 'functions'         ] || {}
    @inst_parameters   = coder[ 'inst_parameters'   ] || {}
    @static_parameters = coder[ 'static_parameters' ] || {}
  
  
    # ensure, that these fields are of type String
    %w[ description date license licensefile 
        author authormail vccmd ].each do |n|
      verr_if( !instance_variable_get( '@'+n ).is_a?( String ),
        "#{n} must be of type String", 
        instance: @name, 
        field:    n )
    end

    # ensure, that these fields are of type Hash
    %w[ interfaces inst_parameters
        functions  static_parameters ].each do |n|
      verr_if( !instance_variable_get( '@'+n ).is_a?( Hash ),
        "#{n} must be of type Hash", 
        instance: @name, 
        field:    n )
    end



    # check interfaces
    @interfaces.each do |ifc_name, ifc|
      serr_if( ifc == nil,
            'Interface not defined', 
            instance:   @name+":"+ifc_name.to_s )
  
      serr_if( !ifc.is_a?( SOCMaker::IfcDef ), 
            'Interface definition is not SOCMaker::IfcDef (please use SOCM_IFC)', 
            instance: @name+":"+ifc_name.to_s )
    end
  
    # check instance parameters
    @inst_parameters.each do |name, param |
      serr_if( param == nil,
            'Instance parameter not defined', 
            instance:   @name+":"+name.to_s )
  
      serr_if( !param.is_a?( SOCMaker::Parameter ), 
            'Instance parameter not SOCMaker::Parameter (please use SOCM_PARAM)', 
            instance: @name+":"+name.to_s )
    end
  
    # check instance parameters
    @static_parameters.each do |name, sparam |
      serr_if( sparam == nil,
            'Static parameter not defined', 
            instance:   @name+":"+name.to_s )
       
      serr_if( !sparam.is_a?( SOCMaker::SParameter ),
            'Static parameter not SOCMaker::Parameter (please use SOCM_SPARAM)', 
            instance: @name+":"+name.to_s )
    end

  end

  #
  # the directory name of this core
  #
  def dir_name
    @id.split(',').join("_")
  end



  #
  # Runs a consistency check: 
  # Iterate over all interfaces and check, if the interface is
  # in the SOCMaker::Lib.
  # The function also checks also, if the ports defined by this
  # core is also defined in the interface.
  #
  def consistency_check
    @interfaces.values.each_with_index do | ifc, i_ifc; ifc_def|
      
      # get interface definition
      ifc_def = SOCMaker::lib.get_ifc( ifc.id )


      # check, if all mandatory ports are implemented by this interface
      ifc_def.ports.each do | port_name, port |
        perr_if( port[ :mandatory ] == true &&  
                  ifc.ports.select{ |key,port_def| port_def.defn.to_sym == port_name }.size == 0,
          "Mandatory port #{port_name} is not implemented in interface #{ifc.name}" )
      end
    end

  end


  #
  # Runs the Version Control System command via system(....)
  #
  def update_vcs
    unless self.vccmd.nil? or @vccmd.size == 0
      #puts"cd #{@dir} && #{@vccmd}" 
      system( "cd #{@dir} && #{vccmd} " )
    end
  end  





  # Iterates over all generic values of this component
  # and yield the call block with
  # - generic name
  # - generic type
  # - generic default
  # - is-last value
  def generics
    @inst_parameters.each_with_index do |(name, val), i|

      _generic_name     = name.to_s
      _generic_type     = val.type
      _generic_default  = val.default
      _is_last          = i == @inst_parameters.size-1
      yield( _generic_name   , 
             _generic_type   , 
             _generic_default, 
             _is_last         )

    end
  end


  #
  # Iterates over interface list (if no argument is given)
  # or all specified interfaces.
  # For each interface, all ports are processed.
  # For each port within each interface, we lookup the port defn
  # and yield the call block with  
  # - port-name 
  # - port length
  # - default value
  # - is-last value
  # as argument
  #
  # An xor mechanism between port_dir and ifc=>dir is used
  # to determine the direction of a port, for example:
  # If the interface is declared as input (1) and a port is declared as input (1)
  # the resulting direction will be an output 1^1 = 0.
  # But if the overall interface direction is an output (0) and a port is declared 
  # as input, the resulting direction will an input 0^1 = 1.
  # This allows to define a port-direction in the interface definition, 
  # and toggle the directions on core-definition level.
  #
  #
  # *args*:: An optional list of interface names
  def ports( *args )

    if args.size == 0
      @ifc_sel = @interfaces
    else
      @ifc_sel = @interfaces.select{ |k,v| args.include?( k.to_s ) }
    end

    @ifc_sel.values.each_with_index do | ifc, i_ifc; ifc_def|
      
      # get interface definition
      ifc_def = SOCMaker::lib.get_ifc( ifc.id )

      # loop over ports in this interface 
      ifc.ports.each_with_index do |(port_name, port_def), i_port |

        # the reference to the port in the definition
        defn_ref      = port_def.defn.to_sym
        perr_if( !ifc_def.ports.has_key?( defn_ref ), 
            "Can't find #{port_def} in" + 
            "interface definition #{ifc_def.name} " + 
            "id #{ifc_def.id}" )

        _port_name    = port_name.to_s
        _port_dir     = ifc_def.ports[ defn_ref ][:dir] ^ ifc.dir
        _port_length  = port_def.len
        _port_default = ifc_def.ports[ defn_ref ][ :default  ]
        _is_last      = ( (i_port == ifc.ports.size-1 ) and (i_ifc == @ifc_sel.size-1 ) )
        yield(  _port_name, _port_dir, _port_length, _port_default, _is_last )
      end
    end
  end



  #
  # Equality operator
  #
  def ==(o)
     
    tmp    = ( o.class   == self.class )
    return tmp if !tmp

    %w[ name id description date license licensefile 
        author authormail vccmd toplevel interfaces 
        functions inst_parameters static_parameters ].
          each do |v| 
      return false if instance_variable_get( "@#{v}" ) != o.instance_variable_get( "@#{v}" )
    end
    return true
  end

  #
  # Returns a string describing this instance
  #
  def to_s
    "id:                #{@id}\n"              +
    "toplevel:          #{@toplevel}\n"             +
    "description:       #{@description}\n"          +
    "date:              #{@date}\n"                 +
    "license:           #{@license}\n"              +
    "licensefile:       #{@licensefile}\n"          +
    "author:            #{@author}\n"               +
    "authormail:        #{@authormail}\n"           +
    "vccmd:             #{@vccmd}\n"                +
    "interfaces:        #{@interfaces}\n"           +
    "functions:         #{@functions}\n"            +
    "inst_parameters:   #{@inst_parameters}\n"      +
    "static_parameters: #{@static_parameters}\n"
  end





  #
  # Creates a core directory, if it doesn't exist.
  # The path of the target directoy depends
  # on SOCMaker::conf[ :build_dir ] and
  # on SOCMaker::conf[ :hdl_dir ].
  # The resulting path is
  # ./#{SOCMaker::conf[ :build_dir ]}/#{SOCMaker::conf[ :hdl_dir ]}/dir_name
  #
  # *dir_name*:: Name of the target directory
  #
  def self.get_and_ensure_dst_dir!( dir_name )
      dst_dir =  File.expand_path(
            File.join( 
              SOCMaker::conf[ :build_dir ], 
              SOCMaker::conf[ :hdl_dir   ],
              dir_name ) )
      FileUtils.mkdir_p dst_dir
      return dst_dir
  end







end # class CoreDef
end # module SOCMaker
  

# vim: noai:ts=2:sw=2

# vim: noai:ts=2:sw=2
