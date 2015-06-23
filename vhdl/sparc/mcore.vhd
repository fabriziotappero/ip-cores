



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
-- Entity: 	mcore
-- File:	mcore.vhd
-- Author:	Jiri Gaisler - Gaisler Reserch
-- Description:	Module containing the processor, caches, memory controller
--	        and standard peripherals
------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use work.leon_target.all;
use work.leon_config.all;
use work.leon_iface.all;
use work.amba.all;
use work.ambacomp.all;
use work.peri_io_comp.all;
use work.peri_mem_comp.all;
use work.peri_serial_comp.all;

-- pragma translate_off
use work.debug.all;
-- pragma translate_on

entity mcore is
  port (
    resetn   : in  std_logic;
    clk      : in  clk_type;
    clkn     : in  clk_type;
    pciclk   : in  clk_type;
    memi     : in  memory_in_type;
    memo     : out memory_out_type;
    ioi      : in  io_in_type;
    ioo      : out io_out_type;
    pcii     : in  pci_in_type;
    pcio     : out pci_out_type;
    dsi      : in  dsuif_in_type;
    dso      : out dsuif_out_type;
    sdo      : out sdram_out_type;
    ethi     : in eth_in_type;
    etho     : out eth_out_type;
    cgo      : in  clkgen_out_type;

    test     : in    std_logic
  );
end; 

architecture rtl of mcore is

component rstgen
port (
    rstin     : in  std_logic;
    pcirstin  : in  std_logic;
    clk       : in  clk_type;
    pciclk    : in  clk_type;
    rstout    : out std_logic;
    pcirstout : out std_logic;
    cgo       : in  clkgen_out_type
);
end component;

component dsu_mem
  port (
    clk    : in  clk_type;
    dmi    : in  dsumem_in_type;
    dmo    : out dsumem_out_type
  );
end component; 




signal rst   : std_logic;
signal iui   : iu_in_type;
signal iuo   : iu_out_type;
signal ahbsto: ahbstat_out_type;
signal mctrlo: mctrl_out_type;
signal wpo   : wprot_out_type;
signal apbi  : apb_slv_in_vector(0 to APB_SLV_MAX-1);
signal apbo  : apb_slv_out_vector(0 to APB_SLV_MAX-1);
signal ahbmi : ahb_mst_in_vector(0 to AHB_MST_MAX-1);
signal ahbmo : ahb_mst_out_vector(0 to AHB_MST_MAX-1);
signal ahbsi : ahb_slv_in_vector(0 to AHB_SLV_MAX-1);
signal ahbso : ahb_slv_out_vector(0 to AHB_SLV_MAX);
signal dsuo  : dsu_out_type;
signal dcomo : dcom_out_type;

signal irqi   : irq_in_type;
signal irqo   : irq_out_type;
signal irq2i  : irq2_in_type;
signal irq2o  : irq2_out_type;
signal timo   : timers_out_type;
signal pioo   : pio_out_type;
signal uart1i, uart2i  : uart_in_type;
signal uart1o, uart2o  : uart_out_type;
signal dmi    : dsumem_in_type;
signal dmo    : dsumem_out_type;
signal pciirq : std_logic;
signal ethirq : std_logic;
signal pcirst : std_logic;
signal pciahb2: ahb_mst_out_type;
signal mctrlo_pioh             : std_logic_vector(15 downto 0);

begin

-- reset generator

  reset0 : rstgen port map (resetn, pcii.pci_rst_in_n, clk, 
	   pciclk, rst, pcirst, cgo);


----------------------------------------------------------------------
-- AHB bus                                                          --
----------------------------------------------------------------------

-- AHB arbiter/decoder

  ahb0 : ahbarb 
	 generic map (masters => AHB_MASTERS, defmast => AHB_DEFMST)
	 port map (rst, clk, ahbmi(0 to AHB_MASTERS-1), 
	      ahbmo(0 to AHB_MASTERS-1), ahbsi, ahbso);

-- AHB/APB bridge

  apb0 : apbmst
	 port map (rst, clk, ahbsi(1), ahbso(1), apbi, apbo);

-- processor and cache sub-system

  proc0 : proc port map (
	rst, clk, clkn, apbi(2), apbo(2), ahbmi(0), ahbmo(0), 
	ahbsi(0), iui, iuo);

