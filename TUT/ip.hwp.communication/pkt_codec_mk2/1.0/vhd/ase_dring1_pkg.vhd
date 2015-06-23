-------------------------------------------------------------------------------
-- Title      : Package for ase_ring1 and wrappers using it
-- Project    : 
-------------------------------------------------------------------------------
-- File       : ase_ring1_pkg.vhdl
-- Author     : Lasse Lehtonen
-- Company    : 
-- Created    : 2010-07-04
-- Last update: 2011-11-03
-- Platform   : 
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2010 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2010-07-04  1.0      ase     Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.log2_pkg.all;

-------------------------------------------------------------------------------
-- PACKAGE DECLARATION
-------------------------------------------------------------------------------
package ase_dring1_pkg is

  -----------------------------------------------------------------------------
  -- HELPER FUNCTIONS
  -----------------------------------------------------------------------------

  -- Returns data_width_c wide address calculated from source and
  --  destination id numbers (ie. their position on the ring)
  function dring1_address (
    src_id       : in integer;
    dst_id       : in integer;
    agents_c     : in positive;
    data_width_c : in positive)
    return std_logic_vector;

  function dring1_address_s (
    constant src_id       : in integer;
    signal   dst_id       : in integer;
    constant agents_c     : in positive;
    constant data_width_c : in positive)
    return std_logic_vector;
  
end package ase_dring1_pkg;

-------------------------------------------------------------------------------
-- PACKAGE BODY
-------------------------------------------------------------------------------
package body ase_dring1_pkg is

  -----------------------------------------------------------------------------
  -- FUNCTIONS
  -----------------------------------------------------------------------------
  function dring1_address (
    src_id       : in integer;
    dst_id       : in integer;
    agents_c     : in positive;
    data_width_c : in positive)
    return std_logic_vector is
    variable retval_v     : std_logic_vector(data_width_c-1 downto 0);
    constant addr_width_c : positive := log2_ceil(agents_c/2);
    variable src_v        : integer;    --natural range 0 to agents_c-1;
    variable dst_v        : integer;    --natural range 0 to agents_c-1;
    variable tmp_v        : signed(addr_width_c+2 downto 0);
  begin
    retval_v := (others => '0');
    src_v    := src_id;
    dst_v    := dst_id;
    if src_v < dst_v then
      if dst_v - src_v <= agents_c / 2 then
        report "#1 src: " & integer'image(src_id) & " dst: "
          & integer'image(dst_id) severity note;
        retval_v(addr_width_c)            := '0';
        retval_v(addr_width_c-1 downto 0) :=
          std_logic_vector(to_signed
                           (2**addr_width_c - (dst_v - src_v), addr_width_c+3)
                           (addr_width_c-1 downto 0));
      else
        report "#2 src: " & integer'image(src_id) & " dst: "
          & integer'image(dst_id) severity note;
        retval_v(addr_width_c)            := '1';
        retval_v(addr_width_c-1 downto 0) :=
          std_logic_vector(to_signed(
            2**addr_width_c - (agents_c - dst_v + src_v), addr_width_c+3)
                           (addr_width_c-1 downto 0));
      end if;
    else
      if src_v - dst_v <= agents_c / 2 then
        report "#3 src: " & integer'image(src_id) & " dst: "
          & integer'image(dst_id) severity note;
        retval_v(addr_width_c)            := '1';
        retval_v(addr_width_c-1 downto 0) :=
          std_logic_vector(to_signed
                           (2**addr_width_c - (src_v - dst_v), addr_width_c+3)
                           (addr_width_c-1 downto 0));
      else
        report "#4 src: " & integer'image(src_id) & " dst: "
          & integer'image(dst_id) severity note;
        retval_v(addr_width_c) := '0';
        tmp_v := to_signed(
          2**addr_width_c - (agents_c - src_v + dst_v), addr_width_c+3);
        report "#4 tmpv: " & integer'image(to_integer(tmp_v));
        retval_v(addr_width_c-1 downto 0) := std_logic_vector(tmp_v(addr_width_c-1 downto 0));
        report "#4 resv: " &
          integer'image(2**addr_width_c - (agents_c - src_v + dst_v))
          severity note;
      end if;
    end if;
    report "RESULT: " & integer'image(to_integer(unsigned(retval_v)))
      severity note;
    return retval_v;
  end function dring1_address;


  function dring1_address_s (
    constant src_id       : in integer;
    signal   dst_id       : in integer;
    constant agents_c     : in positive;
    constant data_width_c : in positive)
    return std_logic_vector is
    variable retval_v     : std_logic_vector(data_width_c-1 downto 0);
    constant addr_width_c : positive := log2_ceil(agents_c/2);
    variable src_v        : integer;    --natural range 0 to agents_c-1;
    variable dst_v        : integer;    --natural range 0 to agents_c-1;
  begin
    retval_v := (others => '0');
    src_v    := src_id;
    dst_v    := dst_id;
    if src_v < dst_v then
      if dst_v - src_v <= agents_c / 2 then
        retval_v(addr_width_c)            := '0';
        retval_v(addr_width_c-1 downto 0) :=
          std_logic_vector(to_unsigned
                           (2**addr_width_c - dst_v - src_v, addr_width_c));
      else
        retval_v(addr_width_c)            := '1';
        retval_v(addr_width_c-1 downto 0) :=
          std_logic_vector(to_unsigned(
            2**addr_width_c - agents_c - dst_v + src_v, addr_width_c));
      end if;
    else
      if src_v - dst_v <= agents_c / 2 then
        retval_v(addr_width_c)            := '1';
        retval_v(addr_width_c-1 downto 0) :=
          std_logic_vector(to_unsigned
                           (2**addr_width_c - src_v - dst_v, addr_width_c));
      else
        retval_v(addr_width_c)            := '0';
        retval_v(addr_width_c-1 downto 0) :=
          std_logic_vector(to_unsigned(
            2**addr_width_c - agents_c - src_v + dst_v, addr_width_c));
      end if;
    end if;
    return retval_v;
  end function dring1_address_s;

end package body ase_dring1_pkg;
