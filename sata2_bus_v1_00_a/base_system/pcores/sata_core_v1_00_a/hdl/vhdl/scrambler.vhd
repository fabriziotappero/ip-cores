-- Copyright (C) 2012
-- Ashwin A. Mendon
--
-- This file is part of SATA2 core.
--
-- This program is free software; you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation; either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.  

----------------------------------------------------------------------------------------
-- ENTITY: scrambler 
-- Version: 1.0
-- Author:  Ashwin Mendon 
-- Description: This sub-module implements the Scrambler Circuit for the SATA Protocol
--              The code provides a parallel implementation of the following 
--              generator polynomial                  
--                          16  15  13  4                               
--                  G(x) = x + x + x + x + 1    
--              The output of this scrambler is then XORed with the input data DWORD                           
--              The scrambler is initialized to a value of 0xF0F6. 
--              The first DWORD output of the implementation is equal to 0xC2D2768D
-- PORTS: 
-----------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity scrambler is
  generic(
    CHIPSCOPE             : boolean := false
       );
  port(
    -- Clock and Reset Signals
    clk                   : in  std_logic;
    reset                 : in  std_logic;
    -- ChipScope ILA / Trigger Signals
    scrambler_ila_control : in  std_logic_vector(35 downto 0);
    ---------------------------------------
    -- Signals from/to Sata Link Layer
    scrambler_en          : in  std_logic;
    prim_scrambler        : in  std_logic;
    din_re                : out std_logic;
    data_in               : in  std_logic_vector(0 to 31);
    data_out              : out std_logic_vector(0 to 31);
    dout_we               : out std_logic
      );
end scrambler;

-------------------------------------------------------------------------------
-- ARCHITECTURE
-------------------------------------------------------------------------------
architecture BEHAV of scrambler is

  -------------------------------------------------------------------------------
  -- Constants
  -------------------------------------------------------------------------------
  constant SCRAMBLER_INIT     : std_logic_vector(0 to 15) := x"F0F6";
 
  signal context              : std_logic_vector (15 downto 0);
  signal context_next         : std_logic_vector (31 downto 0);
  signal context_reg          : std_logic_vector (31 downto 0);
  signal data_out_ila         : std_logic_vector (31 downto 0);
  signal dout_we_reg          : std_logic;
  signal dout_we_ila          : std_logic;
  signal din_re_ila           : std_logic;

  -----------------------------------------------------------------------------
  -- ILA Declaration
  -----------------------------------------------------------------------------
  component scrambler_ila
    port (
      control : in std_logic_vector(35 downto 0);
      clk     : in std_logic;
      trig0   : in std_logic_vector(31 downto 0);
      trig1   : in std_logic_vector(31 downto 0);
      trig2   : in std_logic_vector(31 downto 0);
      trig3   : in std_logic_vector(31 downto 0);
      trig4   : in std_logic_vector(15 downto 0);
      trig5   : in std_logic_vector(3 downto 0)
    );
  end component;

