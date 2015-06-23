------------------------------------------------------------------------------
--  This file is a part of the GRLIB VHDL IP LIBRARY
--  Copyright (C) 2003, Gaisler Research
--
--  This program is free software; you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation; either version 2 of the License, or
--  (at your option) any later version.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
--
--  You should have received a copy of the GNU General Public License
--  along with this program; if not, write to the Free Software
--  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA 
-----------------------------------------------------------------------------
-- Entity: 	various
-- File:	mem_apa3_gen.vhd
-- Author:	Jiri Gaisler Gaisler Research
-- Description:	Memory generators for Actel Proasic3 rams
------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
-- pragma translate_off
library proasic3;
use proasic3.RAM4K9;
-- pragma translate_on

entity proasic3_ram4k9 is
  generic (abits : integer range 9 to 12 := 9; dbits : integer := 9);
  port (
    addra, addrb : in  std_logic_vector(abits -1 downto 0);
    clka, clkb   : in  std_ulogic;
    dia, dib     : in  std_logic_vector(dbits -1 downto 0);
    doa, dob     : out std_logic_vector(dbits -1 downto 0);
    ena, enb     : in  std_ulogic;
    wea, web     : in  std_ulogic
   ); 
end;

architecture rtl of proasic3_ram4k9 is
  component RAM4K9
-- pragma translate_off
    generic (abits : integer range 9 to 12 := 9);
-- pragma translate_on
    port(
	ADDRA0, ADDRA1, ADDRA2, ADDRA3, ADDRA4, ADDRA5, ADDRA6, ADDRA7,
	ADDRA8, ADDRA9, ADDRA10, ADDRA11 : in std_logic;
	ADDRB0, ADDRB1, ADDRB2, ADDRB3, ADDRB4, ADDRB5, ADDRB6, ADDRB7,
	ADDRB8, ADDRB9, ADDRB10, ADDRB11 : in std_logic;
	BLKA, WENA, PIPEA, WMODEA, WIDTHA0, WIDTHA1, WENB, BLKB,
	PIPEB, WMODEB, WIDTHB1, WIDTHB0 : in std_logic;
	DINA0, DINA1, DINA2, DINA3, DINA4, DINA5, DINA6, DINA7, DINA8 : in std_logic;
	DINB0, DINB1, DINB2, DINB3, DINB4, DINB5, DINB6, DINB7, DINB8 : in std_logic;
	RESET, CLKA, CLKB : in std_logic; 
	DOUTA0, DOUTA1, DOUTA2, DOUTA3, DOUTA4, DOUTA5, DOUTA6, DOUTA7, DOUTA8 : out std_logic;
	DOUTB0, DOUTB1, DOUTB2, DOUTB3, DOUTB4, DOUTB5, DOUTB6, DOUTB7, DOUTB8 : out std_logic
    );
  end component;

  attribute syn_black_box : boolean;
  attribute syn_black_box of RAM4K9: component is true;
  attribute syn_tco1 : string;
  attribute syn_tco2 : string;
  attribute syn_tco1 of RAM4K9 : component is
  "CLKA->DOUTA0,DOUTA1,DOUTA2,DOUTA3,DOUTA4,DOUTA5,DOUTA6,DOUTA7,DOUTA8 = 3.0";
  attribute syn_tco2 of RAM4K9 : component is
  "CLKB->DOUTB0,DOUTB1,DOUTB2,DOUTB3,DOUTB4,DOUTB5,DOUTB6,DOUTB7,DOUTB8 = 3.0";
	
signal gnd, vcc : std_ulogic;
signal aa, ab : std_logic_vector(13 downto 0);
signal da, db : std_logic_vector(9 downto 0);
signal qa, qb : std_logic_vector(9 downto 0);
signal width : std_logic_vector(1 downto 0);
begin
  gnd <= '0'; vcc <= '1';
  width <= "11" when abits = 9 else "10" when abits = 10 else
           "01" when abits = 11 else "00";
  doa <= qa(dbits-1 downto 0); dob <= qb(dbits-1 downto 0);
  da(dbits-1 downto 0) <= dia; da(9 downto dbits) <= (others => '0');
  db(dbits-1 downto 0) <= dib; db(9 downto dbits) <= (others => '0');
  aa(abits-1 downto 0) <= addra; aa(13 downto abits) <= (others => '0');
  ab(abits-1 downto 0) <= addrb; ab(13 downto abits) <= (others => '0');
    u0 : RAM4K9
