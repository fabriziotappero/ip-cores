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
-- Package: 	misc
-- File:	misc.vhd
-- Author:	Jiri Gaisler - Gaisler Research
-- Description:	Misc models
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library grlib;
use grlib.amba.all;
use grlib.devices.all;
use grlib.stdlib.all;
library techmap;
use techmap.gencomp.all;
library gaisler;

package misc is

-- reset generator with filter

  component rstgen
  generic (acthigh : integer := 0; syncrst : integer := 0;
	   scanen : integer := 0);
  port (
    rstin     : in  std_ulogic;
    clk       : in  std_ulogic;
    clklock   : in  std_ulogic;
    rstout    : out std_ulogic;
    rstoutraw : out std_ulogic;
    testrst   : in  std_ulogic := '0';
    testen    : in  std_ulogic := '0');
  end component;

  type gptimer_in_type is record
    dhalt    : std_ulogic;
    extclk   : std_ulogic;
  end record;

  type gptimer_out_type is record
    tick     : std_logic_vector(0 to 7);
    timer1   : std_logic_vector(31 downto 0);
    wdogn    : std_ulogic;
    wdog    : std_ulogic;
  end record;

  component gptimer
  generic (
    pindex   : integer := 0;
    paddr    : integer := 0;
    pmask    : integer := 16#fff#;
    pirq     : integer := 0;
    sepirq   : integer := 0;	-- use separate interrupts for each timer
    sbits    : integer := 16;			-- scaler bits
    ntimers  : integer range 1 to 7 := 1; 	-- number of timers
    nbits    : integer := 32;			-- timer bits
    wdog     : integer := 0
  );
  port (
    rst    : in  std_ulogic;
    clk    : in  std_ulogic;
    apbi   : in  apb_slv_in_type;
    apbo   : out apb_slv_out_type;
    gpti   : in gptimer_in_type;
    gpto   : out gptimer_out_type
  );
  end component;

-- 32-bit ram with AHB interface

  component ahbram
  generic (
    hindex  : integer := 0;
    haddr   : integer := 0;
    hmask   : integer := 16#fff#;
    tech    : integer := DEFMEMTECH;
    kbytes  : integer := 1);
  port (
    rst    : in  std_ulogic;
    clk    : in  std_ulogic;
    ahbsi  : in  ahb_slv_in_type;
    ahbso  : out ahb_slv_out_type);
  end component;

  type ahbram_out_type is record
    ce : std_ulogic;
  end record;

  component ftahbram is
    generic (
      hindex    : integer := 0;
      haddr     : integer := 0;
      hmask     : integer := 16#fff#;
      tech      : integer := DEFMEMTECH;
      kbytes    : integer := 1;
      pindex    : integer := 0;
      paddr     : integer := 0;
      pmask     : integer := 16#fff#;
      edacen    : integer := 1;
      autoscrub : integer := 0;
      errcnten  : integer := 0;
      cntbits   : integer range 1 to 8 := 1;
      ahbpipe   : integer := 0);
    port (
      rst     : in  std_ulogic;
      clk     : in  std_ulogic;
      ahbsi   : in  ahb_slv_in_type;
      ahbso   : out ahb_slv_out_type;
      apbi    : in  apb_slv_in_type;
      apbo    : out apb_slv_out_type;
      aramo   : out ahbram_out_type
    );
  end component;

  component ahbtrace is
  generic (
    hindex  : integer := 0;
    ioaddr    : integer := 16#000#;
    iomask    : integer := 16#E00#;
    tech    : integer := DEFMEMTECH;
    irq     : integer := 0;
    kbytes  : integer := 1);
  port (
    rst    : in  std_ulogic;
    clk    : in  std_ulogic;
    ahbmi  : in  ahb_mst_in_type;
    ahbsi  : in  ahb_slv_in_type;
    ahbso  : out ahb_slv_out_type
  );
  end component;

