



----------------------------------------------------------------------------
--  This file is a part of the LEON VHDL model
--  Copyright (C) 1999  European Space Agency (ESA)
--
--  This library is free software; you can redistribute it and/or
--  modify it under the terms of the GNU Lesser General Public
--  License as published by the Free Software Foundation; either
--  version 2 of the License, or (at your option) any later version.
--
--  See the file COPYING.LGPL for the full details of the license.


-----------------------------------------------------------------------------
-- Entity: 	tech_fs90
-- File:	tech_fs90.vhd
-- Author:	Jiri Gaisler - Gaisler Research
-- Description:	Contains UMC (Farraday Technology) FS90A/B specific pads and
--	        ram generators
------------------------------------------------------------------------------

LIBRARY ieee;
use IEEE.std_logic_1164.all;
use work.leon_iface.all;

package tech_fs90 is

-- sync ram generator

  component fs90_syncram
  generic ( abits : integer := 10; dbits : integer := 8 );
  port (
    address  : in std_logic_vector(abits -1 downto 0);
    clk      : in std_logic;
    datain   : in std_logic_vector(dbits -1 downto 0);
    dataout  : out std_logic_vector(dbits -1 downto 0);
    enable   : in std_logic;
    write    : in std_logic);
  end component;

-- regfile generator

  component fs90_regfile
  generic ( abits : integer := 8; dbits : integer := 32; words : integer := 128);
  port (
    rst      : in std_logic;
    clk      : in clk_type;
    clkn     : in clk_type;
    rfi      : in rf_in_type;
    rfo      : out rf_out_type);
  end component;

-- pads

  component fs90_inpad 
    port (pad : in std_logic; q : out std_logic); end component; 
  component fs90_smpad 
    port (pad : in std_logic; q : out std_logic); 
  end component;
  component fs90_outpad
    generic (drive : integer := 1);
    port (d : in  std_logic; pad : out  std_logic);
  end component; 
  component fs90_toutpadu
    generic (drive : integer := 1);
    port (d, en : in  std_logic; pad : out  std_logic);
  end component; 
  component fs90_iopad 
    generic (drive : integer := 1);
    port ( d, en : in std_logic; q : out std_logic; pad : inout std_logic);
  end component;
  component fs90_smiopad 
    generic (drive : integer := 1);
    port ( d, en : in std_logic; q : out std_logic; pad : inout std_logic);
  end component;
  component fs90_iopadu 
    generic (drive : integer := 1);
    port ( d, en : in std_logic; q : out std_logic; pad : inout std_logic);
  end component;
  component fs90_iodpad 
    generic (drive : integer := 1);
    port ( d : in std_logic; q : out std_logic; pad : inout std_logic);
  end component;
  component fs90_odpad 
    generic (drive : integer := 1);
    port ( d : in std_logic; pad : out std_logic);
  end component;

end;

------------------------------------------------------------------
-- behavioural pad models --------------------------------------------
------------------------------------------------------------------
-- Only needed for simulation, not synthesis.
-- pragma translate_off

-- input pad
library IEEE;
use IEEE.std_logic_1164.all;
entity uyfaa is port (
  o   : out std_logic; 
  i   : in std_logic;
  pu  : in std_logic; 
  pd  : in std_logic; 
  smt : in std_logic); 
end; 
architecture rtl of uyfaa is 
signal inode : std_logic;
begin 
  inode <= to_x01(i) after 1 ns;
  inode <= 'H' when pu = '1' else 'L' when pd = '1' else 'Z';
  o <= to_x01(inode);
end;

-- output pad
library IEEE;
use IEEE.std_logic_1164.all;
entity vyfa2gsa is port (
  o   : out  std_logic;
  i   : in  std_logic;
  e   : in  std_logic;
  e2  : in  std_logic;
  e4  : in  std_logic;
  e8  : in  std_logic;
  sr  : in  std_logic);
end; 
architecture rtl of vyfa2gsa is begin 
  o <= to_x01(i) after 2 ns when e = '1' else 'Z' after 2 ns;
end;

-- bidirectional pad
library IEEE;
use IEEE.std_logic_1164.all;
entity wyfa2gsa is port (
  o   : out  std_logic;
  i   : in  std_logic;
  io  : inout  std_logic;
  e   : in  std_logic;
  e2  : in  std_logic;
  e4  : in  std_logic;
  e8  : in  std_logic;
  sr  : in  std_logic;
  pu  : in std_logic; 
  pd  : in std_logic; 
  smt : in std_logic); 
