---this file could be used to build ARP RESPONSE 

--------------------------------------------------------

	LIBRARY IEEE;
	USE IEEE.STD_LOGIC_1164.ALL;
	use ieee.numeric_std.all;
	use IEEE.STD_LOGIC_ARITH.ALL;
	use IEEE.STD_LOGIC_UNSIGNED.ALL;
	USE WORK.CONFIG.ALL;
-------------------------------

	ENTITY  arp_response IS
	GENERIC(DATA_WIDTH :INTEGER := 64;
			CTRL_WIDTH :INTEGER := 8);
	PORT(
	SIGNAL out_data : OUT   STD_LOGIC_VECTOR(63 DOWNTO 0);
	SIGNAL out_ctrl : OUT  STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL out_wr : OUT STD_LOGIC;
	SIGNAL header : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
     --- ethr  header
    SIGNAL src_mac : IN STD_LOGIC_VECTOR(47 DOWNTO 0); --ethernet source MAC
	SIGNAL SHA :IN STD_LOGIC_VECTOR(47 DOWNTO 0);--Sender hardware address (SHA)    Hardware (MAC) address of the sender.
	SIGNAL SPA :IN STD_LOGIC_VECTOR(31 DOWNTO 0);--Sender protocol address (SPA)    Upper layer protocol address of the sender.
	SIGNAL THA : IN STD_LOGIC_VECTOR(47 DOWNTO 0);--Hardware address of the intended receiver. This field is ignored in requests.
	SIGNAL TPA : IN STD_LOGIC_VECTOR(31 DOWNTO 0);-- Upper layer protocol address of the intended receiver. 
    --- Misc
    SIGNAL rdy :IN STD_LOGIC;
    SIGNAL reset :IN STD_LOGIC;
    SIGNAL clk   :IN STD_LOGIC
	);
	END ENTITY;
 ------------------------------------------------------
	ARCHITECTURE behavior OF arp_response IS 
	
------------ one hot encoding state definition	
	TYPE state_type is (IDLE, WRITE_HEADER, WRITE_WORD_1 , WRITE_WORD_2, WRITE_WORD_3, 
						WRITE_WORD_4,WRITE_WORD_5, WRITE_WORD_6,WRITE_DUMP1,WRITE_DUMP2, WAIT_EOP);
	ATTRIBUTE enum_encoding: STRING;
	ATTRIBUTE enum_encoding OF state_type: TYPE IS "onehot";
	SIGNAL state, state_next: state_type; 
------------end state machine definition
   
---------------internal signals
    SIGNAL 		out_data_p 			:   STD_LOGIC_VECTOR(DATA_WIDTH-1 DOWNTO 0);
	SIGNAL 		out_ctrl_p 			:   STD_LOGIC_VECTOR(CTRL_WIDTH-1 DOWNTO 0);
    SIGNAL 		out_wr_p 			:  	STD_LOGIC;
	SIGNAL 		source_port			: 	STD_LOGIC_VECTOR(1 DOWNTO 0);--just four ports
	SIGNAL 		dest_port			: 	STD_LOGIC_VECTOR(15 DOWNTO 0);--just four ports
	
