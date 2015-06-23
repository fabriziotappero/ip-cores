----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:29:11 03/02/2011 
-- Design Name: 
-- Module Name:    PC2FPGA - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity PC2FPGA is
    Port ( rst : in  STD_LOGIC;
           clk : in  STD_LOGIC;
			  
           locked : in  STD_LOGIC;
			  
			  rx_sof : in  STD_LOGIC;
			  rx_eof : in  STD_LOGIC;
			  vld_i : in  STD_LOGIC;
			  val_i : in  STD_LOGIC_VECTOR(7 downto 0);
			  
			  sod_o : out  STD_LOGIC;
			  eod_o : out  STD_LOGIC;
			  
			  type_o : out  STD_LOGIC_VECTOR(2 downto 0); -- 000: no transmission
																		 -- 001: receiving characters
																		 -- 010: receiving short integers
																		 -- 011: receiving integers
																		 -- 100: receiving floats
																		 -- 101: receiving doubles
																		 
			  vld_o : out  STD_LOGIC;

			  val_o_char : out  STD_LOGIC_VECTOR(7 downto 0);
			  val_o_short : out  STD_LOGIC_VECTOR(15 downto 0);
			  val_o_int_float : out  STD_LOGIC_VECTOR(31 downto 0); 
			  val_o_long_double : out  STD_LOGIC_VECTOR(63 downto 0)
			  
			  );
end PC2FPGA;

architecture Behavioral of PC2FPGA is

component MATCH_CMD is
    Port ( rst : in  STD_LOGIC;
           clk : in  STD_LOGIC;
           sof : in  STD_LOGIC;
           vld_i : in  STD_LOGIC;
           val_i : in  STD_LOGIC_VECTOR (7 downto 0);
			  cmd_to_match : in  STD_LOGIC_VECTOR(7 downto 0);
           cmd_match : out  STD_LOGIC);
end component;

component MODE_SEL_REGISTER is
    Port ( rst : in  STD_LOGIC;
           clk : in  STD_LOGIC;
           rx_sof : in  STD_LOGIC;
           rx_eof : in  STD_LOGIC;
           en : in  STD_LOGIC;
           sel : out  STD_LOGIC);
end component;

signal pack_is_chars, pack_is_shorts, pack_is_ints, pack_is_floats, pack_is_longs, pack_is_doubles,
       select_chars, select_shorts, select_ints, select_floats, select_longs, select_doubles,
		 vld_o_t, en_counter, en_counter_r, sod_o_t, vld_i_r, set_eod, rx_eof_reg: std_logic;
signal select_chars_v, select_shorts_v, select_ints_v, select_floats_v, select_ints_floats_v, select_longs_v, select_doubles_v, select_longs_doubles_v,
       type_o_t, type_o_t_r, match_t_1, match_t_2, match_t_3, match_t_4, counter_value: std_logic_vector(2 downto 0);

signal sel_val_o_chars_v: std_logic_vector(7 downto 0);
signal short_res, sel_val_o_shorts_v: std_logic_vector(15 downto 0);
signal int_float_res, sel_val_o_ints_floats_v: std_logic_vector(31 downto 0);
signal long_double_res, sel_val_o_longs_doubles_v: std_logic_vector(63 downto 0);

signal val_i_r2, val_i_r3, val_i_r4, val_i_r5, val_i_r6, val_i_r7, val_i_r8: std_logic_vector(7 downto 0);
signal user_length, user_counter: std_logic_vector(15 downto 0);

begin

sod_o_t <= (pack_is_chars or pack_is_shorts or pack_is_ints or pack_is_floats or pack_is_longs or pack_is_doubles) and locked;

sod_o <= sod_o_t;

eod_o <= (not rx_eof_reg) and locked;

MATCH_CHAR: MATCH_CMD Port Map
( rst => rst,
  clk => clk,
  sof => rx_sof,
  vld_i => vld_i,
  val_i => val_i,  
  cmd_to_match => "00000001",
  cmd_match => pack_is_chars
);

MATCH_SHORT: MATCH_CMD Port Map
( rst => rst,
  clk => clk,
  sof => rx_sof,
  vld_i => vld_i,
  val_i => val_i,  
  cmd_to_match => "00000010",
  cmd_match => pack_is_shorts
);

MATCH_INT: MATCH_CMD Port Map
( rst => rst,
  clk => clk,
  sof => rx_sof,
  vld_i => vld_i,
  val_i => val_i,  
  cmd_to_match => "00000011",
  cmd_match => pack_is_ints
);

MATCH_FLOAT: MATCH_CMD Port Map
( rst => rst,
  clk => clk,
  sof => rx_sof,
  vld_i => vld_i,
  val_i => val_i,  
  cmd_to_match => "00000100",
  cmd_match => pack_is_floats
);

MATCH_LONG: MATCH_CMD Port Map
( rst => rst,
  clk => clk,
  sof => rx_sof,
  vld_i => vld_i,
  val_i => val_i,  
  cmd_to_match => "00000101",
  cmd_match => pack_is_longs
);

MATCH_DOUBLE: MATCH_CMD Port Map
( rst => rst,
  clk => clk,
  sof => rx_sof,
  vld_i => vld_i,
  val_i => val_i,  
  cmd_to_match => "00000110",
  cmd_match => pack_is_doubles
);

