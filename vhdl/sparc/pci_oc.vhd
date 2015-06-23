----------------------------------------------------------------------------
--  This file is a part of the LEON VHDL model
--  Copyright (C) 2003 Gaisler Research
--
--  This library is free software; you can redistribute it and/or
--  modify it under the terms of the GNU Lesser General Public
--  License as published by the Free Software Foundation; either
--  version 2 of the License, or (at your option) any later version.
--
--  See the file COPYING.LGPL for the full details of the license.
----------------------------------------------------------------------------
-- Entity: 	pci_oc
-- File:	pci_oc.vhd
-- Description:	Backend for Opencores PCI_IF
-- Author:     	Daniel Hedberg, Gaisler Research
------------------------------------------------------------------------------
--  ReadMe.txt
--  This backend enables access from PCI to AHB and vice-versa. The address
--  mappings are as follows:
--  
--  PCI to AHB access
--
--  BAR0 (MEM area - 4KB)
--
--  0x000 - 0x0FF	PCI conf. space
--  0x100 - 0x1F0	Opencores device specific conf. space
--  
--  BAR1 (MEM area - 1 MB)
--  
--  PCI				AHB
--  0x00000 - 0xFFFFC		0x[000]00000 - 0x[000]FFFFC
--  
--  Values within [default] are configurable in Opencores device specific
--  conf. space.
--  EXAMPLE: How to map an access to AHB address 0x4000_1000?
--  Write 0x4 to P_IMG_CTRL1 reg at 0x110 to enable translation
--  Write 0x4000_1000 to P_TA1 reg at 0x11C
--  For further information refer to Opencores specification
--  
--  AHB to PCI access
--  
--  AHB                                   PCI
--  0xA000_0000 - 0xA000_FFFC             0x0000 - 0xFFFC (I/O access)
--  0xA001_0000 - 0xA001_01F0 (Read only) Opencores device specific conf. space
--  0xC000_0000 - 0xFFFF_FFFC             0xC000_0000 - 0xFFFF_FFFC (MEM access)
--
-- 
--  How to configure the verilog core (all.v)
--  
--  FIFO implementaion: To get an implemention with flip-flops instead of RAMB4
--  comment the lines marked with "//comment for flip-flops"
--
--  To alter default values for how Wishbone addresses are mapped on PCI 16195
--  edit line 16195 to 16221 and 349 to 357
--
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.amba.all;
use work.ambacomp.all;
use work.leon_iface.all;

entity pci_oc is
   port (
      rst  : in  std_logic;
      clk  : in  std_logic;
      pci_clk : in std_logic;
      ahbsi : in  ahb_slv_in_type;
      ahbso : out ahb_slv_out_type;
      ahbmi : in  ahb_mst_in_type;
      ahbmo : out ahb_mst_out_type;
      apbi  : in  apb_slv_in_type;
      apbo  : out apb_slv_out_type;
      pcio  : out pci_out_type;
      pcii  : in  pci_in_type;
      irq   : out std_logic
      );
end;

architecture rtl of pci_oc is

type wb_mst_in_type is record
  mdat_i : std_logic_vector(31 downto 0);      -- binary data bus
  rty_i  : std_logic;
  ack_i  : std_logic;                          -- data available
end record;                                                            
                                                                           
type wb_mst_out_type is record
  adr_o  : std_logic_vector(31 downto 0); 	-- address bus (byte) 
  mdat_o : std_logic_vector(31 downto 0); 	-- binary data bus    
  we_o   : std_logic;
  stb_o  : std_logic;
  cab_o  : std_logic;
end record;
                                                                           
type wb_slv_in_type is record
  adr_i  : std_logic_vector(31 downto 0);
  sdat_i : std_logic_vector(31 downto 0);
  we_i   : std_logic;
  stb_i  : std_logic;
end record;

type wb_slv_out_type is record 
  ack_o  : std_logic;				-- data available 
  rty_o  : std_logic;
  sdat_o : std_logic_vector(31 downto 0);	-- binary data bus    
