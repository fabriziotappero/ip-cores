-------------------------------------------------------------------------------
-- Unit comparison
-- 
-- 
-------------------------------------------------------------------------------

library IEEE;

use IEEE.STD_LOGIC_1164.all; 

entity compar is
	port (
	d_in1 :   in  std_logic_vector (8 downto 1);
	d_in2 :   in  std_logic_vector (8 downto 1);
	selec_f : in  std_logic_vector (1 downto 0); 
	clk :	  in std_logic ;
	d_out :   out std_logic 
	     );
end compar ; 

architecture archi_compar  of compar is 

component compar1   
port ( 
      x :     in  std_logic ;
	  y :     in  std_logic ;
	  ck :    in  std_logic ;
	  Sin0 :  in  std_logic ;
	  Sin1 :  in  std_logic ; 
	  Sout0 : out std_logic ; 
	  Sout1 : out std_logic ;
	  Sout2 : out std_logic
	  );
end component ;

signal cc1_compar : std_logic_vector (8 downto 0) ;   
signal cc2_compar : std_logic_vector (8 downto 0) ; 
signal cc3_compar : std_logic_vector (8 downto 1) ;
signal ck : std_logic_vector (8 downto 1) ;
signal res1 : std_logic ;
signal res2 : std_logic ;
signal res3 : std_logic ;

begin 
	
cc1_compar(8)<= '0' ;
cc2_compar(8)<= '0' ;
	
compar_unit : for k in 1 to 8 generate   
	            cmp : compar1 port map (d_in1(k),d_in2(k),ck(k),cc1_compar(k),cc2_compar(k),cc1_compar(k-1),cc2_compar(k-1),cc3_compar(k)); 
	            ck(k)<=clk	;
	          end generate ;
	
res1 <= cc1_compar(1)or cc1_compar(2)or cc1_compar(3)or cc1_compar(4)or cc1_compar(5)or cc1_compar(6)or cc1_compar(7)or cc1_compar(8);
res2 <= cc2_compar(1)or cc2_compar(2)or cc2_compar(3)or cc2_compar(4)or cc2_compar(5)or cc2_compar(6)or cc2_compar(7)or cc2_compar(8);
res3 <= cc3_compar(1)and cc3_compar(2)and cc3_compar(3)and cc3_compar(4)and cc3_compar(5)and cc3_compar(6)and cc3_compar(7)and cc3_compar(8);

process (clk)
begin 
	
	if (clk'event and clk='1')then	
	  case selec_f is 
	  when "01"=>	 
	    if (res1='1') then 	
	      d_out <= '1';	    --in1<in2
	    end if ; 
	  ---------
	  when "10"=>	
	    if (res2='1') then 
	      d_out <= '1';		--in1>in2
	    end if ;
	  --------- 
	  when "11"=>	
	    if (res3='1') then 
	      d_out <= '1';		--in1=in2
	    end if ;
	  ---------
	  when "00"=>	
	    d_out <= '0';
	  when others =>  
	  end case;
	end if; 
	
end process ;	
end archi_compar ;
