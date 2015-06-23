--------------------------------------------------------

	LIBRARY IEEE;
	USE IEEE.STD_LOGIC_1164.ALL;
	USE WORK.CONFIG.ALL;
-------------------------------

	ENTITY  router  IS
	GENERIC(DATA_WIDTH :INTEGER := 64;
			CTRL_WIDTH :INTEGER := 8);
	PORT(
	
	 SIGNAL in_data :IN   STD_LOGIC_VECTOR(63 DOWNTO 0);
	 SIGNAL in_ctrl : IN   STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL in_wr :IN STD_LOGIC;
	 SIGNAL in_rdy : OUT STD_LOGIC;
	
	----------------
	
	-------------------
	 SIGNAL out_data : OUT   STD_LOGIC_VECTOR(63 DOWNTO 0);
	 SIGNAL out_ctrl : OUT  STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL out_wr : OUT STD_LOGIC;
	 SIGNAL out_rdy : IN STD_LOGIC;
	 
	 SIGNAL     en : IN STD_LOGIC;
    SIGNAL reset :IN STD_LOGIC;
    SIGNAL clk   :IN STD_LOGIC

	);
	END ENTITY router ;
 ------------------------------------------------------
	ARCHITECTURE behavior OF router  IS 
	-------COMPONENET SMALL FIFO
		COMPONENT  small_fifo IS
	GENERIC(WIDTH :INTEGER := 72;
			MAX_DEPTH_BITS :INTEGER := 3);
	PORT(
	
			   
     SIGNAL din : IN STD_LOGIC_VECTOR(71 DOWNTO 0);--input [WIDTH-1:0] din,     // Data in
     SIGNAL wr_en : IN STD_LOGIC;--input          wr_en,   // Write enable
     
     SIGNAL rd_en : IN STD_LOGIC;--input          rd_en,   // Read the next word 
     
     SIGNAL dout :OUT STD_LOGIC_VECTOR(71 DOWNTO 0);--output reg [WIDTH-1:0]  dout,    // Data out
     SIGNAL full : OUT STD_LOGIC;--output         full,
     SIGNAL nearly_full : OUT STD_LOGIC;--output         nearly_full,
     SIGNAL empty : OUT STD_LOGIC;--output         empty,
     
	
    SIGNAL reset :IN STD_LOGIC;
    SIGNAL clk   :IN STD_LOGIC

	);
	END COMPONENT;

------------ one hot encoding state definition
	TYPE state_type IS (IDLE , IN_MODULE_HDRS, READ_WORD1, IN_PACKET);
	ATTRIBUTE enum_encoding: STRING;
	ATTRIBUTE enum_encoding of state_type : type is "onehot";

	SIGNAL state, state_next : state_type; 
--------------------------------------------------------------
  
-------------------------------------------
     SIGNAL data_in :STD_LOGIC_VECTOR(71 DOWNTO 0);
	  SIGNAL rd_en : STD_LOGIC;
     SIGNAL dout : STD_LOGIC_VECTOR(71 DOWNTO 0);
     SIGNAL fifo_data :STD_LOGIC_VECTOR(63 DOWNTO 0);--output reg [WIDTH-1:0]  dout,    // Data out
	  SIGNAL fifo_ctrl :STD_LOGIC_VECTOR(7 DOWNTO 0);--output reg [WIDTH-1:0]  dout,    // Data out
     SIGNAL full : STD_LOGIC;--output         full,
     SIGNAL nearly_full : STD_LOGIC;--output         nearly_full,
     SIGNAL empty : STD_LOGIC;--output         empty,
	-----------------------------------------
	 SIGNAL 		in_data_int			:	   	STD_LOGIC_VECTOR(63 DOWNTO 0)	;
	 SIGNAL 		in_ctrl_int 		: 	   	STD_LOGIC_VECTOR(7 DOWNTO 0)	;
	 SIGNAL 		in_wr_int 			:	 		STD_LOGIC	;
	 SIGNAL 		in_rdy_int 			:	 		STD_LOGIC	;
		 SIGNAL 		wr_en 			:	 		STD_LOGIC	;
	BEGIN
	
	-------PORT MAP SMALL FIFO
		small_fifo_Inst :  small_fifo 
	GENERIC MAP(WIDTH  => 72,
			MAX_DEPTH_BITS  => 3)
	PORT MAP(
	
			   
      din =>(data_in),    
      wr_en =>wr_en,   
     
      rd_en => rd_en,   
     
      dout =>dout,   
      full =>full,
      nearly_full =>nearly_full,
      empty => empty,
     
	
     reset => reset ,
     clk  => clk 

	);

-------PORT MAP SMALL FIFO
		wr_en <= en and in_wr;
		in_rdy <=  NOT nearly_full;
--		rd_en <= out_rdy AND (NOT empty) AND fifo_go;
		fifo_data <=dout(71 DOWNTO 8);
		fifo_ctrl <=DOUT(7 DOWNTO 0);
		data_in<=in_data & in_ctrl;
		
		PROCESS(reset,clk)
		BEGIN
			IF (reset ='1') THEN
				state <=IDLE;
			ELSIF clk'EVENT AND clk ='1' THEN
				state<=state_next;
			END IF;
		END PROCESS;
		PROCESS(state, fifo_data, fifo_ctrl )
			BEGIN
			    in_data_int <= fifo_data;
				 in_ctrl_int <= fifo_ctrl;
				 in_wr_int   <= '0';
				 rd_en 		 <= '0';
				state_next <= state;
				CASE state IS
					WHEN IDLE =>
						   IF(empty = '0') THEN
											   rd_en 		 			<= '1';									
											   state_next 				<= IN_MODULE_HDRS;				
						END IF;
					WHEN IN_MODULE_HDRS =>
						IF (out_rdy='1'  ) THEN
--							IF (out_rdy='1'  ) THEN
									in_data_int(63 DOWNTO 48)<= DEFAULT_INT_PORT;
									in_wr_int   <= '1';
								    rd_en 		<= '1';	
								    state_next 	<= READ_WORD1;
						
						END IF;
					
					WHEN READ_WORD1 =>
									in_data_int(63 DOWNTO 16)<= VC_MAC;
							IF (out_rdy='1'  ) THEN
									 
									 in_wr_int   <= '1';
								    rd_en 		<= '1';	
								    state_next 	<= IN_PACKET;
						
						END IF;
					
					WHEN IN_PACKET		=>	
					
								    
						IF ( fifo_ctrl /= X"00" ) THEN
									IF ( out_rdy ='1' ) THEN
									state_next               <= IDLE;
									in_wr_int				<=	'1' ;
									END IF;
						ELSIF(empty = '0' AND out_rdy ='1')THEN
									rd_en					<=	'1'	;
									in_wr_int			<=	'1' ;
						END IF;
					
  					
				END CASE;
			END PROCESS;
 PROCESS(clk,reset)
		BEGIN
			
			IF clk'EVENT AND clk ='1' THEN
				 out_data  <=	in_data_int ;
				 out_ctrl  <=	in_ctrl_int ;
				 out_wr	  <=	in_wr_int ;
										
			END IF;
		END PROCESS;	
	 
END behavior;
   