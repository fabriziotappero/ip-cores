--------------------------------------------------------------------------------
-- Company:        
-- Engineer:       Aart Mulder
--
-- Create Date:    18:12:25 08/26/2012
-- Design Name:    Tiff compression and transmission
-- Module Name:    /home/aart/Documents/aaMIUN_master/2nd_15HP_Project_FPGA_CCITT_implementation/vhdl/xilinix_fax4_work_model/TB_capture_manager.vhd
-- Project Name:   Tiff compression and transmission
-- VHDL Test Bench Created by ISE for module: capture_manager
-- Note:           Run the simulation for 13600us when using a 752x480 image
--                 or at least ~54ms to simulate RS232 communication as well. 
--                 I.e. the byte segmentation and RS232 communication are
--                 bypassed for OUT_FILENAME_C to save time in some cases.
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;
use IEEE.MATH_REAL.ALL;
library STD;
use STD.TEXTIO.ALL;
 
ENTITY TB_capture_manager IS
	Generic (
		COLUMNS_G         : integer := 752;
		ROWS_G            : integer := 480;
		COL_INDEX_WIDTH_G : integer := 10;
		ROW_INDEX_WIDTH_G : integer := 9;

		MAX_CODE_LEN_G    : integer := 28;
		MAX_CODE_LEN_WIDTH_G:integer:= 5;
		SEG_OUTPUT_WIDTH_G : integer:= 8;
		
		TX_MEMORY_SIZE_G            : integer := 4000;
		TX_MEMORY_ADDRESS_WIDTH_G   : integer := 12;

		RSYNC_DEATH_LEN_G   : integer := 10;
		INTEGER_RANGE_G   : integer := 200000;

		--@Simulation
		BAUD_DIVIDE_G        : integer := 2;
		BAUD_RATE_G          : integer := 32
	);
	Port(
		cols_o   : buffer unsigned(16-1 downto 0);
		rows_o   : buffer unsigned(16-1 downto 0);
		col_o    : buffer unsigned(16-1 downto 0);
		row_o    : buffer unsigned(16-1 downto 0)
	);
END TB_capture_manager;
 
