



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
-- Entity:      dma
-- File:        dma.vhd
-- Author:      Jiri Gaisler - Gaisler Research
-- Description: Simple DMA (needs the AHB master interface)
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


entity dma is
   port (
      rst  : in  std_logic;
      clk  : in  clk_type;
      dirq  : out std_logic;
      apbi   : in  apb_slv_in_type;
      apbo   : out apb_slv_out_type;
      ahbi : in  ahb_mst_in_type;
      ahbo : out ahb_mst_out_type 
      );
end;      

architecture struct of dma is
type dma_state_type is (readc, writec);
type reg_type is record
  srcaddr : std_logic_vector(31 downto 0);
  srcinc  : std_logic_vector(1 downto 0);
  dstaddr : std_logic_vector(31 downto 0);
  dstinc  : std_logic_vector(1 downto 0);
  len     : std_logic_vector(7 downto 0);
  enable  : std_logic;
  write   : std_logic;
  status  : std_logic_vector(1 downto 0);
  dstate  : dma_state_type;
  data    : std_logic_vector(31 downto 0);
end record;

signal r, rin : reg_type;
signal dmai : ahb_dma_in_type;
signal dmao : ahb_dma_out_type;

begin

  comb : process(apbi, dmao, rst, r)
  variable v       : reg_type;
  variable regd    : std_logic_vector(31 downto 0);   -- data from registers
  variable start   : std_logic;
  variable burst   : std_logic;
  variable write   : std_logic;
  variable ready   : std_logic;
  variable retry   : std_logic;
  variable mexc    : std_logic;
  variable irq     : std_logic;
  variable address : std_logic_vector(31 downto 0);   -- DMA address
  variable size    : std_logic_vector( 1 downto 0);   -- DMA transfer size
  variable newlen  : std_logic_vector(7 downto 0);
  variable oldaddr : std_logic_vector(9 downto 0);
  variable newaddr : std_logic_vector(9 downto 0);
  variable oldsize : std_logic_vector( 1 downto 0);
  variable ainc    : std_logic_vector( 3 downto 0);

  begin

    v := r; regd := (others => '0'); burst := '0'; start := '0';
    write := '0'; ready := '0'; mexc := '0'; address := r.srcaddr;
    size := r.srcinc; irq := '0';

-- pragma translate_off
    if not is_x(r.len) then
-- pragma translate_on
      newlen := r.len - 1;
-- pragma translate_off
   end if;
-- pragma translate_on

    write := r.write; start := r.enable;
    if dmao.active = '1' then
      if r.write = '0' then
	write := '1'; address := r.dstaddr; size := r.dstinc;
	if dmao.ready = '1' then
	  v.write := '1'; v.data := dmao.rdata;
	end if;
      else
	if (r.len(7) xor newlen(7)) = '1' then start := '0'; end if;
	write := '0';
	if dmao.ready = '1' then
	  v.write := '0'; v.len := newlen; v.enable := start; irq := start;
	end if;
      end if;
    end if;

    if r.write = '0' then oldaddr := r.srcaddr(9 downto 0); oldsize := r.srcinc;
    else oldaddr := r.dstaddr(9 downto 0); oldsize := r.dstinc; end if;

    ainc := decode(oldsize);

-- pragma translate_off
    if not is_x(oldaddr & ainc) then
-- pragma translate_on
      newaddr := oldaddr + ainc(3 downto 1);
-- pragma translate_off
   end if;
-- pragma translate_on

    if (dmao.active and dmao.ready) = '1' then
      if r.write = '0' then v.srcaddr(9 downto 0) := newaddr;
      else v.dstaddr(9 downto 0) := newaddr; end if;
    end if;

-- read DMA registers

    case apbi.paddr(3 downto 2) is
    when "00" => regd := r.srcaddr;
    when "01" => regd := r.dstaddr;
    when "10" => regd(12 downto 0) := r.enable & r.srcinc & r.dstinc & r.len;
    when others => null;
    end case;

-- write DMA registers

    if (apbi.psel and apbi.penable and apbi.pwrite) = '1' then
      case apbi.paddr(3 downto 2) is
      when "00" => 
        v.srcaddr := apbi.pwdata;
      when "01" => 
        v.dstaddr := apbi.pwdata;
      when "10" => 
        v.len := apbi.pwdata(7 downto 0);
        v.srcinc := apbi.pwdata(9 downto 8);
        v.dstinc := apbi.pwdata(11 downto 10);
        v.enable := apbi.pwdata(12);
      when others => null;
      end case;
    end if;

    if rst = '0' then
      v.dstate := readc; v.enable := '0'; v.write := '0';
    end if;

    rin <= v;
    apbo.prdata  <= regd;
    dmai.address <= address;
    dmai.wdata   <= r.data;
    dmai.start   <= start;
    dmai.burst   <= '0';
    dmai.write   <= write;
    dmai.size    <= size;
    dirq	 <= irq;

  end process;

  ahbif : ahbmst generic map (1) port map (rst, clk, dmai, dmao, ahbi, ahbo);


  regs : process(clk)
  begin if rising_edge(clk) then r <= rin; end if; end process;

end;
