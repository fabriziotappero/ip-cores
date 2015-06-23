-------------------------------------------------------------------------------
-- Funbase IP library Copyright (C) 2011 TUT Department of Computer Systems
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
-------------------------------------------------------------------------------
-- Title      : Dynamic arbitration algorith, lfsr+lut
-- Project    : 
-------------------------------------------------------------------------------
-- File       : dyn_arb.vhd
-- Author     : 
-- Created    : 22.05.2006
-- Last update: 2009-04-08
-- Description: dynamic arbitration algorithm
-------------------------------------------------------------------------------
-- Copyright (c) 2006 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 22.05.2006  1.0      AK      Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
--use ieee.std_logic_arith.all; poistin 2009-04-06 ES
use ieee.std_logic_unsigned.all;

use ieee.numeric_std.all;               -- ES 2009-04-06

entity dyn_arb is
  
  generic (
    id_width_g : integer := 0;
    n_agents_g : integer := 0);

  port (
    clk           : in  std_logic;
    rst_n         : in  std_logic;
    bus_lock_in   : in  std_logic;
--    incr_agent_in : in  std_logic_vector(n_agents_g-1 downto 0);
    arb_agent_out : out std_logic_vector(id_width_g-1 downto 0)  -- values  1..n
    );

end dyn_arb;

architecture rtl of dyn_arb is
  
  component lfsr
    generic (
      width_g : integer range 1 to 36);
    port (
      rst_n     : in  std_logic;
      enable_in : in  std_logic;
      q_out     : out std_logic_vector(width_g-1 downto 0);
      clk       : in  std_logic);
  end component;


  constant qos_slots_c   : integer := 3;  -- how many fixed slots per agent

  -- Signals for Linear Feedback Shift Register (LFSR) that generates (pseudo)
  -- random numbers
  constant lfsr_width_c  : integer := 8;  -- note! 6 bits only used!
  constant lut_size_c    : integer := 2**(lfsr_width_c-1);
  signal   q_from_lfsr   : std_logic_vector(lfsr_width_c-1 downto 0);  --(pseudo-)rand value
  signal   enable_lfsr_r : std_logic;


  -- Array that stores the "lottery tickets"
  type turn_lut_array is array (lut_size_c-1 downto 0) of std_logic_vector(id_width_g-1 downto 0);
  --  type     turn_lut_array is array (2**(lfsr_width_c-1)-1 downto 0) of std_logic_vector(id_width_g-1 downto 0);
  signal adaptive_lut_r : turn_lut_array;

  
  signal arb_agent    : std_logic_vector(id_width_g-1 downto 0);  -- winner
  signal out_was_r      : std_logic_vector(id_width_g-1 downto 0);
  signal prev_lock_r      : std_logic;


  -- ES 2009-04-06
  -- Calculate LUT statistics for debug. Simulation purposes only.
  -- Modelsim may obtimize this away, so you must statt simulation with
  -- optimizations disabled : vsim -novopt tb_hibiv2_lat etc.
  type   ticket_count_table_type is array (n_agents_g+1-1 downto 0) of integer;
  signal ticket_count_table_r : ticket_count_table_type;

  
begin  -- rtl

  arb_agent_out <= arb_agent;
  enable_lfsr_r <= not bus_lock_in;


  assert lut_size_c >= n_agents_g * qos_slots_c report "Too mnay qos slots" severity failure;
  
  main : process (clk, rst_n)
  begin  -- process main
    if rst_n = '0' then                 -- asynchronous reset (active low)

      dyn_slots: for i in 0 to lut_size_c-(n_agents_g * qos_slots_c)-1 loop
        adaptive_lut_r(i) <= std_logic_vector(to_unsigned ((i mod n_agents_g) +1, id_width_g)); -- 2009-04-06
      end loop dyn_slots;

      qos : for i in lut_size_c-(n_agents_g * qos_slots_c) to lut_size_c-1 loop
        adaptive_lut_r(i) <= std_logic_vector(to_unsigned ((i mod n_agents_g)+1, id_width_g));        
      end loop qos;
      
      prev_lock_r <= '0';
      out_was_r   <= (others => '0');   -- 2009-04-08
      
      
    elsif clk'event and clk = '1' then  -- rising clock edge
      
      adaptive_lut_r <= adaptive_lut_r;
      out_was_r      <= arb_agent;      -- 2009-04-08
      out_was_r      <= adaptive_lut_r(conv_integer(q_from_lfsr(lfsr_width_c-1 downto 1)));
      
        -- Update the LUT when owner uses its turn, i.e. when lock goes 0 -> 1
        -- Updating inserts owner ID to slot(0) and shift the dynamic slots left
        -- (towards bigger indices) by 1.
      if bus_lock_in = '0' then
        prev_lock_r <= '0';
      else
        prev_lock_r <= '1';

        if prev_lock_r = '0' then
          for i in 0 to lut_size_c-(n_agents_g*qos_slots_c)-2 loop
--          for i in 0 to 2**(lfsr_width_c-1)-(n_agents_g*qos_slots_c)-2 loop
            adaptive_lut_r(i+1) <= adaptive_lut_r(i);
          end loop;  -- i
          adaptive_lut_r(0) <= out_was_r;
        end if;
        
      end if;

    end if;
  end process main;

  arb_agent <= adaptive_lut_r(conv_integer(q_from_lfsr(lfsr_width_c-1 downto 1)));

  -- Generate random numbers
  lfsr_1 : lfsr
    generic map (
      width_g => lfsr_width_c
      )
    port map (
      rst_n     => rst_n,
      enable_in => enable_lfsr_r,
      q_out     => q_from_lfsr,
      clk       => clk);


  -- ES 2009-04-06 A process for debugging
  count_tickets : process (clk, rst_n)
    variable ticket_owner_v       : integer := 0;
    variable ticket_count_table_v : ticket_count_table_type;
    
  begin  -- process count_tickets
    if rst_n = '0' then                 -- asynchronous reset (active low)
      ticket_count_table_r <= (others => 0);
      
    elsif clk'event and clk = '1' then  -- rising clock edge
      ticket_count_table_v := (others => 0);

      
      for i in 0 to lut_size_c-1 loop
        ticket_owner_v                        := to_integer(signed(adaptive_lut_r(i)));
        ticket_count_table_v (ticket_owner_v) := ticket_count_table_v (ticket_owner_v) +1;
      end loop;  -- i

      ticket_count_table_r <= ticket_count_table_v;
      
    end if;
  end process count_tickets;

  
end rtl;
