-------------------------------------------------------------------------------
-- Adress Unit 
-- 
-- 
-------------------------------------------------------------------------------

library IEEE;

use IEEE.STD_LOGIC_1164.all;

entity adress_data is
	port(
	ctrl_adress : in std_logic_vector (1 downto 0);
	adress_8 :    in std_logic_vector (7 downto 0);
	adress_16  :  out std_logic_vector (15 downto 0) 
	     );
end adress_data ; 

architecture archi_adress_data of adress_data is 
signal s_adress_16 : std_logic_vector (15 downto 0);

begin 
	process (ctrl_adress,adress_8) 
	begin
	case ctrl_adress is 
		when "10"=>
		s_adress_16(7 downto 0)<= adress_8 ; 
		when "01"=>	 
		s_adress_16(15 downto 8)<= adress_8 ;
		when "11"=>
		adress_16 <= s_adress_16 ;
		when others =>  
	end case ;
	end process ; 
		
end archi_adress_data ;

--------------------------
--------------------------

library IEEE;

use IEEE.STD_LOGIC_1164.all; 
use IEEE.STD_LOGIC_UNSIGNED.all;

entity pc_adress is
	port ( 
	     pc_inc :           in std_logic ;
	     reset	 :	        in std_logic ;	
		 adress  :          out std_logic_vector (15 downto 0);
		 adress_16_in  :    in std_logic_vector (15 downto 0);
		 ctrl_adress_pc	 :	in std_logic ;
		 ctrl_adress_out :	in std_logic ;
		 ret_adress_out :   out std_logic_vector (15 downto 0);
		 lock_pc : 			in std_logic 
		 );
	  
end pc_adress ;	 

architecture archi_pc_adress  of pc_adress  is 	 
begin

process (reset,pc_inc,ctrl_adress_pc,adress_16_in,ctrl_adress_out)  
variable pc : std_logic_vector (15 downto 0); 
begin 
	
if (ctrl_adress_pc='1')then  
pc := adress_16_in  ;
else 
   if reset = '1' then	
     pc    :="0000000000000000" ;
     adress<="0000000000000000" ;
   else 	
    if (pc_inc'event and pc_inc='1')then		
	  if pc<65535 then
        if (lock_pc='0')then  
		  pc := pc + 1 ; 
      	end if ;
	  else 
        pc:="0000000000000000" ;   
      end if;	
    end if ;  
    end if ;
end if ;


if ctrl_adress_out='1' then
  adress <= pc ; 
  ret_adress_out <= pc ;
end if ;

end process ; 

end archi_pc_adress ;