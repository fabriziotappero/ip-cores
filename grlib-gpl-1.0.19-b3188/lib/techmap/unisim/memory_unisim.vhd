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
-- File:	mem_xilinx_gen.vhd
-- Author:	Jiri Gaisler - Gaisler Research
-- Description:	Memory generators for Xilinx rams
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
--pragma translate_off
library unisim;
use unisim.RAMB4_S1;
use unisim.RAMB4_S2;
use unisim.RAMB4_S4;
use unisim.RAMB4_S8;
use unisim.RAMB4_S16;
use unisim.RAMB4_S16_S16;
--pragma translate_on
library techmap;
use techmap.gencomp.all;

entity virtex_syncram is
  generic ( abits : integer := 6; dbits : integer := 8);
  port (
    clk     : in std_ulogic;
    address : in std_logic_vector (abits -1 downto 0);
    datain  : in std_logic_vector (dbits -1 downto 0);
    dataout : out std_logic_vector (dbits -1 downto 0);
    enable  : in std_ulogic;
    write   : in std_ulogic
  );
end;

architecture behav of virtex_syncram is
  component generic_syncram
  generic ( abits : integer := 10; dbits : integer := 8 );
  port (
    clk      : in std_ulogic;
    address  : in std_logic_vector((abits -1) downto 0);
    datain   : in std_logic_vector((dbits -1) downto 0);
    dataout  : out std_logic_vector((dbits -1) downto 0);
    write    : in std_ulogic);
  end component;
  component ramb4_s16 port (
    do   : out std_logic_vector (15 downto 0);
    addr : in  std_logic_vector (7 downto 0);
    clk  : in  std_ulogic;
    di   : in  std_logic_vector (15 downto 0);
    en, rst, we : in std_ulogic);
  end component;
  component RAMB4_S8
  port (do   : out std_logic_vector (7 downto 0);
        addr : in  std_logic_vector (8 downto 0);
        clk  : in  std_ulogic;
        di   : in  std_logic_vector (7 downto 0);
        en, rst, we : in std_ulogic);
  end component;
  component RAMB4_S4
  port (do   : out std_logic_vector (3 downto 0);
        addr : in  std_logic_vector (9 downto 0);
        clk  : in  std_ulogic;
        di   : in  std_logic_vector (3 downto 0);
        en, rst, we : in std_ulogic);
  end component;
  component RAMB4_S2
  port (do   : out std_logic_vector (1 downto 0);
        addr : in  std_logic_vector (10 downto 0);
        clk  : in  std_ulogic;
        di   : in  std_logic_vector (1 downto 0);
        en, rst, we : in std_ulogic);
  end component;
  component RAMB4_S1
  port (do   : out std_logic_vector (0 downto 0);
        addr : in  std_logic_vector (11 downto 0);
        clk  : in  std_ulogic;
        di   : in  std_logic_vector (0 downto 0);
        en, rst, we : in std_ulogic);
  end component;
  component RAMB4_S16_S16
  port (
        doa    : out std_logic_vector (15 downto 0);
        dob    : out std_logic_vector (15 downto 0);
	addra  : in  std_logic_vector (7 downto 0);
	addrb  : in  std_logic_vector (7 downto 0);
	clka   : in  std_ulogic;
	clkb   : in  std_ulogic;
	dia    : in  std_logic_vector (15 downto 0);
	dib    : in  std_logic_vector (15 downto 0);
	ena    : in  std_ulogic;
	enb    : in  std_ulogic;
	rsta   : in  std_ulogic;
	rstb   : in  std_ulogic;
	wea    : in  std_ulogic;
	web    : in  std_ulogic
       );
  end component;