-------------------------------------------------------------------------------
-- BEGIN
-------------------------------------------------------------------------------
begin

  -----------------------------------------------------------------------------
  -- PROCESS: SCRAMBLER_PROC
  -- PURPOSE: Registering Signals and Next State
  -----------------------------------------------------------------------------
  SCRAMBLER_PROC : process (clk)
  begin
    if ((clk'event) and (clk = '1')) then
      if (reset = '1') then
        --Initializing internal signals
        context                 <= SCRAMBLER_INIT;
        context_reg             <= (others => '0');
        dout_we_reg             <= '0';
      elsif (scrambler_en = '1') then
        -- Register all Current Signals to their _next Signals
        context                 <= context_next(31 downto 16);
        context_reg             <= context_next;
        dout_we_reg             <= '1';
      else
        context                 <= context;
        context_reg             <= context_reg;
        dout_we_reg             <= '0';
      end if;
    end if;
  end process SCRAMBLER_PROC ;

 context_next(31) <= context(12) xor context(10) xor context(7) xor context(3) xor context(1) xor context(0);
 context_next(30) <= context(15) xor context(14) xor context(12) xor context(11) xor context(9) xor context(6) xor context(3) xor context(2) xor context(0);
 context_next(29) <= context(15) xor context(13) xor context(12) xor context(11) xor context(10) xor context(8) xor context(5) xor context(3) xor context(2)  xor context(1);
 context_next(28) <= context(14) xor context(12) xor context(11) xor context(10) xor context(9) xor context(7) xor context(4) xor context(2) xor context(1)  xor context(0);
 context_next(27) <= context(15) xor context(14) xor context(13) xor context(12) xor context(11) xor context(10) xor context(9) xor context(8) xor context(6)  xor context(1) xor context(0);
 context_next(26) <= context(15) xor context(13) xor context(11) xor context(10) xor context(9) xor context(8) xor context(7) xor context(5) xor context(3)  xor context(0);
 context_next(25) <= context(15) xor context(10) xor context(9) xor context(8) xor context(7) xor context(6) xor context(4) xor context(3) xor context(2);
 context_next(24) <= context(14) xor context(9) xor context(8) xor context(7) xor context(6) xor context(5) xor context(3) xor context(2) xor context(1);
 context_next(23) <= context(13) xor context(8) xor context(7) xor context(6) xor context(5) xor context(4) xor context(2) xor context(1) xor context(0);
 context_next(22) <= context(15) xor context(14) xor context(7) xor context(6) xor context(5) xor context(4) xor context(1) xor context(0);
 context_next(21) <= context(15) xor context(13) xor context(12) xor context(6) xor context(5) xor context(4) xor context(0);
 context_next(20) <= context(15) xor context(11) xor context(5) xor context(4);
 context_next(19) <= context(14) xor context(10) xor context(4) xor context(3);
 context_next(18) <= context(13) xor context(9) xor context(3) xor context(2);
 context_next(17) <= context(12) xor context(8) xor context(2) xor context(1);
 context_next(16) <= context(11) xor context(7) xor context(1) xor context(0);
     
 context_next(15) <= context(15) xor context(14) xor context(12) xor context(10) xor context(6) xor context(3) xor context(0);
 context_next(14) <= context(15) xor context(13) xor context(12) xor context(11) xor context(9) xor context(5) xor context(3) xor context(2);
 context_next(13) <= context(14) xor context(12) xor context(11) xor context(10) xor context(8) xor context(4) xor context(2) xor context(1);
 context_next(12) <= context(13) xor context(11) xor context(10) xor context(9) xor context(7) xor context(3) xor context(1) xor context(0);
 context_next(11) <= context(15) xor context(14) xor context(10) xor context(9) xor context(8) xor context(6) xor context(3) xor context(2) xor context(0);
 context_next(10) <= context(15) xor context(13) xor context(12) xor context(9) xor context(8) xor context(7) xor context(5) xor context(3) xor context(2)  xor context(1);
 context_next(9) <= context(14) xor context(12) xor context(11) xor context(8) xor context(7) xor context(6) xor context(4) xor context(2) xor context(1)  xor context(0);
 context_next(8) <= context(15) xor context(14) xor context(13) xor context(12) xor context(11) xor context(10) xor context(7) xor context(6) xor context(5)  xor context(1) xor context(0);
 context_next(7) <= context(15) xor context(13) xor context(11) xor context(10) xor context(9) xor context(6) xor context(5) xor context(4) xor context(3)  xor context(0);
 context_next(6) <= context(15) xor context(10) xor context(9) xor context(8) xor context(5) xor context(4) xor context(2);
 context_next(5) <= context(14) xor context(9) xor context(8) xor context(7) xor context(4) xor context(3) xor context(1);
 context_next(4) <= context(13) xor context(8) xor context(7) xor context(6) xor context(3) xor context(2) xor context(0);
 context_next(3) <= context(15) xor context(14) xor context(7) xor context(6) xor context(5) xor context(3) xor context(2)   xor context(1);
 context_next(2) <= context(14) xor context(13) xor context(6) xor context(5) xor context(4) xor context(2) xor context(1)   xor context(0);
 context_next(1) <= context(15) xor context(14) xor context(13) xor context(5) xor context(4) xor context(1) xor context(0);
 context_next(0) <= context(15) xor context(13) xor context(4) xor context(0);

 data_out_ila <= (context_reg xor data_in) when prim_scrambler = '0' else (context_reg);

 --dout_we_ila  <= dout_we_reg when scrambler_en = '1' else '0';
 dout_we_ila  <= dout_we_reg;

 din_re_ila   <= '1' when scrambler_en = '1' else '0';
 
 -----------------------------------------------------------------------------
 -- ILA Instantiation
 -----------------------------------------------------------------------------
 data_out <= data_out_ila;
 dout_we  <= dout_we_ila;
 din_re   <= din_re_ila;

 chipscope_gen_ila : if (CHIPSCOPE) generate
   SCRAMBLER_ILA_i : scrambler_ila
    port map (
      control  => scrambler_ila_control,
      clk      => clk,
      trig0    => data_in,
      trig1    => data_out_ila,
      trig2    => context_reg,
      trig3    => context_next,
      trig4    => context,
      trig5(0) => scrambler_en,
      trig5(1) => din_re_ila,
      trig5(2) => dout_we_ila,
      trig5(3) => reset 
    );
  end generate chipscope_gen_ila;
  
end BEHAV;