-- pragma translate_off
    generic map (abits => abits) 
-- pragma translate_on
    port map (
      ADDRA0 => aa(0), ADDRA1 => aa(1), ADDRA2 => aa(2), ADDRA3 => aa(3),
      ADDRA4 => aa(4), ADDRA5 => aa(5), ADDRA6 => aa(6), ADDRA7 => aa(7),
      ADDRA8 => aa(8), ADDRA9 => aa(9), ADDRA10 => aa(10), ADDRA11 => aa(11),
      ADDRB0 => ab(0), ADDRB1 => ab(1), ADDRB2 => ab(2), ADDRB3 => ab(3),
      ADDRB4 => ab(4), ADDRB5 => ab(5), ADDRB6 => ab(6), ADDRB7 => ab(7),
      ADDRB8 => ab(8), ADDRB9 => ab(9), ADDRB10 => ab(10), ADDRB11 => ab(11),
      BLKA => ena, WENA => wea, PIPEA =>gnd, WMODEA => gnd, WIDTHA0 => width(0), WIDTHA1 => width(1), 
      BLKB => enb, WENB => web, PIPEB =>gnd, WMODEB => gnd, WIDTHB0 => width(0), WIDTHB1 => width(1), 
      DINA0 => da(0), DINA1 => da(1), DINA2 => da(2), DINA3 => da(3), DINA4 => da(4),
      DINA5 => da(5), DINA6 => da(6), DINA7 => da(7), DINA8 => da(8),
      DINB0 => db(0), DINB1 => db(1), DINB2 => db(2), DINB3 => db(3), DINB4 => db(4),
      DINB5 => db(5), DINB6 => db(6), DINB7 => db(7), DINB8 => db(8),
      RESET => vcc, CLKA => clka, CLKB => clkb,
      DOUTA0 => qa(0), DOUTA1 => qa(1), DOUTA2 => qa(2), DOUTA3 => qa(3), DOUTA4 => qa(4),
      DOUTA5 => qa(5), DOUTA6 => qa(6), DOUTA7 => qa(7), DOUTA8 => qa(8),
      DOUTB0 => qb(0), DOUTB1 => qb(1), DOUTB2 => qb(2), DOUTB3 => qb(3), DOUTB4 => qb(4),
      DOUTB5 => qb(5), DOUTB6 => qb(6), DOUTB7 => qb(7), DOUTB8 => qb(8)
      );
end;

library ieee;
use ieee.std_logic_1164.all;
-- pragma translate_off
library proasic3;
use proasic3.RAM512X18;
-- pragma translate_on

entity proasic3_ram512x18 is
  port (
    addra, addrb : in  std_logic_vector(8 downto 0);
    clka, clkb   : in  std_ulogic;
    di           : in  std_logic_vector(17 downto 0);
    do           : out std_logic_vector(17 downto 0);
    ena, enb     : in  std_ulogic;
    wea          : in  std_ulogic
   ); 
end;

architecture rtl of proasic3_ram512x18 is
  component RAM512X18
    port(
      RADDR8, RADDR7, RADDR6, RADDR5, RADDR4, RADDR3, RADDR2, RADDR1, RADDR0 : in std_logic;
      WADDR8, WADDR7, WADDR6, WADDR5, WADDR4, WADDR3, WADDR2, WADDR1, WADDR0 : in std_logic;
      WD17, WD16, WD15, WD14, WD13, WD12, WD11, WD10, WD9, 
      WD8, WD7, WD6, WD5, WD4, WD3, WD2, WD1, WD0 : in std_logic;
      REN, WEN, RESET, RW0, RW1, WW1, WW0, PIPE, RCLK, WCLK : in std_logic;
      RD17, RD16, RD15, RD14, RD13, RD12, RD11, RD10, RD9, 
      RD8, RD7, RD6, RD5, RD4, RD3, RD2, RD1, RD0 : out std_logic
    );
  end component;
  attribute syn_black_box : boolean;
  attribute syn_tco1 : string;
  attribute syn_black_box of RAM512X18: component is true;
  attribute syn_tco1 of RAM512X18 : component is
  "RCLK->RD17,RD16,RD15,RD14,RD13,RD12,RD11,RD10,RD9,RD8,RD7,RD6,RD5,RD4,RD3,RD2,RD1,RD0 = 3.0";
