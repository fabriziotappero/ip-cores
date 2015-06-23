--------------------------------------------------------------------------------
--This file is part of fpga_gpib_controller.
--
-- Fpga_gpib_controller is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- Fpga_gpib_controller is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.

-- You should have received a copy of the GNU General Public License
-- along with Fpga_gpib_controller.  If not, see <http://www.gnu.org/licenses/>.
----------------------------------------------------------------------------------
-- Author: Andrzej Paluch
-- 
-- Create Date:    01:04:57 10/01/2011 
-- Design Name: 
-- Module Name:    if_func_SR - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity if_func_SR is
	port(
		-- device inputs
		clk : in std_logic; -- clock
		pon : in std_logic; -- power on
		rsv : in std_logic; -- service request
		-- state inputs
		SPAS : in std_logic; -- serial poll active state (T or TE)
		-- output instructions
		SRQ : out std_logic; -- service request
		-- reported states
		APRS : out std_logic -- affirmative poll response state
	);
end if_func_SR;

architecture Behavioral of if_func_SR is

 -- states
 type SR_STATE is (
  -- negative poll response state
  ST_NPRS,
  -- service request state
  ST_SRQS,
  -- affirmative poll response state
  ST_APRS
 );

 -- current state
 signal current_state : SR_STATE;

 -- predicates
 signal pred1 : boolean;
 signal pred2 : boolean;
 
begin

 -- state machine process
 process(pon, clk) begin
   
	if pon = '1' then
	
	  current_state <= ST_NPRS;
	  
	elsif rising_edge(clk) then
	  
	  case current_state is
	    ------------------
	    when ST_NPRS =>
		   if pred1 then
		     current_state <= ST_SRQS;
			end if;
		 ------------------
		 when ST_SRQS =>
		   if pred2 then
			  current_state <= ST_NPRS;
			elsif SPAS='1' then
			  current_state <= ST_APRS;
			end if;
		 ------------------
		 when ST_APRS =>
		   if pred2 then
			  current_state <= ST_NPRS;
			end if;
		 ------------------
		 when others =>
		   current_state <= ST_NPRS;
       end case;
	end if;
	
 end process;

 -- predicates
 pred1 <= rsv='1' and SPAS='0';
 pred2 <= rsv='0' and SPAS='0';
 
 -- APRS generator
 with current_state select
   APRS <=
		'1' when ST_APRS,
		'0' when others;
 
 -- SRQ generator
 with current_state select
   SRQ <=
		'1' when ST_SRQS,
		'0' when others;
 
end Behavioral;
