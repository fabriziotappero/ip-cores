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
-- File        : ROMQ.VHD
-- Created     : Sun Aug 27 18:09 2006
--
--------------------------------------------------------------------------------
--
--  Description : ROM for DCT quantizer matrix
--
--------------------------------------------------------------------------------

library IEEE; 
  use IEEE.STD_LOGIC_1164.all; 
  use ieee.numeric_std.all; 

entity ROMQ is 
  generic 
    ( 
      ROMADDR_W     : INTEGER := 6;
      ROMDATA_W     : INTEGER := 8
    );
  port( 
       addr         : in  STD_LOGIC_VECTOR(ROMADDR_W-1 downto 0);
       clk          : in  STD_LOGIC;  
       
       datao        : out STD_LOGIC_VECTOR(ROMDATA_W-1 downto 0) 
  );          
  
end ROMQ; 

architecture RTL of ROMQ is  

  type ROMQ_TYPE is array (0 to 2**ROMADDR_W-1) 
            of INTEGER range 0 to 2**ROMDATA_W-1;
  
  constant rom : ROMQ_TYPE := 
  -- (
  -- 16,11,10,16,24,40,51,61,
  -- 12,12,14,19,26,58,60,55,
  -- 14,13,16,24,40,57,69,56,
  -- 14,17,22,29,51,87,80,62,
  -- 18,22,37,56,68,109,103,77,
  -- 24,35,55,64,81,104,113,92,
  -- 49,64,78,87,103,121,120,101,
  -- 72,92,95,98,112,100,103,99);
                          (
                 --8,6,6,7,6,5,8,
                 --7,7,7,9,9,8,10,12,
                 --20,13,12,11,11,12,25,18,19,15,20,29,
                 --26,31,30,29,26,28,28,32,36,46,39,32,
                 --34,44,35,28,28,40,55,41,44,48,49,52,52,52,
                 --31,39,57,61,56,50,60,46,51,52,50
                   
                   
                   

                          1,1,1,1,1,1,1,1,
                          1,1,1,1,1,1,1,1,
                          1,1,1,1,1,1,1,1,
                          1,1,1,1,1,1,1,1,
                          1,1,1,1,1,1,1,1,
                          1,1,1,1,1,1,1,1,
                          1,1,1,1,1,1,1,1,
                          1,1,1,1,1,1,1,1
                          );
            
 

  signal addr_reg : STD_LOGIC_VECTOR(ROMADDR_W-1 downto 0);
begin   
  
  datao <= STD_LOGIC_VECTOR(TO_UNSIGNED( rom( TO_INTEGER(UNSIGNED(addr_reg)) ), ROMDATA_W)); 
  
  process(clk)
  begin
   if clk = '1' and clk'event then
     addr_reg <= addr;
   end if;
  end process;
      
end RTL;    