signal gnd : std_ulogic;
signal do, di : std_logic_vector(dbits+32 downto 0);
signal xa, ya : std_logic_vector(19 downto 0);
begin
  gnd <= '0';
  dataout <= do(dbits-1 downto 0);
  di(dbits-1 downto 0) <= datain; di(dbits+32 downto dbits) <= (others => '0');
  xa(abits-1 downto 0) <= address; xa(19 downto abits) <= (others => '0');
  ya(abits-1 downto 0) <= address; ya(19 downto abits) <= (others => '1');

  a0 : if (abits <= 5) generate
    r0 : generic_syncram generic map (abits, dbits)
         port map (clk, address, datain, do(dbits-1 downto 0), write);
    do(dbits+32 downto dbits) <= (others => '0');
  end generate;
  a7 : if (abits > 5) and (abits <= 7) and (dbits <= 32) generate
    r0 : RAMB4_S16_S16 port map ( do(31 downto 16), do(15 downto 0),
	xa(7 downto 0), ya(7 downto 0), clk, clk, di(31 downto 16),
	di(15 downto 0), enable, enable, gnd, gnd, write, write);
    do(dbits+32 downto 32) <= (others => '0');
  end generate;
  a8 : if ((abits > 5) and (abits <= 7) and (dbits > 32)) or (abits = 8) generate
    x : for i in 0 to ((dbits-1)/16) generate
      r : RAMB4_S16 port map ( do (((i+1)*16)-1 downto i*16), xa(7 downto 0),
	clk, di (((i+1)*16)-1 downto i*16), enable, gnd, write );
    end generate;
    do(dbits+32 downto 16*(((dbits-1)/16)+1)) <= (others => '0');
  end generate;
  a9 : if abits = 9 generate
    x : for i in 0 to ((dbits-1)/8) generate
      r : RAMB4_S8 port map ( do (((i+1)*8)-1 downto i*8), xa(8 downto 0),
	clk, di (((i+1)*8)-1 downto i*8), enable, gnd, write );
    end generate;
    do(dbits+32 downto 8*(((dbits-1)/8)+1)) <= (others => '0');
  end generate;
  a10 : if abits = 10 generate
    x : for i in 0 to ((dbits-1)/4) generate
      r : RAMB4_S4 port map ( do (((i+1)*4)-1 downto i*4), xa(9 downto 0),
	clk, di (((i+1)*4)-1 downto i*4), enable, gnd, write );
    end generate;
    do(dbits+32 downto 4*(((dbits-1)/4)+1)) <= (others => '0');
  end generate;
  a11 : if abits = 11 generate
    x : for i in 0 to ((dbits-1)/2) generate
      r : RAMB4_S2 port map ( do (((i+1)*2)-1 downto i*2), xa(10 downto 0),
	clk, di (((i+1)*2)-1 downto i*2), enable, gnd, write );
    end generate;
    do(dbits+32 downto 2*(((dbits-1)/2)+1)) <= (others => '0');
  end generate;
  a12 : if abits = 12 generate
    x : for i in 0 to (dbits-1) generate
      r : RAMB4_S1 port map ( do (i downto i), xa(11 downto 0),
	clk, di(i downto i), enable, gnd, write );
    end generate;
    do(dbits+32 downto dbits) <= (others => '0');
  end generate;

  a13 : if abits > 12 generate
    x: generic_syncram generic map (abits, dbits)
      port map (clk, address, datain, do(dbits-1 downto 0), write);
    do(dbits+32 downto dbits) <= (others => '0');
  end generate;

-- pragma translate_off
--  a_to_high : if abits > 12 generate
--    x : process
--    begin
--      assert false
--      report  "Address depth larger than 12 not supported for virtex_syncram"
--      severity failure;
--      wait;
--    end process;
--  end generate;
-- pragma translate_on

end;

library ieee;
use ieee.std_logic_1164.all;
--pragma translate_off
library unisim;
use unisim.RAMB4_S1_S1;
use unisim.RAMB4_S2_S2;
use unisim.RAMB4_S4_S4;
use unisim.RAMB4_S8_S8;
use unisim.RAMB4_S16_S16;
--pragma translate_on

entity virtex_syncram_dp is
  generic (
    abits : integer := 6; dbits : integer := 8
  );
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
    write2   : in std_ulogic);
end;

architecture behav of virtex_syncram_dp is
 component RAMB4_S1_S1
  port (
        doa    : out std_logic_vector (0 downto 0);
        dob    : out std_logic_vector (0 downto 0);
	addra  : in  std_logic_vector (11 downto 0);
	addrb  : in  std_logic_vector (11 downto 0);
	clka   : in  std_ulogic;
	clkb   : in  std_ulogic;
	dia    : in  std_logic_vector (0 downto 0);
	dib    : in  std_logic_vector (0 downto 0);
	ena    : in  std_ulogic;
	enb    : in  std_ulogic;
	rsta   : in  std_ulogic;
	rstb   : in  std_ulogic;
	wea    : in  std_ulogic;
	web    : in  std_ulogic
       );
  end component;
  component RAMB4_S2_S2
  port (
        doa    : out std_logic_vector (1 downto 0);
        dob    : out std_logic_vector (1 downto 0);
	addra  : in  std_logic_vector (10 downto 0);
	addrb  : in  std_logic_vector (10 downto 0);
	clka   : in  std_ulogic;
	clkb   : in  std_ulogic;
	dia    : in  std_logic_vector (1 downto 0);
	dib    : in  std_logic_vector (1 downto 0);
	ena    : in  std_ulogic;
	enb    : in  std_ulogic;
	rsta   : in  std_ulogic;
	rstb   : in  std_ulogic;
	wea    : in  std_ulogic;
	web    : in  std_ulogic
       );
  end component;
  component RAMB4_S4_S4
  port (
        doa    : out std_logic_vector (3 downto 0);
        dob    : out std_logic_vector (3 downto 0);
	addra  : in  std_logic_vector (9 downto 0);
	addrb  : in  std_logic_vector (9 downto 0);
	clka   : in  std_ulogic;
	clkb   : in  std_ulogic;
	dia    : in  std_logic_vector (3 downto 0);
	dib    : in  std_logic_vector (3 downto 0);
	ena    : in  std_ulogic;
	enb    : in  std_ulogic;
	rsta   : in  std_ulogic;
	rstb   : in  std_ulogic;
	wea    : in  std_ulogic;
	web    : in  std_ulogic
       );
  end component;
  component RAMB4_S8_S8
  port (
        doa    : out std_logic_vector (7 downto 0);
        dob    : out std_logic_vector (7 downto 0);
	addra  : in  std_logic_vector (8 downto 0);
	addrb  : in  std_logic_vector (8 downto 0);
	clka   : in  std_ulogic;
	clkb   : in  std_ulogic;
	dia    : in  std_logic_vector (7 downto 0);
	dib    : in  std_logic_vector (7 downto 0);
	ena    : in  std_ulogic;
	enb    : in  std_ulogic;
	rsta   : in  std_ulogic;
	rstb   : in  std_ulogic;
	wea    : in  std_ulogic;
	web    : in  std_ulogic
       );
  end component;
  component RAMB4_S16_S16
  port (
        doa    : out std_logic_vector (15 downto 0);
        dob    : out std_logic_vector (15 downto 0);
	addra  : in  std_logic_vector (7 downto 0);
	addrb  : in  std_logic_vector (7 downto 0);
	clka   : in  std_ulogic;
	clkb   : in  std_ulogic;
	dia    : in  std_logic_vector (15 downto 0);
	dib    : in  std_logic_vector (15 downto 0);
	ena    : in  std_ulogic;
	enb    : in  std_ulogic;
	rsta   : in  std_ulogic;
	rstb   : in  std_ulogic;
	wea    : in  std_ulogic;
	web    : in  std_ulogic
       );
  end component;