end record;            

  type ahbslv_state_type is (idle, strobe, respond, rty, doreturn);
  type ahbmst_state_type is (idle, req, respond);


  type ahbslv_reg_type is record
                     hresp      : std_logic_vector(1 downto 0);
                     hready     : std_logic;
                     adr_o      : std_logic_vector(31 downto 0);
                     hrdata     : std_logic_vector(31 downto 0);
                     mdat_o     : std_logic_vector(31 downto 0);
                     mdat_i     : std_logic_vector(31 downto 0);
                     ack_i      : std_logic;
                     rty_i      : std_logic;
                     we_o       : std_logic;
                     hburst     : std_logic_vector(2 downto 0);
                     htrans     : std_logic_vector(1 downto 0);
                   end record;

  type ahbmst_reg_type is record
                     adr_i       : std_logic_vector(31 downto 0);
                     ack_o       : std_logic;
                     sdat_i      : std_logic_vector(31 downto 0);

                   end record;

  type wb_reg_type is record
                     stb_i     : std_logic;
                     we_i      : std_logic;
                     cab_o     : std_logic;
                   end record;

  type reg_type is record
                     ahbslv_state   : ahbslv_state_type;
                     ahbmst_state   : ahbmst_state_type;
                     ahbslv         : ahbslv_reg_type;
                     ahbmst         : ahbmst_reg_type;
                     rdata          : std_logic_vector(31 downto 0);
                     wb             : wb_reg_type;
  --                   AHB2WBCtrl     : std_logic_vector(31 downto 0); --31:29=WB_TA,0=WB_TA enable,
                   end record;

  signal r, rin : reg_type;
  signal highbits : std_logic_vector(31 downto 0);
  signal lowbits : std_logic_vector(31 downto 0);
  signal occlk : std_logic;
  signal ocrst : std_logic;

  signal cbe_en : std_logic_vector(3 downto 0);
  signal wbmi : wb_mst_in_type;
  signal wbmo : wb_mst_out_type;
  signal wbsi : wb_slv_in_type;
  signal wbso : wb_slv_out_type;

  signal dmai : ahb_dma_in_type;
  signal dmao : ahb_dma_out_type;


  component pci_bridge32
    port (
      PCI_CLK_i : in std_logic;
      PCI_AD_oe_o : out std_logic_vector(31 downto 0);
      PCI_AD_i : in std_logic_vector(31 downto 0);
      PCI_AD_o : out std_logic_vector(31 downto 0);
      PCI_CBE_oe_o : out std_logic_vector(3 downto 0);
      PCI_CBE_i : in std_logic_vector(3 downto 0);
      PCI_CBE_o : out std_logic_vector(3 downto 0);
      PCI_RST_oe_o : out std_logic;
      PCI_RST_i : in std_logic;
      PCI_RST_o : out std_logic;
      PCI_INTA_oe_o : out std_logic;
      PCI_INTA_i : in std_logic;
      PCI_INTA_o : out std_logic;
      PCI_REQ_oe_o : out std_logic;
      PCI_REQ_o : out std_logic;
      PCI_GNT_i: in std_logic;
      PCI_FRAME_oe_o : out std_logic;
      PCI_FRAME_i : in std_logic;
      PCI_FRAME_o : out std_logic;
      PCI_IRDY_oe_o : out std_logic;
      PCI_IRDY_i : in std_logic;
      PCI_IRDY_o : out std_logic;
      PCI_IDSEL_i: in std_logic;
      PCI_DEVSEL_oe_o : out std_logic;
      PCI_DEVSEL_i : in std_logic;
      PCI_DEVSEL_o : out std_logic;
      PCI_TRDY_oe_o : out std_logic;
      PCI_TRDY_i : in std_logic;
      PCI_TRDY_o : out std_logic;
      PCI_STOP_oe_o : out std_logic;
      PCI_STOP_i : in std_logic;
      PCI_STOP_o : out std_logic;
      PCI_PAR_oe_o : out std_logic;
      PCI_PAR_i : in std_logic;
      PCI_PAR_o : out std_logic;
      PCI_PERR_oe_o : out std_logic;
      PCI_PERR_i : in std_logic;
      PCI_PERR_o : out std_logic;
      PCI_SERR_oe_o : out std_logic;
      PCI_SERR_o : out std_logic;

      WB_CLK_I: in std_logic;
      WB_RST_I: in std_logic;
      WB_RST_O: out std_logic;
      WB_INT_I: in std_logic;
      WB_INT_O: out std_logic;

    -- WISHBONE slave interface
      WBS_ADR_I: in std_logic_vector(31 downto 0);
      WBS_DAT_I: in std_logic_vector(31 downto 0);
      WBS_DAT_O: out std_logic_vector(31 downto 0);
      WBS_SEL_I: in std_logic_vector(3 downto 0);
      WBS_CYC_I: in std_logic;
      WBS_STB_I: in std_logic;
      WBS_WE_I: in std_logic;
      WBS_CAB_I: in std_logic;
      WBS_ACK_O: out std_logic;
      WBS_RTY_O: out std_logic;
      WBS_ERR_O: out std_logic;

    -- WISHBONE master interface
      WBM_ADR_O: out std_logic_vector(31 downto 0);
      WBM_DAT_I: in std_logic_vector(31 downto 0);
      WBM_DAT_O: out std_logic_vector(31 downto 0);
      WBM_SEL_O: out std_logic_vector(3 downto 0);
      WBM_CYC_O: out std_logic;
      WBM_STB_O: out std_logic;
      WBM_WE_O: out std_logic;
      WBM_CAB_O: out std_logic;
      WBM_ACK_I: in std_logic;
      WBM_RTY_I: in std_logic;
      WBM_ERR_I: in std_logic

    );
  end component;

