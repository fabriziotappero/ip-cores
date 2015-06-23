



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
-- Entity: 	tech_generic
-- File:	tech_generic.vhd
-- Author:	Jiri Gaisler - ESA/ESTEC
-- Description:	Contains behavioural pads and ram generators
------------------------------------------------------------------------------

LIBRARY ieee;
use IEEE.std_logic_1164.all;
use work.leon_iface.all;
package tech_generic is

-- generic sync ram

component generic_syncram
  generic ( abits : integer := 10; dbits : integer := 8 );
  port (
    address  : in std_logic_vector((abits -1) downto 0);
    clk      : in std_logic;
    datain   : in std_logic_vector((dbits -1) downto 0);
    dataout  : out std_logic_vector((dbits -1) downto 0);
    enable   : in std_logic;
    write    : in std_logic
   ); 
end component;

-- regfile generator

component generic_regfile_iu
  generic ( 
    rftype : integer := 1;
    abits : integer := 8; dbits : integer := 32; words : integer := 128
  );
  port (
    rst      : in std_logic;
    clk      : in std_logic;
    clkn     : in std_logic;
    rfi      : in rf_in_type;
    rfo      : out rf_out_type);
  end component;

component generic_regfile_cp
  generic ( 
    abits : integer := 4; dbits : integer := 32; words : integer := 16
  );
  port (
    rst      : in std_logic;
    clk      : in std_logic;
    rfi      : in rf_cp_in_type;
    rfo      : out rf_cp_out_type);
end component;

-- bypass logic for async-read/sync-write regfiles

component rfbypass
  generic (
    abits : integer := 8;
    dbits : integer := 32
  );
  port (
    clk   : in clk_type;
    write : in std_logic;
    datain: in std_logic_vector (dbits -1 downto 0);
    raddr1: in std_logic_vector (abits -1 downto 0);
    raddr2: in std_logic_vector (abits -1 downto 0);
    waddr : in std_logic_vector (abits -1 downto 0);
    q1    : in std_logic_vector (dbits -1 downto 0);
    q2    : in std_logic_vector (dbits -1 downto 0);
    dataout1 : out std_logic_vector (dbits -1 downto 0);
    dataout2 : out std_logic_vector (dbits -1 downto 0)
  );
end component;

-- generic multipler

component generic_smult
  generic ( abits : integer := 10; bbits : integer := 8 );
  port (
    a    : in  std_logic_vector(abits-1 downto 0);
    b    : in  std_logic_vector(bbits-1 downto 0);
    c    : out std_logic_vector(abits+bbits-1 downto 0)
  ); 
end component; 

-- generic clock generator

component generic_clkgen 
port (
    clkin   : in  std_logic;
    pciclkin: in  std_logic;
    clk     : out std_logic;			-- main clock
    clkn    : out std_logic;			-- inverted main clock
    sdclk   : out std_logic;			-- SDRAM clock
    pciclk  : out std_logic;			-- PCI clock
    cgi     : in clkgen_in_type;
    cgo     : out clkgen_out_type
);
end component;

component generic_dpram_as 
  generic (
    abits : integer := 8;
    dbits : integer := 32;
    words : integer := 256
  );
  port (
    clk : in std_logic;
    rdaddress: in std_logic_vector (abits -1 downto 0);
    wraddress: in std_logic_vector (abits -1 downto 0);
    data: in std_logic_vector (dbits -1 downto 0);
    wren : in std_logic;
    q: out std_logic_vector (dbits -1 downto 0)
  );
end component;

component generic_dpram_ss 
  generic (
    abits : integer := 8;
    dbits : integer := 32;
    words : integer := 256
  );
  port (
    clk : in std_logic;
    rdaddress: in std_logic_vector (abits -1 downto 0);
    wraddress: in std_logic_vector (abits -1 downto 0);
    data: in std_logic_vector (dbits -1 downto 0);
    wren : in std_logic;
    q: out std_logic_vector (dbits -1 downto 0)
  );
end component;

-- pads

component geninpad port (pad : in std_logic; q : out std_logic); end component; 
component gensmpad port (pad : in std_logic; q : out std_logic); end component;
component genoutpad port (d : in  std_logic; pad : out  std_logic); end component; 
component gentoutpadu port (d, en : in std_logic; pad : out std_logic); end component;
component geniopad 
  port ( d, en : in std_logic; q : out std_logic; pad : inout std_logic);
