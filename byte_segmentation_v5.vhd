----------------------------------------------------------------------------------
-- Company:        
-- Engineer: 		 Aart Mulder
-- 
-- Create Date:    22:07:42 04/06/2012 
-- Design Name: 
-- Module Name:	 byte_segmentation - Behavioral 
-- Project Name: 	 CCITT4
--
-- Revision: 
-- Revision 0.01 - File Created
--		             The size of d_width_i and index has a width of 5 bits which 
--		             should be sufficient for most situations. With 5 bits a 
--		             maximum index of 31 can made, which gives a maximum d_i size
--                 of 31 - 8 = 23 bits.
--
-- Revision 0.02 - Input width increased from 13 to 45 bit and the output to 32 
--                 bit. Probably 24 bit output width is sufficient enough but
--                 for safety 32 is used for now.
--
-- Revision 0.03 - A little brainstorm session: 
--                 In worst case we get another huffman code
--                 on every second pclk_i which is 12bit long. The longest huffman
--                 code we can get is 45 bit followed by a 12bit code every other
--                 pclk_i or a 16bit code on the next pclk_i event one time at a line 
--                 end.
--                 Let say the maximum buffer size is 45 bit, then at least 2
--                 8bit buffer read operations are needed before the next pclk_i
--                 event.
--                 When using both the rising and falling edge, a clk_i frequency
--                 of at least 2x pclk_i is needed because we can not read an write
--                 to the buffer at the same time.
--
-- Revision 0.04 - byte_segmentation_v3 is made to be used in the capture_manager.
--
-- Note: byte_segmentation_v4 is omitted to match the revision numbers here with
-- the file numbers
--
-- Revision 0.05 - This is version 1 (byte_segmentation) with a changed output
--                 port. Instead of one 8bit it has four 8bit ports which will
--                 be used when needed. I.e. when more than 7 bits of data is
--                 available the first one is used, the second one when more
--                 than 15 bits are available and the third and fourth when
--                 more than 23 respectively 31 bits are available in the shift
--                 register.
--                 Furthermore, a FIFO is added to buffer the input in case more
--                 data is coming in than can be processed. Theoretically, in
--                 CCITT4 situations can appear where a 28 bit tiff-run is followed
--                 up by a 16 bit tiff-run with 2 clk_i periods in between.
--                 
--                 NOTE: the huffman and fax4 modules has have been modified to
--                 output the black or white run as soon as it is finished, i.e.
--                 separately in time which decreases the maximum code length
--                 to 28. This results in a shift register width of 28+7=35 bit.
--                 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity byte_segmentation_v5 is
	Generic (
		INPUT_WIDTH_G : integer := 28;
		INDEX_WIDTH_G : integer := 5;
		OUTPUT_WIDTH_G : integer := 8
	);
	Port (
		reset_i :   in  STD_LOGIC;
		clk_i : 		in  STD_LOGIC;
		pclk_i : 	in  STD_LOGIC;
		d_i :	 		in  STD_LOGIC_VECTOR (INPUT_WIDTH_G-1 downto 0);
		d_width_i : in  STD_LOGIC_VECTOR (INDEX_WIDTH_G-1 downto 0);
		d_rdy_i : 	in  STD_LOGIC;
		frame_finished_i :in  STD_LOGIC;
		frame_finished_o :out STD_LOGIC;
		d1_o : 		out  STD_LOGIC_VECTOR (OUTPUT_WIDTH_G-1 downto 0);
		d_rdy1_o :	out  STD_LOGIC;
		d2_o : 		out  STD_LOGIC_VECTOR (OUTPUT_WIDTH_G-1 downto 0);
		d_rdy2_o :	out  STD_LOGIC;
		d3_o : 		out  STD_LOGIC_VECTOR (OUTPUT_WIDTH_G-1 downto 0);
		d_rdy3_o :	out  STD_LOGIC;
		d4_o : 		out  STD_LOGIC_VECTOR (OUTPUT_WIDTH_G-1 downto 0);
		d_rdy4_o :	out  STD_LOGIC
	);
end byte_segmentation_v5;

