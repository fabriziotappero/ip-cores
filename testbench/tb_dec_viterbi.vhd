--!
--! Copyright (C) 2011 - 2014 Creonic GmbH
--!
--! This file is part of the Creonic Viterbi Decoder, which is distributed
--! under the terms of the GNU General Public License version 2.
--!
--! @file
--! @brief  Generic Viterbi Decoder Testbench
--! @author Markus Fehrenz
--! @date   2011/12/05
--!

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

library dec_viterbi;
use dec_viterbi.pkg_param.all;
use dec_viterbi.pkg_param_derived.all;
use dec_viterbi.pkg_types.all;
use dec_viterbi.pkg_helper.all;
use dec_viterbi.pkg_tb_fileio.all;
use dec_viterbi.txt_util.all;


entity tb_dec_viterbi is
	generic(
		CLK_PERIOD         : time    := 10 ns;   -- Clock period within simulation.

		BLOCK_LENGTH_START : natural := 200;     -- First block length to simulate.
		BLOCK_LENGTH_END   : natural := 500;     -- Last block length to simulate.
		BLOCK_LENGTH_INCR  : integer := 20;       -- Increment from one block length to another.

		SIM_ALL_BLOCKS     : boolean := true;  -- Set to true in order to simulate all blocks within a data file.
		SIM_BLOCK_START    : natural := 0;      -- If SIM_ALL_BLOCKS = false, gives block to start simulation with.
		SIM_BLOCK_END      : natural := 10;      -- If SIM_ALL_BLOCKS = false, gives last block of simulation.

		WINDOW_LENGTH      : natural := 55;     -- Window length to use for simulation.
		ACQUISITION_LENGTH : natural := 50;     -- Acquisition length to use for simulation.

		DATA_DIRECTORY     : string  := "../testbench/WiFi_121_91/" -- Path to testbench data, relative to simulation directory.
	);
end entity tb_dec_viterbi;


architecture sim of tb_dec_viterbi is

	component dec_viterbi is
	port(
		aclk      : in std_logic;
		aresetn   : in std_logic;
	
		s_axis_input_tvalid : in std_logic;
		s_axis_input_tdata  : in std_logic_vector(31 downto 0);
		s_axis_input_tlast  : in std_logic;
		s_axis_input_tready : out std_logic;
	
		m_axis_output_tvalid : out std_logic;
		m_axis_output_tdata  : out std_logic;
		m_axis_output_tlast  : out std_logic;
		m_axis_output_tready : in std_logic;
	
		s_axis_ctrl_tvalid : in std_logic;
		s_axis_ctrl_tdata  : in std_logic_vector(31 downto 0);
		s_axis_ctrl_tlast  : in std_logic;
		s_axis_ctrl_tready : out std_logic
	);
	end component dec_viterbi;

	signal clk     : std_logic := '0';
	signal aresetn : std_logic;

	signal m_axis_input_tvalid : std_logic;
	signal m_axis_input_tlast  : std_logic;
	signal m_axis_input_tready : std_logic;
	signal m_axis_input_tdata  : std_logic_vector(31 downto 0);

	signal s_axis_output_tvalid : std_logic;
	signal s_axis_output_tlast  : std_logic;
	signal s_axis_output_tready : std_logic;
	signal s_axis_output_tdata  : std_logic;

	signal m_axis_ctrl_tvalid : std_logic;
	signal m_axis_ctrl_tlast  : std_logic;
	signal m_axis_ctrl_tready : std_logic;
	signal m_axis_ctrl_tdata  : std_logic_vector(31 downto 0);


	--
	-- Input data send signals.
	--

	type t_send_data_fsm is (READ_FILE, CONFIGURE, SEND_DATA, DEASSERT_VALID, SEND_DATA_FINISHED, SEND_FIRST_DATA);
	signal send_data_fsm : t_send_data_fsm;

	signal block_send_end   : natural;

	signal current_block             : natural;
	signal current_block_length      : natural;
	signal current_block_length_tail : natural;


	--
	-- Output comparison signals.
	--

	signal sys_bit_counter : natural;
	signal decoded_hardware : std_logic_vector(0 to max(BLOCK_LENGTH_START, BLOCK_LENGTH_END));

	signal block_receive_complete : boolean;
	signal new_block_length       : boolean;

	signal first_block_out            : natural;
	signal last_block_out             : natural;
	signal current_block_out          : natural;
	signal current_block_length_out   : natural;
	signal sys_bit_counter_out        : natural;


	-- Get filename that matches to our current configuration.
	function get_filename_part(v_block_length       : natural;
	                           v_window_length      : natural;
	                           v_acquisition_length : natural) return string is
		
	begin
		return "BL_" & str(v_block_length) & "_WL_" & str(v_window_length) & "_AL_" & str(v_acquisition_length);
	end function get_filename_part;

	shared variable v_decoded_software : t_nat_array_ptr;

	signal valid_cnt : natural :=0;
	signal ready_cnt : natural :=0;
