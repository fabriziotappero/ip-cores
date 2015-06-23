



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
-- Package: 	tech_map
-- File:	tech_map.vhd
-- Author:	Jiri Gaisler - ESA/ESTEC
-- Description:	Technology mapping of cache-rams, regfiles, pads and multiplier
------------------------------------------------------------------------------

LIBRARY ieee;
use IEEE.std_logic_1164.all;
use work.leon_iface.all;
package tech_map is

-- IU three-port regfile
  component regfile_iu
  generic ( 
    rftype : integer := 1;
    abits : integer := 8; dbits : integer := 32; words : integer := 128
  );
  port (
    rst      : in std_logic;
    clk      : in clk_type;
    clkn     : in clk_type;
    rfi      : in rf_in_type;
    rfo      : out rf_out_type);
  end component;

-- CP three-port
  component regfile_cp
  generic ( 
    abits : integer := 4; dbits : integer := 32; words : integer := 16
  );
  port (
    rst      : in std_logic;
    clk      : in clk_type;
    rfi      : in rf_cp_in_type;
    rfo      : out rf_cp_out_type);
  end component;

-- single-port sync ram
  component syncram 
  generic ( abits : integer := 10; dbits : integer := 8);
  port (
    address  : in std_logic_vector((abits -1) downto 0);
    clk      : in clk_type;
    datain   : in std_logic_vector((dbits -1) downto 0);
    dataout  : out std_logic_vector((dbits -1) downto 0);
    enable   : in std_logic;
    write    : in std_logic
  ); 
  end component;     

-- dual-port sync ram
  component dpsyncram 
  generic ( abits : integer := 10; dbits : integer := 8);
  port (
    address1 : in std_logic_vector((abits -1) downto 0);
    clk      : in clk_type;
    datain1  : in std_logic_vector((dbits -1) downto 0);
    dataout1 : out std_logic_vector((dbits -1) downto 0);
    enable1  : in std_logic;
    write1   : in std_logic;
    address2 : in std_logic_vector((abits -1) downto 0);
    datain2  : in std_logic_vector((dbits -1) downto 0);
    dataout2 : out std_logic_vector((dbits -1) downto 0);
    enable2  : in std_logic;
    write2   : in std_logic
  ); 
  end component;     

-- sync prom (used for boot-prom option)
  component bprom
  port (
    clk       : in std_logic;
    cs        : in std_logic;
    addr      : in std_logic_vector(31 downto 0);
    data      : out std_logic_vector(31 downto 0)
  );
  end component;

-- signed multipler

component hw_smult
  generic ( abits : integer := 10; bbits : integer := 8 );
  port (
    clk  : in  clk_type;
    holdn: in  std_logic;
    a    : in  std_logic_vector(abits-1 downto 0);
    b    : in  std_logic_vector(bbits-1 downto 0);
    c    : out std_logic_vector(abits+bbits-1 downto 0)
  ); 
end component; 

component clkgen 
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

-- pads

  component inpad port (pad : in std_logic; q : out std_logic); end component;
  component smpad port (pad : in std_logic; q : out std_logic); end component;
  component outpad
    generic (drive : integer := 1);
    port (d : in std_logic; pad : out std_logic);
  end component;
  component toutpadu
    generic (drive : integer := 1);
    port (d : in std_logic; pad : out std_logic);
  end component;
  component odpad
    generic (drive : integer := 1);
    port (d : in std_logic; pad : out std_logic);
  end component;
  component iodpad
    generic (drive : integer := 1);
    port ( d : in std_logic; q : out std_logic; pad : inout std_logic);
  end component;
  component iopad
    generic (drive : integer := 1);
    port ( d, en : in  std_logic; q : out std_logic; pad : inout std_logic);
  end component;
  component smiopad 
    generic (drive : integer := 1);
    port ( d, en : in  std_logic; q : out std_logic; pad : inout std_logic);
  end component; 
  component pciinpad port (pad : in std_logic; q : out std_logic); end component;
  component pcioutpad port (d : in std_logic; pad : out std_logic); end component;
  component pcitoutpad port (d, en : in std_logic; pad : out std_logic); end component;
  component pciiopad
    port ( d, en : in  std_logic; q : out std_logic; pad : inout std_logic);
  end component;
  component pciiodpad
    port ( d : in  std_logic; q : out std_logic; pad : inout std_logic);
  end component; 
end tech_map;

-- syncronous ram

LIBRARY ieee;
use IEEE.std_logic_1164.all;
use work.leon_target.all;
use work.leon_config.all;
use work.leon_iface.all;
use work.tech_atc25.all;
use work.tech_atc18.all;
use work.tech_atc35.all;
use work.tech_fs90.all;
use work.tech_umc18.all;
use work.tech_generic.all;
use work.tech_virtex.all;
use work.tech_virtex2.all;
use work.tech_tsmc25.all;
use work.tech_proasic.all;
use work.tech_axcel.all;

entity syncram is
  generic ( abits : integer := 8; dbits : integer := 32);
  port (
    address : in std_logic_vector (abits -1 downto 0);
    clk     : in clk_type;
    datain  : in std_logic_vector (dbits -1 downto 0);
    dataout : out std_logic_vector (dbits -1 downto 0);
    enable  : in std_logic;
    write   : in std_logic
  );
