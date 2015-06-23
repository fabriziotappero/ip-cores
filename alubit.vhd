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

entity ALUBIT is
  generic (
    WIDTH         : in  natural := 8
    );
  port (
    A             : in  std_logic_vector(WIDTH-1 downto 0);
    B             : in  std_logic_vector(WIDTH-1 downto 0);
    OP            : in  std_logic_vector(1 downto 0);

    DOUT          : out std_logic_vector(WIDTH-1 downto 0)
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

architecture VIRTEX of ALUBIT is
  function loc(i : integer) return integer is
  begin
    return (((WIDTH+1)/2)-1) - i/2;
  end loc;

begin -- architecture

  ram_bit : for i in 0 to WIDTH-1 generate

  attribute RLOC of u_lut  : label is "R" & integer'image(loc(i)) & "C0.S1";
  attribute INIT of u_lut : label is "56E8";
  begin

    u_lut:  LUT4
      --pragma translate_off
      generic map (
        INIT => str2slv(u_lut'INIT)
        )
      --pragma translate_on
      port map (
        I0 => A(i),
        I1 => B(i),
        I2 => OP(0),
        I3 => OP(1),
        O  => DOUT(i));

  end generate;

end VIRTEX;

--pragma translate_off

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_arith.all;
  use ieee.std_logic_unsigned.all;

architecture RTL of ALUBIT is

begin -- architecture

  p_bit_comb : process(A,B,OP)
  begin
    DOUT <= (others => '0');
    case OP is
      when "00" => DOUT <= (A and B);
      when "01" => DOUT <= (A  or B);
      when "10" => DOUT <= (A xor B);
      when "11" => DOUT <= (  not A);
      when others => null;
    end case;
  end process;

end RTL;

--pragma translate_on

