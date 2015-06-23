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

entity key_scheduler is

  port (
    clock : in  std_logic;
    load  : in  std_logic;
    key_i : in  std_logic_vector (127 downto 00);
    key_o : out std_logic_vector (31 downto 00);
    done  : out std_logic
    );

end key_scheduler;

architecture key_expansion of key_scheduler is

  component bram_block_a
    port (
      clk_a_i    : in  std_logic;
      en_a_i     : in  std_logic;
      we_a_i     : in  std_logic;
      di_a_i     : in  std_logic_vector (07 downto 00);
      addr_a_1_i : in  std_logic_vector (08 downto 00);
      addr_a_2_i : in  std_logic_vector (08 downto 00);
      do_a_1_o   : out std_logic_vector (07 downto 00);
      do_a_2_o   : out std_logic_vector (07 downto 00)
      );
  end component;
--
  component bram_block_b
    port (
      clk_b_i    : in  std_logic;
      we_b_i     : in  std_logic;
      en_b_i     : in  std_logic;
      di_b_i     : in  std_logic_vector (07 downto 00);
      addr_b_1_i : in  std_logic_vector (08 downto 00);
      addr_b_2_i : in  std_logic_vector (08 downto 00);
      do_b_1_o   : out std_logic_vector (07 downto 00);
      do_b_2_o   : out std_logic_vector (07 downto 00)
      );
  end component;
--
  component counter2bit
    port (
      clock      : in  std_logic;
      clear      : in  std_logic;
      count      : out std_logic_vector (1 downto 0));
  end component;

  type state_element is array (03 downto 00) of std_logic_vector (07 downto 00);

  signal   clk_a_i        : std_logic;
  constant enc            : std_logic                       := '0';
  signal   en_a_i         : std_logic;
  signal   we_a_i         : std_logic;
  signal   di_a_i         : std_logic_vector (07 downto 00) := ( B"0000_0000" );
  signal   addr_a_1_i     : std_logic_vector (08 downto 00);
  signal   addr_a_2_i     : std_logic_vector (08 downto 00);
  signal   do_a_1_o       : std_logic_vector (07 downto 00);
  signal   do_a_2_o       : std_logic_vector (07 downto 00);
--
  signal   clk_b_i        : std_logic;
  signal   en_b_i         : std_logic;
  signal   we_b_i         : std_logic;
  signal   di_b_i         : std_logic_vector (07 downto 00) := ( B"0000_0000" );
  signal   addr_b_1_i     : std_logic_vector (08 downto 00);
  signal   addr_b_2_i     : std_logic_vector (08 downto 00);
  signal   do_b_1_o       : std_logic_vector (07 downto 00);
  signal   do_b_2_o       : std_logic_vector (07 downto 00);
--
  signal   temp           : state_element                   := ( B"00000000", B"00000000", B"00000000", B"00000000" );
  signal   side_opt       : state_element                   := ( B"00000000", B"00000000", B"00000000", B"00000000" );
  signal   result         : state_element                   := ( B"00000000", B"00000000", B"00000000", B"00000000" );
--
  signal   rot            : std_logic                       := '0';
  signal   count          : std_logic_vector (1 downto 0)   := ( B"00" );
  signal   rcon           : std_logic_vector (07 downto 00) := ( X"01" );
  constant round_constant : std_logic_vector (79 downto 00) := ( X"01020408_10204080_1B36");
  signal   rcon10x8       : std_logic_vector (79 downto 00) := ( X"01020408_10204080_1B36");
  signal   fifo12x8       : std_logic_vector (95 downto 00) := ( X"00000000_00000000_00000000");

begin

  clk_a_i <= clock;
  clk_b_i <= clock;
  en_a_i  <= '1';
  en_b_i  <= '1';
  we_a_i  <= '0';
  we_b_i  <= '0';
--
  sbox1 : bram_block_a
    port map (
      clk_a_i    => clk_a_i,
      en_a_i     => en_a_i,
      we_a_i     => we_a_i,
      di_a_i     => di_a_i,
      addr_a_1_i => addr_a_1_i,
      addr_a_2_i => addr_a_2_i,
      do_a_1_o   => do_a_1_o,
      do_a_2_o   => do_a_2_o
      );
--
  sbox2 : bram_block_b
    port map (
      clk_b_i    => clk_b_i,
      we_b_i     => we_b_i,
      en_b_i     => en_b_i,
      di_b_i     => di_b_i,
      addr_b_1_i => addr_b_1_i,
      addr_b_2_i => addr_b_2_i,
      do_b_1_o   => do_b_1_o,
      do_b_2_o   => do_b_2_o
      );
