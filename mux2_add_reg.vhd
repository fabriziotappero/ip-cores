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

-- MUX2_ADD_REG
--
-- DOUT <= REG_DOUT + ADD_VAL when ADD = '1'
--      <= LOAD_VAL           when ADD = '0'

-- REG_DOUT <= DOUT            when ENA = '1' and rising_edge(CLK)
--          <= (others => '1') when PRESET = '1'
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_arith.all;
  use ieee.std_logic_unsigned.all;

entity MUX2_ADD_REG is
  generic (
    WIDTH         : in  natural := 11
    );
  port (
    ADD_VAL       : in  std_logic_vector(WIDTH-1 downto 0);
    LOAD_VAL      : in  std_logic_vector(WIDTH-1 downto 0);

    ADD           : in  std_logic;

    PRESET        : in  std_logic; -- async
    ENA           : in  std_logic;
    CLK           : in  std_logic;

    DOUT          : out std_logic_vector(WIDTH-1 downto 0);
    REG_DOUT      : out std_logic_vector(WIDTH-1 downto 0)
    );
end;
--
-- USE THIS ARCHITECTURE FOR XILINX
--
use work.pkg_xilinx_prims.all;
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_arith.all;
  use ieee.std_logic_unsigned.all;

architecture VIRTEX of MUX2_ADD_REG is

    signal lut_op       : std_logic_vector(WIDTH-1 downto 0);
    signal mult_and_op  : std_logic_vector(WIDTH-1 downto 0);
    signal carry        : std_logic_vector(WIDTH   downto 0);
    signal op_int       : std_logic_vector(WIDTH-1 downto 0);
    signal reg_op_int   : std_logic_vector(WIDTH-1 downto 0);

    function loc(i : integer) return integer is
    begin
      return (((WIDTH+1)/2)-1) - i/2;
    end loc;

begin
  carry(0) <= '0';
  INST : for i in 0 to WIDTH-1 generate
    attribute RLOC of u_lut  : label is "R" & integer'image(loc(i)) & "C0.S1";
    attribute RLOC of u_1    : label is "R" & integer'image(loc(i)) & "C0.S1";
    attribute RLOC of u_2    : label is "R" & integer'image(loc(i)) & "C0.S1";
    attribute RLOC of u_3    : label is "R" & integer'image(loc(i)) & "C0.S1";
    attribute RLOC of u_reg  : label is "R" & integer'image(loc(i)) & "C0.S1";
    attribute INIT of u_lut  : label is "7D28";
    begin
      u_lut :  LUT4
      --pragma translate_off
      generic map (
        INIT => str2slv(u_lut'INIT)
        )
      --pragma translate_on
      port map (
        I0 => ADD,
        I1 => ADD_VAL(i),
        I2 => reg_op_int(i),
        I3 => LOAD_VAL(i),
        O  => lut_op(i)
        );

      u_1 : MULT_AND
      port map (
        I0 => ADD,
        I1 => ADD_VAL(i),
        LO => mult_and_op(i)
        );

      u_2 : MUXCY
      port map (
        DI => mult_and_op(i),
        CI => carry(i),
        S  => lut_op(i),
        O  => carry(i+1)
        );

      u_3 : XORCY
      port map (
        LI => lut_op(i),
        CI => carry(i),
        O  => op_int(i)
        );

      u_reg : FDPE
      port map (
        Q  => reg_op_int(i),
        D  => op_int(i),
        C  => CLK,
        CE => ENA,
        PRE=> PRESET
        );
  end generate;
  DOUT <= op_int;
  REG_DOUT <= reg_op_int;
end Virtex;

--pragma translate_off

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

architecture RTL of MUX2_ADD_REG is
signal op_int       : std_logic_vector(WIDTH-1 downto 0);
signal reg_op_int   : std_logic_vector(WIDTH-1 downto 0);
begin -- architecture

p_comb : process(ADD,reg_op_int,ADD_VAL,LOAD_VAL)
begin
if (ADD = '1') then
 op_int <= reg_op_int + ADD_VAL;
else
 op_int <= LOAD_VAL;
end if;
end process;

p_opreg : process(PRESET,CLK)
begin
if (PRESET = '1') then
 reg_op_int <= (others => '1');
elsif CLK'event and (CLK = '1') then
 if (ENA = '1') then
   reg_op_int <= op_int;
 end if;
end if;
end process;
DOUT <= op_int;
REG_DOUT <= reg_op_int;
end RTL;

--pragma translate_on