SELECT_CHAR: MODE_SEL_REGISTER Port map
( rst => rst,
  clk => clk,
  rx_sof => rx_sof,
  rx_eof => rx_eof_reg,
  en => pack_is_chars,
  sel => select_chars
);

SELECT_SHORT: MODE_SEL_REGISTER Port map
( rst => rst,
  clk => clk,
  rx_sof => rx_sof,
  rx_eof => rx_eof_reg,
  en => pack_is_shorts,
  sel => select_shorts
);

SELECT_INT: MODE_SEL_REGISTER Port map
( rst => rst,
  clk => clk,
  rx_sof => rx_sof,
  rx_eof => rx_eof_reg,
  en => pack_is_ints,
  sel => select_ints
);

SELECT_FLOAT: MODE_SEL_REGISTER Port map
( rst => rst,
  clk => clk,
  rx_sof => rx_sof,
  rx_eof => rx_eof_reg,
  en => pack_is_floats,
  sel => select_floats
);

SELECT_LONG: MODE_SEL_REGISTER Port map
( rst => rst,
  clk => clk,
  rx_sof => rx_sof,
  rx_eof => rx_eof_reg,
  en => pack_is_longs,
  sel => select_longs
);

SELECT_DOUBLE: MODE_SEL_REGISTER Port map
( rst => rst,
  clk => clk,
  rx_sof => rx_sof,
  rx_eof => rx_eof_reg,
  en => pack_is_doubles,
  sel => select_doubles
);

select_chars_v <= (others=> select_chars and locked);
select_shorts_v <= (others=> select_shorts and locked);
select_ints_v <= (others=> select_ints and locked);
select_floats_v <= (others=> select_floats and locked);
select_ints_floats_v <= (others=> (select_ints or select_floats) and locked);
select_longs_v <= (others=> select_longs and locked);
select_doubles_v <= (others=> select_doubles and locked);
select_longs_doubles_v <= (others=> (select_longs or select_doubles) and locked);


sel_val_o_chars_v <= (others=> select_chars and locked);
sel_val_o_shorts_v <= (others=> select_shorts and locked);
sel_val_o_ints_floats_v <= (others=> (select_ints or select_floats) and locked);
sel_val_o_longs_doubles_v <= (others=> (select_longs or select_doubles) and locked);

type_o_t <=  (select_chars_v and "001") or 
	         (select_shorts_v and "010") or
				  (select_ints_v and "011") or
				(select_floats_v and "100") or
				 (select_longs_v and "101") or
			  (select_doubles_v and "110") ; 				

type_o <= type_o_t or type_o_t_r;

en_counter <= select_chars or 
				  select_shorts or 
				  select_ints or
				  select_floats or
				  select_longs or
				  select_doubles;
				  
process(clk)
begin
if clk'event and clk='1' then
	rx_eof_reg <= rx_eof;
	if en_counter='0' then
		counter_value <= "000";
	else
		counter_value <= counter_value + "001";
	end if;
end if;
end process;

match_t_1 <= (select_shorts_v and "000") or (select_ints_floats_v and "010") or (select_longs_doubles_v and "110");
match_t_2 <= (select_shorts_v and "010") or (select_ints_floats_v and "010") or (select_longs_doubles_v and "110");
match_t_3 <= (select_shorts_v and "100") or (select_ints_floats_v and "110") or (select_longs_doubles_v and "110");
match_t_4 <= (select_shorts_v and "110") or (select_ints_floats_v and "110") or (select_longs_doubles_v and "110");

process(clk)
begin
if clk'event and clk='1' then
	en_counter_r <= en_counter;
	type_o_t_r <= type_o_t;
	if counter_value = match_t_1 or counter_value = match_t_2 or counter_value = match_t_3 or counter_value = match_t_4 then
		vld_o_t <= '1';
	else
		vld_o_t <= '0';
	end if;
end if;
end process;

process(clk)
begin
if clk'event and clk='1' then
	val_i_r2 <= val_i;
	val_i_r3 <= val_i_r2;
	val_i_r4 <= val_i_r3;
	val_i_r5 <= val_i_r4;
	val_i_r6 <= val_i_r5;
	val_i_r7 <= val_i_r6;
	val_i_r8 <= val_i_r7;
end if;
end process;	

short_res(15 downto 8) <= val_i_r2; 
short_res(7 downto 0) <= val_i; 

int_float_res(31 downto 24) <= val_i_r4;
int_float_res(23 downto 16) <= val_i_r3;
int_float_res(15 downto 0) <= short_res;

long_double_res(63 downto 56) <= val_i_r8;
long_double_res(55 downto 48) <= val_i_r7;
long_double_res(47 downto 40) <= val_i_r6;
long_double_res(39 downto 32) <= val_i_r5;
long_double_res(31 downto 0) <= int_float_res;

process(clk)
begin
if clk'event and clk='1' then	
	vld_o <= (select_chars or ((select_shorts or select_ints or select_floats or select_longs or select_doubles) and vld_o_t and en_counter_r)) and locked;
	val_o_char <= val_i and sel_val_o_chars_v;
	val_o_short <= short_res and sel_val_o_shorts_v;
	val_o_int_float <= int_float_res and sel_val_o_ints_floats_v;
	val_o_long_double <= long_double_res and sel_val_o_longs_doubles_v;
end if;
end process;

end Behavioral;

