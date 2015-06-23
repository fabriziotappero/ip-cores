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
-- File:	mem_axcelerator_gen.vhd
-- Author:	Jiri Gaisler Gaisler Research
-- Description:	Memory generators for Actel AX rams
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
-- pragma translate_off
library axcelerator;
use axcelerator.RAM64K36;
-- pragma translate_on

entity axcel_ssram is
  generic (abits : integer := 16; dbits : integer := 36);
  port (
    wa, ra       : in  std_logic_vector(15 downto 0);
    wclk, rclk   : in  std_ulogic;
    di           : in  std_logic_vector(dbits -1 downto 0);
    do           : out std_logic_vector(dbits -1 downto 0);
    width        : in  std_logic_vector(2 downto 0);
    ren, wen     : in  std_ulogic
   ); 
end;

architecture rtl of axcel_ssram is
 component RAM64K36 
    port(
    WRAD0, WRAD1, WRAD2, WRAD3, WRAD4, WRAD5, WRAD6, WRAD7, WRAD8, WRAD9, WRAD10,
    WRAD11, WRAD12, WRAD13, WRAD14, WRAD15, WD0, WD1, WD2, WD3, WD4, WD5, WD6,
    WD7, WD8, WD9, WD10, WD11, WD12, WD13, WD14, WD15, WD16, WD17, WD18, WD19,
    WD20, WD21, WD22, WD23, WD24, WD25, WD26, WD27, WD28, WD29, WD30, WD31, WD32,
    WD33, WD34, WD35, WEN, DEPTH0, DEPTH1, DEPTH2, DEPTH3, WW0, WW1, WW2, WCLK,
    RDAD0, RDAD1, RDAD2, RDAD3, RDAD4, RDAD5, RDAD6, RDAD7, RDAD8, RDAD9, RDAD10,
    RDAD11, RDAD12, RDAD13, RDAD14, RDAD15, REN, RW0, RW1, RW2, RCLK : in std_logic;
    RD0, RD1, RD2, RD3, RD4, RD5, RD6, RD7, RD8, RD9, RD10, RD11, RD12, RD13,
    RD14, RD15, RD16, RD17, RD18, RD19, RD20, RD21, RD22, RD23, RD24, RD25, RD26,
    RD27, RD28, RD29, RD30, RD31, RD32, RD33, RD34, RD35 : out std_logic);
  end component;