end component;
component geniodpad 
  port ( d : in std_logic; q : out std_logic; pad : inout std_logic);
end component;
component genodpad port ( d : in std_logic; pad : out std_logic); end component;

end;

library IEEE;
use IEEE.std_logic_1164.all;

------------------------------------------------------------------
-- behavioural ram models --------------------------------------------
------------------------------------------------------------------

-- synchronous ram for direct interference 

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use work.leon_iface.all;

entity generic_syncram is
  generic ( abits : integer := 10; dbits : integer := 8 );
  port (
    address  : in std_logic_vector((abits -1) downto 0);
    clk      : in std_logic;
    datain   : in std_logic_vector((dbits -1) downto 0);
    dataout  : out std_logic_vector((dbits -1) downto 0);
    enable   : in std_logic;
    write    : in std_logic
  ); 
end;     

architecture behavioral of generic_syncram is

  type mem is array(0 to (2**abits -1)) 
	of std_logic_vector((dbits -1) downto 0);
  signal memarr : mem;
  signal ra  : std_logic_vector((abits -1) downto 0);
  attribute syn_ramstyle : string;
  attribute syn_ramstyle of memarr: signal is "block_ram";
-- pragma translate_off
  signal rw : std_logic;
-- pragma translate_on

begin

  main : process(clk, memarr, ra)
  begin
    if rising_edge(clk) then
      if write = '1' then
-- pragma translate_off
        if not is_x(address) then
-- pragma translate_on
          memarr(conv_integer(unsigned(address))) <= datain;
-- pragma translate_off
        end if;
-- pragma translate_on
      end if;
      ra <= address;
-- pragma translate_off
      rw <= write;
-- pragma translate_on
    end if;
  end process;

-- pragma translate_off
  readport : process(memarr, ra, rw)
  begin
    if not (is_x(ra) or (rw = '1')) then
-- pragma translate_on
      dataout <= memarr(conv_integer(unsigned(ra)));
-- pragma translate_off
    else
      dataout <= (others => 'X');
    end if;
  end process;
-- pragma translate_on
end;

-- synchronous dpram for direct instantiation 

LIBRARY ieee;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use work.leon_iface.all;

entity generic_dpram_ss is
  generic (
    abits : integer := 8;
    dbits : integer := 32;
    words : integer := 256
  );
  port (
    clk : in std_logic;
    rdaddress: in std_logic_vector (abits -1 downto 0);
    wraddress: in std_logic_vector (abits -1 downto 0);
    data: in std_logic_vector (dbits -1 downto 0);
    wren : in std_logic;
    q: out std_logic_vector (dbits -1 downto 0)
  );
end;

architecture behav of generic_dpram_ss is
  type dregtype is array (0 to words - 1) 
	of std_logic_vector(dbits -1 downto 0);
  signal rfd : dregtype;
  signal wa, ra : std_logic_vector (abits -1 downto 0);
  attribute syn_ramstyle : string;
  attribute syn_ramstyle of rfd: signal is "block_ram";
-- pragma translate_off
  signal drivex : boolean;
-- pragma translate_on
begin

  rp : process(clk)
  begin
    if rising_edge(clk) then
      if wren = '1' then
-- pragma translate_off
	if not ( is_x(wraddress) or 
	    (conv_integer(unsigned(wraddress)) >= words))
	then
-- pragma translate_on
   	  rfd(conv_integer(unsigned(wraddress))) <= data; 
-- pragma translate_off
        end if;
-- pragma translate_on
      end if;
-- pragma translate_off
      drivex <= (wren = '1') and (wraddress = rdaddress);
-- pragma translate_on
      ra <= rdaddress;
    end if;
  end process;

-- pragma translate_off
  readport : process(rfd, ra, drivex)
  begin
    if not (is_x(ra) or (conv_integer(unsigned(ra)) >= words) or drivex) 
    then
-- pragma translate_on
      q <= rfd(conv_integer(unsigned(ra)));
-- pragma translate_off
    else
      q <= (others => 'X');
    end if;
  end process;
-- pragma translate_on
end;

-- async dpram for direct instantiation 

LIBRARY ieee;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use work.leon_iface.all;

