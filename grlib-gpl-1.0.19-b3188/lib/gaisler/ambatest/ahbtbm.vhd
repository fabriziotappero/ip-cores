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
-- Entity:      ahbtbm
-- File:        ahbtbm.vhd
-- Author:      Nils-Johan Wessman - Gaisler Research
-- Description: AHB Testbench master 
------------------------------------------------------------------------------  

library IEEE;
use IEEE.std_logic_1164.all;
library grlib;
use grlib.amba.all;
use grlib.stdlib.all;
use grlib.devices.all;
library gaisler;
use gaisler.misc.all;

use work.ahbtbp.all;

entity ahbtbm is
  generic (
    hindex  : integer := 0;
    hirq    : integer := 0;
    venid   : integer := VENDOR_GAISLER;
    devid   : integer := 0;
    version : integer := 0;
    chprot  : integer := 3;
    incaddr : integer := 0); 
  port (
    rst   : in  std_ulogic;
    clk   : in  std_ulogic;
    ctrli : in  ahbtbm_ctrl_in_type;
    ctrlo : out ahbtbm_ctrl_out_type;
    ahbmi : in  ahb_mst_in_type;
    ahbmo : out ahb_mst_out_type 
    );
end;      

architecture rtl of ahbtbm is

constant hconfig : ahb_config_type := (
  0 => ahb_device_reg ( venid, devid, 0, version, 0),
  others => zero32);

type reg_type is record
  -- new /*
  grant     : std_logic;
  grant2    : std_logic;
  retry     : std_logic_vector(1 downto 0);
  read      : std_logic; -- indicate 

  dbgl      : integer;
  ac        : ahbtbm_access_array_type;
  retryac   : ahbtbm_access_type;
  curac     : ahbtbm_access_type;
  haddr     : std_logic_vector(31 downto 0); -- addr current access
  hdata     : std_logic_vector(31 downto 0); -- data currnet access
  hwrite    : std_logic;                     -- write current access
  hrdata    : std_logic_vector(31 downto 0);
  status    : ahbtbm_status_type;
  dvalid    : std_logic;
  oldhtrans : std_logic_vector(1 downto 0);

  -- new */
  start   : std_ulogic;
  active  : std_ulogic;
end record;


signal dmai : ahb_dma_in_type;
signal dmao : ahb_dma_out_type;

signal r, rin : reg_type;