end; 
architecture rtl of wyfa2gsa is begin 
  io <= to_x01(i) after 2 ns when e = '1' else 'Z' after 2 ns;
  io <= 'H' when pu = '1' else 'L' when pd = '1' else 'Z';
  o <= to_x01(io);
end;

------------------------------------------------------------------
-- behavioural ram models ----------------------------------------
------------------------------------------------------------------
-- synchronous ram 
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use work.leon_iface.all;

entity fs90_syncram_sim is
  generic ( abits : integer := 10; dbits : integer := 8 );
  port (
    address  : in std_logic_vector((abits -1) downto 0);
    clk      : in std_logic;
    datain   : in std_logic_vector((dbits -1) downto 0);
    dataout  : out std_logic_vector((dbits -1) downto 0);
    cselect  : in std_logic;
    oenable  : in std_logic;
    write    : in std_logic
  ); 
end;     

architecture behavioral of fs90_syncram_sim is
  type mem is array(0 to (2**abits -1)) 
	of std_logic_vector((dbits -1) downto 0);
  signal memarr : mem;
begin
  main : process(clk, memarr)
  variable do  : std_logic_vector((dbits -1) downto 0);
  begin
    if rising_edge(clk) then
      do := (others => 'X');
      if cselect = '1' then
        if (write = '0') and not is_x(address) then
          memarr(conv_integer(unsigned(address))) <= datain;
        end if;
        if (write = '1') and not is_x(address) then
	  do := memarr(conv_integer(unsigned(address)));
        end if;
      end if;
      if oenable = '1' then dataout <= do; else dataout <= (others => 'Z'); end if;
    end if;
  end process;
end;

--  2-port ram
LIBRARY ieee;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;

entity fs90_dpram_ss is
  generic (
    abits : integer := 8;
    dbits : integer := 32;
    words : integer := 256
  );
  port (
    data: in std_logic_vector (dbits -1 downto 0);
    rdaddress: in std_logic_vector (abits -1 downto 0);
    wraddress: in std_logic_vector (abits -1 downto 0);
    wren : in std_logic;
    clka, clkb : in std_logic;
    sela, selb : in std_logic;
    oe : in std_logic;
    q: out std_logic_vector (dbits -1 downto 0)
  );
end;

architecture behav of fs90_dpram_ss is
  type mem is array(0 to (2**abits -1)) 
	of std_logic_vector((dbits -1) downto 0);
  signal memarr : mem;
begin
  main : process(clka, clkb, memarr)
  variable do  : std_logic_vector((dbits -1) downto 0);
  begin
    if rising_edge(clka) then
      do := (others => 'X');
      if sela = '1' then
        if ((wren = '1') or (rdaddress /= wraddress)) and not is_x(rdaddress)
	then do := memarr(conv_integer(unsigned(rdaddress))); end if;
      end if;
      if oe = '1' then q <= do; else q <= (others => 'Z'); end if;
    end if;
    if rising_edge(clkb) then
      if (selb = '1') and (wren = '0') and not is_x(wraddress) then
        memarr(conv_integer(unsigned(wraddress))) <= data;
      end if;
    end if;
  end process;
end;

LIBRARY ieee;
use IEEE.std_logic_1164.all;
package tech_fs90_sim is

component fs90_syncram_sim
  generic ( abits : integer := 10; dbits : integer := 8 );
  port (
    address  : in std_logic_vector((abits -1) downto 0);
    clk      : in std_logic;
    datain   : in std_logic_vector((dbits -1) downto 0);
    dataout  : out std_logic_vector((dbits -1) downto 0);
    cselect  : in std_logic;
    oenable  : in std_logic;
    write    : in std_logic
  ); 
end component;

component fs90_dpram_ss
  generic (
    abits : integer := 8;
    dbits : integer := 32;
    words : integer := 256
  );
  port (
    data: in std_logic_vector (dbits -1 downto 0);
    rdaddress: in std_logic_vector (abits -1 downto 0);
    wraddress: in std_logic_vector (abits -1 downto 0);
    wren : in std_logic;
    clka, clkb : in std_logic;
    sela, selb : in std_logic;
    oe : in std_logic;
    q: out std_logic_vector (dbits -1 downto 0)
  );
