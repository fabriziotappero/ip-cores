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

-- pragma translate_on

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity RAM64K36 is port(
        DEPTH3, DEPTH2, DEPTH1, DEPTH0,
        WRAD15, WRAD14, WRAD13, WRAD12, WRAD11, WRAD10, WRAD9 ,
        WRAD8 , WRAD7 , WRAD6 , WRAD5 , WRAD4 , WRAD3 , WRAD2 ,
        WRAD1 , WRAD0 , WD35  , WD34  , WD33  , WD32  , WD31  ,
        WD30  , WD29  , WD28  , WD27  , WD26  , WD25  , WD24  ,
        WD23  , WD22  , WD21  , WD20  , WD19  , WD18  , WD17  ,
        WD16  , WD15  , WD14  , WD13  , WD12  , WD11  , WD10  ,
        WD9   , WD8   , WD7   , WD6   , WD5   , WD4   , WD3   ,
        WD2   , WD1   , WD0   , WW2   , WW1   , WW0   , WEN   ,
        WCLK  , RDAD15, RDAD14, RDAD13, RDAD12, RDAD11, RDAD10,
        RDAD9 , RDAD8 , RDAD7 , RDAD6 , RDAD5 , RDAD4 , RDAD3 ,
        RDAD2 , RDAD1 , RDAD0 , RW2   , RW1   , RW0   , REN   ,
        RCLK   : in  std_ulogic ;
        RD35  , RD34  , RD33  , RD32  , RD31  , RD30  , RD29  ,
        RD28  , RD27  , RD26  , RD25  , RD24  , RD23  , RD22  ,
        RD21  , RD20  , RD19  , RD18  , RD17  , RD16  , RD15  ,
        RD14  , RD13  , RD12  , RD11  , RD10  , RD9   , RD8   ,
        RD7   , RD6   , RD5   , RD4   , RD3   , RD2   , RD1   ,
        RD0    : out std_ulogic);
end;

architecture rtl of RAM64K36 is
  signal re : std_ulogic;
begin

  rp : process(RCLK, WCLK)
  constant words : integer := 2**16;
  subtype word is std_logic_vector(35 downto 0);
  type dregtype is array (0 to words - 1) of word;
  variable rfd : dregtype;
  variable wa, ra : std_logic_vector(15 downto 0);
  variable q : std_logic_vector(35 downto 0);
  begin
    if rising_edge(RCLK) then
      ra := RDAD15 & RDAD14 & RDAD13 & RDAD12 & RDAD11 & RDAD10 & RDAD9 &
            RDAD8 & RDAD7 & RDAD6 & RDAD5 & RDAD4 & RDAD3 & RDAD2 & RDAD1 & RDAD0;
      if not (is_x (ra)) and REN = '1' then 
        q := rfd(to_integer(unsigned(ra)) mod words);
      else q := (others => 'X'); end if;
    end if;
    if rising_edge(WCLK) and (wen = '1') then
      wa := WRAD15 & WRAD14 & WRAD13 & WRAD12 & WRAD11 & WRAD10 & WRAD9 &
            WRAD8 & WRAD7 & WRAD6 & WRAD5 & WRAD4 & WRAD3 & WRAD2 & WRAD1 & WRAD0;
      if not is_x (wa) then 
   	rfd(to_integer(unsigned(wa)) mod words) :=
          WD35 & WD34 & WD33 & WD32 & WD31 & WD30 & WD29 & WD28 & WD27 &
	  WD26 & WD25 & WD24 & WD23 & WD22 & WD21 & WD20 & WD19 & WD18 &
	  WD17 & WD16 & WD15 & WD14 & WD13 & WD12 & WD11 & WD10 & WD9 &
	  WD8 & WD7 & WD6 & WD5 & WD4 & WD3 & WD2 & WD1 & WD0;
      end if;
      if ra = wa then q := (others => 'X'); end if;  -- no write-through
    end if;
    RD35 <= q(35); RD34 <= q(34); RD33 <= q(33); RD32 <= q(32); RD31 <= q(31);
    RD30 <= q(30); RD29 <= q(29); RD28 <= q(28); RD27 <= q(27); RD26 <= q(26);
    RD25 <= q(25); RD24 <= q(24); RD23 <= q(23); RD22 <= q(22); RD21 <= q(21);
    RD20 <= q(20); RD19 <= q(19); RD18 <= q(18); RD17 <= q(17); RD16 <= q(16);
    RD15 <= q(15); RD14 <= q(14); RD13 <= q(13); RD12 <= q(12); RD11 <= q(11);
    RD10 <= q(10); RD9 <= q(9); RD8 <= q(8); RD7 <= q(7); RD6 <= q(6);
    RD5 <= q(5); RD4 <= q(4); RD3 <= q(3); RD2 <= q(2); RD1 <= q(1);
    RD0 <= q(0);
  end process;
