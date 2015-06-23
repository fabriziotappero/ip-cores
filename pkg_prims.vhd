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

package pkg_prims is

  component MUX8
    generic (
      WIDTH         : in  natural;
      OP_REG        : in  boolean
      );
    port (
      DIN7          : in  std_logic_vector(WIDTH-1 downto 0);
      DIN6          : in  std_logic_vector(WIDTH-1 downto 0);
      DIN5          : in  std_logic_vector(WIDTH-1 downto 0);
      DIN4          : in  std_logic_vector(WIDTH-1 downto 0);
      DIN3          : in  std_logic_vector(WIDTH-1 downto 0);
      DIN2          : in  std_logic_vector(WIDTH-1 downto 0);
      DIN1          : in  std_logic_vector(WIDTH-1 downto 0);
      DIN0          : in  std_logic_vector(WIDTH-1 downto 0);

      SEL           : in  std_logic_vector(2 downto 0);
      ENA           : in  std_logic;
      CLK           : in  std_logic;

      DOUT          : out std_logic_vector(WIDTH-1 downto 0)
      );
  end component;

  component MUX4
    generic (
      WIDTH         : in  natural;
      SLICE         : in  natural;
      OP_REG        : in  boolean
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
  end component;

  component MUX2
    generic (
      WIDTH         : in  natural;
      SLICE         : in  natural;
      OP_REG        : in  boolean
      );
    port (
      DIN1          : in  std_logic_vector(WIDTH-1 downto 0);
      DIN0          : in  std_logic_vector(WIDTH-1 downto 0);

      SEL           : in  std_logic;
      ENA           : in  std_logic;
      CLK           : in  std_logic;

      DOUT          : out std_logic_vector(WIDTH-1 downto 0)
      );
  end component;

  component MUX2_ADD_REG
    generic (
      WIDTH         : in  natural
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
  end component;

  component ADD_SUB
    generic (
      WIDTH         : in  natural
      );
    port (
      A             : in  std_logic_vector(WIDTH-1 downto 0);
      B             : in  std_logic_vector(WIDTH-1 downto 0);

      ADD_OR_SUB    : in  std_logic; -- high for DOUT <= A +/- B, low for DOUT <= A
      DO_SUB        : in  std_logic; -- high for DOUT <= A   - B, low for DOUT <= A + B

      CARRY_OUT     : out std_logic_vector(WIDTH-1 downto 0);
      DOUT          : out std_logic_vector(WIDTH-1 downto 0)
      );
  end component;

  component ALUBIT
    generic (
      WIDTH         : in  natural
      );
    port (
      A             : in  std_logic_vector(WIDTH-1 downto 0);
      B             : in  std_logic_vector(WIDTH-1 downto 0);
      OP            : in  std_logic_vector(1 downto 0);

      DOUT          : out std_logic_vector(WIDTH-1 downto 0)
      );
  end component;

end;
