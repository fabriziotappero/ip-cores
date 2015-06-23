-------------------------------------------------------------------------------
--
-- $Id: t48_pack-p.vhd 295 2009-04-01 19:32:48Z arniml $
--
-- Copyright (c) 2004, Arnim Laeuger (arniml@opencores.org)
--
-- All rights reserved
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

package t48_pack is

  -----------------------------------------------------------------------------
  -- Global constants
  -----------------------------------------------------------------------------

  -- clock active level
  constant clk_active_c      : std_logic := '1';
  -- reset active level
  constant res_active_c      : std_logic := '0';
  -- idle level on internal data bus
  constant bus_idle_level_c  : std_logic := '1';

  -- global data word width
  constant word_width_c      : natural := 8;

  -- data memory address width
  constant dmem_addr_width_c : natural := 8;
  -- program memory address width
  constant pmem_addr_width_c : natural := 12;


  -----------------------------------------------------------------------------
  -- Global data types
  -----------------------------------------------------------------------------

  -- the global data word width type
  subtype word_t   is std_logic_vector(word_width_c-1 downto 0);
  subtype nibble_t is std_logic_vector(word_width_c/2-1 downto 0);
  -- the global data memory address type
  subtype dmem_addr_t is std_logic_vector(dmem_addr_width_c-1 downto 0);
  -- the global program memory address type
  subtype pmem_addr_t is std_logic_vector(pmem_addr_width_c-1 downto 0);
  subtype page_t      is std_logic_vector(pmem_addr_width_c-1 downto word_width_c);

  -- the machine states
  type mstate_t is (MSTATE1, MSTATE2, MSTATE3, MSTATE4, MSTATE5);


  -----------------------------------------------------------------------------
  -- Global functions
  -----------------------------------------------------------------------------

  function to_stdLogic(input: boolean) return std_logic;
  function to_boolean(input: std_logic) return boolean;

end t48_pack;

package body t48_pack is

  function to_stdLogic(input: boolean) return std_logic is
  begin
    if input then
      return '1';
    else
      return '0';
    end if;
  end to_stdLogic;

  function to_boolean(input: std_logic) return boolean is
  begin
    if input = '1' then
      return true;
    else
      return false;
    end if;
  end to_boolean;

end t48_pack;