end component;

end;

-- Syncronous SRAM
-- Address, control and data signals latched on rising CK. 
-- Write enable (WEB) active low.

library ieee;
use IEEE.std_logic_1164.all;
use work.tech_fs90_sim.all;

entity SA108019 is	-- 128x25
   port (A0, A1, A2, A3, A4, A5, A6, DI0, DI1, DI2, DI3, DI4, DI5, 
         DI6, DI7, DI8, DI9, DI10, DI11, DI12, DI13, DI14, DI15, DI16, 
         DI17, DI18, DI19, DI20, DI21, DI22, DI23, DI24, CK, CS, OE, 
         WEB : in std_logic;
         DO0, DO1, DO2, DO3, DO4, DO5, DO6, DO7, DO8, DO9, DO10,
         DO11, DO12, DO13, DO14, DO15, DO16, DO17, DO18, DO19, DO20, DO21,
         DO22, DO23, DO24: out std_logic
        );
end;

architecture behavioral of SA108019 is
signal din, dout : std_logic_vector(24 downto 0);
signal addr : std_logic_vector(6 downto 0);
begin
  addr <= a6&a5&a4&a3&a2&a1&a0;
  din  <= di24&di23&di22&di21&di20&di19&di18&di17&di16&di15&di14&di13&di12&
          di11&di10&di9&di8&di7&di6&di5&di4&di3&di2&di1&di0;
  do24 <= dout(24); do23 <= dout(23); do22 <= dout(22); do21 <= dout(21);
  do20 <= dout(20); do19 <= dout(19); do18 <= dout(18); do17 <= dout(17);
  do16 <= dout(16); do15 <= dout(15); do14 <= dout(14); do13 <= dout(13);
  do12 <= dout(12); do11 <= dout(11); do10 <= dout(10); do9 <= dout(9);
  do8 <= dout(8); do7 <= dout(7); do6 <= dout(6); do5 <= dout(5);
  do4 <= dout(4); do3 <= dout(3); do2 <= dout(2); do1 <= dout(1);
  do0 <= dout(0);
  syncram0 : fs90_syncram_sim generic map ( abits => 7, dbits => 25)
    port map ( addr, ck, din, dout, cs, oe, web);
end behavioral;

library ieee;
use IEEE.std_logic_1164.all;
use work.tech_fs90_sim.all;

entity SU004020 is -- 512x32
   port (A0, A1, A2, A3, A4, A5, A6, A7, A8, DI0, DI1, DI2, DI3, DI4, DI5, 
         DI6, DI7, DI8, DI9, DI10, DI11, DI12, DI13, DI14, DI15, DI16, 
         DI17, DI18, DI19, DI20, DI21, DI22, DI23, DI24, DI25, DI26, DI27,
	 DI28, DI29, DI30, DI31, CK, CS, OE, WEB : in std_logic;
         DO0, DO1, DO2, DO3, DO4, DO5, DO6, DO7, DO8, DO9, DO10,
         DO11, DO12, DO13, DO14, DO15, DO16, DO17, DO18, DO19, DO20, DO21,
         DO22, DO23, DO24, DO25, DO26, DO27, DO28, DO29, DO30, DO31: out std_logic
        );
end;

architecture behavioral of SU004020 is
signal din, dout : std_logic_vector(31 downto 0);
signal addr : std_logic_vector(8 downto 0);
begin
  addr <= a8&a7&a6&a5&a4&a3&a2&a1&a0;
  din  <= di31&di30&di29&di28&di27&di26&di25&di24&di23&di22&di21&di20&di19&
          di18&di17&di16&di15&di14&di13&di12&di11&di10&di9&di8&di7&di6&di5&
          di4&di3&di2&di1&di0;
  do31 <= dout(31); do30 <= dout(30); do29 <= dout(29); do28 <= dout(28);
  do27 <= dout(27); do26 <= dout(26); do25 <= dout(25); do24 <= dout(24);
  do23 <= dout(23); do22 <= dout(22); do21 <= dout(21); do20 <= dout(20);
  do19 <= dout(19); do18 <= dout(18); do17 <= dout(17); do16 <= dout(16);
  do15 <= dout(15); do14 <= dout(14); do13 <= dout(13); do12 <= dout(12);
  do11 <= dout(11); do10 <= dout(10); do9 <= dout(9); do8 <= dout(8);
  do7 <= dout(7); do6 <= dout(6); do5 <= dout(5); do4 <= dout(4);
  do3 <= dout(3); do2 <= dout(2); do1 <= dout(1); do0 <= dout(0);
  syncram0 : fs90_syncram_sim generic map ( abits => 9, dbits => 32)
    port map ( addr, ck, din, dout, cs, oe, web);
