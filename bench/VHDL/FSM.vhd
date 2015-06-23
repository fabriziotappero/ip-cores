-------------------------------------------------------------------------------
-- FSM (Finite State Machine) 
-- 
-- 
-------------------------------------------------------------------------------

library IEEE;

use IEEE.STD_LOGIC_1164.all; 

entity FSM is
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
	c_flag_out : 	   out std_logic ;
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
end FSM ; 

architecture archi_FSM  of FSM  is 

type stat_type is (s0,s01,s1,s2,s21,s22,s23,s24,s25,s26,s27,s28,
s29,s3,s31,s32,s33,s34,s35,s36,s37,s4,s41,s42,s43,s44,s45,s46,
s5,s6,s7,s_ck1,s_ck2,s_ck3,s_ck4,s_ck5,s_ck6,s_ck7,s_ck8,s_ck9,
s_ck10,s_ck11,s8,s81,s9,s91,s92,s93,s94,s95,s96,s97,s98,s99,s10,s10a,
s10b,s10c,s10d,s10e,s10f,s10g,s10h);


signal tempo  :       std_logic_vector (7 downto 0);
signal tempo1  :      std_logic_vector (3 downto 0); 
signal temp_adress :  std_logic_vector (15 downto 0);
signal statu :        std_logic ;
signal var_flag :     std_logic ;
signal lock_fsm :     std_logic ;
signal state  :       stat_type ;	 

begin 
	
