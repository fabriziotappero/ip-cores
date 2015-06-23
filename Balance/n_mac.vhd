--------------------------------------------------------
	LIBRARY IEEE;
	USE IEEE.STD_LOGIC_1164.ALL;
	use ieee.numeric_std.all;
	use IEEE.STD_LOGIC_ARITH.ALL;
	use IEEE.STD_LOGIC_UNSIGNED.ALL;
	USE WORK.CONFIG.ALL;
-------------------------------
	ENTITY n_mac IS
	GENERIC(DATA_WIDTH :INTEGER := 64;
			CTRL_WIDTH :INTEGER := 8);
	PORT(
	SIGNAL 		in_data 			:	IN   	STD_LOGIC_VECTOR(63 DOWNTO 0)	;
	SIGNAL 		in_ctrl 			: 	IN   	STD_LOGIC_VECTOR(7 DOWNTO 0)	;
    SIGNAL 		in_wr 				:	IN 		STD_LOGIC	;
	
	SIGNAL rd_next_mac : OUT STD_LOGIC;
	SIGNAL key :OUT   STD_LOGIC_VECTOR(11 DOWNTO 0);
	
    --- Misc
    
    SIGNAL 		reset 				:	IN 		STD_LOGIC	;
    SIGNAL 		clk   				:	IN 		STD_LOGIC
	);
	END ENTITY n_mac;
	
 ------------------------------------------------------
	ARCHITECTURE behavior OF n_mac IS 
	----------------
	COMPONENT hash IS
		GENERIC(
			KEY_WIDTH 	: 	NATURAL := 48;--Hash key width
			ADD_WIDTH 	: 	NATURAL := 12; --address width
			HASH_NO 	: 	NATURAL := 4 --Hash number
		);
		PORT (
			key 		: 	STD_LOGIC_VECTOR(47 DOWNTO 0);	--Hash key 
			address 	: 	OUT STD_LOGIC_VECTOR(ADD_WIDTH-1 DOWNTO 0)		--address 
		);
	END COMPONENT hash;
---------------------------------
------------ one hot encoding state definition
	TYPE state_type is (READ_HEADER, READ_WORD_1, READ_WORD_2);
	ATTRIBUTE enum_encoding: STRING;
	ATTRIBUTE enum_encoding of state_type : type is "onehot";

	SIGNAL state, state_NEXT : state_type; 

	SIGNAL 		src_mac_p1			: 	STD_LOGIC;
	SIGNAL 		src_mac_p2			: 	STD_LOGIC;
	SIGNAL 		rd_next_mac_i		: 	STD_LOGIC;
	SIGNAL		src_mac				: 	STD_LOGIC_VECTOR(47 DOWNTO 0);


	BEGIN
---------------------------------------------
--	hash_Inst :  hash 
--		GENERIC MAP(
--			KEY_WIDTH 	=> 48,	ADD_WIDTH 	=> 12, 	HASH_NO 	=> 1 --Hash number
--		)
--		PORT MAP(
--			key 		=>src_mac,	--Hash key 
--			address 	=>key		--address 
--		);

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
													src_mac_p1				   <= '0' ;
													src_mac_p2				   <= '0' ;
			CASE state IS		
				WHEN READ_HEADER =>			
					IF( in_wr = '1' AND in_ctrl=X"FF"  ) THEN
													src_mac_p1				   <= '1' ;
													src_mac_p2				   <= '1' ;
													state_next                 <=  READ_WORD_1;
					END IF;
				WHEN READ_WORD_1 =>			
					IF( in_wr = '1') THEN			
--													src_mac_p1				   <= '1' ;
													state_next                <=  READ_WORD_2;				
						END IF;
				WHEN READ_WORD_2 =>
					
					IF(in_wr = '1' ) THEN
--													src_mac_p2				  <= '1' ;
													state_next                <= READ_HEADER;
					END IF;
				WHEN OTHERS =>
													state_next                <= READ_HEADER;
			END CASE;
		END PROCESS;
		
		PROCESS(clk)
		BEGIN
			IF clk'EVENT AND clk ='1'  THEN
							
--					IF  src_mac_p1 = '1' THEN
--							src_mac(47 downto 32)<= in_data(15 downto 0);
--					END IF;
--					IF  src_mac_p2 = '1' THEN
--							src_mac(31 downto 0)<= in_data(63 downto 32);
--							
--					END IF;
					rd_next_mac <= src_mac_p2;
--					rd_next_mac_i <= src_mac_p2;
			END IF;
		END PROCESS;
		 
	
END behavior;
   