-- The Potato Processor - A simple processor for FPGAs
-- (c) Kristian Klomsten Skordal 2014 - 2015 <kristian.skordal@wafflemail.net>
-- Report bugs and issues on <https://github.com/skordal/potato/issues>

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--! @brief Simple timer module for generating periodic interrupts.
--! The following registers are defined:
--! * 0: Control register. The bits are:
--!      - 0: Run - set to '1' to enable the counter
--!      - 1: Clear - set to '1' to clear the counter after a comparison match or just to reset it
--! * 1: Compare register, set this to the value where an interrupt should be generated.
--! * 2: Counter register, should only be read, but can be written if you want to.
entity pp_soc_timer is
	port(
		clk   : in std_logic;
		reset : in std_logic;

		-- Timer interrupt:
		irq : out std_logic;

		-- Wishbone interface:
		wb_adr_in  : in  std_logic_vector( 1 downto 0);
		wb_dat_in  : in  std_logic_vector(31 downto 0);
		wb_dat_out : out std_logic_vector(31 downto 0);
		wb_cyc_in  : in  std_logic;
		wb_stb_in  : in  std_logic;
		wb_we_in   : in  std_logic;
		wb_ack_out : out std_logic
	);
end entity;

architecture behaviour of pp_soc_timer is
	signal ctrl_run : std_logic;

	signal counter : std_logic_vector(31 downto 0);
	signal compare : std_logic_vector(31 downto 0);

	-- Wishbone acknowledge signal:
	signal ack : std_logic;
begin

	wb_ack_out <= ack and wb_cyc_in and wb_stb_in;
	irq <= '1' when counter = compare else '0';

	timer: process(clk)
	begin
		if rising_edge(clk) then
			if reset = '1' then
				wb_dat_out <= (others => '0');
				ack <= '0';

				ctrl_run <= '0';
				counter <= (others => '0');
				compare <= (others => '1');
			else
				if ctrl_run = '1' and counter /= compare then
					counter <= std_logic_vector(unsigned(counter) + 1);
				end if;

				if wb_cyc_in = '1' and wb_stb_in = '1' and ack = '0' then
					if wb_we_in = '1' then
						case wb_adr_in is
							when b"00" => -- Write control register
								ctrl_run <= wb_dat_in(0);
								if wb_dat_in(1) = '1' then
									counter <= (others => '0');
								end if;
							when b"01" => -- Write compare register
								compare <= wb_dat_in;
							when b"10" => -- Write count register
								counter <= wb_dat_in;
							when b"11" => -- Unused register
							when others =>
						end case;
						ack <= '1';
					else
						case wb_adr_in is
							when b"00" => -- Read control register
								wb_dat_out <= (0 => ctrl_run, others => '0');
							when b"01" => -- Read compare register
								wb_dat_out <= compare;
							when b"10" => -- Read count register
								wb_dat_out <= counter;
							when b"11" => -- Unused register
							when others =>
						end case;
						ack <= '1';
					end if;
				elsif wb_stb_in = '0' then
					ack <= '0';
				end if;
			end if;
		end if;
	end process timer;

end architecture behaviour;