-- debug support unit
  dsugen : if DEBUG_UNIT generate
    dsu0 : dsu port map ( rst, clk, ahbmi(0), ahbsi(2), ahbso(2),
	              dsi.dsui, dsuo, iuo.debug, iui.debug, irqo, dmi, dmo);
    dso.dsuo <= dsuo;
    dsum0 : dsu_mem port map ( clk, dmi, dmo);
  end generate;
  dcomgen : if DEBUG_UNIT generate
    dcom0 : dcom 
            port map ( rst, clk, dsi.dcomi, dcomo, dsuo, apbi(11),
	    apbo(11), ahbmi(AHB_MASTERS-1), ahbmo(AHB_MASTERS-1) );
    dso.dcomo <= dcomo;
  end generate;

-- sram/prom/sdram memory controller

  mctrl0 : mctrl port map (
	rst => rst, clk=> clk, memi => memi, memo => memo,
	ahbsi => ahbsi(0), ahbso => ahbso(0), apbi => apbi(0), apbo => apbo(0), 
	pioo => pioo, wpo => wpo, sdo => sdo, mctrlo => mctrlo);

-- AHB ram
  aram0 : if AHBRAMEN generate
    aram : ahbram generic map (AHBRAM_BITS) 
           port map (rst, clk, ahbsi(4), ahbso(4));
  end generate;

-- AHB write protection

  wp0 : if WPROTEN generate
    wpm :  wprot port map ( 
	rst => rst, clk => clk, wpo => wpo,  ahbsi => ahbsi(0), 
	apbi => apbi(3), apbo => apbo(3));
  end generate;
  wp1 : if not WPROTEN generate apbo(3).prdata <= (others => '0'); end generate;

-- AHB status register

  as0 : if AHBSTATEN generate
    asm :  ahbstat port map ( 
	rst => rst, clk => clk, ahbmi => ahbmi(0), ahbsi => ahbsi(0), 
	apbi => apbi(1), apbo => apbo(1), ahbsto => ahbsto);
  end generate;

  as1 : if not AHBSTATEN generate 
    apbo(1).prdata <= (others => '0'); ahbsto.ahberr <= '0';
  end generate;

-- Optional PCI core

  pci0 : if PCIEN generate
    pci0 : pci
      port map ( resetn => rst, clk => clk, pciclk => pciclk,
        pcirst => pcirst, pcii => pcii, pcio => pcio,
        ahbmi1 => ahbmi(1), ahbmo1 => ahbmo(1),
        ahbmi2 => ahbmi(2), ahbmo2 => pciahb2,
        ahbsi => ahbsi(3), ahbso => ahbso(3),
        apbi => apbi(12), apbo => apbo(12), irq => pciirq);
    ahbmd2 : if PCIMASTERS = 2 generate ahbmo(2) <= pciahb2; end generate;
  end generate;
  nopci : if not PCIEN generate pciirq <= '0'; end generate;

  eth0 : if ETHEN generate
    eth0 : eth_oc
    port map ( rst => rst, clk => clk,
               ahbsi => ahbsi(5), ahbso => ahbso(5),
               ahbmi  => ahbmi(PCIMASTERS+1), ahbmo => ahbmo(PCIMASTERS+1),
               eneti => ethi, eneto  => etho,
               irq => ethirq);
  end generate;
  noeth : if not ETHEN generate ethirq <= '0'; end generate;

-- drive unused part of the AHB bus to stop some stupid synthesis tools
-- from inserting tri-state buffers (!)  DISABLED

--  ahbdrv : for i in 0 to AHB_SLV_MAX-1 generate
--    u0 : if not AHB_SLVTABLE(i).enable and (AHB_SLVTABLE(i).index /= 0) generate
--      ahbso(AHB_SLVTABLE(i).index).hready <= '0'; 
--      ahbso(AHB_SLVTABLE(i).index).hresp  <= "--";
--      ahbso(AHB_SLVTABLE(i).index).hrdata <= (others => '-'); 
--      ahbso(AHB_SLVTABLE(i).index).hsplit <= (others => '-');
--    end generate;
--  end generate;