signal gnd, vcc : std_ulogic;
signal width : std_logic_vector(1 downto 0);
begin
  gnd <= '0'; vcc <= '1';
  width <= "10";
    u0 : RAM512X18
    port map (
      RADDR0 => addrb(0), RADDR1 => addrb(1), RADDR2 => addrb(2), RADDR3 => addrb(3),
      RADDR4 => addrb(4), RADDR5 => addrb(5), RADDR6 => addrb(6), RADDR7 => addrb(7),
      RADDR8 => addrb(8),
      WADDR0 => addra(0), WADDR1 => addra(1), WADDR2 => addra(2), WADDR3 => addra(3),
      WADDR4 => addra(4), WADDR5 => addra(5), WADDR6 => addra(6), WADDR7 => addra(7),
      WADDR8 => addra(8),
      WD17 => di(17), WD16 => di(16), WD15 => di(15), WD14 => di(14), WD13 => di(13),
      WD12 => di(12), WD11 => di(11), WD10 => di(10), WD9 => di(9),
      WD8 => di(8), WD7 => di(7), WD6 => di(6), WD5 => di(5), WD4 => di(4),
      WD3 => di(3), WD2 => di(2), WD1 => di(1), WD0 => di(0),
      WEN => ena, PIPE => gnd, WW0 => width(0), WW1 => width(1), 
      REN => enb, RW0 => width(0), RW1 => width(1), 
      RESET => vcc, WCLK => clka, RCLK => clkb,
      RD17 => do(17), RD16 => do(16), RD15 => do(15), RD14 => do(14), RD13 => do(13),
      RD12 => do(12), RD11 => do(11), RD10 => do(10), RD9 => do(9),
      RD8 => do(8), RD7 => do(7), RD6 => do(6), RD5 => do(5), RD4 => do(4),
      RD3 => do(3), RD2 => do(2), RD1 => do(1), RD0 => do(0)
      );
end;

library ieee;
use ieee.std_logic_1164.all;

entity proasic3_syncram_dp is
  generic ( abits : integer := 6; dbits : integer := 8 );
  port (
    clk1     : in std_ulogic;
    address1 : in std_logic_vector((abits -1) downto 0);
    datain1  : in std_logic_vector((dbits -1) downto 0);
    dataout1 : out std_logic_vector((dbits -1) downto 0);
    enable1  : in std_ulogic;
    write1   : in std_ulogic;
    clk2     : in std_ulogic;
    address2 : in std_logic_vector((abits -1) downto 0);
    datain2  : in std_logic_vector((dbits -1) downto 0);
    dataout2 : out std_logic_vector((dbits -1) downto 0);
    enable2  : in std_ulogic;
    write2   : in std_ulogic
   ); 
end;

architecture rtl of proasic3_syncram_dp is
  component proasic3_ram4k9
  generic (abits : integer range 9 to 12 := 9; dbits : integer := 9);
  port (
    addra, addrb : in  std_logic_vector(abits -1 downto 0);
    clka, clkb   : in  std_ulogic;
    dia, dib     : in  std_logic_vector(dbits -1 downto 0);
    doa, dob     : out std_logic_vector(dbits -1 downto 0);
    ena, enb     : in  std_ulogic;
    wea, web     : in  std_ulogic); 
  end component;

  constant dlen : integer := dbits + 9;
  signal di1, di2, q1, q2 : std_logic_vector(dlen downto 0);
  signal a1, a2 : std_logic_vector(12 downto 0);
  signal en1, en2, we1, we2 : std_ulogic;
