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
-- author: Andrzej Paluch
-- 
-- Create Date:    01:04:57 10/03/2011 
-- Design Name: 
-- Module Name:    if_func_DC - Behavioral 
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

entity if_func_DC is
	port(
		-- device inputs
		clk : in std_logic; -- clock
		-- state inputs
		LADS : in std_logic; -- listener addressed state (L or LE)
		ACDS : in std_logic; -- accept data state (AH)
		-- instructions
		DCL : in std_logic; -- my listen address
		SDC : in std_logic; -- unlisten
		-- local instructions
		clr : out std_logic -- clear device
	);
end if_func_DC;

architecture Behavioral of if_func_DC is

 -- states
 type DC_STATE is (
  -- device clear idle state
  ST_DCIS,
  -- device clear active state
  ST_DCAS
 );

 -- current state
 signal current_state : DC_STATE;

 -- predicates
 signal pred1 : boolean;
 signal pred2 : boolean;
 
begin

 -- state machine process
 process(clk) begin
   
	if rising_edge(clk) then
	  
	  case current_state is
	    ------------------
	    when ST_DCIS =>
		   if pred1 then
		     current_state <= ST_DCAS;
		   end if;
		 ------------------
		 when ST_DCAS =>
		   if pred2 then
    		 current_state <= ST_DCIS;
    	   end if;
		 ------------------
		 when others =>
		   current_state <= ST_DCIS;
       end case;
	end if;
	
 end process;

 -- predicates
 pred1 <= (DCL='1' or (SDC='1' and LADS='1')) and ACDS='1';
 pred2 <= not pred1;
 
 -- clr generator
 with current_state select
   clr <=
		'1' when ST_DCAS,
		'0' when others;
 
end Behavioral;
