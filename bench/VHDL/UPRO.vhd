--=============================================================================
-- Project: basic Microprocessor(ZA208) http://za208.blogspot.com
-- Copyright: GNU General Public License version 3 (GPLv3) (http://www.gnu.org)(http://www.fsf.org/)
-- Author: Hadef Mohamed Yacine, Barkat Cherif 
-- created : 14/04/2008 
-- Revision: 26/05/2008 ; 29/05/2008
-- Last revised: 12/06/2008	
-- Synthesis : synthesis and implement in 'Xilinx :"SPARTAN 3 VQ100"' 
-- Workfile: upro.vhd ;; Workspace : PFE
-- University: Mentouri - Constantine 
-------------------------------------------------------------------------------
-- Description:
-- 	Microprocessor with 28 instructions  
--  (9 instructions of arithmitic and logic calculates)
-------------------------------------------------------------------------------

--=============================================================================

library IEEE;
use IEEE.STD_LOGIC_1164.all;			 
			 
entity upro is
port (
data_in :  in std_logic_vector (7 downto 0);
data_out : out std_logic_vector (7 downto 0);
addrs :    out std_logic_vector (15 downto 0);	
reset :    in std_logic ;
wo :       out std_logic ;
oe :       out std_logic ;
clk :      in std_logic ;
per_i :	   in std_logic ;
per_o :    out std_logic 
	  );
end upro;
										
architecture archi_upro of upro is    

signal s_alu_in	 :     std_logic_vector (7 downto 0) ; 
signal s_alu_out :     std_logic_vector (7 downto 0) ;
signal s_alu :         std_logic_vector (3 downto 0) ;
signal s_adress8 :     std_logic_vector (7 downto 0) ; 
signal s_c_adress :    std_logic_vector (1 downto 0) ; 
signal s_comp_in :     std_logic_vector (7 downto 0) ; 
signal s_fonc_compar:  std_logic_vector (1 downto 0);
signal s_c_adress1  :  std_logic_vector (15 downto 0) ; 
signal s_c_adress2  :  std_logic_vector (15 downto 0) ; 
signal s_data2ALU :    std_logic_vector (7 downto 0) ;   
signal s_reg_out  :    std_logic_vector (7 downto 0); 
signal s_reg_f :       std_logic_vector (4 downto 0) ; 
signal s_out :         std_logic_vector (1 downto 0) ; 
signal s_d2compar :    std_logic_vector (7 downto 0) ;
signal s_incr :        std_logic ; 
signal s_compar :      std_logic ; 
signal s_cc_adres :    std_logic ;
signal s_carry :       std_logic ;
signal s_overf :       std_logic ;
signal s_inALU :       std_logic ;
signal s_c_in_compar : std_logic ;	
signal s_c_out_PC :    std_logic ;
signal s_lock_pc :     std_logic ;


component FA_8bits 					 
	port (
	clk : in std_logic ;
	selec : in  std_logic_vector (3 downto 0);
	FA_in1 : in  std_logic_vector (7 downto 0);
	FA_in2 : in  std_logic_vector (7 downto 0);
	FA_out : out std_logic_vector (7 downto 0);
    carry   : out std_logic ;  
	overf : out std_logic 
	);
end component ;


component adress_data							 
	port(
	ctrl_adress : in std_logic_vector (1 downto 0);
	adress_8 :    in std_logic_vector (7 downto 0);
	adress_16  :  out std_logic_vector (15 downto 0) 
	     );
end component ;


component pc_adress 
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
	  
end component ;
						 
component ctrl 
	port (
	clk :              in std_logic ;
	data_in :          in std_logic_vector (7 downto 0); 
	reset :            in std_logic ; 
	d_compar2ctrl :    in std_logic ; 
    wo :               out std_logic ;
    oe :               out std_logic ;	
	pc_inc :           out std_logic ;	
	d_ctrl2compar :	   out std_logic_vector (7 downto 0);
	selec_fonc_compar: out std_logic_vector (1 downto 0);
	adress_in :        in std_logic_vector (15 downto 0); 
	ctrl_alu :         out std_logic_vector (3 downto 0);
	ctrl_adress :      out std_logic_vector (1 downto 0); 
	adress_8 :         out std_logic_vector (7 downto 0);
	d_ALU2ctrl :       in std_logic_vector (7 downto 0);
	d_ctrl2ALU :       out std_logic_vector (7 downto 0);
	c_adress_out : 	   out std_logic ;
	carry_flag :	   in std_logic ; 
	ovf_flag :		   in std_logic ;
	c_inALU	   : 	   out std_logic ;
	data_flag :        out std_logic_vector (4 downto 0);
	selec_data_out :   out std_logic_vector (1 downto 0); 
	out_data  :        out std_logic_vector (7 downto 0);
	c_inCompar   : 	   out std_logic ;
	c_AdressOut2 :     out std_logic ;
	p2ctrl :           in std_logic ;
	ctrl2p :	       out std_logic ;
	lock_ctrl2pc :	   out std_logic
	       );
end component ; 


component compar		 
	port (
	d_in1 :   in  std_logic_vector (8 downto 1);
	d_in2 :   in  std_logic_vector (8 downto 1);
	selec_f : in  std_logic_vector (1 downto 0); 
	clk :	  in std_logic ;
	d_out :   out std_logic 
	     );
end component ; 

begin 
	
upro_a : entity work.FA_8bits(archi_FA_8bits)
	port map (clk,s_alu,s_data2ALU,s_alu_in,s_alu_out,s_carry,s_overf);
	
	
upro_b : entity work.adress_data(archi_adress_data)
	port map (s_c_adress,s_adress8,s_c_adress1);	  
	
	
upro_c : entity work.pc_adress(archi_pc_adress)
	port map (s_incr,reset,addrs,s_c_adress1,s_cc_adres,s_c_out_PC,s_c_adress2,s_lock_pc);
	
	
upro_d : entity work.ctrl(archi_ctrl)
	port map (clk,data_in,reset,s_compar,wo,oe,s_incr,s_comp_in,
	s_fonc_compar,s_c_adress2,s_alu,s_c_adress,
	s_adress8,s_alu_out,s_alu_in,s_cc_adres,s_carry,s_overf,
	s_inALU,s_reg_f,s_out,s_reg_out,s_c_in_compar,s_c_out_PC,per_i,per_o,s_lock_pc);           
	
upro_e : entity work.compar(archi_compar)
	port map (s_d2compar,s_comp_in,s_fonc_compar,clk,s_compar);	
	


process (clk,s_inALU,s_c_in_compar,s_out,s_reg_out,s_reg_f)
begin 

if rising_edge(CLK) then
  if s_inALU='1'then
    s_data2ALU <= data_in ;	
  end if ;							 
end if ;    

if rising_edge(CLK) then
  if s_c_in_compar='1'then	
    s_d2compar <= data_in ;	
  end if ;							
end if ;

case s_out is
	when "01"=>
	data_out <=s_reg_out ; 
	when "10"=>
	data_out <= "000"&s_reg_f ;	
	when others => 	
end case ;	

end process ;  

end archi_upro;
