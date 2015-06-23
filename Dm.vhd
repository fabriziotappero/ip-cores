----------------------------------------------------------------------------------
-- Company: 
-- Engineer:     Lazaridis Dimitris
-- 
-- Create Date:    21:37:47 06/13/2012 
-- Design Name: 
-- Module Name:    Dm - Behavioral 
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

entity Dm is
port (
      clk    : in std_logic;
		rst : in std_logic;
      Alu_in :in std_logic_vector(31 downto 0);
		MDR_in : in std_logic_vector(31 downto 0);
		--op_code: in std_logic_vector(5 downto 0);
		MemWrite : in std_logic;
		MemRead : in std_logic;
		IorD : in std_logic;
		MDR_out : out std_logic_vector(31 downto 0)  
      --E  : out std_logic_vector(1 downto 0) 
);
end Dm;

architecture Behavioral of Dm is
component dmem is
port (
               clk : in std_logic;
					rst : in std_logic;
					IorD : in std_logic;
					we : in std_logic_vector(3 downto 0);
               en : in std_logic_vector(3 downto 0);
               ssr : in std_logic_vector(3 downto 0);
               address : in std_logic_vector(10 downto 0);
               data_in : in std_logic_vector(31 downto 0);
               data_out : out std_logic_vector(31 downto 0)
					);
end component;					
component DMcontrol is
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
signal We_c,Re_c,Ssr_c : std_logic_vector(3 downto 0);
				
begin
  

dmem_d:dmem port map(clk=>clk,rst=>rst,IorD=>IorD,we=>We_c,en=>Re_c,ssr=>Ssr_c,address=>Alu_in(10 downto 0),
                    data_in=>MDR_in,data_out=>MDR_out);
DMcont_d:DMcontrol port map(MemRead=>MemRead,MemWrite=>MemWrite,
                            We_c=>We_c,Re_c=>Re_c,Ssr_c=>Ssr_c);                      
end Behavioral;

