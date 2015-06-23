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

package pkg_xilinx_prims is

  attribute INIT    : string;
  attribute INIT_00 : string;
  attribute INIT_01 : string;
  attribute INIT_02 : string;
  attribute INIT_03 : string;
  attribute INIT_04 : string;
  attribute INIT_05 : string;
  attribute INIT_06 : string;
  attribute INIT_07 : string;
  attribute INIT_08 : string;
  attribute INIT_09 : string;
  attribute INIT_0A : string;
  attribute INIT_0B : string;
  attribute INIT_0C : string;
  attribute INIT_0D : string;
  attribute INIT_0E : string;
  attribute INIT_0F : string;

  attribute RLOC   : string;
  attribute HU_SET : string;

  function str2slv (str : string) return std_logic_vector;


  component fd port (
      d : in std_logic; c : in std_logic; q : out std_logic );
  end component;

  component fde port (
      d  : in std_logic; c : in std_logic; ce : in std_logic; q : out std_logic );
  end component;

  component fdc port (
      d : in std_logic; c : in std_logic; clr : in std_logic; q : out std_logic );
  end component;

  component fdce port (
      d : in std_logic; c : in std_logic; clr : in std_logic; ce : in std_logic;
      q : out std_logic );
  end component;

  component fdpe port(
      d : in std_logic; c : in std_logic; pre : in std_logic; ce : in std_logic;
      q : out std_logic );
  end component;

  component ram16x1d
    port (
      a0, a1, a2, a3 : in std_logic;
      dpra0, dpra1, dpra2, dpra3 : in std_logic;
      wclk : in std_logic;
      we : in std_logic;
      d : in std_logic;
      spo : out std_logic;
      dpo : out std_logic
      );
  end component;

  component lut4
    --pragma translate_off
    generic (
      INIT : std_logic_vector (15 downto 0)
      );
    --pragma translate_on
    port (
      i0 : in std_logic;
      i1 : in std_logic;
      i2 : in std_logic;
      i3 : in std_logic;
      O  : out std_logic
      );
  end component;

  component mult_and
     port (
        i0 : in std_logic;
        i1 : in std_logic;
        lo : out std_logic
        );
  end component;

  component muxcy
     port (
        di : in std_logic;
        ci : in std_logic;
        s  : in std_logic;
        o  : out std_logic
        );
  end component;

  component xorcy
     port (
        li : in std_logic;
        ci : in std_logic;
        o  : out std_logic
        );
  end component;

  component muxf6
     port (
        o  : OUT std_logic;
        i0 : IN  std_logic;
        i1 : IN  std_logic;
        s  : IN  std_logic
        );
  end component;

  component muxf5
     port (
        o  : OUT std_logic;
        i0 : IN  std_logic;
        i1 : IN  std_logic;
        s  : IN  std_logic
        );
  end component;

  component ramb4_s2_s2
    --pragma translate_off
    generic (
      INIT_00 : std_logic_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_01 : std_logic_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_02 : std_logic_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_03 : std_logic_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_04 : std_logic_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_05 : std_logic_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_06 : std_logic_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_07 : std_logic_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_08 : std_logic_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_09 : std_logic_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_0A : std_logic_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_0B : std_logic_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_0C : std_logic_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_0D : std_logic_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_0E : std_logic_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_0F : std_logic_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000"
      );
    --pragma translate_on
    port (
      dob   : out std_logic_vector (1 downto 0);
      dib   : in  std_logic_vector (1 downto 0);
      addrb : in  std_logic_vector (10 downto 0);
      web   : in  std_logic;
      enb   : in  std_logic;
      rstb  : in  std_logic;
      clkb  : in  std_logic;

      doa   : out std_logic_vector (1 downto 0);
      dia   : in  std_logic_vector (1 downto 0);
      addra : in  std_logic_vector (10 downto 0);
      wea   : in  std_logic;
      ena   : in  std_logic;
      rsta  : in  std_logic;
      clka  : in  std_logic
      );
  end component;

end;

package body pkg_xilinx_prims is

  function str2slv (str : string) return std_logic_vector is
    variable result : std_logic_vector (str'length*4-1 downto 0);
  begin
    for i in 0 to str'length-1 loop
      case str(str'high-i) is
        when '0'       => result(i*4+3 downto i*4) := x"0";
        when '1'       => result(i*4+3 downto i*4) := x"1";
        when '2'       => result(i*4+3 downto i*4) := x"2";
        when '3'       => result(i*4+3 downto i*4) := x"3";
        when '4'       => result(i*4+3 downto i*4) := x"4";
        when '5'       => result(i*4+3 downto i*4) := x"5";
        when '6'       => result(i*4+3 downto i*4) := x"6";
        when '7'       => result(i*4+3 downto i*4) := x"7";
        when '8'       => result(i*4+3 downto i*4) := x"8";
        when '9'       => result(i*4+3 downto i*4) := x"9";
        when 'a' | 'A' => result(i*4+3 downto i*4) := x"A";
        when 'b' | 'B' => result(i*4+3 downto i*4) := x"B";
        when 'c' | 'C' => result(i*4+3 downto i*4) := x"C";
        when 'd' | 'D' => result(i*4+3 downto i*4) := x"D";
        when 'e' | 'E' => result(i*4+3 downto i*4) := x"E";
        when 'f' | 'F' => result(i*4+3 downto i*4) := x"F";
        when others => result(i*4+3 downto i*4) := "XXXX";
      end case;
    end loop;

    return result;
  end str2slv;

end;
