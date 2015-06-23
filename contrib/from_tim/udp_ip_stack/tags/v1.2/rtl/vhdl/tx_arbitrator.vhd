----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    08:03:30 06/04/2011 
-- Design Name: 
-- Module Name:    tx_arbitrator - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 	arbitrate between two sources that want to transmit onto a bus
--						handles arbitration and multiplexing
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Revision 0.02 - Made sticky on port M1 to optimise access on this port and allow immediate grant
-- Revision 0.03 - Added first
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity tx_arbitrator is
    port (
		clk				: in std_logic;
		reset				: in std_logic;
		
		req_1				: in  std_logic;
		grant_1			: out std_logic;
      data_1         : in  std_logic_vector(7 downto 0);	-- data byte to tx
      valid_1        : in  std_logic;							-- tdata is valid
      first_1        : in  std_logic;							-- indicates first byte of frame
      last_1         : in  std_logic;							-- indicates last byte of frame

		req_2				: in  std_logic;
		grant_2			: out std_logic;
      data_2         : in  std_logic_vector(7 downto 0);	-- data byte to tx
      valid_2        : in  std_logic;							-- tdata is valid
      first_2        : in  std_logic;							-- indicates first byte of frame
      last_2         : in  std_logic;							-- indicates last byte of frame
		
      data         	: out  std_logic_vector(7 downto 0);	-- data byte to tx
      valid        	: out  std_logic;							-- tdata is valid
      first         	: out  std_logic;							-- indicates first byte of frame
      last         	: out  std_logic							-- indicates last byte of frame
    );
end tx_arbitrator;

architecture Behavioral of tx_arbitrator is

	type grant_type is (M1,M2);

	signal grant :	grant_type;
	
begin
	combinatorial : process (
		grant,
		data_1, valid_1, first_1, last_1,
		data_2, valid_2, first_2, last_2
		)
	begin
		-- grant outputs
		case grant is
			when M1 =>
				grant_1 <= '1';
				grant_2 <= '0';
			when M2 =>
				grant_1 <= '0';
				grant_2 <= '1';
		end case;
		
		-- multiplexer
		if grant = M1 then
			data <= data_1;
			valid <= valid_1;
			first <= first_1;
			last <= last_1;
		else
			data <= data_2;
			valid <= valid_2;
			first <= first_2;
			last <= last_2;
		end if;
	end process;
	
	sequential : process (clk, reset, req_1, req_2, grant)
	begin
		if rising_edge(clk) then
			if reset = '1' then
				grant <= M1;
			else
				case grant is
					when M1 =>
						if req_1 = '1' then
							grant <= M1;
						elsif req_2 = '1' then
							grant <= M2;
						end if;
					when M2 =>
						if req_2 = '1' then
							grant <= M2;
						else
							grant <= M1;
						end if;
				end case;
			end if;
		end if;
	end process;


end Behavioral;

