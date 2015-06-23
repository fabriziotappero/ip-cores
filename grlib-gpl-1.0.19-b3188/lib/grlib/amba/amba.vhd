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
-- Package: 	amba
-- File:	amba.vhd
-- Author:	Jiri Gaisler, Gaisler Research
-- Description:	AMBA 2.0 bus signal definitions + support for plug&play
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
-- pragma translate_off
use std.textio.all;
-- pragma translate_on
library grlib;
use grlib.stdlib.all;

package amba is

constant NAHBMST : integer := 16;  -- maximum AHB masters
constant NAHBSLV : integer := 16;  -- maximum AHB slaves
constant NAPBSLV : integer := 16; -- maximum APB slaves
constant NAHBIRQ : integer := 32; -- maximum interrupts
constant NAHBAMR : integer := 4;  -- maximum address mapping registers
constant NAHBIR  : integer := 4;  -- maximum AHB identification registers
constant NAHBCFG : integer := NAHBIR + NAHBAMR;  -- words in AHB config block
constant NAPBIR  : integer := 1;  -- maximum APB configuration words
constant NAPBAMR : integer := 1;  -- maximum APB configuration words
constant NAPBCFG : integer := NAPBIR + NAPBAMR;  -- words in APB config block
constant NBUS    : integer := 4;

subtype amba_config_word is std_logic_vector(31 downto 0);
type ahb_config_type is array (0 to NAHBCFG-1) of amba_config_word;
type apb_config_type is array (0 to NAPBCFG-1) of amba_config_word;

-- AHB master inputs
  type ahb_mst_in_type is record
    hgrant	: std_logic_vector(0 to NAHBMST-1);     -- bus grant
    hready	: std_ulogic;                         	-- transfer done
    hresp	: std_logic_vector(1 downto 0); 	-- response type
    hrdata	: std_logic_vector(31 downto 0); 	-- read data bus
    hcache	: std_ulogic;                         	-- cacheable
    hirq  	: std_logic_vector(NAHBIRQ-1 downto 0);	-- interrupt result bus
    testen	: std_ulogic;                         	-- scan test enable
    testrst	: std_ulogic;                         	-- scan test reset
    scanen 	: std_ulogic;                         	-- scan enable
    testoen 	: std_ulogic;                         	-- test output enable 
  end record;

-- AHB master outputs
  type ahb_mst_out_type is record
    hbusreq	: std_ulogic;                         	-- bus request
    hlock	: std_ulogic;                         	-- lock request
    htrans	: std_logic_vector(1 downto 0); 	-- transfer type
    haddr	: std_logic_vector(31 downto 0); 	-- address bus (byte)
    hwrite	: std_ulogic;                         	-- read/write
    hsize	: std_logic_vector(2 downto 0); 	-- transfer size
    hburst	: std_logic_vector(2 downto 0); 	-- burst type
    hprot	: std_logic_vector(3 downto 0); 	-- protection control
    hwdata	: std_logic_vector(31 downto 0); 	-- write data bus
    hirq   	: std_logic_vector(NAHBIRQ-1 downto 0);	-- interrupt bus
    hconfig 	: ahb_config_type;	 		-- memory access reg.
    hindex  	: integer range 0 to NAHBMST-1;	 	-- diagnostic use only
  end record;

-- AHB slave inputs
  type ahb_slv_in_type is record
    hsel	: std_logic_vector(0 to NAHBSLV-1);     -- slave select
    haddr	: std_logic_vector(31 downto 0); 	-- address bus (byte)
    hwrite	: std_ulogic;                         	-- read/write
    htrans	: std_logic_vector(1 downto 0); 	-- transfer type
    hsize	: std_logic_vector(2 downto 0); 	-- transfer size
    hburst	: std_logic_vector(2 downto 0); 	-- burst type
    hwdata	: std_logic_vector(31 downto 0); 	-- write data bus
    hprot	: std_logic_vector(3 downto 0); 	-- protection control
    hready	: std_ulogic;                         	-- transfer done
    hmaster	: std_logic_vector(3 downto 0); 	-- current master
    hmastlock	: std_ulogic;                         	-- locked access
    hmbsel 	: std_logic_vector(0 to NAHBAMR-1);	-- memory bank select
    hcache	: std_ulogic;                         	-- cacheable
    hirq  	: std_logic_vector(NAHBIRQ-1 downto 0);	-- interrupt result bus
    testen	: std_ulogic;                         	-- scan test enable
    testrst	: std_ulogic;                         	-- scan test reset
    scanen  	: std_ulogic;                         	-- scan enable
    testoen 	: std_ulogic;                         	-- test output enable 
  end record;