end;

-- PCI PADS ----------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
entity hclkbuf_pci is port( pad : in  std_logic; y   : out std_logic); end; 
architecture struct of hclkbuf_pci is begin y <= to_X01(pad); end;

library ieee;
use ieee.std_logic_1164.all;
entity clkbuf_pci is port( pad : in  std_logic; y   : out std_logic); end; 
architecture struct of clkbuf_pci is begin y <= to_X01(pad); end;

library ieee;
use ieee.std_logic_1164.all;
entity inbuf_pci is port( pad : in  std_logic; y   : out std_logic); end; 
architecture struct of inbuf_pci is begin y <= to_X01(pad) after 2 ns; end;

library ieee;
use ieee.std_logic_1164.all;
entity bibuf_pci is port
  (d, e : in  std_logic; pad : inout std_logic; y : out std_logic);
end; 
architecture struct of bibuf_pci is begin 
  y <= to_X01(pad) after 2 ns;
  pad <= d after 5 ns when to_X01(e) = '1' else
	 'Z' after 5 ns when to_X01(e) = '0' else 'X' after 5 ns;
end;

library ieee;
use ieee.std_logic_1164.all;
entity tribuff_pci is port (d, e : in  std_logic; pad : out std_logic ); end; 
architecture struct of tribuff_pci is begin 
  pad <= d after 5 ns when to_X01(e) = '1' else
	 'Z' after 5 ns when to_X01(e) = '0' else 'X' after 5 ns;
end;

library ieee;
use ieee.std_logic_1164.all;
entity outbuf_pci is port (d : in  std_logic; pad : out std_logic ); end; 
architecture struct of outbuf_pci is begin pad <= d after 5 ns; end;

-- STANDARD PADS ----------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
entity clkbuf is port( pad : in  std_logic; y   : out std_logic); end; 
architecture struct of clkbuf is begin y <= to_X01(pad); end;

library ieee;
use ieee.std_logic_1164.all;
entity hclkbuf is port( pad : in  std_logic; y   : out std_logic); end; 
architecture struct of hclkbuf is begin y <= to_X01(pad); end;

library ieee;
use ieee.std_logic_1164.all;
entity inbuf is port( pad : in  std_logic; y   : out std_logic); end; 
architecture struct of inbuf is begin y <= to_X01(pad) after 1 ns; end;

library ieee;
use ieee.std_logic_1164.all;
entity bibuf is port
  (d, e : in  std_logic; pad : inout std_logic; y : out std_logic);
end; 
architecture struct of bibuf is begin 
  y <= to_X01(pad) after 2 ns;
  pad <= d after 2 ns when to_X01(e) = '1' else
	 'Z' after 2 ns when to_X01(e) = '0' else 'X' after 2 ns;
end;

library ieee;
use ieee.std_logic_1164.all;
entity tribuff is port (d, e : in  std_logic; pad : out std_logic ); end; 
architecture struct of tribuff is begin 
  pad <= d after 2 ns when to_X01(e) = '1' else
	 'Z' after 2 ns when to_X01(e) = '0' else 'X' after 2 ns;
end;

library ieee;
use ieee.std_logic_1164.all;
entity outbuf is port (d : in  std_logic; pad : out std_logic ); end; 
architecture struct of outbuf is begin pad <= d after 2 ns; end;

library ieee;
use ieee.std_logic_1164.all;
entity outbuf_f_8 is port (d : in  std_logic; pad : out std_logic ); end; 
architecture struct of outbuf_f_8 is begin pad <= d after 2 ns; end;

