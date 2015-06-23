----------------------------------------------------------------------------------
--
--  This file is a part of Technica Corporation Wizardry Project
--
--  Copyright (C) 2004-2009, Technica Corporation  
--
--  This program is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
--
--  You should have received a copy of the GNU General Public License
--  along with this program.  If not, see <http://www.gnu.org/licenses/>.
--
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
-- Module Name: EmPAC_data_popper - Behavioral 
-- Project Name: Wizardry
-- Target Devices: Virtex 4 ML401
-- Description: Pops data off the FIFO's between EmPAC and eRCP.
-- Revision: 1.0
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity EmPAC_popper is
    Port ( clock : in  STD_LOGIC;
           reset : in  STD_LOGIC;
			  field_data_in : in std_logic_vector(31 downto 0);
			  field_type_in : in std_logic_vector(7 downto 0);
			  field_data_out : out std_logic_vector(31 downto 0);
			  field_type_out : out std_logic_vector(7 downto 0);
			  data_ready : out std_logic;
			  pop : out std_logic;
           empac_empty : in  STD_LOGIC;
           empac_empty_1 : in  STD_LOGIC
			  );
end EmPAC_popper;

architecture Behavioral of EmPAC_popper is

type StateType is (idle, pop_init,pop_0,pop_1);
     signal CurrentState,NextState: StateType;

begin

process(clock,reset,field_data_in, field_type_in)
variable field_data_v : std_logic_vector(31 downto 0);
variable field_type_v : std_logic_vector(7 downto 0);
begin
	if(reset ='1') then
		field_data_v := (others => '0');
		field_type_v := (others => '0');
	elsif(rising_edge(clock)) then
		field_data_v := field_data_in;
		field_type_v := field_type_in;
	end if;
field_data_out <= field_data_v;
field_type_out <= field_type_v;
end process;


pop_control: process(CurrentState,empac_empty,empac_empty_1)
--pop_control: process(CurrentState,empac_almost_full,empac_almost_empty,empac_empty)
   
   begin
	
		case (CurrentState) is			
			when idle =>
				if(EmPAC_empty = '1' OR empac_empty_1 = '1') then
					NextState <= idle;
				else
					NextState <= pop_init;
				end if;


--if(empac_almost_full = '0') then
--					NextState <= idle;
--				else
--					NextState <= pop_init;
--				end if;				
			pop <= '0';
			data_ready <= '0';
--			reg_data <= '0';

		
			when pop_init =>
				NextState <= pop_0;							
			pop <= '1';
			data_ready <= '0';
--			reg_data <= '0';
			
			when pop_0 =>
				NextState <= pop_1;							
			pop <= '0';
			data_ready <= '0';
--			reg_data <= '0';
			
			when pop_1 =>
				NextState <= idle;							
--				NextState <= pop_2;							
			pop <= '0';
			data_ready <= '1';
--			reg_data <= '0';
			
--			when pop_2 =>
--				NextState <= check_almost_empty;							
--			pop <= '0';
--			data_ready <= '0';
----			reg_data <= '0';
--
--			when check_almost_empty =>
--				if(empac_almost_empty = '1') then
--					NextState <= idle;
--				else
--					NextState <= pop_init;
--				end if;		
--			pop <= '0';
--			data_ready <= '0';
----			reg_data <= '0';
			
         when others =>
				NextState <= idle;
			pop <= '0';
			data_ready <= '0';
--			reg_data <= '0';

         end case;
   end process pop_control;

nextstatelogic: process(clock, reset)
--(reset,clock)
	begin
--			wait until clock'EVENT and clock = '1'; --WAIT FOR RISING EDGE
--	if(rising_edge(clock)) then
		-- INITIALIZATION
		if (Reset = '1') then
			CurrentState <= idle;
		elsif rising_edge(clock) then
					CurrentState <= NextState;
		end if;
--	end if;
end process nextstatelogic;

end Behavioral;

