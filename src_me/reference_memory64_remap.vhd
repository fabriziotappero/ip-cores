----------------------------------------------------------------------------
--  This file is a part of the LM VHDL IP LIBRARY
--  Copyright (C) 2009 Jose Nunez-Yanez
--
--  This program is free software; you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation; either version 2 of the License, or
--  (at your option) any later version.
--
--  See the file COPYING for the full details of the license.
--
--  The license allows free and unlimited use of the library and tools for research and education purposes. 
--  The full LM core supports many more advanced motion estimation features and it is available under a 
--  low-cost commercial license. See the readme file to learn more or contact us at 
--  eejlny@byacom.co.uk or www.byacom.co.uk
--------------------------------------
--  entity       = reference_memory64_remap  
--  version      = 1.0              
--  last update  = 08/10/06         
--  author       = Jose Nunez       
--------------------------------------


-- wrapper for reference memory remaps addresses

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use IEEE.Numeric_STD.all;
use IEEE.std_logic_unsigned."+";
use IEEE.std_logic_unsigned."-";
use IEEE.std_logic_unsigned."=";

entity reference_memory64_remap is -- This memory stores the 5x7 reference data (1120 words of 64 bit)
	port (                          -- It also remaps the addresses
	addr_r: in std_logic_vector(10 downto 0);
	addr_w: in std_logic_vector(10 downto 0);
      enable_hp_inter : in std_logic; -- working in interpolation mode
	clk: in std_logic;
	start : in std_logic;
	next_configuration : in std_logic; -- move to the next configuration
	start_row : in std_logic;
	reset : in std_logic;
	clear : in std_logic;
	din: in std_logic_vector(63 downto 0);
	dout: out std_logic_vector(63 downto 0);
   dout2 : out std_logic_vector(63 downto 0); -- from the second read port
	we: in std_logic);
end reference_memory64_remap;

architecture struct of reference_memory64_remap is

component reference_memory64_dp_large
	port (
	we : in std_logic;
	addra: in std_logic_VECTOR(6 downto 0);
	addrb: in std_logic_VECTOR(6 downto 0);
	addrw : in std_logic_vector(6 downto 0);
	clk: in std_logic;
	clear : in std_logic;
	reset : in std_logic;
	dina: in std_logic_VECTOR(63 downto 0);
	douta: out std_logic_VECTOR(63 downto 0);
	doutb: out std_logic_VECTOR(63 downto 0);
	wea: in std_logic_vector(3 downto 0);
	rea : in std_logic_vector(3 downto 0);
	reb : in std_logic_vector(3 downto 0));
end component;

type memory_map_type is (idle,zero,one,two,three,four,five,six,seven); -- 8 different memory configurations

type state_type is record
	memory_map : memory_map_type;
end record;

signal r, r_in: state_type; 
signal real_addr,real_addr2,real_addr_w: std_logic_vector(6 downto 0);
signal rea,reb,wea : std_logic_vector(3 downto 0);

begin
    
    
control: process(r,addr_r,addr_w,next_configuration,start)

variable v : state_type;
variable vreal_addr_r,vreal_addr_w: std_logic_vector(10 downto 0);
variable vrea,vreb,vwea : std_logic_vector(3 downto 0);

begin

v.memory_map := r.memory_map;
vrea := (others => '0');
vreb := (others => '0');
vreal_addr_r := addr_r;
vreal_addr_w := addr_w;

case v.memory_map is
    
    when idle =>
	  if (start = '1') then 
           v.memory_map := zero;
        end if;
    when zero =>
	  vreal_addr_w(3 downto 0) := addr_w(3 downto 0) + "1110";
        if (next_configuration = '1') then 
           v.memory_map := one;
        end if;
    when one =>
        vreal_addr_r(3 downto 0) := addr_r(3 downto 0) + "0010"; -- a full macroblock (two addresses) to the right
	  vreal_addr_w := addr_w;
        if (next_configuration = '1') then 
           v.memory_map := two;
        end if;
    when two =>
        vreal_addr_r(3 downto 0) := addr_r(3 downto 0) + "0100"; -- and so on
	  vreal_addr_w(3 downto 0) := addr_w(3 downto 0) + "0010";
        if (next_configuration = '1') then 
           v.memory_map := three;
        end if;
    when three =>
        vreal_addr_r(3 downto 0) := addr_r(3 downto 0) + "0110";
	  vreal_addr_w(3 downto 0) := addr_w(3 downto 0) + "0100";
        if (next_configuration = '1') then 
           v.memory_map := four;
        end if;  
    when four =>
        vreal_addr_r(3 downto 0) := addr_r(3 downto 0) + "1000"; 
	  vreal_addr_w(3 downto 0) := addr_w(3 downto 0) + "0110";
        if (next_configuration = '1') then 
           v.memory_map := five;
        end if;
   when five =>
        vreal_addr_r(3 downto 0) := addr_r(3 downto 0) + "1010"; 
	  vreal_addr_w(3 downto 0) := addr_w(3 downto 0) + "1000";
        if (next_configuration = '1') then 
           v.memory_map := six;
        end if;
   when six =>
        vreal_addr_r(3 downto 0) := addr_r(3 downto 0) + "1100"; 
	  vreal_addr_w(3 downto 0) := addr_w(3 downto 0) + "1010";
        if (next_configuration = '1') then 
           v.memory_map := seven;
        end if;
   when seven =>
        vreal_addr_r(3 downto 0) := addr_r(3 downto 0) + "1110"; 
	  vreal_addr_w(3 downto 0) := addr_w(3 downto 0) + "1100";
        if (next_configuration = '1') then 
           v.memory_map := zero;
        end if;
    when others => null;
        
end case;

r_in.memory_map <= v.memory_map;
vrea := vreal_addr_r(3 downto 0);
vreb := vreal_addr_r(3 downto 0);
if (enable_hp_inter = '1') then
	vreb := vreb - "0001";
else
	vreb := vreb + "0001";
end if;
vwea := vreal_addr_w(3 downto 0);

real_addr <= vreal_addr_r(10 downto 4);
real_addr2 <= vreal_addr_r(10 downto 4);
real_addr_w <= vreal_addr_w(10 downto 4);
rea <= vrea;
reb <= vreb;
wea <= vwea;

end process control;

reference_memory64_1 : reference_memory64_dp_large
port map (
	we => we,
	addra =>real_addr,
	addrb =>real_addr2,
	addrw =>real_addr_w,
	clk =>clk,
	clear => clear,
	reset => reset,
	dina =>din,
	douta =>dout,
	doutb =>dout2,
	wea =>wea,
	rea =>rea,
	reb =>reb);


regs: process (clk,clear)

begin

if (clear = '1') then
	r.memory_map <= idle;
elsif rising_edge(clk) then
	if (reset = '1' or start_row ='1') then
		r.memory_map <= idle;
	else
		r <= r_in;
	end if;
end if;

end process regs;

end;