----------------------------------------------------------------------------------
-- Company:        
-- Engineer:       Aart Mulder
-- 
-- Create Date:    15:02:11 12/13/2012 
-- Design Name:    Tiff compression and transmission
-- Module Name:    var_width_RAM - Behavioral 
-- Project Name:   CCITT4
--
-- Revision: 
-- Revision 0.01 - File Created
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity var_width_RAM is
	Generic (
		MEM_SIZE_G        : integer := 1024;
		MEM_INDEX_WIDTH_G : integer := 10;
		DATA_WIDTH_G     : integer := 8
	);
	Port ( 
		reset_i   : in  STD_LOGIC;
		clk_i     : in  STD_LOGIC;
		d1_i      : in  STD_LOGIC_VECTOR (DATA_WIDTH_G-1 downto 0);
		wr1_i   : in  STD_LOGIC;
		d2_i      : in  STD_LOGIC_VECTOR (DATA_WIDTH_G-1 downto 0);
		wr2_i   : in  STD_LOGIC;
		d3_i      : in  STD_LOGIC_VECTOR (DATA_WIDTH_G-1 downto 0);
		wr3_i   : in  STD_LOGIC;
		d4_i      : in  STD_LOGIC_VECTOR (DATA_WIDTH_G-1 downto 0);
		wr4_i   : in  STD_LOGIC;
		rd_addr_i : in  STD_LOGIC_VECTOR (MEM_INDEX_WIDTH_G-1 downto 0);
		d_o       : out STD_LOGIC_VECTOR (DATA_WIDTH_G-1 downto 0);
		used_o    : out unsigned (MEM_INDEX_WIDTH_G-1 downto 0)
	);
end var_width_RAM;

architecture Behavioral of var_width_RAM is
	signal rd1, rd2, rd3, rd4, wr1, wr2, wr3, wr4 : std_logic := '0';
	signal rd_addr1, rd_addr2, rd_addr3, rd_addr4, wr_addr1, wr_addr2, wr_addr3, wr_addr4 : std_logic_vector(MEM_INDEX_WIDTH_G-3 downto 0) := (others => '0');
	signal d1_in, d2_in, d3_in, d4_in, d1_out, d2_out, d3_out, d4_out : std_logic_vector(DATA_WIDTH_G-1 downto 0) := (others => '0');
	signal mux_sel : unsigned(1 downto 0) := (others => '0');
