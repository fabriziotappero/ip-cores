-- The Potato Processor - A simple processor for FPGAs
-- (c) Kristian Klomsten Skordal 2014 - 2015 <kristian.skordal@wafflemail.net>
-- Report bugs and issues on <http://opencores.org/project,potato,bugtracker>

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pp_types.all;
use work.pp_utilities.all;

--! @brief Wishbone adapter, for connecting the processor to a Wishbone bus when not using caches.
entity pp_wb_adapter is
	port(
		clk   : in std_logic;
		reset : in std_logic;

		-- Processor data memory signals:
		signal dmem_address   : in  std_logic_vector(31 downto 0);
		signal dmem_data_in   : in  std_logic_vector(31 downto 0); -- Data in to the bus
		signal dmem_data_out  : out std_logic_vector(31 downto 0); -- Data out to the bus
		signal dmem_data_size : in  std_logic_vector( 1 downto 0);
		signal dmem_read_req  : in  std_logic;
		signal dmem_read_ack  : out std_logic;
		signal dmem_write_req : in  std_logic;
		signal dmem_write_ack : out std_logic;

		-- Wishbone interface:
		wb_inputs  : in wishbone_master_inputs;
		wb_outputs : out wishbone_master_outputs
	);
end entity pp_wb_adapter;

architecture behaviour of pp_wb_adapter is

	type states is (IDLE, READ_WAIT_ACK, WRITE_WAIT_ACK);
	signal state : states;

	signal dmem_r_ack : std_logic;

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

	dmem_write_ack <= '1' when state = WRITE_WAIT_ACK and wb_inputs.ack = '1' else '0';
	dmem_read_ack <= dmem_r_ack;

	wishbone: process(clk)
	begin
		if rising_edge(clk) then
			if reset = '1' then
				state <= IDLE;
				wb_outputs.cyc <= '0';
				wb_outputs.stb <= '0';
				dmem_r_ack <= '0';
			else
				case state is
					when IDLE =>
						dmem_r_ack <= '0';

						-- Prioritize requests from the data memory:
						if dmem_write_req = '1' then
							wb_outputs.adr <= dmem_address;
							wb_outputs.dat <= std_logic_vector(shift_left(unsigned(dmem_data_in),
								get_data_shift(dmem_data_size, dmem_address)));
							wb_outputs.sel <= wb_get_data_sel(dmem_data_size, dmem_address);
							wb_outputs.cyc <= '1';
							wb_outputs.stb <= '1';
							wb_outputs.we <= '1';
							state <= WRITE_WAIT_ACK;
						elsif dmem_read_req = '1' then
							wb_outputs.adr <= dmem_address;
							wb_outputs.sel <= wb_get_data_sel(dmem_data_size, dmem_address);
							wb_outputs.cyc <= '1';
							wb_outputs.stb <= '1';
							wb_outputs.we <= '0';
							state <= READ_WAIT_ACK;
						end if;
					when READ_WAIT_ACK =>
						if wb_inputs.ack = '1' then
							dmem_data_out <= std_logic_vector(shift_right(unsigned(wb_inputs.dat),
								get_data_shift(dmem_data_size, dmem_address)));
							wb_outputs.cyc <= '0';
							wb_outputs.stb <= '0';
							dmem_r_ack <= '1';
							state <= IDLE;
						end if;
					when WRITE_WAIT_ACK =>
						if wb_inputs.ack = '1' then
							wb_outputs.cyc <= '0';
							wb_outputs.stb <= '0';
							wb_outputs.we <= '0';
							state <= IDLE;
						end if;
				end case;
			end if;
		end if;
	end process wishbone;

end architecture behaviour;
