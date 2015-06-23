library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
  

entity decryptor is 

port   (	
	 plaintext_d :out std_logic_vector(15 downto 0);-- 16 bit Plaintext output of decryptor
     	 ready_d 	   :out std_logic;     -- 1 bit ready output of decryptor
	ciphertext	  :in std_logic_vector(15 downto 0);-- 16 bit ciphertext input to decrytpor which is output of encryptor
         round_keys_d:in std_logic_vector(15 downto 0);--  16 bit roundkeys given to decryptor
         start_d		   :in std_logic; 
         reset 		    :in std_logic;
         clock 		    :in std_logic
       );

end  decryptor;


Architecture arch_decryptor of decryptor is

component multiplier 
port( B  :in std_logic_vector(15 downto 0);
    Product :out std_logic_vector(15 downto 0)
    );
end component;
-- constants for the plain text fsm

constant   idle:std_logic_vector(3 downto 0):= "0000";
constant out_A :std_logic_vector(3 downto 0):= "0001";
constant out_B :std_logic_vector(3 downto 0):= "0010";
constant out_C :std_logic_vector(3 downto 0):= "0011";
constant out_D :std_logic_vector(3 downto 0):= "0100";




--ct1, ttemp and utemp are temprary registers to hold the values of t, u and C.
--signal round_keys_d_saved:std_logic_vector(15 downto 0);
signal ready_d_pre: std_logic; -- ready_d_pre is used to trigger the plaintext fsm (earlier version of ready_d)

signal  state:std_logic_vector(5 downto 0); --state of primary fsm 
signal state_out:std_logic_vector(3 downto 0); -- state of plaintext fsm

signal sig3,sig4:integer range 0 TO 15;

signal last_round ,cleanup : std_logic; 
signal A_final,B_final,C_final,D_final:std_logic_vector(15 downto 0); 
signal utemp1,ttemp1	:std_logic_vector(15 downto 0);-------a_new
signal A, B, C, D :std_logic_vector(15 downto 0);
signal product1,product2  : std_logic_vector(15 downto 0);
---key constant------

        constant p:std_logic_vector(15 downto 0):= "1011011111100001";
	constant q:std_logic_vector(15 downto 0):= "1001111000110111";
	
	type s_tp is array(43 downto 0) of std_logic_vector(15 downto 0);
			signal s :s_tp;
	type l_tp is array(42 downto 0) of std_logic_vector(15 downto 0);
			signal l :l_tp;	
 
 
   
begin

