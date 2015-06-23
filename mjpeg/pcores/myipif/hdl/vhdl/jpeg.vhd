--------------------------------------------------------------------------------
-- TODO
-- * register all output signals
-- * ??? delay input_fifo_valid by one cycle to match data
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;


entity jpeg is
  port(
    	Clk			:  in std_logic;
		data_i		:  in std_logic_vector(31 downto 0);
		reset_i		:  in std_logic;
		
		-- Indicates the detection of an eoi marker at the input side 
		-- of the pipeline. This is used to handle the input stream.
		eoi_o			: out std_logic;

		-- The Huffman- and the header-component may run in an error-state
		-- on invalid input data.
		error_o		: out std_logic;

		-- data and context at the output side of the pipeline		
		context_o	: out std_logic_vector (3 downto 0);	
		red_o			: out STD_LOGIC_VECTOR (7 downto 0);
		green_o		: out STD_LOGIC_VECTOR (7 downto 0);
		blue_o		: out STD_LOGIC_VECTOR (7 downto 0);
		width_o		: out std_logic_vector(15 downto 0);
		height_o		: out std_logic_vector(15 downto 0);	
		sampling_o	: out std_logic_vector( 1 downto 0);

--		-- debug
--		LEDs			: out std_logic_vector(3 downto 0);
--		BUTTONs		:  in std_logic_vector(4 downto 0); -- 0:left, 1:right, 2:up, 3:down, 4:center
--		SWITCHEs		:  in std_logic_vector(3 downto 0);
--		-- chipscope-debugging
--		chipscope_o	: out std_logic_vector(127 downto 0);

		-- flow controll
		datavalid_i :  in std_logic;
		datavalid_o : out std_logic;
		ready_i		:  in std_logic;
		ready_o		: out std_logic
    );
end entity jpeg;





architecture IMP of jpeg is

-- **********************************************************************************************
-- * Components
-- **********************************************************************************************

------------------------------------------------------------
-- FIFO to buffer the input data
------------------------------------------------------------
component jpeg_input_fifo
	port (
	din: IN std_logic_VECTOR(31 downto 0);
	rd_clk: IN std_logic;
	rd_en: IN std_logic;
	rst: IN std_logic;
	wr_clk: IN std_logic;
	wr_en: IN std_logic;
	almost_full: OUT std_logic;
	dout: OUT std_logic_VECTOR(7 downto 0);
	empty: OUT std_logic;
	full: OUT std_logic;
	valid: OUT std_logic);
end component;
------------------------------------------------------------


------------------------------------------------------------
-- Replaces "FF00" with "FF" and filters out other occurances
-- of "FF", detects eoi markers 
------------------------------------------------------------
component jpeg_check_FF is
	port(
		Clk				: in std_logic;
		reset_i			: in std_logic;
		
		header_valid_i	: in  std_logic;
		header_select_i: in  std_logic;
		eoi_o 			: out std_logic;	
	
		data_i			: in std_logic_vector(7 downto 0);
		data_o			: out std_logic_vector(7 downto 0);
		
		-- bit occupancy
		-- 0: header_valid
		-- 1: header_select
		-- 2: end of block 
		-- 3: end of image
		context_o		: out std_logic_vector(3 downto 0);	
	
		-- flow control
		datavalid_i 	: in std_logic;
		datavalid_o 	: out std_logic;
		ready_i			: in  std_logic;
		ready_o			: out std_logic
	);
end component jpeg_check_FF;
--------------------------------------------------------------


--------------------------------------------------------------
-- Fifo between checkff and huffman
--------------------------------------------------------------
component jpeg_checkff_fifo
	port (
		din: IN std_logic_VECTOR(11 downto 0);
		rd_clk: IN std_logic;
		rd_en: IN std_logic;
		rst: IN std_logic;
		wr_clk: IN std_logic;
		wr_en: IN std_logic;
		almost_empty: OUT std_logic;
		almost_full: OUT std_logic;
		dout: OUT std_logic_VECTOR(11 downto 0);
		empty: OUT std_logic;
		full: OUT std_logic;
		valid: OUT std_logic
	);
end component;
--------------------------------------------------------------


