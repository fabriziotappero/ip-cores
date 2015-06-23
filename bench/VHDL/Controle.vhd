-------------------------------------------------------------------------------
-- Control Unit
-- 
-- 
-------------------------------------------------------------------------------

library IEEE;

use IEEE.STD_LOGIC_1164.all; 

entity ctrl is
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
end ctrl ; 

architecture archi_ctrl  of ctrl  is  

signal c_reg_resu1 :  std_logic_vector (2 downto 0); 
signal reg1 :         std_logic_vector (7 downto 0); 
signal reg2:          std_logic_vector (7 downto 0);
signal reg_flag :     std_logic_vector (4 downto 0); 
signal s_flag2FSM :   std_logic_vector (4 downto 0); 
signal s_flag_compar: std_logic ; 
signal s_addres_out : std_logic ; 
signal s_inALU :      std_logic ; 
signal s_data_out :   std_logic ; 
signal s_flag_out  :  std_logic ;  
signal s_compar :     std_logic ; 

 
component FSM 
	port (
	clk :              in std_logic ;
	d_in_FSM :         in std_logic_vector (7 downto 0); 
	reset :            in std_logic ; 
	compar2FSM :       in std_logic ; 
    wo :               out std_logic ;
    oe :               out std_logic ;	
	pc_inc :           out std_logic ;	
	data2compar :	   out std_logic_vector (7 downto 0);
	selec_fonc_compar: out std_logic_vector (1 downto 0);
	selec_reg_resu1	:  out std_logic_vector (2 downto 0);
	adress_in :        in std_logic_vector (15 downto 0); 
	ctrl_alu :         out std_logic_vector (3 downto 0);
	ctrl_adress :      out std_logic_vector (1 downto 0); 
	adress_8 :         out std_logic_vector (7 downto 0);
	c_data_out :	   out std_logic ;
	c_adress_out : 	   out std_logic ;
	s_flag_out : 	   out std_logic ;
	c_inALU	: 	       out std_logic ;
	resu_compar :      out std_logic ; 
	reg_resu2 :        in std_logic_vector (7 downto 0);
	c_in_compar :      out std_logic ;
	c_adress2_out :	   out std_logic ;
	reg_flag2FSM :     in std_logic_vector (4 downto 0);
	p2fsm :            in std_logic ;
	fsm2p :	           out std_logic ;
	lock_fsm2pc :	   out std_logic
	      );	
end component;



begin 
	
FSM_state : entity work.FSM(archi_FSM)
	port map (clk,data_in,reset,d_compar2ctrl,wo,oe,pc_inc,
	d_ctrl2compar,selec_fonc_compar,c_reg_resu1,
	adress_in,ctrl_alu,ctrl_adress,adress_8,
	s_data_out,s_addres_out,s_flag_out,
	s_inALU,s_flag_compar,reg1,s_compar,
	c_AdressOut2,s_flag2FSM,p2ctrl,ctrl2p,lock_ctrl2pc);

	c_inALU<=s_inALU ;	
	d_ctrl2ALU<=reg1 ;	
	c_inCompar<=s_compar ;
	c_adress_out<=s_addres_out ;

reg_flag(0) <= (not reg1(0))and (not reg1(1))and (not reg1(2))and (not reg1(3))and (not reg1(4))and (not reg1(5))and (not reg1(6))and (not reg1(7));   -- zero flag
reg_flag(1) <= (((((((reg1(0)xor reg1(1))xor reg1(2))xor reg1(3))xor reg1(4))xor reg1(5))xor reg1(6))xor reg1(7));	-- parity flag
reg_flag(2) <= carry_flag ;	   -- carry flag
reg_flag(3) <= ovf_flag ;      -- overflow flag 
reg_flag(4) <= s_flag_compar ; -- comparison flag 

data_flag<=reg_flag ;
selec_data_out<= s_flag_out & s_data_out ;	
s_flag2FSM<=reg_flag ;

process (reset,clk)
begin
	
if reset ='1' then
  reg1<="00000000" ;
  out_data<="00000000" ;
  reg2<="00000000" ;
else
  if rising_edge(clk) then
    case c_reg_resu1 is   
	  when "000"=>
	  reg2 <= reg1 ;				    -- result. out
	  out_data <= reg2 ;
	  when "001"=>	  
	  reg2<='0'&reg1(7 downto 1);	    -- shift right with 0	
	  when "010"=>
	  reg2<='1'&reg1(7 downto 1);	    -- shift right with 1
	  when "011"=>
	  reg2<=reg1(6 downto 0)&'0';	    -- shift left with 0
	  when "100"=>
      reg2<=reg1(6 downto 0)&'1';	    -- shift left with 1
	  when "101"=>
	  reg2<=reg1(0)&reg1(7 downto 1);	-- rot right
	  out_data <= reg2 ;
	  when "110"=>
	  reg2<=reg1(6 downto 0)&reg1(7);	-- rot left 
	  out_data <= reg2 ;
	  when "111"=>
	  reg1<=d_ALU2ctrl ;
	  when others =>	
    end case ; 
  end if ;
end if ; 

end process ;
	   
end archi_ctrl ;