signal gnd, vcc : std_ulogic;
signal do1, do2, di1, di2 : std_logic_vector(dbits+16 downto 0);
signal addr1, addr2 : std_logic_vector(19 downto 0);
begin
  gnd <= '0'; vcc <= '1';
  dataout1 <= do1(dbits-1 downto 0); dataout2 <= do2(dbits-1 downto 0);
  di1(dbits-1 downto 0) <= datain1; di1(dbits+16 downto dbits) <= (others => '0');
  di2(dbits-1 downto 0) <= datain2; di2(dbits+16 downto dbits) <= (others => '0');
  addr1(abits-1 downto 0) <= address1; addr1(19 downto abits) <= (others => '0');
  addr2(abits-1 downto 0) <= address2; addr2(19 downto abits) <= (others => '0');

  a8 : if abits <= 8 generate
    x : for i in 0 to ((dbits-1)/16) generate
      r0 : RAMB4_S16_S16 port map (
	do1(((i+1)*16)-1 downto i*16), do2(((i+1)*16)-1 downto i*16),
	addr1(7 downto 0), addr2(7 downto 0), clk1, clk2,
	di1(((i+1)*16)-1 downto i*16), di2(((i+1)*16)-1 downto i*16),
   	enable1, enable2, gnd, gnd, write1, write2);
    end generate;
  end generate;

  a9 : if abits = 9 generate
    x : for i in 0 to ((dbits-1)/8) generate
      r0 : RAMB4_S8_S8 port map (
	do1(((i+1)*8)-1 downto i*8), do2(((i+1)*8)-1 downto i*8),
	addr1(8 downto 0), addr2(8 downto 0), clk1, clk2,
	di1(((i+1)*8)-1 downto i*8), di2(((i+1)*8)-1 downto i*8),
   	enable1, enable2, gnd, gnd, write1, write2);
    end generate;
  end generate;

  a10: if abits = 10 generate
    x : for i in 0 to ((dbits-1)/4) generate
      r0 : RAMB4_S4_S4 port map (
	do1(((i+1)*4)-1 downto i*4), do2(((i+1)*4)-1 downto i*4),
	addr1(9 downto 0), addr2(9 downto 0), clk1, clk2,
	di1(((i+1)*4)-1 downto i*4), di2(((i+1)*4)-1 downto i*4),
   	enable1, enable2, gnd, gnd, write1, write2);
    end generate;
  end generate;

  a11: if abits = 11 generate
    x : for i in 0 to ((dbits-1)/2) generate
      r0 : RAMB4_S2_S2 port map (
	do1(((i+1)*2)-1 downto i*2), do2(((i+1)*2)-1 downto i*2),
	addr1(10 downto 0), addr2(10 downto 0), clk1, clk2,
	di1(((i+1)*2)-1 downto i*2), di2(((i+1)*2)-1 downto i*2),
   	enable1, enable2, gnd, gnd, write1, write2);
    end generate;
  end generate;

  a12: if abits = 12 generate
    x : for i in 0 to ((dbits-1)/1) generate
      r0 : RAMB4_S1_S1 port map (
	do1(((i+1)*1)-1 downto i*1), do2(((i+1)*1)-1 downto i*1),
	addr1(11 downto 0), addr2(11 downto 0), clk1, clk2,
	di1(((i+1)*1)-1 downto i*1), di2(((i+1)*1)-1 downto i*1),
   	enable1, enable2, gnd, gnd, write1, write2);
    end generate;
  end generate;

-- pragma translate_off
  a_to_high : if abits > 12 generate
    x : process
    begin
      assert false
      report  "Address depth larger than 12 not supported for virtex_syncram_dp"
      severity failure;
      wait;
    end process;
  end generate;
-- pragma translate_on

end;


-- parametrisable sync ram generator using virtex2 select rams

library ieee;
use ieee.std_logic_1164.all;
--pragma translate_off
library unisim;
use unisim.RAMB16_S36_S36;
use unisim.RAMB16_S36;
use unisim.RAMB16_S18;
use unisim.RAMB16_S9;
use unisim.RAMB16_S4;
use unisim.RAMB16_S2;
use unisim.RAMB16_S1;
--pragma translate_on