architecture Behavioral of byte_segmentation_v5 is
	constant SHIFT_REG_SIZE_C : integer := (INPUT_WIDTH_G+OUTPUT_WIDTH_G)-1;
	constant SHIFT_REG_INDEX_WIDTH_C : integer := INDEX_WIDTH_G+1;

	signal shift_reg : std_logic_vector(SHIFT_REG_SIZE_C-1 downto 0) := (others => '1');
	signal index : unsigned (SHIFT_REG_INDEX_WIDTH_C-1 downto 0) := (others => '0');
	signal finish_frame : std_logic := '0';
	signal frame_finished_prev : std_logic := '0';
	signal reset_finish_frame : std_logic := '0';
	signal index2 : std_logic_vector (5 downto 0) := (others => '0');
	
	--FIFO signals
	signal FIFO_din, FIFO_dout : std_logic_vector((INPUT_WIDTH_G+INDEX_WIDTH_G)-1 downto 0) := (others => '1');
	signal FIFO_rd, FIFO_empty, FIFO_valid : std_logic := '0';
	signal in_data : std_logic_vector(INPUT_WIDTH_G-1 downto 0);
	signal in_data_width : std_logic_vector(SHIFT_REG_INDEX_WIDTH_C-1 downto 0);
	signal FIFO_used : unsigned(3 downto 0);