begin

  lowbits <= (others => '0');
  highbits <= (others => '1');
  comb: process (r, ahbsi, wbmi, rst, cbe_en,
                 ahbmi, wbsi, dmao)
    variable v : reg_type;
    variable vstb_o, vstart : std_logic;
    variable vprdata : std_logic_vector(31 downto 0);
--    variable vAHB_TA : std_logic_vector(31 downto 29);
--    variable vAHB_TA_enable : boolean;
  begin  -- process comb
    v := r;
    vstb_o  := '0';
    v.ahbslv.hready := '1';
--    v.wb.cab_o      := '0';
--    vAHB_TA       := r.AHB2WBCtrl(31 downto 29);
--    if r.AHB2WBCtrl(0) = '1' then
--      vAHB_TA_enable := true;
--    else
--      vAHB_TA_enable := false;
--    end if;

    case r.ahbslv_state is

      when idle   =>
        v.ahbslv.ack_i := '0';
--         if not r.ahbslv.hburst = "001" then
--           v.wb.cab_o := '0';
--         end if;
--        v.wb.cab_o  := '0';
        v.ahbslv.hburst := ahbsi.hburst;
        v.ahbslv.htrans := ahbsi.htrans;
        if ahbsi.haddr(31 downto 16) = "1010000000000000" then -- 0xA000
          v.ahbslv.adr_o  := "0000000000000000" & ahbsi.haddr(15 downto 0);
        else
          v.ahbslv.adr_o  := ahbsi.haddr;          --0xa0010000-0xfffffffc
        end if;
        if (ahbsi.hsel and ahbsi.hready and ahbsi.htrans(1)) = '1' then
--          if ahbsi.hsize = "010" then   --word
            v.ahbslv.hready := '0';
            v.ahbslv_state  := strobe;
            v.ahbslv.we_o   := ahbsi.hwrite;
--          end if; --ahbsi.hsize = word
        end if; --ahbsi.hsel = '1'

      when strobe  =>
        v.ahbslv_state    := respond;
        v.ahbslv.mdat_o   := ahbsi.hwdata;  --write specific
        v.ahbslv.mdat_i    := wbmi.mdat_i;
        vstb_o            := '1';
        v.ahbslv.ack_i    := wbmi.ack_i;
        v.ahbslv.rty_i    := wbmi.rty_i;
        v.ahbslv.hready   := '0';
        if r.ahbslv.hburst = "001" then
          v.wb.cab_o := '1';
--          v.ahbslv.hburst := ahbsi.hburst;
        end if;
        
      when respond =>
        if r.ahbslv.ack_i = '1' then
          v.ahbslv_state    := idle;
          v.ahbslv.hrdata   := r.ahbslv.mdat_i;  --read specific
        elsif r.ahbslv.rty_i = '1' then
          v.ahbslv_state    := rty;
          v.ahbslv.hready   := '0';
          v.ahbslv.hresp    := hresp_retry;
        else
          vstb_o     := '1';              --fix
          v.ahbslv.hready   := '0';
          v.ahbslv.mdat_i   := wbmi.mdat_i;  --read specific
          v.ahbslv.ack_i    := wbmi.ack_i;
          v.ahbslv.rty_i    := wbmi.rty_i;
        end if;
        if (r.wb.cab_o = '1' and ahbsi.htrans(0) = '0') then
          v.wb.cab_o := '0';
        end if;
--        if not r.ahbslv.hburst = "001" then          
--          v.wb.cab_o := '0';
--        end if;

      when rty =>
        v.ahbslv_state  := doreturn;

      when doreturn =>
        v.ahbslv_state  := idle;
        v.ahbslv.hresp  := hresp_okay;

      when others => null;
    end case;