begin

	clk <= not clk after CLK_PERIOD / 2;


	-- initial reset
	pr_reset : process is
	begin
		aresetn <= '0';
		wait for 2 * CLK_PERIOD;
		aresetn <= '1';
		wait;
	end process;


	-- Configuration and sending data to the core.
	pr_send : process(clk) is
		variable v_llr          : t_int_array_ptr;
		variable v_filepart_ptr : t_string_ptr;
		variable v_filename_ptr : t_string_ptr;
		variable v_num_lines    : natural := 0;
		variable v_num_blocks   : natural := 0;
	begin
	if rising_edge(clk) then
		if aresetn = '0' then

			--  ctrl_tlast is present but unused in the decoder
			m_axis_ctrl_tlast  <= '0';
			m_axis_ctrl_tvalid <= '0';
			m_axis_ctrl_tdata  <= (others => '0');

			m_axis_input_tlast  <= '0';
			m_axis_input_tvalid <= '0';
			m_axis_input_tdata  <= (others => '0');

			current_block_length      <= BLOCK_LENGTH_START;
			current_block_length_tail <= BLOCK_LENGTH_START + ENCODER_MEMORY_DEPTH;
			current_block    <= 0;
			block_send_end   <= 0;
			sys_bit_counter  <= 0;

			send_data_fsm <= READ_FILE;
			valid_cnt <= 0;

		else

			case send_data_fsm is


				--
				-- For each block length we have a different file as reference data.
				-- Read it when all requested blocks of a file were simulated,
				-- or when we start the simulation.
				--
				when READ_FILE =>

					-- Read the appropriate file
					v_filepart_ptr := new string'(get_filename_part(current_block_length, WINDOW_LENGTH, ACQUISITION_LENGTH));
					v_filename_ptr := new string'(DATA_DIRECTORY & "llr_" &  v_filepart_ptr.all & "_in.txt");
					v_num_lines := get_num_lines(v_filename_ptr.all);
					read_file(v_llr, v_num_lines, BW_LLR_INPUT, v_filename_ptr.all);

					-- NUMBER_PARITY_BITS lines are stored in the file per payload bit!
					v_num_blocks := v_num_lines / ((current_block_length_tail) * NUMBER_PARITY_BITS);

					-- Determine the blocks to simulate.
					if SIM_ALL_BLOCKS then
						current_block    <= 0;
						block_send_end   <= v_num_blocks - 1;
					else
						current_block    <= SIM_BLOCK_START;
						block_send_end   <= SIM_BLOCK_END;
					end if;
					send_data_fsm <= CONFIGURE;


				--
				-- Configure the Viterbi decoder for every single block it has to process.
				--
				when CONFIGURE =>

					-- Set control data.
					m_axis_ctrl_tdata(16 + BW_MAX_WINDOW_LENGTH - 1 downto 16) <=
						std_logic_vector(to_unsigned(WINDOW_LENGTH, BW_MAX_WINDOW_LENGTH));
					m_axis_ctrl_tdata(     BW_MAX_WINDOW_LENGTH - 1 downto  0) <=
						std_logic_vector(to_unsigned(ACQUISITION_LENGTH, BW_MAX_WINDOW_LENGTH));

					-- Check whether configuration succeeded
					if m_axis_ctrl_tvalid = '1' and m_axis_ctrl_tready = '1' then
						m_axis_ctrl_tvalid <= '0';
						send_data_fsm <= SEND_FIRST_DATA;

					else
						m_axis_ctrl_tvalid <= '1';
					end if;

				when SEND_FIRST_DATA =>
					for j in 0 to NUMBER_PARITY_BITS - 1 loop
						m_axis_input_tdata(j * 8 + BW_LLR_INPUT - 1 downto j * 8) <=
							 std_logic_vector(to_signed(v_llr(current_block * (current_block_length_tail * NUMBER_PARITY_BITS) + sys_bit_counter * NUMBER_PARITY_BITS + j), BW_LLR_INPUT));
					end loop;
					sys_bit_counter <= sys_bit_counter + 1;
					send_data_fsm <= SEND_DATA;
					m_axis_input_tvalid <= '1';

				--
				-- Send all data of a block. If we are done with this, we check what to do next:
				-- 1) Configure the decoder to process the next block of the same length.
				-- 2) Read a new file if all blocks of this block length were simulated.
				-- 3) Quit simulation if all blocks of all block lengths were simulated.
				--
				when SEND_DATA =>

					m_axis_input_tvalid <= '1';

					-- Data transmission => increase bit counter and update data for next cycle.
					if m_axis_input_tvalid = '1' and m_axis_input_tready = '1' then
						if valid_cnt = 5 then
							valid_cnt <= 0;
							send_data_fsm <= DEASSERT_VALID;
							m_axis_input_tvalid <= '0';
						else
							valid_cnt <= valid_cnt + 1;
						end if;
						sys_bit_counter <= sys_bit_counter + 1;
					end if;


					if m_axis_input_tvalid = '1' and m_axis_input_tready = '1' then
						if sys_bit_counter < current_block_length_tail then
							-- trim and move data to stream
							for j in 0 to NUMBER_PARITY_BITS - 1 loop
								m_axis_input_tdata(j * 8 + BW_LLR_INPUT - 1 downto j * 8) <=
									 std_logic_vector(to_signed(v_llr(current_block * (current_block_length_tail * NUMBER_PARITY_BITS) + sys_bit_counter * NUMBER_PARITY_BITS + j), BW_LLR_INPUT));
							end loop;
						end if;


						-- Next data will be last of block
						if sys_bit_counter = current_block_length_tail - 1 then
							m_axis_input_tlast <= '1';
						else
							m_axis_input_tlast <= '0';
						end if;
					end if;

					-- We have just sent the very last bit of this block.
					if m_axis_input_tvalid = '1' and m_axis_input_tready = '1' and 
					   m_axis_input_tlast  = '1' then
						sys_bit_counter <= 0;
						m_axis_input_tvalid <= '0';

						-- Did we process the last block of a block length?
						if current_block = block_send_end then

							-- Go to next block length, if we are not done.
							if current_block_length_tail = BLOCK_LENGTH_END + ENCODER_MEMORY_DEPTH then
								send_data_fsm <= SEND_DATA_FINISHED;
							else
								send_data_fsm <= READ_FILE;
								current_block_length   <= current_block_length + BLOCK_LENGTH_INCR;
								current_block_length_tail   <= current_block_length + BLOCK_LENGTH_INCR + ENCODER_MEMORY_DEPTH;
							end if;
						else
							send_data_fsm <= CONFIGURE;
							current_block <= current_block + 1;
						end if;
					end if;

			when DEASSERT_VALID =>
				send_data_fsm <= SEND_DATA;

			--
			-- We are done with all blocks, do nothing anynmore.
			--
			when SEND_DATA_FINISHED =>

			end case;
		end if;
	end if;
	end process;


	--
	-- Process receives the decoded data from the Viterbi decoder
	-- The received data is compared to a test vector
	--
	pr_receive : process(clk) is
		variable v_filepart_ptr  : t_string_ptr;
		variable v_filename_ptr  : t_string_ptr;
		variable v_num_lines     : natural := 0;
	begin
	if rising_edge(clk) then
		if aresetn = '0' then

			current_block_length_out   <= 0;
			sys_bit_counter_out        <= 0;
			s_axis_output_tready       <= '1';
			block_receive_complete     <= false;
			new_block_length           <= false;
			ready_cnt <= 0;

		else

			block_receive_complete     <= false;
			new_block_length           <= false;
			s_axis_output_tready <= '1';

			-- Data passes the output interface.
			if s_axis_output_tvalid = '1' and s_axis_output_tready = '1' then
				if ready_cnt = 8 then
					ready_cnt <= 0;
					s_axis_output_tready <= '0';
				else
					ready_cnt <= ready_cnt + 1;
				end if;

				decoded_hardware(sys_bit_counter_out) <= s_axis_output_tdata;

				sys_bit_counter_out <= sys_bit_counter_out + 1;

				-- This is the last bit of the flag.
				if s_axis_output_tlast = '1' then
					block_receive_complete   <= true;
					current_block_length_out <= sys_bit_counter_out + 1;
					sys_bit_counter_out      <= 0;

					-- Block received and block length changed => read file of correct blocks.
					if current_block_length_out /= sys_bit_counter_out + 1 then
						new_block_length <= true;
						v_filepart_ptr := new string'(get_filename_part(sys_bit_counter_out + 1, WINDOW_LENGTH, ACQUISITION_LENGTH));
						v_filename_ptr := new string'(DATA_DIRECTORY & "decoded_" & v_filepart_ptr.all & "_out.txt");
						v_num_lines := get_num_lines(v_filename_ptr.all);
						read_file(v_decoded_software, v_num_lines, BW_LLR_INPUT, v_filename_ptr.all);

						if SIM_ALL_BLOCKS then
							first_block_out <= 0;
							last_block_out  <= v_num_lines / (sys_bit_counter_out + 1) - 1;
						else
							first_block_out <= SIM_BLOCK_START;
							last_block_out  <= SIM_BLOCK_END;
						end if;

					end if;
				end if;
			end if;

		end if; -- reset
	end if;
	end process pr_receive;



	--
	-- Compare the block we just received from the decoder with the data stored within the files.
	-- Stop simulation if everything was simulated.
	--
	pr_compare : process(clk) is
		variable v_bit_error_count : natural := 0;
		variable v_line_out        : line;
		variable v_current_block   : natural;
	begin
	if rising_edge(clk) then
		if aresetn = '0' then

			current_block_out <= 0;

		else

			-- Which is our current block?
			if new_block_length then
				v_current_block := first_block_out;
			else
				v_current_block := current_block_out;
			end if;

			-- We got a whole block from the decoder, compare whether decoding was successful.
			if block_receive_complete then
				
				for i in 0 to current_block_length_out - 1 loop
					if (v_decoded_software(v_current_block * current_block_length_out + i) = 0 and decoded_hardware(i) = '1') or
					   (v_decoded_software(v_current_block * current_block_length_out + i) = 1 and decoded_hardware(i) = '0') then

						v_bit_error_count := v_bit_error_count + 1;

					   assert false report "Decoded bit " & str(i) & " in block " & str(v_current_block) & " does not match!"
							severity failure;
					end if;
				end loop;

				-- Dump message.
				write(v_line_out, string'("Block length: ")  & str(current_block_length_out));
				write(v_line_out, string'(", Block: ")       & str(v_current_block));
				write(v_line_out, string'(", errors: ")      & str(v_bit_error_count));
				writeline(output, v_line_out);

				current_block_out <= current_block_out + 1;
					
				if current_block_out = last_block_out then
					current_block_out <= 0;

					-- Stop simulation, if we are done with all blocks of all block lengths.
					if current_block_length_out = BLOCK_LENGTH_END then
						 assert false report "Simulation finished with no errors." severity failure;
					end if;
				end if;
			end if;
		end if;
	end if;
	end process pr_compare;


	inst_dec_viterbi : dec_viterbi
	port map(
		aclk => clk,
		aresetn => aresetn,

		s_axis_input_tvalid  => m_axis_input_tvalid,
		s_axis_input_tdata   => m_axis_input_tdata,
		s_axis_input_tlast   => m_axis_input_tlast,
		s_axis_input_tready  => m_axis_input_tready,

		m_axis_output_tvalid => s_axis_output_tvalid,
		m_axis_output_tdata  => s_axis_output_tdata,
		m_axis_output_tlast  => s_axis_output_tlast,
		m_axis_output_tready => s_axis_output_tready,

		s_axis_ctrl_tvalid   => m_axis_ctrl_tvalid,
		s_axis_ctrl_tdata    => m_axis_ctrl_tdata,
		s_axis_ctrl_tlast    => m_axis_ctrl_tlast,
		s_axis_ctrl_tready   => m_axis_ctrl_tready
	);

end architecture sim;
