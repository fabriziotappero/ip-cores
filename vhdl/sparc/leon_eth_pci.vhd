



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
-- Entity: 	leon_pci
-- File:	leon_pci.vhd
-- Author:	Jiri Gaisler - ESA/ESTEC
-- Description:	Complete processor with PCI pads
------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use work.leon_target.all;
use work.leon_config.all;
use work.leon_iface.all;
use work.tech_map.all;
-- pragma translate_off
use work.debug.all;
-- pragma translate_on

entity leon_eth_pci is
  port (
    resetn   : in    std_logic; 			-- system signals
    clk      : in    std_logic;
    pllref   : in    std_logic;
    plllock  : out   std_logic;

    errorn   : out   std_logic;
    address  : out   std_logic_vector(27 downto 0); 	-- memory bus

    data     : inout std_logic_vector(31 downto 0);

    ramsn    : out   std_logic_vector(4 downto 0);
    ramoen   : out   std_logic_vector(4 downto 0);
    rwen     : inout std_logic_vector(3 downto 0);
    romsn    : out   std_logic_vector(1 downto 0);
    iosn     : out   std_logic;
    oen      : out   std_logic;
    read     : out   std_logic;
    writen   : inout std_logic;

    brdyn    : in    std_logic;
    bexcn    : in    std_logic;
-- sdram i/f
    sdcke    : out std_logic_vector ( 1 downto 0);  -- clk en
    sdcsn    : out std_logic_vector ( 1 downto 0);  -- chip sel
    sdwen    : out std_logic;                       -- write en
    sdrasn   : out std_logic;                       -- row addr stb
    sdcasn   : out std_logic;                       -- col addr stb
    sddqm    : out std_logic_vector ( 3 downto 0);  -- data i/o mask
    sdclk    : out std_logic;       
    pio      : inout std_logic_vector(15 downto 0); 	-- I/O port

    wdogn    : out   std_logic;				-- watchdog output

    dsuen    : in    std_logic;
    dsutx    : out   std_logic;
    dsurx    : in    std_logic;
    dsubre   : in    std_logic;
    dsuact   : out   std_logic;
    test     : in    std_logic;

    pci_rst_in_n   : in std_logic;		-- PCI bus
    pci_clk_in 	   : in std_logic;
    pci_gnt_in_n   : in std_logic;
    pci_idsel_in   : in std_logic;  -- ignored in host bridge core
    pci_lock_n     : inout std_logic;  -- Phoenix core: input only
    pci_ad 	   : inout std_logic_vector(31 downto 0);
    pci_cbe_n 	   : inout std_logic_vector(3 downto 0);
    pci_frame_n    : inout std_logic;
    pci_irdy_n 	   : inout std_logic;
    pci_trdy_n 	   : inout std_logic;
    pci_devsel_n   : inout std_logic;
    pci_stop_n 	   : inout std_logic;
    pci_perr_n 	   : inout std_logic;
    pci_par 	   : inout std_logic;    
    pci_req_n 	   : inout std_logic;  -- tristate pad but never read
    pci_serr_n     : inout std_logic;  -- open drain output
    pci_host   	   : in std_logic;
    pci_66	   : in std_logic;

    pci_arb_req_n  : in  std_logic_vector(0 to 3);
    pci_arb_gnt_n  : out std_logic_vector(0 to 3);

    power_state    : out std_logic_vector(1 downto 0);
    pme_enable     : out std_logic;
    pme_clear      : out std_logic;
    pme_status     : in  std_logic;

-- ethernet
    emdio     : inout std_logic;
    etx_clk : in std_logic;
    erx_clk : in std_logic;
    erxd    : in std_logic_vector(3 downto 0);   
    erx_dv  : in std_logic; 
    erx_er  : in std_logic; 
    erx_col : in std_logic;
    erx_crs : in std_logic;

    etxd : out std_logic_vector(3 downto 0);   
    etx_en : out std_logic; 
    etx_er : out std_logic; 
    emdc : out std_logic;    

    emddis : out std_logic;    
    epwrdwn : out std_logic;
    ereset : out std_logic;
    esleep : out std_logic;
    epause : out std_logic

  );
end; 

architecture rtl of leon_eth_pci is

component mcore
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
    ethi     : in  eth_in_type;
    etho     : out eth_out_type;
    cgo      : in  clkgen_out_type;

    test     : in    std_logic
);
end component; 

