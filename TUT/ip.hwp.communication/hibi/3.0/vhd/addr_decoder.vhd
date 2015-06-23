-------------------------------------------------------------------------------
-- Title      : HIBI Address decoder
-- Project    : HIBI
-------------------------------------------------------------------------------
-- File       : addr_decoder.vhd
-- Authors    : Lasse Lehtonen
-- Company    : Tampere University of Technology
-- Created    :
-- Last update: 2011-10-07
-- Platform   : 
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: Address and id decoding logic
-- 
-- Checks if incoming address or configuration id is for this wrapper.
-- This assigns match_out also for configuration commands targeted to ids in range
-- [id_min_g, id_max_g], so that they go over the bridge (provided
-- that id_max_g is not zero, )
--
-- Combinatorial block = zero clock cycle latency.
--
-------------------------------------------------------------------------------
-- Notes      :
--
-- If id_max_g /= 0 then this is assumed to be used inside a HIBI bridge.
--
-- If addr_limit_g == 0 then the old mask style is used to calculate the upper
-- address limit (as in HIBI v.2).
--
-- Own id_g should not be in range [id_min_g, id_max_g]! (this would prevent
-- configuring this side of the bridge) (unless it's inverted)
--
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2010-10-13  1.0      ase     Created
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Funbase IP library Copyright (C) 2011 TUT Department of Computer Systems
--
-- This file is part of HIBI
--
-- This source file may be used and distributed without
-- restriction provided that this copyright statement is not
-- removed from the file and that any derivative work contains
-- the original copyright notice and the associated disclaimer.
--
-- This source file is free software; you can redistribute it
-- and/or modify it under the terms of the GNU Lesser General
-- Public License as published by the Free Software Foundation;
-- either version 2.1 of the License, or (at your option) any
-- later version.
--
-- This source is distributed in the hope that it will be
-- useful, but WITHOUT ANY WARRANTY; without even the implied
-- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
-- PURPOSE.  See the GNU Lesser General Public License for more
-- details.
--
-- You should have received a copy of the GNU Lesser General
-- Public License along with this source; if not, download it
-- from http://www.opencores.org/lgpl.shtml
-------------------------------------------------------------------------------



library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.hibiv3_pkg.all;

entity addr_decoder is
  generic (
    data_width_g    : integer;
    addr_width_g    : integer;
    id_width_g      : integer;
    id_g            : integer;
    id_min_g        : integer;          -- Only for bridges, zero for others!
    id_max_g        : integer;          -- Only for bridges, zero for others!
    addr_base_g     : integer;
    addr_limit_g    : integer;
    invert_addr_g   : integer;          -- Only for one half of a bridge
    cfg_re_g        : integer;
    cfg_we_g        : integer;
    separate_addr_g : integer
    );
  port (
    clk                  : in  std_logic;
    rst_n                : in  std_logic;
    -- from bus
    av_in                : in  std_logic;
    addr_in              : in  std_logic_vector(addr_width_g-1 downto 0);
    comm_in              : in  std_logic_vector(comm_width_c-1 downto 0);
    bus_full_in          : in  std_logic;
    -- decode results
    addr_match_out       : out std_logic;  -- address is (was) in my range
    id_match_out         : out std_logic;  -- id is for me
    norm_cmd_out         : out std_logic;  -- '1' for normal commands
    msg_cmd_out          : out std_logic;  -- '1' for message commands
    conf_re_cmd_out      : out std_logic;  -- '1' for conf read
    conf_we_cmd_out      : out std_logic;  -- '1' for conf write
    excl_lock_cmd_out    : out std_logic;  -- '1' for exclusive lock
    excl_data_cmd_out    : out std_logic;  -- '1' for exclusive read/write
    excl_release_cmd_out : out std_logic   -- '1' for exclusive release
    );

end addr_decoder;


architecture rtl of addr_decoder is

  -----------------------------------------------------------------------------
  -- FUNCTIONS
  -----------------------------------------------------------------------------

  -- Calculates the upper address limit
  function addressLimit (
    constant base_address : unsigned)
    return unsigned is
    variable idx_found_var      : integer;
    variable limit_internal_var : unsigned(addr_width_g-1 downto 0);
  begin  -- function addressLimit
    
    if addr_limit_g = 0 then

      assert false
        report "Automagically calculating the upper address limit. "
        & "FYI: Upper limit can be also set freely with addr_limit_g "
        & "generic"
        severity note;
      
      idx_found_var      := 0;
      limit_internal_var := (others => '1');

      parse : for i in 0 to (addr_width_g - 1) loop
        if base_address(i) = '0' and idx_found_var = 0 then
          limit_internal_var(i) := '1';
        else
          idx_found_var         := 1;
          limit_internal_var(i) := base_address(i);
        end if;
      end loop;  -- i      

    elsif addr_limit_g >= addr_base_g then

      limit_internal_var := to_unsigned(addr_limit_g, addr_width_g);

    else
      
      assert false
        report "Address limit (upper) is smaller than base address"
        severity failure;
      
    end if;

    report "addr_decoder id(" & integer'image(id_g)
      & ") id_min(" & integer'image(id_min_g)
      & ") id_max(" & integer'image(id_max_g)
      & ") invert(" & integer'image(invert_addr_g)
      & ")"
      severity note;

    return limit_internal_var;
    
  end function addressLimit;

  -----------------------------------------------------------------------------
  -- CONSTANTS
  -----------------------------------------------------------------------------

  constant addr_base_c : unsigned(addr_width_g-1 downto 0) :=
    to_unsigned(addr_base_g, addr_width_g);
  
  constant addr_limit_c : unsigned(addr_width_g-1 downto 0) :=
    addressLimit(addr_base_c);

  signal addr_base_dummy  : unsigned(addr_width_g-1 downto 0) := addr_base_c;
  signal addr_limit_dummy : unsigned(addr_width_g-1 downto 0) := addr_limit_c;

  -----------------------------------------------------------------------------
  -- REGISTERS
  -----------------------------------------------------------------------------
  signal old_addr_match_r : std_logic;
  signal old_id_match_r   : std_logic;

  -----------------------------------------------------------------------------
  -- COMBINATORIAL SIGNALS
  -----------------------------------------------------------------------------
  signal addr_match       : std_logic;
  signal id_match         : std_logic;
  signal norm_cmd         : std_logic;
  signal msg_cmd          : std_logic;
  signal conf_re_cmd      : std_logic;
  signal conf_we_cmd      : std_logic;
  signal excl_lock_cmd    : std_logic;
  signal excl_data_cmd    : std_logic;
  signal excl_release_cmd : std_logic;

  
  
begin  -- rtl

  -----------------------------------------------------------------------------
  -- OUPUTS
  -----------------------------------------------------------------------------
  addr_match_out       <= addr_match and not bus_full_in;
  id_match_out         <= id_match and not bus_full_in;
  norm_cmd_out         <= norm_cmd;
  msg_cmd_out          <= msg_cmd;
  conf_re_cmd_out      <= conf_re_cmd;
  conf_we_cmd_out      <= conf_we_cmd;
  excl_lock_cmd_out    <= excl_lock_cmd;
  excl_data_cmd_out    <= excl_data_cmd;
  excl_release_cmd_out <= excl_release_cmd;

  -----------------------------------------------------------------------------
  -- SYNCHRONOUS LOGIC
  -----------------------------------------------------------------------------
  gen_registers : if separate_addr_g = 0 generate

    -- Only needed if address is multiplexed to same bus as data
    -- Used to remember the decoding result from last time av_in was '1'
    
    old_values_p : process (clk, rst_n) is
    begin  -- process old_values_p
      if rst_n = '0' then               -- asynchronous reset (active low)
        
        old_addr_match_r <= '0';
        old_id_match_r   <= '0';
        
      elsif clk'event and clk = '1' then  -- rising clock edge
        
        old_addr_match_r <= addr_match;
        old_id_match_r   <= id_match;
        
      end if;
    end process old_values_p;
    
  end generate gen_registers;

  -----------------------------------------------------------------------------
  -- COMBINATORIAL LOGIC
  -----------------------------------------------------------------------------
  cmd_type : process (comm_in) is
  begin  -- process cmd_type

    -- default
    norm_cmd         <= '0';
    msg_cmd          <= '0';
    conf_re_cmd      <= '0';
    conf_we_cmd      <= '0';
    excl_data_cmd    <= '0';
    excl_lock_cmd    <= '0';
    excl_release_cmd <= '0';

    if (comm_in = DATA_WR_c
        or comm_in = DATA_RD_c
        or comm_in = DATA_RDL_c
        or comm_in = DATA_WRNP_c
        or comm_in = DATA_WRC_c)
    then

      norm_cmd <= '1';

    elsif (comm_in = MSG_WR_c
           or comm_in = MSG_RD_c
           or comm_in = MSG_RDL_c
           or comm_in = MSG_WRNP_c
           or comm_in = MSG_WRC_c) then

      msg_cmd <= '1';

    elsif (comm_in = EXCL_WR_c or comm_in = EXCL_RD_c) then

      excl_data_cmd <= '1';

    elsif (comm_in = EXCL_LOCK_c) then

      excl_lock_cmd <= '1';

    elsif (comm_in = EXCL_RELEASE_c) then

      excl_release_cmd <= '1';

    elsif (comm_in = CFG_WR_c) then

      conf_we_cmd <= '1';

    elsif (comm_in = CFG_RD_c) then

      conf_re_cmd <= '1';
      
    end if;
    
    
  end process cmd_type;

  
  current_values_p : process (av_in, addr_in, old_addr_match_r,
                              old_id_match_r, norm_cmd, msg_cmd,
                              conf_re_cmd, conf_we_cmd, excl_lock_cmd,
                              excl_data_cmd, excl_release_cmd, comm_in) is

    variable id_in_v            : unsigned(id_width_g-1 downto 0);
    variable is_my_id_range_v   : std_logic;
    variable is_my_addr_range_v : std_logic;
    
  begin  -- process current_values_p

    id_in_v := unsigned(addr_in(addr_width_g-1 downto addr_width_g-id_width_g));

    if ((invert_addr_g = 0
         and unsigned(addr_in) >= addr_base_c
         and unsigned(addr_in) <= addr_limit_c)
        or
        (invert_addr_g = 1
         and (unsigned(addr_in) < addr_base_c
              or unsigned(addr_in) > addr_limit_c))) then

      is_my_addr_range_v := '1';
    else
      is_my_addr_range_v := '0';
    end if;

    if ((invert_addr_g = 0
         and id_in_v >= to_unsigned(id_min_g, id_width_g)
         and id_in_v <= to_unsigned(id_max_g, id_width_g))
        or
        (invert_addr_g = 1
         and (id_in_v < to_unsigned(id_min_g, id_width_g)
              or id_in_v > to_unsigned(id_max_g, id_width_g)))) then

      is_my_id_range_v := '1';
    else
      is_my_id_range_v := '0';
    end if;

    -- defaults
    addr_match <= '0';
    id_match   <= '0';

    if separate_addr_g = 1 or av_in = '1' then

      -- Address matches if it's normal command and address is in our range
      -- or for bridges if the incoming id is in the [id_min_g, id_max_g] range
      -- invert_addr_g inverts these conditions
      if ((norm_cmd = '1'
           or msg_cmd = '1'
           or excl_data_cmd = '1'
           or excl_lock_cmd = '1'
           or excl_release_cmd = '1')
          and is_my_addr_range_v = '1')
        or
        (id_max_g /= 0                  -- This must be bridge
         and (conf_re_cmd = '1' or conf_we_cmd = '1')
         and is_my_id_range_v = '1') then

        addr_match <= '1';

      elsif (cfg_re_g = 1 or cfg_we_g = 1)
        and (conf_re_cmd = '1' or conf_we_cmd = '1')
        and (id_in_v = to_unsigned(id_g, id_width_g)
             or id_in_v = to_unsigned(0, id_width_g)) then

        -- Id matches for config commands where incoming id is our id_g        
        id_match <= '1';

        assert cfg_re_g = 1 or comm_in /= CFG_RD_c
          report "Got configure memory read command but reading from it"
          & " is not enabled"
          severity failure;

        assert cfg_we_g = 1 or comm_in /= CFG_WR_c
          report "Got configure memory write command but writing to it"
          & " is not enabled"
          severity failure;
        
      end if;
      
    elsif separate_addr_g = 0 then
      -- av_in is '0', use old values
      
      addr_match <= old_addr_match_r;
      id_match   <= old_id_match_r;
      
    end if;
    
  end process current_values_p;

  
end rtl;
