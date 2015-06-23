



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
-- Entity:      ahbmst
-- File:        ahbmst.vhd
-- Author:      Jiri Gaisler - Gaisler Research
-- Description: Simple AHB master interface
------------------------------------------------------------------------------  

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned."+";
use IEEE.std_logic_arith.conv_unsigned;

use work.amba.all;
use work.leon_iface.all;
use work.macro.all;


entity ahbmst is
  generic (incaddr : integer := 0);
   port (
      rst  : in  std_logic;
      clk  : in  clk_type;
      dmai : in ahb_dma_in_type;
      dmao : out ahb_dma_out_type;
      ahbi : in  ahb_mst_in_type;
      ahbo : out ahb_mst_out_type 
      );
end;      

architecture rtl of ahbmst is

type reg_type is record
  start   : std_logic;
  retry   : std_logic;
  grant   : std_logic;
  active  : std_logic;
end record;

signal r, rin : reg_type;

begin

  comb : process(ahbi, dmai, rst, r)
  variable v       : reg_type;
  variable ready   : std_logic;
  variable retry   : std_logic;
  variable mexc    : std_logic;
  variable inc     : std_logic_vector(3 downto 0);    -- address increment

  variable haddr   : std_logic_vector(31 downto 0);   -- AHB address
  variable hwdata  : std_logic_vector(31 downto 0);   -- AHB write data
  variable htrans  : std_logic_vector(1 downto 0);    -- transfer type 
  variable hwrite  : std_logic;  		      -- read/write
  variable hburst  : std_logic_vector(2 downto 0);    -- burst type
  variable newaddr : std_logic_vector(9 downto 0); -- next sequential address
  variable hbusreq : std_logic;   -- bus request
  begin

    v := r; ready := '0'; mexc := '0'; retry := '0';

    haddr := dmai.address; hbusreq := dmai.start; hwdata := dmai.wdata;
    newaddr := dmai.address(9 downto 0);

    inc := decode(dmai.size);

    if incaddr > 0 then
-- pragma translate_off
      if not is_x(haddr(9 downto 0)) then
-- pragma translate_on
        newaddr := haddr(9 downto 0) + inc(2 downto 0);
-- pragma translate_off
      end if;
-- pragma translate_on
    end if;

    if dmai.burst = '1' then hburst := HBURST_INCR;
    else hburst := HBURST_SINGLE; end if;

    if dmai.start = '1' then 
      if (r.active and dmai.burst and not r.retry) = '1' then 
	htrans := HTRANS_SEQ; hburst := HBURST_INCR; 
	haddr(9 downto 0) := newaddr;
      else htrans := HTRANS_NONSEQ; end if;
    else htrans := HTRANS_IDLE; end if;

    if r.active = '1' then
      if ahbi.hready = '1' then
	case ahbi.hresp is
	when HRESP_OKAY => ready := '1'; 
	when HRESP_RETRY | HRESP_SPLIT=> retry := '1'; 
	when others => ready := '1'; mexc := '1';
	end case;
      end if;
      if ((ahbi.hresp = HRESP_RETRY) or (ahbi.hresp = HRESP_SPLIT)) then 
	v.retry := not ahbi.hready; 
      else v.retry := '0'; end if;
    end if;

    if r.retry = '1' then htrans := HTRANS_IDLE; end if;

    v.start := '0';
    if ahbi.hready = '1' then 
      v.grant := ahbi.hgrant;
      if (htrans = HTRANS_NONSEQ) or (htrans = HTRANS_SEQ) then
        v.active := r.grant; v.start := r.grant;
      else
        v.active := '0';
      end if;
    end if;


    if rst = '0' then v.retry := '0'; v.active := '0'; end if;

    rin <= v;

    ahbo.haddr   <= haddr;
    ahbo.htrans  <= htrans;
    ahbo.hbusreq <= hbusreq;
    ahbo.hwdata  <= dmai.wdata;
    ahbo.hlock   <= '0';
    ahbo.hwrite  <= dmai.write;
    ahbo.hsize   <= '0' & dmai.size;
    ahbo.hburst  <= hburst;
    ahbo.hprot   <= "0011";	-- non-cached supervisor data

    dmao.start   <= r.start;
    dmao.active  <= r.active;
    dmao.ready   <= ready;
    dmao.mexc    <= mexc;
    dmao.retry   <= retry;
    dmao.haddr   <= newaddr;
    dmao.rdata   <= ahbi.hrdata;

  end process;


    regs : process(clk)
    begin if rising_edge(clk) then r <= rin; end if; end process;



end;
