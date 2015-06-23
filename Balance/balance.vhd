--------------------------------------------------------
	LIBRARY IEEE;
	USE IEEE.STD_LOGIC_1164.ALL;
	use ieee.numeric_std.all;
	use IEEE.STD_LOGIC_ARITH.ALL;
	use IEEE.STD_LOGIC_UNSIGNED.ALL;
	
-------------------------------
	ENTITY  balance IS
	GENERIC(DATA_WIDTH :INTEGER := 64;
			CTRL_WIDTH :INTEGER := 8);
	PORT(
		
			SIGNAL in_data :IN   STD_LOGIC_VECTOR(63 DOWNTO 0);
			SIGNAL in_ctrl : IN   STD_LOGIC_VECTOR(7 DOWNTO 0);
			SIGNAL in_wr :IN STD_LOGIC;
			SIGNAL in_rdy : OUT STD_LOGIC;
			
			SIGNAL out_data : OUT   STD_LOGIC_VECTOR(63 DOWNTO 0);
			SIGNAL out_ctrl : OUT  STD_LOGIC_VECTOR(7 DOWNTO 0);
			SIGNAL out_wr : OUT STD_LOGIC;
			SIGNAL out_rdy : IN STD_LOGIC;
			
			SIGNAL in_next_mac :IN   STD_LOGIC_VECTOR(47 DOWNTO 0);
			SIGNAL in_exit_port :IN   STD_LOGIC_VECTOR(7 DOWNTO 0);	
			SIGNAL in_next_mac_rdy : IN STD_LOGIC;
			SIGNAL out_rd_next_mac : OUT STD_LOGIC;
			SIGNAL key :OUT   STD_LOGIC_VECTOR(11 DOWNTO 0); 
			
		   SIGNAL reset :IN STD_LOGIC;
		   SIGNAL clk   :IN STD_LOGIC

	);
	END ENTITY;
	-----------------------------------------------------
	ARCHITECTURE behavior OF balance IS 
-------COMPONENET SMALL FIFO
		COMPONENT  small_fifo IS
				GENERIC(WIDTH :INTEGER := 72;
						MAX_DEPTH_BITS :INTEGER := 3);
				PORT(
					 SIGNAL din : IN STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0);
					 SIGNAL wr_en : IN STD_LOGIC;
					 SIGNAL rd_en : IN STD_LOGIC;
					 SIGNAL dout :OUT STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0);
					 SIGNAL full : OUT STD_LOGIC;
					 SIGNAL nearly_full : OUT STD_LOGIC;
					 SIGNAL empty : OUT STD_LOGIC;
					 SIGNAL reset :IN STD_LOGIC;
					 SIGNAL clk   :IN STD_LOGIC
				);
		END COMPONENT;
-------COMPONENET SMALL FIFO
------COMPONENT vlan2ext
	COMPONENT 	 n_mac IS
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
	END COMPONENT n_mac;
------COMPONENT vlan2ext
------------ one hot encoding state definition
	
	TYPE state_type IS (IDLE, IN_MODULE_HDRS, WORD_1, IN_PACKET);
	ATTRIBUTE enum_encoding: STRING;
	ATTRIBUTE enum_encoding of state_type : type is "onehot";

	SIGNAL state, state_NEXT : state_type; 

------------end state machine definition

----------------------FIFO	  
	  SIGNAL fifo_data : STD_LOGIC_VECTOR(63 DOWNTO 0);
	  SIGNAL fifo_ctrl : STD_LOGIC_VECTOR(7 DOWNTO 0);  
	  SIGNAL in_fifo_in : STD_LOGIC_VECTOR(71 DOWNTO 0);    
      SIGNAL in_fifo_rd_en : STD_LOGIC;
	  SIGNAL in_fifo_go : STD_LOGIC;
	  SIGNAL in_fifo_rd_en_p : STD_LOGIC;
      SIGNAL in_fifo_dout  : STD_LOGIC_VECTOR(71 DOWNTO 0);  
      SIGNAL in_fifo_full : STD_LOGIC;
      SIGNAL in_fifo_nearly_full : STD_LOGIC;
      SIGNAL in_fifo_empty : STD_LOGIC;
------------------------------
	  SIGNAL ctrl_fifo_in : STD_LOGIC_VECTOR(55 DOWNTO 0);         
      SIGNAL ctrl_fifo_rd : STD_LOGIC;       
      SIGNAL ctrl_fifo_dout : STD_LOGIC_VECTOR(55 DOWNTO 0);   
      SIGNAL ctrl_fifo_full : STD_LOGIC; 
      SIGNAL ctrl_fifo_nearly_full : STD_LOGIC; 
      SIGNAL ctrl_fifo_empty : STD_LOGIC; 
--	  SIGNAL cnt : INTEGER; 
	 
	  SIGNAL 		out_data_i 			:	   	STD_LOGIC_VECTOR(63 DOWNTO 0)	;
	  SIGNAL 		out_ctrl_i 			: 	   	STD_LOGIC_VECTOR(7 DOWNTO 0)	;
	  SIGNAL 		out_wr_i 			: 	 	STD_LOGIC	;
	
	  