end;

architecture behav of syncram is
begin

  inf : if INFER_RAM generate 
    u0 : generic_syncram generic map (abits => abits, dbits => dbits)
         port map (address, clk , datain, dataout, enable, write);
  end generate;

  hb : if (not INFER_RAM) generate 
    at1 : if TARGET_TECH = atc18 generate
      u0 : atc18_syncram generic map (abits => abits, dbits => dbits)
	 port map (address, clk, datain, dataout, enable, write);
    end generate;
    at2 : if TARGET_TECH = atc25 generate
      u0 : atc25_syncram generic map (abits => abits, dbits => dbits)
	 port map (address, clk, datain, dataout, enable, write);
    end generate;
    at3 : if TARGET_TECH = atc35 generate
      u0 : atc35_syncram generic map (abits => abits, dbits => dbits)
	 port map (address, clk , datain, dataout, enable, write);
    end generate;
    fs9 : if TARGET_TECH = fs90 generate
      u0 : fs90_syncram generic map (abits => abits, dbits => dbits)
	 port map (address, clk , datain, dataout, enable, write);
    end generate;
    umc1 : if TARGET_TECH = umc18 generate
      u0 : umc18_syncram generic map (abits => abits, dbits => dbits)
         port map (address, clk , datain, dataout, enable, write);
    end generate;
    xcv : if TARGET_TECH = virtex generate 
      u0 : virtex_syncram generic map (abits => abits, dbits => dbits)
	   port map (address, clk , datain, dataout, enable, write);
    end generate;
    xc2v : if TARGET_TECH = virtex2 generate 
      u0 : virtex2_syncram generic map (abits => abits, dbits => dbits)
	   port map (address, clk , datain, dataout, enable, write);
    end generate;
    sim : if TARGET_TECH = gen generate
      u0 : generic_syncram generic map (abits => abits, dbits => dbits)
           port map (address, clk , datain, dataout, enable, write);
    end generate;    
    tsmc : if TARGET_TECH = tsmc25 generate
      u0 : tsmc25_syncram generic map (abits => abits, dbits => dbits)
           port map (address, clk , datain, dataout, enable, write);
    end generate;    
    proa : if TARGET_TECH = proasic generate
      u0 : proasic_syncram generic map (abits => abits, dbits => dbits)
           port map (address, clk , datain, dataout, enable, write);
    end generate;    
    axc : if TARGET_TECH = axcel generate
      u0 : axcel_syncram generic map (abits => abits, dbits => dbits)
           port map (address, clk , datain, dataout, enable, write);
    end generate;    
  end generate;
end;

-- syncronous dual-port ram

LIBRARY ieee;
use IEEE.std_logic_1164.all;
use work.leon_target.all;
use work.leon_config.all;
use work.leon_iface.all;
use work.tech_generic.all;
use work.tech_atc18.all;
use work.tech_atc25.all;
use work.tech_virtex.all;
use work.tech_virtex2.all;
use work.tech_tsmc25.all;

entity dpsyncram is
  generic ( abits : integer := 8; dbits : integer := 32);
  port (
    address1 : in std_logic_vector((abits -1) downto 0);
    clk      : in clk_type;
    datain1  : in std_logic_vector((dbits -1) downto 0);
    dataout1 : out std_logic_vector((dbits -1) downto 0);
    enable1  : in std_logic;
    write1   : in std_logic;
    address2 : in std_logic_vector((abits -1) downto 0);
    datain2  : in std_logic_vector((dbits -1) downto 0);
    dataout2 : out std_logic_vector((dbits -1) downto 0);
    enable2  : in std_logic;
    write2   : in std_logic
  );
end;

architecture behav of dpsyncram is
begin

-- pragma translate_off
  inf : if INFER_RAM generate 
    x : process(clk)
    begin
      assert false 
	report "infering of dual-port rams not supported!"
      severity error;
    end process;
  end generate;
-- pragma translate_on

  hb : if (not INFER_RAM) generate 
    atc1 : if TARGET_TECH = atc18 generate 
      u0 : atc18_dpram generic map (abits => abits, dbits => dbits)
	   port map (address1, clk, datain1, dataout1, enable1, write1,
	             address2, datain2, dataout2, enable2, write2);
    end generate;
    atc2 : if TARGET_TECH = atc25 generate 
      u0 : atc25_dpram generic map (abits => abits, dbits => dbits)
	   port map (address1, clk, datain1, dataout1, enable1, write1,
	             address2, datain2, dataout2, enable2, write2);
    end generate;
    xcv : if TARGET_TECH = virtex generate 
      u0 : virtex_dpram generic map (abits => abits, dbits => dbits)
	   port map (address1, clk, datain1, dataout1, enable1, write1,
	             address2, clk, datain2, dataout2, enable2, write2);
    end generate;
    xc2v : if TARGET_TECH = virtex2 generate 
      u0 : virtex2_dpram generic map (abits => abits, dbits => dbits)
	   port map (address1, clk, datain1, dataout1, enable1, write1,
	             address2, clk, datain2, dataout2, enable2, write2);
    end generate;
    tsmc : if TARGET_TECH = tsmc25 generate 
      u0 : tsmc25_dpram generic map (abits => abits, dbits => dbits)
	   port map (address1, clk, datain1, dataout1, enable1, write1,
	             address2, datain2, dataout2, enable2, write2);
    end generate;

