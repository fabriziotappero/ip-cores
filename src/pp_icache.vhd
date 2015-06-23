-- The Potato Processor - A simple processor for FPGAs
-- (c) Kristian Klomsten Skordal 2014 - 2015 <kristian.skordal@wafflemail.net>
-- Report bugs and issues on <http://opencores.org/project,potato,bugtracker>

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pp_types.all;
use work.pp_utilities.all;

--! @brief Simple read-only direct-mapped instruction cache.
entity pp_icache is
	generic(
		LINE_SIZE : natural := 4;  --! Number of words per cache line
		NUM_LINES : natural := 128 --! Number of lines in the cache
	);
	port(
		clk   : in std_logic;
		reset : in std_logic;

		-- Control interface:
		cache_enable    : in std_logic;
		cache_flush     : in std_logic;
		cached_areas    : in std_logic_vector(31 downto 0);

		-- Memory interface:
		mem_address_in   : in  std_logic_vector(31 downto 0);
		mem_data_in      : in  std_logic_vector(31 downto 0);
		mem_data_out     : out std_logic_vector(31 downto 0);
		mem_data_size    : in  std_logic_vector( 1 downto 0);
		mem_read_req     : in  std_logic;
		mem_read_ack     : out std_logic;
		mem_write_req    : in  std_logic;
		mem_write_ack    : out std_logic;

		-- Wishbone interface:
		wb_inputs  : in wishbone_master_inputs;
		wb_outputs : out wishbone_master_outputs
	);
end entity pp_icache;

architecture behaviour of pp_icache is

	-- Counter types:
	subtype line_counter_type is natural range 0 to NUM_LINES;
	subtype word_counter_type is natural range 0 to LINE_SIZE; 

	-- Cache line types:
	subtype cache_line_type is std_logic_vector((LINE_SIZE * 32) - 1 downto 0);
	type cache_line_word_array is array(0 to LINE_SIZE - 1) of std_logic_vector(31 downto 0); 
	type cache_line_array is array(0 to NUM_LINES - 1) of cache_line_type;

	-- Cache tag type:
	subtype cache_tag_type is std_logic_vector(31 - log2(LINE_SIZE * 4) - log2(NUM_LINES) downto 0);
	type cache_tag_array is array(0 to NUM_LINES - 1) of cache_tag_type;

	-- Cache memories:
	signal cache_memory : cache_line_array;
	signal tag_memory   : cache_tag_array;
	signal valid        : std_logic_vector(NUM_LINES - 1 downto 0) := (others => '0');

	attribute ram_style : string;
	attribute ram_style of cache_memory: signal is "block";
	--attribute ram_style of tag_memory: signal is "block";

	-- Cache controller signals:
	type state_type is (IDLE, CACHE_READ_STALL, SINGLE_READ, SINGLE_WRITE,
		LOAD_CACHELINE_START, LOAD_CACHELINE_WAIT_ACK, LOAD_CACHELINE_FINISH);
	signal state : state_type := IDLE;

	-- Is the current input address in the cache?
	signal input_address_cached : boolean;

	-- Input address components:
	signal input_address_line : std_logic_vector(log2(NUM_LINES) - 1 downto 0);
	signal input_address_word : std_logic_vector(log2(LINE_SIZE) - 1 downto 0);
	signal input_address_tag  : std_logic_vector(31 - log2(LINE_SIZE * 4) - log2(NUM_LINES) downto 0);

	-- Cacheline matching the current input address:
	signal current_cache_line, cache_lookup : cache_line_type;
	signal current_cache_line_words : cache_line_word_array;
	signal current_tag : cache_tag_type;

	-- Base address to store a cacheline to:
	signal cl_store_address : std_logic_vector(31 downto log2(LINE_SIZE * 4));
	-- Base address to load a cacheline from:
	signal cl_load_address  : std_logic_vector(31 downto log2(LINE_SIZE * 4));
	-- Cache line to load:
	signal cl_current_line : line_counter_type;
	-- Current word being loaded/stored:
	signal cl_current_word  : word_counter_type;

	-- Buffer for holding a cache line while loading:
	signal load_buffer : cache_line_type;
	signal load_buffer_tag : cache_tag_type;

	-- Causes a cache line to be stored in the cache memory:
	signal store_cache_line : std_logic;

	-- Set when the current input address matches a cache line:
	signal cache_hit : std_logic;

	-- For regular reads:
	signal read_ack : std_logic;
	signal read_data_out : std_logic_vector(31 downto 0);

	-- For regular writes:
	signal write_ack : std_logic;

	-- Gets the amount to shift output data to the processor with for requests of size != 32 bits:
	function get_data_shift(size : in std_logic_vector(1 downto 0); address : in std_logic_vector)
		return natural is
	begin
		case size is
			when b"01" =>
				case address(1 downto 0) is
					when b"00" =>
						return 0;
					when b"01" =>
						return 8;
					when b"10" =>
						return 16;
					when b"11" =>
						return 24;
					when others =>
						return 0;
				end case;
			when b"10" =>
				if address(1) = '0' then
					return 0;
				else
					return 16;
				end if;
			when others =>
				return 0;
		end case;
	end function get_data_shift;

