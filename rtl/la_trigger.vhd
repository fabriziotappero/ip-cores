-- logic analyser trigger -- ver 1.0
-- Author: Ernest Jamro

--//////////////////////////////////////////////////////////////////////
--//// Copyright (C) 2001 Authors and OPENCORES.ORG                 ////
--////                                                              ////
--//// This source file may be used and distributed without         ////
--/// restriction provided that this copyright statement is not    ////
--//// removed from the file and that any derivative work contains  ////
--//// the original copyright notice and the associated disclaimer. ////
--////                                                              ////
--//// This source file is free software; you can redistribute it   ////
--//// and/or modify it under the terms of the GNU Lesser General   ////
--//// Public License as published by the Free Software Foundation; ////
--//// either version 2.1 of the License, or (at your option) any   ////
--//// later version.                                               ////
--////                                                              ////
--//// This source is distributed in the hope that it will be       ////
--//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
--//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
--//// PURPOSE. See the GNU Lesser General Public License for more  ////
--//// details.                                                     ////
--////                                                              ////
--//// You should have received a copy of the GNU Lesser General    ////
--//// Public License along with this source; if not, download it   ////
--//// from <http://www.opencores.org/lgpl.shtml>                   ////



------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
-- TRIGGER LOGIC (input trig_data when satisfies the trigger condition causes that the data recording starts)

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_misc.all; -- for AND gate

entity la_trigger is
	generic (trig_width: integer:= 8); -- width of the trig data 1<=trig_width<=32
	port (clk, arst: in std_logic;
	-- LA interface
	trig_data: in std_logic_vector(trig_width-1 downto 0); -- data that are alasysed for triger
	trig_now: out std_logic; -- triger data is now presented on the trig_data bus
	-- Control interface (to set and read triger values)
	wr: in std_logic; -- when 1 writes din to triger configuration registers
	adr: in std_logic_vector(3 downto 0);
	dout: out std_logic_vector(7 downto 0);
	din: in std_logic_vector(7 downto 0) );
end la_trigger;

architecture la_trigger_arch of la_trigger is
  signal trig_value: std_logic_vector(trig_width-1 downto 0); -- sets lewel for which reiger should be active
  signal trig_care: std_logic_vector(trig_width-1 downto 0); -- care / or do not care about the input value presented on trig_data
  signal trig_and: std_logic_vector(trig_width-1 downto 0); -- temporal value that goes to trig_width and gate
  signal trig_result: std_logic_vector(trig_width downto 0); -- result of the and gate
  signal dout32value, dout32care: std_logic_vector(31 downto 0); -- dout value extended with zeros
begin
 
  -- trig_value and care registers
t8: if trig_width<=8 generate 
 process(clk, arst) begin
   if arst='1' then trig_value<= (others=>'0'); trig_care<= (others=>'0');
   elsif clk'event and clk='1' then
	if wr='1' then
	   if adr="1000" then trig_value(trig_width-1 downto 0)<= din(trig_width-1 downto 0); end if;
	   if adr="1100" then trig_care(trig_width-1 downto 0)<= din(trig_width-1 downto 0); end if; 
	end if;
   end if;
 end process;
end generate;

t16: if trig_width<=16 and trig_width>8 generate 
 process(clk, arst) begin
   if arst='1' then trig_value<= (others=>'0'); trig_care<= (others=>'0');
   elsif clk'event and clk='1' then
	if wr='1' then
	   if adr="1000" then trig_value(7 downto 0)<= din; end if;
	   if adr="1001" then trig_value(trig_width-1 downto 8)<= din(trig_width-8 downto 0); end if;
	   if adr="1100" then trig_care(7 downto 0)<= din; end if;
	   if adr="1101" then trig_care(trig_width-1 downto 8)<= din(trig_width-8 downto 0); end if;
	 end if;
   end if;
 end process;
end generate;

t24: if trig_width<=24 and trig_width>16 generate 
 process(clk, arst) begin
   if arst='1' then trig_value<= (others=>'0'); trig_care<= (others=>'0');
   elsif clk'event and clk='1' then
	if wr='1' then
	   if adr="1000" then trig_value(7 downto 0)<= din; end if;
	   if adr="1001" then trig_value(15 downto 8)<= din; end if;
   	   if adr="1010" then trig_value(trig_width-1 downto 16)<= din(trig_width-16 downto 0); end if;
	   if adr="1100" then trig_care(7 downto 0)<= din; end if;
	   if adr="1101" then trig_care(15 downto 8)<= din; end if;
	   if adr="1110" then trig_care(trig_width-1 downto 16)<= din(trig_width-16 downto 0); end if;
	 end if;
   end if;
 end process;
end generate;

t32: if trig_width>24 generate 
 process(clk, arst) begin
   if arst='1' then trig_value<= (others=>'0'); trig_care<= (others=>'0');
   elsif clk'event and clk='1' then
	if wr='1' then
	   if adr="1000" then trig_value(7 downto 0)<= din; end if;
	   if adr="1001" then trig_value(15 downto 8)<= din; end if;
   	   if adr="1010" then trig_value(23 downto 16)<= din; end if;
   	   if adr="1011" then trig_value(trig_width-1 downto 24)<= din(trig_width-24 downto 0); end if;
	   if adr="1100" then trig_care(7 downto 0)<= din; end if;
	   if adr="1101" then trig_care(15 downto 8)<= din; end if;
	   if adr="1110" then trig_care(23 downto 16)<= din; end if;
	   if adr="1111" then trig_care(trig_width-1 downto 24)<= din(trig_width-24 downto 0); end if;
	   end if;
   end if;
 end process;
end generate;

			 
  -- trig_now logic
gi: for i in 0 to trig_width-1 generate
  -- trig_and flip-flop (introduces pipelining to speed up the ciruit frequency)
  process(clk, arst) begin
	 if arst='1' then trig_and(i)<= '0';
	 elsif clk'event and clk='1' then
		 trig_and(i)<= not trig_care(i) or not( trig_data(i) xor trig_value(i));
	 end if;
  end process;
end generate;

  -- and gate and flip-flop
  process(clk, arst) begin
	 if arst='1' then trig_now<= '0';
	 elsif clk'event and clk='1' then
       trig_now<= AND_REDUCE(trig_and); -- correct trigger;
	 end if;
  end process;

  -- dout multiplexer
  -- extend MSBs with zeros
  dout32value(trig_width-1 downto 0)<= trig_value;
  dout32care(trig_width-1 downto 0)<= trig_care;
  g31: if trig_width<32 generate
  	dout32value(31 downto trig_width)<= (others=>'0');
  	dout32care(31 downto trig_width)<= (others=>'0');
  end generate;
  
  dout<= dout32value(7 downto 0) when adr(2 downto 0)="000" else
         dout32value(15 downto 8) when adr(2 downto 0)="001" else
	  	 dout32value(23 downto 16) when adr(2 downto 0)="010" else
		 dout32value(31 downto 24) when adr(2 downto 0)="011" else
         dout32care(7 downto 0) when adr(2 downto 0)="100" else
         dout32care(15 downto 8) when adr(2 downto 0)="101" else
	  	 dout32care(23 downto 16) when adr(2 downto 0)="110" else
		 dout32care(31 downto 24) when adr(2 downto 0)="111" else (others=> '-');
end la_trigger_arch;