----------------------------------------
----------------------------------------

    v.wb.stb_i := wbsi.stb_i;
    v.wb.we_i := wbsi.we_i;

    v.ahbmst.adr_i     := wbsi.adr_i(31 downto 0);
    v.ahbmst.sdat_i    := wbsi.sdat_i;
    v.rdata            := dmao.rdata;
    vstart             := '0';
    v.ahbmst.ack_o     := '0';
    case r.ahbmst_state is

      when idle =>
        if r.wb.stb_i = '1' then
          v.ahbmst_state := req;
        end if;

      when req  =>
        if dmao.active = '1' and dmao.ready = '1' then
          v.ahbmst.ack_o := '1';
          v.ahbmst_state := respond;
        else
          vstart := '1';
        end if;

      when respond =>
        v.ahbmst_state := idle;

      when others => null;
    end case;

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

--    if apbi.psel = '1' then
--      if apbi.pwrite = '1' then
--        case apbi.paddr(7 downto 0) is
--          when "00000000" =>
--            v.AHB2WBCtrl        := apbi.pwdata;
--          when others       => Null;
--        end case;

--      else
--        case apbi.paddr(3 downto 0) is
--         when "0000" =>
--            vprdata     := r.AHB2WBCtrl;
--          when others       => Null;
--        end case;
--      end if;

--    end if;


    if rst = '0' then
      v.ahbslv_state          := idle;
      v.ahbslv.hresp          := hresp_okay;
      v.ahbslv.hready         := '1';
      v.ahbslv.adr_o          := (others => '0');
      v.ahbslv.hrdata         := (others => '0');
      v.ahbslv.mdat_o         := (others => '0');
      v.ahbslv.mdat_i         := (others => '0');
      v.ahbslv.ack_i          := '0';
      v.ahbslv.rty_i          := '0';
      v.ahbslv.we_o           := '0';

      v.ahbmst_state          := idle;
      v.ahbmst.adr_i          := (others => '0');
      v.ahbmst.ack_o          := '0';
      v.ahbmst.sdat_i         := (others => '0');
      v.rdata                 := (others => '0');

--      v.AHB2WBCtrl            := (others => '0');
      v.wb.cab_o      := '0';

    end if;

    wbmo.adr_o         <= r.ahbslv.adr_o;
--    if is_x(v.ahbslv.mdat_o) then
--      wbmo.mdat_o        <= (others => '0');
--    else
      wbmo.mdat_o        <= v.ahbslv.mdat_o;
--    end if;
    wbmo.we_o          <= r.ahbslv.we_o;
    wbmo.stb_o         <= vstb_o;
    ahbso.hready       <= r.ahbslv.hready;
    ahbso.hresp        <= r.ahbslv.hresp;
    wbmo.cab_o         <= v.wb.cab_o;
--    if is_x(v.ahbslv.hrdata) then
--      ahbso.hrdata       <= (others => '0');
--    else
      ahbso.hrdata       <= v.ahbslv.hrdata;
--    end if;
    ahbso.hsplit       <= (others => '0');
    dmai.address       <= r.ahbmst.adr_i;
--    if is_x(r.ahbmst.sdat_i) then
--      dmai.wdata         <= (others => '0');
--    else
      dmai.wdata         <= r.ahbmst.sdat_i;
--    end if;
    dmai.start         <= vstart;
    dmai.burst         <= '0';
    dmai.write         <= r.wb.we_i;
    dmai.size          <= "10";
    wbso.ack_o         <= r.ahbmst.ack_o;
    wbso.sdat_o        <= r.rdata;
    wbso.rty_o         <= '0';
    apbo.prdata        <= (others => '0');

    pcio.pci_cbe3_en_n <= cbe_en(3);
    pcio.pci_cbe2_en_n <= cbe_en(2);
    pcio.pci_cbe1_en_n <= cbe_en(1);
    pcio.pci_cbe0_en_n <= cbe_en(0);
--    pcio.pci_serr_en_n <= '0';
    pcio.pci_lock_en_n <= '1';