signal gnd : std_ulogic;
signal depth : std_logic_vector(4 downto 0);
signal d, q : std_logic_vector(36 downto 0);
begin
  depth <= "00000";
  do <= q(dbits-1 downto 0);
  d(dbits-1 downto 0) <= di;
  d(36 downto dbits) <= (others => '0');
    u0 : RAM64K36
    port map (
      WRAD0 => wa(0), WRAD1 => wa(1), WRAD2 => wa(2), WRAD3 => wa(3),
      WRAD4 => wa(4), WRAD5 => wa(5), WRAD6 => wa(6), WRAD7 => wa(7),
      WRAD8 => wa(8), WRAD9 => wa(9), WRAD10 => wa(10), WRAD11 => wa(11),
      WRAD12 => wa(12), WRAD13 => wa(13), WRAD14 => wa(14), WRAD15 => wa(15),
      WD0 => d(0), WD1 => d(1), WD2 => d(2), WD3 => d(3), WD4 => d(4),
      WD5 => d(5), WD6 => d(6), WD7 => d(7), WD8 => d(8), WD9 => d(9),
      WD10 => d(10), WD11 => d(11), WD12 => d(12), WD13 => d(13), WD14 => d(14),
      WD15 => d(15), WD16 => d(16), WD17 => d(17), WD18 => d(18), WD19 => d(19),
      WD20 => d(20), WD21 => d(21), WD22 => d(22), WD23 => d(23), WD24 => d(24),
      WD25 => d(25), WD26 => d(26), WD27 => d(27), WD28 => d(28), WD29 => d(29),
      WD30 => d(30), WD31 => d(31), WD32 => d(32), WD33 => d(33), WD34 => d(34),
      WD35 => d(35), WEN => wen, DEPTH0 => depth(0),
      DEPTH1 => depth(1), DEPTH2 => depth(2), DEPTH3 => depth(3),
      WW0 => width(0), WW1 => width(1), WW2 => width(2), WCLK => wclk,
      RDAD0 => ra(0), RDAD1 => ra(1), RDAD2 => ra(2), RDAD3 => ra(3),
      RDAD4 => ra(4), RDAD5 => ra(5), RDAD6 => ra(6), RDAD7 => ra(7),
      RDAD8 => ra(8), RDAD9 => ra(9), RDAD10 => ra(10), RDAD11 => ra(11),
      RDAD12 => ra(12), RDAD13 => ra(13), RDAD14 => ra(14), RDAD15 => ra(15),
      REN => ren, RW0 => width(0), RW1 => width(1), RW2 => width(2),
      RCLK => rclk,
      RD0 => q(0), RD1 => q(1), RD2 => q(2), RD3 => q(3), RD4 => q(4),
      RD5 => q(5), RD6 => q(6), RD7 => q(7), RD8 => q(8), RD9 => q(9),
      RD10 => q(10), RD11 => q(11), RD12 => q(12), RD13 => q(13), RD14 => q(14),
      RD15 => q(15), RD16 => q(16), RD17 => q(17), RD18 => q(18), RD19 => q(19),
      RD20 => q(20), RD21 => q(21), RD22 => q(22), RD23 => q(23), RD24 => q(24),
      RD25 => q(25), RD26 => q(26), RD27 => q(27), RD28 => q(28), RD29 => q(29),
      RD30 => q(30), RD31 => q(31), RD32 => q(32), RD33 => q(33), RD34 => q(34),
      RD35 => q(35));

end;

library ieee;
use ieee.std_logic_1164.all;
library techmap;

entity axcel_syncram_2p is
  generic ( abits : integer := 10; dbits : integer := 8 );
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

architecture rtl of axcel_syncram_2p is
component axcel_ssram 
  generic (abits : integer := 16; dbits : integer := 36);
  port (
    wa, ra       : in  std_logic_vector(15 downto 0);
    wclk, rclk   : in  std_ulogic;
    di           : in  std_logic_vector(dbits -1 downto 0);
    do           : out std_logic_vector(dbits -1 downto 0);
    width        : in  std_logic_vector(2 downto 0);
    ren, wen     : in  std_ulogic
   ); 
end component;

type dwtype is array (1 to 24) of integer;
constant dwmap : dwtype := (36, 36, 36, 36, 36, 36, 36, 18, 9, 4, 2, others => 1);
constant xbits : integer := dwmap(abits);
constant dw : integer := dbits + 36;
signal wen, gnd : std_ulogic;
signal ra, wa : std_logic_vector(31 downto 0);
signal d, q : std_logic_vector(dw downto 0);
signal ren  : std_ulogic;
signal width : std_logic_vector(2 downto 0);
constant READFAST : std_ulogic := '0';
begin
  width <= "101" when abits <= 7 else
           "100" when abits = 8 else
           "011" when abits = 9 else
           "010" when abits = 10 else
           "001" when abits = 11 else
           "000";
  wen <= write; ren <= rena or READFAST; gnd <= '0';
  ra(31 downto abits) <= (others =>'0'); wa(31 downto abits) <= (others =>'0');
  ra(abits-1 downto 0) <= raddr(abits-1 downto 0);
  wa(abits-1 downto 0) <= waddr(abits-1 downto 0);
  d(dw downto dbits) <= (others =>'0');
  d(dbits-1 downto 0) <= din(dbits-1 downto 0);
  dout <= q(dbits-1 downto 0);
 
  
  a7 : if abits <= 7 generate
    agen : for i in 0 to (dbits-1)/xbits generate
      u0 : axcel_ssram
      generic map (abits => 7, dbits => xbits) 
      port map (ra => ra(15 downto 0), wa => wa(15 downto 0), 
	 di => d(xbits*(i+1)-1 downto xbits*i), wen => wen, width => width, 
	 wclk => wclk, ren => ren, rclk => rclk, 
	 do => q(xbits*(i+1)-1 downto xbits*i));
    end generate;
  end generate;
  a8to12 : if (abits > 7) and (abits <= 12) generate
    agen : for i in 0 to (dbits-1)/xbits generate
      u0 : axcel_ssram
      generic map (abits => abits, dbits => xbits) 
      port map (ra => ra(15 downto 0), wa => wa(15 downto 0), 
	 di => d(xbits*(i+1)-1 downto xbits*i), wen => wen, width => width, 
	 wclk => wclk, ren => ren, rclk => rclk, 
	 do => q(xbits*(i+1)-1 downto xbits*i));
    end generate;
  end generate;
