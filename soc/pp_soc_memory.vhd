-- The Potato Processor - A simple processor for FPGAs
-- (c) Kristian Klomsten Skordal 2014 - 2015 <kristian.skordal@wafflemail.net>
-- Report bugs and issues on <http://opencores.org/project,potato,bugtracker>

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;

use work.pp_utilities.all;

--! @brief Simple memory module for use in Wishbone-based systems.
entity pp_soc_memory is
	generic(
		MEMORY_SIZE : natural := 4096 --! Memory size in bytes.
	);
	port(
		clk : in std_logic;
		reset : in std_logic;

		-- Wishbone interface:
		wb_adr_in  : in  std_logic_vector(log2(MEMORY_SIZE) - 1 downto 0);
		wb_dat_in  : in  std_logic_vector(31 downto 0);
		wb_dat_out : out std_logic_vector(31 downto 0);
		wb_cyc_in  : in  std_logic;
		wb_stb_in  : in  std_logic;
		wb_sel_in  : in  std_logic_vector( 3 downto 0);
		wb_we_in   : in  std_logic;
		wb_ack_out : out std_logic
	);
end entity pp_soc_memory;

architecture behaviour of pp_soc_memory is
	type memory_array is array(0 to (MEMORY_SIZE / 4) - 1) of std_logic_vector(31 downto 0);
	signal memory : memory_array := (others => (others => '0'));

	attribute ram_style : string;
	attribute ram_style of memory : signal is "block";

	type state_type is (IDLE, ACK);
	signal state : state_type;

	signal read_ack : std_logic;

begin

	wb_ack_out <= read_ack and wb_stb_in;

	process(clk)
	begin
		if rising_edge(clk) then
			if reset = '1' then
				read_ack <= '0';
				state <= IDLE;
			else
				if wb_cyc_in = '1' then
					case state is
						when IDLE =>
							if wb_stb_in = '1' and wb_we_in = '1' then
								 for i in 0 to 3 loop
								 	if wb_sel_in(i) = '1' then
								 		memory(to_integer(unsigned(wb_adr_in(wb_adr_in'left downto 2))))(((i + 1) * 8) - 1 downto i * 8)
								 			<= wb_dat_in(((i + 1) * 8) - 1 downto i * 8);
								 	end if;
								 end loop;
								 read_ack <= '1';
								 state <= ACK;
							elsif wb_stb_in = '1' then
								wb_dat_out <= memory(to_integer(unsigned(wb_adr_in(wb_adr_in'left downto 2))));
								read_ack <= '1';
								state <= ACK;
							end if;
						when ACK =>
							if wb_stb_in = '0' then
								read_ack <= '0';
								state <= IDLE;
							end if;
					end case;
				else
					state <= IDLE;
					read_ack <= '0';
				end if;
			end if;
		end if;
	end process clk;

end architecture behaviour;