library ieee;
use ieee.std_logic_1164.all;
entity outbuf_f_12 is port (d : in  std_logic; pad : out std_logic ); end; 
architecture struct of outbuf_f_12 is begin pad <= d after 2 ns; end;

library ieee;
use ieee.std_logic_1164.all;
entity outbuf_f_16 is port (d : in  std_logic; pad : out std_logic ); end; 
architecture struct of outbuf_f_16 is begin pad <= d after 2 ns; end;

library ieee;
use ieee.std_logic_1164.all;
entity outbuf_f_24 is port (d : in  std_logic; pad : out std_logic ); end; 
architecture struct of outbuf_f_24 is begin pad <= d after 2 ns; end;

library ieee;
use ieee.std_logic_1164.all;
entity inbuf_lvds is port( y : out std_logic; padp, padn : in  std_logic); end; 
architecture struct of inbuf_lvds is 
signal yn : std_ulogic := '0';
begin 
  yn <= to_X01(padp) after 1 ns when to_x01(padp xor padn) = '1' else yn after 1 ns;
  y <= yn;
end;

library ieee;
use ieee.std_logic_1164.all;
entity outbuf_lvds is port (d : in  std_logic; padp, padn : out std_logic ); end; 
architecture struct of outbuf_lvds is begin 
  padp <= d after 1 ns; 
  padn <= not d after 1 ns; 
end;

-- clock buffers ----------------------

library ieee;
use ieee.std_logic_1164.all;
entity hclkint is port( a : in  std_logic; y   : out std_logic); end; 
architecture struct of hclkint is begin y <= to_X01(a); end;

library ieee;
use ieee.std_logic_1164.all;
entity clkint is port( a : in  std_logic; y   : out std_logic); end; 
architecture struct of clkint is begin y <= to_X01(a); end;

library ieee;
use ieee.std_logic_1164.all;
entity add1 is
   port(
   a : in std_logic;
   b : in std_logic;
   fci : in std_logic;
   s : out std_logic;
   fco : out std_logic);
end add1;
architecture beh of add1 is
   signal un1_fco : std_logic;
   signal un2_fco : std_logic;
   signal un3_fco : std_logic;
begin
   s <= a xor b xor fci;
   un1_fco <= a and b;
   un2_fco <= a and fci;
   un3_fco <= b and fci;
   fco <= un1_fco or un2_fco or un3_fco;
end beh;


library ieee;
use ieee.std_logic_1164.all;
entity and2 is
   port(
   a : in std_logic;
   b : in std_logic;
   y : out std_logic);
end and2;
architecture beh of and2 is
begin
   y <= b and a;
end beh;


library ieee;
use ieee.std_logic_1164.all;
entity and2a is
   port(
   a : in std_logic;
   b : in std_logic;
   y : out std_logic);
end and2a;
architecture beh of and2a is
   signal ai : std_logic;
begin
   ai <= not a;
   y <= b and ai;
end beh;


library ieee;
use ieee.std_logic_1164.all;
entity and2b is
   port(
   a : in std_logic;
   b : in std_logic;
   y : out std_logic);
end and2b;
architecture beh of and2b is
   signal ai : std_logic;
   signal bi : std_logic;
begin
   ai <= not a;
   bi <= not b;
   y <= bi and ai;
end beh;


library ieee;
use ieee.std_logic_1164.all;
entity and3 is
   port(
   a : in std_logic;
   b : in std_logic;
   c : in std_logic;
   y : out std_logic);
end and3;
architecture beh of and3 is
begin
   y <= c and b and a;
end beh;


library ieee;
use ieee.std_logic_1164.all;
entity and3a is
   port(
   a : in std_logic;
   b : in std_logic;
   c : in std_logic;
   y : out std_logic);
end and3a;
architecture beh of and3a is
   signal ai : std_logic;
begin
   ai <= not a;
   y <= c and b and ai;
end beh;


library ieee;
use ieee.std_logic_1164.all;
entity and3b is
   port(
   a : in std_logic;
   b : in std_logic;
   c : in std_logic;
   y : out std_logic);
end and3b;
architecture beh of and3b is
   signal ai : std_logic;
   signal bi : std_logic;
