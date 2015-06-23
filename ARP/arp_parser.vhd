--------------------------------------------------------

	LIBRARY IEEE;
	USE IEEE.STD_LOGIC_1164.ALL;
-------------------------------

	ENTITY  arp_parser IS
	GENERIC(DATA_WIDTH :INTEGER := 64;
			CTRL_WIDTH :INTEGER := 8);
	PORT(
	SIGNAL in_data :IN   STD_LOGIC_VECTOR(63 DOWNTO 0);
	SIGNAL in_ctrl : IN   STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL in_wr :IN STD_LOGIC;
	
	SIGNAL header : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
     --- ethr  header
    SIGNAL src_mac : OUT STD_LOGIC_VECTOR(47 DOWNTO 0); --ethernet source MAC
    -------ARP------------
 	SIGNAL SHA :OUT STD_LOGIC_VECTOR(47 DOWNTO 0);--Sender hardware address (SHA)    Hardware (MAC) address of the sender.
	SIGNAL SPA :OUT STD_LOGIC_VECTOR(31 DOWNTO 0);--Sender protocol address (SPA)    Upper layer protocol address of the sender.
	SIGNAL THA : OUT STD_LOGIC_VECTOR(47 DOWNTO 0);--Hardware address of the intended receiver. This field is ignored in requests.
	SIGNAL TPA : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);-- Upper layer protocol address of the intended receiver. 
    --- Misc
    SIGNAL done :OUT STD_LOGIC;
    SIGNAL reset :IN STD_LOGIC;
    SIGNAL clk   :IN STD_LOGIC
	);
	END ENTITY;
 ------------------------------------------------------
	ARCHITECTURE behavior OF arp_parser IS 
	
------------ one hot encoding state definition
	
	TYPE state_type is (READ_HEADER, READ_WORD_1, READ_WORD_2, READ_WORD_3, READ_WORD_4,READ_WORD_5, READ_WORD_6, WAIT_EOP);
	ATTRIBUTE enum_encoding: STRING;
	attribute enum_encoding of state_type : type is "onehot";
	SIGNAL state, state_NEXT : state_type; 
------------end state machine definition

---------------internal signals
   --- ethr  header
	SIGNAL header_rdy :STD_LOGIC; 
    SIGNAL src_mac_rdy_p1, src_mac_rdy_p2 :STD_LOGIC; 
    -------ARP------------
	SIGNAL SHA_rdy_p1, SHA_rdy_p2 : STD_LOGIC;
	SIGNAL SPA_rdy : STD_LOGIC;
	SIGNAL THA_rdy :  STD_LOGIC;
	SIGNAL TPA_rdy_p1, TPA_rdy_p2 :  STD_LOGIC;

-------------------------------------------
	BEGIN

		PROCESS(reset,clk)
		BEGIN
			IF (reset ='1') THEN
				state <=READ_HEADER;
			
			ELSIF clk'EVENT AND clk ='1' THEN
				state<=state_next;
			END IF;
		END PROCESS;
		
		PROCESS(state, in_wr, in_ctrl, in_data)
		BEGIN
					 src_mac_rdy_p1				<= '0';
					 src_mac_rdy_p2				<= '0';
					 SHA_rdy_p1					<= '0';
					 SHA_rdy_p2					<= '0';
					 SPA_rdy 					<= '0';
					 THA_rdy 					<= '0';
					 TPA_rdy_p1					<= '0';
					 TPA_rdy_p2					<= '0';
					 header_rdy					<= '0';
					 				
		    state_next<=state;
			CASE state IS
			
			WHEN READ_HEADER =>			
				IF(in_wr = '1'  AND in_ctrl=X"FF" ) THEN -- check if ARP request
					header_rdy					<= '1';
					state_next               	 <= READ_WORD_1;
				END IF;
				
			WHEN READ_WORD_1 =>			
				IF(in_wr='1') THEN
					src_mac_rdy_p1				 <= '1';
					state_next               	 <= READ_WORD_2;
				END IF;
				
			WHEN READ_WORD_2 =>
				
				IF(in_wr='1') THEN
					src_mac_rdy_p2				<= '1';
						state_next                <= READ_WORD_3;
				END IF;
				
			WHEN READ_WORD_3 =>
			
				IF(in_wr='1') THEN
					 SHA_rdy_p1					<= '1';
					state_next                <= READ_WORD_4;
				END IF;
				
			WHEN READ_WORD_4 =>
				 
				IF(in_wr='1') THEN
					SHA_rdy_p2					<= '1';
					SPA_rdy 					<= '1';
					state_next         		  <= READ_WORD_5;
				END IF;
				
			WHEN READ_WORD_5 =>
				 
				IF(in_wr='1') THEN
					THA_rdy 					<= '1';
					TPA_rdy_p1					<= '1';
					state_next         		 <= READ_WORD_6;
				END IF;
				
			WHEN READ_WORD_6 =>
				   
				IF(in_wr='1') THEN
					TPA_rdy_p2					<= '1';
					state_next         		 <= WAIT_EOP;
				END IF;
				
			WHEN WAIT_EOP =>
				IF (in_wr ='1'  AND in_ctrl /= X"00") THEN 
						state_next              <= READ_HEADER;
					END IF;
					
			WHEN OTHERS =>
			END CASE;
		END PROCESS;
----------------------------------
	
----------------------------------
		PROCESS(reset, clk)
		BEGIN
		IF (reset ='1') THEN

			src_mac<=(others=>'0'); 
			-------ARP------------
			SHA<=(others=>'0');
			SPA<=(others=>'0');
			THA<=(others=>'0');
			TPA<=(others=>'0');	
			done <='0';	
		ELSIF clk'EVENT AND clk ='1' THEN
			IF header_rdy ='1' THEN
				header<=in_data(63 DOWNTO 0);
			END IF; 
			
			IF src_mac_rdy_p1 ='1' THEN
			   src_mac(47 DOWNTO 32)   <= in_data(15 DOWNTO 0); 
			END IF;
			IF src_mac_rdy_p2 ='1' THEN
			   src_mac (31 DOWNTO 0)   <= in_data(63 DOWNTO 32); 
			END IF; 
			
			-------ARP------------
			
			IF SHA_rdy_p1 = '1' THEN
				SHA(47 DOWNTO 32)		  <= in_data(15 DOWNTO 0);
			END IF;
			IF SHA_rdy_p2  ='1' THEN
				SHA(31 DOWNTO 0)		  <= in_data(63 DOWNTO 32);
			END IF;
			IF SPA_rdy  ='1' THEN
				SPA		  <= in_data(31 DOWNTO 0);
			END IF;
			IF THA_rdy = '1' THEN
					THA       			 <= in_data(63 DOWNTO 16);					
			END IF;
			IF TPA_rdy_p1 = '1' THEN 
			TPA(31 DOWNTO 16)		 <= in_data(15 DOWNTO 0);
			END IF;
			IF TPA_rdy_p2 = '1' THEN 
			TPA(15 DOWNTO 0)		 <= in_data(63 DOWNTO 48);
		
			END IF;
			done <=TPA_rdy_p2;		
		END IF;
		END PROCESS;

 
END behavior;
   