--    pcio.pci_req_en_n  <= '1';

    ocrst <= not rst;
    irq <= '0';

    rin <= v;
  end process comb;

  regs : process(clk)
  begin
    if rising_edge(clk) then
      r <= rin;
    end if;
  end process;

  ahbmst0 : ahbmst port map (rst, clk, dmai, dmao, ahbmi, ahbmo);

  oc : pci_bridge32 port map (

    PCI_CLK_i 		=> pci_clk,
    PCI_AD_oe_o		=> pcio.pci_aden_n,
    PCI_AD_i 		=> pcii.pci_adin,
    PCI_AD_o 		=> pcio.pci_adout,
    PCI_CBE_oe_o 		=> cbe_en,
    PCI_CBE_i 		=> pcii.pci_cbein_n,
    PCI_CBE_o 		=> pcio.pci_cbeout_n,
    PCI_RST_oe_o	=> Open,        --not host
    PCI_RST_i 		=> pcii.pci_rst_in_n,
    PCI_RST_o 		=> Open,        --not host
    PCI_INTA_oe_o	=> pcio.pci_int_en_n,
    PCI_INTA_i 		=> highbits(0),
    PCI_INTA_o 		=> pcio.pci_int_out_n,
    PCI_REQ_oe_o	=> pcio.pci_req_en_n,
    PCI_REQ_o 		=> pcio.pci_req_out_n,
    PCI_GNT_i           => pcii.pci_gnt_in_n,
    PCI_FRAME_oe_o	=> pcio.pci_frame_en_n,
    PCI_FRAME_i		=> pcii.pci_frame_in_n,
    PCI_FRAME_o           => pcio.pci_frame_out_n,
    PCI_IRDY_oe_o	=> pcio.pci_irdy_en_n,
    PCI_IRDY_i 		=> pcii.pci_irdy_in_n,
    PCI_IRDY_o 		=> pcio.pci_irdy_out_n,
    PCI_IDSEL_i		=> pcii.pci_idsel_in,
    PCI_DEVSEL_oe_o	=> pcio.pci_devsel_en_n, --FIX
    PCI_DEVSEL_i	=> pcii.pci_devsel_in_n,
    PCI_DEVSEL_o	=> pcio.pci_devsel_out_n,
    PCI_TRDY_oe_o	=> pcio.pci_trdy_en_n, --FIX
    PCI_TRDY_i 		=> pcii.pci_trdy_in_n,
    PCI_TRDY_o 		=> pcio.pci_trdy_out_n,
    PCI_STOP_oe_o	=> pcio.pci_stop_en_n, --FIX
    PCI_STOP_i 		=> pcii.pci_stop_in_n,
    PCI_STOP_o 		=> pcio.pci_stop_out_n,
    PCI_PAR_oe_o	=> pcio.pci_par_en_n,
    PCI_PAR_i 		=> pcii.pci_par_in,
    PCI_PAR_o 		=> pcio.pci_par_out,
    PCI_PERR_oe_o	=> pcio.pci_perr_en_n,
    PCI_PERR_i 		=> pcii.pci_perr_in_n,
    PCI_PERR_o 		=> pcio.pci_perr_out_n,
    PCI_SERR_oe_o	=> pcio.pci_serr_en_n,
    PCI_SERR_o 		=> pcio.pci_serr_out_n,

     -- SYSCON Signals
     WB_CLK_I       => clk,
     WB_RST_I       => ocrst,
     WB_RST_O       => Open,
     WB_INT_I       => lowbits(0),--negated and propagated to inta_out
     WB_INT_O       => Open,                      --FIX

     -- WISHBONE slave interface
     WBS_ADR_I       => wbmo.adr_o,
     WBS_DAT_I      => wbmo.mdat_o,
     WBS_DAT_O      => wbmi.mdat_i,
     WBS_SEL_I       => highbits(3 downto 0),
     WBS_CYC_I       => highbits(0),
     WBS_STB_I       => wbmo.stb_o,
     WBS_WE_I        => wbmo.we_o,
     WBS_CAB_I       => wbmo.cab_o,
     WBS_ACK_O       => wbmi.ack_i,
     WBS_RTY_O       => wbmi.rty_i,
     WBS_ERR_O       => Open,

     -- WISHBONE master interface
     WBM_ADR_O       => wbsi.adr_i,
     WBM_DAT_I      => wbso.sdat_o,
     WBM_DAT_O      => wbsi.sdat_i,
     WBM_SEL_O       => Open,
     WBM_CYC_O       => Open,
     WBM_STB_O       => wbsi.stb_i,
     WBM_WE_O        => wbsi.we_i,
     WBM_CAB_O       => Open,
     WBM_ACK_I       => wbso.ack_o,
     WBM_RTY_I       => wbso.rty_o,
     WBM_ERR_I       => lowbits(0)
     );

end;
