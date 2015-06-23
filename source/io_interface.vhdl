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

entity io_interface is
   port (
      clock      : in  std_logic;
      clear      : in  std_logic;
      load_i     : in  std_logic;
      load_i_int : out std_logic;
      data_i     : in  std_logic_vector (7 downto 0);
      key_i      : in  std_logic_vector (7 downto 0);
      data_o     : out std_logic_vector (7 downto 0);
      data_o_int : in  std_logic_vector (127 downto 000);
      data_i_int : out std_logic_vector (127 downto 000);
      key_i_int  : out std_logic_vector (127 downto 000);
      done_o_int : in  std_logic;
      done_o     : out std_logic
      );
end io_interface;

architecture data_flow of io_interface is

type fifo16x8 is array ( 0 to 15 ) of std_logic_vector (7 downto 0);

signal fifo_data : fifo16x8 :=
(
 B"0000_0000", B"0000_0000", B"0000_0000", B"0000_0000",
 B"0000_0000", B"0000_0000", B"0000_0000", B"0000_0000",
 B"0000_0000", B"0000_0000", B"0000_0000", B"0000_0000",
 B"0000_0000", B"0000_0000", B"0000_0000", B"0000_0000"
);

signal fifo_key : fifo16x8 :=
(
 B"0000_0000", B"0000_0000", B"0000_0000", B"0000_0000",
 B"0000_0000", B"0000_0000", B"0000_0000", B"0000_0000",
 B"0000_0000", B"0000_0000", B"0000_0000", B"0000_0000",
 B"0000_0000", B"0000_0000", B"0000_0000", B"0000_0000"
);

signal fifo_output : fifo16x8 :=
(
 B"0000_0000", B"0000_0000", B"0000_0000", B"0000_0000",
 B"0000_0000", B"0000_0000", B"0000_0000", B"0000_0000",
 B"0000_0000", B"0000_0000", B"0000_0000", B"0000_0000",
 B"0000_0000", B"0000_0000", B"0000_0000", B"0000_0000"
);

signal load_core   : std_logic := '0';
signal done_int    : std_logic := '0';
signal up_counter  : integer range 0 to 15 := 0;
-- signal data_o_int : std_logic_vector (127 downto 000) :=
--   ( X"3925841D_02DC09FB_DC118597_196A0B32" );  -- CT 0

begin

load_i_int <= load_core;

process(clock, clear)
begin
if (clear = '1') then
   done_o <= '0';
elsif (clock = '1' and clock'event) then
   done_o <= done_int;
end if;
end process;

process(clock, clear)
begin
if (clear = '1') then
   up_counter <= 0;
elsif (clock = '1' and clock'event) then
   if (done_o_int = '1') then
      up_counter <= 0;
-- elsif ((up_counter = 0) and (done_o_int = '1')) then
-- elsif (done_o_int = '0' and done_o_int'event) then
-- 20051219 FIXME 
      done_int   <= '1';
   elsif (up_counter < 15 ) then
      up_counter <= up_counter + 1;
   else
--    up_counter <= 0;
      done_int   <= '0';
   end if;
end if;
end process;

process(clock, clear)
begin
if (clear = '1') then
   fifo_output <= (others => (others => '0'));
elsif (clock = '1' and clock'event) then
   if (done_o_int = '1') then
      fifo_output <= ( data_o_int (127 downto 120), data_o_int (119 downto 112), data_o_int (111 downto 104), 
                       data_o_int (103 downto 096), data_o_int (095 downto 088), data_o_int (087 downto 080), 
		       data_o_int (079 downto 072), data_o_int (071 downto 064), data_o_int (063 downto 056), 
		       data_o_int (055 downto 048), data_o_int (047 downto 040), data_o_int (039 downto 032), 
		       data_o_int (031 downto 024), data_o_int (023 downto 016), data_o_int (015 downto 008), 
		       data_o_int (007 downto 000));
   end if;
end if;
end process;

process(clock, clear)
begin
if (clear = '1') then
data_o <= (others => '0');
elsif (clock = '1' and clock'event) then
data_o <= fifo_output(up_counter);
end if;
end process;

process(clock, clear)
begin
   if (clear = '1') then
      fifo_key     <= (others => (others => '0'));
      fifo_data    <= (others => (others => '0'));
      load_core    <= '1';
   elsif (clock = '1' and clock'event) then
      if (load_i  = '1') then
         fifo_key     <= (fifo_key (1 to 15) & key_i);
         fifo_data    <= (fifo_data (1 to 15) & data_i);
      end if;
	 load_core    <= load_i;
   end if;
end process;

key_i_int<= ( fifo_key (00) & fifo_key (01) & fifo_key (02) & fifo_key (03) &
              fifo_key (04) & fifo_key (05) & fifo_key (06) & fifo_key (07) &
              fifo_key (08) & fifo_key (09) & fifo_key (10) & fifo_key (11) &
              fifo_key (12) & fifo_key (13) & fifo_key (14) & fifo_key (15) );

data_i_int<= ( fifo_data (00) & fifo_data (01) & fifo_data (02) & fifo_data (03) &
               fifo_data (04) & fifo_data (05) & fifo_data (06) & fifo_data (07) &
               fifo_data (08) & fifo_data (09) & fifo_data (10) & fifo_data (11) &
               fifo_data (12) & fifo_data (13) & fifo_data (14) & fifo_data (15) );

end data_flow;