--------------------------------------------------------------
-- Huffman decoder.
--------------------------------------------------------------
component jpeg_huffman is
	port(
		Clk				: in std_logic;
		reset_i			: in std_logic;
		error_o			: out std_logic;
		header_select_i	: in std_logic;
		
		ht_symbols_wea_i	: in std_logic;
		ht_tables_wea_i	: in std_logic;
		ht_select_i			: in std_logic_vector(2 downto 0);   -- bit 2: dc (low) or ac (high), bit 1 and 0: table-nr.
		ht_tables_address_i			: in std_logic_vector(7 downto 0);	-- address in bram:   ht_select_o & ht_tables_address_o
		ht_nr_of_symbols_address_i	: in std_logic_vector(3 downto 0);	-- address in distrib-ram:   ht_select_o & ht_nr_of_symbols_address_o
		ht_data_i			: in std_logic_vector(7 downto 0);
		
		context_i		: in std_logic_vector(3 downto 0);	
		data_i			: in std_logic_vector(7 downto 0);
		context_o		: out std_logic_vector(3 downto 0);	
		data_o			: out std_logic_vector(15 downto 0);

		-- header data
		comp1_huff_dc_i : in std_logic_vector(3 downto 0);
		comp2_huff_dc_i : in std_logic_vector(3 downto 0);
		comp3_huff_dc_i : in std_logic_vector(3 downto 0);
		comp1_huff_ac_i : in std_logic_vector(3 downto 0);
		comp2_huff_ac_i : in std_logic_vector(3 downto 0);
		comp3_huff_ac_i : in std_logic_vector(3 downto 0);
		sampling_i      : in std_logic_vector(3 downto 0); -- "00"->gray, "01"->4:2:0, "10"->4:2:2, "11"->4:4:4

		-- flow control
		-- datavalid signal valid data in this cycle
		-- ready signals "I am ready in NEXT cycle"
		datavalid_i 	: in std_logic;
		datavalid_o 	: out std_logic;
		ready_i			: in  std_logic;
		ready_o			: out std_logic
	);
end component jpeg_huffman;
--------------------------------------------------------------


--------------------------------------------------------------
-- Dequantization
--------------------------------------------------------------
component jpeg_dequantize is
	port(
		Clk				: in std_logic;
		reset_i			: in std_logic;

		context_i		: in  std_logic_vector(3 downto 0);	
		data_i			: in  std_logic_vector(11 downto 0);
		context_o		: out std_logic_vector(3 downto 0);	
		data_o			: out std_logic_vector(11 downto 0);
		
		-- header data
		header_select_i	: in std_logic;
		sampling_i			: in std_logic_vector(3 downto 0);
		qt_wea_i				: in std_logic;
		qt_select_i			: in std_logic_vector(1 downto 0);
		qt_data_i			: in std_logic_vector(7 downto 0);
		comp1_qt_number_i : in std_logic_vector(1 downto 0);
		comp2_qt_number_i : in std_logic_vector(1 downto 0);
		comp3_qt_number_i : in std_logic_vector(1 downto 0);

		-- flow control
		datavalid_i 	: in std_logic;
		datavalid_o 	: out std_logic;
		ready_i			: in  std_logic;
		ready_o			: out std_logic
	);
end component jpeg_dequantize;
--------------------------------------------------------------


--------------------------------------------------------------
-- Address-maping to revert the ZigZag-Order
--------------------------------------------------------------
component jpeg_dezigzag is
	port(
		Clk 		: in std_logic; 
		context_i: in  std_logic_vector(3 downto 0);	
		data_i	: in std_logic_vector(11 downto 0);
		reset_i	: in std_logic;
		
		context_o: out std_logic_vector(3 downto 0);	
		data_o 	: out std_logic_vector(11 downto 0);

		-- flow control
		datavalid_i 	: in std_logic;
		datavalid_o 	: out std_logic;
		ready_i			: in  std_logic;
		ready_o			: out std_logic
	);
end component jpeg_dezigzag;
--------------------------------------------------------------