-- pragma translate_off
    notech : if ((TARGET_TECH /= virtex) and (TARGET_TECH /= atc25) and 
                 (TARGET_TECH /= virtex2) and 
                 (TARGET_TECH /= atc18) and (TARGET_TECH /= tsmc25)) generate 
      x : process(clk)
      begin
        assert false 
	  report "dual-port rams not supported for this technology!"
        severity error;
      end process;
    end generate;
-- pragma translate_on
  end generate;
end;

-- IU regfile

LIBRARY ieee;
use IEEE.std_logic_1164.all;
use work.leon_target.all;
use work.leon_config.all;
use work.leon_iface.all;
use work.tech_atc18.all;
use work.tech_atc25.all;
use work.tech_atc35.all;
use work.tech_fs90.all;
use work.tech_umc18.all;
use work.tech_generic.all;
use work.tech_virtex.all;
use work.tech_virtex2.all;
use work.tech_tsmc25.all;
use work.tech_proasic.all;
use work.tech_axcel.all;

entity regfile_iu is
  generic ( 
    rftype : integer := 1;
    abits : integer := 8; dbits : integer := 32; words : integer := 128
  );
  port (
    rst      : in std_logic;
    clk      : in clk_type;
    clkn     : in clk_type;
    rfi      : in rf_in_type;
    rfo      : out rf_out_type);
end;

architecture rtl of regfile_iu is
signal vcc : std_logic;
begin

  vcc <= '1';

  inf : if INFER_REGF generate 
    u0 : generic_regfile_iu generic map (rftype, abits, dbits, words)

         port map (rst, clk, clkn, rfi, rfo);

  end generate;

  ninf : if not INFER_REGF generate 
    atm1 : if TARGET_TECH = atc18 generate 
      u0 : atc18_regfile_iu generic map (rftype, abits, dbits, words)
	   port map (rst, clk, clkn, rfi, rfo);
    end generate;
    atm2 : if TARGET_TECH = atc25 generate 
      u0 : atc25_regfile_iu generic map (rftype, abits, dbits, words)
	   port map (rst, clk, clkn, rfi, rfo);
    end generate;
    atm3 : if TARGET_TECH = atc35 generate 
      u0 : atc35_regfile generic map (abits, dbits, words)
	   port map (rst, clk, clkn, rfi, rfo);
    end generate;
    umc0 : if TARGET_TECH = fs90 generate 
      u0 : fs90_regfile generic map (abits, dbits, words)
	   port map (rst, clk, clkn, rfi, rfo);
    end generate;
    umc1 : if TARGET_TECH = umc18 generate 
      u0 : umc18_regfile generic map (abits, dbits, words)
	   port map (rst, clk, clkn, rfi, rfo);
    end generate;
    xcv : if TARGET_TECH = virtex generate 
      u0 : virtex_regfile generic map (rftype, abits, dbits, words)
	   port map (rst, clk , clkn , rfi, rfo);
    end generate;
    xc2v : if TARGET_TECH = virtex2 generate 
      u0 : virtex2_regfile generic map (rftype, abits, dbits, words)
	   port map (rst, clk , clkn , rfi, rfo);
    end generate;
    sim : if TARGET_TECH = gen generate
      u0 : generic_regfile_iu generic map (rftype, abits, dbits, words)
	 port map (rst, clk , clkn , rfi, rfo);
    end generate;
    tsmc : if TARGET_TECH = tsmc25 generate 
      u0 : tsmc25_regfile_iu generic map (abits, dbits, words)
	 port map (rst, clk , clkn , rfi, rfo);
    end generate;
    proa : if TARGET_TECH = proasic generate 
      u0 : proasic_regfile_iu generic map (rftype, abits, dbits, words)
	   port map (rst, clk , clkn , rfi, rfo);
    end generate;
    axc : if TARGET_TECH = axcel generate 
      u0 : axcel_regfile_iu generic map (rftype, abits, dbits, words)
	   port map (rst, clk , clkn , rfi, rfo);
    end generate;
  end generate;
end;

-- Parallel FPU/CP regfile

LIBRARY ieee;
use IEEE.std_logic_1164.all;
use work.leon_target.all;
use work.leon_config.all;
use work.leon_iface.all;
use work.tech_atc18.all;
use work.tech_atc25.all;
use work.tech_atc35.all;
use work.tech_fs90.all;
use work.tech_umc18.all;
use work.tech_generic.all;
use work.tech_virtex.all;
use work.tech_virtex2.all;
use work.tech_tsmc25.all;
use work.tech_proasic.all;
use work.tech_axcel.all;

entity regfile_cp is
  generic ( 
    abits : integer := 4; dbits : integer := 32; words : integer := 16
  );
  port (
    rst      : in std_logic;
    clk      : in clk_type;
    rfi      : in rf_cp_in_type;
    rfo      : out rf_cp_out_type);
end;

