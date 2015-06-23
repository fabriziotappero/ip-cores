-------------------------------------------------------------------------------
-- Title      : Functions for ase_mesh1 and wrappers using it
-- Project    : 
-------------------------------------------------------------------------------
-- File       : ase_mesh1_pkg.vhdl
-- Author     : Lasse Lehtonen
-- Company    : 
-- Created    : 2010-06-16
-- Last update: 2012-03-31
-- Platform   : 
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2010 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2010-06-16  1.0      ase     Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.log2_pkg.all;

-------------------------------------------------------------------------------
-- PACKAGE DECLARATION
-------------------------------------------------------------------------------

package ase_mesh1_pkg is

  -----------------------------------------------------------------------------
  -- HELPER FUCTIONS
  -----------------------------------------------------------------------------

  -- Returns target address (ase_mesh1 network address)
  pure function ase_mesh1_address (
    src_id    : in integer;    -- Source agent id number
    dst_id    : in integer;    -- Destination agent id number
    rows      : in positive;
    cols      : in positive;
    bus_width : in positive)
    return std_logic_vector;

end package ase_mesh1_pkg;

-------------------------------------------------------------------------------
-- PACKAGE BODY
-------------------------------------------------------------------------------

package body ase_mesh1_pkg is

  pure function ase_mesh1_address (
    constant src_id    : in integer;    -- Source agent id number
    constant dst_id    : in integer;    -- Destination agent id number
    constant rows      : in positive;
    constant cols      : in positive;
    constant bus_width : in positive)
    return std_logic_vector is
    variable retval             : std_logic_vector(bus_width-1 downto 0);
    variable lr_bit             : std_logic;
    variable here_bit           : std_logic;
    variable first_dir          : std_logic_vector(1 downto 0);
    variable src_row            : integer;
    variable src_col            : integer;
    variable dst_row            : integer;
    variable dst_col            : integer;
    constant mesh1_row_width_c  : positive := log2_ceil(rows - 1);
    constant mesh1_col_width_c  : positive := log2_ceil(cols - 1);
    constant mesh1_port_width_c : positive :=
      bus_width - mesh1_row_width_c - mesh1_col_width_c - 4;
    variable dst_port : integer := 0;
  begin

    retval    := (others => '0');
    lr_bit    := '0';
    here_bit  := '0';
    first_dir := "00";
    src_row   := (src_id / cols);
    src_col   := src_id - (src_row * cols);
    dst_row   := (dst_id / cols);
    dst_col   := dst_id - (dst_row * cols);

--    if src_id = 7 then
--      report "srow " & integer'image(src_row) & ", drow "
--        & integer'image(dst_row) & ", scol "
--        & integer'image(src_col) & ", dcol "
--        & integer'image(dst_col) & ", cols "
--        & integer'image(cols)    & ", rows "
--        & integer'image(rows)    
--        severity note;
--    end if;

    retval(bus_width-1 downto bus_width-mesh1_port_width_c) :=
      std_logic_vector(to_unsigned(dst_port, mesh1_port_width_c));
    
    if src_row = dst_row then
      if src_col = dst_col then

      elsif src_col < dst_col then
        first_dir := "01";
        retval(mesh1_row_width_c+mesh1_col_width_c-1 downto mesh1_row_width_c)
 := std_logic_vector
          (to_unsigned
           ((2**mesh1_col_width_c)-(dst_col-src_col), mesh1_col_width_c));
      else
        first_dir := "11";
        retval(mesh1_row_width_c+mesh1_col_width_c-1 downto mesh1_row_width_c)
 := std_logic_vector
          (to_unsigned
           ((2**mesh1_col_width_c)-(src_col-dst_col), mesh1_col_width_c));
      end if;
    elsif src_row < dst_row then
      first_dir                            := "10";
      retval(mesh1_row_width_c-1 downto 0) :=
        std_logic_vector
        (to_unsigned
         ((2**mesh1_row_width_c)-(dst_row-src_row), mesh1_row_width_c));
      if src_col = dst_col then
        here_bit := '1';
      elsif src_col < dst_col then
        retval(mesh1_row_width_c+mesh1_col_width_c-1 downto mesh1_row_width_c)
 := std_logic_vector
          (to_unsigned
           ((2**mesh1_col_width_c)-(dst_col-src_col), mesh1_col_width_c));
      else
        lr_bit := '1';
        retval(mesh1_row_width_c+mesh1_col_width_c-1 downto mesh1_row_width_c)
 := std_logic_vector
          (to_unsigned
           ((2**mesh1_col_width_c)-(src_col-dst_col), mesh1_col_width_c));
      end if;
    else
      first_dir                            := "00";
      retval(mesh1_row_width_c-1 downto 0) :=
        std_logic_vector
        (to_unsigned
         ((2**mesh1_row_width_c)-(src_row-dst_row), mesh1_row_width_c));
      if src_col = dst_col then
        here_bit := '1';
      elsif src_col < dst_col then
        retval(mesh1_row_width_c+mesh1_col_width_c-1 downto mesh1_row_width_c)
 := std_logic_vector
          (to_unsigned
           ((2**mesh1_col_width_c)-(dst_col-src_col), mesh1_col_width_c));
      else
        lr_bit := '1';
        retval(mesh1_row_width_c+mesh1_col_width_c-1 downto mesh1_row_width_c)
 := std_logic_vector
          (to_unsigned
           ((2**mesh1_col_width_c)-(src_col-dst_col), mesh1_col_width_c));
      end if;
    end if;

    retval(mesh1_row_width_c+mesh1_col_width_c+0) := lr_bit;
    retval(mesh1_row_width_c+mesh1_col_width_c+1) := here_bit;
    retval(mesh1_row_width_c+mesh1_col_width_c+2) := first_dir(0);
    retval(mesh1_row_width_c+mesh1_col_width_c+3) := first_dir(1);

    return retval;
  end function ase_mesh1_address;


end package body ase_mesh1_pkg;