--------------------------------------------------------------
-- Inverse Discrete Cosine Transformation 
-- Core provided by Xilinx, with some additional logic 
-- for reverse flow control
--------------------------------------------------------------
component jpeg_idct is
	port(
    	Clk				: in  std_logic;
		reset_i			: in  std_logic;
		context_i		: in  std_logic_vector( 3 downto 0);	
		data_i			: in  std_logic_vector(11 downto 0);
		context_o		: out std_logic_vector( 3 downto 0);	
		data_o			: out std_logic_vector( 8 downto 0);
		datavalid_i 	: in  std_logic;
		datavalid_o 	: out std_logic;
		ready_i			: in  std_logic;
		ready_o			: out std_logic
	);
end component jpeg_idct;
--------------------------------------------------------------


--------------------------------------------------------------
-- Upsampling
--------------------------------------------------------------
component jpeg_upsampling is
	port(
		Clk			: in  std_logic;
		reset_i		: in  std_logic;
		context_i	: in  std_logic_vector(3 downto 0);	
		data_i		: in  std_logic_vector(8 downto 0);
		sampling_i	: in  std_logic_vector(3 downto 0);
		context_o	: out std_logic_vector(3 downto 0);	
		Y_o			: out std_logic_vector(8 downto 0);
		Cb_o			: out std_logic_vector(8 downto 0);
		Cr_o			: out std_logic_vector(8 downto 0);
		datavalid_i	: in  std_logic;
		datavalid_o	: out std_logic;
		ready_i		: in  std_logic;
		ready_o		: out std_logic
	);
end component jpeg_upsampling; 
--------------------------------------------------------------


--------------------------------------------------------------
-- Color Transformation
--------------------------------------------------------------
component jpeg_YCbCr2RGB is
	port(
		Clk			: in  std_logic;
		reset_i		: in  std_logic;
		context_i	: in  std_logic_vector(3 downto 0);	
		Y_i			: in  std_logic_vector(8 downto 0);
		Cb_i			: in  std_logic_vector(8 downto 0);
		Cr_i			: in  std_logic_vector(8 downto 0);
		context_o	: out std_logic_vector(3 downto 0);	
		R_o			: out std_logic_vector(7 downto 0);
		G_o			: out std_logic_vector(7 downto 0);
		B_o			: out std_logic_vector(7 downto 0);
		datavalid_i	: in  std_logic;
		datavalid_o	: out std_logic;
		ready_i		: in  std_logic;
		ready_o		: out std_logic
	);
end component jpeg_YCbCr2RGB; 
--------------------------------------------------------------


------------------------------------------------------------
-- This one first reads out header information,
-- then provides header information
------------------------------------------------------------
component jpeg_header is
	port(
		Clk			: in std_logic;
		data_i		: in std_logic_vector(7 downto 0);
		datavalid_i	: in std_logic;
		reset_i		: in std_logic;
		eoi_i			: in std_logic;	
	
		header_valid_o	: out std_logic;
		header_select_o: out std_logic;
		header_error_o	: out std_logic;
		
		-- initialize the huffmann tables located in the huffmann-decoder entity
		ht_symbols_wea_o	: out std_logic;
		ht_tables_wea_o	: out std_logic;
		ht_select_o			: out std_logic_vector(2 downto 0);		-- bit 2: dc (low) or ac (high), bit 1 and 0: table-nr.
		ht_tables_address_o			: out std_logic_vector(7 downto 0);	-- address in bram:   ht_select_o & ht_tables_address_o
		ht_nr_of_symbols_address_o	: out std_logic_vector(3 downto 0);	-- address in distrib-ram:   ht_select_o & ht_nr_of_symbols_address_o
		ht_data_o			: out std_logic_vector(7 downto 0);
		
		-- initialize the quantization tables located in the dequantize entity
		qt_wea_o		: out std_logic;
		qt_select_o	: out std_logic_vector(1 downto 0);
		qt_data_o	: out std_logic_vector(7 downto 0);
		
		-- sos-field
		comp1_huff_dc_o : out std_logic_vector(3 downto 0);
		comp2_huff_dc_o : out std_logic_vector(3 downto 0);
		comp3_huff_dc_o : out std_logic_vector(3 downto 0);
		comp1_huff_ac_o : out std_logic_vector(3 downto 0);
		comp2_huff_ac_o : out std_logic_vector(3 downto 0);
		comp3_huff_ac_o : out std_logic_vector(3 downto 0);
		
		--sof-field
		height_o				: out std_logic_vector(15 downto 0);
		width_o				: out std_logic_vector(15 downto 0);
		sampling_o			: out std_logic_vector(1 downto 0); 	-- "00"->gray, "01"->4:2:0, "10"->4:2:2, "11"->4:4:4
		comp1_qt_number_o	: out std_logic_vector(0 downto 0);
		comp2_qt_number_o	: out std_logic_vector(0 downto 0);
		comp3_qt_number_o	: out std_logic_vector(0 downto 0)
	);