architecture rtl of regfile_cp is
signal vcc : std_logic;
begin

  vcc <= '1';

  inf : if INFER_REGF generate 
    u0 : generic_regfile_cp generic map (abits, dbits, words)

         port map (rst, clk, rfi, rfo);

  end generate;

  ninf : if not INFER_REGF generate 
    atm1 : if TARGET_TECH = atc18 generate 
      u0 : atc18_regfile_cp generic map (abits, dbits, words)
	   port map (rst, clk, rfi, rfo);
    end generate;
    atm2 : if TARGET_TECH = atc25 generate 
      u0 : atc25_regfile_cp generic map (abits, dbits, words)
	   port map (rst, clk, rfi, rfo);
    end generate;
    atm3 : if TARGET_TECH = atc35 generate 
      u0 : atc35_regfile_cp generic map (abits, dbits, words)
	   port map (rst, clk, rfi, rfo);
    end generate;
--    umc0 : if TARGET_TECH = fs90 generate 
--      u0 : fs90_regfile_cp generic map (abits, dbits, words)
--	   port map (rst, clk, rfi, rfo);
--    end generate;
--    umc1 : if TARGET_TECH = umc18 generate 
--      u0 : umc18_regfile_cp generic map (abits, dbits, words)
--	   port map (rst, clk, rfi, rfo);
--    end generate;
    xcv : if TARGET_TECH = virtex generate 
      u0 : virtex_regfile_cp generic map (abits, dbits, words)
	   port map (rst, clk , rfi, rfo);
    end generate;
    xc2v : if TARGET_TECH = virtex2 generate 
      u0 : virtex2_regfile_cp generic map (abits, dbits, words)
	   port map (rst, clk , rfi, rfo);
    end generate;
    tsmc : if TARGET_TECH = tsmc25 generate 
      u0 : tsmc25_regfile_cp generic map (abits, dbits, words)
	   port map (rst, clk , rfi, rfo);
    end generate;
    sim : if TARGET_TECH = gen generate
      u0 : generic_regfile_cp generic map (abits, dbits, words)
	 port map (rst, clk , rfi, rfo);
    end generate;
    proa : if TARGET_TECH = proasic generate 
      u0 : proasic_regfile_cp generic map (abits, dbits, words)
	   port map (rst, clk , rfi, rfo);
    end generate;
    axc : if TARGET_TECH = axcel generate 
      u0 : axcel_regfile_cp generic map (abits, dbits, words)
	   port map (rst, clk , rfi, rfo);
    end generate;
  end generate;
end;

-- boot-prom

LIBRARY ieee;
use IEEE.std_logic_1164.all;
use work.leon_target.all;
use work.leon_config.all;
use work.tech_atc35.all;
use work.tech_generic.all;
use work.tech_virtex.all;

entity bprom is
  port (
    clk       : in std_logic;
    cs        : in std_logic;
    addr      : in std_logic_vector(31 downto 0);
    data      : out std_logic_vector(31 downto 0)
  );
end;

architecture rtl of bprom is
component gen_bprom
  port (
    clk : in std_logic;
    csn : in std_logic;
    addr : in std_logic_vector (29 downto 0);
    data : out std_logic_vector (31 downto 0));
end component;
begin

  b0: if INFER_ROM generate
    u0 : gen_bprom port map (clk, cs, addr(31 downto 2), data);
  end generate;

  b1: if (not INFER_ROM) and ((TARGET_TECH = virtex) or (TARGET_TECH = virtex2)) generate
    u0 : virtex_bprom port map (clk, addr(31 downto 2), data);
  end generate;

end;

-- multiplier 

library ieee;
use ieee.std_logic_1164.all;
use work.leon_target.all;
use work.leon_config.all;
use work.leon_iface.all;
use work.multlib.all;
use work.tech_generic.all;

entity hw_smult is
  generic ( abits : integer := 10; bbits : integer := 8 );
  port (
    clk  : in  clk_type;
    holdn: in  std_logic;
    a    : in  std_logic_vector(abits-1 downto 0);
    b    : in  std_logic_vector(bbits-1 downto 0);
    c    : out std_logic_vector(abits+bbits-1 downto 0)
  ); 
end;

architecture rtl of hw_smult is
begin

  inf : if INFER_MULT generate
    u0 : generic_smult 
         generic map (abits => abits, bbits => bbits)
         port map (a, b, c);
  end generate;

  mg : if not INFER_MULT generate
    m1717 : if (abits = 17) and (bbits = 17) generate
      u0 : mul_17_17 port map (clk, holdn, a, b, c);
    end generate;
    m339 : if (abits = 33) and (bbits = 9) generate
      u0 : mul_33_9 port map (a, b, c);
    end generate;
    m3317 : if (abits = 33) and (bbits = 17) generate
      u0 : mul_33_17 port map (a, b, c);
    end generate;
    m3333 : if (abits = 33) and (bbits = 33) generate
      u0 : mul_33_33 port map (a, b, c);
    end generate;
  end generate;
end;

-- input pad

library IEEE;
use IEEE.std_logic_1164.all;
use work.leon_target.all;
use work.leon_config.all;
use work.tech_atc18.all;
use work.tech_atc25.all;
use work.tech_atc35.all;
use work.tech_fs90.all;
use work.tech_umc18.all;
use work.tech_generic.all;
use work.tech_tsmc25.all;