begin

  ctrlo.rst <= rst;
  ctrlo.clk <= clk;

  comb : process(ahbmi, ctrli, rst, r)
  -- new /*
  variable v       : reg_type;
  variable update  : std_logic;
  variable hbusreq : std_ulogic;   -- bus request
  variable kblimit : std_logic; -- 1 kB limit indicator
  -- new */
  variable ready   : std_ulogic;
  variable retry   : std_ulogic;
  variable mexc    : std_ulogic;
  variable inc     : std_logic_vector(3 downto 0);    -- address increment

  variable haddr   : std_logic_vector(31 downto 0);   -- AHB address
  variable hwdata  : std_logic_vector(31 downto 0);   -- AHB write data
  variable htrans  : std_logic_vector(1 downto 0);    -- transfer type
  variable hwrite  : std_ulogic;  		      -- read/write
  variable hburst  : std_logic_vector(2 downto 0);    -- burst type
  variable newaddr : std_logic_vector(10 downto 0); -- next sequential address
  variable hprot   : std_logic_vector(3 downto 0);    -- transfer type
  variable xhirq    : std_logic_vector(NAHBIRQ-1 downto 0);
  begin
    
    -- new /*
    v := r; update := '0'; hbusreq := '0';--v.retry := '0';
    v.dvalid := '0'; xhirq := (others => '0');
    
    v.hrdata := ahbmi.hrdata;
    -- pragma translate_off
    if ahbmi.hready = '1' and ahbmi.hresp = HRESP_ERROR then
      v.hrdata := (others => 'X');
    end if;
    -- pragma translate_on

    v.status.err := '0';
    --v.oldhtrans := r.ac(1).htrans;
    kblimit := '0';

    -- Sample grant when hready
    if ahbmi.hready = '1' then
      v.grant := ahbmi.hgrant(hindex);
      v.grant2 := r.grant;
      v.oldhtrans := r.ac(1).htrans;
    end if;
      
    -- 1k limit
    if (r.ac(0).htrans = HTRANS_SEQ 
        and (r.ac(0).haddr(10) xor r.ac(1).haddr(10)) = '1')
       or (r.retryac.htrans = HTRANS_SEQ 
        and (r.retryac.haddr(10) xor r.ac(1).haddr(10)) = '1' and r.retry = "10") then
      kblimit := '1';        
    end if;

    -- Read in new access
    --if ((ahbmi.hready = '1' and ahbmi.hresp = HRESP_OKAY and r.grant = '1') 
    --  or r.ac(1).htrans = HTRANS_IDLE) and r.retry = '0' then
    --if ahbmi.hready = '1' and ((ahbmi.hresp = HRESP_OKAY and r.grant = '1') 
    --   or r.ac(1).htrans = HTRANS_IDLE) and r.retry = "00" then
    if ahbmi.hready = '1' and (( r.grant = '1' and 
       (ahbmi.hresp = HRESP_OKAY or ahbmi.hresp = HRESP_ERROR)) 
       or r.ac(1).htrans = HTRANS_IDLE) and r.retry = "00" then
        v.ac(1) := r.ac(0); v.ac(0) := ctrli.ac;
        
        v.curac := r.ac(1);
        v.hdata := r.ac(1).hdata; v.haddr := r.ac(1).haddr; 
        v.hwrite := r.ac(1).hwrite; v.dbgl := r.ac(1).ctrl.dbgl;
        
        v.read := (not r.ac(1).hwrite) and r.ac(1).htrans(1);
        update := '1';
        
        if kblimit = '1' then v.ac(1).htrans := HTRANS_NONSEQ; end if;

    elsif ahbmi.hready = '0' and ahbmi.hresp = HRESP_RETRY and r.grant2 = '1' then 
      if r.retry = "00" then
        v.retryac := r.ac(1);
        v.ac(1) := r.curac;
        v.ac(1).htrans := HTRANS_IDLE;
        v.ac(1).hburst := "000";
        v.retry := "01";
      elsif r.retry = "10" then
        v.ac(1) := r.retryac;
        if kblimit = '1' then v.ac(1).htrans := HTRANS_NONSEQ; end if;
      end if;
    elsif r.retry = "01" then
      v.ac(1).htrans := HTRANS_NONSEQ;
      v.ac(1).hburst := r.curac.hburst;
      v.read := '0';
      v.retry := "10";
    elsif ahbmi.hready = '1' and r.grant = '1' and r.retry = "10" then
      v.read := (not r.ac(1).hwrite) and r.ac(1).htrans(1);
      --if ahbmi.hresp = HRESP_OKAY then
      if ahbmi.hresp = HRESP_OKAY or ahbmi.hresp = HRESP_ERROR then
        v.ac(1) := r.retryac;
        if kblimit = '1' then v.ac(1).htrans := HTRANS_NONSEQ; end if;
        v.retry := "00";
      end if;
    end if;
   
    -- NONSEQ in retry
    --if r.retry = '1' then v.ac(1).htrans := HTRANS_NONSEQ; end if;
  
    -- NONSEQ if burst is interrupted
    if r.grant = '0' and r.ac(1).htrans = HTRANS_SEQ then
      v.ac(1).htrans := HTRANS_NONSEQ;
    end if;

    --if r.ac(1).htrans /= HTRANS_IDLE or r.ac(0).htrans /= HTRANS_IDLE then
    --  hbusreq := '1';
    --end if;
    if r.ac(1).htrans = HTRANS_NONSEQ 
      or (r.ac(1).htrans = HTRANS_SEQ 
          and r.ac(0).htrans /= HTRANS_NONSEQ and kblimit = '0') then
      hbusreq := '1';
    end if;

    --if r.grant = '0' then -- fix dvalid if grant deasserted *** ???
    if r.grant = '0' and ahbmi.hready = '1' then
      v.read := '0';
    end if;

    -- Check read data
    if r.read = '1' and ahbmi.hresp = HRESP_OKAY and ahbmi.hready = '1' then
      v.dvalid := '1';
      if r.hdata /= ahbmi.hrdata then
        v.status.err := '1';
      end if;
    elsif r.read = '1' and ahbmi.hresp = HRESP_ERROR and ahbmi.hready = '1' then
      v.status.err := '1';
    end if;

    -- new */


    if rst = '0' then 
      v.ac(0).htrans := (others => '0');
      v.ac(1).htrans := (others => '0');
      v.retry := (others => '0');
      v.read := '0';
      
      v.ac(1).haddr := (others => '0');
      v.ac(1).htrans := (others => '0');
      v.ac(1).hwrite := '0';
      v.ac(1).hsize := (others => '0');
      v.ac(1).hburst := (others =>'0');
    end if;

    rin <= v;

    ctrlo.update <= update;
    ctrlo.status <= r.status;
    ctrlo.hrdata <= r.hrdata;
    ctrlo.dvalid <= r.dvalid;

    ahbmo.haddr   <= r.ac(1).haddr;
    ahbmo.htrans  <= r.ac(1).htrans;
    ahbmo.hbusreq <= hbusreq;
    ahbmo.hwdata  <= r.hdata;
    ahbmo.hconfig <= hconfig;
    ahbmo.hlock   <= '0';
    ahbmo.hwrite  <= r.ac(1).hwrite;
    ahbmo.hsize   <= r.ac(1).hsize;
    ahbmo.hburst  <= r.ac(1).hburst;
    ahbmo.hprot   <= hprot;
    ahbmo.hirq    <= xhirq;
    ahbmo.hindex  <= hindex;

  end process;

  regs : process(clk)
  begin 
    if rising_edge(clk) then 
      r <= rin; 