end behavioral;


library ieee;
use IEEE.std_logic_1164.all;
use work.tech_fs90_sim.all;
entity SW204420 is
   port (A0, A1, A2, A3, A4, A5, A6, A7, B0, B1, B2, B3, B4, B5, B6,
         B7, DI0, DI1, DI2, DI3, DI4, DI5, DI6, DI7, DI8, DI9, DI10,
         DI11, DI12, DI13, DI14, DI15, DI16, DI17, DI18, DI19, DI20, DI21,
         DI22, DI23, DI24, DI25, DI26, DI27, DI28, DI29, DI30, DI31,
         CKA, CKB, CSA, CSB, OE,
         WEB : in std_logic;
         DO0, DO1, DO2, DO3, DO4, DO5, DO6, DO7, DO8, DO9, DO10,
         DO11, DO12, DO13, DO14, DO15, DO16, DO17, DO18, DO19, DO20, DO21,
         DO22, DO23, DO24, DO25, DO26, DO27, DO28, DO29, DO30, DO31: out std_logic
        );
end;
architecture behavioral of SW204420 is
signal din, dout : std_logic_vector(31 downto 0);
signal addra, addrb : std_logic_vector(7 downto 0);
begin
  addra <= a7&a6&a5&a4&a3&a2&a1&a0;
  addrb <= b7&b6&b5&b4&b3&b2&b1&b0;
  din  <= di31&di30&di29&di28&di27&di26&di25&di24&di23&di22&di21&di20&di19&
          di18&di17&di16&di15&di14&di13&di12&di11&di10&di9&di8&di7&di6&di5&
          di4&di3&di2&di1&di0;
  do31 <= dout(31); do30 <= dout(30); do29 <= dout(29); do28 <= dout(28);
  do27 <= dout(27); do26 <= dout(26); do25 <= dout(25); do24 <= dout(24);
  do23 <= dout(23); do22 <= dout(22); do21 <= dout(21); do20 <= dout(20);
  do19 <= dout(19); do18 <= dout(18); do17 <= dout(17); do16 <= dout(16);
  do15 <= dout(15); do14 <= dout(14); do13 <= dout(13); do12 <= dout(12);
  do11 <= dout(11); do10 <= dout(10); do9 <= dout(9); do8 <= dout(8);
  do7 <= dout(7); do6 <= dout(6); do5 <= dout(5); do4 <= dout(4);
  do3 <= dout(3); do2 <= dout(2); do1 <= dout(1); do0 <= dout(0);
  dpram0 : fs90_dpram_ss generic map ( abits => 8, dbits => 32)
    port map ( din, addra, addrb, web, cka, ckb, csa, csb, oe, dout);
end;

-- pragma translate_on

-- component declarations from true tech library
LIBRARY ieee;
use IEEE.std_logic_1164.all;
package tech_fs90_syn is
-- 128x25 sync ram
component SA108019
   port (A0, A1, A2, A3, A4, A5, A6, DI0, DI1, DI2, DI3, DI4, DI5, 
         DI6, DI7, DI8, DI9, DI10, DI11, DI12, DI13, DI14, DI15, DI16, 
         DI17, DI18, DI19, DI20, DI21, DI22, DI23, DI24, CK, CS, OE, 
         WEB : in std_logic;
         DO0, DO1, DO2, DO3, DO4, DO5, DO6, DO7, DO8, DO9, DO10,
         DO11, DO12, DO13, DO14, DO15, DO16, DO17, DO18, DO19, DO20, DO21,
         DO22, DO23, DO24: out std_logic
        );
