----------------------------------------------------------------------------------
-- Company:        
-- Engineer:       Aart Mulder
-- 
-- Version:        V2.0
-- Create Date:    13:27:31 08/17/2012 
-- Design Name:    Tiff compression and transmission
-- Module Name:    capture_manager - Behavioral 
-- Project Name:   Tiff compression and transmission
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity capture_manager is
	Generic (
		COLUMNS_G                       : integer := 752;
		ROWS_G                          : integer := 480;
		COL_INDEX_WIDTH_G               : integer := 10; --Width to represent the column index
		ROW_INDEX_WIDTH_G               : integer := 9; --Width to represent the row index
                                        
		MAX_CODE_LEN_G                  : integer := 28;
		MAX_CODE_LEN_WIDTH_G            : integer := 5;
		SEG_OUTPUT_WIDTH_G              : integer := 8;

		TX_MEMORY_SIZE_G                : integer := 4000;
		TX_MEMORY_ADDRESS_WIDTH_G       : integer := 12;
		TX_MEMORY_WIDTH_G               : integer := 8;
		
		--@26.6MHz
 		BAUD_DIVIDE_G                   : integer := 15; 	--115200 baud
		BAUD_RATE_G                     : integer := 231
	);
	Port
	(
		reset_i   : in  STD_LOGIC;

		fsync_i   : in  STD_LOGIC;
		rsync_i   : in  STD_LOGIC;
		pclk_i    : in  STD_LOGIC;
		pix_data_i: in  STD_LOGIC_VECTOR(7 downto 0);
		
		vga_fsync_o : out STD_LOGIC;
		vga_rsync_o : out STD_LOGIC;
		vgaRed      : out STD_LOGIC_VECTOR(7 downto 5);
		vgaGreen    : out STD_LOGIC_VECTOR(7 downto 5);
		vgaBlue     : out STD_LOGIC_VECTOR(7 downto 6);

		TX_o    : out STD_LOGIC;
		RX_i    : in STD_LOGIC;

		led0_o  : out STD_LOGIC;
		led1_o  : out STD_LOGIC;
		led2_o  : out STD_LOGIC;
		led3_o  : out STD_LOGIC;
		
		sw_i : in STD_LOGIC_VECTOR(6 downto 0);

		--Testbench connections
		CCITT4_run_len_code_o       : out STD_LOGIC_VECTOR (MAX_CODE_LEN_G-1 downto 0);
		CCITT4_run_len_code_width_o : out STD_LOGIC_VECTOR (MAX_CODE_LEN_WIDTH_G-1 downto 0);
		CCITT4_run_len_code_valid_o : out STD_LOGIC;
		CCITT4_frame_finished_o     : out STD_LOGIC
	);
end capture_manager;

architecture Behavioral of capture_manager is
	type state_type is (S_Start, S_WaitForChar, S_WaitForNewFrame, S_CaptureStoreFrame,
			S_SendSizeB1, S_SendSizeB1WaitRdy,
			S_SendSizeB2, S_SendSizeB2WaitRdy,
			S_SendStreamByte, S_SendStreamByteWaitAccepted, S_SendStreamByteWaitRdy,
			S_Unknown);
			
	constant CHAR_CAP_S            : std_logic_vector(7 downto 0) := std_logic_vector(to_unsigned(83, 8));