signal vcc, gnd, clko, sdclkl, resetno : std_logic;
signal clkm, clkn, pciclk : clk_type;
signal memi     : memory_in_type;
signal memo     : memory_out_type;
signal ioi      : io_in_type;
signal ioo      : io_out_type;
signal pcii     : pci_in_type;
signal pcio     : pci_out_type;
signal dsi      : dsuif_in_type;
signal dso      : dsuif_out_type;
signal sdo      : sdram_out_type;
signal cgi      : clkgen_in_type;
signal cgo      : clkgen_out_type;

signal pci_aden         : std_logic_vector(31 downto 0);
signal pci_cbeen        : std_logic_vector(3 downto 0);
signal pci_frame_en     : std_logic;
signal pci_irdy_en      : std_logic;
signal pci_trdy_en      : std_logic;
signal pci_devsel_en    : std_logic;
signal pci_stop_en      : std_logic;
signal pci_perr_en      : std_logic;
signal pci_par_en       : std_logic;
signal pci_req_en       : std_logic;
signal pci_serr_en      : std_logic;
signal pci_lock_en      : std_logic;
signal pci_lock_out     : std_logic;
signal pci_req_in_dummy : std_logic;
signal pci_clk          : std_logic;

signal ethi     : eth_in_type;
signal etho     : eth_out_type;

begin

  gnd <= '0'; vcc <= '1';
  cgi.pllctrl <= "00"; cgi.pllrst <= resetno; cgi.pllref <= pllref;

-- main processor core

  mcore0  : mcore  
  port map ( 
    resetn => resetno, clk => clkm, clkn => clkn, pciclk => pciclk,
    memi => memi, memo => memo, ioi => ioi, ioo => ioo,
    pcii => pcii, pcio => pcio, dsi => dsi, dso => dso, sdo => sdo,
    ethi => ethi, etho => etho, cgo => cgo, test => test);

-- clock generator

  clkgen0 : clkgen  
  port map ( clko, pci_clk, clkm, clkn, sdclkl, pciclk, cgi, cgo);

-- pads

--  clk_pad   : inpad port map (clk, clko);	-- clock
  clko <= clk;					-- avoid buffering during synthesis
  reset_pad   : smpad port map (resetn, resetno);	-- reset
  brdyn_pad   : inpad port map (brdyn, memi.brdyn);	-- bus ready
  bexcn_pad   : inpad port map (bexcn, memi.bexcn);	-- bus exception

  ds : if DEBUG_UNIT generate
    dsuen_pad   : inpad port map (dsuen, dsi.dsui.dsuen);	-- DSU enable
    dsutx_pad   : outpad generic map (1) port map (dso.dcomo.dsutx, dsutx);
    dsurx_pad   : inpad port map (dsurx, dsi.dcomi.dsurx);	-- DSU receive data
    dsubre_pad  : inpad port map (dsubre, dsi.dsui.dsubre);	-- DSU break
    dsuact_pad  : outpad generic map (1) port map (dso.dsuo.dsuact, dsuact);
  end generate;

  sd : if SDRAMEN generate
    cs_pads: for i in 0 to 1 generate
      sdcke_pad  : outpad generic map (2) port map (sdo.sdcke(i), sdcke(i));
      sdcsn_pad  : outpad generic map (2) port map (sdo.sdcsn(i), sdcsn(i));
    end generate;
    sdwen_pad  : outpad generic map (2) port map (sdo.sdwen, sdwen);
    sdrasn_pad : outpad generic map (2) port map (sdo.rasn, sdrasn);
    sdcasn_pad : outpad generic map (2) port map (sdo.casn, sdcasn);
    dqm_pads: for i in 0 to 3 generate
      sddqm_pad   : outpad generic map (2) port map (sdo.dqm(i), sddqm(i));
    end generate;
