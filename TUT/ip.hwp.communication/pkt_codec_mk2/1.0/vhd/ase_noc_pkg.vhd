-------------------------------------------------------------------------------
-- Title      : Mesh configuration package
-- Project    : 
-------------------------------------------------------------------------------
-- File       : ase_noc_pkg.vhd
-- Author     : Lasse Lehtonen
-- Company    : 
-- Created    : 2011-01-18
-- Last update: 2011-11-08
-- Platform   : 
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2011 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2011-01-18  1.0      lehton87        Created
-------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.log2_pkg.all;

package ase_noc_pkg is

  -- Commands
  constant mesh_cmd_idle_c  : std_logic_vector(1 downto 0) := "00";
  constant mesh_cmd_addr_c  : std_logic_vector(1 downto 0) := "01";
  constant mesh_cmd_data_c  : std_logic_vector(1 downto 0) := "10";
  constant mesh_cmd_empty_c : std_logic_vector(1 downto 0) := "11";

  -- Helper functions
  function ase_noc_address (
    constant own_id             : in natural;
    constant target_id          : in natural;
    constant mesh_cols_c        : in positive;
    constant mesh_rows_c        : in positive;
    constant mesh_agent_ports_c : in positive;
    constant mesh_data_width_c  : in positive)
    return std_logic_vector;

  function ase_noc_address_s (
    constant own_id             : in natural;
    signal   target_id          : in integer;
    constant mesh_cols_c        : in positive;
    constant mesh_rows_c        : in positive;
    constant mesh_agent_ports_c : in positive;
    constant mesh_data_width_c  : in positive)
    return std_logic_vector;
  
end package ase_noc_pkg;




