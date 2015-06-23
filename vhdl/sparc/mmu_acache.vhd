----------------------------------------------------------------------------
--  This file is a part of the LEON VHDL model
--  Copyright (C) 2003  Gaisler Research
--
--  This library is free software; you can redistribute it and/or
--  modify it under the terms of the GNU Lesser General Public
--  License as published by the Free Software Foundation; either
--  version 2 of the License, or (at your option) any later version.
--
--  See the file COPYING.LGPL for the full details of the license.


-----------------------------------------------------------------------------   
-- Entity:      mmu_acache
-- File:        mmu_acache.vhd
-- Author:      Jiri Gaisler - Gaisler Research, Konrad Eisele <eiselekd@web.de>
-- Description: Interface module between I/D cache controllers and Amba AHB
------------------------------------------------------------------------------  


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned."+";
use IEEE.std_logic_arith.conv_unsigned;
use work.leon_target.all;
use work.leon_config.all;
use work.leon_iface.all;
use work.amba.all;
use work.macro.all;

 
entity mmu_acache is
  port (
    rst    : in  std_logic;
    clk    : in  clk_type;
    mcii   : in  memory_ic_in_type;
    mcio   : out memory_ic_out_type;
    mcdi   : in  memory_dc_in_type;
    mcdo   : out memory_dc_out_type;
    mcmmi  : in  memory_mm_in_type;
    mcmmo  : out memory_mm_out_type;
    iuo    : in  iu_out_type;
    apbi   : in  apb_slv_in_type;
    apbo   : out apb_slv_out_type;
    ahbi   : in  ahb_mst_in_type;
    ahbo   : out ahb_mst_out_type
  );
end;

architecture rtl of mmu_acache is

-- cache control register type

type cctrltype is record
  ib     : std_logic;				-- icache burst enable
  dfrz   : std_logic;				-- dcache freeze enable
  ifrz   : std_logic;				-- icache freeze enable
  dsnoop : std_logic;				-- data cache snooping
  dcs    : std_logic_vector(1 downto 0);	-- dcache state
  ics    : std_logic_vector(1 downto 0);	-- icache state
end record;

type astates is (idle, dcache, icache, mmu);
type reg_type is record
  bg     : std_logic; 	-- bus grant
  bo     : std_logic_vector(1 downto 0); 	-- bus owner
  ba     : std_logic;	-- bus active
  retry  : std_logic;	-- retry/split pending
  werr   : std_logic;	-- write error
  cctrl	 : cctrltype;
  pwd    : std_logic;	-- power-down
  hcache : std_logic;	-- cacheable access
  astate : astates;
end record;

signal r, rin : reg_type;
begin

  comb : process(ahbi, r, rst, mcii, mcdi, mcmmi, iuo, apbi)

  variable v : reg_type;
  variable haddr   : std_logic_vector(31 downto 0);   -- address bus
  variable htrans  : std_logic_vector(1 downto 0);    -- transfer type 
  variable hwrite  : std_logic;  		      -- read/write
  variable hlock   : std_logic;  		      -- bus lock
  variable hsize   : std_logic_vector(2 downto 0);    -- transfer size
  variable hburst  : std_logic_vector(2 downto 0);    -- burst type
  variable hwdata  : std_logic_vector(31 downto 0);   -- write data
  variable hbusreq : std_logic;   -- bus request
  variable iflush, dflush, mmflush : std_logic;   
  variable iready, dready, mmready : std_logic;   
  variable igrant, dgrant, mmgrant : std_logic;   
  variable iretry, dretry, mmretry : std_logic;   
  variable ihcache, dhcache, mmhcache, hcache : std_logic;   
  variable imexc, dmexc, mmmexc : std_logic;
  variable dreq : std_logic;
  variable nbo : std_logic_vector(1 downto 0);
  variable su : std_logic;   
  variable cctrl   : std_logic_vector(31 downto 0);

  begin

    -- initialisation

    htrans := HTRANS_IDLE;
    v := r;  v.werr := '0';
    iready := '0'; dready := '0'; mmready := '0';
    igrant := '0'; dgrant := '0'; mmgrant := '0'; 
    imexc := '0'; dmexc := '0'; mmmexc := '0'; hlock := '0';
    iretry := '0'; dretry := '0'; mmretry := '0';
    ihcache := '0'; dhcache := '0'; mmhcache := '0';
    iflush := '0'; dflush := '0'; mmflush := '0'; su := '0';

    haddr := (others => '0');
    hwrite := '0';
    hsize := (others => '0');
    hlock := '0'; 
    hburst := (others => '0'); 
    
    -- generate AHB signals

    dreq := mcdi.req and not r.pwd;
    hwdata := mcdi.data;
    hbusreq := '0';

    if (mcii.req = '1') and
      not (( ((r.ba and dreq) = '1') and (r.bo = "01")) or
           ( ((r.ba and mcmmi.req) = '1') and (r.bo = "10"))) then
      nbo := "00";
      hbusreq := '1';
      htrans := HTRANS_NONSEQ;
    elsif (dreq = '1') and
      not (( ((r.ba and mcii.req) = '1') and (r.bo = "00")) or
           ( ((r.ba and mcmmi.req) = '1') and (r.bo = "10"))) then
      nbo := "01";
      hbusreq := '1';
      htrans := HTRANS_NONSEQ;
    elsif (mcmmi.req = '1') and
      not (( ((r.ba and mcii.req) = '1') and (r.bo = "00")) or
           ( ((r.ba and dreq) = '1') and (r.bo = "01"))) then
      nbo := "10";
      hbusreq := '1';
      htrans := HTRANS_NONSEQ;
    else
      nbo := "11";
    end if;
    
    if nbo = "10" then
      haddr := mcmmi.address; hwrite := not mcmmi.read; hsize := '0' & mcmmi.size;
      hlock := mcmmi.lock;