--	constant CHAR_S                : std_logic_vector(7 downto 0) := std_logic_vector(to_unsigned(115, 8));
	constant START_NEW_FRAME_CHAR  : std_logic_vector(7 downto 0) := CHAR_CAP_S;

	constant ZERO_PADDING_C : std_logic_vector(15 downto 0) := (others => '0');

	function boolean2sl(x : boolean)
			return std_logic is
	begin
		if x then
			return '1';
		else
			return '0';
		end if;
	end boolean2sl;

	function sl2boolean(x : std_logic)
			return boolean is
	begin
		if x = '1' then
			return TRUE;
		else
			return FALSE;
		end if;
	end sl2boolean;

	--State machine signals
	signal state, state_next : state_type := S_Start;

	--Signals to connect the CCITT4 module
	signal run_len_code_CCITT4       : STD_LOGIC_VECTOR(MAX_CODE_LEN_G - 1 downto 0)       := (others => '0');
	signal run_len_code_width_CCITT4 : STD_LOGIC_VECTOR(MAX_CODE_LEN_WIDTH_G - 1 downto 0) := (others => '0');
	signal run_len_code_valid_CCITT4 : STD_LOGIC                                           := '0';
	signal frame_finished_CCITT4     : STD_LOGIC                                           := '0';
	signal pix                       : STD_LOGIC                                           := '0';
	signal fax4_x : unsigned(COL_INDEX_WIDTH_G-1 downto 0) := (others => '0');
	signal fax4_y : unsigned(ROW_INDEX_WIDTH_G-1 downto 0) := (others => '0');

	--Signals to connect the byte segmentation module
	signal seg_d1, seg_d2, seg_d3, seg_d4 : STD_LOGIC_VECTOR(SEG_OUTPUT_WIDTH_G-1 downto 0)  := (others => '0');
	signal seg_d_rdy1, seg_d_rdy2, seg_d_rdy3, seg_d_rdy4 : STD_LOGIC                        := '0';
	signal seg_frame_finished_in       : STD_LOGIC                                           := '0';
	signal seg_frame_finished_out      : STD_LOGIC                                           := '0';
	signal seg_reset                   : STD_LOGIC                                           := '0';

	--Signals to connect the UART module
	signal tx_data, rx_data                              : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
	signal rx_available, tx_buf_empty, tx_buf_empty_prev : STD_LOGIC                    := '0';
	signal rx_trigger, tx_trigger                        : STD_LOGIC                    := '0';
	signal uart_reset                                    : STD_LOGIC                    := '0';

	-- Tx memory
	signal tx_mem_reset         : STD_LOGIC                                              := '0';
	signal tx_mem_d_out         : STD_LOGIC_VECTOR(TX_MEMORY_WIDTH_G-1 downto 0)         := (others => '0');
	signal tx_mem_read_addr     : std_logic_vector(TX_MEMORY_ADDRESS_WIDTH_G-1 downto 0) := (others => '0');
	signal tx_mem_used          : unsigned(TX_MEMORY_ADDRESS_WIDTH_G-1 downto 0)         := (others => '0');

		--Other signals
	signal fsync_prev                    : STD_LOGIC             := '0';
	signal tx_mem_overflow               : std_logic             := '0';

