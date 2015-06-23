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
--  entity       = reference_memory64_dp 
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

entity reference_memory64_dp_large is 
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
end reference_memory64_dp_large;

architecture struct of reference_memory64_dp_large is

component dual_port_component
	port (
	addra: IN std_logic_VECTOR(7 downto 0);
	addrb: IN std_logic_VECTOR(7 downto 0);
	clka: IN std_logic;
	clkb: IN std_logic;
	dina: IN std_logic_VECTOR(63 downto 0);
	douta: OUT std_logic_VECTOR(63 downto 0);
	doutb: OUT std_logic_VECTOR(63 downto 0);
	wea: IN std_logic);
end component;


type memory_read_data is array (0 to 7) of std_logic_vector(63 downto 0);
signal read_data1,read_data2 : memory_read_data;
type addr_type is array (0 to 7) of std_logic_vector(7 downto 0);
signal real_addra,real_addrb : addr_type; 
signal rrea,rreb : std_logic_vector(2 downto 0);
signal wen : std_logic_vector(7 downto 0);

begin
        
control1: process(addra,addrb,addrw,wea,we,rea,reb)
variable vwen : std_logic_vector(7 downto 0);
variable vreal_addra,vreal_addrb : addr_type; 

begin

vwen := (others => '0');
for i in 0 to 7 loop
	vreal_addrb(i) := reb(0) & addrb;
	if (wea(3 downto 1) = i and we = '1') then
		vreal_addra(i) := wea(0) & addrw;
		vwen(i) := '1';
	else
		vreal_addra(i) := rea(0) & addra;
	end if;
end loop;

real_addra <= vreal_addra;
real_addrb <= vreal_addrb;
wen <= vwen;

end process;

control2: process(rrea,read_data1)

begin
case rrea is
	when "000" => douta <= read_data1(0); 
	when "001" => douta <= read_data1(1);
	when "010" => douta <= read_data1(2);
	when "011" => douta <= read_data1(3);
	when "100" => douta <= read_data1(4);
	when "101" => douta <= read_data1(5);
	when "110" => douta <= read_data1(6);
	when "111" => douta <= read_data1(7);
	when others => null;
end case;

end process;

control3: process(rreb,read_data1)

begin
case rreb is
	when "000" => doutb <= read_data2(0); 
	when "001" => doutb <= read_data2(1);
	when "010" => doutb <= read_data2(2);
	when "011" => doutb <= read_data2(3);
	when "100" => doutb <= read_data2(4);
	when "101" => doutb <= read_data2(5);
	when "110" => doutb <= read_data2(6);
	when "111" => doutb <= read_data2(7);
	when others => null;
end case;

end process;

memory_components : for i in 0 to 7 generate

dual_port_component_1 : dual_port_component
port map (
	addra =>real_addra(i),
	addrb =>real_addrb(i),
	clka =>clk,
	clkb =>clk,
	dina =>dina,
	douta =>read_data1(i),
	doutb =>read_data2(i),
	wea =>wen(i));
end generate;

regs: process (clk,clear)

begin

if (clear = '1') then
	rrea <= (others => '0');
	rreb <= (others => '0');
elsif rising_edge(clk) then
	if (reset = '1') then
		rrea <= (others => '0');
		rreb <= (others => '0');
	else
		rrea <= rea(3 downto 1);
		rreb <= reb(3 downto 1);
	end if;
end if;
end process;

end;