type ahb_dma_in_type is record
  address         : std_logic_vector(31 downto 0);
  wdata           : std_logic_vector(31 downto 0);
  start           : std_ulogic;
  burst           : std_ulogic;
  write           : std_ulogic;
  busy            : std_ulogic;
  irq             : std_ulogic;
  size            : std_logic_vector(1 downto 0);
end record;

type ahb_dma_out_type is record
  start           : std_ulogic;
  active          : std_ulogic;
  ready           : std_ulogic;
  retry           : std_ulogic;
  mexc            : std_ulogic;
  haddr           : std_logic_vector(9 downto 0);
  rdata           : std_logic_vector(31 downto 0);
end record;

  component ahbmst
  generic (
    hindex  : integer := 0;
    hirq    : integer := 0;
    venid   : integer := VENDOR_GAISLER;
    devid   : integer := 0;
    version : integer := 0;
    chprot  : integer := 3;
    incaddr : integer := 0);
   port (
      rst  : in  std_ulogic;
      clk  : in  std_ulogic;
      dmai : in ahb_dma_in_type;
      dmao : out ahb_dma_out_type;
      ahbi : in  ahb_mst_in_type;
      ahbo : out ahb_mst_out_type
      );
  end component;

  type gpio_in_type is record
    din      : std_logic_vector(31 downto 0);
    sig_in   : std_logic_vector(31 downto 0);
    sig_en   : std_logic_vector(31 downto 0);
  end record;

  type gpio_out_type is record
    dout     : std_logic_vector(31 downto 0);
    oen      : std_logic_vector(31 downto 0);
    val      : std_logic_vector(31 downto 0);
    sig_out  : std_logic_vector(31 downto 0);
  end record;

  type ahb2ahb_ctrl_type is record
    slck  : std_ulogic;
    blck  : std_ulogic;
  end record;

 component grgpio
  generic (
    pindex   : integer := 0;
    paddr    : integer := 0;
    pmask    : integer := 16#fff#;
    imask    : integer := 16#0000#;
    nbits    : integer := 16;			-- GPIO bits
    oepol    : integer := 0;                    -- Output enable polarity
    syncrst  : integer := 0;
    bypass   : integer := 16#0000#;
    scantest : integer := 0;
    bpdir    : integer := 16#0000#
  );
  port (
    rst    : in  std_ulogic;
    clk    : in  std_ulogic;
    apbi   : in  apb_slv_in_type;
    apbo   : out apb_slv_out_type;
    gpioi  : in  gpio_in_type;
    gpioo  : out gpio_out_type
  );
  end component;

  component ahb2ahb
  generic(
    memtech : integer := 0;
    hsindex : integer := 0;
    hmindex : integer := 0;
    slv     : integer := 0;
    dir     : integer := 0;   -- 0 - down, 1 - up
    ffact    : integer := 0;
    pfen    : integer range 0 to 1 := 0;
    rbufsz  : integer range 2 to 32 := 8;
    wbufsz  : integer range 2 to 32 := 2;
    iburst   : integer range 4 to 8 :=  8;
    rburst   : integer range 2 to 32 := 8;
    irqsync : integer range 0 to 2 := 0;
    bar0     : integer range 0 to 1073741823 := 0;
    bar1     : integer range 0 to 1073741823 := 0;
    bar2     : integer range 0 to 1073741823 := 0;
    bar3     : integer range 0 to 1073741823 := 0;
    sbus     : integer := 0;
    mbus     : integer := 0;
    ioarea   : integer := 0;
    ibrsten  : integer := 0);
  port (
    rstn   : in std_ulogic;
    hclkm  : in std_ulogic;
    hclks  : in std_ulogic;
    ahbsi  : in ahb_slv_in_type;
    ahbso  : out ahb_slv_out_type;
    ahbmi  : in ahb_mst_in_type;
    ahbmo  : out ahb_mst_out_type;
    ahbso2 : in ahb_slv_out_vector;
    lcki   : in ahb2ahb_ctrl_type;
    lcko   : out ahb2ahb_ctrl_type
    );
  end component;

  component ahbbridge
  generic(
    memtech     : integer := 0;
    ffact       : integer := 2;
    -- high-speed bus
    hsb_hsindex : integer := 0;
    hsb_hmindex : integer := 0;
    hsb_iclsize : integer range 4 to 8 := 8;
    hsb_bank0     : integer range 0 to 1073741823 := 0;
    hsb_bank1     : integer range 0 to 1073741823 := 0;
    hsb_bank2     : integer range 0 to 1073741823 := 0;
    hsb_bank3     : integer range 0 to 1073741823 := 0;
    hsb_ioarea   : integer := 0;
    -- low-speed bus
    lsb_hsindex : integer := 0;
    lsb_hmindex : integer := 0;
    lsb_rburst  : integer range 16 to 32 := 16;
    lsb_wburst  : integer range 2 to 32 :=  8;
    lsb_bank0     : integer range 0 to 1073741823 := 0;
    lsb_bank1     : integer range 0 to 1073741823 := 0;
    lsb_bank2     : integer range 0 to 1073741823 := 0;
    lsb_bank3     : integer range 0 to 1073741823 := 0;
    lsb_ioarea    : integer := 0);
  port (
    rstn    : in std_ulogic;
    hsb_clk : in std_ulogic;
    lsb_clk : in std_ulogic;
    hsb_ahbsi : in  ahb_slv_in_type;
    hsb_ahbso : out ahb_slv_out_type;
    hsb_ahbsov: in  ahb_slv_out_vector;
    hsb_ahbmi : in  ahb_mst_in_type;
    hsb_ahbmo : out ahb_mst_out_type;
    lsb_ahbsi : in  ahb_slv_in_type;
    lsb_ahbso : out ahb_slv_out_type;
    lsb_ahbsov: in  ahb_slv_out_vector;
    lsb_ahbmi : in  ahb_mst_in_type;
    lsb_ahbmo : out ahb_mst_out_type);
  end component;

  function ahb2ahb_membar(memaddr : ahb_addr_type; prefetch, cache : std_ulogic;
                          addrmask : ahb_addr_type)
  return integer;

  function ahb2ahb_iobar(memaddr : ahb_addr_type; addrmask : ahb_addr_type)
  return integer;

  type ahbstat_in_type is record
    cerror : std_logic_vector(0 to NAHBSLV-1);
  end record;

  component ahbstat is
    generic(
      pindex : integer := 0;
      paddr  : integer := 0;
      pmask  : integer := 16#FFF#;
      pirq   : integer := 0;
      nftslv : integer range 1 to NAHBSLV - 1 := 3);
    port(
      rst   : in std_ulogic;
      clk   : in std_ulogic;
      ahbmi : in ahb_mst_in_type;
      ahbsi : in ahb_slv_in_type;
      stati : in ahbstat_in_type;
      apbi  : in apb_slv_in_type;
      apbo  : out apb_slv_out_type
    );
  end component;

  type nuhosp3_in_type is record
    flash_d	: std_logic_vector(15 downto 0);
    smsc_data 	: std_logic_vector(31 downto 0);
    smsc_ardy  	: std_ulogic;
    smsc_intr  	: std_ulogic;
    smsc_nldev 	: std_ulogic;
    lcd_data 	: std_logic_vector(7 downto 0);
  end record;

  type nuhosp3_out_type is record
    flash_a 	: std_logic_vector(20 downto 0);
    flash_d	: std_logic_vector(15 downto 0);
    flash_oen  	: std_ulogic;
    flash_wen 	: std_ulogic;
    flash_cen  	: std_ulogic;
    smsc_addr 	: std_logic_vector(14 downto 0);
    smsc_data 	: std_logic_vector(31 downto 0);
    smsc_nbe  	: std_logic_vector(3 downto 0);
    smsc_resetn	: std_ulogic;
    smsc_nrd   	: std_ulogic;
    smsc_nwr   	: std_ulogic;
    smsc_ncs   	: std_ulogic;
    smsc_aen   	: std_ulogic;
    smsc_lclk  	: std_ulogic;
    smsc_wnr   	: std_ulogic;
    smsc_rdyrtn	: std_ulogic;
    smsc_cycle 	: std_ulogic;
    smsc_nads  	: std_ulogic;
    smsc_ben   	: std_ulogic;
    lcd_data 	: std_logic_vector(7 downto 0);
    lcd_rs	: std_ulogic;
    lcd_rw	: std_ulogic;
    lcd_en	: std_ulogic;
    lcd_backl	: std_ulogic;
    lcd_ben	: std_ulogic;
  end record;

  component nuhosp3
  generic (
    hindex  : integer := 0;
    haddr   : integer := 0;
    hmask   : integer := 16#fff#;
    ioaddr : integer := 16#200#;
    iomask : integer := 16#fff#);
  port (
    rst    : in  std_ulogic;
    clk    : in  std_ulogic;
    ahbsi  : in  ahb_slv_in_type;
    ahbso  : out ahb_slv_out_type;
    nui    : in  nuhosp3_in_type;
    nuo    : out nuhosp3_out_type
  );
  end component;

-- On-chip Logic Analyzer

  component logan is

  generic (
    dbits   : integer range 0 to 256 := 32;        -- Number of traced signals
    depth   : integer range 256 to 16384 := 1024;  -- Depth of trace buffer
    trigl   : integer range 1 to 63 := 1;          -- Number of trigger levels
    usereg  : integer range 0 to 1 := 1;           -- Use input register
    usequal : integer range 0 to 1 := 0;
    usediv  : integer range 0 to 1 := 1;
    pindex  : integer := 0;
    paddr   : integer := 0;
    pmask   : integer := 16#F00#;
    memtech : integer := DEFMEMTECH);
  port (
    rstn    : in  std_logic;
    clk     : in  std_logic;
    tclk    : in  std_logic;
    apbi    : in  apb_slv_in_type;                        -- APB in record
    apbo    : out apb_slv_out_type;                       -- APB out record
    signals : in  std_logic_vector(dbits - 1 downto 0));  -- Traced signals

  end component;

  type ps2_in_type is record
    ps2_clk_i      : std_ulogic;
    ps2_data_i     : std_ulogic;
  end record;

  type ps2_out_type is record
    ps2_clk_o      : std_ulogic;
    ps2_clk_oe     : std_ulogic;
    ps2_data_o     : std_ulogic;
    ps2_data_oe    : std_ulogic;
  end record;

  component apbps2
  generic(
    pindex      : integer := 0;
    paddr       : integer := 0;
    pmask       : integer := 16#fff#;
    pirq        : integer := 0;
    fKHz        : integer := 50000;
    fixed       : integer := 1);
  port(
    rst         : in std_ulogic;                -- Global asynchronous reset
    clk         : in std_ulogic;                -- Global clock
    apbi        : in apb_slv_in_type;
    apbo        : out apb_slv_out_type;
    ps2i        : in ps2_in_type;
    ps2o        : out ps2_out_type
    );
  end component;

  type apbvga_out_type is record
    hsync           : std_ulogic;                       -- horizontal sync
    vsync           : std_ulogic;                       -- vertical sync
    comp_sync       : std_ulogic;                       -- composite sync
    blank           : std_ulogic;                       -- blank signal
    video_out_r     : std_logic_vector(7 downto 0);     -- red channel
    video_out_g     : std_logic_vector(7 downto 0);     -- green channel
    video_out_b     : std_logic_vector(7 downto 0);     -- blue channel
  end record;

  component apbvga
  generic(
    memtech     : integer := DEFMEMTECH;
    pindex      : integer := 0;
    paddr       : integer := 0;
    pmask       : integer := 16#fff#);
  port(
    rst             : in std_ulogic;                        -- Global asynchronous reset
    clk             : in std_ulogic;                        -- Global clock
    vgaclk          : in std_ulogic;                        -- VGA clock
    apbi            : in apb_slv_in_type;
    apbo            : out apb_slv_out_type;
    vgao            : out apbvga_out_type
    );
  end component;

  component svgactrl
  generic(
    length      : integer := 384;        -- Fifo-length
    part        : integer := 128;        -- Fifo-part lenght
    memtech     : integer := DEFMEMTECH;
    pindex      : integer := 0;
    paddr       : integer := 0;
    pmask       : integer := 16#fff#;
    hindex      : integer := 0;
    hirq        : integer := 0;
    clk0        : integer := 40000;
    clk1        : integer := 20000;
    clk2        : integer := 15385;
    clk3        : integer := 0;
    burstlen    : integer range 2 to 8 := 8
    );
  port (
    rst       : in std_logic;
    clk       : in std_logic;
    vgaclk    : in std_logic;
    apbi      : in apb_slv_in_type;
    apbo      : out apb_slv_out_type;
    vgao      : out apbvga_out_type;
    ahbi      : in  ahb_mst_in_type;
    ahbo      : out ahb_mst_out_type;
    clk_sel   : out std_logic_vector(1 downto 0)
    );

  end component;

  constant vgao_none : apbvga_out_type :=
	('0', '0', '0', '0', "00000000", "00000000", "00000000");
  constant ps2o_none : ps2_out_type := ('1', '1', '1', '1');

--  component ahbrom
--  generic (
--    hindex  : integer := 0;
--    haddr   : integer := 0;
--    hmask   : integer := 16#fff#;
--    pipe    : integer := 0;
--    tech    : integer := 0;
--    kbytes  : integer := 1);
--  port (
--    rst     : in  std_ulogic;
--    clk     : in  std_ulogic;
--    ahbsi   : in  ahb_slv_in_type;
--    ahbso   : out ahb_slv_out_type
--  );
--  end component;

  component ahbdma
   generic (
     hindex : integer := 0;
     pindex : integer := 0;
     paddr  : integer := 0;
     pmask  : integer := 16#fff#;
     pirq   : integer := 0;
     dbuf   : integer := 0);
   port (
      rst  : in  std_logic;
      clk  : in  std_ulogic;
      apbi : in  apb_slv_in_type;
      apbo : out apb_slv_out_type;
      ahbi : in  ahb_mst_in_type;
      ahbo : out ahb_mst_out_type
      );
  end component;

   -----------------------------------------------------------------------------
   -- Interface type declarations for FIFO controller
   -----------------------------------------------------------------------------
   type FIFO_In_Type is record
      Din:                 Std_Logic_Vector(31 downto 0); -- data input
      Pin:                 Std_Logic_Vector( 3 downto 0); -- parity input
      EFn:                 Std_ULogic;                    -- empty flag
      FFn:                 Std_ULogic;                    -- full flag
      HFn:                 Std_ULogic;                    -- half flag
   end record;

   type FIFO_Out_Type is record
      Dout:                Std_Logic_Vector(31 downto 0); -- data output
      Den:                 Std_Logic_Vector(31 downto 0); -- data enable
      Pout:                Std_Logic_Vector( 3 downto 0); -- parity output
      Pen:                 Std_Logic_Vector( 3 downto 0); -- parity enable
      WEn:                 Std_ULogic;                    -- write enable
      REn:                 Std_ULogic;                    -- read enable
   end record;

   -----------------------------------------------------------------------------
   -- Component declaration for GR FIFO Interface
   -----------------------------------------------------------------------------
   component grfifo is
      generic (
         hindex:           Integer := 0;
         pindex:           Integer := 0;
         paddr:            Integer := 0;
         pmask:            Integer := 16#FFF#;
         pirq:             Integer := 1;                 -- index of first irq
         dwidth:           Integer := 16;                -- data width
         ptrwidth:         Integer range 4 to 16 := 12;  --  16 to  64k bytes
                                                         -- 128 to 512k bits
         singleirq:        Integer range 0 to 1 := 0;    -- single irq output
         oepol:            Integer := 1);                -- output enable polarity
      port (
         rstn:       in    Std_ULogic;
         clk:        in    Std_ULogic;
         apbi:       in    APB_Slv_In_Type;
         apbo:       out   APB_Slv_Out_Type;
         ahbi:       in    AHB_Mst_In_Type;
         ahbo:       out   AHB_Mst_Out_Type;
         fifoi:      in    FIFO_In_Type;
         fifoo:      out   FIFO_Out_Type);
   end component;

   -----------------------------------------------------------------------------
   -- Interface type declarations for CAN controllers
   -----------------------------------------------------------------------------
   type Analog_In_Type is record
      Ain:                 Std_Logic_Vector(31 downto 0); -- address input
      Din:                 Std_Logic_Vector(31 downto 0); -- data input
      Rdy:                 Std_ULogic;                    -- adc ready input
      Trig:                Std_Logic_Vector( 2 downto 0); -- adc trigger inputs
   end record;

   type Analog_Out_Type is record
      Aout:                Std_Logic_Vector(31 downto 0); -- address output
      Aen:                 Std_Logic_Vector(31 downto 0); -- address enable
      Dout:                Std_Logic_Vector(31 downto 0); -- dac data output
      Den:                 Std_Logic_Vector(31 downto 0); -- dac data enable
      Wr:                  Std_ULogic;                    -- dac write strobe
      CS:                  Std_ULogic;                    -- adc chip select
      RC:                  Std_ULogic;                    -- adc read/convert
   end record;

   -----------------------------------------------------------------------------
   -- Component declaration for GR ADC/DAC Interface
   -----------------------------------------------------------------------------
   component gradcdac is
      generic (
         pindex:           Integer := 0;
         paddr:            Integer := 0;
         pmask:            Integer := 16#FFF#;
         pirq:             Integer := 1;                 -- index of first irq
         awidth:           Integer := 8;                 -- address width
         dwidth:           Integer := 16;                -- data width
         oepol:            Integer := 1);                -- output enable polarity
      port (
         rstn:       in    Std_ULogic;
         clk:        in    Std_ULogic;
         apbi:       in    APB_Slv_In_Type;
         apbo:       out   APB_Slv_Out_Type;
         adi:        in    Analog_In_Type;
         ado:        out   Analog_Out_Type);
   end component;

  component grclkgate
  generic (
    pindex   : integer := 0;
    paddr    : integer := 0;
    pmask    : integer := 16#fff#;
    nbits    : integer := 16
  );
  port (
    rst    : in  std_ulogic;
    clk    : in  std_ulogic;
    apbi   : in  apb_slv_in_type;
    apbo   : out apb_slv_out_type;
    clockdis  : out std_logic_vector(nbits-1 downto 0);
    reset     : out std_logic_vector(nbits-1 downto 0)
  );
  end component;

  -----------------------------------------------------------------------------
  -- I2C types and components
  -----------------------------------------------------------------------------
  
  type i2c_in_type is record
      scl : std_ulogic;
      sda : std_ulogic;
  end record;

  type i2c_out_type is record
      scl    : std_ulogic;
      scloen : std_ulogic;
      sda    : std_ulogic;
      sdaoen : std_ulogic;
  end record;
    
  -- AMBA wrapper for OC I2C-master
  component i2cmst
    generic (
      pindex : integer;
      paddr  : integer;
      pmask  : integer;
      pirq   : integer;
      oepol  : integer range 0 to 1 := 0
      );
    port (
      rstn   : in  std_ulogic;
      clk    : in  std_ulogic;
      apbi   : in  apb_slv_in_type;
      apbo   : out apb_slv_out_type;
      i2ci   : in  i2c_in_type;
      i2co   : out i2c_out_type
    );
  end component;

  component i2cslv
    generic (
      pindex  : integer := 0;
      paddr   : integer := 0;
      pmask   : integer := 16#fff#;
      pirq    : integer := 0;
      hardaddr : integer range 0 to 1 := 0; 
      tenbit   : integer range 0 to 1 := 0;
      i2caddr  : integer range 0 to 1023 := 0;
      oepol    : integer range 0 to 1 := 0
      );
    port (
      rstn    : in  std_ulogic;
      clk     : in  std_ulogic;
      apbi    : in  apb_slv_in_type;
      apbo    : out apb_slv_out_type;
      i2ci    : in  i2c_in_type;
      i2co    : out i2c_out_type
      );
  end component;
  
  -----------------------------------------------------------------------------
  -- SPI controller
  -----------------------------------------------------------------------------
  type spi_in_type is record
    miso    : std_ulogic;
    mosi    : std_ulogic;
    sck     : std_ulogic;
    spisel  : std_ulogic;
  end record;

  type spi_out_type is record
    miso     : std_ulogic;
    misooen  : std_ulogic;
    mosi     : std_ulogic;
    mosioen  : std_ulogic;
    sck      : std_ulogic;
    sckoen   : std_ulogic;
    ssn  : std_logic_vector(7 downto 0);  -- used by GE/OC SPI core
  end record;

  component spictrl
    generic (
      pindex   : integer := 0;
      paddr    : integer := 0;
      pmask    : integer := 16#fff#;
      pirq     : integer := 0;
      fdepth   : integer range 1 to 7  := 1;
      slvselen : integer range 0 to 1  := 0;
      slvselsz : integer range 1 to 32 := 1;
      oepol    : integer range 0 to 1  := 0
      );
    port (
      rstn   : in std_ulogic;
      clk    : in std_ulogic;
      apbi   : in apb_slv_in_type;
      apbo   : out apb_slv_out_type;
      spii   : in  spi_in_type;
      spio   : out spi_out_type;
      slvsel : out std_logic_vector((slvselsz-1) downto 0)
    );
  end component;

  function nandtree(v : std_logic_vector) return std_ulogic;

end;


package body misc is

  function ahb2ahb_membar(memaddr : ahb_addr_type; prefetch, cache : std_ulogic;
                          addrmask : ahb_addr_type)
  return integer is
    variable tmp : std_logic_vector(29 downto 0);
    variable bar : std_logic_vector(31 downto 0);
    variable res : integer range 0 to 1073741823;
  begin
    bar := ahb_membar(memaddr, prefetch, cache, addrmask);
    tmp := (others => '0');
    tmp(29 downto 18) := bar(31 downto 20);
    tmp(17 downto 0) := bar(17 downto 0);
    res := conv_integer(tmp);
    return(res);
  end;

  function ahb2ahb_iobar(memaddr : ahb_addr_type; addrmask : ahb_addr_type)
  return integer is
    variable tmp : std_logic_vector(29 downto 0);
    variable bar : std_logic_vector(31 downto 0);
    variable res : integer range 0 to 1073741823;
  begin
    bar := ahb_iobar(memaddr, addrmask);
    tmp := (others => '0');
    tmp(29 downto 18) := bar(31 downto 20);
    tmp(17 downto 0) := bar(17 downto 0);
    res := conv_integer(tmp);
    return(res);
  end;

  function nandtree(v : std_logic_vector) return std_ulogic is
  variable a : std_logic_vector(v'length-1 downto 0);
  variable b : std_logic_vector(v'length downto 0);
  begin

    a := v; b(0) := '1';

    for i in 0 to v'length-1 loop
      b(i+1) := a(i) nand b(i);
    end loop;

    return b(v'length);

  end;


end;
