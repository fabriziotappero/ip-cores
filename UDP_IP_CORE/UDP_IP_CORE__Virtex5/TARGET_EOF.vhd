----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:22:56 11/30/2009 
-- Design Name: 
-- Module Name:    TARGET_EOF - Behavioral 
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

entity TARGET_EOF is
    Port ( rst : in  STD_LOGIC;
           clk : in  STD_LOGIC;
           start : in  STD_LOGIC;
			  total_length_from_reg : in STD_LOGIC_VECTOR(15 downto 0);
           eof_O : out  STD_LOGIC);
end TARGET_EOF;

architecture Behavioral of TARGET_EOF is

signal count_end : std_logic:='0';
signal count_en_sig : std_logic:='0';
signal rst_counter : std_logic:='0';

component COUNTER_11B_EN_TRANS is
    Port ( rst : in  STD_LOGIC;
           clk : in  STD_LOGIC;
           count_en : in  STD_LOGIC;
           value_O : inout  STD_LOGIC_VECTOR (10 downto 0));
end component;

signal value_O_tmp : std_logic_vector(10 downto 0);

component comp_11b_equal is
  port (
    qa_eq_b : out STD_LOGIC; 
    clk : in STD_LOGIC := 'X'; 
    a : in STD_LOGIC_VECTOR ( 10 downto 0 ); 
    b : in STD_LOGIC_VECTOR ( 10 downto 0 ) 
  );
end component;

signal last_byte,last_byte_reg_in,last_byte_reg_out : std_logic;

begin

process(clk)
begin
if (rst='1' or count_end='1') then	
	count_en_sig<='0';
	rst_counter<='1';
else
   rst_counter<='0';
	if clk'event and clk='1' then
		if (start='1' and count_en_sig='0') then
			count_en_sig<='1';
		end if;
	end if;
end if;
end process;


COUNT_TRANFERED_BYTES : COUNTER_11B_EN_TRANS port map
(	  rst =>rst_counter,
	  clk =>clk,
	  count_en => count_en_sig,
	  value_O =>value_O_tmp
);

COMP_TO_TARGET_LAST_BYTE : comp_11b_equal port map 
(
   qa_eq_b =>last_byte_reg_in, 
    clk =>clk,
    a =>value_O_tmp,
    b =>total_length_from_reg(10 downto 0)
);

process(clk)
begin
if clk'event and clk='1' then
	last_byte_reg_out<=last_byte_reg_in;
end if;
end process;
eof_O<=not last_byte_reg_out;
count_end<=last_byte_reg_out;
end Behavioral;

