-------------------------------------------------------------------------------
-- function, procedure librery 
-- 
-- 
-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;

package upro_lib is	  


end upro_lib ; 

-----------------------------------------------
-----------------------------------------------

library IEEE;    -- begin of Full adder 
use IEEE.STD_LOGIC_1164.all;

entity fa is 	
port ( x,y,cin,clk : in std_logic ; s,cout:out std_logic ) ;
end fa ;

architecture archi_fa of fa is
begin 						   
	
process (clk)	
begin
	
if (clk'event and (clk = '1') and (clk'last_value = '0')) then	
  s<=(x xor y) xor cin   ;
  cout<=((x xor y) and cin) or (x and y)  ;	
end if;

end process	;
end	archi_fa ;	 --- end of Full adder   

-----------------------------------------------
-----------------------------------------------

library IEEE;    -- begin of select1 ALU  
use IEEE.STD_LOGIC_1164.all;

entity selec1 is  
port ( a1,b1 : in std_logic ; 
       selec : in std_logic_vector (3 downto 0);
	   s1:     out std_logic 
	  ) ;
end selec1 ;

architecture archi_selec1 of selec1 is
begin  
	
process (selec,a1,b1)
begin
	
case selec is 
	when "0001" =>
	s1<= a1;           -- load a1
	when "0010" =>
	s1<= not a1;       -- inverse a1
	when "0011" => 
	s1<=  b1;  	       -- b1-1
	when "0100" =>
	s1<= a1 xor b1;	   -- a1 xor b1
	when "0101" =>
	s1<= a1 and b1;	   -- a1 and b1
	when "0110" =>
	s1<= a1 or b1;	   -- a1 or b1
	when "0111" =>
	s1<= a1 ;		   -- a1 + b1
	when "1000" =>
	s1<= a1 ;		   -- a1 - b1
	when "1001" =>
	s1<= a1 ;		   -- a1 - 1
	when "1010" =>
	s1<= a1 ;		   -- a1 + 1
	when "1011" => 
	s1<=  b1; 	       -- b1+1 
	when "1100" => 	       
	s1<= '0';		   -- not b 
	when others => null ;
	
end case ; 

end process ;
end	archi_selec1 ; -- end of selec1	

-----------------------------------------------
-----------------------------------------------

library IEEE; -- begin of select2 ALU  
use IEEE.STD_LOGIC_1164.all;

entity selec2 is  
port ( b1:     in std_logic ; 
       selec : in std_logic_vector (3 downto 0);
	   s2:     out std_logic 
	  ) ;
end selec2 ;

architecture archi_selec2 of selec2 is
begin 
	
process (selec,b1)
begin
	
case selec is 
	when "0001" =>
	s2<= '0';         -- load a1
	when "0010" =>
	s2<= '0';         -- inverse a1
	when "0011" => 
	s2<= '0'; 		  -- b1-1
	when "0100" =>
	s2<= '0';		  -- a1 xor b1
	when "0101" =>
	s2<= '0';		  -- a1 and b1
	when "0110" =>
	s2<= '0';		  -- a1 or b1
	when "0111" =>
	s2<= b1 ;		  -- a1 + b1
	when "1000" =>
	s2<= not b1 ;	  -- a1 - b1
	when "1001" =>
	s2<= '1' ;		  -- a1 - 1
	when "1010" =>
	s2<= '0' ; 		  -- a1 + 1
	when "1011" => 
	s2<= '1'; 		  -- b1+1 
	when "1100" => 	       
	s2<= not b1 ;	  -- not b 
	when others => null ;
end case ; 

end process ;
end	archi_selec2 ; -- end of selec2		
	
-----------------------------------------------
----------------------------------------------- 

library IEEE; -- debut de select3 ALU  
use IEEE.STD_LOGIC_1164.all;

entity selec3 is  
port ( 
      selec : in std_logic_vector (3 downto 0);
	  s3:     out std_logic 
	  ) ;
end selec3 ;

architecture archi_selec3 of selec3 is
begin  
	
process (selec)	 
begin
	
case selec is 
	when "1000" =>
	s3<= '1' ;	 -- a1-b1
	when "1010" =>
	s3<= '1' ;   -- a1+1
	when "0011" =>
	s3<= '1' ;   -- b1+1
	when others => 
	s3<= '0' ;	 -- others operations 		
end case ;

end process ; 
end	archi_selec3 ; -- end of selec3	 

-----------------------------------------------
----------------------------------------------- 

library IEEE; -- comparison
use IEEE.STD_LOGIC_1164.all;

entity compar1 is  
port ( 
      x :     in  std_logic ;
	  y :     in  std_logic ;
	  ck :    in  std_logic ;
	  Sin0 :  in  std_logic ;
	  Sin1 :  in  std_logic ; 
	  Sout0 : out std_logic ; 
	  Sout1 : out std_logic ;
	  Sout2 : out std_logic 
	  ) ;
end compar1 ;

architecture archi_compar1 of compar1 is 
signal s_in : std_logic_vector (1 downto 0);
begin

process (ck,Sin1,Sin0)
begin 
s_in <= (not Sin1)&(not Sin0) ;	

    if (ck'event and ck='1')then
      if (s_in ="11")then	
	    Sout1<= (x) and (not y) ;		   -- x>y = '1'
		Sout0<= (y) and (not x) ;		   -- x<y = '1'	
		Sout2<= not((y) xor (x)) ;		   -- x=y = '1'	
	  end if ;
	end if ;
	 		
end process ;
end archi_compar1 ; 

-----------------------------------------------
-----------------------------------------------

package body upro_lib is

	
end upro_lib ;  
	

	
	