ARCHITECTURE behavior OF TB_capture_manager IS 
	type ByteT is (
		c0,c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13,c14,c15,c16,c17,c18,
		c19,c20,c21,c22,c23,c24,c25,c26,c27,c28,c29,c30,c31,c32,c33,c34,
		c35,c36,c37,c38,c39,c40,c41,c42,c43,c44,c45,c46,c47,c48,c49,c50,
		c51,c52,c53,c54,c55,c56,c57,c58,c59,c60,c61,c62,c63,c64,c65,c66,
		c67,c68,c69,c70,c71,c72,c73,c74,c75,c76,c77,c78,c79,c80,c81,c82,
		c83,c84,c85,c86,c87,c88,c89,c90,c91,c92,c93,c94,c95,c96,c97,c98,
		c99,c100,c101,c102,c103,c104,c105,c106,c107,c108,c109,c110,c111,
		c112,c113,c114,c115,c116,c117,c118,c119,c120,c121,c122,c123,c124,
		c125,c126,c127,c128,c129,c130,c131,c132,c133,c134,c135,c136,c137,
		c138,c139,c140,c141,c142,c143,c144,c145,c146,c147,c148,c149,c150,
		c151,c152,c153,c154,c155,c156,c157,c158,c159,c160,c161,c162,c163,
		c164,c165,c166,c167,c168,c169,c170,c171,c172,c173,c174,c175,c176,
		c177,c178,c179,c180,c181,c182,c183,c184,c185,c186,c187,c188,c189,
		c190,c191,c192,c193,c194,c195,c196,c197,c198,c199,c200,c201,c202,
		c203,c204,c205,c206,c207,c208,c209,c210,c211,c212,c213,c214,c215,
		c216,c217,c218,c219,c220,c221,c222,c223,c224,c225,c226,c227,c228,
		c229,c230,c231,c232,c233,c234,c235,c236,c237,c238,c239,c240,c241,
	   c242,c243,c244,c245,c246,c247,c248,c249,c250,c251,c252,c253,c254,c255);
	subtype Byte is ByteT;
	type ByteFileType is file of Byte;
	type MATRIX is array (integer range <>) of std_logic_vector(7 downto 0);

	constant PCLK_PERIOD_C : time := 37ns;	-- ~27MHz, Aptina WVGA Camera Module
	
	constant OUT_FILENAME_C  : String := "../images/tif/Segmentation752x480.tif";
	constant OUT_FILENAME_2_C: String := "../images/tif/Segmentation752x480(UART).tif";

	constant IN_FILENAME1_C : String := "../images/bmp/Segmentation752x480(real)bw_24bit.bmp";
	constant IN_FILENAME2_C : String := "../images/bmp/Segmentation752x480(real2)_24bit.bmp";
	constant IN_FILENAME3_C : String := "../images/bmp/Segmentation752x480(real4)bw_24bit.bmp";
	constant IN_FILENAME4_C : String := "../images/bmp/Segmentation752x480(real5)_24bit.bmp";
	constant IN_FILENAME_C  : String := IN_FILENAME1_C;

	constant CHAR_CAP_S           : std_logic_vector(7 downto 0) := std_logic_vector(to_unsigned(83, 8));
	constant START_NEW_FRAME_CHAR_C : std_logic_vector(7 downto 0) := CHAR_CAP_S;

	function int2bit_vec(A: integer; SIZE: integer) return BIT_VECTOR is
		variable RESULT : BIT_VECTOR(SIZE-1 DOWNTO 0);
		variable TMP  : integer;
	begin
		TMP := A;
		for i in 0 to SIZE - 1 loop
			if TMP mod 2 = 1 then 
				RESULT(i) := '1';
			else 
				RESULT(i) := '0';
			end if;
			TMP := TMP / 2;
		end loop;
		return RESULT;
	end;

	--Files
	file infile  : ByteFileType;
	file tif_file : ByteFileType;

   --Inputs
   signal reset_i : std_logic := '0';
   signal fsync_i : std_logic := '0';
   signal rsync_i : std_logic := '0';
   signal pclk_i : std_logic := '0';
   signal pix_data_i : std_logic_vector(7 downto 0) := (others => '0');
   signal RX_i : std_logic := '0';
	signal sw_i : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');

 	--Outputs
   signal vga_fsync_o : std_logic;
   signal vga_rsync_o : std_logic;
   signal vgaRed : std_logic_vector(7 downto 5);
   signal vgaGreen : std_logic_vector(7 downto 5);
   signal vgaBlue : std_logic_vector(7 downto 6);
   signal TX_o : std_logic;
   signal led0_o : std_logic;
   signal led1_o : std_logic;
   signal led2_o : std_logic;
   signal led3_o : std_logic;
	signal CCITT4_run_len_code_o : STD_LOGIC_VECTOR (MAX_CODE_LEN_G-1 downto 0);
	signal CCITT4_run_len_code_width_o : STD_LOGIC_VECTOR (MAX_CODE_LEN_WIDTH_G-1 downto 0);
	signal CCITT4_run_len_code_valid_o : STD_LOGIC;
	signal CCITT4_frame_finished_o : STD_LOGIC;

	--Other signals
	signal bitsperpixel : std_logic_vector(15 downto 0);
	signal colorplanes : std_logic_vector(15 downto 0);
	signal CCITTOutBuf : std_logic_vector (INTEGER_RANGE_G downto 0);
	signal RxByteCnt : integer range 0 to INTEGER_RANGE_G := 0;
	signal RS232_RX_DATA: MATRIX(0 to TX_MEMORY_SIZE_G);
		
	--RS232 tx module signals
	signal pc_tx_trigger, pc_rx_trigger, pc_tx_buf_empty, pc_rx_available, pc_rx_available_prev, pc_uart_reset : std_logic;
	signal pc_tx_data, pc_rx_data : std_logic_vector(7 downto 0);

	signal rxStreamSizeSignal : integer range 0 to 65535 := 0;

