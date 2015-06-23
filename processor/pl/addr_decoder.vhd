library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.leval2_package.all;

entity addr_decoder is
	port(
		clk			: in std_logic;
		leval_addr	: in std_logic_vector(ADDR_BITS - 1 downto 0);
		avr_irq		: out std_logic;
		mem_wait		: out std_logic;
		mem_ce		: out std_logic_vector(1 downto 0);
		read_s		: in std_logic;
		write_s		: in std_logic);
end entity;

-- PERIOD = 32.25 ns
-- MEMORY ACCESS LATENCY = 55 ns
-- WAIT 8 clock cycles

architecture rtl of addr_decoder is
	signal t_count : integer := 0;
begin
	timer : process(clk)
	begin
		if rising_edge(clk) then
			-- increment timer while communicating with memory
			if ((leval_addr < X"3FFFF00") and ((write_s or read_s) = '1')) then
				if t_count < 8 then
					t_count <= t_count + 1;
				end if;
			else -- reset timer otherwise
				t_count <= 0;
			end if;
		end if;
	end process timer;

	-- set RDY flag low after 8 cycles
	mem_wait <= '0' when t_count = 8 else '1';

	-- set CE flag for memory based on address we're reading
	mem_ce <= "10" when ((leval_addr < X"0080000") and ((write_s or read_s) = '1')) else
				"01" when ((leval_addr < X"0100000") and ((write_s or read_s) = '1')) else "11";
	--mem_ce <= '0' when ((leval_addr < X"3FFFF00") and ((write_s or read_s) = '1')) else '1';

	-- set IRQ flag for AVR
	avr_irq <= '0' when ((leval_addr >= X"3FFFF00") and ((write_s or read_s) = '1')) else '1';

end architecture;
