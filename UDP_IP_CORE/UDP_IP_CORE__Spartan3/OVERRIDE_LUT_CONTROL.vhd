----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:09:25 11/30/2009 
-- Design Name: 
-- Module Name:    OVERRIDE_LUT_CONTROL - Behavioral 
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

entity OVERRIDE_LUT_CONTROL is
    Port ( clk : in  STD_LOGIC;
	        input_addr : in  STD_LOGIC_VECTOR (5 downto 0);
           sel_total_length_MSBs : out  STD_LOGIC;
			  sel_total_length_LSBs : out  STD_LOGIC;
			  sel_header_checksum_MSBs : out  STD_LOGIC;
			  sel_header_checksum_LSBs : out  STD_LOGIC;
			  sel_length_MSBs : out  STD_LOGIC;
			  sel_length_LSBs : out  STD_LOGIC
           );
end OVERRIDE_LUT_CONTROL;

architecture Behavioral of OVERRIDE_LUT_CONTROL is

component comp_6b_equal is
  port (
    qa_eq_b : out STD_LOGIC; 
    clk : in STD_LOGIC := 'X'; 
    a : in STD_LOGIC_VECTOR ( 5 downto 0 ); 
    b : in STD_LOGIC_VECTOR ( 5 downto 0 ) 
  );
end component;

constant total_length_addr1 : std_logic_vector(5 downto 0):="010000";
constant total_length_addr2 : std_logic_vector(5 downto 0):="010001";

constant header_checksum_addr1 : std_logic_vector(5 downto 0):="011000";
constant header_checksum_addr2 : std_logic_vector(5 downto 0):="011001";

constant length_addr1 : std_logic_vector(5 downto 0):="100110";
constant length_addr2 : std_logic_vector(5 downto 0):="100111";


signal sel_header_checksum_MSBs_tmp : std_logic;
signal sel_total_length_MSBs_tmp : std_logic;
signal sel_length_MSBs_tmp : std_logic;

begin

TARGET_TOTAL_LENGTH_1 : comp_6b_equal port map (sel_total_length_MSBs_tmp,clk,input_addr,total_length_addr1);

process(clk)
begin
if clk'event and clk='1' then
	sel_total_length_LSBs<=sel_total_length_MSBs_tmp;
end if;
end process;
sel_total_length_MSBs<=sel_total_length_MSBs_tmp;

--TARGET_TOTAL_LENGTH_2 : comp_6b_equal port map (sel_total_length_LSBs,clk,input_addr,total_length_addr2);

TARGET_HEADER_CHECKSUM_1 : comp_6b_equal port map (sel_header_checksum_MSBs_tmp,clk,input_addr,header_checksum_addr1);
process(clk)
begin
if clk'event and clk='1' then
	sel_header_checksum_LSBs<=sel_header_checksum_MSBs_tmp;
end if;
end process;

sel_header_checksum_MSBs<=sel_header_checksum_MSBs_tmp;



--TARGET_HEADER_CHECKSUM_2 : comp_6b_equal port map (sel_header_checksum_LSBs,clk,input_addr,header_checksum_addr2);

TARGET_LENGTH_1 : comp_6b_equal port map (sel_length_MSBs_tmp,clk,input_addr,length_addr1);

process(clk)
begin
if clk'event and clk='1' then
	sel_length_LSBs<=sel_length_MSBs_tmp;
end if;
end process;

sel_length_MSBs<=sel_length_MSBs_tmp;
--TARGET_LENGTH_2 : comp_6b_equal port map (sel_length_LSBs,clk,input_addr,length_addr2);

end Behavioral;

