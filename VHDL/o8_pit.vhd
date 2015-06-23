-- Copyright (c)2013 Jeremy Seth Henry
-- All rights reserved.
--
-- Redistribution and use in source and binary forms, with or without
-- modification, are permitted provided that the following conditions are met:
--     * Redistributions of source code must retain the above copyright
--       notice, this list of conditions and the following disclaimer.
--     * Redistributions in binary form must reproduce the above copyright
--       notice, this list of conditions and the following disclaimer in the
--       documentation and/or other materials provided with the distribution,
--       where applicable (as part of a user interface, debugging port, etc.)
--
-- THIS SOFTWARE IS PROVIDED BY JEREMY SETH HENRY ``AS IS'' AND ANY
-- EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
-- WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
-- DISCLAIMED. IN NO EVENT SHALL JEREMY SETH HENRY BE LIABLE FOR ANY
-- DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
-- (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
-- LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
-- ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
-- (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
-- SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--
-- VHDL Units :  o8_pit
-- Description:  Provides an 8-bit microsecond resolution timer for generating
--            :   periodic interrupts for the Open8 CPU.
--
-- Notes      :  It is possible to set the value to zero, resulting in the
--            :   output staying high indefinitely. This may cause an issue if
--            :   the output is connected to an interrupt input.
--            :  Also provides uSec_Tick as an output

library ieee;
use ieee.std_logic_1164.all;
  use ieee.std_logic_unsigned.all;
  use ieee.std_logic_arith.all;
  use ieee.std_logic_misc.all;

library work;
  use work.open8_pkg.all;

entity o8_pit is
generic(
  Sys_Freq              : real;
  Reset_Level           : std_logic;
  Address               : ADDRESS_TYPE
);
port(
  Clock                 : in  std_logic;
  Reset                 : in  std_logic;
  uSec_Tick             : out std_logic;
  --
  Bus_Address           : in  ADDRESS_TYPE;
  Wr_Enable             : in  std_logic;
  Wr_Data               : in  DATA_TYPE;
  Rd_Enable             : in  std_logic;
  Rd_Data               : out DATA_TYPE;
  --
  Tmr_Out               : out std_logic
);
end entity;

architecture behave of o8_pit is

  constant User_Addr    : ADDRESS_TYPE := Address;
  alias  Comp_Addr      is Bus_Address(15 downto 0);
  signal Addr_Match     : std_logic;
  signal Wr_En          : std_logic;
  signal Wr_Data_q      : DATA_TYPE;
  signal Rd_En          : std_logic;
  signal Rd_En_q        : std_logic;

  signal Interval       : DATA_TYPE;
  signal Timer_Cnt      : DATA_TYPE;

  -- The ceil_log2 function returns the minimum register width required to
  --  hold the supplied integer.
  function ceil_log2 (x : in natural) return natural is
    variable retval          : natural;
  begin
    retval                   := 1;
    while ((2**retval) - 1) < x loop
      retval                 := retval + 1;
    end loop;
    return retval;
  end ceil_log2;

  constant DLY_1USEC_VAL: integer := integer(Sys_Freq / 1000000.0);
  constant DLY_1USEC_WDT: integer := ceil_log2(DLY_1USEC_VAL - 1);
  constant DLY_1USEC    : std_logic_vector :=
                       conv_std_logic_vector( DLY_1USEC_VAL - 1, DLY_1USEC_WDT);

  signal uSec_Cntr      : std_logic_vector( DLY_1USEC_WDT - 1 downto 0 )
                          := (others => '0');
  signal uSec_Tick_i      : std_logic;
begin

  uSec_Tick             <= uSec_Tick_i;
  Addr_Match            <= '1' when Comp_Addr = User_Addr else '0';

  io_reg: process( Clock, Reset )
  begin
    if( Reset = Reset_Level )then
      Wr_En             <= '0';
      Wr_Data_q         <= x"00";
      Rd_En             <= '0';
      Rd_Data           <= x"00";
      Interval          <= x"00";
    elsif( rising_edge( Clock ) )then
      Wr_En             <= Addr_Match and Wr_Enable;
      Wr_Data_q         <= Wr_Data;
      if( Wr_En = '1' )then
        Interval        <= Wr_Data_q;
      end if;

      Rd_Data           <= (others => '0');
      Rd_En             <= Addr_Match and Rd_Enable;
      if( Rd_En = '1' )then
        Rd_Data         <= Interval;
      end if;
    end if;
  end process;

  uSec_Tick_i_proc: process( Clock, Reset )
  begin
    if( Reset = Reset_Level )then
      uSec_Cntr         <= (others => '0');
      uSec_Tick_i       <= '0';
    elsif( rising_edge( Clock ) )then
      uSec_Cntr         <= uSec_Cntr - 1;
      uSec_Tick_i       <= '0';
      if( uSec_Cntr = 0 )then
        uSec_Cntr       <= DLY_1USEC;
        uSec_Tick_i     <= or_reduce(Interval);
      end if;
    end if;
  end process;

  Interval_proc: process( Clock, Reset )
  begin
    if( Reset = Reset_Level )then
      Timer_Cnt         <= x"00";
      Tmr_Out           <= '0';
    elsif( rising_edge(Clock) )then
      Tmr_Out           <= '0';
      Timer_Cnt         <= Timer_Cnt - uSec_Tick_i;
      if( or_reduce(Timer_Cnt) = '0' )then
        Timer_Cnt       <= Interval;
        Tmr_Out         <= or_reduce(Interval); -- Only issue output on Int > 0
      end if;
    end if;
  end process;

end architecture;
