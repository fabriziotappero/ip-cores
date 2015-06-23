library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-----------------------------------------------------------------------------
-- UART Transmitter ---------------------------------------------------------
entity uart_tx is
	port (
		clk      : in  std_ulogic;
		reset    : in  std_ulogic;
		--
		divisor  : in  std_ulogic_vector(15 downto 0);
		din      : in  std_ulogic_vector( 7 downto 0);
		wr       : in  std_ulogic;
		busy     : out std_ulogic;
		--
		txd      : out std_ulogic );
end uart_tx;


-----------------------------------------------------------------------------
-- Implemenattion -----------------------------------------------------------
architecture rtl of uart_tx is

-- Signals
signal bitcount  : integer range 0 to 10;
signal count     : unsigned(15 downto 0);
signal shiftreg  : std_ulogic_vector(7 downto 0);

begin

proc: process(clk)
begin
	if clk'event and clk='1' then
		if reset='1' then
			count    <= (others => '0');
			bitcount <= 0;
			busy     <= '0';
			txd      <= '1';
		else
			if count/=0 then 
				count <= count - 1;
			else
				if bitcount=0 then
					if wr='1' then          -- START BIT
						shiftreg <= din;
						busy     <= '1';
						txd      <= '0';					
						bitcount <= bitcount + 1;
						count    <= unsigned(divisor);
					else
						busy <= '0';
					end if;
				elsif bitcount=9 then      -- STOP BIT
					txd         <= '1';
					bitcount    <= 0;
					count       <= unsigned(divisor);
				else                       -- DATA BIT
					shiftreg(6 downto 0) <= shiftreg(7 downto 1);
					txd         <= shiftreg(0);				
					bitcount    <= bitcount + 1;				
					count       <= unsigned(divisor);
				end if;
			end if;
		end if;
	end if;
end process;

end rtl;

