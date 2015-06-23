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
-- Modified    : Dez. 30 2008 - Andreas Bergmann
--               Libs and Typeconversion fixed due Xilinx Synthesis errors
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
--  use ieee.STD_LOGIC_signed.all; 
  use IEEE.STD_LOGIC_arith.all;
  use WORK.MDCT_PKG.all;

entity ROMO is 
  port( 
       addr         : in  STD_LOGIC_VECTOR(ROMADDR_W-1 downto 0);
       clk          : in  STD_LOGIC;  
       
       datao        : out STD_LOGIC_VECTOR(ROMDATA_W-1 downto 0) 
  );          
  
end ROMO; 

architecture RTL of ROMO is  
  type ROM_TYPE is array (0 to 2**ROMADDR_W-1) 
            of STD_LOGIC_VECTOR(ROMDATA_W-1 downto 0);
  constant rom : ROM_TYPE := 
    (
       (others => '0'),
       conv_std_logic_vector( GP,ROMDATA_W ),
       conv_std_logic_vector( FP,ROMDATA_W ),
       conv_std_logic_vector( FP+GP,ROMDATA_W ),
       conv_std_logic_vector( EP,ROMDATA_W ),
       conv_std_logic_vector( EP+GP,ROMDATA_W ),
       conv_std_logic_vector( EP+FP,ROMDATA_W ),
       conv_std_logic_vector( EP+FP+GP,ROMDATA_W ),
       conv_std_logic_vector( DP,ROMDATA_W ),
       conv_std_logic_vector( DP+GP,ROMDATA_W ),
       conv_std_logic_vector( DP+FP,ROMDATA_W ),
       conv_std_logic_vector( DP+FP+GP,ROMDATA_W ),
       conv_std_logic_vector( DP+EP,ROMDATA_W ),
       conv_std_logic_vector( DP+EP+GP,ROMDATA_W ),
       conv_std_logic_vector( DP+EP+FP,ROMDATA_W ),
       conv_std_logic_vector( DP+EP+FP+GP,ROMDATA_W ),    
      
       (others => '0'),
       conv_std_logic_vector( FM,ROMDATA_W ),
       conv_std_logic_vector( DM,ROMDATA_W ),
       conv_std_logic_vector( DM+FM,ROMDATA_W ),
       conv_std_logic_vector( GM,ROMDATA_W ),
       conv_std_logic_vector( GM+FM,ROMDATA_W ),
       conv_std_logic_vector( GM+DM,ROMDATA_W ),
       conv_std_logic_vector( GM+DM+FM,ROMDATA_W ),
       conv_std_logic_vector( EP,ROMDATA_W ),
       conv_std_logic_vector( EP+FM,ROMDATA_W ),
       conv_std_logic_vector( EP+DM,ROMDATA_W ),
       conv_std_logic_vector( EP+DM+FM,ROMDATA_W ),
       conv_std_logic_vector( EP+GM,ROMDATA_W ),
       conv_std_logic_vector( EP+GM+FM,ROMDATA_W ),
       conv_std_logic_vector( EP+GM+DM,ROMDATA_W ),
       conv_std_logic_vector( EP+GM+DM+FM,ROMDATA_W ),
      
       (others => '0'),
       conv_std_logic_vector( EP,ROMDATA_W ),
       conv_std_logic_vector( GP,ROMDATA_W ),
       conv_std_logic_vector( EP+GP,ROMDATA_W ),
       conv_std_logic_vector( DM,ROMDATA_W ),
       conv_std_logic_vector( DM+EP,ROMDATA_W ),
       conv_std_logic_vector( DM+GP,ROMDATA_W ),
       conv_std_logic_vector( DM+GP+EP,ROMDATA_W ),
       conv_std_logic_vector( FP,ROMDATA_W ),
       conv_std_logic_vector( FP+EP,ROMDATA_W ),
       conv_std_logic_vector( FP+GP,ROMDATA_W ),
       conv_std_logic_vector( FP+GP+EP,ROMDATA_W ),
       conv_std_logic_vector( FP+DM,ROMDATA_W ),
       conv_std_logic_vector( FP+DM+EP,ROMDATA_W ),
       conv_std_logic_vector( FP+DM+GP,ROMDATA_W ),
       conv_std_logic_vector( FP+DM+GP+EP,ROMDATA_W ),
    
       (others => '0'),
       conv_std_logic_vector( DM,ROMDATA_W ),
       conv_std_logic_vector( EP,ROMDATA_W ),
       conv_std_logic_vector( EP+DM,ROMDATA_W ),
       conv_std_logic_vector( FM,ROMDATA_W ),
       conv_std_logic_vector( FM+DM,ROMDATA_W ),
       conv_std_logic_vector( FM+EP,ROMDATA_W ),
       conv_std_logic_vector( FM+EP+DM,ROMDATA_W ),
       conv_std_logic_vector( GP,ROMDATA_W ),
       conv_std_logic_vector( GP+DM,ROMDATA_W ),
       conv_std_logic_vector( GP+EP,ROMDATA_W ),
       conv_std_logic_vector( GP+EP+DM,ROMDATA_W ),
       conv_std_logic_vector( GP+FM,ROMDATA_W ),
       conv_std_logic_vector( GP+FM+DM,ROMDATA_W ),
       conv_std_logic_vector( GP+FM+EP,ROMDATA_W ),
       conv_std_logic_vector( GP+FM+EP+DM,ROMDATA_W )
       );

begin   
    
  process(clk)
  begin
   if clk = '1' and clk'event then
	  datao <= rom( CONV_INTEGER(UNSIGNED(addr)) ); 
   end if;
  end process;
      
end RTL;    
          

                