process (reset,clk,d_in_FSM)
begin
  if (reset='1') then 
	c_flag_out<='0';
	pc_inc<='0';
	selec_reg_resu1<="000";
	ctrl_alu<="0000";
	var_flag<='0';
	ctrl_adress<="00";
	wo <='0';
	oe <='1';
	adress_8<="00000000";
	statu<='0';
	c_inALU<='0';
	c_adress_out<='0';
	selec_fonc_compar<="00";
	c_in_compar<='0';
	fsm2p<='0';
	data2compar<="00000000";
	temp_adress<="0000000000000000";
	tempo<="00000000";
	c_data_out<='0';
	resu_compar<='0';	
	c_adress2_out<='1';	
	lock_fsm<='1';
	tempo1<="0000";
	lock_fsm2pc<='0';
	state<=s0;
  else 
    if (clk'event and clk='1')then
	  if (p2fsm='0')then
	    wo <='0';
	    oe <='1';
		lock_fsm2pc<='0';
	  else 
	    if(p2fsm='1')then 
		  if (lock_fsm='1') then
	        oe <='0';	
		    fsm2p<='1';
		    lock_fsm2pc<='1'; 
		  end if;  
	    end if;
	  end if;
	  
	  tempo<=d_in_FSM ;
	case state is
	when s0 =>
	pc_inc<='0';
	  if (lock_fsm='1') then 
		 pc_inc<='1'; 
		 statu<= '0' ;
		 state<=s01;  
	  end if ; 
	when s01 =>	
	pc_inc<='0'; 
	state<=s1;
	when s1=> 
	  if statu = '0' then 
		 case tempo is 
	             when "00000001"=>	   --------------------- begin of ALU
	             ctrl_alu<="0001";
				 state<=s3;
	             when "00000010"=>
	             ctrl_alu<="0010";
				 state<=s3;
	             when "00000011"=>
	             ctrl_alu<="0011";
				 state<=s3;
	             when "00000100"=>	             
				 tempo1<="0100";
				 state<=s2;	
	             when "00000101"=>	            
				 tempo1<="0101";
				 state<=s2;			
	             when "00000110"=>	             
				 tempo1<="0110";
				 state<=s2;			
	             when "00000111"=>	             				
				 tempo1<="0111";
				 state<=s2;
	             when "00001000"=>	        
				 tempo1<="1000";
				 state<=s2;					
	             when "00001001"=>
	             ctrl_alu<="1001"; 
				 state<=s3;	 			
	             when "00001010"=>	
	             ctrl_alu<="1010" ;
				 state<=s3; 			
				 when "00001011"=>
	             ctrl_alu<="1011"; 
				 state<=s3; 		
				 when "00001100"=>	
	             ctrl_alu<="1100" ;			
				 state<=s3;           ----------------------- end of ALU  
				 
				 when "00010000"=>	  -------- acces to adress  
				 state<=s4;       
				 when "00100000"=>	  -------- return to address PC 
	             state<=s9;	 
				 
				 when "00110000"=>	  -- comparison >,<,=
				 state<=s5; 
				 when "01000000"=>	
	             state<=s6; 
				 when "01010000"=>	
	             state<=s7; 					
				 
				 when "01100000"=>	  -- Release of the result
				 c_data_out<='1';
	             state<=s0;
				 
				 when "01110000"=>	  -- load flag register
				 c_flag_out<='1';
	             pc_inc<='1';
				 state<=s0;
				 
				 when "10000000"=>	  -- shift/rot
	             selec_reg_resu1<="001";
				 pc_inc<='1';
				 state<=s0;	   
				 when "10010000"=>	
	             selec_reg_resu1<="010";	
				 pc_inc<='1';
				 state<=s0;			 
				 when "10100000"=>	
	             selec_reg_resu1<="011";
				 pc_inc<='1';
				 state<=s0;				 
				 when "10110000"=>	
	             selec_reg_resu1<="100"; 
				 pc_inc<='1';
				 state<=s0;				 
				 when "11000000"=>	
	             selec_reg_resu1<="101";
				 pc_inc<='1';
				 state<=s0;			 
				 when "11010000"=>	
	             selec_reg_resu1<="110"; 
				 pc_inc<='1';
				 state<=s0;	
				 
				 when "11110000"=>	  --  whrite
				 state<=s8;  
				 
				 when "10000001"=>		   -- if  zero
				 var_flag<=reg_flag2FSM(0); 
				 state<=s10;
				 
				 when "11110010"=>		   -- if  parity
				 var_flag<=reg_flag2FSM(1);
				 state<=s10;
				  
				 when "11110011"=>		   -- if  'comparison'
				 var_flag<=reg_flag2FSM(4);
			     state<=s10;
				 
				 when "11110100"=>		   -- if  cary
				 var_flag<=reg_flag2FSM(2);
				 state<=s10;
				 
				 when "11110101"=>		   -- if  overflow
				 var_flag<=reg_flag2FSM(3);
				 state<=s10;
				 
		  		 when others =>				   		
		
		 end case ;
	   end if ; 
			 
	 when s2=>	  -----  opcode a ,b =
	 lock_fsm<='0';
	 statu<= '1' ;
	 c_inALU<='1';
	 pc_inc<='1';
	 state<=s21;
	 when s21=>						
	 pc_inc<='0';
	 state<=s22; 
	 when s22 =>
	 ctrl_alu <= tempo1 ;
	 state<=s23;
	 when s23=>   --- 1st clk
	 state<=s24;
     when s24=>   --- clk
	 state<=s25;
	 when s25=>	  --- clk
	 state<=s26;
	 when s26=>	  --- clk
	 state<=s27;
	 when s27=>	  --- clk
	 state<=s28;
     when s28=>	  --- clk
	 selec_reg_resu1<= "111";	-- record the result in the register
	 state<=s29;
	 when s29=>	  
	 selec_reg_resu1<= "000";	
	 pc_inc<='1';
	 c_inALU<='0';
	 lock_fsm<='1';
	 ctrl_alu <= "0000" ;
	 state<=s0;
		 
	 when s3=>		-------	opcode a =
	 lock_fsm<='0';
	 statu<= '1' ;	
	 c_inALU<='1';
	 pc_inc<='1';
	 state<=s31;
	 when s31=>	
	 pc_inc<='0';
	 state<=s32;
	 when s32 =>	--- 1stclk			 
	 state<=s33;
	 when s33 =>	---  clk			 
	 state<=s34;
	 when s34 =>	---  clk
	 state<=s35;
	 when s35=>		---  clk
	 state<=s36;
	 when s36 =>	---  clk			 
	 selec_reg_resu1<= "111";	  -- record the result in the register
	 state<=s37;
	 when s37 =>
	 selec_reg_resu1<= "000";  
	 pc_inc<='1';
	 c_inALU<='0';
	 lock_fsm<='1';
	 ctrl_alu <= "0000" ;
	 state<=s0;
		 
	 when s4=>		
	 lock_fsm<='0';
	 temp_adress<=adress_in ;
	 pc_inc<='1';
	 state<=s41;
	 when s41=>
	 pc_inc<='0'; 
	 adress_8<=tempo ; 
	 ctrl_adress<="01" ; 
	 state<=s42;
	 when s42=>	
	 pc_inc<='1';
	 state<=s43; 
	 when s43 =>
	 pc_inc<='0';
	 adress_8<=tempo ; 
	 ctrl_adress<="10" ;
	 state<=s44; 
	 when s44 =>
	 ctrl_adress<="11" ;
	 state<=s45;
	 when s45=> 
	 ctrl_adress<="00" ; 
	 c_adress_out <= '1';
	 state<=s46;
	 when s46=>
	 c_adress_out <= '0';
	 lock_fsm<='1';
	 state<=s0;	 
		 
	 when s5=>		 --- comparison	 <
	 selec_reg_resu1<= "000";  
	 data2compar<=reg_resu2	;
	 selec_fonc_compar<="01" ;  
	 pc_inc<='1';
	 state<=s_ck1; 
		 
	 when s6=>		 --- comparison 	 >
	 selec_reg_resu1<= "000";  
	 data2compar<=reg_resu2	;
     selec_fonc_compar<="10" ;  
     pc_inc<='1';
	 state<=s_ck1;
		 
	 when s7=>		 --- comparison 	 =
	 selec_reg_resu1<= "000";  
	 data2compar<=reg_resu2	;
	 selec_fonc_compar<="11" ;  
	 pc_inc<='1';
	 state<=s_ck1;
		 
	 when s_ck1 =>	 
	 lock_fsm<='0';
	 pc_inc<='0';
	 c_in_compar<='1';
	 statu<= '1' ;
	 state<=s_ck2;
	 when s_ck2=> 	 -- 1st clk 
	 state<=s_ck3;
	 when s_ck3=> 	 --  clk	
	 state<=s_ck4;
	 when s_ck4 =>	 --  clk	
	 state<=s_ck5;
	 when s_ck5=> 	 --  clk	
	 state<=s_ck6;
	 when s_ck6=> 	 --  clk	
	 state<=s_ck7;
	 when s_ck7=> 	 --  clk	
	 state<=s_ck8;								
	 when s_ck8=> 	 --  clk 
	 state<=s_ck9;								
	 when s_ck9=> 	 --  clk 	
	 state<=s_ck10;								
	 when s_ck10=> 	 --  clk 
	 state<=s_ck11;								
	 when s_ck11=> 	 --  clk 
	 resu_compar <= compar2FSM ;
	 pc_inc<='1';
	 c_in_compar<='0';
	 lock_fsm<='1';
	 state<=s0;		
		
	 when s8=>		 -- whrite
	 pc_inc<='1';
	 wo <='1';		 
	 oe <='1';
	 c_data_out<='1';
	 state<=s81;
	 when s81=>
	 pc_inc<='0';
	 c_data_out<='0';
	 state<=s0;
		 
 	 when s9=>		-- return to adress	 
	 lock_fsm<='0';
	 c_adress2_out<='0' ;
 	 pc_inc<='0';
	 adress_8<=temp_adress(7 downto 0) ;
	 ctrl_adress<="10" ; 
	 state<=s91;
	 when s91=>
	 adress_8<=temp_adress(15 downto 8) ;
	 ctrl_adress<="01" ; 
	 state<=s92;
	 when s92=>	
	 ctrl_adress<="11" ;
	 c_adress_out <= '1'; 
	 state<=s93; 
	 when s93 =>
	 c_adress_out <= '0';
	 state<=s94; 
	 when s94 =>
	 pc_inc<='1';
	 ctrl_adress<="00" ; 
	 state<=s95; 
	 when s95 =>
     pc_inc<='0';
	 state<=s96; 
	 when s96 =>
	 pc_inc<='1';
	 state<=s97; 
	 when s97 =>
	 pc_inc<='0';
	 state<=s98 ; 
	 when s98 =>
	 pc_inc<='1'; 
	 state<=s99 ; 
	 when s99 =>
	 pc_inc<='0';
	 c_adress2_out<='1' ;
	 lock_fsm<='1';
	 state<=s0;
		 
	 when s10 => 	-- is yes ;; 
	 if var_flag = '1' then
	 pc_inc<='1';	 
	 state<=s0; 
	 else 
	 state<=s10a ;
	 end if ;
		 
	 when s10a =>
	 tempo<="00000000";
	 lock_fsm<='0';
	 pc_inc<='1'; 
	 state<=s10b; 
	 when s10b =>
	 pc_inc<='0'; 
	 state<=s10c; 
	 when s10c =>
	 pc_inc<='1';
	 state<=s10d; 
	 when s10d =>
	 pc_inc<='0';
	 state<=s10e; 
	 when s10e =>
	 pc_inc<='1';
	 state<=s10f; 
	 when s10f =>
	 pc_inc<='0';
	 state<=s10g; 
	 when s10g =>
	 pc_inc<='1';
	 state<=s10h; 
     when s10h =>
	 c_adress2_out <= '1';
	 lock_fsm<='1';
	 state<=s0 ;
	  
	 when others =>
     end case ;
     end if ;
  end if;

end process ;

end archi_FSM ;	