-- pragma translate_off
    if r.read = '1' and ahbmi.hready = '1' then --and r.oldhtrans /= HTRANS_IDLE then
      if ahbmi.hresp = HRESP_OKAY then
        if rin.status.err = '0' then
          if r.dbgl >= 2 then
            print(ptime & "Read[" & tost(r.haddr) & "]: " & tost(ahbmi.hrdata));
          end if;
        else
          if r.dbgl >= 1 then
            print(ptime & "Read[" & tost(r.haddr) & "]: " & tost(ahbmi.hrdata) 
                  & " != " & tost(r.hdata));
          end if;
        end if;
      elsif ahbmi.hresp = HRESP_RETRY then
          if r.dbgl >= 3 then
            print(ptime & "Read[" & tost(r.haddr) & "]: [RETRY]");
          end if;
      elsif ahbmi.hresp = HRESP_ERROR then
          if r.dbgl >= 1 then
            print(ptime & "Read[" & tost(r.haddr) & "]: [ERROR]");
          end if;
      end if;
    end if;
    if r.hwrite = '1' and ahbmi.hready = '1' and r.oldhtrans /= HTRANS_IDLE then
      if ahbmi.hresp = HRESP_OKAY then
        if r.dbgl >= 2 then
          print(ptime & "Write[" & tost(r.haddr) & "]: " & tost(r.hdata));
        end if;
      elsif ahbmi.hresp = HRESP_RETRY then
        if r.dbgl >= 3 then
          print(ptime & "Write[" & tost(r.haddr) & "]: " & tost(r.hdata) 
                & " [RETRY]");
        end if;
      elsif ahbmi.hresp = HRESP_ERROR then
        if r.dbgl >= 1 then
          print(ptime & "Write[" & tost(r.haddr) & "]: " & tost(r.hdata) 
                & " [ERROR]");
        end if;
      end if;
    end if;
-- pragma translate_on

    end if; 
  end process;

end;