begin
   ai <= not a;
   bi <= not b;
   y <= c and bi and ai;
end beh;


library ieee;
use ieee.std_logic_1164.all;
entity and3c is
   port(
   a : in std_logic;
   b : in std_logic;
   c : in std_logic;
   y : out std_logic);
end and3c;
architecture beh of and3c is
   signal ai : std_logic;
   signal bi : std_logic;
   signal ci : std_logic;
begin
   ai <= not a;
   bi <= not b;
   ci <= not c;
   y <= ci and bi and ai;
end beh;


library ieee;
use ieee.std_logic_1164.all;
entity and4 is
   port(
   a : in std_logic;
   b : in std_logic;
   c : in std_logic;
   d : in std_logic;
   y : out std_logic);
end and4;
architecture beh of and4 is
begin
   y <= d and c and b and a;
end beh;


library ieee;
use ieee.std_logic_1164.all;
entity and4a is
   port(
   a : in std_logic;
   b : in std_logic;
   c : in std_logic;
   d : in std_logic;
   y : out std_logic);
end and4a;
architecture beh of and4a is
   signal ai : std_logic;
begin
   ai <= not a;
   y <= d and c and b and ai;
end beh;


library ieee;
use ieee.std_logic_1164.all;
entity and4b is
   port(
   a : in std_logic;
   b : in std_logic;
   c : in std_logic;
   d : in std_logic;
   y : out std_logic);
end and4b;
architecture beh of and4b is
   signal ai : std_logic;
   signal bi : std_logic;
begin
   ai <= not a;
   bi <= not b;
   y <= d and c and bi and ai;
end beh;


library ieee;
use ieee.std_logic_1164.all;
entity and4c is
   port(
   a : in std_logic;
   b : in std_logic;
   c : in std_logic;
   d : in std_logic;
   y : out std_logic);
end and4c;
architecture beh of and4c is
   signal ai : std_logic;
   signal bi : std_logic;
   signal ci : std_logic;
begin
   ai <= not a;
   bi <= not b;
   ci <= not c;
   y <= d and ci and bi and ai;
end beh;


library ieee;
use ieee.std_logic_1164.all;
entity buff is
   port(
   a : in std_logic;
   y : out std_logic);
end buff;
architecture beh of buff is
begin
   y <= a;
end beh;

library ieee;
use ieee.std_logic_1164.all;
entity cm8 is
   port(
   d0 : in std_logic;
   d1 : in std_logic;
   d2 : in std_logic;
   d3 : in std_logic;
   s00 : in std_logic;
   s01 : in std_logic;
   s10 : in std_logic;
   s11 : in std_logic;
   y : out std_logic);
end cm8;
architecture beh of cm8 is
   signal s0 : std_logic;
   signal s1 : std_logic;
   signal m0 : std_logic;
   signal m1 : std_logic;
begin
   s0 <= s01 and s00;
   s1 <= s11 or s10;
   m0 <= d0 when s0 = '0' else d1;
   m1 <= d2 when s0 = '0' else d3;
   y <= m0 when s1 = '0' else m1;
end beh;


library ieee;
use ieee.std_logic_1164.all;
entity cm8inv is
   port(
   a : in std_logic;
   y : out std_logic);
end cm8inv;
architecture beh of cm8inv is
begin
   y <= not a;
end beh;


library ieee;
use ieee.std_logic_1164.all;
entity df1 is
   port(
   d : in std_logic;
   clk : in std_logic;
   q : out std_logic);
end df1;
architecture beh of df1 is
begin
    ff : process (clk)
    begin
      if rising_edge(clk) then
         q <= d;
      end if;
    end process ff;
end beh;


library ieee;
use ieee.std_logic_1164.all;
entity dfc1b is
   port(
   d : in std_logic;
   clk : in std_logic;
   clr : in std_logic;
   q : out std_logic);
end dfc1b;
architecture beh of dfc1b is
begin
   ff : process (clk, clr)
   begin
     if clr = '0' then
        q <= '0';
     elsif rising_edge(clk) then
        q <= d;
     end if;
   end process ff;
end beh;

