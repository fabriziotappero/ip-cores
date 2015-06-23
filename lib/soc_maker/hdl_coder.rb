###############################################################
#   
#  File:      hdl_coder.rb
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
#     This file contains two HDL-coders:
#      - VHDLCoder
#      - VerilogCoder (not implemented, yet)
#
#
#
###############################################################

module SOCMaker
class HDLCoder

  def initialize
    @decl_part  = "";   # declaration
    @asgn_part  = "";   # assignment
    @inst_part  = "";   # instantiation

    

  end


end


class VerilogCoder < HDLCoder
  #TODO
  #
  #
 
  def filename( name )
    return name + ".v"
  end

end


class VHDLCoder < HDLCoder




  #
  # Add a component declaration to the declaration-string @decl_part
  # This for example looks like
  # component <<name>> is
  #  generic(
  #    g1 : ...
  #    g2 : ...
  #    ...
  #    );
  #  port(
  #    p1 : ...
  #    p2 : ...
  #    p3 : ... 
  #    ...
  #    )
  #  end component <<name>>;
  #
  # In addition, we add some VHDL comments (author, mail, license)
  #
  def add_core_component( core_name, core_spec )
    
    @decl_part << "--\n"
    @decl_part << "-- core author: #{core_spec.author} - #{core_spec.authormail}\n"
    @decl_part << "-- license: #{core_spec.license}\n"
    @decl_part << "--\n"
    @decl_part << "component #{core_spec.toplevel} is\n"
    generic_str = entity_generic_str( core_spec );
    @decl_part << "generic ( #{ generic_str  });\n" if generic_str.size > 0
    @decl_part << "port( \n" << entity_port_str( core_spec ) <<" );\n"
    @decl_part << "end component #{core_spec.toplevel};\n"
    #entity_generic_str( core_spec )
  end

  def filename( name )
    return name + ".vhd"
  end


  def entity_generic_str( core )

    generic_str = ""
    core.generics do |gen_name, gen_type, gen_val, is_last|
      generic_str     << gen_name << " : " << gen_type << " := " << gen_val.to_s
      generic_str     << ";" unless is_last
      generic_str     << "\n"
    end
    return generic_str
  end


  #
  # Create a string, which lists all signals of 'core'
  # We iterate over all interface:
  # For each interface, we iterate over all ports:
  # For each port, we lookup the definition in the 'soc_lib' and 
  # add the VHDL code according to the definition as string to 
  # port_string
  #
  def entity_port_str( core )
    port_string = ""

    core.ports do |port_name, port_dir, port_len, port_default, is_last |
       
      # The string we are add in every iteration looks for example like
      #    myportname1 :  out std_logic_vector( 6-1 downto 0 )
      #    or
      #    myportname2 :  in  std_logic
      #
      port_string << port_name.to_s << " : "



      # port direction
      if    port_dir == 2
        port_string << " inout "
      elsif port_dir == 1
        port_string << " in "
      else
        port_string << " out "
      end
      
      # port type / length
      if(   port_len.is_a?( String ) || 
          ( port_len.is_a?( Fixnum ) && port_len > 1 )
        )
        port_string << " std_logic_vector( #{port_len}-1 downto 0 ) " 
      elsif ( port_len.is_a?( Fixnum ) && port_len == 1 )
        port_string << " std_logic "
      else
        puts "FAILED " + port_len.to_s #TODO
      end

      # end of the line
      port_string << ";" unless is_last
      port_string << "\n"
    end
    return port_string
  end


  def add_core_instance( inst_name, inst )

    @inst_part << inst_name << " : " << inst.defn.toplevel << "\n"
    generic_str = ""
    inst.generics do |generic, type, value, is_last|
      generic_str << "#{generic} => #{value}"
      generic_str << "," unless is_last
      generic_str << "\n"
    end
    @inst_part << "generic map( \n#{generic_str} )\n" if generic_str.size > 0
    port_str = ""
    inst.ports do |port_name, dir, length, default, is_last|
      port_str << "#{port_name} => #{inst_name}_#{port_name}"
      port_str << "," unless is_last
      port_str << "\n"
      if length > 1
        @decl_part << "signal #{inst_name}_#{port_name} : std_logic_vector( #{length}-1 downto 0 );\n"
      else
        @decl_part << "signal #{inst_name}_#{port_name} : std_logic;\n"
      end
    end
    @inst_part << "port map( \n#{port_str} );\n\n\n" if port_str.size > 0
    
  end

  def add_ifc_default_assignment( inst, inst_name, ifc_name )


    tmp = ""
    inst.ports( ifc_name.to_s ) do |port_name, dir, length, default_val, is_last|
      if dir == 1 # assign default value only if it is an input
        if length > 1
          tmp << "#{inst_name}_#{port_name} <= ( others => '#{default_val}' );\n"
        else
          tmp << "#{inst_name}_#{port_name} <= '#{default_val}';\n"
        end
      end
    end
   @asgn_part << tmp  

  end
  
  def add_ifc_connection( ifc_spec, ifc_name, length, src_inst, dst_inst, src_ifc, dst_ifc )

    ###
    #
    # declaration
    #
    #
    ifc_spec.ports.each do |port_name, port|
      @decl_part << "signal #{ifc_name}_#{port_name.to_s} : " 
      if length[ port_name ] > 1
        @decl_part << " std_logic_vector( #{length[ port_name ]}-1 downto 0 ) " 
      else
        @decl_part << " std_logic "
      end
      # end of the line
      @decl_part << ";\n" 
    end


    ###
    #
    # assignment
    #
    #
    ifc_spec.ports.each do |port_name, port_setup|


      if port_setup[ :dir ] == 0
        src_inst_sel = src_inst
        dst_inst_sel = dst_inst
        src_ifc_sel  = src_ifc
        dst_ifc_sel  = dst_ifc
      else
        src_inst_sel = dst_inst
        dst_inst_sel = src_inst
        src_ifc_sel  = dst_ifc
        dst_ifc_sel  = src_ifc
      end


      # length == 0 means, that no
      # signal is assigned to this connection
      if length[ port_name ] > 0

        port_tmp_name = "#{ifc_name}_#{port_name.to_s}"


        # combine all sources
        tmp = "#{port_tmp_name} <= "
        # loop over instances
        src_inst_sel.each_with_index do |(inst_name, inst), i|
          ( tmp_name, port) = inst.port( src_ifc_sel[ inst_name ], port_name )
          if port != nil
            if port[ :len ] < length[ port_name ]
              tmp << "\"" + "0" * ( length[ port_name ] - port[ :len ] ) + "\" & "   
            end
            tmp << "#{inst_name}_#{tmp_name}" 
            tmp << " and \n" unless i == src_inst_sel.size-1
          else
            if length[ port_name ] > 1
              tmp << "( others => '0' )"
            else
              tmp << "'0'"
            end
          end
        end
        tmp << ";\n"
        @asgn_part << tmp

        tmp = ""
        assigned = false
        # assign to destination
        dst_inst_sel.each_with_index do |(inst_name, inst), i|
          if not inst == nil  #TODO
            ( tmp_name, port) = inst.port( dst_ifc_sel[ inst_name ], port_name )
            if port != nil
              tmp << "#{inst_name}_#{tmp_name} <= #{port_tmp_name}"
              tmp << "( #{port[ :len ]}-1 downto 0 )" if port[ :len ] > 1
              tmp << ";\n"
              assigned = true
            end
          end
        end
        @asgn_part << tmp if assigned 
        puts "NOT ASSIGNED DST" if not assigned
      else
      #  puts "ifc #{ifc_name} port #{port_name.to_s} is not assigned"
      #  p src_ifc
      #  p dst_ifc
      #  tmp = ""
      #  dst_inst_sel.each_with_index do |(inst_name, inst), i|
      #    p inst_name 
      #    p port_name
      #    ( tmp_name, port) = inst.port( dst_ifc_sel[ inst_name ], port_name )
      #    tmp << "#{inst_name}_#{tmp_name} <= ( others => 'X' );\n"
      #  end
      #  @asgn_part << tmp;
      end

    end
  end
    


  def get_hdl_code( soc, entity_name )
    add_toplevel_sig( soc, entity_name )
    entity_str = SOCMaker::conf[ :LIC ].split(/\n/).map{ |s| "-- "+s }.join("\n") + "\n"
    entity_str << "-- Auto-Generated by #{SOCMaker::conf[ :app_name ]} \n"
    entity_str << "-- Date: #{Time.now}\n"
    entity_str << SOCMaker::conf[ :vhdl_include ] + "\n"
    entity_str << "entity #{entity_name} is \n"
    tmp = entity_port_str( soc ) 
    entity_str << "port( \n" << tmp << " );\n" if tmp.size > 0
    entity_str << "end entity #{entity_name};\n\n\n"
    entity_str << "ARCHITECTURE IMPL of #{entity_name} is \n"
    entity_str << @decl_part
    entity_str << "\n\n"
    entity_str << "begin"
    entity_str << "\n\n"
    entity_str << "--"
    entity_str << "-- assignments "
    entity_str << "--"
    entity_str << "\n\n"
    entity_str << @asgn_part
    entity_str << "\n\n"
    entity_str << "--"
    entity_str << "-- instances "
    entity_str << "--"
    entity_str << "\n\n"
    entity_str << @inst_part
    entity_str << "end ARCHITECTURE IMPL;"
    return entity_str
  end

  def add_toplevel_sig( soc, entity_name )
    soc.ports do |port_name, dir, length, is_last|
      if dir == 0
        @asgn_part << "#{port_name} <= #{entity_name}_#{port_name}"
      else
        @asgn_part << "#{entity_name}_#{port_name} <= #{port_name} "
      end
      @asgn_part << ";\n" 
      if length > 1
        @decl_part << "signal #{entity_name}_#{port_name} : std_logic_vector( #{length}-1 downto 0 );\n"
      else
        @decl_part << "signal #{entity_name}_#{port_name} : std_logic;\n"
      end
    end
  end



  def asgn_str( ifc_spec, con,  ifc_name, core1, core1_name, core2, core2_name )
    port_string = ""

    { core1 => [ con[ :ifc1 ], :src1 ], 
      core2 => [ con[ :ifc2 ], :src2 ] }.each do| core, tmp |

      core.ports( tmp[0] ) do | port_spec_name, port_name, port_dir | 
 
        if port_dir  == 0
          port_string << "#{ifc_name}_#{port_spec_name}"
          port_string << " <= "
          port_string << "#{con[ tmp[1] ]}_#{port_name}"
          port_string << ";\n"
        else
          port_string << "#{con[ tmp[1] ]}_#{port_name}"
          port_string << " <= "
          port_string << "#{ifc_name}_#{port_spec_name }"
          port_string << ";\n"
        end
      end
 
    end

    return port_string
  end





end
end

# vim: noai:ts=2:sw=2
