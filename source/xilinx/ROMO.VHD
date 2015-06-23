--------------------------------------------------------------------------------
--                                                                            --
--                          V H D L    F I L E                                --
--                          COPYRIGHT (C) 2006                                --
--                                                                            --
--------------------------------------------------------------------------------
--
-- Title       : DCT
-- Design      : MDCT Core
-- Author      : Michal Krepa
--
--------------------------------------------------------------------------------
--
-- File        : ROMO.VHD
-- Created     : Sat Mar 5 7:37 2006
--
--------------------------------------------------------------------------------
--
--  Description : ROM for DCT matrix constant cosine coefficients (odd part)
--
--------------------------------------------------------------------------------

-- 5:0
-- 5:4 = select matrix row (1 out of 4)
-- 3:0 = select precomputed MAC ( 1 out of 16)

library IEEE; 
  use IEEE.STD_LOGIC_1164.all; 
  use ieee.numeric_std.all; 
  use WORK.MDCT_PKG.all;

entity ROMO is 
  port( 
       addr         : in  STD_LOGIC_VECTOR(ROMADDR_W-1 downto 0);
       clk          : in  STD_LOGIC;  
       
       datao        : out STD_LOGIC_VECTOR(ROMDATA_W-1 downto 0) 
  );          
  
end ROMO; 

architecture XILINX of ROMO is  

  component romo_xil
	port 
	 (
	  A: IN std_logic_VECTOR(5 downto 0);
	  CLK: IN std_logic;
	  QSPO: OUT std_logic_VECTOR(13 downto 0)
	  );
  end component;

begin 

  U1 : romo_xil
		port map
		(
			A => addr,
			CLK => clk,
			QSPO => datao
		); 
      
end XILINX;                  