library ieee;
use ieee.std_logic_1164.all;
entity dfc1c is
   port(
   d : in std_logic;
   clk : in std_logic;
   clr : in std_logic;
   q : out std_logic);
end dfc1c;
architecture beh of dfc1c is
begin
   ff : process (clk, clr)
   begin
     if clr = '1' then
        q <= '1';
     elsif rising_edge(clk) then
        q <= not d;
     end if;
   end process ff;
end beh;

library ieee;
use ieee.std_logic_1164.all;
entity dfc1d is
   port(
   d : in std_logic;
   clk : in std_logic;
   clr : in std_logic;
   q : out std_logic);
end dfc1d;
architecture beh of dfc1d is
begin
   ff : process (clk, clr)
   begin
     if clr = '0' then
        q <= '0';
     elsif falling_edge(clk) then
        q <= d;
     end if;
   end process ff;
end beh;

library ieee;
use ieee.std_logic_1164.all;
entity dfe1b is
   port(
   d : in std_logic;
   e : in std_logic;
   clk : in std_logic;
   q : out std_logic);
end dfe1b;
architecture beh of dfe1b is
   signal q_int_1 : std_logic;
   signal nq : std_logic;
begin
   nq <= d when e = '0' else q_int_1;
   q <= q_int_1;
   ff : process (clk)
   begin
     if rising_edge(clk) then
        q_int_1 <= nq;
     end if;
   end process ff;
end beh;


library ieee;
use ieee.std_logic_1164.all;
entity dfe3c is
   port(
   d : in std_logic;
   e : in std_logic;
   clk : in std_logic;
   clr : in std_logic;
   q : out std_logic);
end dfe3c;
architecture beh of dfe3c is
   signal q_int_0 : std_logic;
   signal md : std_logic;
begin
   md <= d when e = '0' else q_int_0;
   q <= q_int_0;
   ff : process (clk, clr)
   begin
     if clr = '0' then
        q_int_0 <= '0';
     elsif rising_edge(clk) then
        q_int_0 <= md;
     end if;
   end process ff;
end beh;


library ieee;
use ieee.std_logic_1164.all;
entity dfe4f is
   port(
   d : in std_logic;
   e : in std_logic;
   clk : in std_logic;
   pre : in std_logic;
   q : out std_logic);
end dfe4f;
architecture beh of dfe4f is
   signal q_int_1 : std_logic;
   signal un1 : std_logic;
begin
   un1 <= d when e = '0' else q_int_1;
   q <= q_int_1;
   ff : process (clk, pre)
   begin
     if pre = '0' then
        q_int_1 <= '1';
     elsif rising_edge(clk) then
        q_int_1 <= un1;
     end if;
   end process ff;
end beh;


library ieee;
use ieee.std_logic_1164.all;
entity dfp1 is
   port(
   d : in std_logic;
   clk : in std_logic;
   pre : in std_logic;
   q : out std_logic);
end dfp1;
architecture beh of dfp1 is
begin
   ff : process (clk, pre)
   begin
     if pre = '1' then
        q <= '1';
     elsif rising_edge(clk) then
        q <= d;
     end if;
   end process ff;
end beh;


library ieee;
use ieee.std_logic_1164.all;
entity dfp1b is
   port(
   d : in std_logic;
   clk : in std_logic;
   pre : in std_logic;
   q : out std_logic);
end dfp1b;
architecture beh of dfp1b is
begin
   ff : process (clk, pre)
   begin
     if pre = '0' then
        q <= '1';
     elsif rising_edge(clk) then
        q <= d;
     end if;
   end process ff;
end beh;


library ieee;
use ieee.std_logic_1164.all;
entity dfp1d is
   port(
   d : in std_logic;
   clk : in std_logic;
   pre : in std_logic;
   q : out std_logic);
end dfp1d;
architecture beh of dfp1d is
begin
   ff : process (clk, pre)
   begin
     if pre = '0' then
        q <= '1';
     elsif falling_edge(clk) then
        q <= d;
     end if;
   end process ff;
end beh;


library ieee;
use ieee.std_logic_1164.all;
entity gnd is
   port(
   y : out std_logic);
end gnd;
architecture beh of gnd is
begin
   y <= '0';
end beh;

