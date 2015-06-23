library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-----------------------------------------------------------------------------
-- UART Receiver ------------------------------------------------------------
entity uart_rx is
	port (
		clk      : in  std_ulogic;
		reset    : in  std_ulogic;
		--
		divisor  : in  std_ulogic_vector(15 downto 0);
		dout     : out std_ulogic_vector( 7 downto 0);
		avail    : out std_ulogic;
		error    : out std_ulogic;
		clear    : in  std_ulogic;
		--
		rxd      : in  std_ulogic );
end uart_rx;

-----------------------------------------------------------------------------
-- Implemenattion -----------------------------------------------------------
architecture rtl of uart_rx is

-- Signals
signal bitcount  : integer range 0 to 10;
signal count     : unsigned(15 downto 0);
signal shiftreg  : std_ulogic_vector(7 downto 0);
signal rxh       : std_ulogic_vector(2 downto 0);
signal rxd2      : std_ulogic;

begin

proc: process(clk, reset) is
begin
	if clk'event and clk='1' then
	if reset='1' then
		count    <= (others => '0');
		bitcount <= 0;
		error    <= '0';
		avail    <= '0';
	else
		if clear='1' then 
			error <= '0';
			avail <= '0';
		end if;
	
		if count/=0 then 
			count <= count - 1;
		else
			if bitcount=0 then     -- wait for startbit
				if rxd2='0' then     -- FOUND
					count    <= unsigned("0" & divisor(15 downto 1) );
					bitcount <= bitcount + 1;						
				end if;
			elsif bitcount=1 then  -- sample mid of startbit
				if rxd2='0' then     -- OK
					count    <= unsigned(divisor);
					bitcount <= bitcount + 1;
					shiftreg <= "00000000";
				else                -- ERROR
					error    <= '1';
					bitcount <= 0;
				end if;
			elsif bitcount=10 then -- stopbit
--				if rxd2='1' then     -- OK
					bitcount <= 0;
					dout     <= shiftreg;
					avail    <= '1';
--				else                -- ERROR
--					error    <= '1';
--				end if;
			else
				shiftreg(6 downto 0) <= shiftreg(7 downto 1);
				shiftreg(7) <= rxd2;
				count    <= unsigned(divisor);
				bitcount <= bitcount + 1;
			end if;
		end if;
	end if;
	end if;
end process;

-----------------------------------------------------------------------------
-- Sync incoming RXD (anti metastable) --------------------------------------
syncproc: process(reset, clk) is
begin
	if reset='1' then
		rxh  <= (others => '1');
		rxd2 <= '1';
	elsif clk'event and clk='1' then
		rxh <= rxh(1 downto 0) & rxd;
		if rxh="111" then
			rxd2 <= '1';
		elsif rxh="000" then
			rxd2 <= '0';	
		end if;
	end if;
end process;
					
end rtl;

