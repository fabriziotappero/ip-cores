



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
-- Entity:      ahbarb
-- File:        ahbarb.vhd
-- Author:      Jiri Gaisler - Gaisler Research
-- Description: AMBA AHB arbiter and decoder
------------------------------------------------------------------------------ 

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use work.leon_target.all;
use work.leon_config.all;
use work.leon_iface.all;
use work.amba.all;


entity ahbarb is
  generic (
    masters : integer := 2;		-- number of masters
    defmast : integer := 0 		-- default master
  );
  port (
    rst     : in  std_logic;
    clk     : in  clk_type;
    msti    : out ahb_mst_in_vector(0 to masters-1);
    msto    : in  ahb_mst_out_vector(0 to masters-1);
    slvi    : out ahb_slv_in_vector(0 to AHB_SLV_MAX-1);
    slvo    : in  ahb_slv_out_vector(0 to AHB_SLV_MAX)
  );
end;

architecture rtl of ahbarb is

type reg_type is record
  hmaster   : integer range 0 to masters-1;
  hmasterd  : integer range 0 to masters-1;
  hslave    : integer range 0 to AHB_SLV_MAX;
  hready    : std_logic;	-- needed for two-cycle error response
  hlock     : std_logic;
  hmasterlock : std_logic;
  htrans  : std_logic_vector(1 downto 0);    -- transfer type 
end record;

constant ahbmin : integer := AHB_SLV_ADDR_MSB-1;
type nmstarr is array ( 1 to 5) of integer range 0 to masters-1;
type nvalarr is array ( 1 to 5) of boolean;
signal r, rin : reg_type;
signal rsplit, rsplitin : std_logic_vector(masters-1 downto 0);

begin

  comb : process(rst, msto, slvo, r, rsplit)
  variable rv : reg_type;
  variable nhmaster, hmaster : integer range 0 to masters -1;
  variable haddr   : std_logic_vector(31 downto 0);   -- address bus
  variable hrdata  : std_logic_vector(31 downto 0);   -- read data bus
  variable htrans  : std_logic_vector(1 downto 0);    -- transfer type 
  variable hresp   : std_logic_vector(1 downto 0);    -- respons type 
  variable hwrite  : std_logic;  		     -- read/write
  variable hsize   : std_logic_vector(2 downto 0);    -- transfer size
  variable hprot   : std_logic_vector(3 downto 0);    -- protection info
  variable hburst  : std_logic_vector(2 downto 0);    -- burst type
  variable hwdata  : std_logic_vector(31 downto 0);   -- write data
  variable hgrant  : std_logic_vector(0 to masters-1);   -- bus grant
  variable hsel    : std_logic_vector(0 to AHB_SLV_MAX);   -- slave select
  variable hready  : std_logic;  		     -- ready
  variable hmastlock  : std_logic;  		
  variable nslave : natural range 0 to AHB_SLV_MAX;
  variable ahbaddr : std_logic_vector(ahbmin downto 0);
  variable vsplit  : std_logic_vector(masters-1 downto 0);
  variable nmst    : nmstarr;
  variable nvalid  : nvalarr;
  variable htmp    : std_logic_vector(3 downto 0); 
  begin

    rv := r; rv.hready := '0'; 

    -- bus multiplexers

    haddr     := msto(r.hmaster).haddr;
    htrans    := msto(r.hmaster).htrans;
    hwrite    := msto(r.hmaster).hwrite;
    hsize     := msto(r.hmaster).hsize;
    hprot     := msto(r.hmaster).hprot;
    hburst    := msto(r.hmaster).hburst;
    hmastlock := msto(r.hmaster).hlock;
    hwdata    := msto(r.hmasterd).hwdata;
    hready    := slvo(r.hslave).hready;
    hrdata    := slvo(r.hslave).hrdata;
    hresp     := slvo(r.hslave).hresp ;

    if r.hslave = AHB_SLV_MAX then
      -- default slave
      if (r.htrans = HTRANS_IDLE) or (r.htrans = HTRANS_BUSY) then
        hresp := HRESP_OKAY; hready := '1';
      else
	-- return two-cycle error in case of unimplemented slave access
        hresp := HRESP_ERROR; hready := r.hready; rv.hready := not r.hready;
      end if;
    end if;


