-------------------------------------------------------------------------------
-- Descritpion: Dynamic arbitration algorith, includes lfsr+lut.
--              This block grants turns to agents. Each agents has "lottery
--              tickets" and linear feedabck shift register selects the winner
--              pseudorandomly.
--              Part of the tickets are given statically and part are given
--              to the most active agents. Having more tickets increases the
--              probability of winning.
-- Project    : Nocbench, Funbase
-------------------------------------------------------------------------------
-- File       : dyn_arb.vhd
-- Author     : Ari Kulmala
-- Created    : 22.05.2006
-- Last update: 2011-10-12
-- Description: dynamic arbitration algorithm
-------------------------------------------------------------------------------
-- Copyright (c) 2006 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 22.05.2006  1.0      AK      Created
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
--use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all; 

entity dyn_arb is
  
  generic (
    id_width_g : integer := 0;
    n_agents_g : integer := 0);

  port (
    clk           : in  std_logic;
    rst_n         : in  std_logic;
    bus_lock_in   : in  std_logic;
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

  -- LUT is divided inot two halves: fixed (qos) and dunamically updated part
  -- Define how many fixed slots per agent
  constant qos_slots_c   : integer := 1;  
  -- move this constant to generic (note by ES 2011-10-12)


  
  -- Signals for Linear Feedback Shift Register (LFSR) that generates (pseudo)
  -- random numbers
  constant lfsr_width_c : integer := 5;
  signal   q_from_lfsr  : std_logic_vector(lfsr_width_c-1 downto 0);  --(pseudo-)rand value
  signal   enable_lfsr  : std_logic;


  -- Look-up table that stores the "lottery tickets"
--  constant lut_size_c     : integer := 2**(lfsr_width_c-1);
  constant lut_size_c     : integer := 2**(lfsr_width_c);
  type     turn_lut_array is array (lut_size_c-1 downto 0) of std_logic_vector(id_width_g-1 downto 0);
  signal   adaptive_lut_r : turn_lut_array;

  
  signal prev_lock_r   : std_logic;     -- for edge detection
  signal winner        : std_logic_vector(id_width_g-1 downto 0);  -- winner

  --signal prev_winner_r : std_logic_vector(id_width_g-1 downto 0);


  -- ES 2009-04-06
  -- Calculate LUT statistics for debug. Simulation purposes only.
  -- Modelsim may obtimize this away, so you must start simulation with
  -- optimizations disabled : vsim -novopt tb_hibiv2_lat etc.
  type   ticket_count_table_type is array (n_agents_g+1-1 downto 0) of integer;
  signal ticket_count_table_r : ticket_count_table_type;

  
begin  -- rtl

  assert lut_size_c >= n_agents_g * qos_slots_c report "Too many qos slots" severity failure;
  


  -- Generate random numbers
  lfsr_1 : lfsr
    generic map (
      width_g => lfsr_width_c
      )
    port map (
      rst_n     => rst_n,
      enable_in => enable_lfsr,
      q_out     => q_from_lfsr,
      clk       => clk
      );
  enable_lfsr <= not bus_lock_in;
  
  -- Select the winner from LUT
  -- This creates a rather large multiplexer tree. Critical path comes from
  -- LFSR and goes then through muxes
  winner <= adaptive_lut_r(to_integer(unsigned(q_from_lfsr)));
  --  winner <= adaptive_lut_r(conv_integer(q_from_lfsr(lfsr_width_c-1 downto 1)));
  --  winner <= adaptive_lut_r(to_integer(unsigned(q_from_lfsr(lfsr_width_c-1 downto 1))));

  arb_agent_out <= winner; 
  -- arb_agent_out <= prev_winner_r; -- test what happens



  
  -- Update the LUT dynamically
  main : process (clk, rst_n)
  begin  -- process main
    if rst_n = '0' then                 -- asynchronous reset (active low)

      -- Initialize the both parts of the LUT
      dyn_slots: for i in 0 to lut_size_c-(n_agents_g * qos_slots_c)-1 loop
        adaptive_lut_r(i) <= std_logic_vector(to_unsigned ((i mod n_agents_g) +1, id_width_g)); -- 2009-04-06
      end loop dyn_slots;

      qos : for i in lut_size_c-(n_agents_g * qos_slots_c) to lut_size_c-1 loop
        adaptive_lut_r(i) <= std_logic_vector(to_unsigned ((i mod n_agents_g)+1, id_width_g));        
      end loop qos;

      
      prev_lock_r   <= '0';
      --prev_winner_r <= (others => '0');
      
      
    elsif clk'event and clk = '1' then  -- rising clock edge
      
      adaptive_lut_r <= adaptive_lut_r;
      --prev_winner_r  <= winner;        
      
      -- Update the LUT when owner uses its turn, i.e. when lock goes 0 -> 1
      -- Updating inserts owner ID to slot(0) and shift the dynamic slots left
      -- (towards bigger indices) by 1.
      if bus_lock_in = '0' then
        prev_lock_r <= '0';
      else
        prev_lock_r <= '1';

        if prev_lock_r = '0' then
          for i in 0 to lut_size_c-(n_agents_g*qos_slots_c)-2 loop
            adaptive_lut_r(i+1) <= adaptive_lut_r(i);
          end loop;  -- i
          adaptive_lut_r(0) <= winner; --prev_winner_r;
        end if;        
      end if;                           -- bus_lock_in
    end if;                             -- rst_n/clk'event
  end process main;

  

  -- Count on every clk cycle how many tickets each agents has
  -- This is just for debugging! 
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
