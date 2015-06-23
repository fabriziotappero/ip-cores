--------------------------------------------------------

	LIBRARY IEEE;
	USE IEEE.STD_LOGIC_1164.ALL;
-------------------------------
	ENTITY arp_top IS
	GENERIC(DATA_WIDTH :INTEGER := 64;
			CTRL_WIDTH :INTEGER := 8);
	PORT(
	SIGNAL in_data :IN   STD_LOGIC_VECTOR(63 DOWNTO 0);
	SIGNAL in_ctrl : IN   STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL in_wr :IN STD_LOGIC;
	SIGNAL in_rdy : OUT STD_LOGIC;

	SIGNAL out_data :OUT   STD_LOGIC_VECTOR(63 DOWNTO 0);
	SIGNAL out_ctrl : OUT   STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL out_wr : OUT STD_LOGIC;
	SIGNAL out_rdy : IN STD_LOGIC;
	
	 
    --- Misc
    SIGNAL en :IN STD_LOGIC;
    SIGNAL reset :IN STD_LOGIC;
    SIGNAL clk   :IN STD_LOGIC
	);
	END ENTITY;
 ------------------------------------------------------

	ARCHITECTURE behavior OF arp_top IS 
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
-------COMPONENET SMALL FIFO
	component arp_parser

	GENERIC(DATA_WIDTH :INTEGER := 64;
			CTRL_WIDTH :INTEGER := 8);

	PORT(
	SIGNAL in_data :IN   STD_LOGIC_VECTOR(63 DOWNTO 0);
	SIGNAL in_ctrl : IN   STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL in_wr :IN STD_LOGIC;
	
	SIGNAL header : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
     --- ethr  header
    SIGNAL src_mac : OUT STD_LOGIC_VECTOR(47 DOWNTO 0); 
	SIGNAL SHA :OUT STD_LOGIC_VECTOR(47 DOWNTO 0);
	SIGNAL SPA :OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL THA : OUT STD_LOGIC_VECTOR(47 DOWNTO 0);
	SIGNAL TPA : OUT STD_LOGIC_VECTOR(31 DOWNTO 0); 
    --- Misc
    SIGNAL done :OUT STD_LOGIC;
    SIGNAL reset :IN STD_LOGIC;
    SIGNAL clk   :IN STD_LOGIC
	);

	end component;
    component arp_response

	GENERIC(DATA_WIDTH :INTEGER := 64;
			CTRL_WIDTH :INTEGER := 8);

	PORT(
	SIGNAL out_data : OUT   STD_LOGIC_VECTOR(63 DOWNTO 0);
	SIGNAL out_ctrl : OUT  STD_LOGIC_VECTOR(7 DOWNTO 0);
   SIGNAL out_wr : OUT STD_LOGIC;
	SIGNAL header : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
    SIGNAL src_mac : IN STD_LOGIC_VECTOR(47 DOWNTO 0); 
	SIGNAL SHA :IN STD_LOGIC_VECTOR(47 DOWNTO 0);
	SIGNAL SPA :IN STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL THA : IN STD_LOGIC_VECTOR(47 DOWNTO 0);
	SIGNAL TPA : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    --- Misc
    SIGNAL rdy :IN STD_LOGIC;
    SIGNAL reset :IN STD_LOGIC;
    SIGNAL clk   :IN STD_LOGIC
	);

	end component;
--------------------------------WIRES

	SIGNAL header :  STD_LOGIC_VECTOR(63 DOWNTO 0);
    SIGNAL src_mac :  STD_LOGIC_VECTOR(47 DOWNTO 0); 
 	SIGNAL SHA : STD_LOGIC_VECTOR(47 DOWNTO 0);
	SIGNAL SPA : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL THA :  STD_LOGIC_VECTOR(47 DOWNTO 0);
	SIGNAL TPA :  STD_LOGIC_VECTOR(31 DOWNTO 0);
    --- Misc
    SIGNAL rdy : STD_LOGIC;
    --------------------------------------------------------------
     SIGNAL wr_en : STD_LOGIC;
     SIGNAL data_in :STD_LOGIC_VECTOR(71 DOWNTO 0);
	 SIGNAL rd_en : STD_LOGIC;
	 SIGNAL rd_en_p : STD_LOGIC;
     SIGNAL dout : STD_LOGIC_VECTOR(71 DOWNTO 0);
     SIGNAL fifo_data :STD_LOGIC_VECTOR(63 DOWNTO 0);--output reg [WIDTH-1:0]  dout,    // Data out
	 SIGNAL fifo_ctrl :STD_LOGIC_VECTOR(7 DOWNTO 0);--output reg [WIDTH-1:0]  dout,    // Data out
     SIGNAL full : STD_LOGIC;--output         full,
     SIGNAL nearly_full : STD_LOGIC;--output         nearly_full,
     SIGNAL empty : STD_LOGIC;--output         empty,



-------------------------------------------
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
		wr_en <= in_wr and en;
		in_rdy <=  NOT nearly_full;
		rd_en <= out_rdy AND (NOT empty);
		fifo_data <=dout(71 DOWNTO 8);
		fifo_ctrl <=DOUT(7 DOWNTO 0);
		data_in<=in_data & in_ctrl;
		PROCESS(clk)
		BEGIN		
			IF clk'EVENT AND clk ='1' THEN
			rd_en_p <=rd_en;
			END IF;
		END PROCESS;
		
--	in_rdy <=out_rdy;
	arp_parser1 : arp_parser 
	generic map
	(		DATA_WIDTH  => 64,
			CTRL_WIDTH  => 8)

	PORT MAP(
	in_data =>fifo_data,
	in_ctrl =>fifo_ctrl,
    in_wr =>rd_en_p,
	
	header =>header,
     --- ethr  header
    src_mac =>src_mac, 
	SHA =>SHA,
	SPA =>SPA,
	THA =>THA,
	TPA =>TPA, 
    --- Misc
    done =>rdy,
    reset =>reset,
    clk   =>clk
	);
		arp_response1 : arp_response 
	generic map
	(		DATA_WIDTH  => 64,
			CTRL_WIDTH  => 8)

	PORT MAP(
	out_data =>out_data,
	out_ctrl =>out_ctrl,
    out_wr =>out_wr,
	
	header =>header,
     --- ethr  header
    src_mac =>src_mac, 
	SHA =>SHA,
	SPA =>SPA,
	THA =>THA,
	TPA =>TPA, 
    --- Misc
    rdy =>rdy,
    reset =>reset,
    clk   =>clk
	);
	
END behavior;
   