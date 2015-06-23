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
use ieee.std_logic_textio.all;
use std.textio.all;

entity output is
  port (
    clock          : in std_logic;
    clear          : in std_logic;
    load           : in std_logic;
    enc            : in std_logic;
    done           : in std_logic;
    test_iteration : in integer;
    verifier       : in std_logic_vector (007 downto 000);
    data_o         : in std_logic_vector (007 downto 000)
    );
end output;

architecture test_bench of output is

  file out_enc_file_ptr : text open write_mode is "ecb_tbl_result_enc.txt";
  file out_dec_file_ptr : text open write_mode is "ecb_tbl_result_dec.txt";
  signal failed         : integer := 0;
  signal passed         : integer := 0;

  type fifo16x8 is array (0 to 15) of std_logic_vector (7 downto 0);

  signal fifo_verifier : fifo16x8 :=
  (
   B"0000_0000", B"0000_0000", B"0000_0000", B"0000_0000",
   B"0000_0000", B"0000_0000", B"0000_0000", B"0000_0000",
   B"0000_0000", B"0000_0000", B"0000_0000", B"0000_0000",
   B"0000_0000", B"0000_0000", B"0000_0000", B"0000_0000"
  );

  signal counter : integer range 0 to 15 := 0;
  signal current_verifier : std_logic_vector (7 downto 0);

begin

  process(clock, clear)
  begin
  if (clear = '1') then
     counter <= 0;
  elsif (clock = '1' and clock'event) then
     if (done = '0') then
        counter <= 0;
     elsif (counter < 15 ) then
        counter <= counter + 1;
     else
        counter <= 0;
     end if;
  end if;
  end process;

  current_verifier <= fifo_verifier(counter);

  process(clock, clear)
  begin
  if (clear = '1') then
  fifo_verifier <= (others => ( others => '0'));
  elsif(clock = '1' and clock'event) then
     if (load = '1') then
     fifo_verifier <= (fifo_verifier (1 to 15) & verifier);
     end if;
  end if;
  end process;

  process (clock)
    variable out_line                     : line;
  begin
    if (clock = '1' and clock'event) then
      if (done = '1') then
        write(out_line, string'("Test ====> "));
        write(out_line, test_iteration);
	write(out_line, string'(" byte "));
	write(out_line, counter);
        if ( enc = '0') then
          writeline(out_enc_file_ptr, out_line);
        else
          writeline(out_dec_file_ptr, out_line);
        end if;
        write(out_line, string'("Expected : "));
        write(out_line, current_verifier);
        if ( enc = '0') then
          writeline(out_enc_file_ptr, out_line);
        else
          writeline(out_dec_file_ptr, out_line);
        end if;
        write(out_line, string'("Got      : "));
        write(out_line, data_o);
        if ( enc = '0') then
          writeline(out_enc_file_ptr, out_line);
        else
          writeline(out_dec_file_ptr, out_line);
        end if;
        write(out_line, string'("Status   : "));
        if (current_verifier = data_o ) then
          write (out_line, string'("OK"));
          passed <= passed + 1;
        else
          write (out_line, string'("FAILED"));
          failed <= failed + 1;
        end if;
        if ( enc = '0') then
          writeline(out_enc_file_ptr, out_line);
        else
          writeline(out_dec_file_ptr, out_line);
        end if;

      end if;

    end if;

  end process;

end test_bench;
