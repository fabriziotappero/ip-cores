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
-------------------------------------------------------------------------------
-- Entity:	eth_ahb_mst
-- File:        eth_ahb_mst.vhd
-- Author:      Marko Isomaki - Gaisler Research
-- Description: Ethernet MAC AHB master interface
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.stdlib.all;
library eth;
use eth.grethpkg.all;

entity eth_ahb_mst is
  port(
    rst     : in  std_ulogic;
    clk     : in  std_ulogic;
    ahbmi   : in  ahbc_mst_in_type;
    ahbmo   : out ahbc_mst_out_type;
    tmsti   : in  eth_tx_ahb_in_type;
    tmsto   : out eth_tx_ahb_out_type;
    rmsti   : in  eth_rx_ahb_in_type;
    rmsto   : out eth_rx_ahb_out_type
  );
end entity;

architecture rtl of eth_ahb_mst is
  type reg_type is record
    bg     : std_ulogic; --bus granted
    bo     : std_ulogic; --bus owner, 0=rx, 1=tx
    ba     : std_ulogic; --bus active
    bb     : std_ulogic; --1kB burst boundary detected
    retry  : std_ulogic; 
  end record;

  signal r, rin : reg_type;
begin
  comb : process(rst, r, tmsti, rmsti,  ahbmi) is
  variable v       : reg_type;
  variable htrans  : std_logic_vector(1 downto 0);
  variable hbusreq : std_ulogic;
  variable hwrite  : std_ulogic; 
  variable haddr   : std_logic_vector(31 downto 0);
  variable hwdata  : std_logic_vector(31 downto 0);
  variable nbo     : std_ulogic; 
  variable tretry  : std_ulogic;
  variable rretry  : std_ulogic;
  variable rready  : std_ulogic;
  variable tready  : std_ulogic;
  variable rerror  : std_ulogic;
  variable terror  : std_ulogic;
  variable tgrant  : std_ulogic;
  variable rgrant  : std_ulogic;
  begin
    v := r; htrans := HTRANS_IDLE; rready := '0'; tready := '0'; tretry := '0';
    rretry := '0'; rerror := '0'; terror := '0'; tgrant := '0'; rgrant := '0';
    
    if r.bo = '0' then hwdata := rmsti.data;
    else hwdata := tmsti.data; end if;
    
    hbusreq := tmsti.req or rmsti.req;
    if hbusreq = '1' then htrans := HTRANS_NONSEQ; end if;

    if r.retry = '0' then
      nbo := tmsti.req and not (rmsti.req and not r.bo);
    else
      nbo := r.bo;
    end if;

    if nbo = '0' then
      haddr := rmsti.addr; hwrite := rmsti.write;
      if (rmsti.req and r.ba and not r.bo and not r.retry) = '1' then
        htrans := HTRANS_SEQ; 
      end if;
      if (rmsti.req and r.bg and ahbmi.hready and not r.retry) = '1' 
      then rgrant := '1'; end if; 
    else
      haddr := tmsti.addr; hwrite := tmsti.write;
      if (tmsti.req and r.ba and r.bo and not r.retry) = '1' then
        htrans := HTRANS_SEQ; 
      end if;
      if (tmsti.req and r.bg and ahbmi.hready and not r.retry) = '1' 
      then tgrant := '1'; end if; 
    end if;

    --1 kB burst boundary
    if ahbmi.hready = '1' then
      if haddr(9 downto 2) = "11111111" then
        v.bb := '1';
      else
        v.bb := '0';
      end if;
    end if;

    if (r.bb = '1') and (htrans /= HTRANS_IDLE) then
      htrans := HTRANS_NONSEQ;
    end if;
        
    if r.bo = '0' then
      if r.ba = '1' then
        if ahbmi.hready = '1' then
          case ahbmi.hresp is
          when HRESP_OKAY => rready := '1';
          when HRESP_SPLIT | HRESP_RETRY => rretry := '1';
          when HRESP_ERROR => rerror := '1';
          when others => null;
          end case; 
        end if;
      end if;
    else
      if r.ba = '1' then
        if ahbmi.hready = '1' then
          case ahbmi.hresp is
          when HRESP_OKAY => tready := '1';
          when HRESP_SPLIT | HRESP_RETRY => tretry := '1';
          when HRESP_ERROR => terror := '1';
          when others => null;
          end case; 
        end if;
      end if;
    end if;

    if (r.ba = '1') and 
       ((ahbmi.hresp = HRESP_RETRY) or (ahbmi.hresp = HRESP_SPLIT))
    then v.retry := not ahbmi.hready; else v.retry := '0'; end if;
      
    if r.retry = '1' then htrans := HTRANS_IDLE; end if;
    
    if ahbmi.hready = '1' then
      v.bo := nbo; v.bg := ahbmi.hgrant;
      if (htrans = HTRANS_NONSEQ) or (htrans = HTRANS_SEQ) then
        v.ba := r.bg;
      else
        v.ba := '0';
      end if;
    end if;

    if rst = '0' then
      v.bg := '0'; v.ba := '0'; v.bo := '0'; v.bb := '0';
    end if;
    
    rin <= v;
    tmsto.data     <= ahbmi.hrdata;
    rmsto.data     <= ahbmi.hrdata;
    tmsto.error    <= terror;
    tmsto.retry    <= tretry;
    tmsto.ready    <= tready;
    rmsto.error    <= rerror;
    rmsto.retry    <= rretry;
    rmsto.ready    <= rready;
    tmsto.grant    <= tgrant;
    rmsto.grant    <= rgrant;
    ahbmo.htrans   <= htrans;
    ahbmo.hbusreq  <= hbusreq;
    ahbmo.haddr	   <= haddr;
    ahbmo.hwrite   <= hwrite;
    ahbmo.hwdata   <= hwdata;
  end process;

  regs : process(clk)
  begin
    if rising_edge(clk) then r <= rin; end if;
  end process; 
 
  ahbmo.hlock	 <= '0';
  ahbmo.hsize	 <= HSIZE_WORD;
  ahbmo.hburst   <= HBURST_INCR;
  ahbmo.hprot	 <= "0011";
end architecture; 