package body ase_noc_pkg is

  
  function ase_noc_address (
    constant own_id             : in natural;
    constant target_id          : in natural;
    constant mesh_cols_c        : in positive;
    constant mesh_rows_c        : in positive;
    constant mesh_agent_ports_c : in positive;
    constant mesh_data_width_c  : in positive)
    return std_logic_vector is
    variable ret               : std_logic_vector(mesh_data_width_c-1 downto 0);
    variable src_row           : natural range 0 to mesh_rows_c-1;
    variable src_col           : natural range 0 to mesh_cols_c-1;
    variable dst_row           : natural range 0 to mesh_rows_c-1;
    variable dst_col           : natural range 0 to mesh_cols_c-1;
    variable col_dif           : integer range -mesh_cols_c/2-1 to mesh_cols_c/2+1;
    variable row_dif           : integer range -mesh_rows_c/2-1 to mesh_rows_c/2+1;
    variable dst_port          : natural range 4 to 4+mesh_agent_ports_c-1;
    constant mesh_port_width_c : natural := log2_ceil(4+mesh_agent_ports_c);
    constant mesh_ids_c        : natural :=
      mesh_rows_c*mesh_cols_c*mesh_agent_ports_c;
    constant mesh_col_add_c : natural := log2_ceil(mesh_cols_c-1);
    constant mesh_row_add_c : natural := log2_ceil(mesh_rows_c-1);
  begin  -- function mesh_address    

    ret      := (others => '0');
    src_row  := (own_id / (mesh_cols_c * mesh_agent_ports_c));
    src_col  := own_id - (src_row * (mesh_cols_c * mesh_agent_ports_c));
    dst_row  := (target_id / (mesh_cols_c * mesh_agent_ports_c));
    dst_col  := target_id - (dst_row * (mesh_cols_c * mesh_agent_ports_c));
    col_dif  := dst_col - src_col;
    row_dif  := dst_row - src_row;
    dst_port := target_id - (dst_row*mesh_cols_c+dst_col)*mesh_agent_ports_c+4;

    if src_row = dst_row then

      if src_col = dst_col then

        ret(mesh_port_width_c-1 downto 0) :=
          std_logic_vector(to_unsigned(dst_port, mesh_port_width_c));

      elsif src_col < dst_col then
        
        ret(mesh_port_width_c-1 downto 0) :=
          std_logic_vector(to_unsigned(1, mesh_port_width_c));
        ret(mesh_col_add_c+mesh_port_width_c-1 downto mesh_port_width_c) :=
          std_logic_vector(to_unsigned(2**mesh_col_add_c-col_dif,
                                       mesh_col_add_c));
        ret(mesh_port_width_c+mesh_col_add_c+mesh_port_width_c-1 downto
            mesh_col_add_c+mesh_port_width_c) :=
          std_logic_vector(to_unsigned(dst_port, mesh_port_width_c));
        
      else

        ret(mesh_port_width_c-1 downto 0) :=
          std_logic_vector(to_unsigned(3, mesh_port_width_c));
        ret(mesh_col_add_c+mesh_port_width_c-1 downto mesh_port_width_c) :=
          std_logic_vector(to_unsigned(2**mesh_col_add_c+col_dif,
                                       mesh_col_add_c));
        ret(mesh_port_width_c+mesh_col_add_c+mesh_port_width_c-1 downto
            mesh_col_add_c+mesh_port_width_c) :=
          std_logic_vector(to_unsigned(dst_port, mesh_port_width_c));
        
      end if;

    elsif src_row < dst_row then

      if src_col = dst_col then

        ret(mesh_port_width_c-1 downto 0) :=
          std_logic_vector(to_unsigned(2, mesh_port_width_c));
        ret(mesh_col_add_c+mesh_port_width_c-1 downto mesh_port_width_c) :=
          std_logic_vector(to_unsigned(2**mesh_row_add_c-row_dif,
                                       mesh_row_add_c));
        ret(mesh_port_width_c+mesh_row_add_c+mesh_port_width_c-1 downto
            mesh_row_add_c+mesh_port_width_c) :=
          std_logic_vector(to_unsigned(dst_port, mesh_port_width_c));
        
      elsif src_col < dst_col then

        ret(mesh_port_width_c-1 downto 0) :=
          std_logic_vector(to_unsigned(2, mesh_port_width_c));
        ret(mesh_row_add_c+mesh_port_width_c-1 downto mesh_port_width_c) :=
          std_logic_vector(to_unsigned(2**mesh_row_add_c-row_dif,
                                       mesh_row_add_c));
        ret(mesh_row_add_c+mesh_port_width_c*2-1 downto
            mesh_row_add_c+mesh_port_width_c) :=
          std_logic_vector(to_unsigned(1, mesh_port_width_c));
        ret(mesh_col_add_c+mesh_row_add_c+mesh_port_width_c*2-1 downto
            mesh_port_width_c*2+mesh_row_add_c) :=
          std_logic_vector(to_unsigned(2**mesh_col_add_c-col_dif,
                                       mesh_col_add_c));        
        ret(mesh_col_add_c+mesh_row_add_c+mesh_port_width_c*3-1 downto
            mesh_col_add_c+mesh_row_add_c+mesh_port_width_c*2) :=
          std_logic_vector(to_unsigned(dst_port, mesh_port_width_c));
        
      else

        ret(mesh_port_width_c-1 downto 0) :=
          std_logic_vector(to_unsigned(2, mesh_port_width_c));
        ret(mesh_row_add_c+mesh_port_width_c-1 downto mesh_port_width_c) :=
          std_logic_vector(to_unsigned(2**mesh_row_add_c-row_dif,
                                       mesh_row_add_c));
        ret(mesh_row_add_c+mesh_port_width_c*2-1 downto
            mesh_row_add_c+mesh_port_width_c) :=
          std_logic_vector(to_unsigned(3, mesh_port_width_c));
        ret(mesh_col_add_c+mesh_row_add_c+mesh_port_width_c*2-1 downto
            mesh_port_width_c*2+mesh_row_add_c) :=
          std_logic_vector(to_unsigned(2**mesh_col_add_c+col_dif,
                                       mesh_col_add_c));        
        ret(mesh_col_add_c+mesh_row_add_c+mesh_port_width_c*3-1 downto
            mesh_col_add_c+mesh_row_add_c+mesh_port_width_c*2) :=
          std_logic_vector(to_unsigned(dst_port, mesh_port_width_c));
        
      end if;
      
    else

      if src_col = dst_col then

        ret(mesh_port_width_c-1 downto 0) :=
          std_logic_vector(to_unsigned(0, mesh_port_width_c));
        ret(mesh_col_add_c+mesh_port_width_c-1 downto mesh_port_width_c) :=
          std_logic_vector(to_unsigned(2**mesh_row_add_c+row_dif,
                                       mesh_row_add_c));
        ret(mesh_port_width_c+mesh_row_add_c+mesh_port_width_c-1 downto
            mesh_row_add_c+mesh_port_width_c) :=
          std_logic_vector(to_unsigned(dst_port, mesh_port_width_c));
        
      elsif src_col < dst_col then

        ret(mesh_port_width_c-1 downto 0) :=
          std_logic_vector(to_unsigned(0, mesh_port_width_c));
        ret(mesh_row_add_c+mesh_port_width_c-1 downto mesh_port_width_c) :=
          std_logic_vector(to_unsigned(2**mesh_row_add_c+row_dif,
                                       mesh_row_add_c));
        ret(mesh_row_add_c+mesh_port_width_c*2-1 downto
            mesh_row_add_c+mesh_port_width_c) :=
          std_logic_vector(to_unsigned(1, mesh_port_width_c));
        ret(mesh_col_add_c+mesh_row_add_c+mesh_port_width_c*2-1 downto
            mesh_port_width_c*2+mesh_row_add_c) :=
          std_logic_vector(to_unsigned(2**mesh_col_add_c-col_dif,
                                       mesh_col_add_c));        
        ret(mesh_col_add_c+mesh_row_add_c+mesh_port_width_c*3-1 downto
            mesh_col_add_c+mesh_row_add_c+mesh_port_width_c*2) :=
          std_logic_vector(to_unsigned(dst_port, mesh_port_width_c));
        
      else

        ret(mesh_port_width_c-1 downto 0) :=
          std_logic_vector(to_unsigned(0, mesh_port_width_c));
        ret(mesh_row_add_c+mesh_port_width_c-1 downto mesh_port_width_c) :=
          std_logic_vector(to_unsigned(2**mesh_row_add_c+row_dif,
                                       mesh_row_add_c));
        ret(mesh_row_add_c+mesh_port_width_c*2-1 downto
            mesh_row_add_c+mesh_port_width_c) :=
          std_logic_vector(to_unsigned(3, mesh_port_width_c));
        ret(mesh_col_add_c+mesh_row_add_c+mesh_port_width_c*2-1 downto
            mesh_port_width_c*2+mesh_row_add_c) :=
          std_logic_vector(to_unsigned(2**mesh_col_add_c+col_dif,
                                       mesh_col_add_c));        
        ret(mesh_col_add_c+mesh_row_add_c+mesh_port_width_c*3-1 downto
            mesh_col_add_c+mesh_row_add_c+mesh_port_width_c*2) :=
          std_logic_vector(to_unsigned(dst_port, mesh_port_width_c));
        
      end if;
      
    end if;

    report "From " & integer'image(own_id) & " to " & integer'image(target_id)
      & " gives " & integer'image(to_integer(unsigned(ret))) severity note;
    report "col_add " & integer'image(mesh_col_add_c)
      & ", row_add " & integer'image(mesh_row_add_c)
      & ", port_w " & integer'image(mesh_port_width_c) severity note;
    
    return ret;
    
  end function ase_noc_address;


  function ase_noc_address_s (
    constant own_id             : in natural;
    signal   target_id          : in integer;
    constant mesh_cols_c        : in positive;
    constant mesh_rows_c        : in positive;
    constant mesh_agent_ports_c : in positive;
    constant mesh_data_width_c  : in positive)
    return std_logic_vector is
    variable ret               : std_logic_vector(mesh_data_width_c-1 downto 0);
    variable src_row           : natural range 0 to mesh_rows_c-1;
    variable src_col           : natural range 0 to mesh_cols_c-1;
    variable dst_row           : natural range 0 to mesh_rows_c-1;
    variable dst_col           : natural range 0 to mesh_cols_c-1;
    variable col_dif           : integer range -mesh_cols_c/2-1 to mesh_cols_c/2+1;
    variable row_dif           : integer range -mesh_rows_c/2-1 to mesh_rows_c/2+1;
    variable dst_port          : natural range 4 to 4+mesh_agent_ports_c-1;
    constant mesh_port_width_c : natural := log2_ceil(4+mesh_agent_ports_c);
    constant mesh_ids_c        : natural :=
      mesh_rows_c*mesh_cols_c*mesh_agent_ports_c;
    constant mesh_col_add_c : natural := log2_ceil(mesh_cols_c-1);
    constant mesh_row_add_c : natural := log2_ceil(mesh_rows_c-1);
  begin  -- function mesh_address

    ret      := (others => '0');
    src_row  := (own_id / (mesh_cols_c * mesh_agent_ports_c));
    src_col  := own_id - (src_row * (mesh_cols_c * mesh_agent_ports_c));
    dst_row  := (target_id / (mesh_cols_c * mesh_agent_ports_c));
    dst_col  := target_id - (dst_row * (mesh_cols_c * mesh_agent_ports_c));
    col_dif  := dst_col - src_col;
    row_dif  := dst_row - src_row;
    dst_port := target_id - (dst_row*mesh_cols_c+dst_col)*mesh_agent_ports_c+4;

    if src_row = dst_row then

      if src_col = dst_col then

        ret(mesh_port_width_c-1 downto 0) :=
          std_logic_vector(to_unsigned(dst_port, mesh_port_width_c));

      elsif src_col < dst_col then
        
        ret(mesh_port_width_c-1 downto 0) :=
          std_logic_vector(to_unsigned(1, mesh_port_width_c));
        ret(mesh_col_add_c+mesh_port_width_c-1 downto mesh_port_width_c) :=
          std_logic_vector(to_unsigned(2**mesh_col_add_c-col_dif,
                                       mesh_col_add_c));
        ret(mesh_port_width_c+mesh_col_add_c+mesh_port_width_c-1 downto
            mesh_col_add_c+mesh_port_width_c) :=
          std_logic_vector(to_unsigned(dst_port, mesh_port_width_c));
        
      else

        ret(mesh_port_width_c-1 downto 0) :=
          std_logic_vector(to_unsigned(3, mesh_port_width_c));
        ret(mesh_col_add_c+mesh_port_width_c-1 downto mesh_port_width_c) :=
          std_logic_vector(to_unsigned(2**mesh_col_add_c+col_dif,
                                       mesh_col_add_c));
        ret(mesh_port_width_c+mesh_col_add_c+mesh_port_width_c-1 downto
            mesh_col_add_c+mesh_port_width_c) :=
          std_logic_vector(to_unsigned(dst_port, mesh_port_width_c));
        
      end if;

    elsif src_row < dst_row then

      if src_col = dst_col then

        ret(mesh_port_width_c-1 downto 0) :=
          std_logic_vector(to_unsigned(2, mesh_port_width_c));
        ret(mesh_col_add_c+mesh_port_width_c-1 downto mesh_port_width_c) :=
          std_logic_vector(to_unsigned(2**mesh_row_add_c-row_dif,
                                       mesh_row_add_c));
        ret(mesh_port_width_c+mesh_row_add_c+mesh_port_width_c-1 downto
            mesh_row_add_c+mesh_port_width_c) :=
          std_logic_vector(to_unsigned(dst_port, mesh_port_width_c));
        
      elsif src_col < dst_col then

        ret(mesh_port_width_c-1 downto 0) :=
          std_logic_vector(to_unsigned(2, mesh_port_width_c));
        ret(mesh_row_add_c+mesh_port_width_c-1 downto mesh_port_width_c) :=
          std_logic_vector(to_unsigned(2**mesh_row_add_c-row_dif,
                                       mesh_row_add_c));
        ret(mesh_row_add_c+mesh_port_width_c*2-1 downto
            mesh_row_add_c+mesh_port_width_c) :=
          std_logic_vector(to_unsigned(1, mesh_port_width_c));
        ret(mesh_col_add_c+mesh_row_add_c+mesh_port_width_c*2-1 downto
            mesh_port_width_c*2+mesh_row_add_c) :=
          std_logic_vector(to_unsigned(2**mesh_col_add_c-col_dif,
                                       mesh_col_add_c));        
        ret(mesh_col_add_c+mesh_row_add_c+mesh_port_width_c*3-1 downto
            mesh_col_add_c+mesh_row_add_c+mesh_port_width_c*2) :=
          std_logic_vector(to_unsigned(dst_port, mesh_port_width_c));
        
      else

        ret(mesh_port_width_c-1 downto 0) :=
          std_logic_vector(to_unsigned(2, mesh_port_width_c));
        ret(mesh_row_add_c+mesh_port_width_c-1 downto mesh_port_width_c) :=
          std_logic_vector(to_unsigned(2**mesh_row_add_c-row_dif,
                                       mesh_row_add_c));
        ret(mesh_row_add_c+mesh_port_width_c*2-1 downto
            mesh_row_add_c+mesh_port_width_c) :=
          std_logic_vector(to_unsigned(3, mesh_port_width_c));
        ret(mesh_col_add_c+mesh_row_add_c+mesh_port_width_c*2-1 downto
            mesh_port_width_c*2+mesh_row_add_c) :=
          std_logic_vector(to_unsigned(2**mesh_col_add_c+col_dif,
                                       mesh_col_add_c));        
        ret(mesh_col_add_c+mesh_row_add_c+mesh_port_width_c*3-1 downto
            mesh_col_add_c+mesh_row_add_c+mesh_port_width_c*2) :=
          std_logic_vector(to_unsigned(dst_port, mesh_port_width_c));
        
      end if;
      
    else

      if src_col = dst_col then

        ret(mesh_port_width_c-1 downto 0) :=
          std_logic_vector(to_unsigned(0, mesh_port_width_c));
        ret(mesh_col_add_c+mesh_port_width_c-1 downto mesh_port_width_c) :=
          std_logic_vector(to_unsigned(2**mesh_row_add_c+row_dif,
                                       mesh_row_add_c));
        ret(mesh_port_width_c+mesh_row_add_c+mesh_port_width_c-1 downto
            mesh_row_add_c+mesh_port_width_c) :=
          std_logic_vector(to_unsigned(dst_port, mesh_port_width_c));
        
      elsif src_col < dst_col then

        ret(mesh_port_width_c-1 downto 0) :=
          std_logic_vector(to_unsigned(0, mesh_port_width_c));
        ret(mesh_row_add_c+mesh_port_width_c-1 downto mesh_port_width_c) :=
          std_logic_vector(to_unsigned(2**mesh_row_add_c+row_dif,
                                       mesh_row_add_c));
        ret(mesh_row_add_c+mesh_port_width_c*2-1 downto
            mesh_row_add_c+mesh_port_width_c) :=
          std_logic_vector(to_unsigned(1, mesh_port_width_c));
        ret(mesh_col_add_c+mesh_row_add_c+mesh_port_width_c*2-1 downto
            mesh_port_width_c*2+mesh_row_add_c) :=
          std_logic_vector(to_unsigned(2**mesh_col_add_c-col_dif,
                                       mesh_col_add_c));        
        ret(mesh_col_add_c+mesh_row_add_c+mesh_port_width_c*3-1 downto
            mesh_col_add_c+mesh_row_add_c+mesh_port_width_c*2) :=
          std_logic_vector(to_unsigned(dst_port, mesh_port_width_c));
        
      else

        ret(mesh_port_width_c-1 downto 0) :=
          std_logic_vector(to_unsigned(0, mesh_port_width_c));
        ret(mesh_row_add_c+mesh_port_width_c-1 downto mesh_port_width_c) :=
          std_logic_vector(to_unsigned(2**mesh_row_add_c+row_dif,
                                       mesh_row_add_c));
        ret(mesh_row_add_c+mesh_port_width_c*2-1 downto
            mesh_row_add_c+mesh_port_width_c) :=
          std_logic_vector(to_unsigned(3, mesh_port_width_c));
        ret(mesh_col_add_c+mesh_row_add_c+mesh_port_width_c*2-1 downto
            mesh_port_width_c*2+mesh_row_add_c) :=
          std_logic_vector(to_unsigned(2**mesh_col_add_c+col_dif,
                                       mesh_col_add_c));        
        ret(mesh_col_add_c+mesh_row_add_c+mesh_port_width_c*3-1 downto
            mesh_col_add_c+mesh_row_add_c+mesh_port_width_c*2) :=
          std_logic_vector(to_unsigned(dst_port, mesh_port_width_c));
        
      end if;
      
    end if;

    return ret;
    
  end function ase_noc_address_s;



end package body ase_noc_pkg;
