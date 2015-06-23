-----------------------------------------------------------------------
----                                                               ----
---- Montgomery modular multiplier and exponentiator               ----
----                                                               ----
---- This file is part of the Montgomery modular multiplier        ----
---- and exponentiator project                                     ----
---- http://opencores.org/project,mod_mult_exp                     ----
----                                                               ----
---- Description:                                                  ----
----     Properties file for multiplier and exponentiator          ----
----     (512 bit).                                                ----
---- To Do:                                                        ----
----                                                               ----
---- Author(s):                                                    ----
---- - Krzysztof Gajewski, gajos@opencores.org                     ----
----                       k.gajewski@gmail.com                    ----
----                                                               ----
-----------------------------------------------------------------------
----                                                               ----
---- Copyright (C) 2014 Authors and OPENCORES.ORG                  ----
----                                                               ----
---- This source file may be used and distributed without          ----
---- restriction provided that this copyright statement is not     ----
---- removed from the file and that any derivative work contains   ----
---- the original copyright notice and the associated disclaimer.  ----
----                                                               ----
---- This source file is free software; you can redistribute it    ----
---- and-or modify it under the terms of the GNU Lesser General    ----
---- Public License as published by the Free Software Foundation;  ----
---- either version 2.1 of the License, or (at your option) any    ----
---- later version.                                                ----
----                                                               ----
---- This source is distributed in the hope that it will be        ----
---- useful, but WITHOUT ANY WARRANTY; without even the implied    ----
---- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR       ----
---- PURPOSE. See the GNU Lesser General Public License for more   ----
---- details.                                                      ----
----                                                               ----
---- You should have received a copy of the GNU Lesser General     ----
---- Public License along with this source; if not, download it    ----
---- from http://www.opencores.org/lgpl.shtml                      ----
----                                                               ----
-----------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;

package properties is

-- Declare constants
 
constant BYTE             : INTEGER := 8;

constant WORD_LENGTH	   : INTEGER := 512;
constant WORD_INTEGER     : INTEGER := 10;
constant WORD_INT_LOG     : INTEGER := 6;
constant WORD_INT_LOG_STR : STD_LOGIC_VECTOR(WORD_INT_LOG - 1 downto 0) := "111111";

constant count_up : STD_LOGIC_VECTOR(1 downto 0) := "00";
constant count_down : STD_LOGIC_VECTOR(1 downto 0) := "01";
constant do_nothing : STD_LOGIC_VECTOR(1 downto 0) := "11";

type multiplier_states is (NOP, CALCULATE_START, STOP);

type exponentiator_states is (FIRST_RUN, NOP, 
    READ_DATA_BASE, READ_DATA_MODULUS, READ_DATA_EXPONENT, READ_DATA_RESIDUUM,
    COUNT_POWER, EXP_Z, SAVE_EXP_Z, EXP_P, SAVE_EXP_P, EXP_CONTROL, EXP_END, SAVE_EXP_MULT,
    INFO_RESULT, SHOW_RESULT);

type fin_data_ctrl_states is (NOP, PAD_FAIL, PAD_FAIL_NOP, PAD_FAIL_DECODE,
    DECODE_IN, READ_DATA, DECODE_READ, DECODE_READ_PROP, MAKE_FINALIZE, OUTPUT_DATA, INFO_STATE, 
    TEMPORARY_STATE, DATA_TO_OUT_PROPAGATE, DATA_TO_OUT_PROPAGATE2, MOVE_DATA, MOVE_OUTPUT_DATA);

---- mnemonics for exponentiator
constant mn_read_base        : STD_LOGIC_VECTOR(2 downto 0) := "000";
constant mn_read_modulus     : STD_LOGIC_VECTOR(2 downto 0) := "001";
constant mn_read_exponent    : STD_LOGIC_VECTOR(2 downto 0) := "010";
constant mn_read_residuum    : STD_LOGIC_VECTOR(2 downto 0) := "011";
constant mn_count_power      : STD_LOGIC_VECTOR(2 downto 0) := "100";
constant mn_show_result      : STD_LOGIC_VECTOR(2 downto 0) := "101";
constant mn_show_status      : STD_LOGIC_VECTOR(2 downto 0) := "110";
constant mn_prepare_for_data : STD_LOGIC_VECTOR(2 downto 0) := "111";

---- addresses for memory data
constant addr_base     : STD_LOGIC_VECTOR(3 downto 0) := "0000";
constant addr_modulus  : STD_LOGIC_VECTOR(3 downto 0) := "0010";
constant addr_exponent : STD_LOGIC_VECTOR(3 downto 0) := "0100";
constant addr_power    : STD_LOGIC_VECTOR(3 downto 0) := "0101";
constant addr_residuum : STD_LOGIC_VECTOR(3 downto 0) := "1000";
constant addr_one      : STD_LOGIC_VECTOR(3 downto 0) := "1001";
constant addr_unused   : STD_LOGIC_VECTOR(3 downto 0) := "1101";
constant addr_z        : STD_LOGIC_VECTOR(3 downto 0) := "1110";
constant addr_p        : STD_LOGIC_VECTOR(3 downto 0) := "1111";

---- help_statuses_for_clarity
constant stat_all_data_readed : STD_LOGIC_VECTOR(5 downto 0) := "111111";
constant stat_clear_status    : STD_LOGIC_VECTOR(5 downto 0) := "000000";

end properties;

package body properties is
 
end properties;
