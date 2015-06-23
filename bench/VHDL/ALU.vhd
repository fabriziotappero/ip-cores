-------------------------------------------------------------------------------
-- ALU 
-- 12 opcodes
-- 
-------------------------------------------------------------------------------

library IEEE;

use IEEE.STD_LOGIC_1164.all;

entity FA_8bits is
	port (
	clk : in std_logic ;
	selec : in  std_logic_vector (3 downto 0);
	FA_in1 : in  std_logic_vector (7 downto 0);
	FA_in2 : in  std_logic_vector (7 downto 0);
	FA_out : out std_logic_vector (7 downto 0);
    carry   : out std_logic ;  
	overf : out std_logic 
	);
end FA_8bits ; 

architecture archi_FA_8bits of FA_8bits is  

signal cc_FA :   std_logic_vector (8 downto 0);	   
signal out2FA1 : std_logic_vector (7 downto 0);	   
signal out2FA2 : std_logic_vector (7 downto 0);	   
signal ck :      std_logic_vector (7 downto 0);    
signal c0 :      std_logic ; 					   


component FA 	  -- Full adder
port (	
      x,y,cin,clk : in std_logic ;
      s,cout : out std_logic 
	  );
end component ;	 

component selec1  -- select logic unit
port ( 
      a1,b1 : in std_logic ; 
      selec : in std_logic_vector (3 downto 0);
	  s1: out std_logic 
	  ) ;
end component ;

component selec2  -- select arithmitic unit
port (
      b1 : in std_logic ; 
      selec : in std_logic_vector (3 downto 0);
	  s2: out std_logic 
	  );
end component ;

begin  
	
carry_unit : entity work.selec3(archi_selec3)    
	        port map (selec,c0);	
cc_FA(0) <= c0;	


Logic_unit :for k in 7 downto 0 generate 	    

	           FA_8bits  : selec1 port map (FA_in1(k),FA_in2(k),selec,out2FA1(k));
			 
            end generate Logic_unit ;

Arith_unit :for k in 7 downto 0 generate 	     

	           FA_8bits  : selec2 port map (FA_in2(k),selec,out2FA2(k));
			
            end generate Arith_unit ;


FullA_unit :for k in 7 downto 0 generate 	

	           FA_8bits  : fa port map (out2FA1(k),out2FA2(k),cc_FA(k),ck(k),FA_out(k),cc_FA(k+1));  -- les blocs d'additionaire complet
			   ck(k)<=clk ;	
				   
            end generate FullA_unit ; 

carry<=cc_FA(8);
overf<=cc_FA(7) xor cc_FA(8);	  		

end archi_FA_8bits ;	
	