entity generic_dpram_as is
  generic (
    abits : integer := 8;
    dbits : integer := 32;
    words : integer := 256
  );
  port (
    clk : in std_logic;
    rdaddress: in std_logic_vector (abits -1 downto 0);
    wraddress: in std_logic_vector (abits -1 downto 0);
    data: in std_logic_vector (dbits -1 downto 0);
    wren : in std_logic;
    q: out std_logic_vector (dbits -1 downto 0)
  );
end;

architecture behav of generic_dpram_as is
  type dregtype is array (0 to words - 1) 
       of std_logic_vector(dbits -1 downto 0);
  signal rfd : dregtype;
  signal wa : std_logic_vector (abits -1 downto 0);
  attribute syn_ramstyle : string;
  attribute syn_ramstyle of rfd: signal is "block_ram";
begin

  rp : process(clk)
  begin
    if rising_edge(clk) then
      if wren = '1' then
-- pragma translate_off
	if not ( is_x(wraddress) or 
	    (conv_integer(unsigned(wraddress)) >= words))
	then
-- pragma translate_on
   	  rfd(conv_integer(unsigned(wraddress))) <= data; 
-- pragma translate_off
        end if;
-- pragma translate_on
      end if;
--     wa <= wraddress;
    end if;
  end process;
-- pragma translate_off

  comb : process(rdaddress, rfd)
  begin
    if not (is_x(rdaddress) or (conv_integer(unsigned(rdaddress)) >= words))
    then
-- pragma translate_on
      q <= rfd(conv_integer(unsigned(rdaddress)));
-- pragma translate_off
    else
      q <= (others => 'X');
    end if;
  end process;
-- pragma translate_on

end;

-- Bypass logic for async regfiles with delayed (synchronous) write
-- Bypass written data to read port if write enabled
-- and read and write address are equal.

library IEEE;
use IEEE.std_logic_1164.all;
use work.leon_iface.all;

entity rfbypass is
  generic (
    abits : integer := 8;
    dbits : integer := 32
  );
  port (
    clk   : in clk_type;
    write : in std_logic;
    datain: in std_logic_vector (dbits -1 downto 0);
    raddr1: in std_logic_vector (abits -1 downto 0);
    raddr2: in std_logic_vector (abits -1 downto 0);
    waddr : in std_logic_vector (abits -1 downto 0);
    q1    : in std_logic_vector (dbits -1 downto 0);
    q2    : in std_logic_vector (dbits -1 downto 0);
    dataout1 : out std_logic_vector (dbits -1 downto 0);
    dataout2 : out std_logic_vector (dbits -1 downto 0)
  );
end;
architecture rtl of rfbypass is 
type wbypass_type is record
  wraddr  : std_logic_vector(abits-1 downto 0);
  wrdata  : std_logic_vector(dbits-1 downto 0);
  wren    : std_logic;
end record;
signal wbpr : wbypass_type;
begin 

    wbp_comb : process(q1, q2, wbpr, raddr1, raddr2)
    begin
      if (wbpr.wren = '1') and (wbpr.wraddr = raddr1)   then
 	dataout1 <= wbpr.wrdata;
      else dataout1 <= q1(dbits-1 downto 0); end if;
      if (wbpr.wren = '1') and (wbpr.wraddr = raddr2)   then
 	dataout2 <= wbpr.wrdata;
      else dataout2 <= q2(dbits-1 downto 0); end if;
    end process;

    wbp_reg : process(clk)
    begin
      if rising_edge(clk) then 
	wbpr.wraddr <= waddr; 
	wbpr.wrdata <= datain; 
	wbpr.wren <= write; 
      end if;
    end process;

end;

--------------------------------------------------------------------
-- regfile generators
--------------------------------------------------------------------

-- integer unit regfile
LIBRARY ieee;
use IEEE.std_logic_1164.all;
use work.leon_config.all;
use work.leon_iface.all;
entity generic_regfile_iu is
  generic ( 
    rftype : integer := 1;
    abits : integer := 8; dbits : integer := 32; words : integer := 128
  );
  port (
    rst      : in std_logic;
    clk      : in std_logic;
    clkn     : in std_logic;
    rfi      : in rf_in_type;
    rfo      : out rf_out_type);
end;