entity inpad is port (pad : in std_logic; q : out std_logic); end; 
architecture rtl of inpad is
begin
  inf : if INFER_PADS or (TARGET_TECH = gen) or 
          (TARGET_TECH = virtex) or (TARGET_TECH = proasic) or
          (TARGET_TECH = virtex2) or (TARGET_TECH = axcel) generate
    ginpad0 : geninpad port map (q => q, pad => pad);
  end generate;
  ninf : if not INFER_PADS generate
    ip0 : if TARGET_TECH = atc18 generate
      ipx : atc18_inpad port map (q => q, pad => pad);
    end generate;
    ip1 : if TARGET_TECH = atc25 generate
      ipx : atc25_inpad port map (q => q, pad => pad);
    end generate;
    ip2 : if TARGET_TECH = atc35 generate
      ipx : atc35_inpad port map (q => q, pad => pad);
    end generate;
    ip3 : if TARGET_TECH = fs90 generate
      ipx : fs90_inpad port map (q => q, pad => pad);
    end generate;
    ip4 : if TARGET_TECH = umc18 generate
      ipx : umc18_inpad port map (q => q, pad => pad);
    end generate;
    ip5 : if TARGET_TECH = tsmc25 generate
      ipx : tsmc25_inpad port map (q => q, pad => pad);
    end generate;
  end generate;
end;

-- input schmitt pad

library IEEE;
use IEEE.std_logic_1164.all;
use work.leon_target.all;
use work.leon_config.all;
use work.tech_atc18.all;
use work.tech_atc25.all;
use work.tech_atc35.all;
use work.tech_fs90.all;
use work.tech_umc18.all;
use work.tech_generic.all;
use work.tech_tsmc25.all;

entity smpad is port (pad : in std_logic; q : out std_logic); end; 
architecture rtl of smpad is
begin
  inf : if INFER_PADS or (TARGET_TECH = gen) or 
          (TARGET_TECH = virtex) or (TARGET_TECH = proasic) or
          (TARGET_TECH = virtex2) or (TARGET_TECH = axcel) generate
    gsmpad0 : gensmpad port map (pad => pad, q => q);
  end generate;
  ninf : if not INFER_PADS generate
    sm0 : if TARGET_TECH = atc18 generate
      smx : atc18_smpad port map (q => q, pad => pad);
    end generate;
    sm1 : if TARGET_TECH = atc25 generate
      smx : atc25_smpad port map (q => q, pad => pad);
    end generate;
    sm2 : if TARGET_TECH = atc35 generate
      smx : atc35_smpad port map (q => q, pad => pad);
    end generate;
    sm3 : if TARGET_TECH = fs90 generate
      smx : fs90_smpad port map (q => q, pad => pad);
    end generate;
    sm4 : if TARGET_TECH = umc18 generate
      smx : umc18_smpad port map (q => q, pad => pad);
    end generate;
    sm5 : if TARGET_TECH = tsmc25 generate
      smx : tsmc25_smpad port map (q => q, pad => pad);
    end generate;
  end generate;
end;

-- output pads

library IEEE;
use IEEE.std_logic_1164.all;
use work.leon_target.all;
use work.leon_config.all;
use work.tech_atc25.all;
use work.tech_atc35.all;
use work.tech_fs90.all;
use work.tech_umc18.all;
use work.tech_generic.all;
use work.tech_tsmc25.all;

entity outpad is
  generic (drive : integer := 1);
  port (d : in std_logic; pad : out std_logic);
end; 
architecture rtl of outpad is
begin
  inf : if INFER_PADS or (TARGET_TECH = gen) or 
          (TARGET_TECH = virtex) or (TARGET_TECH = proasic) or
          (TARGET_TECH = virtex2) or (TARGET_TECH = axcel) generate
    goutpad0 : genoutpad port map (d => d, pad => pad);
  end generate;
  ninf : if not INFER_PADS generate
    op1 : if (TARGET_TECH = atc25) or (TARGET_TECH = atc18) generate
      opx : atc25_outpad generic map (drive) port map (d => d, pad => pad);
    end generate;
    op2 : if TARGET_TECH = atc35 generate
      opx : atc35_outpad generic map (drive) port map (d => d, pad => pad);
    end generate;
    op3 : if TARGET_TECH = fs90 generate
      opx : fs90_outpad generic map (drive) port map (d => d, pad => pad);
    end generate;
    op4 : if TARGET_TECH = umc18 generate
      opx : umc18_outpad generic map (drive) port map (d => d, pad => pad);
    end generate;
    op5 : if TARGET_TECH = tsmc25 generate
      opx : tsmc25_outpad generic map (drive) port map (d => d, pad => pad);
    end generate;
  end generate;
end;

-- tri-state output pads with pull-up

library IEEE;
use IEEE.std_logic_1164.all;
use work.leon_target.all;
use work.leon_config.all;
use work.tech_atc25.all;
use work.tech_atc35.all;
use work.tech_fs90.all;
use work.tech_umc18.all;
use work.tech_generic.all;
use work.tech_tsmc25.all;

