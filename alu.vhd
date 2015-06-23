--
-- Risc5x
-- www.OpenCores.Org - November 2001
--
--
-- This library is free software; you can distribute it and/or modify it
-- under the terms of the GNU Lesser General Public License as published
-- by the Free Software Foundation; either version 2.1 of the License, or
-- (at your option) any later version.
--
-- This library is distributed in the hope that it will be useful, but
-- WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
-- See the GNU Lesser General Public License for more details.
--
-- A RISC CPU core.
--
-- (c) Mike Johnson 2001. All Rights Reserved.
-- mikej@opencores.org for support or any other issues.
--
-- Revision list
--
-- version 1.0 initial opencores release
--

use work.pkg_prims.all;
use work.pkg_risc5x.all;
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_arith.all;
  use ieee.std_logic_unsigned.all;

entity ALU is
  port (
    ADDSUB          : in  std_logic_vector(1 downto 0);
    BIT             : in  std_logic_vector(1 downto 0);
    SEL             : in  std_logic_vector(1 downto 0);

    A               : in  std_logic_vector(7 downto 0);
    B               : in  std_logic_vector(7 downto 0);
    Y               : out std_logic_vector(7 downto 0);
    CIN             : in  std_logic;
    COUT            : out std_logic;
    DCOUT           : out std_logic;
    ZOUT            : out std_logic
    );
end;

architecture RTL of ALU is

-- signal definitions
  signal add_sub_dout   : std_logic_vector(7 downto 0) := (others => '0');
  signal add_sub_result : std_logic_vector(8 downto 0) := (others => '0');
  signal alubit_dout    : std_logic_vector(7 downto 0) := (others => '0');
  signal alubit_result  : std_logic_vector(8 downto 0) := (others => '0');
  signal a_rol          : std_logic_vector(8 downto 0) := (others => '0');
  signal a_ror          : std_logic_vector(8 downto 0) := (others => '0');

  signal carry          : std_logic_vector(7 downto 0) := (others => '0');
  signal alu_result     : std_logic_vector(8 downto 0) := (others => '0');

begin -- architecture

  u_add_sub : ADD_SUB
    generic map (
      WIDTH         => 8
      )
    port map (
      A             => A,
      B             => B,

      ADD_OR_SUB    => ADDSUB(1),
      DO_SUB        => ADDSUB(0),

      CARRY_OUT     => carry,
      DOUT          => add_sub_dout
      );

  add_sub_result <= carry(7) & add_sub_dout(7 downto 0);
  a_ror  <= A(0) & CIN & A(7 downto 1);
  a_rol  <= A(7) & A(6 downto 0) & CIN;

  u_alubit : ALUBIT
    generic map (
      WIDTH         => 8
      )
    port map (
      A             => A,
      B             => B,
      OP            => BIT,

      DOUT          => alubit_dout
      );

  alubit_result <= '0' & alubit_dout;

  u_mux4 : MUX4
    generic map (
      WIDTH         => 9,
      SLICE         => 0,
      OP_REG        => FALSE
      )
    port map (
      DIN3          => a_rol,
      DIN2          => a_ror,
      DIN1          => alubit_result,
      DIN0          => add_sub_result,

      SEL           => SEL,
      ENA           => '0',
      CLK           => '0',

      DOUT          => alu_result
      );

  p_zout_comb : process(alu_result)
  begin
    ZOUT <= '0';
    if (alu_result(7 downto 0) = "00000000") then ZOUT <= '1'; end if;
  end process;

  COUT   <=     alu_result(8);
  DCOUT  <=     carry(3);
  Y      <=     alu_result(7 downto 0);
end rtl;