end component jpeg_header;
--------------------------------------------------------------




-- **********************************************************************************************
-- * Signals
-- ********************************************************************************************** 
	signal ready, ready_D : std_logic :='0';
	signal reset, error : std_logic :='0';

	-- double width to have old and new values present in pipline in case of picture change
	signal sampling, sampling_D : std_logic_vector(3 downto 0) :=(others=>'0');
	signal width, width_D, height, height_D : std_logic_vector(31 downto 0) :=(others=>'0');
	signal comp1_qt_number, comp1_qt_number_D : std_logic_vector(1 downto 0) := (others=>'0');
	signal comp2_qt_number, comp2_qt_number_D : std_logic_vector(1 downto 0) := (others=>'0');
	signal comp3_qt_number, comp3_qt_number_D : std_logic_vector(1 downto 0) := (others=>'0');
	signal sampling_out : std_logic_vector(1 downto 0) :=(others=>'0');
	signal width_out, height_out : std_logic_vector(15 downto 0) :=(others=>'0');

	-- Signals to connect the pipeline components. The signals are named after the component 
	-- from which it originates.
	signal check_FF_ready : std_logic :='0';
	signal check_FF_data : std_logic_vector(7 downto 0) := (others=>'0');
	signal check_FF_datavalid : std_logic :='0';
	signal check_FF_eoi : std_logic :='0';
	signal check_FF_context : std_logic_vector(3 downto 0) := (others=>'0');

	signal input_fifo_data : std_logic_vector(7 downto 0) := (others=>'0');
	signal input_fifo_datavalid, input_fifo_full, input_fifo_almost_full, input_fifo_empty, input_fifo_almost_empty : std_logic :='0';
	signal input_fifo_rd_en, input_fifo_wr_en, input_fifo_reset : std_logic :='0';

	signal checkff_fifo_data : std_logic_vector(11 downto 0) := (others=>'0');
	signal checkff_fifo_datavalid, checkff_fifo_full, checkff_fifo_almost_full, checkff_fifo_empty, checkff_fifo_almost_empty : std_logic :='0';
	signal checkff_fifo_ready : std_logic :='0';
	
	signal huffman_error, huffman_ready, huffman_datavalid, huffman_eob : std_logic :='0';
	signal huffman_address : std_logic_vector(5 downto 0) := (others=>'0');
	signal huffman_data : std_logic_vector(15 downto 0) := (others=>'0');
	signal huffman_context : std_logic_vector(3 downto 0) :=(others=>'0');

	signal dezigzag_context : std_logic_vector(3 downto 0) :=(others=>'0');
	signal dezigzag_data : std_logic_vector(11 downto 0) := (others=>'0');
	signal dezigzag_datavalid, dezigzag_ready : std_logic :='0';

	signal dequantize_datavalid, dequantize_ready : std_logic :='0';
	signal dequantize_context : std_logic_vector(3 downto 0) :=(others=>'0');
	signal dequantize_data : std_logic_vector(11 downto 0) := (others=>'0');
	
	signal idct_datavalid, idct_ready : std_logic :='0';
	signal idct_context : std_logic_vector(3 downto 0) :=(others=>'0');
	signal idct_data : std_logic_vector(8 downto 0) := (others=>'0');
	
	signal upsampling_datavalid, upsampling_ready : std_logic :='0';
	signal upsampling_context : std_logic_vector(3 downto 0) :=(others=>'0');
	signal upsampling_Y, upsampling_Cb, upsampling_Cr : std_logic_vector(8 downto 0) := (others=>'0');
	
	signal YCbCr2RGB_datavalid, YCbCr2RGB_ready : std_logic :='0';
	signal YCbCr2RGB_context : std_logic_vector(3 downto 0) :=(others=>'0');
	signal YCbCr2RGB_R, YCbCr2RGB_G, YCbCr2RGB_B : std_logic_vector(7 downto 0) := (others=>'0');

	signal vga_datavalid, vga_ready, vga_error : std_logic :='0';

   -- header: info
	signal header_select, header_valid, header_error : std_logic :='0';
	-- huffman tables
	signal header_ht_symbols_wea, header_ht_tables_wea :std_logic :='0';
	signal header_ht_select : std_logic_vector(2 downto 0) := (others=>'0');
	signal header_ht_tables_address : std_logic_vector(7 downto 0) := (others=>'0');
	signal header_ht_nr_of_symbols_address : std_logic_vector(3 downto 0) := (others=>'0');
	signal header_ht_data : std_logic_vector(7 downto 0) := (others=>'0');
	-- quantization tables
	signal header_qt_wea : std_logic := '0';
	signal header_qt_select : std_logic_vector(1 downto 0) := (others=>'0');
	signal header_qt_data : std_logic_vector(7 downto 0) := (others=>'0');
	-- header: sos-field
	signal header_comp1_huff_dc : std_logic_vector(3 downto 0) := (others=>'0');
	signal header_comp2_huff_dc : std_logic_vector(3 downto 0) := (others=>'0');
	signal header_comp3_huff_dc : std_logic_vector(3 downto 0) := (others=>'0');
	signal header_comp1_huff_ac : std_logic_vector(3 downto 0) := (others=>'0');
	signal header_comp2_huff_ac : std_logic_vector(3 downto 0) := (others=>'0');
	signal header_comp3_huff_ac : std_logic_vector(3 downto 0) := (others=>'0');
	--header: sof-field
	signal header_height : std_logic_vector(15 downto 0) := (others=>'0');
	signal header_width : std_logic_vector(15 downto 0) := (others=>'0');
	signal header_sampling: std_logic_vector(1 downto 0) := (others=>'0');
	signal header_comp1_qt_number : std_logic_vector(0 downto 0) := (others=>'0');
	signal header_comp2_qt_number : std_logic_vector(0 downto 0) := (others=>'0');
	signal header_comp3_qt_number : std_logic_vector(0 downto 0) := (others=>'0');




