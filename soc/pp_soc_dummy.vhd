-- The Potato Processor - A simple processor for FPGAs
-- (c) Kristian Klomsten Skordal 2014 - 2015 <kristian.skordal@wafflemail.net>
-- Report bugs and issues on <https://github.com/skordal/potato/issues>

library ieee;
use ieee.std_logic_1164.all;

--! @brief Dummy module for an SoC implementation.
--! Reads returns whatever was last written into the module.
entity pp_soc_dummy is
	port(
		clk : in std_logic;
		reset : in std_logic;

		-- Wishbone signals:
		wb_dat_in  : in  std_logic_vector(31 downto 0);
		wb_dat_out : out std_logic_vector(31 downto 0);
		wb_cyc_in  : in  std_logic;
		wb_stb_in  : in  std_logic;
		wb_we_in   : in  std_logic;
		wb_ack_out : out std_logic
	);
end entity pp_soc_dummy;

architecture behaviour of pp_soc_dummy is

	signal reg : std_logic_vector(31 downto 0);
	signal ack : std_logic;

begin

	wb_ack_out <= ack and wb_cyc_in and wb_stb_in;

	wishbone: process(clk)
	begin
		if rising_edge(clk) then
			if reset = '1' then
				reg <= (others => '0');
				ack <= '0';
			else
				if wb_cyc_in = '1' and wb_stb_in = '1' and ack = '0' then
					if wb_we_in = '1' then
						reg <= wb_dat_in;
						ack <= '1';
					else
						wb_dat_out <= reg;
						ack <= '1';
					end if;
				elsif wb_stb_in = '0' then
					ack <= '0';
				end if;
			end if;
		end if;
	end process wishbone;

end architecture behaviour;
