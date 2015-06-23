----------------------------------------------------------------------------------
-- Company: OPL Aerospatiale AG
-- Engineer: Owen Lynn <lynn0p@hotmail.com>
-- 
-- Create Date:    16:30:07 09/03/2009 
-- Design Name: 
-- Module Name:    sdram_reader - impl 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: Logic to capture data from the chip after issuing a read command.
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--  Copyright (c) 2009 Owen Lynn <lynn0p@hotmail.com>
--  Released under the GNU Lesser General Public License, Version 3
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

-- I strongly suggest you run this in the post-PAR simulator first and then start
--  making changes to it after looking at what goes on at the post-PAR level. Don't
--  say I didn't warn you. 
-- Why didn't I use the IDDR2 primitives? Map'nPack keeps bitching about how it
--  won't fit into the IOBs with the ODDR2 primitives. I decided the ODDR2s were
--  more important to keep.
-- I'm just capturing the front side of the burst, and letting the back side of
--  the burst fall on the floor. If you want to support both sides of the 2 burst
--  or bigger bursts, you'll need to rework this.
entity sdram_reader is
	port(
		clk270 : in std_logic;
		rst    : in std_logic;
		dq     : in std_logic_vector(15 downto 0);
		data0  : out std_logic_vector(7 downto 0);
		data1  : out std_logic_vector(7 downto 0)
	);
end sdram_reader;

architecture impl of sdram_reader is

	type FSM0_STATES is ( FSM0_START, FSM0_WAIT0, FSM0_CAPTURE, FSM0_END );
	signal fsm0_state : FSM0_STATES;	
	signal reg0 : std_logic_vector(7 downto 0);
	signal reg1 : std_logic_vector(7 downto 0);

begin
	
	data0 <= reg0;
	data1 <= reg1;
	
	process(clk270,rst)
	begin
		if (rst = '1') then
			fsm0_state <= FSM0_START;
		elsif (rising_edge(clk270)) then
			case fsm0_state is
				when FSM0_START =>
					fsm0_state <= FSM0_WAIT0;
				when FSM0_WAIT0 =>
					fsm0_state <= FSM0_CAPTURE;
				when FSM0_CAPTURE =>
					reg0 <= dq(7 downto 0);
					reg1 <= dq(15 downto 8);
					fsm0_state <= FSM0_END;
				when others =>
					fsm0_state <= fsm0_state;
			end case;
		end if;
	end process;

end impl;