entity toutpadu is
  generic (drive : integer := 1);
  port (d, en : in std_logic; pad : out std_logic);
end; 
architecture rtl of toutpadu is
begin
  inf : if INFER_PADS or (TARGET_TECH = gen) or 
          (TARGET_TECH = virtex) or (TARGET_TECH = proasic) or
          (TARGET_TECH = virtex2) or (TARGET_TECH = axcel) generate
    giop0 : gentoutpadu port map (d => d, en => en, pad => pad);
  end generate;
  ninf : if not INFER_PADS generate
    atc25t : if (TARGET_TECH = atc25) or (TARGET_TECH = atc18) generate
      p0 : atc25_toutpadu generic map (drive) port map (d => d, en => en, pad => pad);
    end generate;
    atc35t : if TARGET_TECH = atc35 generate
      p0 : atc35_toutpadu generic map (drive) port map (d => d, en => en, pad => pad);
    end generate;
    fs90t : if TARGET_TECH = fs90 generate
      p0 : fs90_toutpadu generic map (drive) port map (d => d, en => en, pad => pad);
    end generate;
    umc18t : if TARGET_TECH = umc18 generate
      p0 : umc18_toutpadu generic map (drive) port map (d => d, en => en, pad => pad);
    end generate;
    tsmc25t : if TARGET_TECH = tsmc25 generate
      p0 : tsmc25_toutpadu generic map (drive) port map (d => d, en => en, pad => pad);
    end generate;
  end generate;
end;

-- bidirectional pad

library IEEE;
use IEEE.std_logic_1164.all;
use work.leon_target.all;
use work.leon_config.all;
use work.tech_atc25.all;
use work.tech_atc35.all;
use work.tech_fs90.all;
use work.tech_umc18.all;
use work.tech_generic.all;
use work.tech_tsmc25.all;

entity iopad is
  generic (drive : integer := 1);
  port (
    d     : in  std_logic;
    en    : in  std_logic;
    q     : out std_logic;
    pad   : inout std_logic
  );
end; 

architecture rtl of iopad is
begin
  inf : if INFER_PADS or (TARGET_TECH = gen) or 
          (TARGET_TECH = virtex) or (TARGET_TECH = proasic) or
          (TARGET_TECH = virtex2) or (TARGET_TECH = axcel) generate
    giop0 : geniopad port map (d => d, en => en, q => q, pad => pad);
  end generate;
  ninf : if not INFER_PADS generate
    atc25t : if (TARGET_TECH = atc25) or (TARGET_TECH = atc18) generate
      p0 : atc25_iopad generic map (drive) port map (d => d, en => en, q => q, pad => pad);
    end generate;
    atc35t : if TARGET_TECH = atc35 generate
      po : atc35_iopad generic map (drive) port map (d => d, en => en, q => q, pad => pad);
    end generate;
    fs90t : if TARGET_TECH = fs90 generate
      po : fs90_iopad generic map (drive) port map (d => d, en => en, q => q, pad => pad);
    end generate;
    umc18t : if TARGET_TECH = umc18 generate
      po : umc18_iopad generic map (drive) port map (d => d, en => en, q => q, pad => pad);
    end generate;
    tsmc25t : if TARGET_TECH = tsmc25 generate
      po : tsmc25_iopad generic map (drive) port map (d => d, en => en, q => q, pad => pad);
    end generate;
  end generate;
end;

-- bidirectional pad with schmitt trigger for I/O ports
-- (if available)

library IEEE;
use IEEE.std_logic_1164.all;
use work.leon_target.all;
use work.leon_config.all;
use work.tech_atc25.all;
use work.tech_atc35.all;
use work.tech_fs90.all;
use work.tech_umc18.all;
use work.tech_generic.all;
use work.tech_tsmc25.all;

entity smiopad is
  generic (drive : integer := 1);
  port (
    d     : in  std_logic;
    en    : in  std_logic;
    q     : out std_logic;
    pad   : inout std_logic
  );
end; 

architecture rtl of smiopad is
begin
  inf : if INFER_PADS or (TARGET_TECH = gen) or 
          (TARGET_TECH = virtex) or (TARGET_TECH = proasic) or
          (TARGET_TECH = virtex2) or (TARGET_TECH = axcel) generate
    giop0 : geniopad port map (d => d, en => en, q => q, pad => pad);
  end generate;
  ninf : if not INFER_PADS generate
    smiop1 : if (TARGET_TECH = atc25) or (TARGET_TECH = atc18) generate
      p0 : atc25_iopad generic map (drive) port map (d => d, en => en, q => q, pad => pad);
    end generate;
    smiop2 : if TARGET_TECH = atc35 generate
      p0 : atc35_iopad generic map (drive) port map (d => d, en => en, q => q, pad => pad);
    end generate;
    smiop3 : if TARGET_TECH = fs90 generate
      p0 : fs90_smiopad generic map (drive) port map (d => d, en => en, q => q, pad => pad);
    end generate;
    smiop4 : if TARGET_TECH = umc18 generate
      p0 : umc18_smiopad generic map (drive) port map (d => d, en => en, q => q, pad => pad);
    end generate;
    smiop5 : if TARGET_TECH = tsmc25 generate
      p0 : tsmc25_smiopad generic map (drive) port map (d => d, en => en, q => q, pad => pad);
    end generate;
  end generate;