end component;
-- 512x32 sync ram
component SU004020
   port (A0, A1, A2, A3, A4, A5, A6, A7, A8, DI0, DI1, DI2, DI3, DI4, DI5, 
         DI6, DI7, DI8, DI9, DI10, DI11, DI12, DI13, DI14, DI15, DI16, 
         DI17, DI18, DI19, DI20, DI21, DI22, DI23, DI24, DI25, DI26, DI27,
	 DI28, DI29, DI30, DI31, CK, CS, OE, WEB : in std_logic;
         DO0, DO1, DO2, DO3, DO4, DO5, DO6, DO7, DO8, DO9, DO10,
         DO11, DO12, DO13, DO14, DO15, DO16, DO17, DO18, DO19, DO20, DO21,
         DO22, DO23, DO24, DO25, DO26, DO27, DO28, DO29, DO30, DO31: out std_logic
        );
end component;
-- 2-port sync ram
component SW204420
   port (A0, A1, A2, A3, A4, A5, A6, A7, B0, B1, B2, B3, B4, B5, B6,
         B7, DI0, DI1, DI2, DI3, DI4, DI5, DI6, DI7, DI8, DI9, DI10,
         DI11, DI12, DI13, DI14, DI15, DI16, DI17, DI18, DI19, DI20, DI21,
         DI22, DI23, DI24, DI25, DI26, DI27, DI28, DI29, DI30, DI31,
         CKA, CKB, CSA, CSB, OE,
         WEB : in std_logic;
         DO0, DO1, DO2, DO3, DO4, DO5, DO6, DO7, DO8, DO9, DO10,
         DO11, DO12, DO13, DO14, DO15, DO16, DO17, DO18, DO19, DO20, DO21,
         DO22, DO23, DO24, DO25, DO26, DO27, DO28, DO29, DO30, DO31: out std_logic
        );
end component;

-- in-pad
component uyfaa port (
  o   : out std_logic; 
  i   : in std_logic;
  pu  : in std_logic; 
  pd  : in std_logic; 
  smt : in std_logic); 
end component; 
-- out-pad
component vyfa2gsa port (
  o   : out  std_logic;
  i   : in  std_logic;
  e   : in  std_logic;
  e2  : in  std_logic;
  e4  : in  std_logic;
  e8  : in  std_logic;
  sr  : in  std_logic);
end component;
-- io-pad
component wyfa2gsa port (
  o   : out  std_logic;
  i   : in  std_logic;
  io  : inout  std_logic;
  e   : in  std_logic;
  e2  : in  std_logic;
  e4  : in  std_logic;
  e8  : in  std_logic;
  sr  : in  std_logic;
  pu  : in std_logic; 
  pd  : in std_logic; 
  smt : in std_logic); 
end component;

end;

------------------------------------------------------------------
-- sync ram generator --------------------------------------------
------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use work.tech_fs90_syn.all;

entity fs90_syncram is
  generic ( abits : integer := 10; dbits : integer := 8 );
  port (
    address  : in std_logic_vector(abits -1 downto 0);
    clk      : in std_logic;
    datain   : in std_logic_vector(dbits -1 downto 0);
    dataout  : out std_logic_vector(dbits -1 downto 0);
    enable  : in std_logic;
    write    : in std_logic
  );
end;

architecture rtl of fs90_syncram is
  signal wr   : std_logic;
  signal a    : std_logic_vector(19 downto 0);
  signal d, o : std_logic_vector(34 downto 0);
  constant synopsys_bug : std_logic_vector(37 downto 0) := (others => '0');
  signal we, vcc : std_logic;