begin

	--assert is_pow2(LINE_SIZE) report "Cache line size must be a power of 2!" severity FAILURE;
	--assert is_pow2(NUM_LINES) report "Number of cache lines must be a power of 2!" severity FAILURE;

	-- Check if the current input address should be/is in the cache:
	input_address_cached <= cached_areas(to_integer(unsigned(mem_address_in(31 downto 27)))) = '1'; 

	mem_data_out <= current_cache_line_words(to_integer(unsigned(input_address_word))) when
			input_address_cached and cache_enable = '1' and cache_flush = '0'
		else read_data_out;
	mem_read_ack <= (cache_hit and mem_read_req)
		when state = IDLE and input_address_cached and cache_enable = '1' and cache_flush = '0'
		else read_ack;
	write_ack <= wb_inputs.ack when state = SINGLE_WRITE else '0';
	mem_write_ack <= write_ack;

	input_address_line <= mem_address_in(log2(LINE_SIZE * 4) + log2(NUM_LINES) - 1 downto log2(LINE_SIZE * 4));
	input_address_tag  <= mem_address_in(31 downto log2(LINE_SIZE * 4) + log2(NUM_LINES));

	find_word: process(clk)
	begin
		if rising_edge(clk) then
			input_address_word <= mem_address_in(log2(LINE_SIZE * 4) - 1 downto 2);
		end if;
	end process find_word;

	cacheline_lookup: process(clk)
	begin
		if rising_edge(clk) then
			if store_cache_line = '1' then
				cache_memory(cl_current_line) <= load_buffer;
			end if;

			current_cache_line <= cache_memory(to_integer(unsigned(input_address_line)));
		end if;
	end process cacheline_lookup;

	decompose_cache_line: for i in 0 to LINE_SIZE - 1 generate
		current_cache_line_words(i) <= current_cache_line(32 * i + 31 downto 32 * i);
	end generate decompose_cache_line;

	tag_lookup: process(clk)
	begin
		if rising_edge(clk) then
			if reset = '1' then
				cache_hit <= '0';
			else
				if store_cache_line = '1' then
					tag_memory(cl_current_line) <= load_buffer_tag;
				end if;
	
				current_tag <= tag_memory(to_integer(unsigned(input_address_line)));
				cache_hit <= valid(to_integer(unsigned(input_address_line))) and to_std_logic(tag_memory(to_integer(unsigned(input_address_line))) = input_address_tag);
			end if;
		end if;
	end process tag_lookup;

	controller: process(clk)
		variable current_word : std_logic_vector(31 downto 0);
	begin
		if rising_edge(clk) then
			if reset = '1' then
				state <= IDLE;
				wb_outputs.cyc <= '0';
				wb_outputs.stb <= '0';
				store_cache_line <= '0';
				read_ack <= '0';
				valid <= (others => '0');
				read_data_out <= (others => '0');
			else
				case state is
					when IDLE =>
						read_ack <= '0';
						if cache_flush = '1' then
							valid <= (others => '0');
						elsif input_address_cached and cache_enable = '1' then
							if (mem_read_req = '1' or mem_write_req = '1') and cache_hit = '0' then
								wb_outputs.adr <= mem_address_in(31 downto log2(LINE_SIZE * 4)) & (log2(LINE_SIZE * 4) - 1 downto 0 => '0');
								wb_outputs.cyc <= '1';
								wb_outputs.we <= '0';
								wb_outputs.sel <= (others => '1');
								load_buffer_tag <= input_address_tag;
								cl_load_address <= mem_address_in(31 downto log2(LINE_SIZE * 4));
								cl_store_address <= input_address_tag & input_address_line;
								cl_current_line <= to_integer(unsigned(input_address_line));
								cl_current_word <= 0;
								state <= LOAD_CACHELINE_START;
							end if;
						else
							if mem_read_req = '1' and read_ack = '0' then		-- Do an uncached read
								wb_outputs.adr <= mem_address_in;
								wb_outputs.sel <= wb_get_data_sel(mem_data_size, mem_address_in);
								wb_outputs.cyc <= '1';
								wb_outputs.stb <= '1';
								wb_outputs.we <= '0';
								state <= SINGLE_READ;
							elsif mem_write_req = '1' then	-- Do an uncached write
								wb_outputs.adr <= mem_address_in;
								wb_outputs.dat <= std_logic_vector(shift_left(unsigned(mem_data_in),
									get_data_shift(mem_data_size, mem_address_in)));
								wb_outputs.sel <= wb_get_data_sel(mem_data_size, mem_address_in);
								wb_outputs.cyc <= '1';
								wb_outputs.stb <= '1';
								wb_outputs.we <= '1';
								state <= SINGLE_WRITE;
							end if;
						end if;
					when CACHE_READ_STALL =>
						state <= IDLE;
					when SINGLE_READ =>
						if wb_inputs.ack = '1' then
							read_data_out <= std_logic_vector(shift_right(unsigned(wb_inputs.dat),
								get_data_shift(mem_data_size, mem_address_in)));
							wb_outputs.cyc <= '0';
							wb_outputs.stb <= '0';
							read_ack <= '1';
							state <= IDLE;
						end if;
					when SINGLE_WRITE =>
						if wb_inputs.ack = '1' then
							wb_outputs.cyc <= '0';
							wb_outputs.stb <= '0';
							wb_outputs.we <= '0';
							state <= IDLE;
						end if;
					when LOAD_CACHELINE_START =>
						wb_outputs.stb <= '1';
						wb_outputs.we <= '0';
						wb_outputs.adr <= cl_load_address & std_logic_vector(to_unsigned(cl_current_word, log2(LINE_SIZE))) & b"00";
						state <= LOAD_CACHELINE_WAIT_ACK;
					when LOAD_CACHELINE_WAIT_ACK =>
						if wb_inputs.ack = '1' then
							wb_outputs.stb <= '0';
							load_buffer(cl_current_word * 32 + 31 downto cl_current_word * 32) <= wb_inputs.dat;
							if natural(cl_current_word) = LINE_SIZE - 1 then
								wb_outputs.cyc <= '0';
								store_cache_line <= '1';
								state <= LOAD_CACHELINE_FINISH;
							else
								cl_current_word <= cl_current_word + 1;
								state <= LOAD_CACHELINE_START;
							end if;
						end if;
					when LOAD_CACHELINE_FINISH =>
						store_cache_line <= '0';
						valid(cl_current_line) <= '1';
						state <= CACHE_READ_STALL;
				end case;
			end if;
		end if;
	end process controller;

end architecture behaviour;