-- pragma translate_off
  a_to_high : if abits > 12 generate
    x : process
    begin
      assert false
      report  "Address depth larger than 12 not supported for AX rams"
      severity failure;
      wait;
    end process;
  end generate;
-- pragma translate_on
end;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity axcel_syncram is
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

architecture rtl of axcel_syncram is
  
 component axcel_syncram_2p
  generic ( abits : integer := 10; dbits : integer := 8 );
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

  component axcel_ssram 
  generic (abits : integer := 16; dbits : integer := 36);
  port (
    wa, ra       : in  std_logic_vector(15 downto 0);
    wclk, rclk   : in  std_ulogic;
    di           : in  std_logic_vector(dbits -1 downto 0);
    do           : out std_logic_vector(dbits -1 downto 0);
    width        : in  std_logic_vector(2 downto 0);
    ren, wen     : in  std_ulogic
   ); 
  end component;

  type d_type is array (0 to 3) of std_logic_vector(35 downto 0);

  signal wen : std_logic_vector(3 downto 0);
  signal q   : d_type;
  signal addr : std_logic_vector(15 downto 0);

  signal addrreg : std_logic_vector(1 downto 0);
  
begin

  a : if not ((abits = 10 or abits = 11) and dbits = 36) generate  
    u0 : axcel_syncram_2p generic map (abits, dbits)
      port map (clk, enable, address, dataout, clk, address, datain, write);
  end generate;

  
  -- Special case for 4 or 8 KB cache with FT: 36x1024 or 2048: 2 or 4 banks of 4*9*512 
  a10to11d36 : if (abits = 10 or abits = 11) and dbits = 36 generate

    addr_reg : process (clk)
      begin
        if rising_edge(clk) then addrreg(abits-10 downto 0) <= address(abits-1 downto 9); end if;
      end process;

    addr(15 downto 9)  <= (others => '0');
    addr(8 downto 0) <= address(8 downto 0);

    decode : process (address, write)
      variable vwen : std_logic_vector(3 downto 0);
    begin
      vwen := (others => '0');
      if write = '1' then
        vwen( to_integer(unsigned(address(abits-1 downto 9))) ) := '1';
      end if;
      wen <= vwen;
    end process;
    
    loop0 : for b in 0 to 2*(abits-9)-1 generate  
      agen0 : for i in 0 to 3 generate
        u0 : axcel_ssram
          generic map (abits => 9, dbits => 9) 
          port map (ra => addr, wa =>  addr, 
                    di => datain(9*(i+1)-1 downto 9*i), wen => wen(b), width => "011", 
                    wclk => clk, ren => enable, rclk => clk, 
                    do => q(b)(9*(i+1)-1 downto 9*i));
      end generate;
    end generate;

    dout10: if abits = 10 generate
      dataout <= q(0) when addrreg(0)='0' else q(1);
    end generate;
    dout11: if abits = 11 generate
      dataout <= q(0) when addrreg(1 downto 0)="00" else q(1) when addrreg(1 downto 0)="01" else
                 q(2) when addrreg(1 downto 0)="10" else q(3);              
    end generate;
    
  end generate;

end;

