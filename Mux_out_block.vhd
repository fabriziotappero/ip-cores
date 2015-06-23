----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    19:01:59 06/24/2012 
-- Design Name: 
-- Module Name:    Mux_out_block - Behavioral 
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

entity Mux_out_block is
port (
      clk   : in std_logic;
		Zero_in,EqNq : in std_logic;
		RFmux : in std_logic_vector(2 downto 0);
      Hi_in : in std_logic_vector(31 downto 0);
      Lo_in : in std_logic_vector(31 downto 0);
      Alu_in: in std_logic_vector(31 downto 0);	
      Mdr_fr_out : in std_logic_vector(31 downto 0);
      RF_out: out std_logic_vector(31 downto 0);
		From_N: in std_logic_vector(31 downto 0);
		From_A: in std_logic_vector(31 downto 0);
		From_M: in std_logic_vector(31 downto 0);
		PCSource: in std_logic_vector(1 downto 0);
		NPC_out: out std_logic_vector(31 downto 0)
);
end Mux_out_block;

architecture Behavioral of Mux_out_block is
component RF_mux is
port (
      clk   : in std_logic;
		RFmux : in std_logic_vector(2 downto 0);
      Hi_in : in std_logic_vector(31 downto 0);
      Lo_in : in std_logic_vector(31 downto 0);
      Alu_in: in std_logic_vector(31 downto 0);
      From_N : in std_logic_vector(31 downto 0);		
      Mdr_fr_out : in std_logic_vector(31 downto 0);
      RF_out: out std_logic_vector(31 downto 0)
      );
end component;
component NPC_mux is
port (
      clk   : in std_logic;
		Zero_in,EqNq : in std_logic;
		From_N: in std_logic_vector(31 downto 0);
		From_A: in std_logic_vector(31 downto 0);
		From_M: in std_logic_vector(31 downto 0);
		PCSource: in std_logic_vector(1 downto 0);
		NPC_out: out std_logic_vector(31 downto 0)  
  	);
end component;
begin
Rf_m_o:RF_mux port map(clk=>clk,RFmux=>RFmux,Hi_in=>Hi_in,
                       Lo_in=>Lo_in,Alu_in=>Alu_in,From_N=>From_N,Mdr_fr_out=>Mdr_fr_out,RF_out=>RF_out);
NP_m_o:NPC_mux port map(clk=>clk,Zero_in=>Zero_in,EqNq=>EqNq,From_N=>From_N,From_A=>From_A,From_M=>From_M,
                       PCSource=>PCSource,NPC_out=>NPC_out);
end Behavioral;