library ieee;
use ieee.std_logic_1164.all;
entity dfm is
   port(
      clk : in std_logic;
      s	: in std_logic;
      a	: in std_logic;
      b	: in std_logic;
      q	: out std_logic);
end dfm;
architecture beh of dfm is
begin
   ff : process (clk)
   begin
     if rising_edge(clk) then
	if s = '0' then q <= a;
	else q <= b; end if;
     end if;
   end process ff;
end beh;

--
--library ieee;
--use ieee.std_logic_1164.all;
--entity hclkbuf is
--   port(
--   pad : in std_logic;
--   y : out std_logic);
--end hclkbuf;
--architecture beh of hclkbuf is
--begin
--   y <= pad;
--end beh;
--
--
--library ieee;
--use ieee.std_logic_1164.all;
--entity inbuf is
--   port(
--   pad : in std_logic;
--   y : out std_logic);
--end inbuf;
--architecture beh of inbuf is
--begin
--   y <= pad;
--end beh;


library ieee;
use ieee.std_logic_1164.all;
entity inv is
   port(
   a : in std_logic;
   y : out std_logic);
end inv;
architecture beh of inv is
begin
   y <= not a;
end beh;


library ieee;
use ieee.std_logic_1164.all;
entity nand4 is
   port(
   a : in std_logic;
   b : in std_logic;
   c : in std_logic;
   d : in std_logic;
   y : out std_logic);
end nand4;
architecture beh of nand4 is
   signal yx : std_logic;
begin
   yx <= d and c and b and a;
   y <= not yx;
end beh;


library ieee;
use ieee.std_logic_1164.all;
entity or2 is
   port(
   a : in std_logic;
   b : in std_logic;
   y : out std_logic);
end or2;
architecture beh of or2 is
begin
   y <= b or a;
end beh;


library ieee;
use ieee.std_logic_1164.all;
entity or2a is
   port(
   a : in std_logic;
   b : in std_logic;
   y : out std_logic);
end or2a;
architecture beh of or2a is
   signal ai : std_logic;
begin
   ai <= not a;
   y <= b or ai;
end beh;


library ieee;
use ieee.std_logic_1164.all;
entity or2b is
   port(
   a : in std_logic;
   b : in std_logic;
   y : out std_logic);
end or2b;
architecture beh of or2b is
   signal ai : std_logic;
   signal bi : std_logic;
begin
   ai <= not a;
   bi <= not b;
   y <= bi or ai;
end beh;


library ieee;
use ieee.std_logic_1164.all;
entity or3 is
   port(
   a : in std_logic;
   b : in std_logic;
   c : in std_logic;
   y : out std_logic);
end or3;
architecture beh of or3 is
begin
   y <= c or b or a;
end beh;


library ieee;
use ieee.std_logic_1164.all;
entity or3a is
   port(
   a : in std_logic;
   b : in std_logic;
   c : in std_logic;
   y : out std_logic);
end or3a;
architecture beh of or3a is
   signal ai : std_logic;
begin
   ai <= not a;
   y <= c or b or ai;
end beh;


library ieee;
use ieee.std_logic_1164.all;
entity or3b is
   port(
   a : in std_logic;
   b : in std_logic;
   c : in std_logic;
   y : out std_logic);
end or3b;
architecture beh of or3b is
   signal ai : std_logic;
   signal bi : std_logic;
begin
   ai <= not a;
   bi <= not b;
   y <= c or bi or ai;
end beh;


library ieee;
use ieee.std_logic_1164.all;
entity or3c is
   port(
   a : in std_logic;
   b : in std_logic;
   c : in std_logic;
   y : out std_logic);
end or3c;
architecture beh of or3c is
   signal ai : std_logic;
   signal bi : std_logic;
   signal ci : std_logic;
begin
   ai <= not a;
   bi <= not b;
   ci <= not c;
   y <= ci or bi or ai;
end beh;


library ieee;
use ieee.std_logic_1164.all;
entity or4 is
   port(
   a : in std_logic;
   b : in std_logic;
   c : in std_logic;
   d : in std_logic;
   y : out std_logic);
end or4;
architecture beh of or4 is
begin
   y <= d or c or b or a;
end beh;