begin
	RAM_ins1 : entity work.MyRAM
	generic map(
		DATA_WIDTH_G => DATA_WIDTH_G,
		MEMORY_SIZE_G => MEM_SIZE_G/4,
		MEMORY_ADDRESS_WIDTH_G  => MEM_INDEX_WIDTH_G-2,
		BUFFER_OUTPUT_G => true
	)
	port map(
		clk => clk_i,
		en => '1',
		rd => rd1,
		wr => wr1,
		rd_addr => rd_addr1,
		wr_addr => wr_addr1,
		Data_in => d1_in,
		Data_out => d1_out
	);
	rd_addr1 <= rd_addr_i(MEM_INDEX_WIDTH_G-1 downto 2);
	rd1 <= (not rd_addr_i(1)) and (not rd_addr_i(0));

	RAM_ins2 : entity work.MyRAM
	generic map(
		DATA_WIDTH_G => DATA_WIDTH_G,
		MEMORY_SIZE_G => MEM_SIZE_G/4,
		MEMORY_ADDRESS_WIDTH_G  => MEM_INDEX_WIDTH_G-2,
		BUFFER_OUTPUT_G => true
	)
	port map(
		clk => clk_i,
		en => '1',
		rd => rd2,
		wr => wr2,
		rd_addr => rd_addr2,
		wr_addr => wr_addr2,
		Data_in => d2_in,
		Data_out => d2_out
	);
	rd_addr2 <= rd_addr_i(MEM_INDEX_WIDTH_G-1 downto 2);
	rd2 <= (not rd_addr_i(1)) and (rd_addr_i(0));

	RAM_ins3 : entity work.MyRAM
	generic map(
		DATA_WIDTH_G => DATA_WIDTH_G,
		MEMORY_SIZE_G => MEM_SIZE_G/4,
		MEMORY_ADDRESS_WIDTH_G  => MEM_INDEX_WIDTH_G-2,
		BUFFER_OUTPUT_G => true
	)
	port map(
		clk => clk_i,
		en => '1',
		rd => rd3,
		wr => wr3,
		rd_addr => rd_addr3,
		wr_addr => wr_addr3,
		Data_in => d3_in,
		Data_out => d3_out
	);
	rd_addr3 <= rd_addr_i(MEM_INDEX_WIDTH_G-1 downto 2);
	rd3 <= (rd_addr_i(1)) and (not rd_addr_i(0));

	RAM_ins4 : entity work.MyRAM
	generic map(
		DATA_WIDTH_G => DATA_WIDTH_G,
		MEMORY_SIZE_G => MEM_SIZE_G/4,
		MEMORY_ADDRESS_WIDTH_G  => MEM_INDEX_WIDTH_G-2,
		BUFFER_OUTPUT_G => true
	)
	port map(
		clk => clk_i,
		en => '1',
		rd => rd4,
		wr => wr4,
		rd_addr => rd_addr4,
		wr_addr => wr_addr4,
		Data_in => d4_in,
		Data_out => d4_out
	);
	rd_addr4 <= rd_addr_i(MEM_INDEX_WIDTH_G-1 downto 2);
	rd4 <= (rd_addr_i(1)) and (rd_addr_i(0));
	
	--Multiplexer that selects the RAM output data
	d_o <= d1_out when rd_addr_i(1 downto 0) = "00"
			else d2_out when rd_addr_i(1 downto 0) = "01"
			else d3_out when rd_addr_i(1 downto 0) = "10"
			else d4_out when rd_addr_i(1 downto 0) = "11";

	--The multiplexer selection counter
	mux_sel_cnt_process : process(clk_i)
	begin
		if clk_i'event and clk_i = '0' then
			-- "0000" => 0
			-- "0001" => 1
			-- "0011" => 2 
			-- "0111" => 3
			-- "1111" => 4 = 0
				
			if reset_i = '1' then
				mux_sel <= (others => '0');
			elsif    wr4_i = '0' and wr3_i = '0' and wr2_i = '0' and wr1_i = '1' then
				mux_sel <= mux_sel - to_unsigned(1,2);
			elsif wr4_i = '0' and wr3_i = '0' and wr2_i = '1' and wr1_i = '1' then
				mux_sel <= mux_sel - to_unsigned(2,2);
			elsif wr4_i = '0' and wr3_i = '1' and wr2_i = '1' and wr1_i = '1' then
				mux_sel <= mux_sel - to_unsigned(3,2);
			else
				mux_sel <= mux_sel - to_unsigned(0,2);
			end if;
		end if;
	end process mux_sel_cnt_process;
	
	--This process controls the read addresses, i.e. counting up and reseting.
	rd_addr_cnt_process : process(clk_i)
	begin
		if clk_i'event and clk_i = '1' then
			if reset_i = '1' then
				wr_addr1 <= (others => '0');
				wr_addr2 <= (others => '0');
				wr_addr3 <= (others => '0');
				wr_addr4 <= (others => '0');
			else
				if wr1 = '1' then
					wr_addr1 <= std_logic_vector(unsigned(wr_addr1) + to_unsigned(1, MEM_INDEX_WIDTH_G - 3));
				end if;
				if wr2 = '1' then
					wr_addr2 <= std_logic_vector(unsigned(wr_addr2) + to_unsigned(1, MEM_INDEX_WIDTH_G - 3));
				end if;
				if wr3 = '1' then
					wr_addr3 <= std_logic_vector(unsigned(wr_addr3) + to_unsigned(1, MEM_INDEX_WIDTH_G - 3));
				end if;
				if wr4 = '1' then
					wr_addr4 <= std_logic_vector(unsigned(wr_addr4) + to_unsigned(1, MEM_INDEX_WIDTH_G - 3));
				end if;
			end if;
		end if;
	end process rd_addr_cnt_process;
	
	--Multiplexer 1(input to RAM 1)
	mux1_process : process(clk_i)
	begin
		if clk_i'event and clk_i = '0' then
			if (mux_sel + to_unsigned(0,2)) = to_unsigned(0,2) then
				wr1 <= wr1_i;
				d1_in <= d1_i;
			elsif (mux_sel + to_unsigned(0,2)) = to_unsigned(1,2) then
				wr1 <= wr2_i;
				d1_in <= d2_i;
			elsif (mux_sel + to_unsigned(0,2)) = to_unsigned(2,2) then
				wr1 <= wr3_i;
				d1_in <= d3_i;
			elsif (mux_sel + to_unsigned(0,2)) = to_unsigned(3,2) then
				wr1 <= wr4_i;
				d1_in <= d4_i;
			end if;
		end if;
	end process mux1_process;
	
	--Multiplexer 2(input to RAM 2)
	mux2_process : process(clk_i)
	begin
		if clk_i'event and clk_i = '0' then
			if (mux_sel + to_unsigned(1,2)) = to_unsigned(0,2) then
				wr2 <= wr1_i;
				d2_in <= d1_i;
			elsif (mux_sel + to_unsigned(1,2)) = to_unsigned(1,2) then
				wr2 <= wr2_i;
				d2_in <= d2_i;
			elsif (mux_sel + to_unsigned(1,2)) = to_unsigned(2,2) then
				wr2 <= wr3_i;
				d2_in <= d3_i;
			elsif (mux_sel + to_unsigned(1,2)) = to_unsigned(3,2) then
				wr2 <= wr4_i;
				d2_in <= d4_i;
			end if;
		end if;
	end process mux2_process;
	
	--Multiplexer 3(input to RAM 3)
	mux3_process : process(clk_i)
	begin
		if clk_i'event and clk_i = '0' then
			if (mux_sel + to_unsigned(2,2)) = to_unsigned(0,2) then
				wr3 <= wr1_i;
				d3_in <= d1_i;
			elsif (mux_sel + to_unsigned(2,2)) = to_unsigned(1,2) then
				wr3 <= wr2_i;
				d3_in <= d2_i;
			elsif (mux_sel + to_unsigned(2,2)) = to_unsigned(2,2) then
				wr3 <= wr3_i;
				d3_in <= d3_i;
			elsif (mux_sel + to_unsigned(2,2)) = to_unsigned(3,2) then
				wr3 <= wr4_i;
				d3_in <= d4_i;
			end if;
		end if;
	end process mux3_process;
	
	--Multiplexer 4(input to RAM 4)
	mux4_process : process(clk_i)
	begin
		if clk_i'event and clk_i = '0' then
			if (mux_sel + to_unsigned(3,2)) = to_unsigned(0,2) then
				wr4 <= wr1_i;
				d4_in <= d1_i;
			elsif (mux_sel + to_unsigned(3,2)) = to_unsigned(1,2) then
				wr4 <= wr2_i;
				d4_in <= d2_i;
			elsif (mux_sel + to_unsigned(3,2)) = to_unsigned(2,2) then
				wr4 <= wr3_i;
				d4_in <= d3_i;
			elsif (mux_sel + to_unsigned(3,2)) = to_unsigned(3,2) then
				wr4 <= wr4_i;
				d4_in <= d4_i;
			end if;
		end if;
	end process mux4_process;
	
	used_o <= ("00" & unsigned(wr_addr1)) + ("00" & unsigned(wr_addr2)) + ("00" & unsigned(wr_addr3)) + ("00" & unsigned(wr_addr4));

end Behavioral;