----------------------------------------------------------------------
-- APB bus                                                          --
----------------------------------------------------------------------

  pci_arb0 : if PCIARBEN generate
    pciarb : pci_arb
       port map (
         clk => pciclk, rst_n => rst,
         req_n => ioi.pci_arb_req_n, frame_n => pcii.pci_frame_in_n,
         gnt_n => ioo.pci_arb_gnt_n, pclk => clk, 
         prst_n => pcirst, pbi => apbi(13), pbo => apbo(13)
       );
  end generate;

-- LEON configuration register

  lc0 : if CFGREG generate
    lcm : lconf port map (rst => rst, apbo => apbo(4));
  end generate;

-- timers (and watchdog)

  timers0 : timers 
  port map (rst => rst, clk => clk, apbi => apbi(5), 
	    apbo => apbo(5), timo => timo, dsuo => dsuo);

-- UARTS
-- This stupidity exists because synopsys DC is not capable of
-- handling record elements in port maps. Sad really ...

  uart1i.rxd     <= pioo.rxd(0); uart1i.ctsn    <= pioo.ctsn(0);
  uart2i.rxd     <= pioo.rxd(1); uart2i.ctsn    <= pioo.ctsn(1);
  uart1i.scaler  <= pioo.io8lsb; uart2i.scaler  <= pioo.io8lsb;

  uart1 : uart port map ( 
    rst => rst, clk => clk, apbi => apbi(6), apbo => apbo(6), 
    uarti => uart1i, uarto => uart1o);
      
  uart2 : uart port map ( 
    rst => rst, clk => clk, apbi => apbi(7), apbo => apbo(7), 
    uarti => uart2i, uarto => uart2o);
      
-- interrupt controller

  irqctrl0 : irqctrl 
  port map (rst  => rst, clk  => clk, apbi => apbi(8), 
	    apbo => apbo(8), irqi => irqi, irqo => irqo);
  irqi.intack <= iuo.intack; irqi.irl <= iuo.irqvec; iui.irl <= irqo.irl;    

-- optional secondary interrupt controller

  i2 : if IRQ2EN generate
    irqctrl1 : irqctrl2
    port map (rst  => rst, clk  => clk, apbi => apbi(10), 
 	      apbo => apbo(10), irqi => irq2i, irqo => irq2o);
  end generate;

-- parallel I/O port

  ioport0 : ioport 
  port map (rst => rst, clk  => clk, apbi => apbi(9), apbo => apbo(9),
            uart1o => uart1o, uart2o => uart2o, mctrlo_pioh => mctrlo_pioh,
	    ioi => ioi, pioo => pioo);

  mctrlo_pioh <= mctrlo.pioh;
  
-- drive unused part of the APB bus to stop some stupid synthesis tools
-- from inserting tri-state buffers (!) DISABLED

--  apbdrv : for i in 0 to APB_SLV_MAX-1 generate
--    u0 : if not APB_TABLE(i).enable and (APB_TABLE(i).index /= 0) generate
--	apbo( APB_TABLE(i).index).prdata <= (others => '-');
--    end generate;
--  end generate;

-- IRQ assignments, add you mapping below

  irqi.irq(15) <= '0';             -- unmaskable irq
  irqi.irq(14) <= pciirq;
  irqi.irq(13) <= '0';
  irqi.irq(12) <= ethirq;
  irqi.irq(11) <= dsuo.ntrace when DEBUG_UNIT else '0';
  irqi.irq(10) <= irq2o.irq when IRQ2EN else '0';
  irqi.irq(9) <=  timo.irq(1);		     -- timer 2
  irqi.irq(8) <=  timo.irq(0);		     -- timer 1
  irqi.irq(7 downto 4) <= pioo.irq;	     -- I/O port interrupts
  irqi.irq(3) <= uart1o.irq;		     -- UART 1
  irqi.irq(2) <= uart2o.irq;		     -- UART 2
  irqi.irq(1) <= ahbsto.ahberr;		     -- AHB error

  -- additional 32 interrupts for secondary interrupt controller
  irq2i.irq <= (others => '0');

-- drive outputs

  ioo.piol      <= pioo.piol(15 downto 0);
  ioo.piodir    <= pioo.piodir(15 downto 0);
  ioo.wdog      <= timo.wdog;
  ioo.errorn    <= iuo.error;




-- disassambler

-- pragma translate_off
  trace0 : trace(iuo.debug, (test = '1'));
-- pragma translate_on


end ;