entity virtex2_syncram is
  generic ( abits : integer := 9; dbits : integer := 32);
  port (
    clk     : in std_ulogic;
    address : in std_logic_vector (abits -1 downto 0);
    datain  : in std_logic_vector (dbits -1 downto 0);
    dataout : out std_logic_vector (dbits -1 downto 0);
    enable  : in std_ulogic;
    write   : in std_ulogic
  );
end;

architecture behav of virtex2_syncram is
  component RAMB16_S36_S36
  port (
    DOA : out std_logic_vector (31 downto 0);
    DOB : out std_logic_vector (31 downto 0);
    DOPA : out std_logic_vector (3 downto 0);
    DOPB : out std_logic_vector (3 downto 0);
    ADDRA : in std_logic_vector (8 downto 0);
    ADDRB : in std_logic_vector (8 downto 0);
    CLKA : in std_ulogic;
    CLKB : in std_ulogic;
    DIA : in std_logic_vector (31 downto 0);
    DIB : in std_logic_vector (31 downto 0);
    DIPA : in std_logic_vector (3 downto 0);
    DIPB : in std_logic_vector (3 downto 0);
    ENA : in std_ulogic;
    ENB : in std_ulogic;
    SSRA : in std_ulogic;
    SSRB : in std_ulogic;
    WEA : in std_ulogic;
    WEB : in std_ulogic);
  end component;

  component RAMB16_S1
  port (
    DO : out std_logic_vector (0 downto 0);
    ADDR : in std_logic_vector (13 downto 0);
    CLK : in std_ulogic;
    DI : in std_logic_vector (0 downto 0);
    EN : in std_ulogic;
    SSR : in std_ulogic;
    WE : in std_ulogic
  );
end component;

  component RAMB16_S2
 port (
   DO : out std_logic_vector (1 downto 0);
   ADDR : in std_logic_vector (12 downto 0);
   CLK : in std_ulogic;
   DI : in std_logic_vector (1 downto 0);
   EN : in std_ulogic;
   SSR : in std_ulogic;
   WE : in std_ulogic
 );
  end component;

  component RAMB16_S4
 port (
   DO : out std_logic_vector (3 downto 0);
   ADDR : in std_logic_vector (11 downto 0);
   CLK : in std_ulogic;
   DI : in std_logic_vector (3 downto 0);
   EN : in std_ulogic;
   SSR : in std_ulogic;
   WE : in std_ulogic
 );
  end component;

  component RAMB16_S9
 port (
   DO : out std_logic_vector (7 downto 0);
   DOP : out std_logic_vector (0 downto 0);
   ADDR : in std_logic_vector (10 downto 0);
   CLK : in std_ulogic;
   DI : in std_logic_vector (7 downto 0);
   DIP : in std_logic_vector (0 downto 0);
   EN : in std_ulogic;
   SSR : in std_ulogic;
   WE : in std_ulogic
 );
  end component;

  component RAMB16_S18
  port (
    DO : out std_logic_vector (15 downto 0);
    DOP : out std_logic_vector (1 downto 0);
    ADDR : in std_logic_vector (9 downto 0);
    CLK : in std_ulogic;
    DI : in std_logic_vector (15 downto 0);
    DIP : in std_logic_vector (1 downto 0);
    EN : in std_ulogic;
    SSR : in std_ulogic;
    WE : in std_ulogic
  );
  end component;

 component RAMB16_S36
 port (
   DO : out std_logic_vector (31 downto 0);
   DOP : out std_logic_vector (3 downto 0);
   ADDR : in std_logic_vector (8 downto 0);
   CLK : in std_ulogic;
   DI : in std_logic_vector (31 downto 0);
   DIP : in std_logic_vector (3 downto 0);
   EN : in std_ulogic;
   SSR : in std_ulogic;
   WE : in std_ulogic
 );
end component;

  component generic_syncram
  generic ( abits : integer := 10; dbits : integer := 8 );
  port (
    clk      : in std_ulogic;
    address  : in std_logic_vector((abits -1) downto 0);
    datain   : in std_logic_vector((dbits -1) downto 0);
    dataout  : out std_logic_vector((dbits -1) downto 0);
    write    : in std_ulogic);
  end component;

