--  Copyright (C) 2004-2005 Digish Pandya <digish.pandya@gmail.com>

--  This program is free software; you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation; either version 2 of the License, or
--  (at your option) any later version.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
--
--  You should have received a copy of the GNU General Public License
--  along with this program; if not, write to the Free Software
--  Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

-- A.3 data_gen.vhd
-- datagenerator system for generating test data feed to lms filter
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity data_gen is
    Port ( clock : in std_logic;
           reset : in std_logic;
           xout : out std_logic_vector(7 downto 0);
           dxout : out std_logic_vector(7 downto 0));
end data_gen;

architecture structural of data_gen is
	-- training sequence generator
	component tr_seq_gen 
	    Port ( clock : in std_logic;
	           reset : in std_logic;
	           data_out : out std_logic_vector(7 downto 0)
			);
	end component;
	-- channel filter
	component const_ch_filt
	    Port ( 
			clock : in std_logic;
	          data_in : in std_logic_vector(7 downto 0);
	          shifted_data_out : out std_logic_vector(7 downto 0);
	          filtered_data_out : out std_logic_vector(7 downto 0)
		     );
	end component;

	signal data : std_logic_vector (7 downto 0);

begin
		-- Test Data generator
		data_generator:
		process(clock,reset)
		begin
			if(clock'event and clock = '1') then
				if (data = "01000000") then
					data <= "11000000";
				else
					data <= "01000000";
				end if;
			end if;
			if(reset = '0') then
					data <= "01000000";
			end if;

		end process;
		-- This Channel Filter will convolve our input Signal
	     channel: const_ch_filt
		port map (
				clock => clock,
		          data_in => data,
		          shifted_data_out => dxout,
		          filtered_data_out => xout
				);

end structural;