begin

  di1(dbits-1 downto 0) <= datain1; di1(dlen downto dbits) <= (others => '0');
  di2(dbits-1 downto 0) <= datain1; di2(dlen downto dbits) <= (others => '0');
  a1(abits-1 downto 0) <= address1; a1(12 downto abits) <= (others => '0');
  a2(abits-1 downto 0) <= address1; a2(12 downto abits) <= (others => '0');
  dataout1 <= q1(dbits-1 downto 0); q1(dlen downto dbits) <= (others => '0');
  dataout2 <= q2(dbits-1 downto 0); q2(dlen downto dbits) <= (others => '0');
  en1 <= not enable1; en2 <= not enable2;
  we1 <= not write1; we2 <= not write2;
  a9 : if (abits <= 9) generate
    x : for i in 0 to (dbits-1)/9 generate
      u0 : proasic3_ram4k9 generic map (9, 9) port map (
        a1(8 downto 0), a2(8 downto 0), clk1, clk2, 
	di1(i*9+8 downto i*9), di2(i*9+8 downto i*9),
	q1(i*9+8 downto i*9), q2(i*9+8 downto i*9), 
	en1, en2, we1, we2);
    end generate;
  end generate;
  a10 : if (abits = 10) generate
    x : for i in 0 to (dbits-1)/4 generate
      u0 : proasic3_ram4k9 generic map (10, 4) port map (
        a1(9 downto 0), a2(9 downto 0), clk1, clk2, 
	di1(i*4+3 downto i*4), di2(i*4+3 downto i*4),
	q1(i*4+3 downto i*4), q2(i*4+3 downto i*4), 
	en1, en2, we1, we2);
    end generate;
  end generate;
  a11 : if (abits = 11) generate
    x : for i in 0 to (dbits-1)/2 generate
      u0 : proasic3_ram4k9 generic map (11, 2) port map (
        a1(10 downto 0), a2(10 downto 0), clk1, clk2, 
	di1(i*2+1 downto i*2), di2(i*2+1 downto i*2),
	q1(i*2+1 downto i*2), q2(i*2+1 downto i*2), 
	en1, en2, we1, we2);
    end generate;
  end generate;
  a12 : if (abits = 12) generate
    x : for i in 0 to (dbits-1) generate
      u0 : proasic3_ram4k9 generic map (12, 1) port map (
        a1(11 downto 0), a2(11 downto 0), clk1, clk2, 
	di1(i*1 downto i*1), di2(i*1 downto i*1),
	q1(i*1 downto i*1), q2(i*1 downto i*1), 
	en1, en2, we1, we2);
    end generate;
  end generate;
-- pragma translate_off  
  unsup : if abits > 12 generate
    x : process
    begin
      assert false
      report  "Address depth larger than 12 not supported for ProAsic3 rams"
      severity failure;
      wait;
    end process;
  end generate;
-- pragma translate_on
end;

library ieee;
use ieee.std_logic_1164.all;

entity proasic3_syncram_2p is
  generic ( abits : integer := 8; dbits : integer := 32);
  port (
    rclk  : in std_ulogic;
    rena  : in std_ulogic;
    raddr : in std_logic_vector (abits -1 downto 0);
    dout  : out std_logic_vector (dbits -1 downto 0);
    wclk  : in std_ulogic;
    waddr : in std_logic_vector (abits -1 downto 0);
    din   : in std_logic_vector (dbits -1 downto 0);
    write : in std_ulogic);
end;

architecture rtl of proasic3_syncram_2p is
  component proasic3_ram4k9
  generic (abits : integer range 9 to 12 := 9; dbits : integer := 9);
  port (
    addra, addrb : in  std_logic_vector(abits -1 downto 0);
    clka, clkb   : in  std_ulogic;
    dia, dib     : in  std_logic_vector(dbits -1 downto 0);
    doa, dob     : out std_logic_vector(dbits -1 downto 0);
    ena, enb     : in  std_ulogic;
    wea, web     : in  std_ulogic); 
  end component;
  component proasic3_ram512x18
  port (
    addra, addrb : in  std_logic_vector(8 downto 0);
    clka, clkb   : in  std_ulogic;
    di           : in  std_logic_vector(17 downto 0);
    do           : out std_logic_vector(17 downto 0);
    ena, enb     : in  std_ulogic;
    wea          : in  std_ulogic); 
  end component;

  constant dlen : integer := dbits + 18;
  signal di1, q2, gnd : std_logic_vector(dlen downto 0);
  signal a1, a2 : std_logic_vector(12 downto 0);
  signal en1, en2, we1, vcc : std_ulogic;