---------------------------------------------------
	BEGIN
	
	
	------PORT MAP open_header
	n_mac_Inst : n_mac 
	GENERIC MAP (DATA_WIDTH  => 64,
			CTRL_WIDTH => 8)
	PORT MAP(
	 		in_data 			=>	in_data,
	 		in_ctrl 			=> 	in_ctrl ,
     		in_wr 				=>	in_wr,
			rd_next_mac 		=>  out_rd_next_mac,    
			key 				=>  key, 
     		reset 				=>	reset,
     		clk   				=>	clk
	);
	
	------PORT MAP open_header
	
		-------PORT MAP SMALL FIFO DATA
		small_fifo_Inst1 :  small_fifo 
		GENERIC MAP(WIDTH  => 72,
				MAX_DEPTH_BITS  => 5)
			PORT MAP(			   
				  din =>in_fifo_in,    
				  wr_en =>in_wr,       
				  rd_en => in_fifo_rd_en,       
				  dout =>in_fifo_dout,   
				  full =>in_fifo_full,
				  nearly_full =>in_fifo_nearly_full,
				  empty => in_fifo_empty,
				  reset => reset ,
				  clk  => clk 
			);
	
	

-------PORT MAP SMALL FIFO
		-------PORT MAP SMALL FIFO DATA
		small_fifo_Inst_ctrl :  small_fifo 
	GENERIC MAP(WIDTH  => 56,
			MAX_DEPTH_BITS  => 5)
				PORT MAP(			   
				  din =>ctrl_fifo_in,    
				  wr_en =>in_next_mac_rdy,        
				  rd_en => ctrl_fifo_rd,       
				  dout =>ctrl_fifo_dout,   
				  full =>ctrl_fifo_full,
				  nearly_full =>ctrl_fifo_nearly_full,
				  empty => ctrl_fifo_empty,
				  reset => reset ,
				  clk  => clk 
				);
	

-----------------------
        in_fifo_in 	<= 	in_data & in_ctrl ;
		fifo_data 	<=	   in_fifo_dout(71 DOWNTO 8)	;
		fifo_ctrl 	<= 	in_fifo_dout(7 DOWNTO 0)	;
		ctrl_fifo_in <= in_next_mac & in_exit_port;
		in_fifo_rd_en <=out_rdy AND (NOT in_fifo_empty) AND in_fifo_go;
		 in_rdy 	<=	(NOT in_fifo_nearly_full) AND (NOT ctrl_fifo_nearly_full)	;
--	in_rdy 	<=	(NOT in_fifo_nearly_full) 	;	
		PROCESS(clk,reset)
		BEGIN
			IF (reset ='1') THEN
				state <=IDLE;	
				ELSIF clk'EVENT AND clk ='1' THEN
				state<=state_next;
			END IF;
		END PROCESS;
		PROCESS(clk,reset)
			BEGIN
				IF (reset ='1') THEN
					in_fifo_rd_en_p <='0';	
				ELSIF clk'EVENT AND clk ='1' THEN
					in_fifo_rd_en_p <=in_fifo_rd_en;
				END IF;
		END PROCESS;

PROCESS(state, ctrl_fifo_empty ,fifo_data, fifo_ctrl,in_fifo_empty)
	BEGIN
							state_next 				<= 	state;
							out_data_i				<=  fifo_data ;
							out_ctrl_i				<=  fifo_ctrl ;
							out_wr_i				   <=  in_fifo_rd_en_p ;
							ctrl_fifo_rd			<=	'0'	;
							in_fifo_go				<=	'0'	; 
	
		CASE state IS
			WHEN IDLE =>
				   IF(ctrl_fifo_empty = '0') THEN
								   ctrl_fifo_rd				<=	'1'	;
								   in_fifo_go				<=	'1'	;	
								   state_next 				<=  IN_MODULE_HDRS;				
					END IF;						
			WHEN IN_MODULE_HDRS =>
							in_fifo_go				<=	'1'	;
							IF ( in_fifo_rd_en_p ='1'  )THEN
								out_data_i(55 downto 48)<=	 X"01";--ctrl_fifo_dout(7 DOWNTO 0) ;								
								state_next              <=  WORD_1;
							END IF;				
			WHEN WORD_1	=>
								in_fifo_go		   		<=	'1'	;
							IF ( in_fifo_rd_en_p ='1'  ) THEN
								out_data_i(63 downto 16)<=	 ctrl_fifo_dout (55 DOWNTO 8);
								state_next              <=   IN_PACKET;
								END IF;
			WHEN IN_PACKET	=>
								in_fifo_go		   		<=	'1'	;
							IF ( fifo_ctrl /=X"00" ) THEN
								in_fifo_go		   		<=	'0'	;
							state_next              <=   IDLE;
						END IF;
				
			END CASE;
	END PROCESS;
---------------Register output
		
		
		PROCESS(clk,reset) 
		BEGIN
			
			IF clk'EVENT AND clk ='1' THEN
									out_data				<=	out_data_i;
									out_ctrl				<=	out_ctrl_i;
									out_wr					<=	out_wr_i;	
			END IF;
		END PROCESS;	
END behavior;
   