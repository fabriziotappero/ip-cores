----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:06:05 01/12/2011 
-- Design Name: 
-- Module Name:    FLEX_CONTROL - Behavioral 
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

entity FLEX_CONTROL is
    Port ( rst : in  STD_LOGIC;
           clk : in  STD_LOGIC;
           r_sof : in  STD_LOGIC;
			  r_usrvld : in STD_LOGIC;
           r_data : in  STD_LOGIC_VECTOR (7 downto 0);
			  r_usrdata: in STD_LOGIC_VECTOR (7 downto 0);
           r_eof : in  STD_LOGIC;
           l_wren : out  STD_LOGIC;
           l_addr : out  STD_LOGIC_VECTOR (5 downto 0);
           l_data : out  STD_LOGIC_VECTOR (7 downto 0);
			  checksum_baseval : out STD_LOGIC_VECTOR(15 downto 0);
			  locked : out  STD_LOGIC
			  );
end FLEX_CONTROL;

architecture Behavioral of FLEX_CONTROL is

component MATCH_CMD_CODE is
    Port ( clk : in  STD_LOGIC;
		     vld : in  STD_LOGIC;
           data_in : in  STD_LOGIC_VECTOR(7 downto 0);
           eof : in  STD_LOGIC;
           cmd_code : in  STD_LOGIC_VECTOR (7 downto 0);
           sig_out : out  STD_LOGIC);
end component;

component MATCH_CMD is
    Port ( rst : in  STD_LOGIC;
           clk : in  STD_LOGIC;
           sof : in  STD_LOGIC;
           vld_i : in  STD_LOGIC;
           val_i : in  STD_LOGIC_VECTOR (7 downto 0);
			  cmd_to_match : in  STD_LOGIC_VECTOR(7 downto 0);
           cmd_match : out  STD_LOGIC);
end component;

signal config_en, ulock_en, wren_checksum_1, wren_checksum_2,local_rst: std_logic;

component CONFIG_CONTROL is
    Port ( rst : in  STD_LOGIC;
           clk : in  STD_LOGIC;
           config_en : in  STD_LOGIC;
			  nxt_sof : in STD_LOGIC;
			  wren : out  STD_LOGIC;
           addr : out  STD_LOGIC_VECTOR (5 downto 0);
			  ulock_en : in  STD_LOGIC;
			  wren_checksum_1 : out STD_LOGIC;
			  wren_checksum_2 : out STD_LOGIC;
			  locked : out  STD_LOGIC
			);
end component;

signal checksum_baseval_t: std_logic_vector(15 downto 0);

begin

MATCH_RST_CODE: MATCH_CMD Port Map
( rst => rst,
  clk => clk,
  sof => r_sof,
  vld_i => r_usrvld,
  val_i => r_usrdata,
  cmd_to_match => "00001111",
  cmd_match => config_en
 );

ulock_en <= '0';

CONFIG_CONTROL_FSM: CONFIG_CONTROL Port Map
( rst => rst,
  clk => clk,
  config_en => config_en,
  nxt_sof => r_sof,
  wren => l_wren,
  addr => l_addr,
  ulock_en => ulock_en,
  wren_checksum_1 => wren_checksum_1,
  wren_checksum_2 => wren_checksum_2,
  locked => locked
);

process(clk)
begin
if rst = '1' then
	checksum_baseval_t <= (others=>'0');
else
	if clk'event and clk='1' then
		if wren_checksum_1='1' then
			checksum_baseval_t(15 downto 8) <= r_data;
		end if;
		if wren_checksum_2='1' then
			checksum_baseval_t(7 downto 0) <= r_data;
		end if;
	end if;
end if;
end process;

checksum_baseval <= checksum_baseval_t;

process(clk)
begin
if clk'event and clk='1' then
	l_data <= r_data;
end if;
end process;

end Behavioral;