begin



-- **********************************************************************************************
-- * Debugging
-- **********************************************************************************************
--LEDs <= not header_error & not huffman_error & not vga_ready & not header_valid; 
--chipscope_o <= data_i & 
--					input_fifo_data & YCbCr2RGB_R & YCbCr2RGB_G & YCbCr2RGB_B & 
--					datavalid_i & ready_i & YCbCr2RGB_datavalid & ready & header_sampling & check_FF_eoi & 
--					(header_error or huffman_error) & check_FF_data & checkff_fifo_data(7 downto 0) & 
--					huffman_data(7 downto 0) & header_width &  header_height; 
-- **********************************************************************************************



--------------------------------------------------------------
-- store some values from header
--------------------------------------------------------------
process(	header_select, header_sampling, sampling, width, height, header_width, header_height,
			header_comp1_qt_number, header_comp2_qt_number, header_comp3_qt_number,
			comp1_qt_number, comp2_qt_number, comp3_qt_number)
begin
	sampling_D	<= sampling;
	comp1_qt_number_D <= comp1_qt_number;
	comp2_qt_number_D <= comp2_qt_number;
	comp3_qt_number_D <= comp3_qt_number;
	width_D		<= width;
	height_D		<= height;
	if(header_select='0') then
		sampling_D(1 downto 0)	<= header_sampling;
		comp1_qt_number_D(0 downto 0) <= header_comp1_qt_number;
		comp2_qt_number_D(0 downto 0) <= header_comp2_qt_number;
		comp3_qt_number_D(0 downto 0) <= header_comp3_qt_number;
		width_D(15 downto 0)		<= header_width;
		height_D(15 downto 0)	<= header_height;
	else 
		sampling_D(3 downto 2)	<= header_sampling;
		comp1_qt_number_D(1 downto 1) <= header_comp1_qt_number;
		comp2_qt_number_D(1 downto 1) <= header_comp2_qt_number;
		comp3_qt_number_D(1 downto 1) <= header_comp3_qt_number;
		width_D(31 downto 16)	<= header_width;
		height_D(31 downto 16)	<= header_height;
	end if;