a1: multiplier port map (B,product1);
b1: multiplier port map (D,product2);


	sig3<=conv_integer(unsigned(utemp1(3 downto 0)));
	sig4<=conv_integer(unsigned(ttemp1(3 downto 0)));
	
	
	----key algo----
	
	
	                                s(0) <= P ;						--   initialize constant array 
					l(0)<=(round_keys_d + s(0)); 
					s(1)<=(l(0)+ s(0)+ q);
					l(1)<=( l(0)+s(1));
					s(2)<=(l(1)+ s(1)+ q);					
					l(2)<=( l(1)+s(2));
					s(3)<=(l(2)+ s(2)+ q);					
					l(3)<=( l(2)+s(3));
					s(4)<=(l(3)+ s(3)+ q);					
					l(4)<=( l(3)+s(4));					
					s(5)<=(l(4)+ s(4)+ q);					
					l(5)<=( l(4)+s(5));
					s(6)<=(l(5)+ s(5)+ q);					
					l(6)<=( l(5)+s(6));					
					s(7)<=(l(6)+ s(6)+ q);					
					l(7)<=( l(6)+s(7));
					s(8)<=(l(7)+ s(7)+ q);					
					l(8)<=( l(7)+s(8));					
					s(9)<=(l(8)+ s(8)+ q);					
					l(9)<=( l(8)+s(9));
					s(10)<=(l(9)+ s(9)+ q);					
					l(10)<=( l(9)+s(10 ));
					s(11)<=(l(10)+ s(10)+ q);					
					l(11)<=( l(10)+s(11));				
					s(12)<=(l(11)+ s(11)+ q);					
					l(12)<=( l(11)+s(12));					
					s(13)<=(l(12)+ s(12)+ q);					
					l(13)<=( l(12)+s(13));
					s(14)<=(l(13)+ s(13)+ q);					
					l(14)<=( l(13)+s(14));
					s(15)<=(l(14)+ s(14)+ q);					
					l(15)<=( l(14)+s(15));
					s(16)<=(l(15)+ s(15)+ q);					
					l(16)<=( l(15)+s(16));								
					s(17)<=(l(16)+ s(16)+ q);					
					l(17)<=( l(16)+s(17));
					s(18)<=(l(17)+ s(17)+ q);					
					l(18)<=( l(17)+s(18));
					s(19)<=(l(18)+ s(18)+ q);					
					l(19)<=( l(18)+s(19));
					s(20)<=(l(19)+ s(19)+ q);					
					l(20)<=( l(19)+s(20));					
					s(21)<=(l(20)+ s(20)+ q);					
					l(21)<=( l(20)+s(21));
					s(22)<=(l(21)+ s(21)+ q);					
					l(22)<=( l(21)+s(22));
					s(23)<=(l(22)+ s(22)+ q);
					l(23)<=( l(22)+s(23));
					s(24)<=(l(23)+ s(23)+ q);					
					l(24)<=( l(23)+s(24));					
					s(25)<=(l(24)+ s(24)+ q);					
					l(25)<=( l(24)+s(25));
					s(26)<=(l(25)+ s(25)+ q);					
					l(26)<=( l(25)+s(26));
					s(27)<=(l(26)+ s(26)+ q);					
					l(27)<=( l(26)+s(27));
					s(28)<=(l(27)+ s(27)+ q);					
					l(28)<=( l(27)+s(28));
					s(29)<=(l(28)+ s(28)+ q);					
					l(29)<=( l(23)+s(24));					
					s(30)<=(l(29)+ s(29)+ q);					
					l(30)<=( l(29)+s(30));
					s(31)<=(l(30)+ s(30)+ q);					
					l(31)<=( l(30)+s(31));
					s(32)<=(l(31)+ s(31)+ q);					
					l(32)<=( l(31)+s(32));
					s(33)<=(l(32)+ s(32)+ q);					
					l(33)<=( l(32)+s(33));
				        s(34)<=(l(33)+ s(33)+ q);					
					l(34)<=( l(33)+s(34));					
					s(35)<=(l(34)+ s(34)+ q);					
					l(35)<=( l(34)+s(35));
					s(36)<=(l(35)+ s(35)+ q);					
					l(36)<=( l(35)+s(36));
					s(37)<=(l(36)+ s(36)+ q);					
					l(37)<=( l(36)+s(37));
					s(38)<=(l(37)+ s(37)+ q);					
					l(38)<=( l(37)+s(38));
					s(39)<=(l(38)+ s(38)+ q);					
					l(39)<=( l(33)+s(34));					
					s(40)<=(l(39)+ s(39)+ q);					
					l(40)<=( l(39)+s(40));
					s(40)<=(l(39)+ s(39)+ q);					
					l(41)<=( l(40)+s(40));
					s(41)<=(l(40)+ s(40)+ q);					
					l(42)<=( l(41)+s(41));
					s(42)<=(l(41)+ s(41)+ q);					
					s(43)<=(l(42)+ s(42)+ q);
 


process(clock,reset,ciphertext,sig3,sig4)


variable tempA,tempB,tempC,tempD :std_logic_vector(15 downto 0);
variable temp_AD,temp_BA,temp_CB,temp_DC :std_logic_vector(15 downto 0);
VARIABLE t,u,t_pre,u_pre:std_logic_vector( 15 downto 0);--temporary VARIABLE used for calculation of A, C, t and u
VARIABLE A_pre_2,C_pre_2,A_pre ,C_pre  :std_logic_vector(15 downto 0);

variable cnt: std_logic_vector(6 downto 0):="0000000"; 