signal gnd : std_ulogic;
signal do, di : std_logic_vector(dbits+72 downto 0);
signal xa, ya : std_logic_vector(19 downto 0);
begin
  gnd <= '0'; dataout <= do(dbits-1 downto 0); di(dbits-1 downto 0) <= datain;
  di(dbits+72 downto dbits) <= (others => '0'); xa(abits-1 downto 0) <= address;
  xa(19 downto abits) <= (others => '0'); ya(abits-1 downto 0) <= address;
  ya(19 downto abits) <= (others => '1');

  a0 : if (abits <= 5) generate
    r0 : generic_syncram generic map (abits, dbits)
         port map (clk, address, datain, do(dbits-1 downto 0), write);
    do(dbits+72 downto dbits) <= (others => '0');
  end generate;

  a8 : if (abits > 5) and (abits <= 8) generate
    x : for i in 0 to ((dbits-1)/72) generate
      r0 : RAMB16_S36_S36 port map (
	do(i*72+36+31 downto i*72+36), do(i*72+31 downto i*72),
	do(i*72+36+32+3 downto i*72+36+32), do(i*72+32+3 downto i*72+32),
	xa(8 downto 0), ya(8 downto 0), clk, clk,
	di(i*72+36+31 downto i*72+36), di(i*72+31 downto i*72),
	di(i*72+36+32+3 downto i*72+36+32), di(i*72+32+3 downto i*72+32),
	enable, enable, gnd, gnd, write, write);
    end generate;
    do(dbits+72 downto 72*(((dbits-1)/72)+1)) <= (others => '0');
  end generate;
  a9 : if (abits = 9) generate
    x : for i in 0 to ((dbits-1)/36) generate
      r : RAMB16_S36 port map ( do(((i+1)*36)-5 downto i*36),
	do(((i+1)*36)-1 downto i*36+32), xa(8 downto 0), clk,
	di(((i+1)*36)-5 downto i*36), di(((i+1)*36)-1 downto i*36+32),
	enable, gnd, write);
    end generate;
    do(dbits+72 downto 36*(((dbits-1)/36)+1)) <= (others => '0');
  end generate;
  a10 : if (abits = 10) generate
    x : for i in 0 to ((dbits-1)/18) generate
      r : RAMB16_S18 port map ( do(((i+1)*18)-3 downto i*18),
	do(((i+1)*18)-1 downto i*18+16), xa(9 downto 0), clk,
	di(((i+1)*18)-3 downto i*18), di(((i+1)*18)-1 downto i*18+16),
	enable, gnd, write);
    end generate;
    do(dbits+72 downto 18*(((dbits-1)/18)+1)) <= (others => '0');
  end generate;
  a11 : if abits = 11 generate
    x : for i in 0 to ((dbits-1)/9) generate
      r : RAMB16_S9 port map ( do(((i+1)*9)-2 downto i*9),
	do(((i+1)*9)-1 downto i*9+8), xa(10 downto 0), clk,
	di(((i+1)*9)-2 downto i*9), di(((i+1)*9)-1 downto i*9+8),
	enable, gnd, write);
    end generate;
    do(dbits+72 downto 9*(((dbits-1)/9)+1)) <= (others => '0');
  end generate;
  a12 : if abits = 12 generate
    x : for i in 0 to ((dbits-1)/4) generate
      r : RAMB16_S4 port map ( do(((i+1)*4)-1 downto i*4), xa(11 downto 0),
	clk, di(((i+1)*4)-1 downto i*4), enable, gnd, write);
    end generate;
    do(dbits+72 downto 4*(((dbits-1)/4)+1)) <= (others => '0');
  end generate;
  a13 : if abits = 13 generate
    x : for i in 0 to ((dbits-1)/2) generate
      r : RAMB16_S2 port map ( do(((i+1)*2)-1 downto i*2), xa(12 downto 0),
	clk, di(((i+1)*2)-1 downto i*2), enable, gnd, write);
    end generate;
    do(dbits+72 downto 2*(((dbits-1)/2)+1)) <= (others => '0');
  end generate;
  a14 : if abits = 14 generate
    x : for i in 0 to (dbits-1) generate
      r : RAMB16_S1 port map ( do((i+1)-1 downto i), xa(13 downto 0),
	clk, di((i+1)-1 downto i), enable, gnd, write);
    end generate;
    do(dbits+72 downto dbits) <= (others => '0');
  end generate;

  a15 : if abits > 14 generate
    x: generic_syncram generic map (abits, dbits)
      port map (clk, address, datain, do(dbits-1 downto 0), write);
    do(dbits+72 downto dbits) <= (others => '0');
  end generate;

-- pragma translate_off
--  a_to_high : if abits > 14 generate
--    x : process
--    begin
--      assert false
--      report  "Address depth larger than 14 not supported for virtex2_syncram"
--      severity failure;
--      wait;
--    end process;
--  end generate;
-- pragma translate_on

end;

LIBRARY ieee;
use ieee.std_logic_1164.all;
--pragma translate_off
library unisim;
use unisim.RAMB16_S36_S36;
use unisim.RAMB16_S18_S18;
use unisim.RAMB16_S9_S9;
use unisim.RAMB16_S4_S4;
use unisim.RAMB16_S2_S2;
use unisim.RAMB16_S1_S1;
--pragma translate_on

entity virtex2_syncram_dp is
  generic (
    abits : integer := 4; dbits : integer := 32
  );
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
    write2   : in std_ulogic);
end;