end process;

process(Clk)
begin
	if rising_edge(Clk) then
		if reset='1' then
			sampling <= (others=>'0');
			comp1_qt_number	<= (others=>'0');
			comp2_qt_number	<= (others=>'0');
			comp3_qt_number	<= (others=>'0');
			width		<= (others=>'0');
			height	<= (others=>'0');
		else
			sampling <= sampling_D;
			comp1_qt_number	<= comp1_qt_number_D;
			comp2_qt_number	<= comp2_qt_number_D;
			comp3_qt_number	<= comp3_qt_number_D;
			width		<= width_D;
			height	<= height_D;
		end if;
	end if;
end process;
--------------------------------------------------------------




-- **********************************************************************************************
-- * Port Maps
-- **********************************************************************************************

--------------------------------------------------------------
-- FIFO to buffer the input data
--------------------------------------------------------------
jpeg_input_fifo_p:jpeg_input_fifo
	port map (
		din 				=> data_i,
		rd_clk			=> Clk,
		rd_en 			=> input_fifo_rd_en,
		rst 				=> input_fifo_reset,
		wr_clk 			=> Clk,
		wr_en 			=> input_fifo_wr_en,
		almost_full 	=> input_fifo_almost_full,
		dout 				=> input_fifo_data,
		empty 			=> input_fifo_empty,
		full 				=> input_fifo_full,
		valid 			=> input_fifo_datavalid
	);
input_fifo_reset <= reset or check_FF_eoi;
--------------------------------------------------------------
input_fifo_rd_en <= check_FF_ready;
input_fifo_wr_en <= datavalid_i and ready;


--------------------------------------------------------------
-- Replaces "FF00" with "FF" and filters out other occurances
-- of "FF" 
--------------------------------------------------------------
jpeg_check_FF_p:jpeg_check_FF
	port map(
		Clk				=> Clk,
		reset_i			=> reset,
		eoi_o				=> check_FF_eoi,
		header_valid_i	=> header_valid,
		header_select_i=> header_select,
		data_i			=> input_fifo_data,
		data_o			=> check_FF_data,
		context_o		=> check_FF_context,
		datavalid_i 	=> input_fifo_datavalid,
		datavalid_o 	=> check_FF_datavalid,
		ready_i			=> checkff_fifo_ready,
		ready_o			=> check_FF_ready
	);
--------------------------------------------------------------	


--------------------------------------------------------------	
-- Fifo between checkff and huffman 
--------------------------------------------------------------		
jpeg_checkff_fifo_p:jpeg_checkff_fifo
	port map (
		din(11 downto 8)	=> check_ff_context,
		din(7 downto 0)	=> check_FF_data,
		rd_clk 			=> Clk,
		rd_en 			=> huffman_ready,
		rst 				=> reset,
		wr_clk 			=> Clk,
		wr_en 			=> check_FF_datavalid,
		almost_empty	=> checkff_fifo_almost_empty,
		almost_full 	=> checkff_fifo_almost_full,
		dout 				=> checkff_fifo_data,
		empty 			=> checkff_fifo_empty,
		full 				=> checkff_fifo_full,
		valid 			=> checkff_fifo_datavalid
	);

--------------------------------------------------------------	
checkff_fifo_ready <= not (checkff_fifo_full);


--------------------------------------------------------------
-- Huffman decoder
--------------------------------------------------------------
jpeg_huffman_p:jpeg_huffman 
	port map (
		Clk						=> Clk,
		reset_i					=> reset,
		header_select_i		=> header_select,
		error_o					=> huffman_error,
		ht_symbols_wea_i		=> header_ht_symbols_wea,
		ht_tables_wea_i		=> header_ht_tables_wea,
		ht_select_i				=> header_ht_select,
		ht_tables_address_i			=> header_ht_tables_address,
		ht_nr_of_symbols_address_i	=> header_ht_nr_of_symbols_address,
		ht_data_i				=> header_ht_data,
		context_i				=> checkff_fifo_data(11 downto 8),
		data_i					=> checkff_fifo_data(7 downto 0),
		context_o				=> huffman_context,
		data_o					=> huffman_data,
		comp1_huff_dc_i		=> header_comp1_huff_dc,		
		comp2_huff_dc_i		=> header_comp2_huff_dc,		
		comp3_huff_dc_i		=> header_comp3_huff_dc,		
		comp1_huff_ac_i		=> header_comp1_huff_ac,		
		comp2_huff_ac_i		=> header_comp2_huff_ac,		
		comp3_huff_ac_i		=> header_comp3_huff_ac,		
		sampling_i				=> sampling,
		datavalid_i 			=> checkff_fifo_datavalid,
		datavalid_o 			=> huffman_datavalid,
		ready_i					=> dequantize_ready,
		ready_o					=> huffman_ready
    );
