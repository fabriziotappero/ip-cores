----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    21:29:54 06/19/2012 
-- Design Name: 
-- Module Name:    Reg_block - Behavioral 
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

entity Reg_block is
port (
      Clk : in std_logic;
		rst : in  STD_LOGIC;
		vector_on : in std_logic_vector(2 downto 0);
		Reg_Write : in std_logic;
		Reg_Imm_not : in std_logic;
		rs : in std_logic_vector(4 downto 0);
		rt : in std_logic_vector(4 downto 0);
		rd : in std_logic_vector(4 downto 0);
		Ext_sz_c   : in std_logic;
		immed_addr : in std_logic_vector(15 downto 0);
		Bus_W : in std_logic_vector(31 downto 0);
		A2Alu : out std_logic_vector(31 downto 0);
		B2Alu : out std_logic_vector(31 downto 0);
      I2Alu : out std_logic_vector(31 downto 0)

);
end Reg_block;

architecture Behavioral of Reg_block is
component reg_file_block is
port(
		Clk : in std_logic;
		rst : in  STD_LOGIC;
		vector_on : in std_logic_vector(2 downto 0);
		Reg_Write : in std_logic;
		Reg_Imm_not : in std_logic;
		rs : in std_logic_vector(4 downto 0);
		rt : in std_logic_vector(4 downto 0);
		rd : in std_logic_vector(4 downto 0);
		Bus_W : in std_logic_vector(31 downto 0);
		Bus_A : out std_logic_vector(31 downto 0);
		Bus_B : out std_logic_vector(31 downto 0)
		--result: out std_logic_vector(31 downto 0)
);
end component;
component Ext_sz is
port (
      clk : in  STD_LOGIC;
	   rst : in  STD_LOGIC;
		immed_addr : in std_logic_vector(15 downto 0);
		Ext_sz_c   : in std_logic;
      Ext_sz     : out std_logic_vector(31 downto 0)


); 
end component;

--signal Bus_A,Bus_B :std_logic_vector(31 downto 0);         
begin
Reg_block_b:reg_file_block port map(Clk=>Clk,rst=>rst,vector_on=>vector_on,Reg_Write=>Reg_Write,Reg_Imm_not=>Reg_Imm_not,
                                    rs=>rs,rt=>rt,rd=>rd,Bus_W=>Bus_W,Bus_A=>A2Alu,Bus_B=>B2Alu);
Ext_sz_b:Ext_sz port map (clk=>clk,rst=>rst,immed_addr=>immed_addr,
                                    Ext_sz_c =>Ext_sz_c,Ext_sz=>I2Alu);
end Behavioral;