begin
	CCITT4_ins : entity work.CCITT4_v2
	Port Map(
		pclk_i    => pclk_i,
		fsync_i  => fsync_i,
		rsync_i  => rsync_i,
		pix_i  => pix,
		run_len_code_o  => run_len_code_CCITT4,
		run_len_code_width_o  => run_len_code_width_CCITT4,
		run_len_code_valid_o  => run_len_code_valid_CCITT4,
		frame_finished_o  => frame_finished_CCITT4
	);

	byte_segmentation_ins_v5 : entity work.byte_segmentation_v5
	Generic Map(
		INPUT_WIDTH_G =>  MAX_CODE_LEN_G,
		OUTPUT_WIDTH_G => SEG_OUTPUT_WIDTH_G,
		INDEX_WIDTH_G =>  MAX_CODE_LEN_WIDTH_G
	)
	Port Map(
		reset_i => seg_reset,
		clk_i => pclk_i,
		pclk_i => pclk_i,
		d_i => run_len_code_CCITT4,
		d_width_i => run_len_code_width_CCITT4,
		d_rdy_i => run_len_code_valid_CCITT4,
		d1_o => seg_d1,
		d_rdy1_o => seg_d_rdy1,
		d2_o => seg_d2,
		d_rdy2_o => seg_d_rdy2,
		d3_o => seg_d3,
		d_rdy3_o => seg_d_rdy3,
		d4_o => seg_d4,
		d_rdy4_o => seg_d_rdy4,
		frame_finished_i => seg_frame_finished_in,
		frame_finished_o => seg_frame_finished_out
	);
	seg_frame_finished_in <= frame_finished_CCITT4;

	var_width_RAM_ins : entity work.var_width_RAM
	generic map(
		MEM_SIZE_G => TX_MEMORY_SIZE_G,
		MEM_INDEX_WIDTH_G => TX_MEMORY_ADDRESS_WIDTH_G,
		DATA_WIDTH_G  => TX_MEMORY_WIDTH_G
	)
	port map(
		reset_i   => tx_mem_reset,
		clk_i     => pclk_i,
		wr1_i     => seg_d_rdy1,
		d1_i      => seg_d1,
		wr2_i     => seg_d_rdy2,
		d2_i      => seg_d2,
		wr3_i     => seg_d_rdy3,
		d3_i      => seg_d3,
		wr4_i     => seg_d_rdy4,
		d4_i      => seg_d4,
		rd_addr_i => tx_mem_read_addr,
		d_o       => tx_mem_d_out,
		used_o    => tx_mem_used
	);

	UART_ins : entity work.UartComponent
	Generic Map(
		BAUD_DIVIDE_G => BAUD_DIVIDE_G,
		BAUD_RATE_G => BAUD_RATE_G
	)
	Port Map( 
		TXD 	=> TX_o,
		RXD 	=> RX_i,
		CLK 	=> pclk_i,
		DBIN 	=> tx_data,
		DBOUT   => rx_data,
		RDA	    => rx_available,
		TBE	    => tx_buf_empty,
		RD		=> rx_trigger,
		WR		=> tx_trigger,
		PE		=> open,
		FE		=> open,
		OE		=> open,
		RST	    => uart_reset
	);
	
	decode_state_process : process(reset_i, pclk_i)
	begin
		if reset_i = '1' then
			state <= S_Start;
		elsif pclk_i'event and pclk_i = '1' then
			state <= state_next;
		else
			state <= state;
		end if;
	end process decode_state_process;
	
	decode_next_state : process (reset_i, pclk_i, fsync_i, tx_buf_empty)
	begin
		if pclk_i'event and pclk_i = '1' then
			fsync_prev <= fsync_i;
			uart_reset <= '0';
			rx_trigger <= '0';
			tx_trigger <= '0';
			tx_buf_empty_prev <= tx_buf_empty;

			case (state) is
				when S_Start =>
					state_next <= S_WaitForChar;
					uart_reset <= '1';

				when S_WaitForChar =>
					if rx_available = '1' and rx_data = START_NEW_FRAME_CHAR then
						state_next <= S_WaitForNewFrame;
						rx_trigger <= '1';
					elsif rx_available = '1' then
						rx_trigger <= '1';
						tx_data <= rx_data;
						tx_trigger <= '1';
						state_next <= state_next;
					else
						state_next <= state_next;
					end if;

				when S_WaitForNewFrame =>
					if fsync_prev = '0' and fsync_i = '1' then
						state_next <= S_CaptureStoreFrame;
					else
						state_next <= state_next;
					end if;

				when S_CaptureStoreFrame =>
					if seg_frame_finished_out = '1' then
						state_next <= S_SendSizeB1;
					else
						state_next <= state_next;
					end if;

				when S_SendSizeB1 =>
					state_next <= S_SendSizeB1WaitRdy;
					tx_data <= std_logic_vector(tx_mem_used(7 downto 0));
					tx_trigger <= '1';
				when S_SendSizeB1WaitRdy =>
					if tx_buf_empty_prev = '0' and tx_buf_empty = '1' then
						state_next <= S_SendSizeB2;
					else
						state_next <= state_next;
					end if;
				when S_SendSizeB2 =>
					state_next <= S_SendSizeB2WaitRdy;
					tx_data <= ZERO_PADDING_C(16-1 downto TX_MEMORY_ADDRESS_WIDTH_G) & std_logic_vector(tx_mem_used(TX_MEMORY_ADDRESS_WIDTH_G-1 downto 8));
					tx_trigger <= '1';

				when S_SendSizeB2WaitRdy =>
					if tx_buf_empty_prev = '0' and tx_buf_empty = '1' then
						state_next <= S_SendStreamByte;
					else
						state_next <= state_next;
					end if;

				when S_SendStreamByte =>
					state_next <= S_SendStreamByteWaitAccepted;
					tx_data <= tx_mem_d_out;
					tx_trigger <= '1';
				when S_SendStreamByteWaitAccepted =>
					if tx_buf_empty = '0' then
						state_next <= S_SendStreamByteWaitRdy;
					end if;

				when S_SendStreamByteWaitRdy =>
					if tx_buf_empty = '1' then
						if unsigned(tx_mem_read_addr) = tx_mem_used then
							state_next <= S_Start;
						else
							state_next <= S_SendStreamByte;
						end if;
					else
						state_next <= state_next;
					end if;

				when S_Unknown =>

				when others =>
					state_next <= S_Unknown;
			end case;
		end if;
	end process decode_next_state;
	
	-- Detection of memory overflow and notification to the user.
	mem_overflow_detection_process : process(pclk_i)
	begin
		if pclk_i'event and pclk_i = '1' then
			if reset_i = '1' then
				tx_mem_overflow <= '0';
			elsif tx_mem_used >= to_unsigned(TX_MEMORY_SIZE_G, 16) then
				tx_mem_overflow <= '1';
			else
				tx_mem_overflow <= tx_mem_overflow;
			end if;
		end if;
	end process mem_overflow_detection_process;

	led0_o <= boolean2sl(state = S_WaitForChar);
	led1_o <= boolean2sl(state = S_CaptureStoreFrame);
	led2_o <= boolean2sl(state = S_SendSizeB1)
				or boolean2sl(state = S_SendSizeB2)
				or boolean2sl(state = S_SendSizeB1WaitRdy)
				or boolean2sl(state = S_SendSizeB2WaitRdy)
				or boolean2sl(state = S_SendStreamByte)
				or boolean2sl(state = S_SendStreamByteWaitAccepted)
				or boolean2sl(state = S_SendStreamByteWaitRdy);
	led3_o <= tx_mem_overflow;

	pix <= pix_data_i(7) 
			when unsigned(tx_mem_used) < (to_unsigned(TX_MEMORY_SIZE_G, TX_MEMORY_ADDRESS_WIDTH_G) - to_unsigned(ROWS_G, TX_MEMORY_ADDRESS_WIDTH_G))
			else '1';

	--Data segmentation tasks
	seg_reset <= '0' when state = S_CaptureStoreFrame else '1';
	tx_mem_reset <= '1' when state = S_WaitForNewFrame else '0';
	
	--Transmission memory read pointer incrementation
	tx_mem_read_write_pos_process : process(pclk_i)
	begin
		if pclk_i'event and pclk_i = '1' then
			if state = S_WaitForNewFrame then
				tx_mem_read_addr <= (others => '0');
			elsif (tx_trigger = '1')
					and unsigned(tx_mem_read_addr) /= tx_mem_used
					and state = S_SendStreamByte then
				tx_mem_read_addr <= std_logic_vector(unsigned(tx_mem_read_addr) + to_unsigned(1, TX_MEMORY_ADDRESS_WIDTH_G));
			else
				tx_mem_read_addr <= tx_mem_read_addr;
			end if;
		end if;
	end process tx_mem_read_write_pos_process;

	-- Other tasks
	vgaRed <= pix_data_i(7 downto 5) when sw_i(0) = '0' else pix_data_i(7) & pix_data_i(7) & pix_data_i(7);
	vgaGreen <= pix_data_i(7 downto 5) when sw_i(0) = '0' else pix_data_i(7) & pix_data_i(7) & pix_data_i(7);
	vgaBlue <= pix_data_i(7 downto 6) when sw_i(0) = '0' else pix_data_i(7) & pix_data_i(7);
	vga_fsync_o <= fsync_i;
	vga_rsync_o <= rsync_i;
	
	CCITT4_run_len_code_o <= run_len_code_CCITT4;
	CCITT4_run_len_code_width_o <= run_len_code_width_CCITT4;
	CCITT4_run_len_code_valid_o <= run_len_code_valid_CCITT4;
	CCITT4_frame_finished_o <= frame_finished_CCITT4;

end Behavioral;