--      sdclk_pad : outpad generic map (2) port map (sdclkl, sdclk);
    sdclk <= sdclkl;  -- disable pad for simulation
  end generate;

    error_pad   : odpad generic map (2) port map (ioo.errorn, errorn);	-- cpu error mode

    d_pads: for i in 0 to 31 generate			-- data bus
      d_pad : iopad generic map (3) port map (memo.data(i), memo.bdrive((31-i)/8), memi.data(i), data(i));
    end generate;


    pio_pads : for i in 0 to 15 generate		-- parallel I/O port
      pio_pad : smiopad generic map (2) port map (ioo.piol(i), ioo.piodir(i), ioi.piol(i), pio(i));
    end generate;

    rwen_pads : for i in 0 to 3 generate			-- ram write strobe
      rwen_pad : iopad generic map (2) port map (memo.wrn(i), gnd, memi.wrn(i), rwen(i));
    end generate;

     							-- I/O write strobe
    writen_pad : iopad generic map (2) port map (memo.writen, gnd, memi.writen, writen);

    a_pads : for i in 0 to 27 generate			-- memory address
      a_pads : outpad generic map (3) port map (memo.address(i), address(i));
    end generate;

    ramsn_pads : for i in 0 to 4 generate		-- ram oen/rasn
      ramsn_pad : outpad generic map (2) port map (memo.ramsn(i), ramsn(i));
    end generate;

    ramoen_pads : for i in 0 to 4 generate		-- ram chip select
      ramoen_pad : outpad generic map (2) port map (memo.ramoen(i), ramoen(i));
    end generate;

    romsn_pads : for i in 0 to 1 generate			-- rom chip select
      romsn_pad : outpad generic map (2) port map (memo.romsn(i), romsn(i));
    end generate;

    read_pad : outpad generic map (2) port map (memo.read, read);	-- memory read
    oen_pad  : outpad generic map (2) port map (memo.oen, oen);	-- memory oen
    iosn_pad : outpad generic map (2) port map (memo.iosn, iosn);	-- I/O select

    wd : if WDOGEN generate
      wdogn_pad : odpad generic map (2) port map (ioo.wdog, wdogn);	-- watchdog output
    end generate;

    pl : if TARGET_CLK /= gen generate
      plllock_pad : outpad generic map (2) port map (cgo.clklock, plllock);
    end generate;

      pcictrl0 : if PCICORE /= opencores generate
        pci_trdy_en   <= pcio.pci_ctrl_en_n;
        pci_devsel_en <= pcio.pci_ctrl_en_n;
        pci_stop_en   <= pcio.pci_ctrl_en_n;
      end generate;

      pcictrl1 : if PCICORE = opencores generate
        pci_trdy_en   <= pcio.pci_trdy_en_n;
        pci_devsel_en <= pcio.pci_devsel_en_n;
        pci_stop_en   <= pcio.pci_stop_en_n;

      end generate;

      pcictrl2 : if PCIEN generate
        pci_aden     <= pcio.pci_aden_n;
        pci_cbeen(0) <= pcio.pci_cbe0_en_n;
        pci_cbeen(1) <= pcio.pci_cbe1_en_n;
        pci_cbeen(2) <= pcio.pci_cbe2_en_n;
        pci_cbeen(3) <= pcio.pci_cbe3_en_n;
        pci_frame_en <= pcio.pci_frame_en_n;
        pci_irdy_en  <= pcio.pci_irdy_en_n;
        pci_perr_en  <= pcio.pci_perr_en_n;
        pci_par_en   <= pcio.pci_par_en_n;
        pci_req_en   <= pcio.pci_req_en_n;
        pci_serr_en  <= pcio.pci_serr_out_n;  -- open drain pad!
        pci_lock_en  <= '1'; -- is-core has no lock output -> deactivate
        pci_lock_out <= '0';            -- dont care this output
      end generate;

      pci_rst_in_n_pad : pciinpad port map(pci_rst_in_n, pcii.pci_rst_in_n);
--      pci_clk_in_pad : inpad port map(pci_clk_in, pci_clk);
      pci_clk <= pci_clk_in;
      pci_gnt_in_n_pad : pciinpad port map(pci_gnt_in_n, pcii.pci_gnt_in_n);
      pci_idsel_in_pad : pciinpad port map(pci_idsel_in, pcii.pci_idsel_in);  -- ignored in host bridge core