begin
	DualClkFIFO_ins : entity work.DualClkFIFO
	GENERIC MAP (
		DATA_WIDTH_G => INPUT_WIDTH_G+INDEX_WIDTH_G,
		MEMORY_SIZE_G  => 16,
		MEMORY_ADDRESS_WIDTH_G => 4
	)
	PORT MAP (
		rst_i => reset_i,
		wr_clk_i => pclk_i,
		rd_clk_i => clk_i,
		empty_o => FIFO_empty,
		full_o => open,
		pull_i => FIFO_rd,
		valid_o=> FIFO_valid,
		push_i => d_rdy_i,
		used_o => FIFO_used,
		d_i => FIFO_din,
		d_o => FIFO_dout
	);

	FIFO_din <= d_width_i & d_i;
	in_data_width <= '0' & FIFO_dout((INPUT_WIDTH_G+INDEX_WIDTH_G)-1 downto INPUT_WIDTH_G);
	in_data <= FIFO_dout(INPUT_WIDTH_G-1 downto 0);

	index2 <= std_logic_vector(index);
	
	--This process controls the read pin of the FIFO.
	FIFO_rd_process : process(clk_i)
	begin
		if clk_i'event and clk_i = '0' then
			if FIFO_empty = '0' then
				if (FIFO_valid = '0' and index < to_unsigned(OUTPUT_WIDTH_G, SHIFT_REG_INDEX_WIDTH_C))
						or (FIFO_rd = '1' and (index + unsigned(in_data_width)) < to_unsigned(8, SHIFT_REG_INDEX_WIDTH_C)) then
					FIFO_rd <= '1';
				else
					FIFO_rd <= '0';
				end if;
			else
				FIFO_rd <= '0';
			end if;
		end if;
	end process FIFO_rd_process;
	
	process(clk_i)
		variable ind1, ind2, ind3, ind4 : integer range 0 to SHIFT_REG_SIZE_C := 0;
	begin
		if clk_i'event and clk_i = '1' then
			reset_finish_frame <= '0';

			if FIFO_valid = '1' and index < to_unsigned(OUTPUT_WIDTH_G, SHIFT_REG_INDEX_WIDTH_C) then
				--
				--The synthesiser complains that shift_reg(0) is equal to shift_reg(1) to shift_reg(6). When
				--verifying by hand the following situations can apear:
				--  SHIFT_REG_SIZE_C = 45+8-1=52
				--  index = 0
				--  d_width_i = 45
				--  Gives: shift_reg(51 downto 7) <= input data
				--
				--  index = 7
				--  d_width_i = 45
				--  Gives: shift_reg(44 downto 0) <= input data
				--
				--So theoretically the warning is not correct.
				--  
				d_rdy1_o <= '0';
				d_rdy2_o <= '0';
				d_rdy3_o <= '0';
				d_rdy4_o <= '0';
				ind3 := to_integer(unsigned(in_data_width))-1;
				case index2 is
					when std_logic_vector(to_unsigned(0, 6)) =>
						ind2 := (SHIFT_REG_SIZE_C-0)-to_integer(unsigned(in_data_width));
						shift_reg((SHIFT_REG_SIZE_C-1)-0 downto ind2) <= in_data(ind3 downto 0);
					when std_logic_vector(to_unsigned(1, 6)) =>
						ind2 := (SHIFT_REG_SIZE_C-1)-to_integer(unsigned(in_data_width));
						shift_reg((SHIFT_REG_SIZE_C-1)-1 downto ind2) <= in_data(ind3 downto 0);
					when std_logic_vector(to_unsigned(2, 6)) =>
						ind2 := (SHIFT_REG_SIZE_C-2)-to_integer(unsigned(in_data_width));
						shift_reg((SHIFT_REG_SIZE_C-1)-2 downto ind2) <= in_data(ind3 downto 0);
					when std_logic_vector(to_unsigned(3, 6)) =>
						ind2 := (SHIFT_REG_SIZE_C-3)-to_integer(unsigned(in_data_width));
						shift_reg((SHIFT_REG_SIZE_C-1)-3 downto ind2) <= in_data(ind3 downto 0);
					when std_logic_vector(to_unsigned(4, 6)) =>
						ind2 := (SHIFT_REG_SIZE_C-4)-to_integer(unsigned(in_data_width));
						shift_reg((SHIFT_REG_SIZE_C-1)-4 downto ind2) <= in_data(ind3 downto 0);
					when std_logic_vector(to_unsigned(5, 6)) =>
						ind2 := (SHIFT_REG_SIZE_C-5)-to_integer(unsigned(in_data_width));
						shift_reg((SHIFT_REG_SIZE_C-1)-5 downto ind2) <= in_data(ind3 downto 0);
					when std_logic_vector(to_unsigned(6, 6)) =>
						ind2 := (SHIFT_REG_SIZE_C-6)-to_integer(unsigned(in_data_width));
						shift_reg((SHIFT_REG_SIZE_C-1)-6 downto ind2) <= in_data(ind3 downto 0);
					when std_logic_vector(to_unsigned(7, 6)) =>
						ind2 := (SHIFT_REG_SIZE_C-7)-to_integer(unsigned(in_data_width));
						shift_reg((SHIFT_REG_SIZE_C-1)-7 downto ind2) <= in_data(ind3 downto 0);
					when others =>
						shift_reg <= (others => '0');
				end case;
				index <= index + unsigned(in_data_width);
			elsif index >= to_unsigned(OUTPUT_WIDTH_G*1, SHIFT_REG_INDEX_WIDTH_C) and index < to_unsigned(OUTPUT_WIDTH_G*2, SHIFT_REG_INDEX_WIDTH_C) then
				--Move the highest OUTPUT_WIDTH_G bits to the output
				d1_o <= shift_reg(SHIFT_REG_SIZE_C-1 downto SHIFT_REG_SIZE_C-OUTPUT_WIDTH_G);
				d_rdy1_o <= '1';
				d_rdy2_o <= '0';
				d_rdy3_o <= '0';
				d_rdy4_o <= '0';
				--Shift the left over bits(all except OUTPUT_WIDTH_G highest) OUTPUT_WIDTH_G positions up/left
				shift_reg(SHIFT_REG_SIZE_C-1 downto OUTPUT_WIDTH_G) <= shift_reg((SHIFT_REG_SIZE_C-1)-OUTPUT_WIDTH_G downto 0);
				--Decrement the index with 8
				index <= index - to_unsigned(OUTPUT_WIDTH_G, SHIFT_REG_INDEX_WIDTH_C);
			elsif index >= to_unsigned(OUTPUT_WIDTH_G*2, SHIFT_REG_INDEX_WIDTH_C) and index < to_unsigned(OUTPUT_WIDTH_G*3, SHIFT_REG_INDEX_WIDTH_C) then
				--Move the highest OUTPUT_WIDTH_G*2 bits to the output
				d1_o <= shift_reg(SHIFT_REG_SIZE_C-1 downto SHIFT_REG_SIZE_C-OUTPUT_WIDTH_G);
				d_rdy1_o <= '1';
				d2_o <= shift_reg((SHIFT_REG_SIZE_C-1)-(OUTPUT_WIDTH_G*1) downto SHIFT_REG_SIZE_C-(OUTPUT_WIDTH_G*2));
				d_rdy2_o <= '1';
				d_rdy3_o <= '0';
				d_rdy4_o <= '0';
				--Shift the left over bits(all except OUTPUT_WIDTH_G*2 highest) OUTPUT_WIDTH_G*2 positions up/left
				shift_reg(SHIFT_REG_SIZE_C-1 downto (OUTPUT_WIDTH_G*2)) <= shift_reg((SHIFT_REG_SIZE_C-1)-(OUTPUT_WIDTH_G*2) downto 0);
				--Decrement the index with 16
				index <= index - to_unsigned(OUTPUT_WIDTH_G*2, SHIFT_REG_INDEX_WIDTH_C);
			elsif index >= to_unsigned(OUTPUT_WIDTH_G*3, SHIFT_REG_INDEX_WIDTH_C) and index < to_unsigned(OUTPUT_WIDTH_G*4, SHIFT_REG_INDEX_WIDTH_C) then
				--Move the highest OUTPUT_WIDTH_G*3 bits to the output
				d1_o <= shift_reg(SHIFT_REG_SIZE_C-1 downto SHIFT_REG_SIZE_C-OUTPUT_WIDTH_G);
				d_rdy1_o <= '1';
				d2_o <= shift_reg((SHIFT_REG_SIZE_C-1)-(OUTPUT_WIDTH_G*1) downto SHIFT_REG_SIZE_C-(OUTPUT_WIDTH_G*2));
				d_rdy2_o <= '1';
				d3_o <= shift_reg((SHIFT_REG_SIZE_C-1)-(OUTPUT_WIDTH_G*2) downto SHIFT_REG_SIZE_C-(OUTPUT_WIDTH_G*3));
				d_rdy3_o <= '1';
				d_rdy4_o <= '0';
				--Shift the left over bits(all except OUTPUT_WIDTH_G*3 highest) OUTPUT_WIDTH_G*3 positions up/left
				shift_reg(SHIFT_REG_SIZE_C-1 downto (OUTPUT_WIDTH_G*3)) <= shift_reg((SHIFT_REG_SIZE_C-1)-(OUTPUT_WIDTH_G*3) downto 0);
				--Decrement the index with 24
				index <= index - to_unsigned(OUTPUT_WIDTH_G*3, SHIFT_REG_INDEX_WIDTH_C);
			elsif index >= to_unsigned(OUTPUT_WIDTH_G*4, SHIFT_REG_INDEX_WIDTH_C) then
				--Move the highest OUTPUT_WIDTH_G*4 bits to the output
				d1_o <= shift_reg(SHIFT_REG_SIZE_C-1 downto SHIFT_REG_SIZE_C-OUTPUT_WIDTH_G);
				d_rdy1_o <= '1';
				d2_o <= shift_reg((SHIFT_REG_SIZE_C-1)-(OUTPUT_WIDTH_G*1) downto SHIFT_REG_SIZE_C-(OUTPUT_WIDTH_G*2));
				d_rdy2_o <= '1';
				d3_o <= shift_reg((SHIFT_REG_SIZE_C-1)-(OUTPUT_WIDTH_G*2) downto SHIFT_REG_SIZE_C-(OUTPUT_WIDTH_G*3));
				d_rdy3_o <= '1';
				d4_o <= shift_reg((SHIFT_REG_SIZE_C-1)-(OUTPUT_WIDTH_G*3) downto SHIFT_REG_SIZE_C-(OUTPUT_WIDTH_G*4));
				d_rdy4_o <= '1';
				--Shift the left over bits(all except OUTPUT_WIDTH_G*4 highest) OUTPUT_WIDTH_G*4 positions up/left
				shift_reg(SHIFT_REG_SIZE_C-1 downto (OUTPUT_WIDTH_G*4)) <= shift_reg((SHIFT_REG_SIZE_C-1)-(OUTPUT_WIDTH_G*4) downto 0);
				--Decrement the index with 32
				index <= index - to_unsigned(OUTPUT_WIDTH_G*4, SHIFT_REG_INDEX_WIDTH_C);
			elsif finish_frame = '1' and FIFO_used = "0000" then
				reset_finish_frame <= '1';

				d1_o <= (others => '0');
				if index > to_unsigned(0, SHIFT_REG_INDEX_WIDTH_C) then
					d1_o(OUTPUT_WIDTH_G-1 downto OUTPUT_WIDTH_G-to_integer(index)) <= shift_reg(SHIFT_REG_SIZE_C-1 downto SHIFT_REG_SIZE_C-to_integer(index));
					d_rdy1_o <= '1';
				else
					d_rdy1_o <= '0';
				end if;
				d_rdy2_o <= '0';
				d_rdy3_o <= '0';
				d_rdy4_o <= '0';

				index <= (others => '0');
				shift_reg <= (others => '0');
			else
				d_rdy1_o <= '0';
				d_rdy2_o <= '0';
				d_rdy3_o <= '0';
				d_rdy4_o <= '0';
			end if;
		end if;
	end process;
	
	process(clk_i)
	begin
		if clk_i'event and clk_i = '1' then
			frame_finished_prev <= frame_finished_i;

			if frame_finished_i = '0' and frame_finished_prev = '1' then
				finish_frame <= '1';
			elsif reset_finish_frame = '1' then
				finish_frame <= '0';
			end if;
		end if;
	end process;

	frame_finished_o <= reset_finish_frame;

end Behavioral;