architecture rtl of generic_regfile_iu is
  component generic_dpram_ss
  generic (
    abits : integer := 8;
    dbits : integer := 32;
    words : integer := 256
  );
  port (
    clk : in std_logic;
    rdaddress: in std_logic_vector (abits -1 downto 0);
    wraddress: in std_logic_vector (abits -1 downto 0);
    data: in std_logic_vector (dbits -1 downto 0);
    wren : in std_logic;
    q: out std_logic_vector (dbits -1 downto 0)
  );
  end component;

  component generic_dpram_as
  generic (
    abits : integer := 8;
    dbits : integer := 32;
    words : integer := 256
  );
  port (
    clk : in std_logic;
    rdaddress: in std_logic_vector (abits -1 downto 0);
    wraddress: in std_logic_vector (abits -1 downto 0);
    data: in std_logic_vector (dbits -1 downto 0);
    wren : in std_logic;
    q: out std_logic_vector (dbits -1 downto 0)
  );
  end component;

  component rfbypass
  generic (
    abits : integer := 8;
    dbits : integer := 32
  );
  port (
    clk   : in clk_type;
    write : in std_logic;
    datain: in std_logic_vector (dbits -1 downto 0);
    raddr1: in std_logic_vector (abits -1 downto 0);
    raddr2: in std_logic_vector (abits -1 downto 0);
    waddr : in std_logic_vector (abits -1 downto 0);
    q1    : in std_logic_vector (dbits -1 downto 0);
    q2    : in std_logic_vector (dbits -1 downto 0);
    dataout1 : out std_logic_vector (dbits -1 downto 0);
    dataout2 : out std_logic_vector (dbits -1 downto 0)
  );
  end component;

signal qq1, qq2  : std_logic_vector (dbits -1 downto 0);
begin

  rfss : if rftype = 1 generate
    u0 : generic_dpram_ss 
       generic map (abits => abits, dbits => dbits, words => words)
       port map (clk => clkn, rdaddress => rfi.rd1addr, wraddress => rfi.wraddr,
	         data => rfi.wrdata, wren => rfi.wren, q => rfo.data1);

    u1 : generic_dpram_ss 
       generic map (abits => abits, dbits => dbits, words => words)
       port map (clk => clkn, rdaddress => rfi.rd2addr, wraddress => rfi.wraddr,
	         data => rfi.wrdata, wren => rfi.wren, q => rfo.data2);
  end generate;

  rfas : if rftype = 2 generate
    u0 : generic_dpram_as 
       generic map (abits => abits, dbits => dbits, words => words)
       port map (clk => clk, rdaddress => rfi.rd1addr, wraddress => rfi.wraddr,
	         data => rfi.wrdata, wren => rfi.wren, q => rfo.data1);

    u1 : generic_dpram_as 
       generic map (abits => abits, dbits => dbits, words => words)
       port map (clk => clk, rdaddress => rfi.rd2addr, wraddress => rfi.wraddr,
	         data => rfi.wrdata, wren => rfi.wren, q => rfo.data2);
  end generate;

end;

-- co-processor regfile
-- synchronous operation without write-through support
LIBRARY ieee;
use IEEE.std_logic_1164.all;
use work.leon_config.all;
use work.leon_iface.all;
entity generic_regfile_cp is
  generic ( 
    abits : integer := 4; dbits : integer := 32; words : integer := 16
  );
  port (
    rst      : in std_logic;
    clk      : in std_logic;
    rfi      : in rf_cp_in_type;
    rfo      : out rf_cp_out_type);
end;

architecture rtl of generic_regfile_cp is
  component generic_dpram_ss
  generic (
    abits : integer := 8;
    dbits : integer := 32;
    words : integer := 256
  );
  port (
    clk : in std_logic;
    rdaddress: in std_logic_vector (abits -1 downto 0);
    wraddress: in std_logic_vector (abits -1 downto 0);
    data: in std_logic_vector (dbits -1 downto 0);
    wren : in std_logic;
    q: out std_logic_vector (dbits -1 downto 0)
  );
  end component;

begin
    u0 : generic_dpram_ss 
       generic map (abits => abits, dbits => dbits, words => words)
       port map (clk => clk, rdaddress => rfi.rd1addr, wraddress => rfi.wraddr,
	         data => rfi.wrdata, wren => rfi.wren, q => rfo.data1);
    u1 : generic_dpram_ss 
       generic map (abits => abits, dbits => dbits, words => words)
       port map (clk => clk, rdaddress => rfi.rd2addr, wraddress => rfi.wraddr,
	         data => rfi.wrdata, wren => rfi.wren, q => rfo.data2);
end;