-- AHB slave outputs
  type ahb_slv_out_type is record
    hready	: std_ulogic;                         	-- transfer done
    hresp	: std_logic_vector(1 downto 0); 	-- response type
    hrdata	: std_logic_vector(31 downto 0); 	-- read data bus
    hsplit	: std_logic_vector(15 downto 0); 	-- split completion
    hcache	: std_ulogic;                         	-- cacheable
    hirq   	: std_logic_vector(NAHBIRQ-1 downto 0); -- interrupt bus
    hconfig 	: ahb_config_type;	 		-- memory access reg.
    hindex  	: integer range 0 to NAHBSLV-1;	 	-- diagnostic use only
  end record;

-- array types
  type ahb_mst_out_vector_type is array (natural range <>) of ahb_mst_out_type;
  type ahb_slv_out_vector_type is array (natural range <>) of ahb_slv_out_type;
  subtype ahb_mst_out_vector is ahb_mst_out_vector_type(NAHBMST-1 downto 0);
  subtype ahb_slv_out_vector is ahb_slv_out_vector_type(NAHBSLV-1 downto 0);
  type ahb_mst_out_bus_vector is array (0 to NBUS-1) of ahb_mst_out_vector;
  type ahb_slv_out_bus_vector is array (0 to NBUS-1) of ahb_slv_out_vector;


-- constants
  constant HTRANS_IDLE:   std_logic_vector(1 downto 0) := "00";
  constant HTRANS_BUSY:   std_logic_vector(1 downto 0) := "01";
  constant HTRANS_NONSEQ: std_logic_vector(1 downto 0) := "10";
  constant HTRANS_SEQ:    std_logic_vector(1 downto 0) := "11";

  constant HBURST_SINGLE: std_logic_vector(2 downto 0) := "000";
  constant HBURST_INCR:   std_logic_vector(2 downto 0) := "001";
  constant HBURST_WRAP4:  std_logic_vector(2 downto 0) := "010";
  constant HBURST_INCR4:  std_logic_vector(2 downto 0) := "011";
  constant HBURST_WRAP8:  std_logic_vector(2 downto 0) := "100";
  constant HBURST_INCR8:  std_logic_vector(2 downto 0) := "101";
  constant HBURST_WRAP16: std_logic_vector(2 downto 0) := "110";
  constant HBURST_INCR16: std_logic_vector(2 downto 0) := "111";

  constant HSIZE_BYTE:    std_logic_vector(2 downto 0) := "000";
  constant HSIZE_HWORD:   std_logic_vector(2 downto 0) := "001";
  constant HSIZE_WORD:    std_logic_vector(2 downto 0) := "010";
  constant HSIZE_DWORD:   std_logic_vector(2 downto 0) := "011";
  constant HSIZE_4WORD:   std_logic_vector(2 downto 0) := "100";
  constant HSIZE_8WORD:   std_logic_vector(2 downto 0) := "101";
  constant HSIZE_16WORD:  std_logic_vector(2 downto 0) := "110";
  constant HSIZE_32WORD:  std_logic_vector(2 downto 0) := "111";

  constant HRESP_OKAY:    std_logic_vector(1 downto 0) := "00";
  constant HRESP_ERROR:   std_logic_vector(1 downto 0) := "01";
  constant HRESP_RETRY:   std_logic_vector(1 downto 0) := "10";
  constant HRESP_SPLIT:   std_logic_vector(1 downto 0) := "11";

-- APB slave inputs
  type apb_slv_in_type is record
    psel	: std_logic_vector(0 to NAPBSLV-1);     -- slave select
    penable	: std_ulogic;                         	-- strobe
    paddr	: std_logic_vector(31 downto 0); 	-- address bus (byte)
    pwrite	: std_ulogic;                         	-- write
    pwdata	: std_logic_vector(31 downto 0); 	-- write data bus
    pirq	: std_logic_vector(NAHBIRQ-1 downto 0); -- interrupt result bus
    testen	: std_ulogic;                         	-- scan test enable
    testrst	: std_ulogic;                         	-- scan test reset
    scanen 	: std_ulogic;                         	-- scan enable
    testoen	: std_ulogic;                         	-- test output enable
  end record;

