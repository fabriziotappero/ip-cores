----------------------------------------------------------------------------
--  This file is a part of the GRLIB VHDL IP LIBRARY
--  Copyright (C) 2004 GAISLER RESEARCH
--
--  This program is free software; you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation; either version 2 of the License, or
--  (at your option) any later version.
--
--  See the file COPYING for the full details of the license.
--
-----------------------------------------------------------------------------   
-- Entity:      ac97_oc
-- File:        ac97_oc.vhd
-- Author:      Thomas Ameseder, Gleichmann Electronics
-- Description: AHB interface for the OpenCores AC97 controller
------------------------------------------------------------------------------ 

library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
library grlib;
use grlib.amba.all;
use grlib.stdlib.all;
use grlib.devices.all;


library gleichmann;
use gleichmann.ac97.all;
use gleichmann.miscellaneous.all;

library opencores;
use opencores.occomp.all;

entity ac97_oc is
  generic (
    slvndx : integer := 0;
    ioaddr : integer := 16#000#;
    iomask : integer := 16#FF0#;
    irq    : integer := 7);
  port (
    resetn : in  std_logic;
    clk    : in  std_logic;
    ahbsi  : in  ahb_slv_in_type;
    ahbso  : out ahb_slv_out_type;

    -- AC97 codec signals
    bit_clk_pad_i     : in  std_logic;
    sync_pad_o        : out std_logic;
    sdata_pad_o       : out std_logic;
    sdata_pad_i       : in  std_logic;
    ac97_reset_padn_o : out std_logic;

    -- misc signals
    int_o       : out std_logic;
    dma_req_o   : out std_logic_vector(8 downto 0);
    dma_ack_i   : in  std_logic_vector(8 downto 0);
    suspended_o : out std_logic;

    int_pol : in std_logic

    );
end ac97_oc;


architecture rtl of ac97_oc is

  constant REVISION : amba_version_type := 0;

  constant hconfig : ahb_config_type := (
    0      => ahb_device_reg (VENDOR_GLEICHMANN, GLEICHMANN_AC97 , 0, REVISION, irq),
    4      => ahb_iobar (ioaddr, iomask),
    others => zero32);

--      // AHB interface
--      // AHB common
  signal hwdata : std_logic_vector(31 downto 0);
  signal hrdata : std_logic_vector(31 downto 0);

--     // AHB slave   
  signal haddr     : std_logic_vector(31 downto 0);
  signal hready_ba : std_logic;
  signal hsel      : std_logic;
  signal hresp     : std_logic_vector(1 downto 0);
  signal hwrite    : std_logic;
  signal hready    : std_logic;

--     // AHB Additional
  signal htrans : std_logic_vector(1 downto 0);
  signal hsize  : std_logic_vector(2 downto 0);
  signal hburst : std_logic_vector(2 downto 0);

  signal hmaster   : std_logic_vector(3 downto 0);
  signal hmastlock : std_logic;
  signal hsplit    : std_logic_vector(15 downto 0);

--     // Wishbone interface
--     // WISHBONE common  
  signal wbm_dat_i : std_logic_vector(31 downto 0);
  signal wbm_dat_o : std_logic_vector(31 downto 0);

--     // WISHBONE slave   
  signal wbm_adr_o : std_logic_vector(31 downto 0);
  signal wbm_cyc_o : std_logic;
  signal wbm_stb_o : std_logic;
  signal wbm_we_o  : std_logic;
  signal wbm_ack_i : std_logic;

--     // WISHBONE Additional
  signal wb_inta_i : std_logic;
  signal wbm_sel_o : std_logic_vector(3 downto 0);
  signal wbm_rty_i : std_logic;
  signal wbm_err_i : std_logic;