end;

-- open-drain pad

library IEEE;
use IEEE.std_logic_1164.all;
use work.leon_target.all;
use work.leon_config.all;
use work.tech_atc25.all;
use work.tech_atc35.all;
use work.tech_fs90.all;
use work.tech_umc18.all;
use work.tech_generic.all;
use work.tech_tsmc25.all;

entity odpad is
  generic (drive : integer := 1);
  port (d : in std_logic; pad : out std_logic);
end; 
architecture rtl of odpad is
begin
  inf : if INFER_PADS or (TARGET_TECH = gen) or 
          (TARGET_TECH = virtex) or (TARGET_TECH = proasic) or
          (TARGET_TECH = virtex2) or (TARGET_TECH = axcel) generate
    godpad0 : genodpad port map (d => d, pad => pad);
  end generate;
  ninf : if not INFER_PADS generate
    odp1 : if (TARGET_TECH = atc25) or (TARGET_TECH = atc18) generate
      p0 : atc25_odpad generic map (drive) port map (d => d, pad => pad);
    end generate;
    odp2 : if TARGET_TECH = atc35 generate
      p0 : atc35_odpad generic map (drive) port map (d => d, pad => pad);
    end generate;
    odp3 : if TARGET_TECH = fs90 generate
      p0 : fs90_odpad generic map (drive) port map (d => d, pad => pad);
    end generate;
    odp4 : if TARGET_TECH = umc18 generate
      p0 : umc18_odpad generic map (drive) port map (d => d, pad => pad);
    end generate;
    odp5 : if TARGET_TECH = tsmc25 generate
      p0 : tsmc25_odpad generic map (drive) port map (d => d, pad => pad);
    end generate;
  end generate;
end;

-- bi-directional open-drain
library IEEE;
use IEEE.std_logic_1164.all;
use work.leon_target.all;
use work.leon_config.all;
use work.tech_atc25.all;
use work.tech_atc35.all;
use work.tech_fs90.all;
use work.tech_umc18.all;
use work.tech_generic.all;
use work.tech_tsmc25.all;

entity iodpad is
  generic (drive : integer := 1);
  port ( d : in  std_logic; q : out std_logic; pad : inout std_logic);
end; 

architecture rtl of iodpad is
begin 
  inf : if INFER_PADS or (TARGET_TECH = gen) or 
          (TARGET_TECH = virtex) or (TARGET_TECH = proasic) or
          (TARGET_TECH = virtex2) or (TARGET_TECH = axcel) generate
    giodp0 : geniodpad port map (d => d, q => q, pad => pad);
  end generate;
  ninf : if not INFER_PADS generate
    iodp1 : if (TARGET_TECH = atc25) or (TARGET_TECH = atc18) generate
      p0 : atc25_iodpad generic map (drive) port map (d => d, q => q, pad => pad);
    end generate;
    iodp2 : if TARGET_TECH = atc35 generate
      p0 : atc35_iodpad generic map (drive) port map (d => d, q => q, pad => pad);
    end generate;
    iodp3 : if TARGET_TECH = fs90 generate
      p0 : fs90_iodpad generic map (drive) port map (d => d, q => q, pad => pad);
    end generate;
    iodp4 : if TARGET_TECH = umc18 generate
      p0 : umc18_iodpad generic map (drive) port map (d => d, q => q, pad => pad);
    end generate;
    iodp5 : if TARGET_TECH = tsmc25 generate
      p0 : tsmc25_iodpad generic map (drive) port map (d => d, q => q, pad => pad);
    end generate;
  end generate;
end;

-- PCI input pad

library IEEE;
use IEEE.std_logic_1164.all;
use work.leon_target.all;
use work.leon_config.all;
use work.tech_virtex.all;
use work.tech_generic.all;
use work.tech_map.all;
entity pciinpad is port (pad : in std_logic; q : out std_logic); end; 
architecture rtl of pciinpad is
begin
  inf : if INFER_PCI_PADS or ((TARGET_TECH /= virtex) and (TARGET_TECH /= virtex2))
  generate
    ginpad0 : geninpad port map (q => q, pad => pad);
  end generate;
  ninf : if not INFER_PCI_PADS generate
    xcv : if (TARGET_TECH = virtex) or (TARGET_TECH = virtex2) generate
      p0 : virtex_pciinpad port map (q => q, pad => pad);
    end generate;
  end generate;
end;

-- PCI output pad

library IEEE;
use IEEE.std_logic_1164.all;
use work.leon_target.all;
use work.leon_config.all;
use work.tech_virtex.all;
use work.tech_atc25.all;
use work.tech_generic.all;

entity pcioutpad is port (d : in std_logic; pad : out std_logic); end; 
architecture rtl of pcioutpad is
begin
  inf : if INFER_PCI_PADS or ((TARGET_TECH /= atc25) and (TARGET_TECH /= atc18) and
	 (TARGET_TECH /= virtex) and (TARGET_TECH /= virtex2)) generate
    goutpad0 : genoutpad port map (d => d, pad => pad);
  end generate;
  ninf : if not INFER_PCI_PADS generate
    xcv : if (TARGET_TECH = virtex) or (TARGET_TECH = virtex2) generate
      opx : virtex_pcioutpad port map (d => d, pad => pad);
    end generate;
    op1 : if (TARGET_TECH = atc25) or (TARGET_TECH = atc18) generate
      opx : atc25_pcioutpad port map (d => d, pad => pad);
    end generate;
  end generate;