--      pci_lock_in_n_pad : inpad port map(pci_lock_in_n, pcii.pci_lock_in_n);  -- Phoenix core: input only
      pci_lock_n_pad : pciiopad port map(pci_lock_out, pci_lock_en, pcii.pci_lock_in_n, pci_lock_n);



      pci_ad_pads : for i in 0 to 31 generate
	pci_adio_pad : pciiopad
	    port map(pcio.pci_adout(i), pci_aden(i), pcii.pci_adin(i), pci_ad(i));  
      end generate pci_ad_pads;

      pci_cbe_n_pads : for i in 0 to 3 generate
	pci_cbeio_n_pad : pciiopad
	    port map(pcio.pci_cbeout_n(i), pci_cbeen(i), pcii.pci_cbein_n(i), pci_cbe_n(i));
      end generate pci_cbe_n_pads;

      pci_frame_io_n_pad : pciiopad port map
	(pcio.pci_frame_out_n, pci_frame_en, pcii.pci_frame_in_n, pci_frame_n);

      pci_irdy_io_n_pad : pciiopad port map
	(pcio.pci_irdy_out_n, pci_irdy_en, pcii.pci_irdy_in_n, pci_irdy_n);

      pci_trdy_io_n_pad : pciiopad port map
	(pcio.pci_trdy_out_n, pci_trdy_en, pcii.pci_trdy_in_n, pci_trdy_n);
      pci_devsel_io_n_pad : pciiopad port map
	(pcio.pci_devsel_out_n, pci_devsel_en, pcii.pci_devsel_in_n, pci_devsel_n);
      pci_stop_io_n_pad : pciiopad port map
	(pcio.pci_stop_out_n, pci_stop_en, pcii.pci_stop_in_n, pci_stop_n);
    
      pci_perr_io_n_pad : pciiopad port map
	(pcio.pci_perr_out_n, pci_perr_en, pcii.pci_perr_in_n, pci_perr_n);

      pci_par_io_pad : pciiopad port map
	(pcio.pci_par_out, pci_par_en, pcii.pci_par_in, pci_par);    

      pci_req_io_n_pad : pciiopad port map  	-- tristate pad but never read
	(pcio.pci_req_out_n, pci_req_en, pci_req_in_dummy, pci_req_n);

    -- open drain bidir
      pci_serr_n_pad   : pciiodpad port map (pci_serr_en, pcii.pci_serr_in_n, pci_serr_n);

    -- PCI host select
      pci_host_pad : inpad port map (pci_host, pcii.pci_host);	

    -- Optional PCI arbiter

      parb1 : if PCIARBEN generate
        pgnt : for i in 0 to 3 generate
          pcignt : pcioutpad port map (ioo.pci_arb_gnt_n(i), pci_arb_gnt_n(i));
        end generate;
      end generate;

      parb2 : if PCIARBEN generate
        preq : for i in 0 to 3 generate
          pcireq : inpad port map (pci_arb_req_n(i), ioi.pci_arb_req_n(i));
        end generate;
      end generate;
    -- Optional 66 MHz pad
      p66  : if PCI66PADEN generate
        pci_66_pad : inpad port map(pci_66, pcii.pci_66);
      end generate;
      np66  : if not PCI66PADEN generate
        pcii.pci_66 <= '0';
      end generate;

    -- Optional power control pads

      pme  : if PCIPMEEN generate
        pmes : for i in 1 downto 0 generate
          power_state_pad : pcioutpad port map (pcio.power_state(i), power_state(i));
	end generate;
        pme_enable_pad : pcioutpad port map (pcio.pme_enable, pme_enable);
        pme_clear_pad  : pcioutpad port map (pcio.pme_clear, pme_clear);
        pme_status_pad : inpad port map(pme_status, pcii.pme_status);
      end generate;
      npme  : if not PCIPMEEN generate
        pcii.pme_status <= '0';
      end generate;

    eth_pads : if ETHEN generate
      emdio_pad : iopad generic map (2) port map (etho.mdio_o, etho.mdio_oe, ethi.mdio_i, emdio);
      etx_clk_pad   : inpad port map (etx_clk, ethi.tx_clk);
      erx_clk_pad   : inpad port map (erx_clk, ethi.rx_clk);
      erxd_pads: for i in 0 to 3 generate			-- data bus
        erxd_pad   : inpad port map (erxd(i), ethi.rxd(i));
      end generate;
      erx_dv_pad   : inpad port map (erx_dv, ethi.rx_dv);
      erx_er_pad   : inpad port map (erx_er, ethi.rx_er);
      erx_col_pad   : inpad port map (erx_col, ethi.rx_col);
      erx_crs_pad   : inpad port map (erx_crs, ethi.rx_crs);
      etxd_pads: for i in 0 to 3 generate			-- data bus
        etxd_pad   : outpad generic map (1) port map (etho.txd(i), etxd(i));
      end generate;
      etx_en_pad   : outpad generic map (1) port map (etho.tx_en, etx_en);
      etx_er_pad   : outpad generic map (1) port map (etho.tx_er, etx_er);
      emdc_pad   : outpad generic map (1) port map (etho.mdc, emdc);

      emddis_pad   : outpad generic map (1) port map (gnd, emddis);
      epwrdwn_pad   : outpad generic map (1) port map (gnd, epwrdwn);
      ereset_pad   : outpad generic map (1) port map (vcc, etho.reset);
      esleep_pad   : outpad generic map (1) port map (vcc, esleep);
      epause_pad   : outpad generic map (1) port map (gnd, epause);
    end generate;

end ;

