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
-- Entity: 	grusbhc_net
-- File:	grusbhc_net.vhd
-- Author:	Jonas Ekergarn - Gaisler Research
-- Description: GRUSBHC netlist wrapper
------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
library techmap;
use techmap.gencomp.all;

entity grusbhc_net is
  generic (
    tech        : integer := 0;
    nports      : integer range 1 to 15 := 1;
    ehcgen      : integer range 0 to 1 := 1;
    uhcgen      : integer range 0 to 1 := 1;
    n_cc        : integer range 1 to 15 := 1;
    n_pcc       : integer range 1 to 15 := 1;
    prr         : integer range 0 to 1 := 0;
    portroute1  : integer := 0;
    portroute2  : integer := 0;
    endian_conv : integer range 0 to 1 := 1;
    be_regs     : integer range 0 to 1 := 0;
    be_desc     : integer range 0 to 1 := 0;
    uhcblo      : integer range 0 to 255 := 2;
    bwrd        : integer range 1 to 256 := 16;
    utm_type    : integer range 0 to 2 := 2;
    vbusconf    : integer range 0 to 3 := 3;
    ramtest     : integer range 0 to 1 := 0;
    urst_time   : integer := 250;
    oepol       : integer range 0 to 1 := 0;
    scantest    : integer := 0;
    memtech     : integer range 0 to NTECH := DEFMEMTECH);
  port (
    clk               : in  std_ulogic;
    uclk              : in  std_ulogic;
    rst               : in  std_ulogic;
    ursti             : in  std_ulogic;
    -- EHC apb_slv_in_type unwrapped
    ehc_apbsi_psel    : in  std_ulogic;
    ehc_apbsi_penable : in  std_ulogic;
    ehc_apbsi_paddr   : in  std_logic_vector(31 downto 0);
    ehc_apbsi_pwrite  : in  std_ulogic;
    ehc_apbsi_pwdata  : in  std_logic_vector(31 downto 0);
    ehc_apbsi_testen  : in  std_ulogic;
    ehc_apbsi_testrst : in  std_ulogic;
    ehc_apbsi_scanen  : in  std_ulogic;
    -- EHC apb_slv_out_type unwrapped
    ehc_apbso_prdata  : out std_logic_vector(31 downto 0);
    ehc_apbso_pirq    : out std_ulogic;
    -- EHC/UHC ahb_mst_in_type unwrapped
    ahbmi_hgrant      : in  std_logic_vector(n_cc*uhcgen downto 0);
    ahbmi_hready      : in  std_ulogic;
    ahbmi_hresp       : in  std_logic_vector(1 downto 0);
    ahbmi_hrdata      : in  std_logic_vector(31 downto 0);
    ahbmi_hcache      : in  std_ulogic;
    ahbmi_testen      : in  std_ulogic;
    ahbmi_testrst     : in  std_ulogic;
    ahbmi_scanen      : in  std_ulogic;
    -- UHC ahb_slv_in_type unwrapped
    uhc_ahbsi_hsel    : in  std_logic_vector(n_cc*uhcgen downto 1*uhcgen);
    uhc_ahbsi_haddr   : in  std_logic_vector(31 downto 0);
    uhc_ahbsi_hwrite  : in  std_ulogic;
    uhc_ahbsi_htrans  : in  std_logic_vector(1 downto 0);
    uhc_ahbsi_hsize   : in  std_logic_vector(2 downto 0);
    uhc_ahbsi_hwdata  : in  std_logic_vector(31 downto 0);
    uhc_ahbsi_hready  : in  std_ulogic;
    uhc_ahbsi_testen  : in  std_ulogic;
    uhc_ahbsi_testrst : in  std_ulogic;
    uhc_ahbsi_scanen  : in  std_ulogic;
    -- EHC ahb_mst_out_type_unwrapped 
    ehc_ahbmo_hbusreq : out std_ulogic;
    ehc_ahbmo_hlock   : out std_ulogic;
    ehc_ahbmo_htrans  : out std_logic_vector(1 downto 0);
    ehc_ahbmo_haddr   : out std_logic_vector(31 downto 0);
    ehc_ahbmo_hwrite  : out std_ulogic;
    ehc_ahbmo_hsize   : out std_logic_vector(2 downto 0);
    ehc_ahbmo_hburst  : out std_logic_vector(2 downto 0);
    ehc_ahbmo_hprot   : out std_logic_vector(3 downto 0);
    ehc_ahbmo_hwdata  : out std_logic_vector(31 downto 0);
    -- UHC ahb_mst_out_vector_type unwrapped
    uhc_ahbmo_hbusreq : out std_logic_vector(n_cc*uhcgen downto 1*uhcgen);
    uhc_ahbmo_hlock   : out std_logic_vector(n_cc*uhcgen downto 1*uhcgen);
    uhc_ahbmo_htrans  : out std_logic_vector((n_cc*2)*uhcgen downto 1*uhcgen);
    uhc_ahbmo_haddr   : out std_logic_vector((n_cc*32)*uhcgen downto 1*uhcgen);
    uhc_ahbmo_hwrite  : out std_logic_vector(n_cc*uhcgen downto 1*uhcgen);
    uhc_ahbmo_hsize   : out std_logic_vector((n_cc*3)*uhcgen downto 1*uhcgen);
    uhc_ahbmo_hburst  : out std_logic_vector((n_cc*3)*uhcgen downto 1*uhcgen);
    uhc_ahbmo_hprot   : out std_logic_vector((n_cc*4)*uhcgen downto 1*uhcgen);
    uhc_ahbmo_hwdata  : out std_logic_vector((n_cc*32)*uhcgen downto 1*uhcgen);
    -- UHC ahb_slv_out_vector_type unwrapped
    uhc_ahbso_hready  : out std_logic_vector(n_cc*uhcgen downto 1*uhcgen);
    uhc_ahbso_hresp   : out std_logic_vector((n_cc*2)*uhcgen downto 1*uhcgen);
    uhc_ahbso_hrdata  : out std_logic_vector((n_cc*32)*uhcgen downto 1*uhcgen);
    uhc_ahbso_hsplit  : out std_logic_vector((n_cc*16)*uhcgen downto 1*uhcgen);
    uhc_ahbso_hcache  : out std_logic_vector(n_cc*uhcgen downto 1*uhcgen);
    uhc_ahbso_hirq    : out std_logic_vector(n_cc*uhcgen downto 1*uhcgen);
    -- grusb_out_type_vector unwrapped
    xcvrsel           : out std_logic_vector(((nports*2)-1) downto 0);
    termsel           : out std_logic_vector((nports-1) downto 0);
    opmode            : out std_logic_vector(((nports*2)-1) downto 0);
    txvalid           : out std_logic_vector((nports-1) downto 0);
    drvvbus           : out std_logic_vector((nports-1) downto 0);
    dataho            : out std_logic_vector(((nports*8)-1) downto 0);
    validho           : out std_logic_vector((nports-1) downto 0);
    stp               : out std_logic_vector((nports-1) downto 0);
    datao             : out std_logic_vector(((nports*8)-1) downto 0);
    utm_rst           : out std_logic_vector((nports-1) downto 0);
    dctrlo            : out std_logic_vector((nports-1) downto 0);
    suspendm          : out std_ulogic;
    dbus16_8          : out std_ulogic;
    dppulldown        : out std_ulogic;
    dmpulldown        : out std_ulogic;
    idpullup          : out std_ulogic;
    dischrgvbus       : out std_ulogic;
    chrgvbus          : out std_ulogic;
    txbitstuffenable  : out std_ulogic;
    txbitstuffenableh : out std_ulogic;
    fslsserialmode    : out std_ulogic;
    txenablen         : out std_ulogic;
    txdat             : out std_ulogic;
    txse0             : out std_ulogic;
    -- grusb_in_type_vector unwrapped
    linestate         : in  std_logic_vector(((nports*2)-1) downto 0);
    txready           : in  std_logic_vector((nports-1) downto 0);
    rxvalid           : in  std_logic_vector((nports-1) downto 0);
    rxactive          : in  std_logic_vector((nports-1) downto 0);
    rxerror           : in  std_logic_vector((nports-1) downto 0);
    vbusvalid         : in  std_logic_vector((nports-1) downto 0);
    datahi            : in  std_logic_vector(((nports*8)-1) downto 0);
    validhi           : in  std_logic_vector((nports-1) downto 0);
    hostdisc          : in  std_logic_vector((nports-1) downto 0);
    nxt               : in  std_logic_vector((nports-1) downto 0);
    dir               : in  std_logic_vector((nports-1) downto 0);
    datai             : in  std_logic_vector(((nports*8)-1) downto 0);
    -- EHC transaction buffer signals
    mbc20_tb_addr     : out std_logic_vector(8 downto 0);
    mbc20_tb_data     : out std_logic_vector(31 downto 0);
    mbc20_tb_en       : out std_ulogic;
    mbc20_tb_wel      : out std_ulogic;
    mbc20_tb_weh      : out std_ulogic;
    tb_mbc20_data     : in  std_logic_vector(31 downto 0);
    pe20_tb_addr      : out std_logic_vector(8 downto 0);
    pe20_tb_data      : out std_logic_vector(31 downto 0);
    pe20_tb_en        : out std_ulogic;
    pe20_tb_wel       : out std_ulogic;
    pe20_tb_weh       : out std_ulogic;
    tb_pe20_data      : in  std_logic_vector(31 downto 0);
    -- EHC packet buffer signals
    mbc20_pb_addr     : out std_logic_vector(8 downto 0);
    mbc20_pb_data     : out std_logic_vector(31 downto 0);
    mbc20_pb_en       : out std_ulogic;
    mbc20_pb_we       : out std_ulogic;
    pb_mbc20_data     : in  std_logic_vector(31 downto 0);
    sie20_pb_addr     : out std_logic_vector(8 downto 0);
    sie20_pb_data     : out std_logic_vector(31 downto 0);
    sie20_pb_en       : out std_ulogic;
    sie20_pb_we       : out std_ulogic;
    pb_sie20_data     : in  std_logic_vector(31 downto 0);
    -- UHC packet buffer signals
    sie11_pb_addr     : out std_logic_vector((n_cc*9)*uhcgen downto 1*uhcgen);
    sie11_pb_data     : out std_logic_vector((n_cc*32)*uhcgen downto 1*uhcgen);
    sie11_pb_en       : out std_logic_vector(n_cc*uhcgen downto 1*uhcgen);
    sie11_pb_we       : out std_logic_vector(n_cc*uhcgen downto 1*uhcgen);
    pb_sie11_data     : in  std_logic_vector((n_cc*32)*uhcgen downto 1*uhcgen);
    mbc11_pb_addr     : out std_logic_vector((n_cc*9)*uhcgen downto 1*uhcgen);
    mbc11_pb_data     : out std_logic_vector((n_cc*32)*uhcgen downto 1*uhcgen);
    mbc11_pb_en       : out std_logic_vector(n_cc*uhcgen downto 1*uhcgen);
    mbc11_pb_we       : out std_logic_vector(n_cc*uhcgen downto 1*uhcgen);
    pb_mbc11_data     : in  std_logic_vector((n_cc*32)*uhcgen downto 1*uhcgen);
    bufsel            : out std_ulogic);
