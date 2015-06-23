--
--	pld_init2.vhd
--
--	Pinout for jopcore.brd (simmilar with BB).
--	don't use cs and oe in.
--
--	nce und noe wird durchgeschleift um erstes Programmieren von
--	Flash zu erlauben.
--	
--


library ieee ;
use ieee.std_logic_1164.all ;
use ieee.std_logic_unsigned.all;

library EXEMPLAR;					-- for pin_number
use EXEMPLAR.EXEMPLAR_1164.ALL;

entity pld_init is

port (
	clk		: in std_logic;
	nreset	: in std_logic;

	a		: out std_logic_vector(17 downto 0);	-- FLASH adr
	noe_in	: in std_logic;							-- input from ACEX		-- not used
	nce_in	: in std_logic;							-- input from ACEX		-- not used
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
attribute pin_number of clk 	: signal is "37";
attribute pin_number of nreset 	: signal is "43";
attribute array_pin_number of a 	: signal is (
	"5", "18", "35", "34", "33", "31", "30", "28", "19",
	"21", "22", "25", "27", "23", "20", "15", "8", "14"
);
attribute pin_number of noe 	: signal is "44";
attribute pin_number of nce 	: signal is "12";
attribute pin_number of d0in 	: signal is "2";
attribute pin_number of d0out 	: signal is "13";
attribute pin_number of nconf 	: signal is "6";
attribute pin_number of conf_done 	: signal is "38";
attribute pin_number of csacx 	: signal is "10";
attribute pin_number of nws 	: signal is "11";
attribute pin_number of resacx 	: signal is "42";

end pld_init ;

architecture rtl of pld_init is

begin

	nconf <= '1';
	nws <= '1';
	resacx <= '0';			-- will be changed to neg. reset (some day)
	csacx <= '0';
	
	
	a <= (others => 'Z');
	d0out <= '1';
	noe <= 'Z';
	nce <= 'Z';

end rtl;