begin
        if (reset='1') then 
        
                state <= "000001"; -- reset state
                ready_d <= '0';
                  
                cnt :=(others=>'0'); 
                
                A <= (others=>'0');
                B <= (others=>'0');
                C <= (others=>'0');
                D <= (others=>'0');
                ready_d <= '0';
					TEMPA:=(others=>'0');
					TEMPB:=(others=>'0');
					TEMPC:=(others=>'0');
					TEMPD:=(others=>'0');
					temp_AD:= (others=>'0');					
					temp_BA:= (others=>'0');					
					temp_CB:= (others=>'0');				
					temp_DC:= (others=>'0');
					
        
        elsif(clock'event and clock='1') then
       
          case state is  --synopsys parallel_case
                when"000001"=>
                
                        if (start_d = '0') then
                               state <= "000001"; 
                        else 
                                state <= "000010";
                                ready_d <= '1';                      
                    end if;
                
 
               when "000010"=>
               
                        state <= "000011";
                        A <= ciphertext;--read ciphertext into A
                        ready_d <= '0';
                     
                when "000011"=>
                
                        state <= "000100";
                        B <= ciphertext; -- read ciphertext into B
                        ready_d <= '0';
                       
                
                when "000100"=>
               
                        state <= "000101";
                        C <= ciphertext;  -- read ciphertext  into C
                        ready_d <= '0';
                     	
                
                when "000101"=>
                
                        state <= "000110";
                        D <=  ciphertext;--assign ciphertext to D
                        A <=  A - s(42); -- Use round keys to calculate new value of A
			C <=  C - s(43); -- read ciphertext - roundkeys into C
                        ready_d <= '0';
								
                       
               when "000110"=>  -- begin calculation of plaintext loop from r downto 1
                			state <= "001000";		
				 TEMPA:=A;
				 TEMPB:=B;
				 TEMPC:=C;
				 TEMPD:=D;
  --swap the value of A, B ,C and D  so that new value of A,B ,C AND D can be used.
				temp_AD:= tempA xor tempD;
				A<= temp_AD xor tempA;
				
				temp_BA:= tempB xor tempA;
				B<= temp_BA xor tempB;
				
				temp_CB:= tempC xor tempB;
				C<= temp_CB xor tempC;
				
				temp_DC:= tempD xor tempC;
				D<= temp_DC xor tempD;                                             
                       
                         ready_d <= '0';		  
                      
                
                when "001000"=>
					 
			STATE <="001001";
				
				
				t_pre := product1;
				
		
				u_pre := product2; 
                      	
                                t:= t_pre(11 downto 0) & t_pre(15 downto 12);	
				ttemp1<=t;		 					 
				
						
				u:= u_pre(11 downto 0)& u_pre(15 downto 12);
			        utemp1<=u;
                
               	                 ready_d <= '0';
                
                
                
                when "001001"=> 
                
                        state <= "001010";
								
			for i in 1 to 20 loop
                 	      A_pre_2 := (A - s(2*i)); 			-- A = A-S[2i]
                        C_pre_2 := (C - s(2*i+1)); 	-- C = C - S[2i+1]
                        end loop ;       
                        ready_d <= '0';

								--sig3<=conv_integer(unsigned(u(3 downto 0)));
 			A_pre	:=A_pre_2(sig3-1 downto 0) & A_pre_2(15 downto sig3);
                    
			A <= (A_pre xor t); 			-- A = ((A-S[2i] >>>u) xor  t       
           								--sig4<=conv_integer(unsigned(t(3 downto 0)));
 			C_pre:=C_pre_2(sig4-1 downto 0)& C_pre_2(15 downto sig4);     
					 	
			C <= (C_pre xor u); -- C = ((C-S[2i+1]>>>t) xor u

                when "001010"=>
               
                        state <= "000001"; 
                                        if(cnt<19 )then
				 	  	cnt:=cnt+1	; 
						state <="000110"; 							
					else
						last_round <='1';
						state<="001011"; 
						cnt:="0000000" ;
						end if;
			                            
                
                      
                 
                
               when "001011"=> 
               
                        state <= "001100";
                        D <= D - s(1); -- Calculate final value of D
                        ready_d <= '0';
                        
                
                                        
                when "001100" => 
                
                        state <= "001101";
                        B <= B - s(0); -- Calculate final value of B
                        ready_d <= '1'; -- set ready_d signal high as decryption process is over
			
			cleanup<='1';
			ready_d_pre <= '1';-- Assign ready_d_pre high which essentially starts up second FSM. 
			
		when "001101" => 
			
			if(cleanup='1') then
				A_final <= A;
				B_final <= B;
				C_final <= C;
				D_final <= D;
			else
				A_final <= A_final ;
				B_final <= B_final ;
				C_final <= C_final ;
				D_final <= D_final ;
			end if;
	
                
                when others=>                
                        state <= "000001";
                        ready_d <= '1';
                        A <= (others=>'0');
                        B <= (others=>'0');
                        C <= (others=>'0');
                        D <= (others=>'0');
                
                end case;
        end if;
end process;
                              

process(clock,reset,ready_d_pre,A_final,B_final,C_final,D_final)
        begin
                if (reset='1') then
	
                        state_out <= idle;
			plaintext_d <= (others=>'0');	
		
                elsif (clock'event and clock='1') then
		
                        case state_out is --synopsys parallel_case
                        when idle=>
                        
                                if (ready_d_pre='1') then
                                        state_out <= out_A; 
                                else
                                        state_out <= idle;
                                plaintext_d <= (others=>'0');
                        	end if;
                        when out_A=> 
                        
                                state_out <= out_B;
                                plaintext_d <= A_final; -- Output plaintext as A
                              
                        
                        when out_B=> 
                        
                                state_out <= out_C;
                                plaintext_d <= B_final; -- Output plaintext as B
                              
                        when out_C=> 
                        
                                state_out <= out_D;
                                plaintext_d <= C_final;  -- Output plaintext as C
                              
                       when out_D=>                
        
                                state_out <= idle;
                                plaintext_d <= D_final; -- Output plaintext as D
                              
                        when others=>
                       
                                state_out <= idle;
                                plaintext_d <= (others=>'0');
                              
                        end case;
		end if;
        end process;

end arch_decryptor ;   