-------------------------------------------
	BEGIN
	   PROCESS(clk)
		BEGIN
	
			IF RISING_EDGE( clk )THEN		
					IF( rdy ='1' ) THEN
						IF header(31 DOWNTO 16)=X"0000" THEN
								source_port <= "00";
								dest_port <= X"0001";
							ELSIF header(31 DOWNTO 16)=X"0002" THEN
								source_port <= "01";
								dest_port <= X"0004";
							ELSIF header(31 DOWNTO 16)=X"0004" THEN
								source_port <= "10";
								dest_port <= X"0010";
							ELSIF header(31 DOWNTO 16)=X"0006" THEN
								source_port <= "11";
								dest_port <= X"0040";
						END IF;
					END IF;
			END IF;
		END PROCESS;
	    
		PROCESS(reset,clk)
		BEGIN
			IF (reset ='1') THEN
					state 								<=	IDLE;
			ELSIF clk'EVENT AND clk ='1' THEN
					state								<=	state_next;
			END IF;
		END PROCESS;
		PROCESS(state, rdy)
		BEGIN
					state_next							<=	state;
			CASE state IS
			WHEN IDLE =>
				IF rdy ='1' THEN 
					state_next         		    	 	<=	WRITE_HEADER;	
				END IF;
			WHEN WRITE_HEADER =>
					state_next         		    	 	<=	WRITE_WORD_1;
			WHEN WRITE_WORD_1 =>
					state_next         		    	 	<=	WRITE_WORD_2;					
			WHEN WRITE_WORD_2 =>
					state_next                		 	<=	WRITE_WORD_3;				
			WHEN WRITE_WORD_3 =>            
					state_next                		 	<=	WRITE_WORD_4;				
			WHEN WRITE_WORD_4 =>											        			  
					state_next         		  			<=	WRITE_WORD_5;
			WHEN WRITE_WORD_5 =>
					state_next         		 			<=	WRITE_WORD_6;
			WHEN WRITE_WORD_6 =>
					state_next         		 			<=	WRITE_DUMP1;
			WHEN WRITE_DUMP1 =>
					state_next         		 			<=	WRITE_DUMP2;
			WHEN WRITE_DUMP2 =>
					state_next         		 			<=	WAIT_EOP;			
			WHEN WAIT_EOP =>
					state_next 							<=	IDLE;
			WHEN OTHERS =>
					state_next 							<=	IDLE;
			END CASE;
		END PROCESS;
		-------------------OUTPUT ASSIGNMENT
		with state select
		 out_data_p <= dest_port & X"0008" & header(31 DOWNTO 16)&X"0040" WHEN WRITE_HEADER,
					   src_mac & mac_array(CONV_INTEGER(source_port))(47 downto 32) when WRITE_WORD_1,
					   mac_array(CONV_INTEGER(source_port))(31 downto 0) & X"0806" & X"0001" when WRITE_WORD_2,
					   X"0800" & X"06" & X"04" & X"0002" & mac_array(CONV_INTEGER(source_port))(47 downto 32) when WRITE_WORD_3,
					   mac_array(CONV_INTEGER(source_port))(31 downto 0) & TPA WHEN WRITE_WORD_4, 
					   SHA & SPA(31 DOWNTO 16) WHEN WRITE_WORD_5,
					   SPA(15 DOWNTO 0) & ( X"000000000000") WHEN WRITE_WORD_6,
					   X"0000000000000000" WHEN WRITE_DUMP1,
					   X"0000000000000000" WHEN WRITE_DUMP2,
					   ( OTHERS=>'0') when others;

	   with state select
				 out_wr_p <= '1' when WRITE_HEADER|WRITE_WORD_1| WRITE_WORD_2| WRITE_WORD_3|WRITE_WORD_4| WRITE_WORD_5|WRITE_WORD_6| WRITE_DUMP1|WRITE_DUMP2,
							   '0' when others;
		with state select
				 out_ctrl_p <= X"FF" when WRITE_HEADER,
							   X"00" WHEN WRITE_WORD_1| WRITE_WORD_2| WRITE_WORD_3|WRITE_WORD_4| WRITE_WORD_5|WRITE_WORD_6 | WRITE_DUMP1,
							   X"01" WHEN WRITE_DUMP2,
							   X"00" when others;
		PROCESS(reset, clk)
		BEGIN
		IF (reset ='1') THEN
		    out_data<=(others=>'0'); 
			out_ctrl<=(others=>'0'); 
			out_wr<='0'; 
		
		ELSIF clk'EVENT AND clk ='1' THEN
			out_data<=out_data_p; 
			out_ctrl<=out_ctrl_p; 
			out_wr<=out_wr_p;
		END IF;
		END PROCESS;


END behavior;
   