end grusbhc_net;

architecture rtl of grusbhc_net is

  component grusbhc_unisim is
    generic (
      nports      : integer range 1 to 15 := 1;
      ehcgen      : integer range 0 to 1 := 1;
      uhcgen      : integer range 0 to 1 := 1;
      n_cc        : integer range 1 to 15 := 1;
      n_pcc       : integer range 1 to 15 := 1;
      prr         : integer range 0 to 1 := 0;
      portroute1  : integer := 0;
      portroute2  : integer := 0;
      endian_conv : integer range 0 to 1 := 1;
      be_regs     : integer range 0 to 1 := 0;
      be_desc     : integer range 0 to 1 := 0;
      uhcblo      : integer range 0 to 255 := 2;
      bwrd        : integer range 1 to 256 := 16;
      utm_type    : integer range 0 to 2 := 2;
      vbusconf    : integer range 0 to 3 := 3;
      ramtest     : integer range 0 to 1 := 0;
      urst_time   : integer := 250;
      oepol       : integer range 0 to 1 := 0;
      scantest    : integer := 0;
      memtech     : integer range 0 to NTECH := DEFMEMTECH
    );
    port (
      clk               : in  std_ulogic;
      uclk              : in  std_ulogic;
      rst               : in  std_ulogic;
      ursti             : in  std_ulogic;
      -- EHC apb_slv_in_type unwrapped
      ehc_apbsi_psel    : in  std_ulogic;
      ehc_apbsi_penable : in  std_ulogic;
      ehc_apbsi_paddr   : in  std_logic_vector(31 downto 0);
      ehc_apbsi_pwrite  : in  std_ulogic;
      ehc_apbsi_pwdata  : in  std_logic_vector(31 downto 0);
      ehc_apbsi_testen  : in  std_ulogic;
      ehc_apbsi_testrst : in  std_ulogic;
      ehc_apbsi_scanen  : in  std_ulogic;
      -- EHC apb_slv_out_type unwrapped
      ehc_apbso_prdata  : out std_logic_vector(31 downto 0);
      ehc_apbso_pirq    : out std_ulogic;
      -- EHC/UHC ahb_mst_in_type unwrapped
      ahbmi_hgrant      : in  std_logic_vector(n_cc*uhcgen downto 0);
      ahbmi_hready      : in  std_ulogic;
      ahbmi_hresp       : in  std_logic_vector(1 downto 0);
      ahbmi_hrdata      : in  std_logic_vector(31 downto 0);
      ahbmi_hcache      : in  std_ulogic;
      ahbmi_testen      : in  std_ulogic;
      ahbmi_testrst     : in  std_ulogic;
      ahbmi_scanen      : in  std_ulogic;
      -- UHC ahb_slv_in_type unwrapped
      uhc_ahbsi_hsel    : in  std_logic_vector(n_cc*uhcgen downto 1*uhcgen);
      uhc_ahbsi_haddr   : in  std_logic_vector(31 downto 0);
      uhc_ahbsi_hwrite  : in  std_ulogic;
      uhc_ahbsi_htrans  : in  std_logic_vector(1 downto 0);
      uhc_ahbsi_hsize   : in  std_logic_vector(2 downto 0);
      uhc_ahbsi_hwdata  : in  std_logic_vector(31 downto 0);
      uhc_ahbsi_hready  : in  std_ulogic;
      uhc_ahbsi_testen  : in  std_ulogic;
      uhc_ahbsi_testrst : in  std_ulogic;
      uhc_ahbsi_scanen  : in  std_ulogic;
      -- EHC ahb_mst_out_type_unwrapped 
      ehc_ahbmo_hbusreq : out std_ulogic;
      ehc_ahbmo_hlock   : out std_ulogic;
      ehc_ahbmo_htrans  : out std_logic_vector(1 downto 0);
      ehc_ahbmo_haddr   : out std_logic_vector(31 downto 0);
      ehc_ahbmo_hwrite  : out std_ulogic;
      ehc_ahbmo_hsize   : out std_logic_vector(2 downto 0);
      ehc_ahbmo_hburst  : out std_logic_vector(2 downto 0);
      ehc_ahbmo_hprot   : out std_logic_vector(3 downto 0);
      ehc_ahbmo_hwdata  : out std_logic_vector(31 downto 0);
      -- UHC ahb_mst_out_vector_type unwrapped
      uhc_ahbmo_hbusreq : out std_logic_vector(n_cc*uhcgen downto 1*uhcgen);
      uhc_ahbmo_hlock   : out std_logic_vector(n_cc*uhcgen downto 1*uhcgen);
      uhc_ahbmo_htrans  : out std_logic_vector((n_cc*2)*uhcgen downto 1*uhcgen);
      uhc_ahbmo_haddr   : out std_logic_vector((n_cc*32)*uhcgen downto 1*uhcgen);
      uhc_ahbmo_hwrite  : out std_logic_vector(n_cc*uhcgen downto 1*uhcgen);
      uhc_ahbmo_hsize   : out std_logic_vector((n_cc*3)*uhcgen downto 1*uhcgen);
      uhc_ahbmo_hburst  : out std_logic_vector((n_cc*3)*uhcgen downto 1*uhcgen);
      uhc_ahbmo_hprot   : out std_logic_vector((n_cc*4)*uhcgen downto 1*uhcgen);
      uhc_ahbmo_hwdata  : out std_logic_vector((n_cc*32)*uhcgen downto 1*uhcgen);
      -- UHC ahb_slv_out_vector_type unwrapped
      uhc_ahbso_hready  : out std_logic_vector(n_cc*uhcgen downto 1*uhcgen);
      uhc_ahbso_hresp   : out std_logic_vector((n_cc*2)*uhcgen downto 1*uhcgen);
      uhc_ahbso_hrdata  : out std_logic_vector((n_cc*32)*uhcgen downto 1*uhcgen);
      uhc_ahbso_hsplit  : out std_logic_vector((n_cc*16)*uhcgen downto 1*uhcgen);
      uhc_ahbso_hcache  : out std_logic_vector(n_cc*uhcgen downto 1*uhcgen);
      uhc_ahbso_hirq    : out std_logic_vector(n_cc*uhcgen downto 1*uhcgen);
      -- grusb_out_type_vector unwrapped
      xcvrsel           : out std_logic_vector(((nports*2)-1) downto 0);
      termsel           : out std_logic_vector((nports-1) downto 0);
      opmode            : out std_logic_vector(((nports*2)-1) downto 0);
      txvalid           : out std_logic_vector((nports-1) downto 0);
      drvvbus           : out std_logic_vector((nports-1) downto 0);
      dataho            : out std_logic_vector(((nports*8)-1) downto 0);
      validho           : out std_logic_vector((nports-1) downto 0);
      stp               : out std_logic_vector((nports-1) downto 0);
      datao             : out std_logic_vector(((nports*8)-1) downto 0);
      utm_rst           : out std_logic_vector((nports-1) downto 0);
      dctrlo            : out std_logic_vector((nports-1) downto 0);
      suspendm          : out std_ulogic;
      dbus16_8          : out std_ulogic;
      dppulldown        : out std_ulogic;
      dmpulldown        : out std_ulogic;
      idpullup          : out std_ulogic;
      dischrgvbus       : out std_ulogic;
      chrgvbus          : out std_ulogic;
      txbitstuffenable  : out std_ulogic;
      txbitstuffenableh : out std_ulogic;
      fslsserialmode    : out std_ulogic;
      txenablen         : out std_ulogic;
      txdat             : out std_ulogic;
      txse0             : out std_ulogic;
      -- grusb_in_type_vector unwrapped
      linestate         : in  std_logic_vector(((nports*2)-1) downto 0);
      txready           : in  std_logic_vector((nports-1) downto 0);
      rxvalid           : in  std_logic_vector((nports-1) downto 0);
      rxactive          : in  std_logic_vector((nports-1) downto 0);
      rxerror           : in  std_logic_vector((nports-1) downto 0);
      vbusvalid         : in  std_logic_vector((nports-1) downto 0);
      datahi            : in  std_logic_vector(((nports*8)-1) downto 0);
      validhi           : in  std_logic_vector((nports-1) downto 0);
      hostdisc          : in  std_logic_vector((nports-1) downto 0);
      nxt               : in  std_logic_vector((nports-1) downto 0);
      dir               : in  std_logic_vector((nports-1) downto 0);
      datai             : in  std_logic_vector(((nports*8)-1) downto 0);
      -- EHC transaction buffer signals
      mbc20_tb_addr     : out std_logic_vector(8 downto 0);
      mbc20_tb_data     : out std_logic_vector(31 downto 0);
      mbc20_tb_en       : out std_ulogic;
      mbc20_tb_wel      : out std_ulogic;
      mbc20_tb_weh      : out std_ulogic;
      tb_mbc20_data     : in  std_logic_vector(31 downto 0);
      pe20_tb_addr      : out std_logic_vector(8 downto 0);
      pe20_tb_data      : out std_logic_vector(31 downto 0);
      pe20_tb_en        : out std_ulogic;
      pe20_tb_wel       : out std_ulogic;
      pe20_tb_weh       : out std_ulogic;
      tb_pe20_data      : in  std_logic_vector(31 downto 0);
      -- EHC packet buffer signals
      mbc20_pb_addr     : out std_logic_vector(8 downto 0);
      mbc20_pb_data     : out std_logic_vector(31 downto 0);
      mbc20_pb_en       : out std_ulogic;
      mbc20_pb_we       : out std_ulogic;
      pb_mbc20_data     : in  std_logic_vector(31 downto 0);
      sie20_pb_addr     : out std_logic_vector(8 downto 0);
      sie20_pb_data     : out std_logic_vector(31 downto 0);
      sie20_pb_en       : out std_ulogic;
      sie20_pb_we       : out std_ulogic;
      pb_sie20_data     : in  std_logic_vector(31 downto 0);
      -- UHC packet buffer signals
      sie11_pb_addr     : out std_logic_vector((n_cc*9)*uhcgen downto 1*uhcgen);
      sie11_pb_data     : out std_logic_vector((n_cc*32)*uhcgen downto 1*uhcgen);
      sie11_pb_en       : out std_logic_vector(n_cc*uhcgen downto 1*uhcgen);
      sie11_pb_we       : out std_logic_vector(n_cc*uhcgen downto 1*uhcgen);
      pb_sie11_data     : in  std_logic_vector((n_cc*32)*uhcgen downto 1*uhcgen);
      mbc11_pb_addr     : out std_logic_vector((n_cc*9)*uhcgen downto 1*uhcgen);
      mbc11_pb_data     : out std_logic_vector((n_cc*32)*uhcgen downto 1*uhcgen);
      mbc11_pb_en       : out std_logic_vector(n_cc*uhcgen downto 1*uhcgen);
      mbc11_pb_we       : out std_logic_vector(n_cc*uhcgen downto 1*uhcgen);
      pb_mbc11_data     : in  std_logic_vector((n_cc*32)*uhcgen downto 1*uhcgen);
      bufsel            : out std_ulogic);
  end component;

  component grusbhc_stratixii is
    generic (
      nports      : integer range 1 to 15 := 1;
      ehcgen      : integer range 0 to 1 := 1;
      uhcgen      : integer range 0 to 1 := 1;
      n_cc        : integer range 1 to 15 := 1;
      n_pcc       : integer range 1 to 15 := 1;
      prr         : integer range 0 to 1 := 0;
      portroute1  : integer := 0;
      portroute2  : integer := 0;
      endian_conv : integer range 0 to 1 := 1;
      be_regs     : integer range 0 to 1 := 0;
      be_desc     : integer range 0 to 1 := 0;
      uhcblo      : integer range 0 to 255 := 2;
      bwrd        : integer range 1 to 256 := 16;
      utm_type    : integer range 0 to 2 := 2;
      vbusconf    : integer range 0 to 3 := 3;
      ramtest     : integer range 0 to 1 := 0;
      urst_time   : integer := 250;
      oepol       : integer range 0 to 1 := 0;
      scantest    : integer := 0;
      memtech     : integer range 0 to NTECH := DEFMEMTECH
    );
    port (
      clk               : in  std_ulogic;
      uclk              : in  std_ulogic;
      rst               : in  std_ulogic;
      ursti             : in  std_ulogic;
      -- EHC apb_slv_in_type unwrapped
      ehc_apbsi_psel    : in  std_ulogic;
      ehc_apbsi_penable : in  std_ulogic;
      ehc_apbsi_paddr   : in  std_logic_vector(31 downto 0);
      ehc_apbsi_pwrite  : in  std_ulogic;
      ehc_apbsi_pwdata  : in  std_logic_vector(31 downto 0);
      ehc_apbsi_testen  : in  std_ulogic;
      ehc_apbsi_testrst : in  std_ulogic;
      ehc_apbsi_scanen  : in  std_ulogic;
      -- EHC apb_slv_out_type unwrapped
      ehc_apbso_prdata  : out std_logic_vector(31 downto 0);
      ehc_apbso_pirq    : out std_ulogic;
      -- EHC/UHC ahb_mst_in_type unwrapped
      ahbmi_hgrant      : in  std_logic_vector(n_cc*uhcgen downto 0);
      ahbmi_hready      : in  std_ulogic;
      ahbmi_hresp       : in  std_logic_vector(1 downto 0);
      ahbmi_hrdata      : in  std_logic_vector(31 downto 0);
      ahbmi_hcache      : in  std_ulogic;
      ahbmi_testen      : in  std_ulogic;
      ahbmi_testrst     : in  std_ulogic;
      ahbmi_scanen      : in  std_ulogic;
      -- UHC ahb_slv_in_type unwrapped
      uhc_ahbsi_hsel    : in  std_logic_vector(n_cc*uhcgen downto 1*uhcgen);
      uhc_ahbsi_haddr   : in  std_logic_vector(31 downto 0);
      uhc_ahbsi_hwrite  : in  std_ulogic;
      uhc_ahbsi_htrans  : in  std_logic_vector(1 downto 0);
      uhc_ahbsi_hsize   : in  std_logic_vector(2 downto 0);
      uhc_ahbsi_hwdata  : in  std_logic_vector(31 downto 0);
      uhc_ahbsi_hready  : in  std_ulogic;
      uhc_ahbsi_testen  : in  std_ulogic;
      uhc_ahbsi_testrst : in  std_ulogic;
      uhc_ahbsi_scanen  : in  std_ulogic;
      -- EHC ahb_mst_out_type_unwrapped 
      ehc_ahbmo_hbusreq : out std_ulogic;
      ehc_ahbmo_hlock   : out std_ulogic;
      ehc_ahbmo_htrans  : out std_logic_vector(1 downto 0);
      ehc_ahbmo_haddr   : out std_logic_vector(31 downto 0);
      ehc_ahbmo_hwrite  : out std_ulogic;
      ehc_ahbmo_hsize   : out std_logic_vector(2 downto 0);
      ehc_ahbmo_hburst  : out std_logic_vector(2 downto 0);
      ehc_ahbmo_hprot   : out std_logic_vector(3 downto 0);
      ehc_ahbmo_hwdata  : out std_logic_vector(31 downto 0);
      -- UHC ahb_mst_out_vector_type unwrapped
      uhc_ahbmo_hbusreq : out std_logic_vector(n_cc*uhcgen downto 1*uhcgen);
      uhc_ahbmo_hlock   : out std_logic_vector(n_cc*uhcgen downto 1*uhcgen);
      uhc_ahbmo_htrans  : out std_logic_vector((n_cc*2)*uhcgen downto 1*uhcgen);
      uhc_ahbmo_haddr   : out std_logic_vector((n_cc*32)*uhcgen downto 1*uhcgen);
      uhc_ahbmo_hwrite  : out std_logic_vector(n_cc*uhcgen downto 1*uhcgen);
      uhc_ahbmo_hsize   : out std_logic_vector((n_cc*3)*uhcgen downto 1*uhcgen);
      uhc_ahbmo_hburst  : out std_logic_vector((n_cc*3)*uhcgen downto 1*uhcgen);
      uhc_ahbmo_hprot   : out std_logic_vector((n_cc*4)*uhcgen downto 1*uhcgen);
      uhc_ahbmo_hwdata  : out std_logic_vector((n_cc*32)*uhcgen downto 1*uhcgen);
      -- UHC ahb_slv_out_vector_type unwrapped
      uhc_ahbso_hready  : out std_logic_vector(n_cc*uhcgen downto 1*uhcgen);
      uhc_ahbso_hresp   : out std_logic_vector((n_cc*2)*uhcgen downto 1*uhcgen);
      uhc_ahbso_hrdata  : out std_logic_vector((n_cc*32)*uhcgen downto 1*uhcgen);
      uhc_ahbso_hsplit  : out std_logic_vector((n_cc*16)*uhcgen downto 1*uhcgen);
      uhc_ahbso_hcache  : out std_logic_vector(n_cc*uhcgen downto 1*uhcgen);
      uhc_ahbso_hirq    : out std_logic_vector(n_cc*uhcgen downto 1*uhcgen);
      -- grusb_out_type_vector unwrapped
      xcvrsel           : out std_logic_vector(((nports*2)-1) downto 0);
      termsel           : out std_logic_vector((nports-1) downto 0);
      opmode            : out std_logic_vector(((nports*2)-1) downto 0);
      txvalid           : out std_logic_vector((nports-1) downto 0);
      drvvbus           : out std_logic_vector((nports-1) downto 0);
      dataho            : out std_logic_vector(((nports*8)-1) downto 0);
      validho           : out std_logic_vector((nports-1) downto 0);
      stp               : out std_logic_vector((nports-1) downto 0);
      datao             : out std_logic_vector(((nports*8)-1) downto 0);
      utm_rst           : out std_logic_vector((nports-1) downto 0);
      dctrlo            : out std_logic_vector((nports-1) downto 0);
      suspendm          : out std_ulogic;
      dbus16_8          : out std_ulogic;
      dppulldown        : out std_ulogic;
      dmpulldown        : out std_ulogic;
      idpullup          : out std_ulogic;
      dischrgvbus       : out std_ulogic;
      chrgvbus          : out std_ulogic;
      txbitstuffenable  : out std_ulogic;
      txbitstuffenableh : out std_ulogic;
      fslsserialmode    : out std_ulogic;
      txenablen         : out std_ulogic;
      txdat             : out std_ulogic;
      txse0             : out std_ulogic;
      -- grusb_in_type_vector unwrapped
      linestate         : in  std_logic_vector(((nports*2)-1) downto 0);
      txready           : in  std_logic_vector((nports-1) downto 0);
      rxvalid           : in  std_logic_vector((nports-1) downto 0);
      rxactive          : in  std_logic_vector((nports-1) downto 0);
      rxerror           : in  std_logic_vector((nports-1) downto 0);
      vbusvalid         : in  std_logic_vector((nports-1) downto 0);
      datahi            : in  std_logic_vector(((nports*8)-1) downto 0);
      validhi           : in  std_logic_vector((nports-1) downto 0);
      hostdisc          : in  std_logic_vector((nports-1) downto 0);
      nxt               : in  std_logic_vector((nports-1) downto 0);
      dir               : in  std_logic_vector((nports-1) downto 0);
      datai             : in  std_logic_vector(((nports*8)-1) downto 0);
      -- EHC transaction buffer signals
      mbc20_tb_addr     : out std_logic_vector(8 downto 0);
      mbc20_tb_data     : out std_logic_vector(31 downto 0);
      mbc20_tb_en       : out std_ulogic;
      mbc20_tb_wel      : out std_ulogic;
      mbc20_tb_weh      : out std_ulogic;
      tb_mbc20_data     : in  std_logic_vector(31 downto 0);
      pe20_tb_addr      : out std_logic_vector(8 downto 0);
      pe20_tb_data      : out std_logic_vector(31 downto 0);
      pe20_tb_en        : out std_ulogic;
      pe20_tb_wel       : out std_ulogic;
      pe20_tb_weh       : out std_ulogic;
      tb_pe20_data      : in  std_logic_vector(31 downto 0);
      -- EHC packet buffer signals
      mbc20_pb_addr     : out std_logic_vector(8 downto 0);
      mbc20_pb_data     : out std_logic_vector(31 downto 0);
      mbc20_pb_en       : out std_ulogic;
      mbc20_pb_we       : out std_ulogic;
      pb_mbc20_data     : in  std_logic_vector(31 downto 0);
      sie20_pb_addr     : out std_logic_vector(8 downto 0);
      sie20_pb_data     : out std_logic_vector(31 downto 0);
      sie20_pb_en       : out std_ulogic;
      sie20_pb_we       : out std_ulogic;
      pb_sie20_data     : in  std_logic_vector(31 downto 0);
      -- UHC packet buffer signals
      sie11_pb_addr     : out std_logic_vector((n_cc*9)*uhcgen downto 1*uhcgen);
      sie11_pb_data     : out std_logic_vector((n_cc*32)*uhcgen downto 1*uhcgen);
      sie11_pb_en       : out std_logic_vector(n_cc*uhcgen downto 1*uhcgen);
      sie11_pb_we       : out std_logic_vector(n_cc*uhcgen downto 1*uhcgen);
      pb_sie11_data     : in  std_logic_vector((n_cc*32)*uhcgen downto 1*uhcgen);
      mbc11_pb_addr     : out std_logic_vector((n_cc*9)*uhcgen downto 1*uhcgen);
      mbc11_pb_data     : out std_logic_vector((n_cc*32)*uhcgen downto 1*uhcgen);
      mbc11_pb_en       : out std_logic_vector(n_cc*uhcgen downto 1*uhcgen);
      mbc11_pb_we       : out std_logic_vector(n_cc*uhcgen downto 1*uhcgen);
      pb_mbc11_data     : in  std_logic_vector((n_cc*32)*uhcgen downto 1*uhcgen);
      bufsel            : out std_ulogic);
  end component;
  
  component grusbhc_axcelerator is
    generic (
      nports      : integer range 1 to 15 := 1;
      ehcgen      : integer range 0 to 1 := 1;
      uhcgen      : integer range 0 to 1 := 1;
      n_cc        : integer range 1 to 15 := 1;
      n_pcc       : integer range 1 to 15 := 1;
      prr         : integer range 0 to 1 := 0;
      portroute1  : integer := 0;
      portroute2  : integer := 0;
      endian_conv : integer range 0 to 1 := 1;
      be_regs     : integer range 0 to 1 := 0;
      be_desc     : integer range 0 to 1 := 0;
      uhcblo      : integer range 0 to 255 := 2;
      bwrd        : integer range 1 to 256 := 16;
      utm_type    : integer range 0 to 2 := 2;
      vbusconf    : integer range 0 to 3 := 3;
      ramtest     : integer range 0 to 1 := 0;
      urst_time   : integer := 250;
      oepol       : integer range 0 to 1 := 0;
      scantest    : integer := 0;
      memtech     : integer range 0 to NTECH := DEFMEMTECH
    );
    port (
      clk               : in  std_ulogic;
      uclk              : in  std_ulogic;
      rst               : in  std_ulogic;
      ursti             : in  std_ulogic;
      -- EHC apb_slv_in_type unwrapped
      ehc_apbsi_psel    : in  std_ulogic;
      ehc_apbsi_penable : in  std_ulogic;
      ehc_apbsi_paddr   : in  std_logic_vector(31 downto 0);
      ehc_apbsi_pwrite  : in  std_ulogic;
      ehc_apbsi_pwdata  : in  std_logic_vector(31 downto 0);
      ehc_apbsi_testen  : in  std_ulogic;
      ehc_apbsi_testrst : in  std_ulogic;
      ehc_apbsi_scanen  : in  std_ulogic;
      -- EHC apb_slv_out_type unwrapped
      ehc_apbso_prdata  : out std_logic_vector(31 downto 0);
      ehc_apbso_pirq    : out std_ulogic;
      -- EHC/UHC ahb_mst_in_type unwrapped
      ahbmi_hgrant      : in  std_logic_vector(n_cc*uhcgen downto 0);
      ahbmi_hready      : in  std_ulogic;
      ahbmi_hresp       : in  std_logic_vector(1 downto 0);
      ahbmi_hrdata      : in  std_logic_vector(31 downto 0);
      ahbmi_hcache      : in  std_ulogic;
      ahbmi_testen      : in  std_ulogic;
      ahbmi_testrst     : in  std_ulogic;
      ahbmi_scanen      : in  std_ulogic;
      -- UHC ahb_slv_in_type unwrapped
      uhc_ahbsi_hsel    : in  std_logic_vector(n_cc*uhcgen downto 1*uhcgen);
      uhc_ahbsi_haddr   : in  std_logic_vector(31 downto 0);
      uhc_ahbsi_hwrite  : in  std_ulogic;
      uhc_ahbsi_htrans  : in  std_logic_vector(1 downto 0);
      uhc_ahbsi_hsize   : in  std_logic_vector(2 downto 0);
      uhc_ahbsi_hwdata  : in  std_logic_vector(31 downto 0);
      uhc_ahbsi_hready  : in  std_ulogic;
      uhc_ahbsi_testen  : in  std_ulogic;
      uhc_ahbsi_testrst : in  std_ulogic;
      uhc_ahbsi_scanen  : in  std_ulogic;
      -- EHC ahb_mst_out_type_unwrapped 
      ehc_ahbmo_hbusreq : out std_ulogic;
      ehc_ahbmo_hlock   : out std_ulogic;
      ehc_ahbmo_htrans  : out std_logic_vector(1 downto 0);
      ehc_ahbmo_haddr   : out std_logic_vector(31 downto 0);
      ehc_ahbmo_hwrite  : out std_ulogic;
      ehc_ahbmo_hsize   : out std_logic_vector(2 downto 0);
      ehc_ahbmo_hburst  : out std_logic_vector(2 downto 0);
      ehc_ahbmo_hprot   : out std_logic_vector(3 downto 0);
      ehc_ahbmo_hwdata  : out std_logic_vector(31 downto 0);
      -- UHC ahb_mst_out_vector_type unwrapped
      uhc_ahbmo_hbusreq : out std_logic_vector(n_cc*uhcgen downto 1*uhcgen);
      uhc_ahbmo_hlock   : out std_logic_vector(n_cc*uhcgen downto 1*uhcgen);
      uhc_ahbmo_htrans  : out std_logic_vector((n_cc*2)*uhcgen downto 1*uhcgen);
      uhc_ahbmo_haddr   : out std_logic_vector((n_cc*32)*uhcgen downto 1*uhcgen);
      uhc_ahbmo_hwrite  : out std_logic_vector(n_cc*uhcgen downto 1*uhcgen);
      uhc_ahbmo_hsize   : out std_logic_vector((n_cc*3)*uhcgen downto 1*uhcgen);
      uhc_ahbmo_hburst  : out std_logic_vector((n_cc*3)*uhcgen downto 1*uhcgen);
      uhc_ahbmo_hprot   : out std_logic_vector((n_cc*4)*uhcgen downto 1*uhcgen);
      uhc_ahbmo_hwdata  : out std_logic_vector((n_cc*32)*uhcgen downto 1*uhcgen);
      -- UHC ahb_slv_out_vector_type unwrapped
      uhc_ahbso_hready  : out std_logic_vector(n_cc*uhcgen downto 1*uhcgen);
      uhc_ahbso_hresp   : out std_logic_vector((n_cc*2)*uhcgen downto 1*uhcgen);
      uhc_ahbso_hrdata  : out std_logic_vector((n_cc*32)*uhcgen downto 1*uhcgen);
      uhc_ahbso_hsplit  : out std_logic_vector((n_cc*16)*uhcgen downto 1*uhcgen);
      uhc_ahbso_hcache  : out std_logic_vector(n_cc*uhcgen downto 1*uhcgen);
      uhc_ahbso_hirq    : out std_logic_vector(n_cc*uhcgen downto 1*uhcgen);
      -- grusb_out_type_vector unwrapped
      xcvrsel           : out std_logic_vector(((nports*2)-1) downto 0);
      termsel           : out std_logic_vector((nports-1) downto 0);
      opmode            : out std_logic_vector(((nports*2)-1) downto 0);
      txvalid           : out std_logic_vector((nports-1) downto 0);
      drvvbus           : out std_logic_vector((nports-1) downto 0);
      dataho            : out std_logic_vector(((nports*8)-1) downto 0);
      validho           : out std_logic_vector((nports-1) downto 0);
      stp               : out std_logic_vector((nports-1) downto 0);
      datao             : out std_logic_vector(((nports*8)-1) downto 0);
      utm_rst           : out std_logic_vector((nports-1) downto 0);
      dctrlo            : out std_logic_vector((nports-1) downto 0);
      suspendm          : out std_ulogic;
      dbus16_8          : out std_ulogic;
      dppulldown        : out std_ulogic;
      dmpulldown        : out std_ulogic;
      idpullup          : out std_ulogic;
      dischrgvbus       : out std_ulogic;
      chrgvbus          : out std_ulogic;
      txbitstuffenable  : out std_ulogic;
      txbitstuffenableh : out std_ulogic;
      fslsserialmode    : out std_ulogic;
      txenablen         : out std_ulogic;
      txdat             : out std_ulogic;
      txse0             : out std_ulogic;
      -- grusb_in_type_vector unwrapped
      linestate         : in  std_logic_vector(((nports*2)-1) downto 0);
      txready           : in  std_logic_vector((nports-1) downto 0);
      rxvalid           : in  std_logic_vector((nports-1) downto 0);
      rxactive          : in  std_logic_vector((nports-1) downto 0);
      rxerror           : in  std_logic_vector((nports-1) downto 0);
      vbusvalid         : in  std_logic_vector((nports-1) downto 0);
      datahi            : in  std_logic_vector(((nports*8)-1) downto 0);
      validhi           : in  std_logic_vector((nports-1) downto 0);
      hostdisc          : in  std_logic_vector((nports-1) downto 0);
      nxt               : in  std_logic_vector((nports-1) downto 0);
      dir               : in  std_logic_vector((nports-1) downto 0);
      datai             : in  std_logic_vector(((nports*8)-1) downto 0);
      -- EHC transaction buffer signals
      mbc20_tb_addr     : out std_logic_vector(8 downto 0);
      mbc20_tb_data     : out std_logic_vector(31 downto 0);
      mbc20_tb_en       : out std_ulogic;
      mbc20_tb_wel      : out std_ulogic;
      mbc20_tb_weh      : out std_ulogic;
      tb_mbc20_data     : in  std_logic_vector(31 downto 0);
      pe20_tb_addr      : out std_logic_vector(8 downto 0);
      pe20_tb_data      : out std_logic_vector(31 downto 0);
      pe20_tb_en        : out std_ulogic;
      pe20_tb_wel       : out std_ulogic;
      pe20_tb_weh       : out std_ulogic;
      tb_pe20_data      : in  std_logic_vector(31 downto 0);
      -- EHC packet buffer signals
      mbc20_pb_addr     : out std_logic_vector(8 downto 0);
      mbc20_pb_data     : out std_logic_vector(31 downto 0);
      mbc20_pb_en       : out std_ulogic;
      mbc20_pb_we       : out std_ulogic;
      pb_mbc20_data     : in  std_logic_vector(31 downto 0);
      sie20_pb_addr     : out std_logic_vector(8 downto 0);
      sie20_pb_data     : out std_logic_vector(31 downto 0);
      sie20_pb_en       : out std_ulogic;
      sie20_pb_we       : out std_ulogic;
      pb_sie20_data     : in  std_logic_vector(31 downto 0);
      -- UHC packet buffer signals
      sie11_pb_addr     : out std_logic_vector((n_cc*9)*uhcgen downto 1*uhcgen);
      sie11_pb_data     : out std_logic_vector((n_cc*32)*uhcgen downto 1*uhcgen);
      sie11_pb_en       : out std_logic_vector(n_cc*uhcgen downto 1*uhcgen);
      sie11_pb_we       : out std_logic_vector(n_cc*uhcgen downto 1*uhcgen);
      pb_sie11_data     : in  std_logic_vector((n_cc*32)*uhcgen downto 1*uhcgen);
      mbc11_pb_addr     : out std_logic_vector((n_cc*9)*uhcgen downto 1*uhcgen);
      mbc11_pb_data     : out std_logic_vector((n_cc*32)*uhcgen downto 1*uhcgen);
      mbc11_pb_en       : out std_logic_vector(n_cc*uhcgen downto 1*uhcgen);
      mbc11_pb_we       : out std_logic_vector(n_cc*uhcgen downto 1*uhcgen);
      pb_mbc11_data     : in  std_logic_vector((n_cc*32)*uhcgen downto 1*uhcgen);
      bufsel            : out std_ulogic);
  end component;
                          
