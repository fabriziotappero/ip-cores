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
use ieee.std_logic_unsigned.all;

entity folded_register is
  port (
    clk_i  : in  std_logic;
    enc_i  : in  std_logic;
    load_i : in  std_logic;
    data_i : in  std_logic_vector (127 downto 000);
    key_i  : in  std_logic_vector (127 downto 000);
    di_0_i : in  std_logic_vector (007 downto 000);
    di_1_i : in  std_logic_vector (007 downto 000);
    di_2_i : in  std_logic_vector (007 downto 000);
    di_3_i : in  std_logic_vector (007 downto 000);
    do_0_o : out std_logic_vector (007 downto 000);
    do_1_o : out std_logic_vector (007 downto 000);
    do_2_o : out std_logic_vector (007 downto 000);
    do_3_o : out std_logic_vector (007 downto 000)
    );
end folded_register;

architecture data_flow of folded_register is

  component counter2bit
    port (
      clock : in  std_logic;
      clear : in  std_logic;
      count : out std_logic_vector (1 downto 0)
      );
  end component;

  type fifo16x8 is array (00 to 15) of std_logic_vector (7 downto 0);
  type addr4x4 is array (3 downto 0) of std_logic_vector (3 downto 0);
  type addr4x8 is array (3 downto 0) of std_logic_vector (7 downto 0);

  signal foldreg0 : fifo16x8 :=
    (
      X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00",
      X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00"
      );
--
  signal foldreg1 : fifo16x8 :=
    (
      X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00",
      X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00"
      );
--
  signal foldreg2 : fifo16x8 :=
    (
      X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00",
      X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00"
      );

  signal   round0             : std_logic_vector (127 downto 000) := ( X"00000000_00000000_00000000_00000000" );
--
  signal   a_0_i              : std_logic_vector (3 downto 0)     := ( B"0000" );
  signal   a_1_i              : std_logic_vector (3 downto 0)     := ( B"0000" );
  signal   a_2_i              : std_logic_vector (3 downto 0)     := ( B"0000" );
  signal   a_3_i              : std_logic_vector (3 downto 0)     := ( B"0000" );
--
  constant fifo_addr_cons     : std_logic_vector (63 downto 00)   := ( X"05AF_49E3_8D27_C16B" );
  constant fifo_addr_cons_inv : std_logic_vector (63 downto 00)   := ( X"0DA7_41EB_852F_C963" );
  signal   fifo_addr          : std_logic_vector (63 downto 00)   := ( X"0000_0000_0000_0000" );
--
  signal   tmp                : addr4x8                           := ( X"00", X"00", X"00", X"00" );
  signal   addr               : addr4x4                           := ( X"0", X"0", X"0", X"0" );
--
  signal   count              : std_logic_vector (1 downto 0);
  signal   switch             : std_logic                         := '0';
  signal   reg_i              : std_logic                         := '0';

begin

  sect : counter2bit
    port map (
      clock => clk_i,
      clear => load_i,
      count => count
      );

  round0 <= data_i xor key_i;

  process(clk_i, load_i)
  begin
    if (load_i = '1') then
      foldreg0                 <= (
        round0 (127 downto 120), round0 (119 downto 112), round0 (111 downto 104), round0 (103 downto 096),
        round0 (095 downto 088), round0 (087 downto 080), round0 (079 downto 072), round0 (071 downto 064),
        round0 (063 downto 056), round0 (055 downto 048), round0 (047 downto 040), round0 (039 downto 032),
        round0 (031 downto 024), round0 (023 downto 016), round0 (015 downto 008), round0 (007 downto 000)
        );
--
      foldreg1                 <= (
        round0 (127 downto 120), round0 (119 downto 112), round0 (111 downto 104), round0 (103 downto 096),
        round0 (095 downto 088), round0 (087 downto 080), round0 (079 downto 072), round0 (071 downto 064),
        round0 (063 downto 056), round0 (055 downto 048), round0 (047 downto 040), round0 (039 downto 032),
        round0 (031 downto 024), round0 (023 downto 016), round0 (015 downto 008), round0 (007 downto 000)
        );
--
      if (enc_i = '0') then
        fifo_addr              <= fifo_addr_cons;
      else
        fifo_addr              <= fifo_addr_cons_inv;
      end if;
      reg_i                    <= '0';
    elsif (clk_i = '1' and clk_i'event) then
      if (reg_i = '1') then
        foldreg0 (00 to 11)    <= ( foldreg0 (04 to 15) );
        foldreg0 (12 to 15)    <= ( di_0_i, di_1_i, di_2_i, di_3_i );
      else
        foldreg1 (00 to 11)    <= ( foldreg1 (04 to 15) );
        foldreg1 (12 to 15)    <= ( di_0_i, di_1_i, di_2_i, di_3_i );
      end if;
      fifo_addr (63 downto 16) <= fifo_addr (47 downto 00);
      fifo_addr (15 downto 00) <= fifo_addr (63 downto 48);
      if (switch = '1') then
        reg_i                  <= not(reg_i);
      end if;
    end if;
  end process;

  a_0_i               <= addr(0);
  a_1_i               <= addr(1);
  a_2_i               <= addr(2);
  a_3_i               <= addr(3);
--
  foldreg2 (00 to 11) <= ( foldreg0 (04 to 15) )       when (reg_i = '1')    else ( foldreg1 (04 to 15) );
  foldreg2 (12 to 15) <= ( di_0_i, di_1_i, di_2_i, di_3_i );
--
  switch              <= (count(1)) and (count(0));
--
  addr(0)             <= fifo_addr (51 downto 48)      when ( load_i = '1' ) else fifo_addr (35 downto 32);
  addr(1)             <= fifo_addr (55 downto 52)      when ( load_i = '1' ) else fifo_addr (39 downto 36);
  addr(2)             <= fifo_addr (59 downto 56)      when ( load_i = '1' ) else fifo_addr (43 downto 40);
  addr(3)             <= fifo_addr (63 downto 60)      when ( load_i = '1' ) else fifo_addr (47 downto 44);
--
  tmp(0)              <= foldreg1(conv_integer(a_0_i)) when ( reg_i = '1' )  else foldreg0(conv_integer(a_0_i));
  tmp(1)              <= foldreg1(conv_integer(a_1_i)) when ( reg_i = '1' )  else foldreg0(conv_integer(a_1_i));
  tmp(2)              <= foldreg1(conv_integer(a_2_i)) when ( reg_i = '1' )  else foldreg0(conv_integer(a_2_i));
  tmp(3)              <= foldreg1(conv_integer(a_3_i)) when ( reg_i = '1' )  else foldreg0(conv_integer(a_3_i));
--
  do_0_o              <= tmp(3)                        when ( switch = '0')  else foldreg2(conv_integer(a_3_i));
  do_1_o              <= tmp(2)                        when ( switch = '0')  else foldreg2(conv_integer(a_2_i));
  do_2_o              <= tmp(1)                        when ( switch = '0')  else foldreg2(conv_integer(a_1_i));
  do_3_o              <= tmp(0)                        when ( switch = '0')  else foldreg2(conv_integer(a_0_i));

end data_flow;
