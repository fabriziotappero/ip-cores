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

entity MUX4 is
  generic (
    WIDTH         : in  natural := 8;
    SLICE         : in  natural := 1; -- 1 left, 0 right
    OP_REG        : in  boolean := FALSE
    );
  port (
    DIN3          : in  std_logic_vector(WIDTH-1 downto 0);
    DIN2          : in  std_logic_vector(WIDTH-1 downto 0);
    DIN1          : in  std_logic_vector(WIDTH-1 downto 0);
    DIN0          : in  std_logic_vector(WIDTH-1 downto 0);

    SEL           : in  std_logic_vector(1 downto 0);
    ENA           : in  std_logic;
    CLK           : in  std_logic;

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

architecture VIRTEX of MUX4 is

  signal dout_int : std_logic_vector(WIDTH-1 downto 0);
  signal mux8_01  : std_logic_vector(WIDTH-1 downto 0);
  signal mux8_23  : std_logic_vector(WIDTH-1 downto 0);

begin -- architecture

  ram_bit : for i in 0 to WIDTH-1 generate
  attribute RLOC of mux8_lut1,mux8_lut2 : label is "R" & integer'image((WIDTH -1)-i) & "C0.S" & integer'image(SLICE);
  attribute RLOC of mux8_muxf5_1 : label is "R" & integer'image((WIDTH -1)-i) & "C0.S" & integer'image(SLICE);

  attribute INIT  of mux8_lut1 : label is "00CA";
  attribute INIT  of mux8_lut2 : label is "00CA";
  begin

    mux8_lut1:  LUT4
      --pragma translate_off
      generic map (
        INIT => str2slv(mux8_lut1'INIT)
        )
      --pragma translate_on
      port map (
        I0 => DIN0(i),
        I1 => DIN1(i),
        I2 => SEL(0),
        I3 => '0',
        O  => mux8_01(i));

    mux8_lut2:  LUT4
      --pragma translate_off
      generic map (
        INIT => str2slv(mux8_lut2'INIT)
        )
      --pragma translate_on
      port map (
        I0 => DIN2(i),
        I1 => DIN3(i),
        I2 => SEL(0),
        I3 => '0',
        O  => mux8_23(i));

    mux8_muxf5_1 : MUXF5
       port map (
          O  => dout_int(i),
          I0 => mux8_01(i),
          I1 => mux8_23(i),
          S  => SEL(1));

    opreg : if OP_REG generate
    attribute RLOC of reg : label is "R" & integer'image((WIDTH -1)-i) & "C0.S" & integer'image(SLICE);
    begin
     reg : FDE
       port map (
          D  => dout_int(i),
          C  => CLK,
          CE => ENA,
          Q  => DOUT(i));
    end generate;

    opwire : if not OP_REG generate
      DOUT(i) <= dout_int(i);
    end generate;

  end generate;

end VIRTEX;

--pragma translate_off

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_arith.all;
  use ieee.std_logic_unsigned.all;

architecture RTL of MUX4 is
  signal mux : std_logic_vector(WIDTH-1 downto 0);
begin -- architecture

  p_mux_comb : process(DIN0,DIN1,DIN2,DIN3,SEL)
    variable ram_addr : integer := 0;
  begin
    mux <= DIN0;
    case SEL is
      when "00" => mux <= DIN0;
      when "01" => mux <= DIN1;
      when "10" => mux <= DIN2;
      when "11" => mux <= DIN3;
      when others => null;
    end case;

  end process;

  opreg : if OP_REG generate
    p_opreg : process
    begin
      wait until CLK'event and (CLK = '1');
      if (ENA = '1') then
        DOUT <= mux;
      end if;
    end process;
  end generate;

  opwire : if not OP_REG generate
    DOUT <= mux;
  end generate;

end RTL;

--pragma translate_on