BEGIN
	-- Instantiate the Unit Under Test (UUT)
	uut : entity work.capture_manager
	Generic Map(
		COLUMNS_G         => COLUMNS_G,
		ROWS_G            => ROWS_G,
		COL_INDEX_WIDTH_G => COL_INDEX_WIDTH_G,
		ROW_INDEX_WIDTH_G => ROW_INDEX_WIDTH_G,

		MAX_CODE_LEN_WIDTH_G => MAX_CODE_LEN_WIDTH_G,
		MAX_CODE_LEN_G    => MAX_CODE_LEN_G,

		SEG_OUTPUT_WIDTH_G => SEG_OUTPUT_WIDTH_G,

		TX_MEMORY_SIZE_G => TX_MEMORY_SIZE_G,
		TX_MEMORY_ADDRESS_WIDTH_G => TX_MEMORY_ADDRESS_WIDTH_G,

		BAUD_DIVIDE_G => BAUD_DIVIDE_G,
		BAUD_RATE_G => BAUD_RATE_G
	)
	Port Map 
	(
		reset_i => reset_i,
		fsync_i => fsync_i,
		rsync_i => rsync_i,
		pclk_i => pclk_i,
		pix_data_i => pix_data_i,
		vga_fsync_o => vga_fsync_o,
		vga_rsync_o => vga_rsync_o,
		vgaRed => vgaRed,
		vgaGreen => vgaGreen,
		vgaBlue => vgaBlue,
		TX_o => TX_o,
		RX_i => RX_i,
		led0_o => led0_o,
		led1_o => led1_o,
		led2_o => led2_o,
		led3_o => led3_o,
		sw_i => sw_i(6 downto 0),
		CCITT4_run_len_code_o => CCITT4_run_len_code_o,
		CCITT4_run_len_code_width_o => CCITT4_run_len_code_width_o,
		CCITT4_run_len_code_valid_o => CCITT4_run_len_code_valid_o,
		CCITT4_frame_finished_o => CCITT4_frame_finished_o
	);

	UART_pc_ins : entity work.UartComponent
	Generic Map(
		BAUD_DIVIDE_G => BAUD_DIVIDE_G,
		BAUD_RATE_G => BAUD_RATE_G
	)
	Port Map( 
		TXD 	=> RX_i,
		RXD 	=> TX_o,
		CLK 	=> pclk_i,
		DBIN 	=> pc_tx_data,
		DBOUT => pc_rx_data,
		RDA	=> pc_rx_available,
		TBE	=> pc_tx_buf_empty,
		RD		=> pc_rx_trigger,
		WR		=> pc_tx_trigger,
		PE		=> open,
		FE		=> open,
		OE		=> open,
		RST	=> pc_uart_reset
	);
	pc_uart_reset <= reset_i;
	
	-- hold reset state for 3 clk periods.
	reset_i <= '1', '0' after PCLK_PERIOD_C * 3;

	-- Clock process definitions
	pclk_process : process
	begin
		pclk_i <= '0';
		wait for PCLK_PERIOD_C/2;
		pclk_i <= '1';
		wait for PCLK_PERIOD_C/2;
	end process;
	
	--Simulation of the master/PC on the other side of the RS232 connection.
	master_sim_process : process
	begin
		pc_tx_trigger <= '0';
		while reset_i = '1' loop
		
		end loop;
		
		wait for PCLK_PERIOD_C * 6;
		pc_tx_data <= START_NEW_FRAME_CHAR_C;
		pc_tx_trigger <= '1';
		wait for PCLK_PERIOD_C * 1;
		pc_tx_trigger <= '0';
		
		wait for 50ms;
		pc_tx_data <= START_NEW_FRAME_CHAR_C;
		pc_tx_trigger <= '1';
		wait for PCLK_PERIOD_C * 1;
		pc_tx_trigger <= '0';
		
		wait;
	end process master_sim_process;

	--Simulation of the input from the camera.
	img_read : process (pclk_i)
		variable pixelB : Byte;
		variable pixelG : Byte;
		variable pixelR : Byte;
		variable pixel : Byte;
		variable pixel1 : real := 0.0;
		variable pixel2 : std_logic_vector(7 downto 0);
		variable cols : unsigned(16-1 downto 0);
		variable rows : unsigned(16-1 downto 0);
		variable col : unsigned(16-1 downto 0);
		variable row : unsigned(16-1 downto 0);
		variable cnt : integer;
		variable rsync : std_logic;
		variable stop : std_logic;
		variable is_header_read : std_logic := '0';
		variable fileClosed : boolean := true;
		variable bitPos : integer range 0 to 8 := 0;
		variable dataOffset : std_logic_vector(31 downto 0);
		variable dataOffset2 : integer;
	begin  -- process img_read
		if (reset_i = '1') then

		elsif (pclk_i'event and pclk_i = '1') then
			if fileClosed = true then
				fileClosed := false;
				file_open(infile, IN_FILENAME_C, READ_MODE);
				
				is_header_read := '1';
				pix_data_i <= (others => '0');
				col		:= (others => '0');
				row		:=	(others => '0');
				for i in 0 to 13 loop -- read header infos
					read(infile, pixel);

					case i is
						when 0 =>      -- First BMP indicator byte: 0x42
						when 1 =>      -- Second BMP indicator byte: 0x4D
						when 2 => 		-- 4 bytes with the file size
						when 10 => 		-- 1st byte with the data offset
							dataOffset(7 downto 0) := to_Stdlogicvector(int2bit_vec(ByteT'pos(pixel), 8));
						when 11 => 		-- 2st byte with the data offset
							dataOffset(15 downto 8) := to_Stdlogicvector(int2bit_vec(ByteT'pos(pixel), 8));
						when 12 => 		-- 3st byte with the data offset
							dataOffset(23 downto 16) := to_Stdlogicvector(int2bit_vec(ByteT'pos(pixel), 8));
						when 13 => 		-- 4st byte with the data offset
							dataOffset(31 downto 24) := to_Stdlogicvector(int2bit_vec(ByteT'pos(pixel), 8));
							dataOffset2 := to_integer(unsigned(dataOffset));
						when others =>
							null;
					end case;
				end loop; -- i
				for i in 14 to dataOffset2-1 loop -- read header infos
					read(infile, pixel);

					case i is
						when 18 =>		-- 1st byte of cols
							cols(7 downto 0 ) := unsigned(to_Stdlogicvector(int2bit_vec(ByteT'pos(pixel), 8)));
						when 19 =>		-- 2nd byte of cols
							cols(15 downto 8) := unsigned(to_Stdlogicvector(int2bit_vec(ByteT'pos(pixel), 8)));
						when 22 =>		-- 1st byte of rows
							rows(7 downto 0 ) := unsigned(to_Stdlogicvector(int2bit_vec(ByteT'pos(pixel), 8)));
						when 23 =>		-- 2nd byte of  rows
							rows(15 downto 8) := unsigned(to_Stdlogicvector(int2bit_vec(ByteT'pos(pixel), 8)));
						when 24 =>		-- do important things
							cols_o	<= cols;
							rows_o	<= rows;
							cols		:= cols - 1;
							rows		:= rows - 1;
						when 26 => 		--2 bytes with number of color planes
							colorplanes(7 downto 0) <= to_Stdlogicvector(int2bit_vec(ByteT'pos(pixel), 8));
						when 27 =>
							colorplanes(15 downto 8) <= to_Stdlogicvector(int2bit_vec(ByteT'pos(pixel), 8));
						when 28 =>
							bitsperpixel(7 downto 0) <= to_Stdlogicvector(int2bit_vec(ByteT'pos(pixel), 8));
						when 29 => 		--2 bytes with number of bits per pixel
							bitsperpixel(15 downto 8) <= to_Stdlogicvector(int2bit_vec(ByteT'pos(pixel), 8));
						when 53 =>
							--report "\nFinished reading reading header\n";
						when others =>
							null;
					end case;
				end loop; -- i
				rsync := '0';
				cnt	:= RSYNC_DEATH_LEN_G;
				stop	:= '0';
				bitPos := 7;
				
			end if; --fileClosed = true

			rsync_i <= rsync;
			if rsync = '1' then	
				if row = 0 and col = 0 then
					fsync_i <= '1';
				else
					fsync_i <= '0';
				end if;
				
				if stop = '0' then
					if bitsperpixel = std_logic_vector(to_unsigned(1, 16)) then
						if bitPos = 7 then
							read(infile, pixelB); -- B
						end if;
						pixel2 := to_stdlogicvector(int2bit_vec(ByteT'pos(pixelB), 8));
						pixel2 := "0000000" & pixel2(bitPos downto bitPos);
						pixel1 := real(to_integer(unsigned(pixel2))*255);
						if bitPos = 0 then
							bitPos := 7;
						else
							bitPos := bitPos - 1;
						end if;
					elsif bitsperpixel = std_logic_vector(to_unsigned(8, 16)) then
						read(infile, pixelB); -- B
						pixel1	:= (ByteT'pos(pixelB)*1.0);
					elsif bitsperpixel = std_logic_vector(to_unsigned(24, 16)) then
						read(infile, pixelB); -- B
						read(infile, pixelG); -- G
						read(infile, pixelR); -- R
						pixel1	:= (ByteT'pos(pixelB)*0.11) + (ByteT'pos(pixelR)*0.3) + (ByteT'pos(pixelG)*0.59);
					elsif bitsperpixel = std_logic_vector(to_unsigned(32, 16)) then
						read(infile, pixelB); -- X do a dummy read to get rid of the first byte.
						read(infile, pixelB); -- B
						read(infile, pixelG); -- G
						read(infile, pixelR); -- R
						pixel1	:= (ByteT'pos(pixelB)*0.11) + (ByteT'pos(pixelR)*0.3) + (ByteT'pos(pixelG)*0.59);
					end if;
					pix_data_i <= std_logic_vector(to_unsigned(integer(pixel1), 8));

					col_o		<= col;
					row_o		<= row;
				end if;
				
				if col = cols then
					col	:= (others => '0');
					rsync	:= '0';
					if row = rows then
						File_Close(infile);
						fileClosed := true;
						stop := '1';
					else
						row := row + 1;
					end if;		-- row
				else
					col := col + 1;
				end if;			-- col
			else					-- rsync
				if cnt > 0 then
					cnt	:= cnt -1;
				else
					cnt	:= RSYNC_DEATH_LEN_G;
					rsync := '1';
				end if;
				pix_data_i <= (others => 'X');
			end if;	-- rsync
		end if;	  -- clk
	end process img_read;

	write_CCITT4_output_to_img_process : process(pclk_i)
		variable HEADER : MATRIX(0 to 5)         := (x"4D",x"4D",x"00",x"2A",x"00",x"00");--first 6 bytes of header fix
		variable HEADER_offset : MATRIX(0 to 1)  := (x"00",x"0F");                 --offset for number of directories 
		variable DATA: MATRIX(0 to INTEGER_RANGE_G);
		variable NO_DIR : MATRIX(0 to 1)           := (x"00",x"08");                        -- no of directories fix\
		--Types: 1=BYTE
		--       2=ASCII
		--       3=SHORT
		--       4=LONG
		--       5=RATIONAL
		--Tif IFD(header) entry                       |  ID tag   | Field type|   Number of values    |     Actual value      |
		variable HEADER_W: MATRIX(0 to 11)         := (x"01",x"00",x"00",x"03",x"00",x"00",x"00",x"01",x"00",x"05",x"00",x"00");   -- img width
		variable HEADER_L: MATRIX(0 to 11)         := (x"01",x"01",x"00",x"03",x"00",x"00",x"00",x"01",x"00",x"05",x"00",x"00");   -- img length
		variable HEADER_BITS: MATRIX(0 to 11)      := (x"01",x"02",x"00",x"03",x"00",x"00",x"00",x"01",x"00",x"01",x"00",x"00");   -- bits per sample fix
		variable HEADER_COMPRESS: MATRIX(0 to 11)  := (x"01",x"03",x"00",x"03",x"00",x"00",x"00",x"01",x"00",x"04",x"00",x"00");   -- COMPRESSION fix
		variable HEADER_PHOTO: MATRIX(0 to 11)     := (x"01",x"06",x"00",x"03",x"00",x"00",x"00",x"01",x"00",x"00",x"00",x"00");   -- photomotric interpretation fix
		variable STRIP_OFFSET: MATRIX(0 to 11)     := (x"01",x"11",x"00",x"03",x"00",x"00",x"00",x"01",x"00",x"08",x"00",x"00");   -- strip offset 
		variable ROWS_PER_STRIP: MATRIX(0 to 11)   := (x"01",x"16",x"00",x"03",x"00",x"00",x"00",x"01",x"00",x"00",x"00",x"00");   -- strip offset 
		variable STRIP_BYTE_COUNT: MATRIX(0 to 11) := (x"01",x"17",x"00",x"03",x"00",x"00",x"00",x"01",x"00",x"00",x"00",x"00");   -- strip offset 
		variable HEADER_EOB: MATRIX(0 to 3)        := (x"00",x"00",x"00",x"00");   -- END of block
		variable CCITTOutIndex : integer range 0 to INTEGER_RANGE_G+1 := 0;
		variable ind1 : integer range 0 to INTEGER_RANGE_G+2 := 0;
		variable ind2 : integer range 0 to INTEGER_RANGE_G+4 := 0;
		variable ind3 : integer range 0 to INTEGER_RANGE_G+5 := 0;
		variable rem_index2 : std_logic_vector(15 downto 0);
		variable s : line;
		variable fileClosed : boolean := true;
		variable frame_finished_prev : std_logic := '0';
	begin
		if pclk_i'event and pclk_i = '1' then
			if CCITT4_run_len_code_valid_o = '1' then
				ind1 := INTEGER_RANGE_G - CCITTOutIndex;
				ind2 := INTEGER_RANGE_G - CCITTOutIndex - to_integer(unsigned(CCITT4_run_len_code_width_o)) + 1;
				ind3 := to_integer(unsigned(CCITT4_run_len_code_width_o))-1;
				CCITTOutBuf(ind1 downto ind2) <= CCITT4_run_len_code_o(ind3 downto 0);
				CCITTOutIndex := CCITTOutIndex + to_integer(unsigned(CCITT4_run_len_code_width_o));
			elsif frame_finished_prev = '0' and CCITT4_frame_finished_o = '1' then
				----------------------------------------------------File writing--------------------------
				if fileClosed then
					fileClosed := false;
					file_open(tif_file, OUT_FILENAME_C, WRITE_MODE);
				end if;
				
				report "Frame finished. Starting to copy to DATA()";

				write(s, string'("CCITTOutIndex = "));
				write(s, CCITTOutIndex);
				writeline(output, s);

				--Fill up the last byte with zeros if left over
				ind1 := CCITTOutIndex mod 8;
				if ind1 > 0 then
					ind1 := INTEGER_RANGE_G - (CCITTOutIndex - (CCITTOutIndex mod 8) + 8);
					CCITTOutBuf(INTEGER_RANGE_G - CCITTOutIndex downto ind1) <= (others => '0');
					CCITTOutIndex := INTEGER_RANGE_G - ind1;
				end if;
				CCITTOutIndex := CCITTOutIndex / 8;

				write(s, string'("CCITTOutIndex = "));
				write(s, CCITTOutIndex);
				writeline(output, s);

				ind1 := INTEGER_RANGE_G;
				ind2 := INTEGER_RANGE_G - 7;
				for i in 0 to CCITTOutIndex loop --
					if ind2 > INTEGER_RANGE_G then
						report "Invalid ind2";
					end if;
					if ind1 > INTEGER_RANGE_G then
						report "Invalid ind1";
					end if;
					DATA(i) := CCITTOutBuf(ind1 downto ind2);
					ind1 := ind1 - 8;
					ind2 := ind2 - 8;
				end loop;
				report "Finished copying to DATA()";

				write(s, string'("CCITTOutIndex = "));
				write(s, CCITTOutIndex);
				writeline(output, s);
				
				--Align the data in the DATA() on word size
				if CCITTOutIndex mod 2 = 1 then
					DATA(CCITTOutIndex) := (others => '0');
					CCITTOutIndex := CCITTOutIndex + 1;
				end if;

				report "Finished copying to DATA()";
				HEADER_W(8):=std_logic_vector(cols_o(15 downto 8));
				HEADER_W(9):=std_logic_vector(cols_o(7 downto 0));

				HEADER_L(8):=std_logic_vector(rows_o(15 downto 8));
				HEADER_L(9):=std_logic_vector(rows_o(7 downto 0));

				rem_index2 :=STD_LOGIC_VECTOR(to_unsigned(CCITTOutIndex + 8, 16));
				HEADER_offset(1):=rem_index2(7 downto 0);
				HEADER_offset(0):=rem_index2(15 downto 8);

				ROWS_PER_STRIP(8):=std_logic_vector(rows_o(15 downto 8));
				ROWS_PER_STRIP(9):=std_logic_vector(rows_o(7 downto 0));
				
				STRIP_BYTE_COUNT(8) := STD_LOGIC_VECTOR(to_unsigned(CCITTOutIndex/256, 8));
				STRIP_BYTE_COUNT(9) := STD_LOGIC_VECTOR(to_unsigned(CCITTOutIndex, 8));

				--------------------------------------
				---- start writing
				--------------------------------------	
				for i in 0 to 5 loop -- read header infos
					write(tif_file , ByteT'val(ieee.numeric_std.To_Integer(unsigned(HEADER(i))))); --first 6 bytes of header	
				end loop;
				for i in 0 to 1 loop 
					write(tif_file , ByteT'val(ieee.numeric_std.To_Integer(unsigned(HEADER_offset(i))))); --, offset for number of directories 
				end loop;
				for i in 0 to CCITTOutIndex-1 loop 
					write(tif_file , ByteT'val(ieee.numeric_std.To_Integer(unsigned(DATA(i))))); --, data
				end loop;
				for i in 0 to 1 loop 
					write(tif_file , ByteT'val(ieee.numeric_std.To_Integer(unsigned(NO_DIR(i))))); --, number of directories
				end loop;
				for i in 0 to 11 loop 
					write(tif_file , ByteT'val(ieee.numeric_std.To_Integer(unsigned(HEADER_W(i))))); --, img width
				end loop;
				for i in 0 to 11 loop 
					write(tif_file , ByteT'val(ieee.numeric_std.To_Integer(unsigned(HEADER_L(i))))); --, img length
				end loop;
				for i in 0 to 11 loop 
					write(tif_file , ByteT'val(ieee.numeric_std.To_Integer(unsigned(HEADER_BITS(i))))); --, bits per sample
				end loop;
				for i in 0 to 11 loop 
					write(tif_file , ByteT'val(ieee.numeric_std.To_Integer(unsigned(HEADER_COMPRESS(i))))); --, COMPRESSION
				end loop;
				for i in 0 to 11 loop 
					write(tif_file , ByteT'val(ieee.numeric_std.To_Integer(unsigned(HEADER_PHOTO(i))))); --, Photometric interprattion
				end loop;
				for i in 0 to 11 loop 
					write(tif_file , ByteT'val(ieee.numeric_std.To_Integer(unsigned(STRIP_OFFSET(i))))); --, STRIP offset
				end loop;
				for i in 0 to 11 loop 
					write(tif_file , ByteT'val(ieee.numeric_std.To_Integer(unsigned(ROWS_PER_STRIP(i))))); --, Rows per strip
				end loop;
				for i in 0 to 11 loop 
					write(tif_file , ByteT'val(ieee.numeric_std.To_Integer(unsigned(STRIP_BYTE_COUNT(i))))); --, Strip byte count
				end loop;
				for i in 0 to 3 loop 
					write(tif_file , ByteT'val(ieee.numeric_std.To_Integer(unsigned(HEADER_EOB(i))))); --, EOB
				end loop;
				--------------------------------------
				---- end writing
				--------------------------------------		

				File_Close(tif_file);
				fileClosed := true;
				CCITTOutIndex := 0;
			end if;
			
			rxStreamSizeSignal <= CCITTOutIndex;
			frame_finished_prev := CCITT4_frame_finished_o;
		end if;
	end process write_CCITT4_output_to_img_process;

	rs232_rx_sim_process : process(pclk_i)
		variable HEADER : MATRIX(0 to 5)           := (x"4D",x"4D",x"00",x"2A",x"00",x"00");--first 6 bytes of header fix
		variable HEADER_offset : MATRIX(0 to 1)    := (x"00",x"0F");                 --offset for number of directories 
		variable DATA: MATRIX(0 to 10000);
		variable NO_DIR : MATRIX(0 to 1)           := (x"00",x"08");                        -- no of directories fix\
		--Types: 1=BYTE
		--       2=ASCII
		--       3=SHORT
		--       4=LONG
		--       5=RATIONAL
		--Tif IFD(header) entry                       |  ID tag   | Field type|   Number of values    |     Actual value      |
		variable HEADER_W: MATRIX(0 to 11)         := (x"01",x"00",x"00",x"03",x"00",x"00",x"00",x"01",x"00",x"05",x"00",x"00");   -- img width
		variable HEADER_L: MATRIX(0 to 11)         := (x"01",x"01",x"00",x"03",x"00",x"00",x"00",x"01",x"00",x"05",x"00",x"00");   -- img length
		variable HEADER_BITS: MATRIX(0 to 11)      := (x"01",x"02",x"00",x"03",x"00",x"00",x"00",x"01",x"00",x"01",x"00",x"00");   -- bits per sample fix
		variable HEADER_COMPRESS: MATRIX(0 to 11)  := (x"01",x"03",x"00",x"03",x"00",x"00",x"00",x"01",x"00",x"04",x"00",x"00");   -- COMPRESSION fix
		variable HEADER_PHOTO: MATRIX(0 to 11)     := (x"01",x"06",x"00",x"03",x"00",x"00",x"00",x"01",x"00",x"00",x"00",x"00");   -- photomotric interpretation fix
		variable STRIP_OFFSET: MATRIX(0 to 11)     := (x"01",x"11",x"00",x"03",x"00",x"00",x"00",x"01",x"00",x"08",x"00",x"00");   -- strip offset 
		variable ROWS_PER_STRIP: MATRIX(0 to 11)   := (x"01",x"16",x"00",x"03",x"00",x"00",x"00",x"01",x"00",x"00",x"00",x"00");   -- strip offset 
		variable STRIP_BYTE_COUNT: MATRIX(0 to 11) := (x"01",x"17",x"00",x"03",x"00",x"00",x"00",x"01",x"00",x"00",x"00",x"00");   -- strip offset 
		variable HEADER_EOB: MATRIX(0 to 3)        := (x"00",x"00",x"00",x"00");   -- END of block
		variable ind1 : integer range 0 to INTEGER_RANGE_G := 0;
		variable rem_index2 : std_logic_vector(15 downto 0);
		variable fileClosed : boolean := true;
		variable rxStreamSize : integer range 0 to 65535 := 0;
	begin
		if pclk_i'event and pclk_i = '1' then
			pc_rx_trigger <= '0';
			pc_rx_available_prev <= pc_rx_available;
			
			if ind1 = 2 then
				rxStreamSize := to_integer(unsigned(DATA(0))) + to_integer(unsigned(DATA(1))) * 256;
			end if;
			
			if pc_rx_available_prev = '0' and pc_rx_available = '1' then
				DATA(ind1) := pc_rx_data;
				ind1 := ind1 + 1;
				pc_rx_trigger <= '1';
			elsif ind1 = rxStreamSize+2 and rxStreamSize /= 0 then
				----------------------------------------------------File writing--------------------------
				if fileClosed then
					fileClosed := false;
					file_open(tif_file, OUT_FILENAME_2_C, WRITE_MODE);
				end if;
				
				--Align the data in the DATA() on word size
				if ind1 mod 2 = 1 then
					DATA(ind1) := (others => '0');
					ind1 := ind1 + 1;
				end if;
				
				HEADER_W(8):=std_logic_vector(cols_o(15 downto 8));
				HEADER_W(9):=std_logic_vector(cols_o(7 downto 0));

				HEADER_L(8):=std_logic_vector(rows_o(15 downto 8));
				HEADER_L(9):=std_logic_vector(rows_o(7 downto 0));--- "00000010";

				rem_index2 :=STD_LOGIC_VECTOR(to_unsigned(ind1 + 8 - 2, 16));
				HEADER_offset(1):=rem_index2(7 downto 0);
				HEADER_offset(0):=rem_index2(15 downto 8);

				ROWS_PER_STRIP(8):=std_logic_vector(rows_o(15 downto 8));
				ROWS_PER_STRIP(9):=std_logic_vector(rows_o(7 downto 0));
				
				STRIP_BYTE_COUNT(8) := STD_LOGIC_VECTOR(to_unsigned(ind1/256, 8));
				STRIP_BYTE_COUNT(9) := STD_LOGIC_VECTOR(to_unsigned(ind1, 8));

				--------------------------------------
				---- start writing
				--------------------------------------	
				for i in 0 to 5 loop -- read header infos
					write(tif_file , ByteT'val(ieee.numeric_std.To_Integer(unsigned(HEADER(i))))); --first 6 bytes of header	
				end loop;
				for i in 0 to 1 loop 
					write(tif_file , ByteT'val(ieee.numeric_std.To_Integer(unsigned(HEADER_offset(i))))); --, offset for number of directories 
				end loop;
				for i in 2 to ind1-1 loop 
					write(tif_file , ByteT'val(ieee.numeric_std.To_Integer(unsigned(DATA(i))))); --, data
				end loop;
				for i in 0 to 1 loop 
					write(tif_file , ByteT'val(ieee.numeric_std.To_Integer(unsigned(NO_DIR(i))))); --, number of directories
				end loop;
				for i in 0 to 11 loop 
					write(tif_file , ByteT'val(ieee.numeric_std.To_Integer(unsigned(HEADER_W(i))))); --, img width
				end loop;
				for i in 0 to 11 loop 
					write(tif_file , ByteT'val(ieee.numeric_std.To_Integer(unsigned(HEADER_L(i))))); --, img length
				end loop;
				for i in 0 to 11 loop 
					write(tif_file , ByteT'val(ieee.numeric_std.To_Integer(unsigned(HEADER_BITS(i))))); --, bits per sample
				end loop;
				for i in 0 to 11 loop 
					write(tif_file , ByteT'val(ieee.numeric_std.To_Integer(unsigned(HEADER_COMPRESS(i))))); --, COMPRESSION
				end loop;
				for i in 0 to 11 loop 
					write(tif_file , ByteT'val(ieee.numeric_std.To_Integer(unsigned(HEADER_PHOTO(i))))); --, Photometric interprattion
				end loop;
				for i in 0 to 11 loop 
					write(tif_file , ByteT'val(ieee.numeric_std.To_Integer(unsigned(STRIP_OFFSET(i))))); --, STRIP offset
				end loop;
				for i in 0 to 11 loop 
					write(tif_file , ByteT'val(ieee.numeric_std.To_Integer(unsigned(ROWS_PER_STRIP(i))))); --, Rows per strip
				end loop;
				for i in 0 to 11 loop 
					write(tif_file , ByteT'val(ieee.numeric_std.To_Integer(unsigned(STRIP_BYTE_COUNT(i))))); --, Strip byte count
				end loop;
				for i in 0 to 3 loop 
					write(tif_file , ByteT'val(ieee.numeric_std.To_Integer(unsigned(HEADER_EOB(i))))); --, EOB
				end loop;
				--------------------------------------
				---- end writing
				--------------------------------------		

				ind1 := 0;
				rxStreamSize := 0;
				File_Close(tif_file);
				fileClosed := true;
			end if;
			
			RxByteCnt <= ind1;
		end if;
	end process rs232_rx_sim_process;

end;