library ieee;
use ieee.std_logic_1164.all;
entity or4a is
   port(
   a : in std_logic;
   b : in std_logic;
   c : in std_logic;
   d : in std_logic;
   y : out std_logic);
end or4a;
architecture beh of or4a is
   signal ai : std_logic;
begin
   ai <= not a;
   y <= d or c or b or ai;
end beh;


library ieee;
use ieee.std_logic_1164.all;
entity or4b is
   port(
   a : in std_logic;
   b : in std_logic;
   c : in std_logic;
   d : in std_logic;
   y : out std_logic);
end or4b;
architecture beh of or4b is
   signal ai : std_logic;
   signal bi : std_logic;
begin
   ai <= not a;
   bi <= not b;
   y <= d or c or bi or ai;
end beh;


library ieee;
use ieee.std_logic_1164.all;
entity or4c is
   port(
   a : in std_logic;
   b : in std_logic;
   c : in std_logic;
   d : in std_logic;
   y : out std_logic);
end or4c;
architecture beh of or4c is
   signal ai : std_logic;
   signal bi : std_logic;
   signal ci : std_logic;
begin
   ai <= not a;
   bi <= not b;
   ci <= not c;
   y <= d or ci or bi or ai;
end beh;


library ieee;
use ieee.std_logic_1164.all;
entity or4d is
   port(
   a : in std_logic;
   b : in std_logic;
   c : in std_logic;
   d : in std_logic;
   y : out std_logic);
end or4d;
architecture beh of or4d is
   signal ai : std_logic;
   signal bi : std_logic;
   signal ci : std_logic;
   signal di : std_logic;
begin
   ai <= not a;
   bi <= not b;
   ci <= not c;
   di <= not d;
   y <= di or ci or bi or ai;
end beh;

library ieee;
use ieee.std_logic_1164.all;
entity sub1 is
   port(
   a : in std_logic;
   b : in std_logic;
   fci : in std_logic;
   s : out std_logic;
   fco : out std_logic);
end sub1;
architecture beh of sub1 is
   signal un1_b : std_logic;
   signal un3_fco : std_logic;
   signal un1_fco : std_logic;
   signal un4_fco : std_logic;
begin
   un1_b <= not b;
   un3_fco <= a and fci;
   s <= a xor fci xor un1_b;
   un1_fco <= a and un1_b;
   un4_fco <= fci and un1_b;
   fco <= un1_fco or un3_fco or un4_fco;
end beh;


library ieee;
use ieee.std_logic_1164.all;
entity vcc is
   port(
   y : out std_logic);
end vcc;
architecture beh of vcc is
begin
   y <= '1';
end beh;


library ieee;
use ieee.std_logic_1164.all;
entity xa1 is
   port(
   a : in std_logic;
   b : in std_logic;
   c : in std_logic;
   y : out std_logic);
end xa1;
architecture beh of xa1 is
   signal xab : std_logic;
begin
   xab <= b xor a;
   y <= c and xab;
end beh;


library ieee;
use ieee.std_logic_1164.all;
entity xnor2 is
   port(
   a : in std_logic;
   b : in std_logic;
   y : out std_logic);
end xnor2;
architecture beh of xnor2 is
   signal yi : std_logic;
begin
   yi <= b xor a;
   y <= not yi;
end beh;


library ieee;
use ieee.std_logic_1164.all;
entity xor2 is
   port(
   a : in std_logic;
   b : in std_logic;
   y : out std_logic);
end xor2;
architecture beh of xor2 is
begin
   y <= b xor a;
end beh;


library ieee;
use ieee.std_logic_1164.all;
entity xor4 is
   port(a,b,c,d : in std_logic;
     y : out std_logic);
end xor4;
architecture beh of xor4 is
   signal xab, xcd : std_logic;
begin
   xab <= b xor a;
   xcd <= c xor d;
   y <= xab xor xcd;
end beh;

library ieee;
use ieee.std_logic_1164.all;
entity mx2 is
   port(
   a : in std_logic;
   s : in std_logic;
   b : in std_logic;
   y : out std_logic);
end mx2;
architecture beh of mx2 is
   signal xab : std_logic;
begin
   y <= b when s = '0' else a;
end beh;


-- pragma translate_on

