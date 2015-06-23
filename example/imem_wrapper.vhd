-- The Potato Processor - A simple processor for FPGAs
-- (c) Kristian Klomsten Skordal 2015 <kristian.skordal@wafflemail.net>
-- Report bugs and issues on <http://opencores.org/project,potato,bugtracker>

library ieee;
use ieee.std_logic_1164.all;

entity imem_wrapper is
	port(
		clk   : in std_logic;
		reset : in std_logic;

		-- Wishbone interface:
		wb_adr_in  : in  std_logic_vector(12 downto 0);
		wb_dat_out : out std_logic_vector(31 downto 0);
		wb_cyc_in  : in  std_logic;
		wb_stb_in  : in  std_logic;
		wb_ack_out : out std_logic
	);
end entity imem_wrapper;

architecture behaviour of imem_wrapper is

	type wb_state is (IDLE, READ_ACK);
	signal state : wb_state := IDLE;

	signal address : std_logic_vector(10 downto 0);
	signal data : std_logic_vector(31 downto 0);

	signal ack : std_logic := '0';

begin

	imem: entity work.instruction_rom
		port map(
			clka => clk,
			addra => address,
			douta => wb_dat_out
		);

	wb_ack_out <= ack and wb_cyc_in and wb_stb_in;

	wishbone: process(clk)
	begin
		if rising_edge(clk) then
			if reset = '1' then
				ack <= '0';
				state <= IDLE;
			else
				case state is
					when IDLE =>
						if wb_cyc_in = '1' and wb_stb_in = '1' then
							address <= wb_adr_in(12 downto 2);
							state <= READ_ACK;
						end if;
					when READ_ACK =>
						if ack = '0' then
							ack <= '1';
						elsif wb_stb_in = '0' then
							ack <= '0';
							state <= IDLE;
						end if;
				end case;
			end if;
		end if;
	end process wishbone;

end architecture behaviour;