--
  rc    : counter2bit
    port map (
      clock      => clock,
      clear      => load,
      count      => count
      );

  ---------------------------------------------------------------
  -- key input 127 - 96 => column 0
  -- key input  95 - 64 => column 1
  -- key input  63 - 32 => column 2
  -- key input  31 -  0 => column 3 (root word) (shift) (subbyte)
  ---------------------------------------------------------------

  ---------------------------------------------------------------
  -- Round constant table
  --  encrypt:        decrypt:
  -- round 0 : 0x0100_0000   : 0x3600_0000
  -- round 1 : 0x0200_0000   : 0x1B00_0000
  -- round 2 : 0x0400_0000   : 0x8000_0000
  -- round 3 : 0x0800_0000   : 0x4000_0000
  -- round 4 : 0x1000_0000   : 0x2000_0000
  -- round 5 : 0x2000_0000   : 0x1000_0000
  -- round 6 : 0x4000_0000   : 0x0800_0000
  -- round 7 : 0x8000_0000   : 0x0400_0000
  -- round 8 : 0x1B00_0000   : 0x0200_0000
  -- round 9 : 0x3600_0000   : 0x0100_0000
  ---------------------------------------------------------------

  process (clock, load)
  begin
--
    if (load = '1') then
--
      fifo12x8 (095 downto 000) <= key_i (127 downto 032);
--
      side_opt (3)              <= key_i (031 downto 024);
      side_opt (2)              <= key_i (023 downto 016);
      side_opt (1)              <= key_i (015 downto 008);
      side_opt (0)              <= key_i (007 downto 000);
--
      addr_a_1_i                <= ( enc & key_i (023 downto 016) );
      addr_a_2_i                <= ( enc & key_i (015 downto 008) );
      addr_b_1_i                <= ( enc & key_i (007 downto 000) );
      addr_b_2_i                <= ( enc & key_i (031 downto 024) );
--
    elsif (clock = '1' and clock'event) then
--
      fifo12x8 (95 downto 32)   <= fifo12x8 (63 downto 00);
      fifo12x8 (31 downto 00)   <= side_opt (3) & side_opt (2) & side_opt (1) & side_opt (0);
--
      side_opt (3)              <= result(3);
      side_opt (2)              <= result(2);
      side_opt (1)              <= result(1);
      side_opt (0)              <= result(0);
--
      addr_a_1_i                <= ( enc & result (2) );
      addr_a_2_i                <= ( enc & result (1) );
      addr_b_1_i                <= ( enc & result (0) );
      addr_b_2_i                <= ( enc & result (3) );
--
    end if;
--
  end process;
--
  process (clock, load)
  begin
--
    if (load = '1') then
--
      rcon10x8 (79 downto 00)   <= round_constant (79 downto 00);
--
    elsif (clock = '1' and clock'event) then
--
      if (count = "10") then
--
        rcon10x8 (79 downto 08) <= rcon10x8 (71 downto 00);
        rcon10x8 (07 downto 00) <= rcon10x8 (79 downto 72);
--
      end if;
--
      done                      <= not(load) and count(1) and not(count(0)) and rcon(5) and rcon(4) and rcon(2) and rcon(1);
--
    end if;
--
  end process;

  rcon (07 downto 00)  <= rcon10x8 (79 downto 72);
--
  rot                  <= ( not(count(1)) and not(count(0)) ) when (load = '0') else '1';
--
  temp (3)             <= (do_a_1_o xor rcon)                 when (rot = '1')  else side_opt (3);
  temp (2)             <= (do_a_2_o)                          when (rot = '1')  else side_opt (2);
  temp (1)             <= (do_b_1_o)                          when (rot = '1')  else side_opt (1);
  temp (0)             <= (do_b_2_o)                          when (rot = '1')  else side_opt (0);
--
  result (3)           <= temp (3) xor fifo12x8 (95 downto 88);
  result (2)           <= temp (2) xor fifo12x8 (87 downto 80);
  result (1)           <= temp (1) xor fifo12x8 (79 downto 72);
  result (0)           <= temp (0) xor fifo12x8 (71 downto 64);
--
  key_o (31 downto 24) <= result(3);
  key_o (23 downto 16) <= result(2);
  key_o (15 downto 08) <= result(1);
  key_o (07 downto 00) <= result(0);

end key_expansion;
