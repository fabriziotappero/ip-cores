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
use ieee.std_logic_textio.all;
use std.textio.all;

library std_developerskit;
use std_developerskit.std_iopak.all;    -- Function From_HexString

entity input is
  port (
    clock          : out std_logic;
    load           : out std_logic;
    done           : in  std_logic;
    test_iteration : out integer;
    key_i_byte     : out std_logic_vector (007 downto 000);
    data_i_byte    : out std_logic_vector (007 downto 000);
    cipher_o_byte  : out std_logic_vector (007 downto 000)
    );
end input;

architecture test_bench of input is

--
  file in_file_ptr            : text open read_mode is "../data/ecb_tbl.txt";
--
  signal     clock_int        : std_logic := '0';
  signal     ct               : std_logic_vector (127 downto 000);
  signal     pt               : std_logic_vector (127 downto 000);
  signal     ky               : std_logic_vector (127 downto 000);
--
begin
--
  clock_int            <= not(clock_int) after 1 ns;
  clock                <= clock_int;
--
  process
--
    variable delay            : time      := 1 ns;
    variable in_line          : line;
    variable cipher_text      : string ( 01 to 32 );
    variable plain_text       : string ( 01 to 32 );
    variable key              : string ( 01 to 32 );
    variable test             : integer;
    variable junk_test        : string ( 01 to 02 );
    variable junk_plain_text  : string ( 01 to 03 );
    variable junk_cipher_text : string (01 to 03 );
    variable junk_key         : string ( 01 to 04 );
--
  begin
--
    while not (endfile(in_file_ptr)) loop
--
      readline(in_file_ptr, in_line);   -- blank lines
--
      readline(in_file_ptr, in_line);
      read(in_line, junk_test);
      read(in_line, test);
      readline(in_file_ptr, in_line);
      read(in_line, junk_key);
      read(in_line, key);
      readline(in_file_ptr, in_line);
      read(in_line, junk_plain_text);
      read(in_line, plain_text);
      readline(in_file_ptr, in_line);
      read(in_line, junk_cipher_text);
      read(in_line, cipher_text);
--
      ky               <= to_StdLogicVector(From_HexString(key( 01 to 32)));
      pt               <= to_StdLogicVector(From_HexString(plain_text( 01 to 32 )));
      ct               <= to_StdLogicVector(From_HexString(cipher_text( 01 to 32 )));
--
      for a in 1 to key'length/2 loop
        wait until rising_edge(clock_int);
        key_i_byte     <= to_StdLogicVector(From_HexString(key(2*a-1 to 2*a)));
        data_i_byte    <= to_StdLogicVector(From_HexString(plain_text(2*a-1 to 2*a)));
        cipher_o_byte  <= to_StdLogicVector(From_HexString(cipher_text(2*a-1 to 2*a)));
        load           <= '1';
        test_iteration <= test;
      end loop;
--
      wait until rising_edge(clock_int);
      load             <= '0';
--
      wait until falling_edge(done);
      wait until rising_edge(clock_int);
--
    end loop;
    wait;
  end process;
--
end test_bench;