--------------------------------------------------------------


--------------------------------------------------------------
-- Dequantization
--------------------------------------------------------------
jpeg_dequantize_p:jpeg_dequantize
	port map (
		Clk				=> Clk,
		reset_i			=> reset,
		header_select_i=> header_select,
		qt_wea_i			=> header_qt_wea,
		qt_select_i		=> header_qt_select,
		qt_data_i		=> header_qt_data,
		sampling_i		=> sampling,
		comp1_qt_number_i => comp1_qt_number,
		comp2_qt_number_i => comp2_qt_number,
		comp3_qt_number_i => comp3_qt_number,
		context_i		=> huffman_context,
		data_i(11)		=> huffman_data(15),			-- handle negative values (TODO better)
		data_i(10 downto 0) => huffman_data(10 downto 0),
		context_o		=> dequantize_context,
		data_o			=> dequantize_data,
		datavalid_i 	=> huffman_datavalid,				-- TODO
		datavalid_o 	=> dequantize_datavalid,
		ready_i			=> dezigzag_ready,
		ready_o			=> dequantize_ready					-- TODO
    );
--------------------------------------------------------------


--------------------------------------------------------------
-- Address-maping to revert the ZigZag-Order
--------------------------------------------------------------
jpeg_dezigzag_p:jpeg_dezigzag 
	port map (
		Clk 			=> Clk,
		context_i	=> dequantize_context,
		data_i		=> dequantize_data,
		reset_i		=> reset,
		data_o 		=> dezigzag_data,
		context_o	=> dezigzag_context,
		datavalid_i => dequantize_datavalid,
		datavalid_o => dezigzag_datavalid,
		ready_i		=> idct_ready,
		ready_o		=> dezigzag_ready
    );
--------------------------------------------------------------


--------------------------------------------------------------
-- IDCT
--------------------------------------------------------------
jpeg_idct_p:jpeg_idct
	port map (
		Clk				=> Clk,
		reset_i			=> reset,
		context_i		=> dezigzag_context,
		data_i			=> dezigzag_data,
		context_o		=> idct_context,
		data_o			=> idct_data,
		datavalid_i 	=> dezigzag_datavalid,
		datavalid_o 	=> idct_datavalid,
		ready_i			=> upsampling_ready,
		ready_o			=> idct_ready
    );
--------------------------------------------------------------


--------------------------------------------------------------
-- Upsampling
--------------------------------------------------------------
jpeg_upsampling_p:jpeg_upsampling
	port map (
		Clk				=> Clk,
		reset_i			=> reset,
		context_i		=> idct_context,
		data_i			=> idct_data,
		sampling_i		=> sampling,
		context_o		=> upsampling_context,
		Y_o				=> upsampling_Y,
		Cb_o				=> upsampling_Cb,
		Cr_o				=> upsampling_Cr,
		datavalid_i 	=> idct_datavalid,
		datavalid_o 	=> upsampling_datavalid,
		ready_i			=> YCbCr2RGB_ready,
		ready_o			=> upsampling_ready
    );
--------------------------------------------------------------


--------------------------------------------------------------
-- YCbCr2RGB
--------------------------------------------------------------
jpeg_YCbCr2RGB_p:jpeg_YCbCr2RGB
	port map (
		Clk				=> Clk,
		reset_i			=> reset,
		context_i		=> upsampling_context,
		Y_i				=> upsampling_Y,
		Cb_i				=> upsampling_Cb,
		Cr_i				=> upsampling_Cr,
		context_o		=> YCbCr2RGB_context,
		R_o				=> YCbCr2RGB_R,
		G_o				=> YCbCr2RGB_G,
		B_o				=> YCbCr2RGB_B,
		datavalid_i 	=> upsampling_datavalid,
		datavalid_o 	=> YCbCr2RGB_datavalid,
		ready_i			=> vga_ready,
		ready_o			=> YCbCr2RGB_ready
    );
