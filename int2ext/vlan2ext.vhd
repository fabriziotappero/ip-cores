--------------------------------------------------------
	LIBRARY IEEE;
	USE IEEE.STD_LOGIC_1164.ALL;
	use ieee.numeric_std.all;
	use IEEE.STD_LOGIC_ARITH.ALL;
	use IEEE.STD_LOGIC_UNSIGNED.ALL;
	USE WORK.CONFIG.ALL;
-------------------------------
	ENTITY vlan2ext IS
	GENERIC(DATA_WIDTH :INTEGER := 64;
			CTRL_WIDTH :INTEGER := 8);
	PORT(
	SIGNAL 		in_data 			:	IN   	STD_LOGIC_VECTOR(63 DOWNTO 0)	;
	SIGNAL 		in_ctrl 			: 	IN   	STD_LOGIC_VECTOR(7 DOWNTO 0)	;
    SIGNAL 		in_wr 				:	IN 		STD_LOGIC	;
	
	SIGNAL 		exit_port			:	OUT   	STD_LOGIC_VECTOR(7 DOWNTO 0)	;
	SIGNAL 		done				:	OUT   	STD_LOGIC 	;
	
    --- Misc
    
    SIGNAL 		reset 				:	IN 		STD_LOGIC	;
    SIGNAL 		clk   				:	IN 		STD_LOGIC
	);
	END ENTITY vlan2ext;
	
 ------------------------------------------------------
	ARCHITECTURE behavior OF vlan2ext IS 
------------ one hot encoding state definition
	TYPE state_type is (READ_HEADER, READ_WORD_1, READ_WORD_2);
	ATTRIBUTE enum_encoding: STRING;
	ATTRIBUTE enum_encoding of state_type : type is "onehot";

	SIGNAL state, state_NEXT : state_type; 

	SIGNAL 		exit_port_p			: 	STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL 		vlan_rdy			: 	STD_LOGIC;

	


	BEGIN
---------------------------------------------	
	PROCESS(reset,clk)
		BEGIN
			IF (reset ='1') THEN
				state <=READ_HEADER;
			ELSIF clk'EVENT AND clk ='1' THEN
				state<=state_next; 
			END IF;
		END PROCESS;
		
		PROCESS(state , in_ctrl , in_wr)
		BEGIN
													state_next				   <=  state;
													vlan_rdy				   <= '0' ;
			CASE state IS		
				WHEN READ_HEADER =>			
					IF( in_wr = '1' AND in_ctrl=X"FF"  ) THEN
					
													state_next                 <=  READ_WORD_1;
					END IF;
				WHEN READ_WORD_1 =>			
					IF( in_wr = '1') THEN														
													state_next                <=  READ_WORD_2;				
						END IF;
				WHEN READ_WORD_2 =>
					
					IF(in_wr = '1' ) THEN
													vlan_rdy				  <= '1' ;
													state_next                <= READ_HEADER;
					END IF;
				WHEN OTHERS =>
													state_next                <= READ_HEADER;
			END CASE;
		END PROCESS;
		
		PROCESS(clk)
		BEGIN
			IF clk'EVENT AND clk ='1'  THEN
							done <=vlan_rdy;
--					IF  vlan_rdy = '1' THEN
							
							CASE in_data(11 downto 0) IS
							WHEN  vlan_array(0) => exit_port  <=  X"01" ; 
							WHEN  vlan_array(1) => exit_port  <=  X"04" ;
							WHEN  vlan_array(2) => exit_port  <=  X"10" ;
							WHEN  vlan_array(3) => exit_port  <=  X"40" ;
							WHEN  OTHERS => 		  exit_port  <=  X"01" ;
							END CASE;
--							done <='1';
--					END IF;
			END IF;
		END PROCESS;
		 
	
END behavior;
   