begin

  vcc <= '1'; gnd <= (others => '0');
  di1(dbits-1 downto 0) <= din; di1(dlen downto dbits) <= (others => '0');
  a1(abits-1 downto 0) <= waddr; a1(12 downto abits) <= (others => '0');
  a2(abits-1 downto 0) <= raddr; a2(12 downto abits) <= (others => '0');
  dout <= q2(dbits-1 downto 0); q2(dlen downto dbits) <= (others => '0');
  en1 <= not write; en2 <= not rena; we1 <= not write;
  a8 : if (abits <= 8) generate
    x : for i in 0 to (dbits-1)/18 generate
      u0 : proasic3_ram512x18 port map (
        a1(8 downto 0), a2(8 downto 0), wclk, rclk, 
	di1(i*18+17 downto i*18), q2(i*18+17 downto i*18), 
	en1, en2, we1);
    end generate;
  end generate;
  a9 : if (abits = 9) generate
    x : for i in 0 to (dbits-1)/9 generate
      u0 : proasic3_ram4k9 generic map (9, 9) port map (
        a1(8 downto 0), a2(8 downto 0), wclk, rclk, 
	di1(i*9+8 downto i*9), gnd(8 downto 0),
	open, q2(i*9+8 downto i*9), 
	en1, en2, we1, vcc);
    end generate;
  end generate;
  a10 : if (abits = 10) generate
    x : for i in 0 to (dbits-1)/4 generate
      u0 : proasic3_ram4k9 generic map (10, 4) port map (
        a1(9 downto 0), a2(9 downto 0), wclk, rclk, 
	di1(i*4+3 downto i*4), gnd(3 downto 0),
	open, q2(i*4+3 downto i*4), 
	en1, en2, we1, vcc);
    end generate;
  end generate;
  a11 : if (abits = 11) generate
    x : for i in 0 to (dbits-1)/2 generate
      u0 : proasic3_ram4k9 generic map (11, 2) port map (
        a1(10 downto 0), a2(10 downto 0), wclk, rclk, 
	di1(i*2+1 downto i*2), gnd(1 downto 0),
	open, q2(i*2+1 downto i*2), 
	en1, en2, we1, vcc);
    end generate;
  end generate;
  a12 : if (abits = 12) generate
    x : for i in 0 to (dbits-1) generate
      u0 : proasic3_ram4k9 generic map (12, 1) port map (
        a1(11 downto 0), a2(11 downto 0), wclk, rclk, 
	di1(i*1 downto i*1), gnd(0 downto 0),
	open, q2(i*1 downto i*1), 
	en1, en2, we1, vcc);
    end generate;
  end generate;
-- pragma translate_off  
  unsup : if abits > 12 generate
    x : process
    begin
      assert false
      report  "Address depth larger than 12 not supported for ProAsic3 rams"
      severity failure;
      wait;
    end process;
  end generate;
-- pragma translate_on
end;

library ieee;
use ieee.std_logic_1164.all;

entity proasic3_syncram is
  generic ( abits : integer := 10; dbits : integer := 8 );
  port (
    clk      : in std_ulogic;
    address  : in std_logic_vector((abits -1) downto 0);
    datain   : in std_logic_vector((dbits -1) downto 0);
    dataout  : out std_logic_vector((dbits -1) downto 0);
    enable   : in std_ulogic;
    write    : in std_ulogic
   ); 
end;

architecture rtl of proasic3_syncram is
component proasic3_syncram_dp
  generic ( abits : integer := 6; dbits : integer := 8 );
  port (
    clk1     : in std_ulogic;
    address1 : in std_logic_vector((abits -1) downto 0);
    datain1  : in std_logic_vector((dbits -1) downto 0);
    dataout1 : out std_logic_vector((dbits -1) downto 0);
    enable1  : in std_ulogic;
    write1   : in std_ulogic;
    clk2     : in std_ulogic;
    address2 : in std_logic_vector((abits -1) downto 0);
    datain2  : in std_logic_vector((dbits -1) downto 0);
    dataout2 : out std_logic_vector((dbits -1) downto 0);
    enable2  : in std_ulogic;
    write2   : in std_ulogic
   ); 
end component;

component proasic3_syncram_2p
  generic ( abits : integer := 8; dbits : integer := 32);
  port (
    rclk  : in std_ulogic;
    rena  : in std_ulogic;
    raddr : in std_logic_vector (abits -1 downto 0);
    dout  : out std_logic_vector (dbits -1 downto 0);
    wclk  : in std_ulogic;
    waddr : in std_logic_vector (abits -1 downto 0);
    din   : in std_logic_vector (dbits -1 downto 0);
    write : in std_ulogic);
end component;

signal gnd : std_logic_vector(abits+dbits downto 0);
begin
  gnd <= (others => '0');
  r2p  : if abits <= 8 generate 
    u0 : proasic3_syncram_2p generic map (abits, dbits)
       port map (clk, enable, address, dataout, clk, address, datain, write);
  end generate;
  rdp  : if abits > 8 generate 
    u0 : proasic3_syncram_dp generic map (abits, dbits)
         port map (clk, address, datain, dataout, enable, write, 
                   clk, gnd(abits-1 downto 0), gnd(dbits-1 downto 0), open, gnd(0), gnd(0));
  end generate;
end;

