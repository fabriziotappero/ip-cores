----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    22:44:55 06/21/2012 
-- Design Name: 
-- Module Name:    DMcontrol - Behavioral 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity DMcontrol is
port (
      --clk : in std_logic;
		--From_Alu : in std_logic_vector(31 downto 0);
		--op_code: in std_logic_vector(5 downto 0);
		MemRead: in std_logic;
		MemWrite : in std_logic;
		--IorD : in std_logic;
		--E : out std_logic_vector(1 downto 0);
		We_c : out std_logic_vector(3 downto 0);
		Re_c :out std_logic_vector(3 downto 0);
		Ssr_c:out std_logic_vector(3 downto 0)
		);
end DMcontrol;

architecture Behavioral of DMcontrol is

component DM_cnt_core is
port (
      --clk : in std_logic;
		--From_Alu : in std_logic_vector(31 downto 0);
		--op_code: in std_logic_vector(5 downto 0);
		MemRead: in std_logic;
		MemWrite : in std_logic;
		--IorD : in std_logic;
		--E : out std_logic_vector(1 downto 0);
		We_c : out std_logic_vector(3 downto 0);
		Re_c :out std_logic_vector(3 downto 0);
		Ssr_c:out std_logic_vector(3 downto 0)
);
end component;
begin
DMcontr_d:DM_cnt_core port map (MemRead=>MemRead,MemWrite=>MemWrite,
                                We_c=>We_c,Re_c=>Re_c,Ssr_c=>Ssr_c);

end Behavioral;