--      if mcmmi.burst = '1' then hburst := HBURST_INCR; 
--      else hburst := HBURST_SINGLE; end if;
--      if ((mcmmi.req and r.ba) = '1')  and (r.bo = "10") and ((not r.retry) = '1') then 
--        htrans := HTRANS_SEQ; haddr(4 downto 2) := haddr(4 downto 2) +1;
--        hburst := HBURST_INCR; 
--      end if;
      htrans := HTRANS_NONSEQ; hburst := HBURST_SINGLE; 
      if (mcmmi.req and r.bg and ahbi.hready and not r.retry) = '1' 
      then mmgrant := '1'; end if; 
    elsif nbo = "00" then
      haddr := mcii.address; hwrite := '0'; hsize := HSIZE_WORD; hlock := '0';
      su := mcii.su;
      if mcii.burst = '1' then hburst := HBURST_INCR; 
      else hburst := HBURST_SINGLE; end if;
      if ((mcii.req and r.ba) = '1')  and (r.bo = "00") and ((not r.retry) = '1') then
        htrans := HTRANS_SEQ; haddr(4 downto 2) := haddr(4 downto 2) +1;
        hburst := HBURST_INCR; 
      end if;
      if (mcii.req and r.bg and ahbi.hready and not r.retry) = '1' 
      then igrant := '1'; end if; 
    elsif nbo = "01" then
      haddr := mcdi.address; hwrite := not mcdi.read; hsize := '0' & mcdi.size;
      hlock := mcdi.lock; 
      if mcdi.asi /= "1010" then su := '1'; else su := '0'; end if;  --ASI_UDATA
      if mcdi.burst = '1' then hburst := HBURST_INCR; 
      else hburst := HBURST_SINGLE; end if;
      if ((dreq and r.ba) = '1') and (r.bo = "01") and ((not r.retry) = '1') then 
        htrans := HTRANS_SEQ; haddr(4 downto 2) := haddr(4 downto 2) +1;
        hburst := HBURST_INCR; 
      end if;
      if (dreq and r.bg and ahbi.hready and not r.retry) = '1' 
      then dgrant := '1'; end if;
    end if;
    
    if mcii.req = '0' then hlock := mcdi.lock; end if;

    if (r.ba = '1') and 
       ((ahbi.hresp = HRESP_RETRY) or (ahbi.hresp = HRESP_SPLIT))
    then v.retry := not ahbi.hready; else v.retry := '0'; end if;
      
    if r.retry = '1' then htrans := HTRANS_IDLE; end if;

    if r.bo = "10" then
      hwdata := mcmmi.data;
      if r.ba = '1' then
        mmhcache := r.hcache;
        if ahbi.hready = '1' then
	  case ahbi.hresp is
	  when HRESP_OKAY => mmready := '1'; 
	  when HRESP_RETRY | HRESP_SPLIT=> mmretry := '1'; 
	  when others => mmready := '1'; mmmexc := '1'; v.werr := not mcmmi.read;
	  end case;
        end if;
      end if;
    elsif r.bo = "00" then
      if r.ba = '1' then
        ihcache := r.hcache;
        if ahbi.hready = '1' then
	  case ahbi.hresp is
	  when HRESP_OKAY => iready := '1'; 
	  when HRESP_RETRY | HRESP_SPLIT=> iretry := '1'; 
	  when others => iready := '1'; imexc := '1';
	  end case;
        end if;
      end if;
    elsif r.bo = "01" then
      --hwdata := mcdi.data;
      if r.ba = '1' then
	dhcache := r.hcache;
        if ahbi.hready = '1' then
	  case ahbi.hresp is
	  when HRESP_OKAY => dready := '1'; 
	  when HRESP_RETRY | HRESP_SPLIT=> dretry := '1'; 
	  when others => dready := '1'; dmexc := '1'; v.werr := not mcdi.read;
	  end case;
        end if;
      end if;
      hlock := mcdi.lock;
    end if;

    -- decode cacheability

    hcache := is_cacheable(haddr(31 downto 24));

    if nbo = "01" and ((hsize = "011") or ((hcache and mcdi.read) = '1')) then 
      hsize := "010";
    end if;

    if ahbi.hready = '1' then
      v.hcache := hcache; v.bo := nbo; v.bg := ahbi.hgrant;
      if (htrans = HTRANS_NONSEQ) or (htrans = HTRANS_SEQ) then
	v.ba := r.bg;
      else v.ba := '0'; end if;
    end if;

    -- cache freeze operation
    
    if (r.cctrl.ifrz and iuo.intack and r.cctrl.ics(0)) = '1' then
      v.cctrl.ics := "01";
    end if;
    if (r.cctrl.dfrz and iuo.intack and r.cctrl.dcs(0)) = '1' then
      v.cctrl.dcs := "01";
    end if;

    if (apbi.psel and apbi.penable and apbi.pwrite) = '1' then
      case apbi.paddr(2 downto 2) is
      when "1" =>

        v.cctrl.dsnoop := apbi.pwdata(23);
        dflush       := apbi.pwdata(22);
        iflush       := apbi.pwdata(21);
        v.cctrl.ib   := apbi.pwdata(16);
        v.cctrl.dfrz := apbi.pwdata(5);
        v.cctrl.ifrz := apbi.pwdata(4);
        v.cctrl.dcs  := apbi.pwdata(3 downto 2);
        v.cctrl.ics  := apbi.pwdata(1 downto 0);
      when others =>
	v.pwd := '1';
      end case;
    end if;

    cctrl := (others => '0');

    if DSNOOP then cctrl(23) := r.cctrl.dsnoop; end if;
    cctrl(16 downto 14) := r.cctrl.ib & mcii.flush  &  mcdi.flush; 
    cctrl(5 downto 0)   := r.cctrl.dfrz & r.cctrl.ifrz & r.cctrl.dcs & r.cctrl.ics;
    cctrl(25 downto 24) := std_logic_vector(conv_unsigned(DSETS-1,2));
    cctrl(27 downto 26) := std_logic_vector(conv_unsigned(ISETS-1,2));
    if ISETS /= 1 then
      if ICREPLACE = rnd then cctrl(29 downto 28) := "01"; end if;
      if ICREPLACE = lrr then cctrl(29 downto 28) := "10"; end if;
      if ICREPLACE = lru then cctrl(29 downto 28) := "11"; end if;
    end if;
    if DSETS /= 1 then
      if DCREPLACE = rnd then cctrl(31 downto 30) := "01"; end if;
      if DCREPLACE = lrr then cctrl(31 downto 30) := "10"; end if;
      if DCREPLACE = lru then cctrl(31 downto 30) := "11"; end if;
    end if;

  
    -- exit power-down in DSU debug mode
    
    if DEBUG_UNIT then 
      v.pwd := v.pwd and (not iuo.ipend) and not iuo.debug.dbreak;
    else v.pwd := v.pwd and not iuo.ipend; end if;


    -- reset operation

    if rst = '0' then
      v.bg := '0'; v.bo := "00"; v.ba := '0'; v.retry := '0'; v.werr := '0';
      v.cctrl.dcs := "00"; v.cctrl.ics := "00"; v.hcache := '0';
      v.cctrl.ib := '0'; v.pwd := '0'; v.cctrl.dsnoop := '0';
      v.astate := idle;
    end if;

    -- drive ports
    
    ahbo.haddr   <= haddr ;
    ahbo.htrans  <= htrans;
    ahbo.hbusreq <= hbusreq;
    ahbo.hwdata  <= hwdata;
    ahbo.hlock   <= hlock;
    ahbo.hwrite  <= hwrite;
    ahbo.hsize   <= hsize;
    ahbo.hburst  <= hburst;

    if nbo = "00" then ahbo.hprot   <= hcache & hcache & su & '0';
    else ahbo.hprot   <= hcache & hcache & su & '1'; end if;
    mcio.grant   <= igrant;
    mcio.ready   <= iready;
    mcio.mexc    <= imexc;
    mcio.retry   <= iretry;
    mcio.cache   <= ihcache;
    mcdo.grant   <= dgrant;
    mcdo.ready   <= dready;
    mcdo.mexc    <= dmexc;
    mcdo.retry   <= dretry;
    mcdo.werr    <= r.werr;
    mcdo.cache   <= dhcache;
    mcdo.iflush  <= iflush;
    mcdo.dflush  <= dflush;
    mcdo.ba      <= r.ba;
    mcdo.bg      <= r.bg;
    mcdo.dsnoop  <= r.cctrl.dsnoop;
    apbo.prdata  <= cctrl;

    mcmmo.grant   <= mmgrant;
    mcmmo.ready   <= mmready;
    mcmmo.mexc    <= mmmexc;
    mcmmo.retry   <= mmretry;
    mcmmo.werr    <= r.werr;
    mcmmo.cache   <= mmhcache;
 
    rin <= v;

  end process;

  mcio.data  <= ahbi.hrdata;
  mcdo.data  <= ahbi.hrdata;
  mcmmo.data <= ahbi.hrdata;

  mcio.ics <= r.cctrl.ics; mcdo.dcs <= r.cctrl.dcs;
  mcio.burst <= r.cctrl.ib;

  reg : process(clk)
  begin if rising_edge(clk) then r <= rin; end if; end process;


end;