end;

-- PCI tristate output pad
library IEEE;
use IEEE.std_logic_1164.all;
use work.leon_target.all;
use work.leon_config.all;
use work.tech_virtex.all;
use work.tech_atc25.all;
use work.tech_generic.all;

entity pcitoutpad is port (d, en : in std_logic; pad : out std_logic); end; 

architecture rtl of pcitoutpad is
begin
  inf : if INFER_PCI_PADS or ((TARGET_TECH /= atc25) and (TARGET_TECH /= atc18) and
	 (TARGET_TECH /= virtex) and (TARGET_TECH /= virtex2)) generate
    giop0 : gentoutpadu port map (d => d, en => en, pad => pad);
  end generate;
  ninf : if not INFER_PCI_PADS generate
    xcv : if (TARGET_TECH = virtex) or (TARGET_TECH = virtex2) generate
      p0 : virtex_pcitoutpad port map (d => d, en => en, pad => pad);
    end generate;
    atc25t : if (TARGET_TECH = atc25) or (TARGET_TECH = atc18) generate
      p0 : atc25_pcitoutpad port map (d => d, en => en, pad => pad);
    end generate;
  end generate;
end;

-- bidirectional pad
-- PCI bidir pad

library IEEE;
use IEEE.std_logic_1164.all;
use work.leon_target.all;
use work.leon_config.all;
use work.tech_virtex.all;
use work.tech_atc25.all;
use work.tech_generic.all;

entity pciiopad is
  port (
    d     : in  std_logic;
    en    : in  std_logic;
    q     : out std_logic;
    pad   : inout std_logic
  );
end; 

architecture rtl of pciiopad is
begin
  inf : if INFER_PCI_PADS or ((TARGET_TECH /= atc25) and (TARGET_TECH /= atc18) and
	 (TARGET_TECH /= virtex) and (TARGET_TECH /= virtex2)) generate
    giop0 : geniopad port map (d => d, en => en, q => q, pad => pad);
  end generate;
  ninf : if not INFER_PCI_PADS generate
    xcv : if (TARGET_TECH = virtex) or (TARGET_TECH = virtex2) generate
      p0 : virtex_pciiopad port map (d => d, en => en, q => q, pad => pad);
    end generate;
    iop1 : if (TARGET_TECH = atc25) or (TARGET_TECH = atc18) generate
      p0 : atc25_pciiopad port map (d => d, en => en, q => q, pad => pad);
    end generate;
  end generate;
end;

-- PCI bi-directional open-drain
library IEEE;
use IEEE.std_logic_1164.all;
use work.leon_target.all;
use work.leon_config.all;
use work.tech_virtex.all;
use work.tech_atc25.all;
use work.tech_generic.all;

entity pciiodpad is
  port ( d : in  std_logic; q : out std_logic; pad : inout std_logic);
end; 

architecture rtl of pciiodpad is
begin 
  inf : if INFER_PCI_PADS or ((TARGET_TECH /= atc25) and (TARGET_TECH /= atc18) and
	 (TARGET_TECH /= virtex) and (TARGET_TECH /= virtex2)) generate
    giodp0 : geniodpad port map (d => d, q => q, pad => pad);
  end generate;
  ninf : if not INFER_PCI_PADS generate
    xcv : if (TARGET_TECH = virtex) or (TARGET_TECH = virtex2) generate
      p0 : virtex_pciiodpad port map (d => d, q => q, pad => pad);
    end generate;
    iodp1 : if (TARGET_TECH = atc25) or (TARGET_TECH = atc18) generate
      p0 : atc25_pciiodpad port map (d => d, q => q, pad => pad);
    end generate;
  end generate;
end;

library IEEE;
use IEEE.std_logic_1164.all;
use work.leon_target.all;
use work.leon_iface.all;
use work.leon_config.all;
use work.tech_generic.all;
use work.tech_virtex.all;
use work.tech_virtex2.all;

entity clkgen is
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

architecture rtl of clkgen is
begin

  c0: if TARGET_CLK = gen generate
    g0 : generic_clkgen 
    port map (clkin, pciclkin, clk, clkn, sdclk, pciclk, cgi, cgo);
  end generate;
  c1: if TARGET_CLK = virtex generate
    v : virtex_clkgen 
    generic map (clk_mul => PLL_CLK_MUL, clk_div => PLL_CLK_DIV)
    port map (clkin, pciclkin, clk, clkn, sdclk, pciclk, cgi, cgo);
  end generate;
  c2: if TARGET_CLK = virtex2 generate
    v : virtex2_clkgen 
    generic map (clk_mul => PLL_CLK_MUL, clk_div => PLL_CLK_DIV)
    port map (clkin, pciclkin, clk, clkn, sdclk, pciclk, cgi, cgo);
  end generate;

end;
