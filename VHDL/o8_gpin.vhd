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
-- VHDL Units :  o8_gpin
-- Description:  Provides a single 8-bit input register

library ieee;
use ieee.std_logic_1164.all;

library work;
  use work.open8_pkg.all;

entity o8_gpin is
generic(
  Reset_Level           : std_logic;
  Address               : ADDRESS_TYPE
);
port(
  Clock                 : in  std_logic;
  Reset                 : in  std_logic;
  --
  Bus_Address           : in  ADDRESS_TYPE;
  Rd_Enable             : in  std_logic;
  Rd_Data               : out DATA_TYPE;
  --
  GPIN                  : in  DATA_TYPE
);
end entity;

architecture behave of o8_gpin is

  constant User_Addr    : std_logic_vector(15 downto 0) := Address;
  alias  Comp_Addr      is Bus_Address(15 downto 0);
  signal Addr_Match     : std_logic;
  signal Rd_En          : std_logic;
  signal User_In        : DATA_TYPE;

begin

  Addr_Match            <= Rd_Enable when Comp_Addr = User_Addr else '0';

  io_reg: process( Clock, Reset )
  begin
    if( Reset = Reset_Level )then
      Rd_En             <= '0';
      Rd_Data           <= x"00";
    elsif( rising_edge( Clock ) )then
      User_In           <= GPIN; -- first stage of double buffer

      Rd_Data           <= (others => '0');
      Rd_En             <= Addr_Match;
      if( Rd_En = '1' )then
        Rd_Data         <= User_In;
      end if;
    end if;
  end process;

end architecture;