begin

  vcc <= '1';
  wr <= not write; 
  a(abits -1 downto 0) <= address; 
  a(abits+1 downto abits) <= synopsys_bug(abits+1 downto abits);
  d(dbits -1 downto 0) <= datain; 
  d(dbits+1 downto dbits) <= synopsys_bug(dbits+1 downto dbits);

  dataout <= o(dbits -1 downto 0);

  a7d25 : if (abits <= 7) and (dbits <= 25) generate
    id0 : SA108019 port map (
      a(0), a(1), a(2), a(3), a(4), a(5), a(6),
      d(0), d(1), d(2), d(3), d(4), d(5), d(6), d(7), d(8),
      d(9), d(10), d(11), d(12), d(13), d(14), d(15), d(16),
      d(17), d(18), d(19), d(20), d(21), d(22), d(23), d(24),
      clk, enable, vcc, wr,
      o(0), o(1), o(2), o(3), o(4), o(5), o(6), o(7), o(8),
      o(9), o(10), o(11), o(12), o(13), o(14), o(15), o(16),
      o(17), o(18), o(19), o(20), o(21), o(22), o(23), o(24));
  end generate;
  a9d32 : if (abits = 9) and (dbits = 32) generate
    id0 : SU004020 port map (
      a(0), a(1), a(2), a(3), a(4), a(5), a(6), a(7), a(8),
      d(0), d(1), d(2), d(3), d(4), d(5), d(6), d(7), d(8),
      d(9), d(10), d(11), d(12), d(13), d(14), d(15), d(16),
      d(17), d(18), d(19), d(20), d(21), d(22), d(23), d(24),
      d(25), d(26), d(27), d(28), d(29), d(30), d(31),
      clk, enable, vcc, wr,
      o(0), o(1), o(2), o(3), o(4), o(5), o(6), o(7), o(8),
      o(9), o(10), o(11), o(12), o(13), o(14), o(15), o(16),
      o(17), o(18), o(19), o(20), o(21), o(22), o(23), o(24),
      o(25), o(26), o(27), o(28), o(29), o(30), o(31));
  end generate;
end rtl;

------------------------------------------------------------------
-- regfile generator  --------------------------------------------
------------------------------------------------------------------

LIBRARY ieee;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use work.leon_config.all;
use work.leon_iface.all;
use work.tech_fs90_syn.all;

entity fs90_regfile is
  generic ( 
    abits : integer := 8;
    dbits : integer := 32;
    words : integer := 128
  );
  port (
    rst      : in std_logic;
    clk      : in clk_type;
    clkn     : in clk_type;
    rfi      : in rf_in_type;
    rfo      : out rf_out_type);
end;

architecture rtl of fs90_regfile is
signal d, q1, q2 : std_logic_vector(39 downto 0);
signal vcc, wen : std_logic;
signal ra1, ra2, wa : std_logic_vector(12 downto 0);
begin
  wen <= not rfi.wren; vcc <= '1';
  ra1(abits-1 downto 0) <= rfi.rd1addr;
  ra1(12 downto abits) <= (others => '0');
  ra2(abits-1 downto 0) <= rfi.rd2addr;
  ra2(12 downto abits) <= (others => '0');
  wa(abits-1 downto 0) <= rfi.wraddr;
  wa(12 downto abits) <= (others => '0');
  rfo.data1 <= q1(dbits-1 downto 0);
  rfo.data2 <= q2(dbits-1 downto 0);
  d(RDBITS-1 downto 0) <= rfi.wrdata;

  dp136x32 : if (words = 136) and (dbits = 32) generate
    u0: SW204420 port map (
      ra1(0), ra1(1), ra1(2), ra1(3), ra1(4), ra1(5), ra1(6), ra1(7),
      wa(0), wa(1), wa(2), wa(3), wa(4), wa(5), wa(6), wa(7),
      d(0), d(1), d(2), d(3), d(4), d(5), d(6), d(7), d(8),
      d(9), d(10), d(11), d(12), d(13), d(14), d(15), d(16),
      d(17), d(18), d(19), d(20), d(21), d(22), d(23), d(24),
      d(25), d(26), d(27), d(28), d(29), d(30), d(31),

      clkn, clkn, rfi.ren1, rfi.wren, vcc, wen,

      q1(0), q1(1), q1(2), q1(3), q1(4), q1(5), q1(6), q1(7), q1(8),
      q1(9), q1(10), q1(11), q1(12), q1(13), q1(14), q1(15), q1(16),
      q1(17), q1(18), q1(19), q1(20), q1(21), q1(22), q1(23), q1(24),
      q1(25), q1(26), q1(27), q1(28), q1(29), q1(30), q1(31));
    u1: SW204420 port map (
      ra2(0), ra2(1), ra2(2), ra2(3), ra2(4), ra2(5), ra2(6), ra2(7),
      wa(0), wa(1), wa(2), wa(3), wa(4), wa(5), wa(6), wa(7),
      d(0), d(1), d(2), d(3), d(4), d(5), d(6), d(7), d(8),
      d(9), d(10), d(11), d(12), d(13), d(14), d(15), d(16),
      d(17), d(18), d(19), d(20), d(21), d(22), d(23), d(24),
      d(25), d(26), d(27), d(28), d(29), d(30), d(31),

      clkn, clkn, rfi.ren2, rfi.wren, vcc, wen,

      q2(0), q2(1), q2(2), q2(3), q2(4), q2(5), q2(6), q2(7), q2(8),
      q2(9), q2(10), q2(11), q2(12), q2(13), q2(14), q2(15), q2(16),
      q2(17), q2(18), q2(19), q2(20), q2(21), q2(22), q2(23), q2(24),
      q2(25), q2(26), q2(27), q2(28), q2(29), q2(30), q2(31));
  end generate;