architecture behav of virtex2_syncram_dp is

  component RAMB16_S4_S4
 port (
   DOA : out std_logic_vector (3 downto 0);
   DOB : out std_logic_vector (3 downto 0);
   ADDRA : in std_logic_vector (11 downto 0);
   ADDRB : in std_logic_vector (11 downto 0);
   CLKA : in std_ulogic;
   CLKB : in std_ulogic;
   DIA : in std_logic_vector (3 downto 0);
   DIB : in std_logic_vector (3 downto 0);
   ENA : in std_ulogic;
   ENB : in std_ulogic;
   SSRA : in std_ulogic;
   SSRB : in std_ulogic;
   WEA : in std_ulogic;
   WEB : in std_ulogic
 );
  end component;

  component RAMB16_S1_S1
 port (
   DOA : out std_logic_vector (0 downto 0);
   DOB : out std_logic_vector (0 downto 0);
   ADDRA : in std_logic_vector (13 downto 0);
   ADDRB : in std_logic_vector (13 downto 0);
   CLKA : in std_ulogic;
   CLKB : in std_ulogic;
   DIA : in std_logic_vector (0 downto 0);
   DIB : in std_logic_vector (0 downto 0);
   ENA : in std_ulogic;
   ENB : in std_ulogic;
   SSRA : in std_ulogic;
   SSRB : in std_ulogic;
   WEA : in std_ulogic;
   WEB : in std_ulogic
 );
  end component;

  component RAMB16_S2_S2
 port (
   DOA : out std_logic_vector (1 downto 0);
   DOB : out std_logic_vector (1 downto 0);
   ADDRA : in std_logic_vector (12 downto 0);
   ADDRB : in std_logic_vector (12 downto 0);
   CLKA : in std_ulogic;
   CLKB : in std_ulogic;
   DIA : in std_logic_vector (1 downto 0);
   DIB : in std_logic_vector (1 downto 0);
   ENA : in std_ulogic;
   ENB : in std_ulogic;
   SSRA : in std_ulogic;
   SSRB : in std_ulogic;
   WEA : in std_ulogic;
   WEB : in std_ulogic
 );
  end component;

  component RAMB16_S9_S9
 port (
   DOA : out std_logic_vector (7 downto 0);
   DOB : out std_logic_vector (7 downto 0);
   DOPA : out std_logic_vector (0 downto 0);
   DOPB : out std_logic_vector (0 downto 0);
   ADDRA : in std_logic_vector (10 downto 0);
   ADDRB : in std_logic_vector (10 downto 0);
   CLKA : in std_ulogic;
   CLKB : in std_ulogic;
   DIA : in std_logic_vector (7 downto 0);
   DIB : in std_logic_vector (7 downto 0);
   DIPA : in std_logic_vector (0 downto 0);
   DIPB : in std_logic_vector (0 downto 0);
   ENA : in std_ulogic;
   ENB : in std_ulogic;
   SSRA : in std_ulogic;
   SSRB : in std_ulogic;
   WEA : in std_ulogic;
   WEB : in std_ulogic
 );
end component;

  component RAMB16_S18_S18
  port (
    DOA : out std_logic_vector (15 downto 0);
    DOB : out std_logic_vector (15 downto 0);
    DOPA : out std_logic_vector (1 downto 0);
    DOPB : out std_logic_vector (1 downto 0);
    ADDRA : in std_logic_vector (9 downto 0);
    ADDRB : in std_logic_vector (9 downto 0);
    CLKA : in std_ulogic;
    CLKB : in std_ulogic;
    DIA : in std_logic_vector (15 downto 0);
    DIB : in std_logic_vector (15 downto 0);
    DIPA : in std_logic_vector (1 downto 0);
    DIPB : in std_logic_vector (1 downto 0);
    ENA : in std_ulogic;
    ENB : in std_ulogic;
    SSRA : in std_ulogic;
    SSRB : in std_ulogic;
    WEA : in std_ulogic;
    WEB : in std_ulogic);
  end component;

  component RAMB16_S36_S36
  port (
    DOA : out std_logic_vector (31 downto 0);
    DOB : out std_logic_vector (31 downto 0);
    DOPA : out std_logic_vector (3 downto 0);
    DOPB : out std_logic_vector (3 downto 0);
    ADDRA : in std_logic_vector (8 downto 0);
    ADDRB : in std_logic_vector (8 downto 0);
    CLKA : in std_ulogic;
    CLKB : in std_ulogic;
    DIA : in std_logic_vector (31 downto 0);
    DIB : in std_logic_vector (31 downto 0);
    DIPA : in std_logic_vector (3 downto 0);
    DIPB : in std_logic_vector (3 downto 0);
    ENA : in std_ulogic;
    ENB : in std_ulogic;
    SSRA : in std_ulogic;
    SSRB : in std_ulogic;
    WEA : in std_ulogic;
    WEB : in std_ulogic);
  end component;