------------------------------------------------------------------
-- multiplier ----------------------------------------------------
------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
entity generic_smult is
  generic ( abits : integer := 10; bbits : integer := 8 );
  port (
    a    : in  std_logic_vector(abits-1 downto 0);
    b    : in  std_logic_vector(bbits-1 downto 0);
    c    : out std_logic_vector(abits+bbits-1 downto 0)
  ); 
end; 
architecture rtl of generic_smult is
begin 

  m: process(a, b)
  variable w : std_logic_vector(abits+bbits-1 downto 0);
  begin
-- pragma translate_off
    if is_x(a) or is_x(b) then
      w := (others => 'X');
    else
-- pragma translate_on
      w := std_logic_vector'(signed(a) * signed(b));  --'
-- pragma translate_off
    end if;
-- pragma translate_on
    c <= w;
  end process;
end;


------------------------------------------------------------------
-- generic clock generator ---------------------------------------
------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use work.leon_target.all;
use work.leon_iface.all;
use work.leon_config.all;

entity generic_clkgen is
port (
    clkin   : in  std_logic;
    pciclkin: in  std_logic;
    clk     : out std_logic;			-- main clock
    clkn    : out std_logic;			-- inverted main clock
    sdclk   : out std_logic;			-- SDRAM clock
    pciclk  : out std_logic;			-- PCI clock
    cgi     : in clkgen_in_type;
    cgo     : out clkgen_out_type
);
end;

architecture rtl of generic_clkgen is
signal pciclk_actel : clk_type;
begin

  pciclk_actel <= pciclkin after 1 ns; -- need this to stay synced with Actel core
  cgo.clklock <= '1'; cgo.pcilock <= '1';

  cp : process (pciclk_actel, clkin, pciclkin)
  begin
    if PCI_SYSCLK then
      clk <= pciclk_actel; clkn <= not pciclk_actel; pciclk <= pciclk_actel;

      if SDINVCLK then sdclk <= not pciclk_actel; else sdclk <= pciclk_actel; end if;

    else

      clk <= clkin; clkn <= not clkin; pciclk <= pciclkin;

      if SDINVCLK then sdclk <= not clkin; else sdclk <= clkin; end if;
    end if;
  end process;
end;

------------------------------------------------------------------
-- behavioural pad models --------------------------------------------
------------------------------------------------------------------

-- input pad
library IEEE;
use IEEE.std_logic_1164.all;
entity geninpad is port (pad : in std_logic; q : out std_logic); end; 
architecture rtl of geninpad is begin q <= to_x01(pad); end;

-- input schmitt pad
library IEEE;
use IEEE.std_logic_1164.all;
entity gensmpad is port (pad : in std_logic; q : out std_logic); end; 
architecture rtl of gensmpad is begin q <= to_x01(pad); end;

-- output pad
library IEEE;
use IEEE.std_logic_1164.all;
entity genoutpad is port (d : in  std_logic; pad : out  std_logic); end; 
architecture rtl of genoutpad is begin pad <= to_x01(d) after 2 ns; end;

-- tri-state outpad with pull-up pad
library IEEE;
use IEEE.std_logic_1164.all;
entity gentoutpadu is port (d, en : in std_logic; pad : out std_logic); end; 
architecture rtl of gentoutpadu is
begin pad <= to_x01(d) after 2 ns when en = '0' else 'H' after 2 ns; end;

-- bidirectional pad
library IEEE;
use IEEE.std_logic_1164.all;
entity geniopad is
  port ( d, en : in std_logic; q : out std_logic; pad : inout std_logic);
end; 
architecture rtl of geniopad is
begin pad <= to_x01(d) after 2 ns when en = '0' else 'Z' after 2 ns; q <= to_x01(pad); end;

-- bidirectional open-drain pad
library IEEE;
use IEEE.std_logic_1164.all;
entity geniodpad is
  port ( d : in std_logic; q : out std_logic; pad : inout std_logic);
end; 
architecture rtl of geniodpad is
begin pad <= '0' after 2 ns when d = '0' else 'Z' after 2 ns; q <= to_x01(pad); end;

-- open-drain pad
library IEEE;
use IEEE.std_logic_1164.all;
entity genodpad is port ( d : in std_logic; pad : out std_logic); end; 
architecture rtl of genodpad is begin pad <= '0' after 2 ns when d = '0' else 'Z'; end;