-- APB slave outputs
  type apb_slv_out_type is record
    prdata	: std_logic_vector(31 downto 0); 	-- read data bus
    pirq 	: std_logic_vector(NAHBIRQ-1 downto 0); -- interrupt bus
    pconfig 	: apb_config_type;	 		-- memory access reg.
    pindex      : integer range 0 to NAPBSLV -1;	-- diag use only
  end record;

-- array types
  type apb_slv_out_vector is array (0 to NAPBSLV-1) of apb_slv_out_type;

-- support for plug&play configuration

  constant AMBA_CONFIG_VER0  : std_logic_vector(1 downto 0) := "00";

  subtype amba_vendor_type  is integer range 0 to  16#ff#;
  subtype amba_device_type  is integer range 0 to 16#3ff#;
  subtype amba_version_type is integer range 0 to  16#3f#;
  subtype amba_cfgver_type  is integer range 0 to      3;
  subtype amba_irq_type     is integer range 0 to NAHBIRQ-1;
  subtype ahb_addr_type     is integer range 0 to 16#fff#;
  constant zx : std_logic_vector(31 downto 0) := (others => '0');
  constant zxirq : std_logic_vector(NAHBIRQ-1 downto 0) := (others => '0');
  constant zy : std_logic_vector(0 to 31) := (others => '0');

  constant apb_none : apb_slv_out_type :=
    (zx, zxirq(NAHBIRQ-1 downto 0), (others => zx), 0);
  constant ahbm_none : ahb_mst_out_type := ( '0', '0', "00", zx,
   '0', "000", "000", "0000", zx, zxirq(NAHBIRQ-1 downto 0), (others => zx), 0);
  constant ahbs_none : ahb_slv_out_type := (
   '1', "00", zx, zx(15 downto 0), '0', zxirq(NAHBIRQ-1 downto 0), (others => zx), 0);
  constant ahbs_in_none : ahb_slv_in_type := (
   zy(0 to NAHBSLV-1), zx, '0', "00", "000", "000", zx,
   "0000", '1', "0000", '0', zy(0 to NAHBAMR-1), '0', zxirq(NAHBIRQ-1 downto 0),
   '0', '0', '0', '0');

  constant ahbsv_none : ahb_slv_out_vector := (others => ahbs_none);

  function ahb_device_reg(vendor : amba_vendor_type; device : amba_device_type;
	cfgver : amba_cfgver_type; version : amba_version_type;
        interrupt : amba_irq_type)
  return std_logic_vector;

  function ahb_membar(memaddr : ahb_addr_type; prefetch, cache : std_ulogic;
	addrmask : ahb_addr_type)
  return std_logic_vector;

  function ahb_membar_opt(memaddr : ahb_addr_type; prefetch, cache : std_ulogic;
	addrmask : ahb_addr_type; enable : integer)
  return std_logic_vector;

  function ahb_iobar(memaddr : ahb_addr_type; addrmask : ahb_addr_type)
  return std_logic_vector;

  function apb_iobar(memaddr : ahb_addr_type; addrmask : ahb_addr_type)
  return std_logic_vector;

  function ahb_slv_dec_cache(haddr : std_logic_vector(31 downto 0);
                             ahbso : ahb_slv_out_vector; cached : integer)
  return std_ulogic;

  function ahb_slv_dec_pfetch(haddr : std_logic_vector(31 downto 0);
                             ahbso : ahb_slv_out_vector)
  return std_ulogic;


  component ahbctrl
  generic (
    defmast : integer := 0;		-- default master
    split   : integer := 0;		-- split support
    rrobin  : integer := 0;		-- round-robin arbitration
    timeout : integer range 0 to 255 := 0;  -- HREADY timeout
    ioaddr  : ahb_addr_type := 16#fff#;  -- I/O area MSB address
    iomask  : ahb_addr_type := 16#fff#;  -- I/O area address mask
    cfgaddr : ahb_addr_type := 16#ff0#;  -- config area MSB address
    cfgmask : ahb_addr_type := 16#ff0#;  -- config area address mask
    nahbm   : integer range 1 to NAHBMST := NAHBMST; -- number of masters
    nahbs   : integer range 1 to NAHBSLV := NAHBSLV; -- number of slaves
    ioen    : integer range 0 to 15 := 1; -- enable I/O area
    disirq  : integer range 0 to 1 := 0;  -- disable interrupt routing
    fixbrst : integer range 0 to 1 := 0;  -- support fix-length bursts
    debug   : integer range 0 to 2 := 2;  -- print config to console
    fpnpen  : integer range 0 to 1 := 0;  -- full PnP configuration decoding
    icheck  : integer range 0 to 1 := 1;
    devid   : integer := 0;		  -- unique device ID
    enbusmon    : integer range 0 to 1 := 0; --enable bus monitor
    assertwarn  : integer range 0 to 1 := 0; --enable assertions for warnings 
    asserterr   : integer range 0 to 1 := 0; --enable assertions for errors
    hmstdisable : integer := 0; --disable master checks           
    hslvdisable : integer := 0; --disable slave checks
    arbdisable  : integer := 0; --disable arbiter checks
    mprio       : integer := 0; --master with highest priority
    enebterm    : integer range 0 to 1 := 0  --enable early burst termination
  );
  port (
    rst     : in  std_ulogic;
    clk     : in  std_ulogic;
    msti    : out ahb_mst_in_type;
    msto    : in  ahb_mst_out_vector;
    slvi    : out ahb_slv_in_type;
    slvo    : in  ahb_slv_out_vector;
    testen  : in  std_ulogic := '0';
    testrst : in  std_ulogic := '1';
    scanen  : in  std_ulogic := '0';
    testoen : in  std_ulogic := '1'
  );
  end component;

  component apbctrl
  generic (
    hindex      : integer := 0;
    haddr       : integer := 0;
    hmask       : integer := 16#fff#;
    nslaves     : integer range 1 to NAPBSLV := NAPBSLV;
    debug       : integer range 0 to 2 := 2;   -- print config to console
    icheck      : integer range 0 to 1 := 1;
    enbusmon    : integer range 0 to 1 := 0;
    asserterr   : integer range 0 to 1 := 0;
    assertwarn  : integer range 0 to 1 := 0;
    pslvdisable : integer := 0
  );
  port (
    rst     : in  std_ulogic;
    clk     : in  std_ulogic;
    ahbi    : in  ahb_slv_in_type;
    ahbo    : out ahb_slv_out_type;
    apbi    : out apb_slv_in_type;
    apbo    : in  apb_slv_out_vector
  );
  end component;

  component ahbctrl_mb
  generic (
    defmast     : integer := 0;		-- default master
    split       : integer := 0;		-- split support
    rrobin      : integer := 0;		-- round-robin arbitration
    timeout     : integer range 0 to 255 := 0;  -- HREADY timeout
    ioaddr      : ahb_addr_type := 16#fff#;  -- I/O area MSB address
    iomask      : ahb_addr_type := 16#fff#;  -- I/O area address mask
    cfgaddr     : ahb_addr_type := 16#ff0#;  -- config area MSB address
    cfgmask     : ahb_addr_type := 16#ff0#;   -- config area address mask
    nahbm       : integer range 1 to NAHBMST := NAHBMST; -- number of masters
    nahbs       : integer range 1 to NAHBSLV := NAHBSLV; -- number of slaves
    ioen        : integer range 0 to 15 := 1;   -- enable I/O area
    disirq      : integer range 0 to 1 := 0;   -- disable interrupt routing
    fixbrst     : integer range 0 to 1 := 0;   -- support fix-length bursts
    debug       : integer range 0 to 2 := 2;   -- report cores to console
    fpnpen      : integer range 0 to 1 := 0;   -- full PnP configuration decoding
    busndx      : integer range 0 to 3 := 0;
    icheck      : integer range 0 to 1 := 1;    
    devid       : integer := 0;		   -- unique device ID
    enbusmon    : integer range 0 to 1 := 0; --enable bus monitor
    assertwarn  : integer range 0 to 1 := 0; --enable assertions for warnings 
    asserterr   : integer range 0 to 1 := 0; --enable assertions for errors
    hmstdisable : integer := 0; --disable master checks           
    hslvdisable : integer := 0; --disable slave checks
    arbdisable  : integer := 0; --disable arbiter checks
    mprio       : integer := 0; --master with highest priority
    enebterm    : integer range 0 to 1 := 0  --enable early burst termination
  );
  port (
    rst     : in  std_ulogic;
    clk     : in  std_ulogic;
    msti    : out ahb_mst_in_type;
    msto    : in  ahb_mst_out_bus_vector;
    slvi    : out ahb_slv_in_type;
    slvo    : in  ahb_slv_out_bus_vector;
    testen  : in  std_ulogic := '0';
    testrst : in  std_ulogic := '1';
    scanen  : in  std_ulogic := '0';
    testoen : in  std_ulogic := '1'
    );
  end component;
  
  component ahbdefmst
    generic ( hindex : integer range 0 to NAHBMST-1 := 0);
    port ( ahbmo  : out ahb_mst_out_type);
  end component;