--------------------------------------------------------------
vga_ready	<= ready_i;


------------------------------------------------------------
-- This one first reads out header information,
-- then provides header information
------------------------------------------------------------
jpeg_header_p:jpeg_header
	port map (
		Clk			=> Clk,							-- 1 bit
		data_i		=> input_fifo_data,			-- 8 bit
		datavalid_i	=> input_fifo_datavalid,	-- 1 bit
		reset_i 		=> reset,						-- 1 bit
		eoi_i			=> check_FF_eoi,  			-- 1 ibt

		header_valid_o => header_valid,			-- 1 bit
		header_select_o=> header_select,			-- 1 bit
		header_error_o => header_error,			-- 1 bit
		
		-- initialize the huffmann tables (located in the huffmann-decoder entity)
		ht_symbols_wea_o 	=> header_ht_symbols_wea,
		ht_tables_wea_o 	=> header_ht_tables_wea,
		ht_select_o			=> header_ht_select,
		ht_tables_address_o 			=> header_ht_tables_address,
		ht_nr_of_symbols_address_o	=> header_ht_nr_of_symbols_address,
		ht_data_o 			=> header_ht_data,

		-- initialize the quantization tables (located in the dequantisation entity)
		qt_wea_o			=> header_qt_wea,
		qt_select_o		=> header_qt_select,
		qt_data_o		=> header_qt_data,

		-- sos-field
		comp1_huff_dc_o 	=> header_comp1_huff_dc,
		comp2_huff_dc_o 	=> header_comp2_huff_dc,
		comp3_huff_dc_o 	=> header_comp3_huff_dc,
		comp1_huff_ac_o 	=> header_comp1_huff_ac,
		comp2_huff_ac_o 	=> header_comp2_huff_ac,
		comp3_huff_ac_o 	=> header_comp3_huff_ac,
		
		--sof-field
		height_o 				=> header_height,
		width_o 					=> header_width,
		sampling_o				=> header_sampling,
		comp1_qt_number_o 	=> header_comp1_qt_number,
		comp2_qt_number_o 	=> header_comp2_qt_number,
		comp3_qt_number_o 	=> header_comp3_qt_number
	);
------------------------------------------------------------



-- **********************************************************************************************
-- * Wires
-- **********************************************************************************************
eoi_o		<= check_FF_eoi; 			-- for controlling input data (backwards in pipeline)
context_o<= YCbCr2RGB_context; 	-- context of output data

reset		<= reset_i;
error_o	<= error;
error		<= header_error or huffman_error;

red_o		<= YCbCr2RGB_R; 
green_o	<= YCbCr2RGB_G; 
blue_o	<= YCbCr2RGB_B; 

-- connect the valid context set to the outside
sampling_o	<= sampling_out;
width_o		<= width_out;
height_o		<= height_out;
process(YCbCr2RGB_context, sampling, width, height)
begin
	if YCbCr2RGB_context(1) ='0' then
		sampling_out	<= sampling(1 downto 0);
		width_out		<= width(15 downto 0);
		height_out		<= height(15 downto 0);
	else
		sampling_out	<= sampling(3 downto 2);
		width_out		<= width(31 downto 16);
		height_out		<= height(31 downto 16);
	end if;
end process;


-- connect pipeline flowcontroll to the outside
datavalid_o <= YCbCr2RGB_datavalid;
ready_o		<= ready and not error; 


-- **********************************************************************************************
-- * Processes
-- **********************************************************************************************

-- refill the input-fifo only after it has run empty -> bus is free the most time
process(input_fifo_almost_full, input_fifo_empty)
begin
	ready_D <= ready;
	if input_fifo_almost_full='1' then
		ready_D <= '0';
	elsif input_fifo_empty ='1' then
		ready_D <= '1';
	end if;
end process;

process(Clk)
begin
	if rising_edge(Clk) then
		if reset='1' or check_FF_eoi='1' then
			ready <= '0';
		else
			ready <= ready_D;
		end if;
	end if;
end process;

end IMP;
