-- lem1_9min_test.vhd	test harness for lem1_9min, show moving HELLO WORLD on 7-seg display
--	targets Spartan-2/3 on Digilent board
--	output signals to 7-segment display
--	step via push buttons & switch

-- inst word: upper vertical bars, bit 7..0, bit 8 is left most top horzontal bar
-- progam counter: lower vertical bars, bit 7..0, bits 10..8 are left most bottom horzontal bars
-- ACC, CRY, WE, mem read bit: middle horizontal bars
-- step start signal: left most PB
-- step clk: right most PB
-- RUN/STEP: left most switch
-- uses 50 Mhz clock & board level reset
-- the eight discrete LEDs to be allocated later
-- 7-seg: 0: decimal point, 1: top, 2: top right, 3: bot right, 4: bottom, 5: bot left, 6: top left, 7: middle
-- dig_led: 3: left, 1: left mdle, 2: right mdle, 3: right

library ieee;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_misc.all;
use IEEE.std_logic_signed.all;

entity lem1_9min_test is port(
    clk:		in std_logic;
    reset:	in std_logic;
    start:	in std_logic;
    step:		in std_logic;
    run:		in std_logic;
    btn:		in std_logic_vector(3 downto 0);	-- only #3 and #0 used, push for logic 1
    sw:		in std_logic_vector(7 downto 0);	-- only #7 used, up for 1, down for 0
    led:		out std_logic_vector(7 downto 0);	-- not currently used
    seg:		out std_logic_vector(3 downto 0);	-- active low
    dig_led:	out std_logic_vector(7 downto 0));	-- active low
end entity lem1_9min_test;

architecture arch of lem1_9min_test is
signal cntr: std_logic_vector(31 downto 0);		--  clock divider for segement select & PB de-bounce
signal we, acc, cry, mem_bit: std_logic;
signal pc_reg: std_logic_vector(10 downto 0);
signal inst: std_logic_vector(8 downto 0);
signal btn3, btn0: std_logic;
signal sw7: std_logic;
signal dig3, dig2, dig1, dig0: std_logic_vector(7 downto 0); 

component lem1_9 is port (
    clk:		in std_logic;
    reset:	in std_logic;
    start:	in std_logic;
    pc_reg:	out std_logic_vector(10 downto 0);
    mem_rd:	out std_logic_vector(8 downto 0);
    nxdata:	out std_logic;
    data_we:	out std_logic;
    acc_cpy:	out std_logic;
    cry_cpy:	out std_logic);
end component;

begin
 btn3 <= btn(3);
 btn0 <= btn(0);
 sw7  <= sw(7);

-- port maps
lem1_9min: entity lem1_9 port map(
	clk		=> clk,
	reset	=> reset,
    	start	=> start,
	pc_reg	=> pc_reg,
	mem_rd	=> inst,
	nxdata	=> mem_bit,
	data_we	=> we,
	acc_cpy	=> acc,
	cry_cpy	=> cry);

count: process(clk) begin
  if rising_edge(clk) then
    cntr(31 downto 0) <= cntr(31 downto 0) + 1;
    if inst(5 downto 0) = "000000" AND we = '1' then led(0) <= acc; end if;
    if inst(5 downto 0) = "000001" AND we = '1' then led(1) <= acc; end if;
    if inst(5 downto 0) = "000010" AND we = '1' then led(2) <= acc; end if;
    if inst(5 downto 0) = "000011" AND we = '1' then led(3) <= acc; end if;
    if inst(5 downto 0) = "000100" AND we = '1' then led(4) <= acc; end if;
    if inst(5 downto 0) = "000101" AND we = '1' then led(5) <= acc; end if;
    if inst(5 downto 0) = "000110" AND we = '1' then led(6) <= acc; end if;
    if inst(5 downto 0) = "000111" AND we = '1' then led(7) <= acc; end if;
    if inst(5 downto 0) = "110000" AND we = '1' then dig_led(0) <= acc; end if;	-- dp
    if inst(5 downto 0) = "110001" AND we = '1' then dig_led(1) <= acc; end if;
    if inst(5 downto 0) = "110010" AND we = '1' then dig_led(2) <= acc; end if;
    if inst(5 downto 0) = "110011" AND we = '1' then dig_led(3) <= acc; end if;
    if inst(5 downto 0) = "110100" AND we = '1' then dig_led(4) <= acc; end if;
    if inst(5 downto 0) = "110101" AND we = '1' then dig_led(5) <= acc; end if;
    if inst(5 downto 0) = "110110" AND we = '1' then dig_led(6) <= acc; end if;
    if inst(5 downto 0) = "110111" AND we = '1' then dig_led(7) <= acc; end if;	-- top
    if inst(5 downto 0) = "111100" AND we = '1' then seg(0) <= acc; end if; -- LSB
    if inst(5 downto 0) = "111101" AND we = '1' then seg(1) <= acc; end if;
    if inst(5 downto 0) = "111110" AND we = '1' then seg(2) <= acc; end if;
    if inst(5 downto 0) = "111111" AND we = '1' then seg(3) <= acc; end if; -- MSB
    end if;
end process;

end arch;