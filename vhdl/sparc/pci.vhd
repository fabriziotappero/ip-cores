



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
-- Entity: 	pci
-- File:	pci.vhd
-- Author:	Jiri Gaisler - Gaisler Reserch
-- Description:	Module containing all possible PCI cores
------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use work.leon_target.all;
use work.leon_config.all;
use work.leon_iface.all;
use work.amba.all;
use work.ambacomp.all;

entity pci is
  port (
    resetn : in  std_logic;
    clk    : in  clk_type;
    pciclk : in  clk_type;
    pcirst : in  std_logic;
    pcii   : in  pci_in_type;
    pcio   : out pci_out_type;
    apbi   : in  apb_slv_in_type;
    apbo   : out apb_slv_out_type;
    ahbmi1 : in  ahb_mst_in_type;
    ahbmo1 : out ahb_mst_out_type;
    ahbmi2 : in  ahb_mst_in_type;
    ahbmo2 : out ahb_mst_out_type;
    ahbsi  : in  ahb_slv_in_type;
    ahbso  : out ahb_slv_out_type;
    irq    : out std_logic
  );
end; 

architecture rtl of pci is

signal gnd4 : std_logic_vector(3 downto 0);

begin

-- InSilicon PCI core

  pci_is0 : if PCICORE = insilicon generate
    pci0 : pci_is 
      port map ( resetn, pcirst, clk, pciclk, apbi, apbo, irq,
      ahbmo1, ahbmi1, pcii, pcio, ahbso, ahbsi, ahbmo2, ahbmi2);
  end generate;


  pci_gr0 : if PCICORE = target_only generate
    pci0 : pci_gr
      generic map (PCI_DEVICE_ID, PCI_VENDOR_ID, 2)
      port map ( resetn, pcirst, clk, pciclk, pcii, pcio,
      		 ahbmi1, ahbmo1, ahbsi, ahbso);

    ahbmo2.hbusreq <= '0';
    ahbmo2.hlock <= '0';
    ahbmo2.htrans <= HTRANS_IDLE;
    ahbmo2.haddr <= (others => '0');
    ahbmo2.hwrite <= '0';
    ahbmo2.hburst <= HBURST_SINGLE;
    ahbmo2.hprot <= (others => '0');
    ahbmo2.hwdata <= (others => '0');

    irq <= '0';
  end generate;

-- OpenCores PCI bridge

  pci_oc0 : if PCICORE = opencores generate

    pci0 : pci_oc
      port map ( rst => resetn, clk => clk , pci_clk => pciclk,
                ahbsi => ahbsi, ahbso => ahbso, ahbmi => ahbmi1,
                ahbmo => ahbmo1, apbi => apbi, apbo => apbo, pcio => pcio,
                pcii => pcii, irq => irq);

    ahbmo2.hbusreq <= '0';
    ahbmo2.hlock <= '0';
    ahbmo2.htrans <= HTRANS_IDLE;
    ahbmo2.haddr <= (others => '0');
    ahbmo2.hwrite <= '0';
    ahbmo2.hburst <= HBURST_SINGLE;
    ahbmo2.hprot <= (others => '0');
    ahbmo2.hwdata <= (others => '0');
  end generate;

end ;

