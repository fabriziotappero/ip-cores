--
--	confppa.vhd
--
--	configuration ACEX from ROM in PPA mode
--	Pinout for BB KFL board
--	
--	resources on MAX7032
--
--		32 LCs !!!
--
--	timing for ACEX:
--		nConfig low							min 2 us
--		nConfig high to nStatus high		max 4 us
--		nConfig high to nWS rising edge 	max 5 us
--		nWS pulse width						min 200 ns
--		nStatus high to first rising DCLK	min 1 us
--		DCLK clk							max 33.3 MHz
--
--	for simpler config wait tbusy+trdy2ws+tws2b befor next byte
--		1.6 us + 50 ns + 50 ns
--
--
--	todo:
--
--
--	2001-10-26	creation
--	2002-01-11	changed clock div to 32 for 7.3 MHz
--


library ieee ;
use ieee.std_logic_1164.all ;
use ieee.std_logic_unsigned.all;

entity confppa is

port (
	clk		: in std_logic;
	nreset	: in std_logic;

	a		: out std_logic_vector(16 downto 0);	-- FLASH adr
	noe_in	: in std_logic;							-- input from ACEX
	nce_in	: in std_logic;							-- input from ACEX
	noe		: out std_logic;						-- output to FLASH
	nce		: out std_logic;						-- output to FLASH
	d0in	: in std_logic;							-- D0 from FLASH
	d0out	: out std_logic;						-- reseved DATA0 to ACEX

	nconf	: out std_logic;						-- ACEX nConfig
	nstatus	: in std_logic;							-- ACEX nStatus			-- not used
	conf_done	: in std_logic;						-- ACEX conf_done

	csacx	: out std_logic;						-- ACEX CS ???
	nws		: out std_logic;						-- ACEX nWS
	nbsy	: in std_logic;							-- ACEX RDYnBSY			-- not used

	resacx	: out std_logic							-- ACEX reset line

);
end confppa ;

architecture rtl of confppa is

	signal slowclk		: std_logic;
	signal div			: std_logic_vector(6 downto 0);

	signal state 		: std_logic_vector(4 downto 0);

	signal ar			: std_logic_vector(16 downto 0);	-- adress register

-- 
--	special encoding to use as output!
--
constant start 			:std_logic_vector(4 downto 0) := "00110";
constant wait_nCfg_2us	:std_logic_vector(4 downto 0) := "10110";
constant wait_5us		:std_logic_vector(4 downto 0) := "01111";
constant wslow			:std_logic_vector(4 downto 0) := "01101";
constant wshigh			:std_logic_vector(4 downto 0) := "11111";
constant resacex		:std_logic_vector(4 downto 0) := "00111";
constant running		:std_logic_vector(4 downto 0) := "00011";

begin

--
--	divide clock to max 250 kHz (4us for nstatus)
--
process(clk, nreset)
begin

	if nreset='0' then
		div <= (others => '0');
	else
		if rising_edge(clk) then
			div <= div + 1;
		end if;
	end if;
end process;

--	slowclk <= div(6);		for 24 MHz
	slowclk <= div(4);		-- for 7.3 MHz

	nconf <= state(0);
	nws <= state(1);
	resacx <= state(2);
	csacx <= state(3);
	
	
--
--	state machine
--
process(slowclk, nreset)

begin

	if nreset='0' then

		state <= start;
		ar <= (others => '0');

	else
		if rising_edge(slowclk) then
	
			case state is
	
				when start =>
					ar <= (others => '0');
					state <= wait_nCfg_2us;
	
				when wait_nCfg_2us =>
					state <= wait_5us;
					
				when wait_5us =>
					state <= wslow;
	
				when wslow =>
					state <= wshigh;

				when wshigh =>
					ar <= ar + 1;
					if conf_done='1' then
						state <= resacex;
					else
						state <= wslow;
					end if;
	
				when resacex =>
					state <= running;

				when running =>

				when others =>
					
			end case;
		end if;
	end if;

end process;

process (state(2), ar, d0in, noe_in, nce_in)
begin

	if state(2)='0' then		-- is resacx
		a <= (others => 'Z');
		d0out <= '1';
		noe <= noe_in;
		nce <= nce_in;
	else
		a <= ar;
		d0out <= d0in;
		noe <= '0';
		nce <= '0';
	end if;

end process;


end rtl;
