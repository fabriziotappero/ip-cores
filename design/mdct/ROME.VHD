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
-- File        : ROME.VHD
-- Created     : Sat Mar 5 7:37 2006
--
--------------------------------------------------------------------------------
--
--  Description : ROM for DCT matrix constant cosine coefficients (even part)
--
--------------------------------------------------------------------------------

-- 5:0
-- 5:4 = select matrix row (1 out of 4)
-- 3:0 = select precomputed MAC ( 1 out of 16)

library IEEE; 
  use IEEE.STD_LOGIC_1164.all;
  use IEEE.STD_LOGIC_arith.all;
  use WORK.MDCT_PKG.all;

entity ROME is 
  port( 
       addr         : in  STD_LOGIC_VECTOR(ROMADDR_W-1 downto 0); 
       clk          : in  STD_LOGIC; 
       
       datao        : out STD_LOGIC_VECTOR(ROMDATA_W-1 downto 0) 
  );         
  
end ROME; 

architecture RTL of ROME is  
  
  type ROM_TYPE is array (0 to (2**ROMADDR_W)-1) 
            of STD_LOGIC_VECTOR(ROMDATA_W-1 downto 0);
  constant rom : ROM_TYPE := 
    (
    (others => '0'),                
     conv_std_logic_vector( AP,ROMDATA_W ),         
     conv_std_logic_vector( AP,ROMDATA_W ),         
     conv_std_logic_vector( AP+AP,ROMDATA_W ),      
     conv_std_logic_vector( AP,ROMDATA_W ),         
     conv_std_logic_vector( AP+AP,ROMDATA_W ),      
     conv_std_logic_vector( AP+AP,ROMDATA_W ),      
     conv_std_logic_vector( AP+AP+AP,ROMDATA_W ),   
     conv_std_logic_vector( AP,ROMDATA_W ),         
     conv_std_logic_vector( AP+AP,ROMDATA_W ),      
     conv_std_logic_vector( AP+AP,ROMDATA_W ),      
     conv_std_logic_vector( AP+AP+AP,ROMDATA_W ),   
     conv_std_logic_vector( AP+AP,ROMDATA_W ),      
     conv_std_logic_vector( AP+AP+AP,ROMDATA_W ),   
     conv_std_logic_vector( AP+AP+AP,ROMDATA_W ),   
     conv_std_logic_vector( AP+AP+AP+AP,ROMDATA_W ),
                                     
                                     
     (others => '0'),                
     conv_std_logic_vector( BM,ROMDATA_W ),         
     conv_std_logic_vector( CM,ROMDATA_W ),         
     conv_std_logic_vector( CM+BM,ROMDATA_W ),      
     conv_std_logic_vector( CP,ROMDATA_W ),         
     conv_std_logic_vector( CP+BM,ROMDATA_W ),      
     (others => '0'),                
     conv_std_logic_vector( BM,ROMDATA_W ),         
     conv_std_logic_vector( BP,ROMDATA_W ),         
     (others => '0'),                
     conv_std_logic_vector( BP+CM,ROMDATA_W ),      
     conv_std_logic_vector( CM,ROMDATA_W ),         
     conv_std_logic_vector( BP+CP,ROMDATA_W ),      
     conv_std_logic_vector( CP,ROMDATA_W ),         
     conv_std_logic_vector( BP,ROMDATA_W ),         
     (others => '0'),                
                                     
                                     
     (others => '0'),                
     conv_std_logic_vector( AP,ROMDATA_W ),         
     conv_std_logic_vector( AM,ROMDATA_W ),         
     (others => '0'),                
     conv_std_logic_vector( AM,ROMDATA_W ),         
     (others => '0'),                
     conv_std_logic_vector( AM+AM,ROMDATA_W ),      
     conv_std_logic_vector( AM,ROMDATA_W ),         
     conv_std_logic_vector( AP,ROMDATA_W ),         
     conv_std_logic_vector( AP+AP,ROMDATA_W ),      
     (others => '0'),                
     conv_std_logic_vector( AP,ROMDATA_W ),         
     (others => '0'),                
     conv_std_logic_vector( AP,ROMDATA_W ),         
     conv_std_logic_vector( AM,ROMDATA_W ),         
     (others => '0'),                
                                     
                                     
     (others => '0'),                
     conv_std_logic_vector( CM,ROMDATA_W ),         
     conv_std_logic_vector( BP,ROMDATA_W ),         
     conv_std_logic_vector( BP+CM,ROMDATA_W ),      
     conv_std_logic_vector( BM,ROMDATA_W ),         
     conv_std_logic_vector( BM+CM,ROMDATA_W ),      
     (others => '0'),                
     conv_std_logic_vector( CM,ROMDATA_W ),         
     conv_std_logic_vector( CP,ROMDATA_W ),         
     (others => '0'),                
     conv_std_logic_vector( CP+BP,ROMDATA_W ),      
     conv_std_logic_vector( BP,ROMDATA_W ),         
     conv_std_logic_vector( CP+BM,ROMDATA_W ),      
     conv_std_logic_vector( BM,ROMDATA_W ),         
     conv_std_logic_vector( CP,ROMDATA_W ),         
     (others => '0')
     );                
  
begin 

  
  process(clk)
  begin
   if clk = '1' and clk'event then
    datao <= rom(CONV_INTEGER(UNSIGNED(addr)) ); 
   end if;
  end process;  
      
end RTL;    

                

