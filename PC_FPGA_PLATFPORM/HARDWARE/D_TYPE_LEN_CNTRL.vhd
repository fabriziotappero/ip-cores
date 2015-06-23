----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:37:32 05/03/2011 
-- Design Name: 
-- Module Name:    D_TYPE_LEN_CNTRL - Behavioral 
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity D_TYPE_LEN_CNTRL is
    Port ( rst : in  STD_LOGIC;
           clk : in  STD_LOGIC;
           locked : in  STD_LOGIC;
           trans_en : in  STD_LOGIC;
           d_type : in  STD_LOGIC_VECTOR (2 downto 0);
           d_len : in  STD_LOGIC_VECTOR (15 downto 0);
           d_type_byte : out  STD_LOGIC_VECTOR (7 downto 0);
           d_length_out : out  STD_LOGIC_VECTOR (15 downto 0));
end D_TYPE_LEN_CNTRL;

architecture Behavioral of D_TYPE_LEN_CNTRL is

begin

process(clk)
begin
if rst='1' then
	d_type_byte <= "00000000";
	d_length_out <= "0000000000000000";
else
	if clk'event and clk='1' then
		if locked='1' then
			if trans_en = '1' then			
				if d_type="001" then
					d_type_byte(2 downto 0) <= d_type;
					d_length_out <= d_len+ "0000000000000001";
				elsif d_type="010" then
					d_type_byte(2 downto 0) <= d_type;
					d_length_out(15 downto 1) <= d_len(14 downto 0);
					d_length_out(0)<='1';
				elsif d_type="011" then
					d_type_byte(2 downto 0) <= d_type;
					d_length_out(15 downto 2) <= d_len(13 downto 0);
					d_length_out(1 downto 0)<="01";
				elsif d_type="100" then
					d_type_byte(2 downto 0) <= d_type;
					d_length_out(15 downto 2) <= d_len(13 downto 0);
					d_length_out(1 downto 0)<="01";
				elsif d_type="101" then
					d_type_byte(2 downto 0) <= d_type;
					d_length_out(15 downto 3) <= d_len(12 downto 0);
					d_length_out(2 downto 0)<="001";
				elsif d_type="110" then
					d_type_byte(2 downto 0) <= d_type;
					d_length_out(15 downto 3) <= d_len(12 downto 0);
					d_length_out(2 downto 0)<="001";
				else
					d_type_byte <= "00000000";
					d_length_out <= "0000000000000001";
				end if; 		
			end if;
		else
			d_type_byte <= "00000000";
			d_length_out <= "0000000000000001";
		end if;
	end if;
end if;
end process;


end Behavioral;