signal gnd, vcc : std_ulogic;
signal do1, do2, di1, di2 : std_logic_vector(dbits+36 downto 0);
signal addr1, addr2 : std_logic_vector(19 downto 0);
begin
  gnd <= '0'; vcc <= '1';
  dataout1 <= do1(dbits-1 downto 0); dataout2 <= do2(dbits-1 downto 0);
  di1(dbits-1 downto 0) <= datain1; di1(dbits+36 downto dbits) <= (others => '0');
  di2(dbits-1 downto 0) <= datain2; di2(dbits+36 downto dbits) <= (others => '0');
  addr1(abits-1 downto 0) <= address1; addr1(19 downto abits) <= (others => '0');
  addr2(abits-1 downto 0) <= address2; addr2(19 downto abits) <= (others => '0');

  a9 : if abits <= 9 generate
    x : for i in 0 to ((dbits-1)/36) generate
      r0 : RAMB16_S36_S36 port map (
	do1(((i+1)*36)-5 downto i*36), do2(((i+1)*36)-5 downto i*36),
	do1(((i+1)*36)-1 downto i*36+32), do2(((i+1)*36)-1 downto i*36+32),
	addr1(8 downto 0), addr2(8 downto 0), clk1, clk2,
	di1(((i+1)*36)-5 downto i*36), di2(((i+1)*36)-5 downto i*36),
	di1(((i+1)*36)-1 downto i*36+32), di2(((i+1)*36)-1 downto i*36+32),
--	enable1, enable2, gnd, gnd, write1, write2);
	vcc, vcc, gnd, gnd, write1, write2);
    end generate;
    do1(dbits+36 downto 36*(((dbits-1)/36)+1)) <= (others => '0');
    do2(dbits+36 downto 36*(((dbits-1)/36)+1)) <= (others => '0');
  end generate;

  a10 : if abits = 10 generate
    x : for i in 0 to ((dbits-1)/18) generate
      r0 : RAMB16_S18_S18 port map (
	do1(((i+1)*18)-3 downto i*18), do2(((i+1)*18)-3 downto i*18),
	do1(((i+1)*18)-1 downto i*18+16), do2(((i+1)*18)-1 downto i*18+16),
	addr1(9 downto 0), addr2(9 downto 0), clk1, clk2,
	di1(((i+1)*18)-3 downto i*18), di2(((i+1)*18)-3 downto i*18),
	di1(((i+1)*18)-1 downto i*18+16), di2(((i+1)*18)-1 downto i*18+16),
	vcc, vcc, gnd, gnd, write1, write2);
--	enable1, enable2, gnd, gnd, write1, write2);
    end generate;
    do1(dbits+36 downto 18*(((dbits-1)/18)+1)) <= (others => '0');
    do2(dbits+36 downto 18*(((dbits-1)/18)+1)) <= (others => '0');
  end generate;

  a11 : if abits = 11 generate
    x : for i in 0 to ((dbits-1)/9) generate
      r0 : RAMB16_S9_S9 port map (
	do1(((i+1)*9)-2 downto i*9), do2(((i+1)*9)-2 downto i*9),
	do1(((i+1)*9)-1 downto i*9+8), do2(((i+1)*9)-1 downto i*9+8),
	addr1(10 downto 0), addr2(10 downto 0), clk1, clk2,
	di1(((i+1)*9)-2 downto i*9), di2(((i+1)*9)-2 downto i*9),
	di1(((i+1)*9)-1 downto i*9+8), di2(((i+1)*9)-1 downto i*9+8),
	vcc, vcc, gnd, gnd, write1, write2);
--	enable1, enable2, gnd, gnd, write1, write2);
    end generate;
    do1(dbits+36 downto 9*(((dbits-1)/9)+1)) <= (others => '0');
    do2(dbits+36 downto 9*(((dbits-1)/9)+1)) <= (others => '0');
  end generate;

  a12 : if abits = 12 generate
    x : for i in 0 to ((dbits-1)/4) generate
      r0 : RAMB16_S4_S4 port map (
	do1(((i+1)*4)-1 downto i*4), do2(((i+1)*4)-1 downto i*4),
	addr1(11 downto 0), addr2(11 downto 0), clk1, clk2,
	di1(((i+1)*4)-1 downto i*4), di2(((i+1)*4)-1 downto i*4),
	vcc, vcc, gnd, gnd, write1, write2);
--	enable1, enable2, gnd, gnd, write1, write2);
    end generate;
    do1(dbits+36 downto 4*(((dbits-1)/4)+1)) <= (others => '0');
    do2(dbits+36 downto 4*(((dbits-1)/4)+1)) <= (others => '0');
  end generate;

  a13 : if abits = 13 generate
    x : for i in 0 to ((dbits-1)/2) generate
      r0 : RAMB16_S2_S2 port map (
	do1(((i+1)*2)-1 downto i*2), do2(((i+1)*2)-1 downto i*2),
	addr1(12 downto 0), addr2(12 downto 0), clk1, clk2,
	di1(((i+1)*2)-1 downto i*2), di2(((i+1)*2)-1 downto i*2),
	vcc, vcc, gnd, gnd, write1, write2);
--	enable1, enable2, gnd, gnd, write1, write2);
    end generate;
    do1(dbits+36 downto 2*(((dbits-1)/2)+1)) <= (others => '0');
    do2(dbits+36 downto 2*(((dbits-1)/2)+1)) <= (others => '0');
  end generate;

  a14 : if abits = 14 generate
    x : for i in 0 to ((dbits-1)/1) generate
      r0 : RAMB16_S1_S1 port map (
	do1(((i+1)*1)-1 downto i*1), do2(((i+1)*1)-1 downto i*1),
	addr1(13 downto 0), addr2(13 downto 0), clk1, clk2,
	di1(((i+1)*1)-1 downto i*1), di2(((i+1)*1)-1 downto i*1),
	vcc, vcc, gnd, gnd, write1, write2);
--	enable1, enable2, gnd, gnd, write1, write2);
    end generate;
    do1(dbits+36 downto dbits) <= (others => '0');
    do2(dbits+36 downto dbits) <= (others => '0');
  end generate;

-- pragma translate_off
  a_to_high : if abits > 14 generate
    x : process
    begin
      assert false
      report  "Address depth larger than 14 not supported for virtex2_syncram_dp"
      severity failure;
      wait;
    end process;
  end generate;
-- pragma translate_on

end;

library ieee;
use ieee.std_logic_1164.all;