--     // miscellaneous signals
  signal irq_o    : std_logic;
  signal wb_reset : std_logic;

  -- delayed signals
  signal hsel_d      : std_logic;                      --
  signal hready_ba_d : std_logic;                      --
  signal hwrite_d    : std_logic;                      --
  signal hmastlock_d : std_logic;                      --
  signal haddr_d     : std_logic_vector(31 downto 0);  --
  signal htrans_d    : std_logic_vector(1 downto 0);   --
  signal hsize_d     : std_logic_vector(2 downto 0);   --
  signal hburst_d    : std_logic_vector(2 downto 0);   --
  signal hwdata_d    : std_logic_vector(31 downto 0);  --
  signal hmaster_d   : std_logic_vector(3 downto 0);   --

  -- delay AHB input signals at VHDL/Verilog domain boarder
  -- for simulation purposes only
  constant DELAY_AHB_INPUTS : integer := 0;

  signal irq_s : std_ulogic;
  signal irq_1t    : std_ulogic;
  signal irq_adapt : std_ulogic;        -- registered and converted to rising edge activity


begin

  delay_module : if DELAY_AHB_INPUTS /= 0 generate

    postponer_1 : postponer
      generic map (
        HAMAX => 32,
        HDMAX => 32,
        delta => 1)
      port map (
        hsel_d      => hsel_d,
        hready_ba_d => hready_ba_d,
        hwrite_d    => hwrite_d,
        hmastlock_d => hmastlock_d,
        haddr_d     => haddr_d,
        htrans_d    => htrans_d,
        hsize_d     => hsize_d,
        hburst_d    => hburst_d,
        hwdata_d    => hwdata_d,
        hmaster_d   => hmaster_d,
        hsel        => hsel,
        hready_ba   => hready_ba,
        hwrite      => hwrite,
        hmastlock   => hmastlock,
        haddr       => haddr,
        htrans      => htrans,
        hsize       => hsize,
        hburst      => hburst,
        hwdata      => hwdata,
        hmaster     => hmaster);


    bridge : ahb2wb
      generic map(HDMAX => 32, HAMAX => 32)
      port map (
--      // AHB common
        hclk      => clk,
        hresetn   => resetn,
        hwdata    => hwdata_d,
        hrdata    => hrdata,
--      // AHB slave
        haddr     => haddr_d,
        hready_ba => hready_ba_d,
        hsel      => hsel_d,
        hresp     => hresp,
        hwrite    => hwrite_d,
        hready    => hready,
--      // AHB Additional
        htrans    => htrans_d,
        hsize     => hsize_d,
        hburst    => hburst_d,
        hmaster   => hmaster_d,
        hmastlock => hmastlock_d,
        hsplit    => hsplit,
--      // WISHBONE common
        wbm_dat_i => wbm_dat_i,
        wbm_dat_o => wbm_dat_o,
--      // WISHBONE slave
        wbm_adr_o => wbm_adr_o,
        wbm_cyc_o => wbm_cyc_o,
        wbm_stb_o => wbm_stb_o,
        wbm_we_o  => wbm_we_o,
        wbm_ack_i => wbm_ack_i,
--      // WISHBONE Additional
        wb_inta_i => wb_inta_i,
        wbm_sel_o => wbm_sel_o,
        wbm_rty_i => wbm_rty_i,
        wbm_err_i => wbm_err_i,
--     // miscellaneous signals
        irq_o     => irq_o
        );

  end generate delay_module;

  no_delay_module : if DELAY_AHB_INPUTS = 0 generate

    bridge : ahb2wb
      generic map(HDMAX => 32, HAMAX => 32)
      port map (
--      // AHB common
        hclk      => clk,
        hresetn   => resetn,
        hwdata    => hwdata,
        hrdata    => hrdata,
--      // AHB slave
        haddr     => haddr,
        hready_ba => hready_ba,
        hsel      => hsel,
        hresp     => hresp,
        hwrite    => hwrite,
        hready    => hready,
--      // AHB Additional
        htrans    => htrans,
        hsize     => hsize,
        hburst    => hburst,
        hmaster   => hmaster,
        hmastlock => hmastlock,
        hsplit    => hsplit,
--      // WISHBONE common
        wbm_dat_i => wbm_dat_i,
        wbm_dat_o => wbm_dat_o,
--      // WISHBONE slave
        wbm_adr_o => wbm_adr_o,
        wbm_cyc_o => wbm_cyc_o,
        wbm_stb_o => wbm_stb_o,
        wbm_we_o  => wbm_we_o,
        wbm_ack_i => wbm_ack_i,
--      // WISHBONE Additional
        wb_inta_i => wb_inta_i,
        wbm_sel_o => wbm_sel_o,
        wbm_rty_i => wbm_rty_i,
        wbm_err_i => wbm_err_i,
--     // miscellaneous signals
        irq_o     => irq_o
        );

  end generate no_delay_module;


  ac97_top_1 : ac97_top
    port map (
      clk_i     => clk,
      rst_i     => wb_reset,
      wb_data_i => wbm_dat_o,
      wb_data_o => wbm_dat_i,
      wb_addr_i => wbm_adr_o,
      wb_sel_i  => wbm_sel_o,
      wb_we_i   => wbm_we_o,
      wb_cyc_i  => wbm_cyc_o,
      wb_stb_i  => wbm_stb_o,
      wb_ack_o  => wbm_ack_i,
      wb_err_o  => wbm_err_i,

      int_o       => irq_s,
      dma_req_o   => dma_req_o,
      dma_ack_i   => dma_ack_i,
      suspended_o => suspended_o,

      bit_clk_pad_i     => bit_clk_pad_i,
      sync_pad_o        => sync_pad_o,
      sdata_pad_o       => sdata_pad_o,
      sdata_pad_i       => sdata_pad_i,
      ac97_resetn_pad_o => ac97_reset_padn_o
      );