end;

------------------------------------------------------------------
-- mapping generic pads on tech pads ---------------------------------
------------------------------------------------------------------

-- input pad
library IEEE;
use IEEE.std_logic_1164.all;
use work.tech_fs90_syn.all;
entity fs90_inpad is 
  port (pad : in std_logic; q : out std_logic);
end; 
architecture syn of fs90_inpad is 
signal gnd : std_logic;
begin 
  gnd <= '0';
  i0 : uyfaa port map (q, pad, gnd, gnd, gnd);
end;

-- input schmitt pad
library IEEE;
use IEEE.std_logic_1164.all;
use work.tech_fs90_syn.all;
entity fs90_smpad is port (pad : in std_logic; q : out std_logic); end; 
architecture syn of fs90_smpad is 
signal gnd, vcc : std_logic;
begin 
  gnd <= '0'; vcc <= '1';
  i0 : uyfaa port map (q, pad, gnd, gnd, vcc);
end;

-- output pads
library IEEE;
use IEEE.std_logic_1164.all;
use work.tech_fs90_syn.all;
entity fs90_outpad is 
  generic (drive : integer := 1);
  port (d : in std_logic; pad : out std_logic);
end; 
architecture syn of fs90_outpad is 
signal gnd, vcc : std_logic;
begin 
  gnd <= '0'; vcc <= '1';
  d1 : if drive = 1 generate
    u0 : vyfa2gsa port map (pad, d, vcc, vcc, gnd, gnd, gnd);
  end generate;
  d2 : if drive = 2 generate
    u0 : vyfa2gsa port map (pad, d, vcc, gnd, vcc, gnd, gnd);
  end generate;
  d3 : if drive = 3 generate
    u0 : vyfa2gsa port map (pad, d, vcc, gnd, gnd, vcc, gnd);
  end generate;
  d4 : if drive > 3 generate
    u0 : vyfa2gsa port map (pad, d, vcc, gnd, vcc, vcc, gnd);
  end generate;
end;

-- tri-state output pads with pull-up
library IEEE;
use IEEE.std_logic_1164.all;
use work.tech_fs90_syn.all;
entity fs90_toutpadu is 
  generic (drive : integer := 1);
  port (d, en : in  std_logic; pad : out  std_logic);
end; 
architecture syn of fs90_toutpadu is 
signal gnd, vcc, q, ipad, eni : std_logic;
begin 
  gnd <= '0'; vcc <= '1'; pad <= ipad; eni <= not en;
  d1 : if drive = 1 generate
    u0 : wyfa2gsa port map (q, d, ipad, eni, vcc, gnd, gnd, gnd, vcc, gnd, gnd);
  end generate;
  d2 : if drive = 2 generate
    u0 : wyfa2gsa port map (q, d, ipad, eni, gnd, vcc, gnd, gnd, vcc, gnd, gnd);
  end generate;
  d3 : if drive = 3 generate
    u0 : wyfa2gsa port map (q, d, ipad, eni, gnd, gnd, vcc, gnd, vcc, gnd, gnd);
  end generate;
  d4 : if drive > 3 generate
    u0 : wyfa2gsa port map (q, d, ipad, eni, gnd, vcc, vcc, gnd, vcc, gnd, gnd);
  end generate;
end;

-- bidirectional pad
library IEEE;
use IEEE.std_logic_1164.all;
use work.tech_fs90_syn.all;
entity fs90_iopad is
  generic (drive : integer := 1);
  port ( d, en : in std_logic; q : out std_logic; pad : inout std_logic);