begin

  xil : if (tech = virtex2) or (tech = virtex4) or (tech = virtex5) or
	(tech = spartan3) or (tech = spartan3e) generate
    usbhc0 : grusbhc_unisim
      generic map(
        nports      => nports,
        ehcgen      => ehcgen,
        uhcgen      => uhcgen,
        n_cc        => n_cc,
        n_pcc       => n_pcc,
        prr         => prr,
        portroute1  => portroute1,
        portroute2  => portroute2,
        endian_conv => endian_conv,
        be_regs     => be_regs,
        be_desc     => be_desc,
        uhcblo      => uhcblo,
        bwrd        => bwrd,
        utm_type    => utm_type,
        vbusconf    => vbusconf,
        ramtest     => ramtest,
        urst_time   => urst_time,
        oepol       => oepol,
        scantest    => scantest,
        memtech     => memtech)
      port map(
        clk               => clk,
        uclk              => uclk,
        rst               => rst,
        ursti             => ursti,
        -- EHC apb_slv_in_type unwrapped
        ehc_apbsi_psel    => ehc_apbsi_psel,
        ehc_apbsi_penable => ehc_apbsi_penable,
        ehc_apbsi_paddr   => ehc_apbsi_paddr,
        ehc_apbsi_pwrite  => ehc_apbsi_pwrite,
        ehc_apbsi_pwdata  => ehc_apbsi_pwdata,
        ehc_apbsi_testen  => ehc_apbsi_testen,
        ehc_apbsi_testrst => ehc_apbsi_testrst,
        ehc_apbsi_scanen  => ehc_apbsi_scanen,
        -- EHC apb_slv_out_type unwrapped
        ehc_apbso_prdata  => ehc_apbso_prdata,
        ehc_apbso_pirq    => ehc_apbso_pirq,
        -- EHC/UHC ahb_mst_in_type unwrapped
        ahbmi_hgrant      => ahbmi_hgrant,
        ahbmi_hready      => ahbmi_hready,
        ahbmi_hresp       => ahbmi_hresp,
        ahbmi_hrdata      => ahbmi_hrdata,
        ahbmi_hcache      => ahbmi_hcache,
        ahbmi_testen      => ahbmi_testen,
        ahbmi_testrst     => ahbmi_testrst,
        ahbmi_scanen      => ahbmi_scanen,
        -- UHC ahb_slv_in_type unwrapped
        uhc_ahbsi_hsel    => uhc_ahbsi_hsel,
        uhc_ahbsi_haddr   => uhc_ahbsi_haddr,
        uhc_ahbsi_hwrite  => uhc_ahbsi_hwrite,
        uhc_ahbsi_htrans  => uhc_ahbsi_htrans,
        uhc_ahbsi_hsize   => uhc_ahbsi_hsize,
        uhc_ahbsi_hwdata  => uhc_ahbsi_hwdata,
        uhc_ahbsi_hready  => uhc_ahbsi_hready,
        uhc_ahbsi_testen  => uhc_ahbsi_testen,
        uhc_ahbsi_testrst => uhc_ahbsi_testrst,
        uhc_ahbsi_scanen  => uhc_ahbsi_scanen,
        -- EHC ahb_mst_out_type_unwrapped 
        ehc_ahbmo_hbusreq => ehc_ahbmo_hbusreq,
        ehc_ahbmo_hlock   => ehc_ahbmo_hlock,
        ehc_ahbmo_htrans  => ehc_ahbmo_htrans,
        ehc_ahbmo_haddr   => ehc_ahbmo_haddr,
        ehc_ahbmo_hwrite  => ehc_ahbmo_hwrite,
        ehc_ahbmo_hsize   => ehc_ahbmo_hsize,
        ehc_ahbmo_hburst  => ehc_ahbmo_hburst,
        ehc_ahbmo_hprot   => ehc_ahbmo_hprot,
        ehc_ahbmo_hwdata  => ehc_ahbmo_hwdata,
        -- UHC ahb_mst_out_vector_type unwrapped
        uhc_ahbmo_hbusreq => uhc_ahbmo_hbusreq,
        uhc_ahbmo_hlock   => uhc_ahbmo_hlock,
        uhc_ahbmo_htrans  => uhc_ahbmo_htrans,
        uhc_ahbmo_haddr   => uhc_ahbmo_haddr,
        uhc_ahbmo_hwrite  => uhc_ahbmo_hwrite,
        uhc_ahbmo_hsize   => uhc_ahbmo_hsize,
        uhc_ahbmo_hburst  => uhc_ahbmo_hburst,
        uhc_ahbmo_hprot   => uhc_ahbmo_hprot,
        uhc_ahbmo_hwdata  => uhc_ahbmo_hwdata,
        -- UHC ahb_slv_out_vector_type unwrapped 
        uhc_ahbso_hready  => uhc_ahbso_hready,
        uhc_ahbso_hresp   => uhc_ahbso_hresp,
        uhc_ahbso_hrdata  => uhc_ahbso_hrdata,
        uhc_ahbso_hsplit  => uhc_ahbso_hsplit,
        uhc_ahbso_hcache  => uhc_ahbso_hcache,
        uhc_ahbso_hirq    => uhc_ahbso_hirq,
        -- grusb_out_type_vector unwrapped
        xcvrsel           => xcvrsel,
        termsel           => termsel,
        opmode            => opmode,
        txvalid           => txvalid,
        drvvbus           => drvvbus,
        dataho            => dataho,
        validho           => validho,
        stp               => stp,
        datao             => datao,
        utm_rst           => utm_rst,
        dctrlo            => dctrlo,
        suspendm          => suspendm,
        dbus16_8          => dbus16_8,
        dppulldown        => dppulldown,
        dmpulldown        => dmpulldown,
        idpullup          => idpullup,
        dischrgvbus       => dischrgvbus,
        chrgvbus          => chrgvbus,
        txbitstuffenable  => txbitstuffenable,
        txbitstuffenableh => txbitstuffenableh,
        fslsserialmode    => fslsserialmode,
        txenablen         => txenablen,
        txdat             => txdat,
        txse0             => txse0,
        -- grusb_in_type_vector unwrapped
        linestate         => linestate,
        txready           => txready,
        rxvalid           => rxvalid,
        rxactive          => rxactive,
        rxerror           => rxerror,
        vbusvalid         => vbusvalid,
        datahi            => datahi,
        validhi           => validhi,
        hostdisc          => hostdisc,
        nxt               => nxt,
        dir               => dir,
        datai             => datai,
        -- EHC transaction buffer signals
        mbc20_tb_addr     => mbc20_tb_addr,
        mbc20_tb_data     => mbc20_tb_data,
        mbc20_tb_en       => mbc20_tb_en,
        mbc20_tb_wel      => mbc20_tb_wel,
        mbc20_tb_weh      => mbc20_tb_weh,
        tb_mbc20_data     => tb_mbc20_data,
        pe20_tb_addr      => pe20_tb_addr,
        pe20_tb_data      => pe20_tb_data,
        pe20_tb_en        => pe20_tb_en,
        pe20_tb_wel       => pe20_tb_wel,
        pe20_tb_weh       => pe20_tb_weh,
        tb_pe20_data      => tb_pe20_data,
        -- EHC packet buffer signals
        mbc20_pb_addr     => mbc20_pb_addr,
        mbc20_pb_data     => mbc20_pb_data,
        mbc20_pb_en       => mbc20_pb_en,
        mbc20_pb_we       => mbc20_pb_we,
        pb_mbc20_data     => pb_mbc20_data,
        sie20_pb_addr     => sie20_pb_addr,
        sie20_pb_data     => sie20_pb_data,
        sie20_pb_en       => sie20_pb_en,
        sie20_pb_we       => sie20_pb_we,
        pb_sie20_data     => pb_sie20_data,
        -- UHC packet buffer signals
        sie11_pb_addr     => sie11_pb_addr,
        sie11_pb_data     => sie11_pb_data,
        sie11_pb_en       => sie11_pb_en,
        sie11_pb_we       => sie11_pb_we,
        pb_sie11_data     => pb_sie11_data,
        mbc11_pb_addr     => mbc11_pb_addr,
        mbc11_pb_data     => mbc11_pb_data,
        mbc11_pb_en       => mbc11_pb_en,
        mbc11_pb_we       => mbc11_pb_we,
        pb_mbc11_data     => pb_mbc11_data,
        bufsel            => bufsel);
  end generate;

  alt : if (tech = altera) or (tech = stratix1) or (tech = stratix2) or
	(tech = stratix3) or (tech = cyclone3) generate
    usbhc0 : grusbhc_stratixii
      generic map(
        nports      => nports,
        ehcgen      => ehcgen,
        uhcgen      => uhcgen,
        n_cc        => n_cc,
        n_pcc       => n_pcc,
        prr         => prr,
        portroute1  => portroute1,
        portroute2  => portroute2,
        endian_conv => endian_conv,
        be_regs     => be_regs,
        be_desc     => be_desc,
        uhcblo      => uhcblo,
        bwrd        => bwrd,
        utm_type    => utm_type,
        vbusconf    => vbusconf,
        ramtest     => ramtest,
        urst_time   => urst_time,
        oepol       => oepol,
        scantest    => scantest,
        memtech     => memtech)
      port map(
        clk               => clk,
        uclk              => uclk,
        rst               => rst,
        ursti             => ursti,
        -- EHC apb_slv_in_type unwrapped
        ehc_apbsi_psel    => ehc_apbsi_psel,
        ehc_apbsi_penable => ehc_apbsi_penable,
        ehc_apbsi_paddr   => ehc_apbsi_paddr,
        ehc_apbsi_pwrite  => ehc_apbsi_pwrite,
        ehc_apbsi_pwdata  => ehc_apbsi_pwdata,
        ehc_apbsi_testen  => ehc_apbsi_testen,
        ehc_apbsi_testrst => ehc_apbsi_testrst,
        ehc_apbsi_scanen  => ehc_apbsi_scanen,
        -- EHC apb_slv_out_type unwrapped
        ehc_apbso_prdata  => ehc_apbso_prdata,
        ehc_apbso_pirq    => ehc_apbso_pirq,
        -- EHC/UHC ahb_mst_in_type unwrapped
        ahbmi_hgrant      => ahbmi_hgrant,
        ahbmi_hready      => ahbmi_hready,
        ahbmi_hresp       => ahbmi_hresp,
        ahbmi_hrdata      => ahbmi_hrdata,
        ahbmi_hcache      => ahbmi_hcache,
        ahbmi_testen      => ahbmi_testen,
        ahbmi_testrst     => ahbmi_testrst,
        ahbmi_scanen      => ahbmi_scanen,
        -- UHC ahb_slv_in_type unwrapped
        uhc_ahbsi_hsel    => uhc_ahbsi_hsel,
        uhc_ahbsi_haddr   => uhc_ahbsi_haddr,
        uhc_ahbsi_hwrite  => uhc_ahbsi_hwrite,
        uhc_ahbsi_htrans  => uhc_ahbsi_htrans,
        uhc_ahbsi_hsize   => uhc_ahbsi_hsize,
        uhc_ahbsi_hwdata  => uhc_ahbsi_hwdata,
        uhc_ahbsi_hready  => uhc_ahbsi_hready,
        uhc_ahbsi_testen  => uhc_ahbsi_testen,
        uhc_ahbsi_testrst => uhc_ahbsi_testrst,
        uhc_ahbsi_scanen  => uhc_ahbsi_scanen,
        -- EHC ahb_mst_out_type_unwrapped 
        ehc_ahbmo_hbusreq => ehc_ahbmo_hbusreq,
        ehc_ahbmo_hlock   => ehc_ahbmo_hlock,
        ehc_ahbmo_htrans  => ehc_ahbmo_htrans,
        ehc_ahbmo_haddr   => ehc_ahbmo_haddr,
        ehc_ahbmo_hwrite  => ehc_ahbmo_hwrite,
        ehc_ahbmo_hsize   => ehc_ahbmo_hsize,
        ehc_ahbmo_hburst  => ehc_ahbmo_hburst,
        ehc_ahbmo_hprot   => ehc_ahbmo_hprot,
        ehc_ahbmo_hwdata  => ehc_ahbmo_hwdata,
        -- UHC ahb_mst_out_vector_type unwrapped
        uhc_ahbmo_hbusreq => uhc_ahbmo_hbusreq,
        uhc_ahbmo_hlock   => uhc_ahbmo_hlock,
        uhc_ahbmo_htrans  => uhc_ahbmo_htrans,
        uhc_ahbmo_haddr   => uhc_ahbmo_haddr,
        uhc_ahbmo_hwrite  => uhc_ahbmo_hwrite,
        uhc_ahbmo_hsize   => uhc_ahbmo_hsize,
        uhc_ahbmo_hburst  => uhc_ahbmo_hburst,
        uhc_ahbmo_hprot   => uhc_ahbmo_hprot,
        uhc_ahbmo_hwdata  => uhc_ahbmo_hwdata,
        -- UHC ahb_slv_out_vector_type unwrapped 
        uhc_ahbso_hready  => uhc_ahbso_hready,
        uhc_ahbso_hresp   => uhc_ahbso_hresp,
        uhc_ahbso_hrdata  => uhc_ahbso_hrdata,
        uhc_ahbso_hsplit  => uhc_ahbso_hsplit,
        uhc_ahbso_hcache  => uhc_ahbso_hcache,
        uhc_ahbso_hirq    => uhc_ahbso_hirq,
        -- grusb_out_type_vector unwrapped
        xcvrsel           => xcvrsel,
        termsel           => termsel,
        opmode            => opmode,
        txvalid           => txvalid,
        drvvbus           => drvvbus,
        dataho            => dataho,
        validho           => validho,
        stp               => stp,
        datao             => datao,
        utm_rst           => utm_rst,
        dctrlo            => dctrlo,
        suspendm          => suspendm,
        dbus16_8          => dbus16_8,
        dppulldown        => dppulldown,
        dmpulldown        => dmpulldown,
        idpullup          => idpullup,
        dischrgvbus       => dischrgvbus,
        chrgvbus          => chrgvbus,
        txbitstuffenable  => txbitstuffenable,
        txbitstuffenableh => txbitstuffenableh,
        fslsserialmode    => fslsserialmode,
        txenablen         => txenablen,
        txdat             => txdat,
        txse0             => txse0,
        -- grusb_in_type_vector unwrapped
        linestate         => linestate,
        txready           => txready,
        rxvalid           => rxvalid,
        rxactive          => rxactive,
        rxerror           => rxerror,
        vbusvalid         => vbusvalid,
        datahi            => datahi,
        validhi           => validhi,
        hostdisc          => hostdisc,
        nxt               => nxt,
        dir               => dir,
        datai             => datai,
        -- EHC transaction buffer signals
        mbc20_tb_addr     => mbc20_tb_addr,
        mbc20_tb_data     => mbc20_tb_data,
        mbc20_tb_en       => mbc20_tb_en,
        mbc20_tb_wel      => mbc20_tb_wel,
        mbc20_tb_weh      => mbc20_tb_weh,
        tb_mbc20_data     => tb_mbc20_data,
        pe20_tb_addr      => pe20_tb_addr,
        pe20_tb_data      => pe20_tb_data,
        pe20_tb_en        => pe20_tb_en,
        pe20_tb_wel       => pe20_tb_wel,
        pe20_tb_weh       => pe20_tb_weh,
        tb_pe20_data      => tb_pe20_data,
        -- EHC packet buffer signals
        mbc20_pb_addr     => mbc20_pb_addr,
        mbc20_pb_data     => mbc20_pb_data,
        mbc20_pb_en       => mbc20_pb_en,
        mbc20_pb_we       => mbc20_pb_we,
        pb_mbc20_data     => pb_mbc20_data,
        sie20_pb_addr     => sie20_pb_addr,
        sie20_pb_data     => sie20_pb_data,
        sie20_pb_en       => sie20_pb_en,
        sie20_pb_we       => sie20_pb_we,
        pb_sie20_data     => pb_sie20_data,
        -- UHC packet buffer signals
        sie11_pb_addr     => sie11_pb_addr,
        sie11_pb_data     => sie11_pb_data,
        sie11_pb_en       => sie11_pb_en,
        sie11_pb_we       => sie11_pb_we,
        pb_sie11_data     => pb_sie11_data,
        mbc11_pb_addr     => mbc11_pb_addr,
        mbc11_pb_data     => mbc11_pb_data,
        mbc11_pb_en       => mbc11_pb_en,
        mbc11_pb_we       => mbc11_pb_we,
        pb_mbc11_data     => pb_mbc11_data,
        bufsel            => bufsel);
  end generate;
  
  ax : if tech = axcel generate
    usbhc0 : grusbhc_axcelerator
      generic map(
        nports      => nports,
        ehcgen      => ehcgen,
        uhcgen      => uhcgen,
        n_cc        => n_cc,
        n_pcc       => n_pcc,
        prr         => prr,
        portroute1  => portroute1,
        portroute2  => portroute2,
        endian_conv => endian_conv,
        be_regs     => be_regs,
        be_desc     => be_desc,
        uhcblo      => uhcblo,
        bwrd        => bwrd,
        utm_type    => utm_type,
        vbusconf    => vbusconf,
        ramtest     => ramtest,
        urst_time   => urst_time,
        oepol       => oepol,
        scantest    => scantest,
        memtech     => memtech)
      port map(
        clk               => clk,
        uclk              => uclk,
        rst               => rst,
        ursti             => ursti,
        -- EHC apb_slv_in_type unwrapped
        ehc_apbsi_psel    => ehc_apbsi_psel,
        ehc_apbsi_penable => ehc_apbsi_penable,
        ehc_apbsi_paddr   => ehc_apbsi_paddr,
        ehc_apbsi_pwrite  => ehc_apbsi_pwrite,
        ehc_apbsi_pwdata  => ehc_apbsi_pwdata,
        ehc_apbsi_testen  => ehc_apbsi_testen,
        ehc_apbsi_testrst => ehc_apbsi_testrst,
        ehc_apbsi_scanen  => ehc_apbsi_scanen,
        -- EHC apb_slv_out_type unwrapped
        ehc_apbso_prdata  => ehc_apbso_prdata,
        ehc_apbso_pirq    => ehc_apbso_pirq,
        -- EHC/UHC ahb_mst_in_type unwrapped
        ahbmi_hgrant      => ahbmi_hgrant,
        ahbmi_hready      => ahbmi_hready,
        ahbmi_hresp       => ahbmi_hresp,
        ahbmi_hrdata      => ahbmi_hrdata,
        ahbmi_hcache      => ahbmi_hcache,
        ahbmi_testen      => ahbmi_testen,
        ahbmi_testrst     => ahbmi_testrst,
        ahbmi_scanen      => ahbmi_scanen,
        -- UHC ahb_slv_in_type unwrapped
        uhc_ahbsi_hsel    => uhc_ahbsi_hsel,
        uhc_ahbsi_haddr   => uhc_ahbsi_haddr,
        uhc_ahbsi_hwrite  => uhc_ahbsi_hwrite,
        uhc_ahbsi_htrans  => uhc_ahbsi_htrans,
        uhc_ahbsi_hsize   => uhc_ahbsi_hsize,
        uhc_ahbsi_hwdata  => uhc_ahbsi_hwdata,
        uhc_ahbsi_hready  => uhc_ahbsi_hready,
        uhc_ahbsi_testen  => uhc_ahbsi_testen,
        uhc_ahbsi_testrst => uhc_ahbsi_testrst,
        uhc_ahbsi_scanen  => uhc_ahbsi_scanen,
        -- EHC ahb_mst_out_type_unwrapped 
        ehc_ahbmo_hbusreq => ehc_ahbmo_hbusreq,
        ehc_ahbmo_hlock   => ehc_ahbmo_hlock,
        ehc_ahbmo_htrans  => ehc_ahbmo_htrans,
        ehc_ahbmo_haddr   => ehc_ahbmo_haddr,
        ehc_ahbmo_hwrite  => ehc_ahbmo_hwrite,
        ehc_ahbmo_hsize   => ehc_ahbmo_hsize,
        ehc_ahbmo_hburst  => ehc_ahbmo_hburst,
        ehc_ahbmo_hprot   => ehc_ahbmo_hprot,
        ehc_ahbmo_hwdata  => ehc_ahbmo_hwdata,
        -- UHC ahb_mst_out_vector_type unwrapped
        uhc_ahbmo_hbusreq => uhc_ahbmo_hbusreq,
        uhc_ahbmo_hlock   => uhc_ahbmo_hlock,
        uhc_ahbmo_htrans  => uhc_ahbmo_htrans,
        uhc_ahbmo_haddr   => uhc_ahbmo_haddr,
        uhc_ahbmo_hwrite  => uhc_ahbmo_hwrite,
        uhc_ahbmo_hsize   => uhc_ahbmo_hsize,
        uhc_ahbmo_hburst  => uhc_ahbmo_hburst,
        uhc_ahbmo_hprot   => uhc_ahbmo_hprot,
        uhc_ahbmo_hwdata  => uhc_ahbmo_hwdata,
        -- UHC ahb_slv_out_vector_type unwrapped 
        uhc_ahbso_hready  => uhc_ahbso_hready,
        uhc_ahbso_hresp   => uhc_ahbso_hresp,
        uhc_ahbso_hrdata  => uhc_ahbso_hrdata,
        uhc_ahbso_hsplit  => uhc_ahbso_hsplit,
        uhc_ahbso_hcache  => uhc_ahbso_hcache,
        uhc_ahbso_hirq    => uhc_ahbso_hirq,
        -- grusb_out_type_vector unwrapped
        xcvrsel           => xcvrsel,
        termsel           => termsel,
        opmode            => opmode,
        txvalid           => txvalid,
        drvvbus           => drvvbus,
        dataho            => dataho,
        validho           => validho,
        stp               => stp,
        datao             => datao,
        utm_rst           => utm_rst,
        dctrlo            => dctrlo,
        suspendm          => suspendm,
        dbus16_8          => dbus16_8,
        dppulldown        => dppulldown,
        dmpulldown        => dmpulldown,
        idpullup          => idpullup,
        dischrgvbus       => dischrgvbus,
        chrgvbus          => chrgvbus,
        txbitstuffenable  => txbitstuffenable,
        txbitstuffenableh => txbitstuffenableh,
        fslsserialmode    => fslsserialmode,
        txenablen         => txenablen,
        txdat             => txdat,
        txse0             => txse0,
        -- grusb_in_type_vector unwrapped
        linestate         => linestate,
        txready           => txready,
        rxvalid           => rxvalid,
        rxactive          => rxactive,
        rxerror           => rxerror,
        vbusvalid         => vbusvalid,
        datahi            => datahi,
        validhi           => validhi,
        hostdisc          => hostdisc,
        nxt               => nxt,
        dir               => dir,
        datai             => datai,
        -- EHC transaction buffer signals
        mbc20_tb_addr     => mbc20_tb_addr,
        mbc20_tb_data     => mbc20_tb_data,
        mbc20_tb_en       => mbc20_tb_en,
        mbc20_tb_wel      => mbc20_tb_wel,
        mbc20_tb_weh      => mbc20_tb_weh,
        tb_mbc20_data     => tb_mbc20_data,
        pe20_tb_addr      => pe20_tb_addr,
        pe20_tb_data      => pe20_tb_data,
        pe20_tb_en        => pe20_tb_en,
        pe20_tb_wel       => pe20_tb_wel,
        pe20_tb_weh       => pe20_tb_weh,
        tb_pe20_data      => tb_pe20_data,
        -- EHC packet buffer signals
        mbc20_pb_addr     => mbc20_pb_addr,
        mbc20_pb_data     => mbc20_pb_data,
        mbc20_pb_en       => mbc20_pb_en,
        mbc20_pb_we       => mbc20_pb_we,
        pb_mbc20_data     => pb_mbc20_data,
        sie20_pb_addr     => sie20_pb_addr,
        sie20_pb_data     => sie20_pb_data,
        sie20_pb_en       => sie20_pb_en,
        sie20_pb_we       => sie20_pb_we,
        pb_sie20_data     => pb_sie20_data,
        -- UHC packet buffer signals
        sie11_pb_addr     => sie11_pb_addr,
        sie11_pb_data     => sie11_pb_data,
        sie11_pb_en       => sie11_pb_en,
        sie11_pb_we       => sie11_pb_we,
        pb_sie11_data     => pb_sie11_data,
        mbc11_pb_addr     => mbc11_pb_addr,
        mbc11_pb_data     => mbc11_pb_data,
        mbc11_pb_en       => mbc11_pb_en,
        mbc11_pb_we       => mbc11_pb_we,
        pb_mbc11_data     => pb_mbc11_data,
        bufsel            => bufsel);
  end generate;

  -- pragma translate_off
  nonet : if not ((tech = virtex2) or (tech = virtex4) or (tech = virtex5) or
                  (tech = spartan3) or (tech = spartan3e) or (tech = axcel) or
                  (tech = stratix3) or (tech = cyclone3) or
                  (tech = stratix1) or (tech = stratix2) or (tech = altera)) generate
    err : process 
    begin
      assert false report "ERROR : No GRUSBHC netlist available for this process!"
        severity failure;
      wait;
    end process;
  end generate;
  -- pragma translate_on

  
end rtl;
