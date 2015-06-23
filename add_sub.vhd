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
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_arith.all;
  use ieee.std_logic_unsigned.all;

--
-- op <= A +/- B or A
--
entity ADD_SUB is
  generic (
    WIDTH         : in  natural := 8
    );
  port (
    A             : in  std_logic_vector(WIDTH-1 downto 0);
    B             : in  std_logic_vector(WIDTH-1 downto 0);

    ADD_OR_SUB    : in  std_logic; -- high for DOUT <= A +/- B, low for DOUT <= A
    DO_SUB        : in  std_logic; -- high for DOUT <= A   - B, low for DOUT <= A + B

    CARRY_OUT     : out std_logic_vector(WIDTH-1 downto 0);
    DOUT          : out std_logic_vector(WIDTH-1 downto 0)
    );
end;

use work.pkg_xilinx_prims.all;
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_arith.all;
  use ieee.std_logic_unsigned.all;

architecture VIRTEX of ADD_SUB is

    signal lut_op       : std_logic_vector(WIDTH-1 downto 0);
    signal mult_and_op  : std_logic_vector(WIDTH-1 downto 0);
    signal carry        : std_logic_vector(WIDTH   downto 0);
    signal op_int       : std_logic_vector(WIDTH-1 downto 0);

    function loc(i : integer) return integer is
    begin
      return (((WIDTH+1)/2)-1) - i/2;
    end loc;

begin
  carry(0) <= DO_SUB;
  INST : for i in 0 to WIDTH-1 generate
    attribute RLOC of u_lut  : label is "R" & integer'image(loc(i)) & "C0.S1";
    attribute RLOC of u_1    : label is "R" & integer'image(loc(i)) & "C0.S1";
    attribute RLOC of u_2    : label is "R" & integer'image(loc(i)) & "C0.S1";
    attribute RLOC of u_3    : label is "R" & integer'image(loc(i)) & "C0.S1";
    attribute INIT of u_lut  : label is "C66C";
    begin
      u_lut :  LUT4
      --pragma translate_off
      generic map (
        INIT => str2slv(u_lut'INIT)
        )
      --pragma translate_on
      port map (
        I0 => ADD_OR_SUB,
        I1 => A(i),
        I2 => B(i),
        I3 => DO_SUB,
        O  => lut_op(i)
        );

      u_1 : MULT_AND
      port map (
        I0 => ADD_OR_SUB,
        I1 => A(i),
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

  end generate;
  CARRY_OUT <= carry(WIDTH downto 1);
  DOUT <= op_int;
end Virtex;

--pragma translate_off

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_arith.all;
  use ieee.std_logic_unsigned.all;

architecture RTL of ADD_SUB is
  signal a_plus_b   : std_logic_vector(9 downto 0) := (others => '0');
  signal a_minus_b  : std_logic_vector(9 downto 0) := (others => '0');
begin -- architecture

  p_addsub_comb : process(A,B,a_plus_b,a_minus_b)
  begin
    a_plus_b(4 downto 0)  <= ('0' & A(3 downto 0)) + ('0' & B(3 downto 0));
    a_plus_b(9 downto 5)  <= ('0' & A(7 downto 4)) + ('0' & B(7 downto 4)) + ("0000" & a_plus_b(4));
    a_minus_b(4 downto 0) <= ('0' & A(3 downto 0)) - ('0' & B(3 downto 0));
    a_minus_b(9 downto 5) <= ('0' & A(7 downto 4)) - ('0' & B(7 downto 4)) - ("0000" & a_minus_b(4));
  end process;

  p_add_sub_comb : process(A,B,ADD_OR_SUB,DO_SUB,a_minus_b,a_plus_b)
  begin
    DOUT <= A;
    CARRY_OUT <= (others => '0');
    if (ADD_OR_SUB = '1') then
      if (DO_SUB = '1') then
        DOUT <= a_minus_b(8 downto 5) & a_minus_b(3 downto 0);
        CARRY_OUT(7) <= not a_minus_b(9);
        CARRY_OUT(3) <= not a_minus_b(4);
      else
        DOUT <= a_plus_b(8 downto 5) & a_plus_b(3 downto 0);
        CARRY_OUT(7) <=     a_plus_b(9);
        CARRY_OUT(3) <=     a_plus_b(4);
      end if;
    end if;
  end process;

end RTL;

--pragma translate_on