-- pragma translate_off

  component ahbmon is
  generic(
    asserterr   : integer range 0 to 1 := 1;
    assertwarn  : integer range 0 to 1 := 1;
    hmstdisable : integer := 0;
    hslvdisable : integer := 0;
    arbdisable  : integer := 0;
    nahbm       : integer range 0 to NAHBMST := NAHBMST;
    nahbs       : integer range 0 to NAHBSLV := NAHBSLV
  );
  port(
    rst         : in std_ulogic;
    clk         : in std_ulogic;
    ahbmi       : in ahb_mst_in_type;
    ahbmo       : in ahb_mst_out_vector;
    ahbsi       : in ahb_slv_in_type;
    ahbso       : in ahb_slv_out_vector;
    err         : out std_ulogic);
  end component;

  component apbmon is
  generic(
    asserterr   : integer range 0 to 1 := 1;
    assertwarn  : integer range 0 to 1 := 1;
    pslvdisable : integer := 0;
    napb        : integer range 0 to NAPBSLV := NAPBSLV
  );
  port(
    rst         : in std_ulogic;
    clk         : in std_ulogic;
    apbi        : in apb_slv_in_type;
    apbo        : in apb_slv_out_vector;
    err         : out std_ulogic);
  end component;
  
  component ambamon is
    generic(
      asserterr   : integer range 0 to 1 := 1;
      assertwarn  : integer range 0 to 1 := 1;
      hmstdisable : integer := 0;
      hslvdisable : integer := 0;
      pslvdisable : integer := 0;
      arbdisable  : integer := 0;
      nahbm       : integer range 0 to NAHBMST := NAHBMST;
      nahbs       : integer range 0 to NAHBSLV := NAHBSLV;
      napb        : integer range 0 to NAPBSLV := NAPBSLV
    );
    port(
      rst        : in std_ulogic;
      clk        : in std_ulogic;
      ahbmi      : in ahb_mst_in_type;
      ahbmo      : in ahb_mst_out_vector;
      ahbsi      : in ahb_slv_in_type;
      ahbso      : in ahb_slv_out_vector;
      apbi       : in apb_slv_in_type;
      apbo       : in apb_slv_out_vector;
      err        : out std_ulogic);
  end component;
  
  subtype vendor_description is string(1 to 24);
  subtype device_description is string(1 to 31);
  type device_table_type is array (0 to 1023) of device_description;
  type vendor_library_type is record
    vendorid	 : amba_vendor_type;
    vendordesc   : vendor_description;
    device_table : device_table_type;
  end record;
  type device_array is array (0 to 255) of vendor_library_type;

