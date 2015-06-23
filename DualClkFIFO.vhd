----------------------------------------------------------------------------------
-- Company:        
-- Engineer: 	    Aart Mulder
-- 
-- Create Date:    12:56:08 01/02/2013 
-- Design Name: 
-- Module Name:    DualClkFIFO - Behavioral 
-- Project Name: 	 CCITT4
--
-- Description:    This design describes a dual clock FIFO.
--                 The value of MEMORY_SIZE_G must be equal to 2^MEMORY_ADDRESS_WIDTH
--                 The empty_o
--
-- Revision: 
-- Revision 0.01 - File Created
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity DualClkFIFO is
	Generic (
		DATA_WIDTH_G           : integer := 51;
		MEMORY_SIZE_G          : integer := 16;
		MEMORY_ADDRESS_WIDTH_G : integer := 4
	);
	Port (
		rst_i    : in  STD_LOGIC;
		wr_clk_i : in  STD_LOGIC;
		rd_clk_i : in  STD_LOGIC;
		empty_o  : out STD_LOGIC;
		full_o   : out STD_LOGIC;
		pull_i   : in  STD_LOGIC;
		valid_o  : out STD_LOGIC;
		push_i   : in  STD_LOGIC;
		used_o   : out UNSIGNED(MEMORY_ADDRESS_WIDTH_G-1 downto 0);
		d_i      : in  STD_LOGIC_VECTOR(DATA_WIDTH_G-1 downto 0);
		d_o      : out STD_LOGIC_VECTOR(DATA_WIDTH_G-1 downto 0)
	);
end DualClkFIFO;

architecture Behavioral of DualClkFIFO is
	signal valid : std_logic := '0';
	signal used, wr_addr, rd_addr : unsigned(MEMORY_ADDRESS_WIDTH_G-1 downto 0) := (others => '0');
	signal data_out, data_out_cache : std_logic_vector(DATA_WIDTH_G-1 downto 0) := (others => '0');
begin
	DualClkRAM_ins : entity work.DualClkRAM
	GENERIC MAP (
		DATA_WIDTH_G => DATA_WIDTH_G,
		MEMORY_SIZE_G  => MEMORY_SIZE_G,
		MEMORY_ADDRESS_WIDTH_G => MEMORY_ADDRESS_WIDTH_G
	)
	PORT MAP (
		wr_clk_i => wr_clk_i,
		rd_clk_i => rd_clk_i,
		wr_en_i => '1',
		rd_en_i => '1',
		rd_i => pull_i,
		wr_i=> push_i,
		rd_addr_i => rd_addr,
		wr_addr_i => wr_addr,
		d_i => d_i,
		d_o => data_out
	);

	data_out_cache_process : process(rd_clk_i)
	begin
		if rd_clk_i'event and rd_clk_i = '1' then
			if valid = '1' then
				data_out_cache <= data_out;
			else
				data_out_cache <= data_out_cache;
			end if;
		end if;
	end process data_out_cache_process;
	
	d_o <= data_out when valid = '1' else data_out_cache;

	counter_wr_addr_ins : entity work.counter
	generic map (
		COUNTER_WIDTH_G => MEMORY_ADDRESS_WIDTH_G,
		START_VALUE_G   => 0,
		MAX_VALUE_G     => MEMORY_SIZE_G-1,
		ASYNCHRONOUS_RESET_G => true
	)
	port map (
		reset_i     => rst_i,
		clk_i       => wr_clk_i,
		en_i        => push_i,
		cnt_o       => wr_addr,
		overflow_o  => open
	);

	fifo_valid_pin_process : process(rd_clk_i)
	begin
		if rd_clk_i'event and rd_clk_i = '1' then
			if rst_i = '1' then
				valid <= '0';
			elsif pull_i = '1' then
				valid <= '1';
			else
				valid <= '0';
			end if;
		end if;
	end process fifo_valid_pin_process;
	valid_o <= valid;

	counter_rd_addr_ins : entity work.counter
	generic map (
		COUNTER_WIDTH_G => MEMORY_ADDRESS_WIDTH_G,
		START_VALUE_G   => 0,
		MAX_VALUE_G     => MEMORY_SIZE_G-1,
		ASYNCHRONOUS_RESET_G => true
	)
	port map (
		reset_i     => rst_i,
		clk_i       => rd_clk_i,
		en_i        => pull_i,
		cnt_o       => rd_addr,
		overflow_o  => open
	);
	
	empty_o <= '1' when wr_addr = rd_addr else '0';
	-- wr_addr = 1, rd_addr = 3, MEMORY_SIZE_G = 4
	--  This gives: used = 1+(4-3) = 2
	-- wr_addr = 0, rd_addr = 1, MEMORY_SIZE_G = 4
	--  This gives: used = 0+(4-1) = 3
	-- wr_addr = 2, rd_addr = 3, MEMORY_SIZE_G = 4
	--  This gives: used = 2+(4-3) = 3
	--  So: used = wr_addr + (MEMORY_SIZE_G - 1 - rd_addr)
	used <= wr_addr - rd_addr when wr_addr >= rd_addr else wr_addr + (to_unsigned(MEMORY_SIZE_G, MEMORY_ADDRESS_WIDTH_G) - rd_addr);
	used_o <= used;
	full_o <= '1' when used = to_unsigned(MEMORY_SIZE_G-1, MEMORY_ADDRESS_WIDTH_G) else '0';
end Behavioral;

