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
-------------------------------------------
--  entity       = concatenate           --
--  version      = 1.0                   --
--  last update  = 1/08/06               --
--  author       = Jose Nunez            --
-------------------------------------------


-- FUNCTION
-- this unit makes sure that 8 valid pixels are assemble depending on byte address 

library ieee;
use ieee.std_logic_1164.all;
use IEEE.std_logic_unsigned."+";

entity concatenate64 is
	port(
	addr : in std_logic_vector(2 downto 0);
	clk : in std_logic;
	clear : in std_logic;
	reset : in std_logic;
	din : in std_logic_vector(63 downto 0);
	din2 : in std_logic_vector(63 downto 0);
	dout : out std_logic_vector(63 downto 0);
	enable : in std_logic;
	enable_hp_inter : in std_logic; -- working in interpolation mode
      quick_valid : out std_logic; --as valid but one cycle earlier
	valid : out std_logic);  -- indicates when 64 valid bits are in the output
end concatenate64;


architecture behav of concatenate64 is

type register_type is record
	data : std_logic_vector(63 downto 0);
      valid : std_logic; -- bytes are valid
      pipe_din : std_logic_vector(63 downto 0);
      pipe_din2 : std_logic_vector(63 downto 0);
      pipe_addr : std_logic_vector(2 downto 0);
      pipe_enable_hp_inter : std_logic;
      pipe_enable : std_logic;
end record;

signal r,r_in : register_type;
signal din_temp : std_logic_vector(63 downto 0);

begin


r_in.pipe_din <= din;
r_in.pipe_din2 <= din2;
r_in.pipe_addr <= addr;
r_in.pipe_enable_hp_inter <= enable_hp_inter;
r_in.pipe_enable <= enable;
r_in.valid <= r.pipe_enable;



valid <= '1' when r.valid = '1' else '0';
quick_valid <= '1' when r.pipe_enable= '1' else '0';


shift_data : process(r)


begin


   if (r.pipe_enable_hp_inter = '0') then -- when interpolating the good data is at the beginning
       
	case r.pipe_addr is

	   when "000" =>
		   din_temp <= r.pipe_din;
	   when "001" =>
		   din_temp <= r.pipe_din(55 downto 0)& r.pipe_din2(63 downto 56);	
	   when "010" =>
		   din_temp <= r.pipe_din(47 downto 0) & r.pipe_din2(63 downto 48);		
	   when "011" =>
		   din_temp <= r.pipe_din(39 downto 0) & r.pipe_din2(63 downto 40);	
	   when "100" =>
		   din_temp <= r.pipe_din(31 downto 0)& r.pipe_din2(63 downto 32);	
	   when "101" =>
		   din_temp <= r.pipe_din(23 downto 0)& r.pipe_din2(63 downto 24);		
	   when "110" =>
		   din_temp <= r.pipe_din(15 downto 0)& r.pipe_din2(63 downto 16);		
	   when "111" =>
		   din_temp <= r.pipe_din(7 downto 0)& r.pipe_din2(63 downto 8);	
      when others => null;
    end case;
    else
           
	case r.pipe_addr is
	   when "000" =>
		din_temp <= r.pipe_din2;
	   when "001" =>
		din_temp <=  r.pipe_din2(55 downto 0) & r.pipe_din(63 downto 56);	
	   when "010" => 
	      din_temp <= r.pipe_din2(47 downto 0) & r.pipe_din(63 downto 48);
	   when "011" => 
	      din_temp <= r.pipe_din2(39 downto 0) & r.pipe_din(63 downto 40); 
	   when "100" => 
	      din_temp <= r.pipe_din2(31 downto 0) & r.pipe_din(63 downto 32); 	
	   when "101" =>
		din_temp <= r.pipe_din2(23 downto 0) & r.pipe_din(63 downto 24); 	
	   when "110" =>
		din_temp <= r.pipe_din2(15 downto 0) & r.pipe_din(63 downto 16);
	   when "111" =>
		din_temp <= r.pipe_din2(7 downto 0) & r.pipe_din(63 downto 8);	
    when others => null;
    end case;
    end if;
    

end process shift_data;

r_in.data <= din_temp;

dout <= r.data;


-- sequential part

regs: process (clk,clear)

begin

if (clear = '1') then
	r.data <= (others => '0');
	r.valid <= '0';
      r.pipe_din <= (others => '0');
	   r.pipe_din2 <= (others => '0');
      r.pipe_addr <= (others => '0');
      r.pipe_enable_hp_inter <= '0';
      r.pipe_enable <= '0';
elsif rising_edge(clk) then
	if (reset = '1') then
    		r.data <= (others => '0');
		r.valid <= '0';
  		r.pipe_din <= (others => '0');
		 r.pipe_din2 <= (others => '0');
            r.pipe_addr <= (others => '0');
            r.pipe_enable_hp_inter <= '0';
            r.pipe_enable <= '0';
	else
		r <= r_in;
	end if;
end if;

end process regs;


--valid <= r.valid;

end behav; -- end of architecture







