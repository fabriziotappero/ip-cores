library ieee;
use ieee.std_logic_1164.all;

library work;    

package Constants is
   
   
	constant number_of_rows : natural := 6;
	constant number_of_cols : natural  := 12;
	constant scancode_width : natural  := 8;
	constant max_keys_pressed : natural  := 3;

	constant number_of_keys : natural  := number_of_rows * number_of_cols;

	-- internal clock of 50 Mhz divided by 512 gives about 100 kHz, 1 clock-cycle is about 10 us
	-- 100 ticks is about 1 ms.
	constant debounce_count : natural  := 100;
	
	subtype row is std_logic_vector(number_of_cols-1 downto 0);
	subtype col is std_logic_vector(number_of_rows-1 downto 0);

	--3 bits
	subtype col_number is natural range 0 to number_of_rows-1;
	--4 bits
	subtype row_number is natural range 0 to number_of_cols-1;
	--number of keys pressed
	subtype key_number is natural range 0 to max_keys_pressed ;

	
	subtype states is std_logic_vector(6 downto 0);
  
    --last bit is to differentiate between idle and storing_stage2
   	--output-lines : strobe, sample, analyse, store, produce, release
	constant idle : states := "0000000";
	constant strobing : states := "1000000";
	constant sampling : states := "0100000";
	constant analysing : states := "0110000";
	constant storing : states := "0001000";
	constant storing_stage2 : states := "0000001";
	constant producenormal : states := "0000100";
	constant producerelease : states := "0000110";
	

	type keymap is array (number_of_rows-1 downto 0) of row;

	subtype scancode is std_logic_vector(scancode_width-1 downto 0);
	-- we need 4 bits to encode the columns and 3 bits for the rows, gives an address of 7 bits
	-- that makes 128 possibilities of which 70 are used 
	type set1_scancodes_lut_type is array (0 to 93) of std_logic_vector(scancode_width-1 downto 0);
	constant set1_scancodes_lut : set1_scancodes_lut_type :=
	(0 => X"01", --esc
	1 => X"10", --q
	2 => X"1e", --a
	3 => X"2a", --lshi
	4 => X"33", --,<
	5 => X"1d", --ctrl

	8 => X"3b", --f1
	9 => X"11", --w
	10 => X"1f", --s
	11 => X"2c", --z
	12 => X"1c", --enter
	13 => X"38", --alt

	16 => X"3c", --f2
	17 => X"12", --e
	18 => X"20", --d
	19 => X"2d", --x
	20 => X"48", --up
	21 => X"39", --space

	24 => X"3d", --f3
	25 => X"13", --r
	26 => X"21", --f
	27 => X"2e", --c
	28 => X"50", --down

	32 => X"3e", --f4
	33 => X"14", --t
	34 => X"22", --g
	35 => X"2f", --v
	36 => X"4b", --left

	40 => X"3f", --f5
	41 => X"15", --y
	42 => X"23", --h
	43 => X"30", --b
	44 => X"4d", --right
	45 => X"39", --space

	48 => X"28", --'"
	49 => X"16", --u
	50 => X"24", --j
	51 => X"31", --n
	53 => X"0f", --tab

	56 => X"1a", --[{
	57 => X"17", --i
	58 => X"25", --k
	59 => X"32", --m
	60 => X"34", --.>
	61 => X"3a", --caps
	
	64 => X"1b", --]}
	65 => X"18", --o
	66 => X"26", --l
	67 => X"36", --rshi
	68 => X"0e", --backspace
	69 => X"27", --;:

	72 => X"0c", ---_
	73 => X"19", --p
	74 => X"08", --7&
	75 => X"05", --4$
	76 => X"52", --ins
	77 => X"02", --1!

	80 => X"0d", --=+
	81 => X"29", --`~
	82 => X"09", --8*
	83 => X"06", --5%
	84 => X"0b", --0)
	85 => X"03", --2@

	88 => X"2b", --\|
	89 => X"35", --/?
	90 => X"0a", --9(
	91 => X"07", --6^
	92 => X"53", --del
	93 => X"04", --3#

	others => X"00" --error
	);


end Constants;