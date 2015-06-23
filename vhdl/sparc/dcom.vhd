



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
-- Entity:      dcom
-- File:        dcom.vhd
-- Author:      Jiri Gaisler - Gaisler Research
-- Description: UART for debug support unit
------------------------------------------------------------------------------  

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned."-";
use IEEE.std_logic_unsigned."+";
use IEEE.std_logic_arith.conv_unsigned;
use work.macro.all;
use work.amba.all;
use work.ambacomp.all;
use work.leon_iface.all;


entity dcom is
   port (
      rst    : in  std_logic;
      clk    : in  clk_type;
      dcomi  : in  dcom_in_type;
      dcomo  : out dcom_out_type;
      dsuo   : in  dsu_out_type;
      apbi   : in  apb_slv_in_type;
      apbo   : out apb_slv_out_type;
      ahbi : in  ahb_mst_in_type;
      ahbo : out ahb_mst_out_type 
      );
end;      

architecture struct of dcom is

type dcom_state_type is (idle, addr1, read1, read2, write1, write2);

type reg_type is record
  addr    : std_logic_vector(31 downto 0);
  data    : std_logic_vector(31 downto 0);
  len     : std_logic_vector(5 downto 0);
  write   : std_logic;
  clen    : std_logic_vector(1 downto 0);
  state   : dcom_state_type;
  hresp   : std_logic_vector(1 downto 0);
  txresp  : std_logic;
  dmode   : std_logic;
  dsuact  : std_logic;
end record;

signal r, rin : reg_type;
signal dmai : ahb_dma_in_type;
signal dmao : ahb_dma_out_type;
signal uarti : dcom_uart_in_type;
signal uarto : dcom_uart_out_type;

begin

  comb : process(dmao, rst, uarto, dcomi, ahbi, dsuo, r)
  variable v : reg_type;
  variable enable : std_logic;
  variable newlen : std_logic_vector(5 downto 0);
  variable vuarti : dcom_uart_in_type;
  variable vdmai : ahb_dma_in_type;
  variable newaddr : std_logic_vector(31 downto 2);

  begin

    v := r;
    vuarti.rxd := dcomi.dsurx;
    vuarti.read := '0'; vuarti.write := '0'; vuarti.data := r.data(31 downto 24);
    vdmai.start := '0'; vdmai.burst := '0'; vdmai.size := "10";
    vdmai.address := r.addr(31 downto 2) & "00"; vdmai.wdata := r.data;
    vdmai.write := r.write; v.dsuact := dsuo.dsuact;

    -- save hresp
    if dmao.ready = '1' then v.hresp := ahbi.hresp; end if;

    -- detect entering into debug mode
    v.dmode := (r.dmode or (dsuo.dsuact and not r.dsuact)) and dsuo.dresp;
    -- address incrementer
-- pragma translate_off
    if not is_x(r.len) then
-- pragma translate_on
      newlen := r.len - 1;
-- pragma translate_off
   end if;
    if not is_x(r.addr(31 downto 2)) then
-- pragma translate_on
      newaddr := r.addr(31 downto 2) + 1;
-- pragma translate_off
   end if;
-- pragma translate_on


    case r.state is
    when idle =>		-- idle state
      v.clen := "00";
      if uarto.dready = '1' then
        if uarto.data(7) = '1' then v.state := addr1; end if;
	v.write := uarto.data(6); v.len := uarto.data(5 downto 0);  
	vuarti.read := '1';
      end if;
      -- send response byte if debug mode was entered
      if (r.dmode and dsuo.dresp) = '1' then 
	v.txresp := '1'; v.dmode := '0';
      end if;
    when addr1 =>		-- receive address
      if uarto.dready = '1' then
	v.addr := r.addr(23 downto 0) & uarto.data;  
	vuarti.read := '1'; v.clen := r.clen + 1;
      end if;
      if (r.clen(1) and not v.clen(1)) = '1' then
	if r.write = '1' then v.state := write1; else v.state := read1; end if;
      end if;
    when read1 =>		-- read AHB
      if dmao.active = '1' then
	if dmao.ready = '1' then
	  v.data := dmao.rdata; v.state := read2;
        end if;
      elsif r.txresp = '0' then vdmai.start := '1'; end if;
      v.clen := "00";
    when read2 =>		-- send read-data on uart
      if uarto.thempty = '1' then
	v.data := r.data(23 downto 0) & uarto.data;  
	vuarti.write := '1'; v.clen := r.clen + 1; 
        if (r.clen(1) and not v.clen(1)) = '1' then
	  v.addr(31 downto 2) := newaddr; v.len := newlen;
          if (v.len(5) and not r.len(5)) = '1' then v.state := idle; 
	  else v.state := read1; end if;
	  if dsuo.lresp = '1' then v.txresp := '1'; end if;
        end if;
      end if;
    when write1 =>		-- receive write-data
      if uarto.dready = '1' then
	v.data := r.data(23 downto 0) & uarto.data;  
	vuarti.read := '1'; v.clen := r.clen + 1;
      end if;
      if (r.clen(1) and not v.clen(1)) = '1' then v.state := write2; end if;
    when write2 =>		-- write AHB
      if dmao.active = '1' then
	if dmao.ready = '1' then 
	  v.addr(31 downto 2) := newaddr; v.len := newlen;
          if (v.len(5) and not r.len(5)) = '1' then v.state := idle; 
	  else v.state := write1; end if;
	  if dsuo.lresp = '1' then v.txresp := '1'; end if;
        end if;
      else vdmai.start := '1'; end if;
      v.clen := "00";

    end case;

    -- send response byte
    if r.txresp = '1' then
      v.dmode := '0';
      if (uarto.lock and uarto.enable and uarto.thempty) = '1' then
        vuarti.data := "00000" & dsuo.dsuact & r.hresp; vuarti.write := '1';
	v.txresp := '0';
      end if;
    end if;

    vuarti.dsuen := dsuo.dsuen;

    if (uarto.lock and rst) = '0' then
      v.state := idle; v.write := '0'; v.dmode := '0'; v.txresp := '0';
    end if;

    rin <= v;
    dmai <= vdmai;
    uarti <= vuarti;
    dcomo.dsutx <= uarto.txd;

  end process;

  ahbmst0 : ahbmst port map (rst, clk, dmai, dmao, ahbi, ahbo);
  dcom_uart0 : dcom_uart port map (rst, clk, apbi, apbo, uarti, uarto);


  regs : process(clk)
  begin if rising_edge(clk) then r <= rin; end if; end process;

end;