-- fill ahb slave-in vector
  hsel      <= ahbsi.HSEL(slvndx);
  hready_ba <= '1';                     --ahbsi.HREADY;
  haddr     <= ahbsi.HADDR;
  hwrite    <= ahbsi.HWRITE;
  htrans    <= ahbsi.HTRANS;
  hsize     <= ahbsi.HSIZE;
  hburst    <= ahbsi.HBURST;
  hwdata    <= ahbsi.HWDATA;            --(7 downto 0);
  hmaster   <= ahbsi.HMASTER;
  hmastlock <= ahbsi.HMASTLOCK;


-- fill ahb slave-out vector
  ahbso.HREADY  <= hready;
  ahbso.HRESP   <= hresp;
  ahbso.HRDATA  <= hrdata;
  ahbso.HSPLIT  <= hsplit;              -- maybe better way (others => '0');
  ahbso.HCACHE  <= '0';
  ahbso.HCONFIG <= hconfig;
  ahbso.HINDEX  <= slvndx;

  -- drive device specific interrupt line,
  -- other bus signals are driven with '0'
  -- note: interrupt 15 should not be used,
  -- since it is not maskable
  drive_irq_high : if (IRQ /= 15) generate
    ahbso.HIRQ(15 downto IRQ+1) <= (others => '0');
  end generate drive_irq_high;
  drive_irq: ahbso.HIRQ(IRQ) <= irq_adapt when int_pol = '1' else
                                 not irq_adapt;
  drive_irq_low : if (IRQ > 0) generate
    ahbso.HIRQ(IRQ-1 downto 0) <= (others => '0');
  end generate;

  ---------------------------------------------------------------------------------------
  -- Synchronous process to convert the high level interrupt from the core to
  -- to an rising edge triggered interrupt to be suitable for the Leon IRQCTL
  --    asynchronous low active reset like the open core simple SPI module !!!
  ---------------------------------------------------------------------------------------
  irq_adaption: process (clk, resetn)  -- added by tame, 07-12-2006
  begin  -- process irq_adaption)
    if resetn = '0' then
      irq_adapt <= '0';
      irq_1t    <= '0';
    elsif clk'event and clk = '1' then
      irq_1t    <= irq_s;
      irq_adapt <= irq_s and not irq_1t;
    end if;
  end process irq_adaption;

  -- unmodified interrupt output
  int_o <= irq_s;

-- wbm_rty_i is not used
  wbm_rty_i <= '0';

-- bridge device IRQ unused
  wb_inta_i <= '0';

-- AC97 reset is active low
  wb_reset <= resetn;

-- pragma translate_off
  bootmsg : report_version
    generic map (
      "ac97_oc" & tost(slvndx) &
      ": Opencores AC97 controller, rev " & tost(REVISION) & ", irq " & tost(irq));
-- pragma translate_on

end;