end;
architecture syn of fs90_iopad is 
signal gnd, vcc, eni : std_logic;
begin 
  gnd <= '0'; vcc <= '1'; eni <= not en;
  d1 : if drive = 1 generate
    u0 : wyfa2gsa port map (q, d, pad, eni, vcc, gnd, gnd, gnd, gnd, gnd, gnd);
  end generate;
  d2 : if drive = 2 generate
    u0 : wyfa2gsa port map (q, d, pad, eni, gnd, vcc, gnd, gnd, gnd, gnd, gnd);
  end generate;
  d3 : if drive = 3 generate
    u0 : wyfa2gsa port map (q, d, pad, eni, gnd, gnd, vcc, gnd, gnd, gnd, gnd);
  end generate;
  d4 : if drive > 3 generate
    u0 : wyfa2gsa port map (q, d, pad, eni, gnd, vcc, vcc, gnd, gnd, gnd, gnd);
  end generate;
end;

-- bidirectional schmitt pad
library IEEE;
use IEEE.std_logic_1164.all;
use work.tech_fs90_syn.all;
entity fs90_smiopad is
  generic (drive : integer := 1);
  port ( d, en : in std_logic; q : out std_logic; pad : inout std_logic);
end;
architecture syn of fs90_smiopad is 
signal gnd, vcc, eni : std_logic;
begin 
  gnd <= '0'; vcc <= '1'; eni <= not en;
  d1 : if drive = 1 generate
    u0 : wyfa2gsa port map (q, d, pad, eni, vcc, gnd, gnd, gnd, gnd, gnd, vcc);
  end generate;
  d2 : if drive = 2 generate
    u0 : wyfa2gsa port map (q, d, pad, eni, gnd, vcc, gnd, gnd, gnd, gnd, vcc);
  end generate;
  d3 : if drive = 3 generate
    u0 : wyfa2gsa port map (q, d, pad, eni, gnd, gnd, vcc, gnd, gnd, gnd, vcc);
  end generate;
  d4 : if drive > 3 generate
    u0 : wyfa2gsa port map (q, d, pad, eni, gnd, vcc, vcc, gnd, gnd, gnd, vcc);
  end generate;
end;

-- bidirectional pad with open-drain
library IEEE;
use IEEE.std_logic_1164.all;
use work.tech_fs90_syn.all;
entity fs90_iodpad is
  generic (drive : integer := 1);
  port ( d : in std_logic; q : out std_logic; pad : inout std_logic);
end;
architecture syn of fs90_iodpad is 
signal gnd, vcc, eni : std_logic;
begin 
  gnd <= '0'; vcc <= '1'; eni <= not d;
  d1 : if drive = 1 generate
    u0 : wyfa2gsa port map (q, gnd, pad, eni, vcc, gnd, gnd, gnd, gnd, gnd, gnd);
  end generate;
  d2 : if drive = 2 generate
    u0 : wyfa2gsa port map (q, gnd, pad, eni, gnd, vcc, gnd, gnd, gnd, gnd, gnd);
  end generate;
  d3 : if drive = 3 generate
    u0 : wyfa2gsa port map (q, gnd, pad, eni, gnd, gnd, vcc, gnd, gnd, gnd, gnd);
  end generate;
  d4 : if drive > 3 generate
    u0 : wyfa2gsa port map (q, gnd, pad, eni, gnd, vcc, vcc, gnd, gnd, gnd, gnd);
  end generate;
end;

-- output pad with open-drain
library IEEE;
use IEEE.std_logic_1164.all;
use work.tech_fs90_syn.all;
entity fs90_odpad is
  generic (drive : integer := 1);
  port (d : in std_logic; pad : out std_logic);
end;
architecture syn of fs90_odpad is 
signal gnd, vcc, eni : std_logic;
begin 
  gnd <= '0'; vcc <= '1'; eni <= not d;
  d1 : if drive = 1 generate
    u0 : vyfa2gsa port map (pad, gnd, eni, vcc, gnd, gnd, gnd);
  end generate;
  d2 : if drive = 2 generate
    u0 : vyfa2gsa port map (pad, gnd, eni, gnd, vcc, gnd, gnd);
  end generate;
  d3 : if drive = 3 generate
    u0 : vyfa2gsa port map (pad, gnd, eni, gnd, gnd, vcc, gnd);
  end generate;
  d4 : if drive > 3 generate
    u0 : vyfa2gsa port map (pad, gnd, eni, gnd, vcc, vcc, gnd);
  end generate;
end;