entity virtex2_syncram_2p is
  generic (abits : integer := 6; dbits : integer := 8; sepclk : integer := 0;
		 wrfst : integer := 0);
  port (
    rclk     : in std_ulogic;
    renable  : in std_ulogic;
    raddress : in std_logic_vector((abits -1) downto 0);
    dataout  : out std_logic_vector((dbits -1) downto 0);
    wclk     : in std_ulogic;
    write    : in std_ulogic;
    waddress : in std_logic_vector((abits -1) downto 0);
    datain   : in std_logic_vector((dbits -1) downto 0));
end;

architecture behav of virtex2_syncram_2p is

  component virtex2_syncram_dp
  generic ( abits : integer := 10; dbits : integer := 8 );
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

component generic_syncram_2p
  generic (abits : integer := 8; dbits : integer := 32; sepclk : integer := 0);
  port (
    rclk : in std_ulogic;
    wclk : in std_ulogic;
    rdaddress: in std_logic_vector (abits -1 downto 0);
    wraddress: in std_logic_vector (abits -1 downto 0);
    data: in std_logic_vector (dbits -1 downto 0);
    wren : in std_ulogic;
    q: out std_logic_vector (dbits -1 downto 0)
  );
end component;

signal write2, renable2 : std_ulogic;
signal datain2 : std_logic_vector((dbits-1) downto 0); 
begin

    nowf: if wrfst = 0 generate 
      write2 <= '0'; renable2 <= renable; datain2 <= (others => '0');
    end generate;
    
    wf : if wrfst = 1 generate
      write2 <= '0' when (waddress /= raddress) else write;
      renable2 <= renable or write2; datain2 <= datain;
    end generate;

    a0 : if abits <= 5 generate
      x0 :  generic_syncram_2p generic map (abits, dbits, sepclk)
  	port map (rclk, wclk, raddress, waddress, datain, write, dataout);
    end generate;

    a6 : if abits > 5 generate
      x0 : virtex2_syncram_dp generic map (abits, dbits)
         port map (wclk, waddress, datain, open, write, write, 
                   rclk, raddress, datain2, dataout, renable2, write2);
    end generate;
end;

-- parametrisable sync ram generator using virtex2 block rams

library ieee;
use ieee.std_logic_1164.all;
--pragma translate_off
library unisim;
use unisim.RAMB16_S36_S36;
--pragma translate_on

entity virtex2_syncram64 is
  generic ( abits : integer := 9);
  port (
    clk     : in  std_ulogic;
    address : in  std_logic_vector (abits -1 downto 0);
    datain  : in  std_logic_vector (63 downto 0);
    dataout : out std_logic_vector (63 downto 0);
    enable  : in  std_logic_vector (1 downto 0);
    write   : in  std_logic_vector (1 downto 0)
  );
end;

architecture behav of virtex2_syncram64 is
component virtex2_syncram
  generic ( abits : integer := 9; dbits : integer := 32);
  port (
    clk     : in std_ulogic;
    address : in std_logic_vector (abits -1 downto 0);
    datain  : in std_logic_vector (dbits -1 downto 0);
    dataout : out std_logic_vector (dbits -1 downto 0);
    enable  : in std_ulogic;
    write   : in std_ulogic
  );
end component;
  component RAMB16_S36_S36
  port (
    DOA : out std_logic_vector (31 downto 0);
    DOB : out std_logic_vector (31 downto 0);
    DOPA : out std_logic_vector (3 downto 0);
    DOPB : out std_logic_vector (3 downto 0);
    ADDRA : in std_logic_vector (8 downto 0);
    ADDRB : in std_logic_vector (8 downto 0);
    CLKA : in std_ulogic;
    CLKB : in std_ulogic;
    DIA : in std_logic_vector (31 downto 0);
    DIB : in std_logic_vector (31 downto 0);
    DIPA : in std_logic_vector (3 downto 0);
    DIPB : in std_logic_vector (3 downto 0);
    ENA : in std_ulogic;
    ENB : in std_ulogic;
    SSRA : in std_ulogic;
    SSRB : in std_ulogic;
    WEA : in std_ulogic;
    WEB : in std_ulogic);
  end component;

signal gnd : std_logic_vector(3 downto 0);
signal xa, ya : std_logic_vector(19 downto 0);
begin

  gnd <= "0000"; 
  xa(abits-1 downto 0) <= address; xa(19 downto abits) <= (others => '0');
  ya(abits-1 downto 0) <= address; ya(19 downto abits) <= (others => '1');

  a8 : if abits <= 8 generate
    r0 : RAMB16_S36_S36 port map (
	dataout(63 downto 32), dataout(31 downto 0), open, open,
	xa(8 downto 0), ya(8 downto 0), clk, clk,
	datain(63 downto 32), datain(31 downto 0), gnd, gnd,
	enable(1), enable(0), gnd(0), gnd(0), write(1), write(0));
  end generate;
  a9 : if abits > 8 generate
    x1 : virtex2_syncram generic map ( abits, 32)
         port map (clk, address, datain(63 downto 32), dataout(63 downto 32),
	           enable(1), write(1));
    x2 : virtex2_syncram generic map ( abits, 32)
         port map (clk, address, datain(31 downto 0), dataout(31 downto 0),
	           enable(0), write(0));
  end generate;
end;