-- Find next master:
--   * priority is fixed, highest index has highest priority
--   * splitted masters are not granted
--   * burst transfers cannot be interrupted
--   * low-priority masters will be granted if they drive SEQ or NONSEQ
--     on HTRANS, and high-priority masters only drive IDLE

    nvalid(1 to 4) := (others => false); nvalid(5) := true;
    nmst(1 to 4) := (others => 0); nmst(5) := defmast; nhmaster := r.hmaster; 

    if (r.hmasterlock = '0') and (
       (msto(r.hmaster).htrans = HTRANS_IDLE) or
       ( (msto(r.hmaster).htrans = HTRANS_NONSEQ) and
         (msto(r.hmaster).hburst = HBURST_SINGLE) ) ) then
      for i in 0 to (masters -1) loop
	if ((rsplit(i) = '0') or not AHB_SPLIT) then
          if (msto(i).hbusreq = '1') and (msto(i).htrans(1) = '1') then
	    nmst(2) := i; nvalid(2) := true;
	  end if;
          if (msto(i).hbusreq = '1') then
	    nmst(3) := i; nvalid(3) := true;
	  end if;
	  if not ((nmst(4) = defmast) and nvalid(4)) then 
	    nmst(4) := i; nvalid(4) := true; 
	  end if;
	end if;
      end loop;
      for i in 1 to 5 loop
        if nvalid(i) then nhmaster := nmst(i); exit; end if;
      end loop;
    end if;

    rv.hlock := msto(nhmaster).hlock;

    hgrant := (others => '0'); hgrant(nhmaster) := '1';

-- select slave
    ahbaddr := haddr(31 downto (31 - ahbmin));
-- pragma translate_off
    if not is_x(haddr(31 downto (31 - AHB_SLV_ADDR_MSB +1))) then
-- pragma translate_on
      nslave :=  AHBSLVADDR(conv_integer(unsigned(haddr(31 downto (31 - AHB_SLV_ADDR_MSB +1)))));
-- pragma translate_off
    end if;
-- pragma translate_on

--    if htrans = HTRANS_IDLE then nslave := AHB_SLV_MAX; end if;

    hsel := (others => '0'); hsel(nslave) := '1'; 

    -- latch active master and slave
    if hready = '1' then 
      rv.hmaster := nhmaster; rv.hmasterd := r.hmaster; 
      rv.hslave := nslave; rv.htrans := htrans; rv.hmasterlock := r.hlock;
    end if;

-- latch HLOCK

    -- split support
    
    vsplit := (others => '0');
    if AHB_SPLIT then
      vsplit := rsplit;
      if hresp = HRESP_SPLIT then vsplit(r.hmasterd) := '1'; end if;
      for i in AHBSLVSPLIT'range loop --'
	if AHBSLVSPLIT(i) = 1 then
	  vsplit := vsplit and not slvo(i).hsplit(masters-1 downto 0);
	end if;
      end loop;
    end if;

    -- reset operation
    if (rst = '0') then
      rv.hmaster := 0; rv.hmasterlock := '0'; rv.hslave := AHB_SLV_MAX;
      hsel := (others => '0'); rv.htrans := HTRANS_IDLE;
      hready := '1'; vsplit := (others => '0');
    end if;
    
    -- drive master inputs
    for i in 0 to (masters -1) loop
      msti(i).hgrant  <= hgrant(i);
      msti(i).hready  <= hready;
      msti(i).hrdata  <= hrdata;
      msti(i).hresp   <= hresp;
    end loop;

    -- drive slave inputs
    for i in 0 to (AHB_SLV_MAX-1) loop
      slvi(i).haddr   <= haddr;
      slvi(i).htrans  <= htrans;
      slvi(i).hwrite  <= hwrite;
      slvi(i).hsize   <= hsize;
      slvi(i).hburst  <= hburst;
      slvi(i).hready  <= hready;
      slvi(i).hwdata  <= hwdata;
      slvi(i).hprot   <= hprot;
      slvi(i).hsel    <= hsel(i);
      slvi(i).hmaster <=  std_logic_vector(conv_unsigned(r.hmaster, 4));
      slvi(i).hmastlock <= r.hmasterlock;
    end loop;

    -- assign register inputs
    
    rin <= rv;
    rsplitin <= vsplit;

  end process;


  reg0 : process(clk)
  begin if rising_edge(clk) then r <= rin; end if; end process;

  splitreg : if AHB_SPLIT generate
    reg1 : process(clk)
    begin if rising_edge(clk) then rsplit <= rsplitin; end if; end process;
  end generate;


end;

