--
--	sigdel.vhd
--
--	sigma delta AD converter
--	
--	without external comperator:
--		input threshhold of Acex is used as comperator
--		(not very exact but only 3 external components)
--
--
--            100k
--            ___
--    sdo o--|___|--+
--                  |
--            100k  |
--            ___   |
--    uin o--|___|--o----------o sdi
--                  |
--                 ---
--                 ---  100n
--                  |
--                  |
--                 ---
--                  -
--
--		
--	Author: Martin Schoeberl	martin@jopdesign.com
--
--
--	resources on ACEX1K30-3
--
--		xx LCs, max xx MHz
--
--
--	todo:
--		use clk_freq, make it configurable
--		use a 'real' LP
--
--
--	2002-02-23	first working version
--	2002-08-08	free running 16 bit counter -> 16 bit ADC
--	2003-09-23	new IO standard
--	2005-12-28	just a simple data port
--


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sigdel is

generic (clk_freq : integer);
port (
	clk		: in std_logic;
	reset	: in std_logic;
	dout	: out std_logic_vector(15 downto 0);

	sdi		: in std_logic;
	sdo		: out std_logic
);
end sigdel ;

architecture rtl of sigdel is

	signal clksd		: unsigned(4 downto 0);

	signal clkint		: unsigned(15 downto 0);
	signal val			: unsigned(15 downto 0);
	signal sd_dout		: std_logic_vector(15 downto 0);

	signal rx_d			: std_logic;
	signal serdata		: std_logic;

	signal spike		: std_logic_vector(2 downto 0);	-- sync in, filter

begin

	sdo <= serdata;
	dout <= sd_dout;

--
--	sigma delta converter
--
process(clk, reset)

begin
	if (reset='1') then
		clksd <= "00000";
		spike <= "000";
		sd_dout <= (others => '0');
		val <= (others => '0');
		clkint <= (others => '0');
		serdata <= '0';

	elsif rising_edge(clk) then

		clksd <= clksd+1;

		if clksd="00000" then		-- with 20 MHz => 625 kHz

--
--	delay
--
			spike(0) <= sdi;
			spike(2 downto 1) <= spike(1 downto 0);
			serdata <= rx_d;		-- no inverter, using an invert. comperator
--			serdata <= not rx_d;	-- without comperator

--
--	integrate
--

			if serdata='0' then		-- 'invert' value
				val <= val+1;
			end if;

			if clkint=0 then		-- some time... (9.5 Hz)
				sd_dout <= std_logic_vector(val);
				val <= (others => '0');
			end if;

			clkint <= clkint+1;		-- free running counter

		end if;
	end if;

end process;


--
--	filter input
--
	with spike select
		rx_d <=	'0' when "000",
				'0' when "001",
				'0' when "010",
				'1' when "011",
				'0' when "100",
				'1' when "101",
				'1' when "110",
				'1' when "111",
				'X' when others;


end rtl;
