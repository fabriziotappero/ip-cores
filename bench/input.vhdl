-- ------------------------------------------------------------------------
-- Copyright (C) 2005 Arif Endro Nugroho
-- All rights reserved.
-- 
-- Redistribution and use in source and binary forms, with or without
-- modification, are permitted provided that the following conditions
-- are met:
-- 
-- 1. Redistributions of source code must retain the above copyright
--    notice, this list of conditions and the following disclaimer.
-- 2. Redistributions in binary form must reproduce the above copyright
--    notice, this list of conditions and the following disclaimer in the
--    documentation and/or other materials provided with the distribution.
-- 
-- THIS SOFTWARE IS PROVIDED BY ARIF ENDRO NUGROHO "AS IS" AND ANY EXPRESS
-- OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
-- WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
-- DISCLAIMED. IN NO EVENT SHALL ARIF ENDRO NUGROHO BE LIABLE FOR ANY
-- DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
-- DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
-- OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
-- HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
-- STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
-- ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
-- POSSIBILITY OF SUCH DAMAGE.
-- 
-- End Of License.
-- ------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use std.textio.all;

entity input is
   port (
      clock   : out bit;
      start   : out bit;
      rxin    : out bit_vector (07 downto 00)
      );
end input;

architecture test_bench of input is

type char_to_stdlogic_t is array (character) of std_logic;
constant to_std_logic : char_to_stdlogic_t := (
   'U' => 'U',
   'X' => 'X',
   '0' => '0',
   '1' => '1',
   'Z' => 'Z',
   'W' => 'L',
   'H' => 'H',
   '-' => '-',
others => 'X'
   );

file start_ptr : text open read_mode is "../data/start.txt";
file rxin_ptr  : text open read_mode is "../data/rxin100DB.txt";

begin
   process
   variable start_ln  : line;
   variable rxin_ln   : line;
   variable delay     : time := 1 ns;
   variable start_str : string (01 to 01) := " ";
   variable rxin_str  : string (01 to 08) := "        ";
   variable rxin_len  : integer;
   variable start_var : std_logic;
   variable rxin_var  : std_logic_vector (07 downto 00);
   begin
      while not (endfile(start_ptr) and endfile(rxin_ptr)) loop
      
      readline(start_ptr, start_ln);
      
      if (not(endfile(rxin_ptr))) then
         readline(rxin_ptr, rxin_ln);
      else
         write(rxin_ln, string'("00000000"));
      end if;
      
      if (start_ln /= NULL) and (start_ln'length > 0) and (rxin_ln /= NULL) and (rxin_ln'length > 0) then
         
	 read(start_ln, start_str);
	 read(rxin_ln, rxin_str);
	 rxin_len  := rxin_str'length - 1;

	 start_var := to_std_logic (start_str(01));

	 for b in rxin_str'range loop
	    rxin_var(rxin_len)   := to_std_logic (rxin_str(b));
	    rxin_len             := rxin_len - 1;
	 end loop;

	 start    <= to_bit       (start_var);
	 rxin     <= to_bitvector (rxin_var);

	 clock <= '1';
	 wait for delay;
	 clock <= '0';
	 wait for delay;
      end if;
      end loop;
   wait;
   end process;
end test_bench;