-- pragma translate_on

end;

package body amba is

  function ahb_device_reg(vendor : amba_vendor_type; device : amba_device_type;
	cfgver : amba_cfgver_type; version : amba_version_type;
        interrupt : amba_irq_type)
  return std_logic_vector is
  variable cfg : std_logic_vector(31 downto 0);
  begin
    case cfgver is
    when 0 =>
      cfg(31 downto 24) := std_logic_vector(to_unsigned(vendor, 8));
      cfg(23 downto 12) := std_logic_vector(to_unsigned(device, 12));
      cfg(11 downto 10) := std_logic_vector(to_unsigned(cfgver, 2));
      cfg( 9 downto  5) := std_logic_vector(to_unsigned(version, 5));
      cfg( 4 downto  0) := std_logic_vector(to_unsigned(interrupt, 5));
    when others => cfg := (others => '0');
    end case;
    return(cfg);
  end;

  function ahb_membar(memaddr : ahb_addr_type; prefetch, cache : std_ulogic;
	addrmask : ahb_addr_type)
  return std_logic_vector is
  variable cfg : std_logic_vector(31 downto 0);
  begin
    cfg(31 downto 20) := std_logic_vector(to_unsigned(memaddr, 12));
    cfg(19 downto 16) := "00" & prefetch & cache;
    cfg(15 downto  4) := std_logic_vector(to_unsigned(addrmask, 12));
    cfg( 3 downto  0) := "0010";
    return(cfg);
  end;

  function ahb_membar_opt(memaddr : ahb_addr_type; prefetch, cache : std_ulogic;
	addrmask : ahb_addr_type; enable : integer)
  return std_logic_vector is
  variable cfg : std_logic_vector(31 downto 0);
  begin
    cfg := (others => '0');
    if enable /= 0 then
      return (ahb_membar(memaddr, prefetch, cache, addrmask));
    else return(cfg); end if;
  end;

  function ahb_iobar(memaddr : ahb_addr_type; addrmask : ahb_addr_type)
  return std_logic_vector is
  variable cfg : std_logic_vector(31 downto 0);
  begin
    cfg(31 downto 20) := std_logic_vector(to_unsigned(memaddr, 12));
    cfg(19 downto 16) := "0000";
    cfg(15 downto  4) := std_logic_vector(to_unsigned(addrmask, 12));
    cfg( 3 downto  0) := "0011";
    return(cfg);
  end;

  function apb_iobar(memaddr : ahb_addr_type; addrmask : ahb_addr_type)
  return std_logic_vector is
  variable cfg : std_logic_vector(31 downto 0);
  begin
    cfg(31 downto 20) := std_logic_vector(to_unsigned(memaddr, 12));
    cfg(19 downto 16) := "0000";
    cfg(15 downto  4) := std_logic_vector(to_unsigned(addrmask, 12));
    cfg( 3 downto  0) := "0001";
    return(cfg);
  end;

  function ahb_slv_dec_cache(haddr : std_logic_vector(31 downto 0);
                             ahbso : ahb_slv_out_vector; cached : integer)
  return std_ulogic is
    variable hcache : std_ulogic;
    variable ctbl : std_logic_vector(15 downto 0);
  begin
    hcache := '0'; ctbl := (others => '0');
    if cached = 0 then
      for i in 0 to NAHBSLV-1 loop
        for j in NAHBAMR to NAHBCFG-1 loop
          if (ahbso(i).hconfig(j)(16) = '1') and 
		(ahbso(i).hconfig(j)(15 downto 4) /= "000000000000")
	  then
            if (haddr(31 downto 20) and ahbso(i).hconfig(j)(15 downto 4)) =
              (ahbso(i).hconfig(j)(31 downto 20) and ahbso(i).hconfig(j)(15 downto 4)) then
              hcache := '1';
            end if;
          end if;
        end loop;
      end loop;
    else
      ctbl := conv_std_logic_vector(cached, 16);
      hcache := ctbl(conv_integer(haddr(31 downto 28)));
    end if;
    return(hcache);
  end;

  function ahb_slv_dec_pfetch(haddr : std_logic_vector(31 downto 0);
                             ahbso : ahb_slv_out_vector)
  return std_ulogic is
    variable pfetch : std_ulogic;
  begin
    pfetch := '0';
    for i in 0 to NAHBSLV-1 loop
      for j in NAHBAMR to NAHBCFG-1 loop
        if ahbso(i).hconfig(j)(17) = '1' then
          if (haddr(31 downto 20) and ahbso(i).hconfig(j)(15 downto 4)) =
            (ahbso(i).hconfig(j)(31 downto 20) and ahbso(i).hconfig(j)(15 downto 4)) then
            pfetch := '1';
          end if;
        end if;
      end loop;
    end loop;
    return(pfetch);
  end;

end;
