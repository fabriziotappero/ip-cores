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
-- Package:     grusb
-- File:        grusb.vhd
-- Author:      Marko Isomaki, Jonas Ekergarn
-- Description: Package for GRUSBHC, GRUSBDC, and GRUSB_DCL
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.stdlib.all;
use grlib.amba.all;
library gaisler;
use gaisler.misc.all;
library techmap;
use techmap.gencomp.all;

package grusb is
  -----------------------------------------------------------------------------
  -- USB in/out types
  -----------------------------------------------------------------------------  
  type grusb_in_type is record
    datain         : std_logic_vector(15 downto 0);
    rxactive       : std_ulogic;
    rxvalid        : std_ulogic;
    rxvalidh       : std_ulogic;
    rxerror        : std_ulogic;
    txready        : std_ulogic;
    linestate      : std_logic_vector(1 downto 0);
    nxt            : std_ulogic;
    dir            : std_ulogic;
    vbusvalid      : std_ulogic;
    hostdisconnect : std_ulogic;
  end record;
  type grusb_out_type is record
    dataout           : std_logic_vector(15 downto 0);
    txvalid           : std_ulogic;
    txvalidh          : std_ulogic;
    opmode            : std_logic_vector(1 downto 0);
    xcvrselect        : std_logic_vector(1 downto 0);
    termselect        : std_ulogic;
    suspendm          : std_ulogic;
    reset             : std_ulogic;
    stp               : std_ulogic;
    oen               : std_ulogic;
    databus16_8       : std_ulogic;
    dppulldown        : std_ulogic;
    dmpulldown        : std_ulogic;
    idpullup          : std_ulogic;
    drvvbus           : std_ulogic;
    dischrgvbus       : std_ulogic;
    chrgvbus          : std_ulogic;
    txbitstuffenable  : std_ulogic;
    txbitstuffenableh : std_ulogic;
    fslsserialmode    : std_ulogic;
    tx_enable_n       : std_ulogic;
    tx_dat            : std_ulogic;
    tx_se0            : std_ulogic;
  end record;
  
  type grusb_in_vector is array (natural range <>) of grusb_in_type;
  type grusb_out_vector is array (natural range <>) of grusb_out_type;

  -----------------------------------------------------------------------------
  -- Component declarations
  -----------------------------------------------------------------------------
  component grusbhc is
    generic (
      ehchindex   : integer range 0 to NAHBMST-1 := 0;
      ehcpindex   : integer range 0 to NAPBSLV-1 := 0;
      ehcpaddr    : integer range 0 to 16#FFF#   := 0;
      ehcpirq     : integer range 0 to NAHBIRQ-1 := 0;
      ehcpmask    : integer range 0 to 16#FFF#   := 16#FFF#;
      uhchindex   : integer range 0 to NAHBMST-1 := 0;
      uhchsindex  : integer range 0 to NAHBSLV-1 := 0;
      uhchaddr    : integer range 0 to 16#FFF#   := 0;
      uhchmask    : integer range 0 to 16#FFF#   := 16#FFF#;
      uhchirq     : integer range 0 to NAHBIRQ-1 := 0;
      tech        : integer range 0 to NTECH     := DEFFABTECH;
      memtech     : integer range 0 to NTECH     := DEFMEMTECH;
      nports      : integer range 1 to 15        := 1;
      ehcgen      : integer range 0 to 1         := 1;
      uhcgen      : integer range 0 to 1         := 1;
      n_cc        : integer range 1 to 15        := 1;
      n_pcc       : integer range 1 to 15        := 1;
      prr         : integer range 0 to 1         := 0;
      portroute1  : integer                      := 0;
      portroute2  : integer                      := 0;
      endian_conv : integer range 0 to 1         := 1;
      be_regs     : integer range 0 to 1         := 0;
      be_desc     : integer range 0 to 1         := 0;
      uhcblo      : integer range 0 to 255       := 2;
      bwrd        : integer range 1 to 256       := 16;
      utm_type    : integer range 0 to 2         := 2;
      vbusconf    : integer range 0 to 3         := 3;
      netlist     : integer range 0 to 1         := 0;
      ramtest     : integer range 0 to 1         := 0;
      urst_time   : integer                      := 250;
      oepol       : integer range 0 to 1         := 0;
      scantest    : integer                      := 0);
    port (
      clk       : in  std_ulogic;
      uclk      : in  std_ulogic;
      rst       : in  std_ulogic;
      apbi      : in  apb_slv_in_type;
      ehc_apbo  : out apb_slv_out_type;
      ahbmi     : in  ahb_mst_in_type;
      ahbsi     : in  ahb_slv_in_type;
      ehc_ahbmo : out ahb_mst_out_type;
      uhc_ahbmo : out ahb_mst_out_vector_type(n_cc*uhcgen downto 1*uhcgen);
      uhc_ahbso : out ahb_slv_out_vector_type(n_cc*uhcgen downto 1*uhcgen);
      o         : out grusb_out_vector((nports-1) downto 0);
      i         : in  grusb_in_vector((nports-1) downto 0));               
  end component;

  component grusbdc is
    generic (
      hsindex  : integer range 0 to NAHBSLV-1 := 0;
      hirq     : integer range 0 to NAHBIRQ-1 := 0;
      haddr    : integer                      := 0;
      hmask    : integer                      := 16#FFF#;
      hmindex  : integer range 0 to NAHBMST-1 := 0;
      aiface   : integer range 0 to 1         := 0;
      memtech  : integer range 0 to NTECH     := DEFMEMTECH;
      uiface   : integer range 0 to 1         := 0;
      dwidth   : integer range 8 to 16        := 8;
      nepi     : integer range 1 to 16        := 1;
      nepo     : integer range 1 to 16        := 1;
      i0       : integer range 8 to 3072      := 1024;
      i1       : integer range 8 to 3072      := 1024;
      i2       : integer range 8 to 3072      := 1024;
      i3       : integer range 8 to 3072      := 1024;
      i4       : integer range 8 to 3072      := 1024;
      i5       : integer range 8 to 3072      := 1024;
      i6       : integer range 8 to 3072      := 1024;
      i7       : integer range 8 to 3072      := 1024;
      i8       : integer range 8 to 3072      := 1024;
      i9       : integer range 8 to 3072      := 1024;
      i10      : integer range 8 to 3072      := 1024;
      i11      : integer range 8 to 3072      := 1024;
      i12      : integer range 8 to 3072      := 1024;
      i13      : integer range 8 to 3072      := 1024;
      i14      : integer range 8 to 3072      := 1024;
      i15      : integer range 8 to 3072      := 1024;
      o0       : integer range 8 to 3072      := 1024;
      o1       : integer range 8 to 3072      := 1024;
      o2       : integer range 8 to 3072      := 1024;
      o3       : integer range 8 to 3072      := 1024;
      o4       : integer range 8 to 3072      := 1024;
      o5       : integer range 8 to 3072      := 1024;
      o6       : integer range 8 to 3072      := 1024;
      o7       : integer range 8 to 3072      := 1024;
      o8       : integer range 8 to 3072      := 1024;
      o9       : integer range 8 to 3072      := 1024;
      o10      : integer range 8 to 3072      := 1024;
      o11      : integer range 8 to 3072      := 1024;
      o12      : integer range 8 to 3072      := 1024;
      o13      : integer range 8 to 3072      := 1024;
      o14      : integer range 8 to 3072      := 1024;
      o15      : integer range 8 to 3072      := 1024;
      oepol    : integer range 0 to 1         := 0;
      syncprst : integer range 0 to 1         := 0;
      prsttime : integer range 0 to 512       := 0;
      sysfreq  : integer := 50000;
      keepclk  : integer range 0 to 1         := 0;
      sepirq   : integer range 0 to 1         := 0;
      irqi     : integer range 0 to NAHBIRQ-1 := 1;
      irqo     : integer range 0 to NAHBIRQ-1 := 2);
    port (
      uclk  : in  std_ulogic;
      usbi  : in  grusb_in_type;
      usbo  : out grusb_out_type;
      hclk  : in  std_ulogic;
      hrst  : in  std_ulogic;
      ahbmi : in  ahb_mst_in_type;
      ahbmo : out ahb_mst_out_type;
      ahbsi : in  ahb_slv_in_type;
      ahbso : out ahb_slv_out_type
    );
  end component;

  component grusb_dcl is
    generic (
      hindex   : integer                := 0;
      memtech  : integer                := DEFMEMTECH;
      uiface   : integer range 0 to 1   := 0;
      dwidth   : integer range 8 to 16  := 8;
      oepol    : integer range 0 to 1   := 0;
      syncprst : integer range 0 to 1   := 0;
      prsttime : integer range 0 to 512 := 0;
      sysfreq  : integer                := 50000;
      keepclk  : integer range 0 to 1   := 0
    );
    port (
      uclk : in  std_ulogic;
      usbi : in  grusb_in_type;
      usbo : out grusb_out_type;
      hclk : in  std_ulogic;
      hrst : in  std_ulogic;
      ahbi : in  ahb_mst_in_type;
      ahbo : out ahb_mst_out_type
    );
  end component grusb_dcl;
  
end grusb;

