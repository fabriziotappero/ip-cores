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
-- Package: 	netcomp
-- File:	netcomp.vhd
-- Author:	Jiri Gaisler - Gaisler Research
-- Description:	Delcation of netlists componnets
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.amba.all;
use work.gencomp.all;

package netcomp is

---------------------------------------------------------------------------
-- netlists ---------------------------------------------------------------
---------------------------------------------------------------------------

component grusbhc_net is
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
    memtech     : integer range 0 to NTECH := DEFMEMTECH
    );
  port (
    clk               : in  std_ulogic;
    uclk              : in  std_ulogic;
    rst               : in  std_ulogic;
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

component grspwc_net 
  generic(
    tech         : integer := 0;
    sysfreq      : integer := 40000;
    usegen       : integer range 0 to 1  := 1;
    nsync        : integer range 1 to 2  := 1; 
    rmap         : integer range 0 to 1  := 0;
    rmapcrc      : integer range 0 to 1  := 0;
    fifosize1    : integer range 4 to 32 := 32;
    fifosize2    : integer range 16 to 64 := 64;
    rxunaligned  : integer range 0 to 1 := 0;
    rmapbufs     : integer range 2 to 8 := 4;
    scantest     : integer range 0 to 1 := 0
  );
  port(
    rst          : in  std_ulogic;
    clk          : in  std_ulogic;
    txclk        : in  std_ulogic;
    --ahb mst in
    hgrant       : in  std_ulogic;
    hready       : in  std_ulogic;   
    hresp        : in  std_logic_vector(1 downto 0);
    hrdata       : in  std_logic_vector(31 downto 0); 
    --ahb mst out
    hbusreq      : out  std_ulogic;        
    hlock        : out  std_ulogic;
    htrans       : out  std_logic_vector(1 downto 0);
    haddr        : out  std_logic_vector(31 downto 0);
    hwrite       : out  std_ulogic;
    hsize        : out  std_logic_vector(2 downto 0);
    hburst       : out  std_logic_vector(2 downto 0);
    hprot        : out  std_logic_vector(3 downto 0);
    hwdata       : out  std_logic_vector(31 downto 0);
    --apb slv in 
    psel	 : in   std_ulogic;
    penable	 : in   std_ulogic;
    paddr	 : in   std_logic_vector(31 downto 0);
    pwrite	 : in   std_ulogic;
    pwdata	 : in   std_logic_vector(31 downto 0);
    --apb slv out
    prdata	 : out  std_logic_vector(31 downto 0);
    --spw in
    di 		 : in std_logic_vector(1 downto 0);
    si 		 : in std_logic_vector(1 downto 0);
    --spw out
    do 		 : out std_logic_vector(1 downto 0);
    so 		 : out std_logic_vector(1 downto 0);
    --time iface
    tickin       : in   std_ulogic;
    tickout      : out  std_ulogic;
    --irq
    irq          : out  std_logic;
    --misc     
    clkdiv10     : in   std_logic_vector(7 downto 0);
    dcrstval     : in   std_logic_vector(9 downto 0);
    timerrstval  : in   std_logic_vector(11 downto 0);
    --rmapen
    rmapen       : in   std_ulogic;
    --clk bufs
    rxclki       : in std_logic_vector(1 downto 0);
    nrxclki      : in std_logic_vector(1 downto 0);
    rxclko       : out std_logic_vector(1 downto 0);
    --rx ahb fifo
    rxrenable    : out  std_ulogic;
    rxraddress   : out  std_logic_vector(4 downto 0);
    rxwrite      : out  std_ulogic;
    rxwdata      : out  std_logic_vector(31 downto 0);
    rxwaddress   : out  std_logic_vector(4 downto 0);
    rxrdata      : in   std_logic_vector(31 downto 0);    
    --tx ahb fifo
    txrenable    : out  std_ulogic;
    txraddress   : out  std_logic_vector(4 downto 0);
    txwrite      : out  std_ulogic;
    txwdata      : out  std_logic_vector(31 downto 0);
    txwaddress   : out  std_logic_vector(4 downto 0);
    txrdata      : in   std_logic_vector(31 downto 0);    
    --nchar fifo
    ncrenable    : out  std_ulogic;
    ncraddress   : out  std_logic_vector(5 downto 0);
    ncwrite      : out  std_ulogic;
    ncwdata      : out  std_logic_vector(8 downto 0);
    ncwaddress   : out  std_logic_vector(5 downto 0);
    ncrdata      : in   std_logic_vector(8 downto 0);
    --rmap buf
    rmrenable    : out  std_ulogic;
    rmraddress   : out  std_logic_vector(7 downto 0);
    rmwrite      : out  std_ulogic;
    rmwdata      : out  std_logic_vector(7 downto 0);
    rmwaddress   : out  std_logic_vector(7 downto 0);
    rmrdata      : in   std_logic_vector(7 downto 0);
    linkdis      : out  std_ulogic;
    testclk      : in   std_ulogic := '0';
    testrst      : in   std_ulogic := '0';
    testen       : in   std_ulogic := '0'
  );
end component;

  component grlfpw_net 
  generic (tech     : integer := 0;
           pclow    : integer range 0 to 2 := 2;
           dsu      : integer range 0 to 1 := 1;           
           disas    : integer range 0 to 2 := 0;
           pipe     : integer range 0 to 2 := 0
           );
  port (
    rst    : in  std_ulogic;			-- Reset
    clk    : in  std_ulogic;
    holdn  : in  std_ulogic;			-- pipeline hold
    cpi_flush  	: in std_ulogic;			  -- pipeline flush
    cpi_exack    	: in std_ulogic;			  -- FP exception acknowledge
    cpi_a_rs1  	: in std_logic_vector(4 downto 0);
    cpi_d_pc    : in std_logic_vector(31 downto 0);
    cpi_d_inst  : in std_logic_vector(31 downto 0);
    cpi_d_cnt   : in std_logic_vector(1 downto 0);
    cpi_d_trap  : in std_ulogic;
    cpi_d_annul : in std_ulogic;
    cpi_d_pv    : in std_ulogic;
    cpi_a_pc    : in std_logic_vector(31 downto 0);
    cpi_a_inst  : in std_logic_vector(31 downto 0);
    cpi_a_cnt   : in std_logic_vector(1 downto 0);
    cpi_a_trap  : in std_ulogic;
    cpi_a_annul : in std_ulogic;
    cpi_a_pv    : in std_ulogic;
    cpi_e_pc    : in std_logic_vector(31 downto 0);
    cpi_e_inst  : in std_logic_vector(31 downto 0);
    cpi_e_cnt   : in std_logic_vector(1 downto 0);
    cpi_e_trap  : in std_ulogic;
    cpi_e_annul : in std_ulogic;
    cpi_e_pv    : in std_ulogic;
    cpi_m_pc    : in std_logic_vector(31 downto 0);
    cpi_m_inst  : in std_logic_vector(31 downto 0);
    cpi_m_cnt   : in std_logic_vector(1 downto 0);
    cpi_m_trap  : in std_ulogic;
    cpi_m_annul : in std_ulogic;
    cpi_m_pv    : in std_ulogic;
    cpi_x_pc    : in std_logic_vector(31 downto 0);
    cpi_x_inst  : in std_logic_vector(31 downto 0);
    cpi_x_cnt   : in std_logic_vector(1 downto 0);
    cpi_x_trap  : in std_ulogic;
    cpi_x_annul : in std_ulogic;
    cpi_x_pv    : in std_ulogic;    
    cpi_lddata        : in std_logic_vector(31 downto 0);     -- load data
    cpi_dbg_enable : in std_ulogic;
    cpi_dbg_write  : in std_ulogic;
    cpi_dbg_fsr    : in std_ulogic;                            -- FSR access
    cpi_dbg_addr   : in std_logic_vector(4 downto 0);
    cpi_dbg_data   : in std_logic_vector(31 downto 0);
    cpo_data          : out std_logic_vector(31 downto 0); -- store data
    cpo_exc  	        : out std_logic;			 -- FP exception
    cpo_cc           : out std_logic_vector(1 downto 0);  -- FP condition codes
    cpo_ccv  	       : out std_ulogic;			 -- FP condition codes valid
    cpo_ldlock       : out std_logic;			 -- FP pipeline hold
    cpo_holdn         : out std_ulogic;
    cpo_dbg_data     : out std_logic_vector(31 downto 0);

    rfi1_rd1addr 	: out std_logic_vector(3 downto 0); 
    rfi1_rd2addr 	: out std_logic_vector(3 downto 0); 
    rfi1_wraddr 	: out std_logic_vector(3 downto 0); 
    rfi1_wrdata 	: out std_logic_vector(31 downto 0);
    rfi1_ren1        : out std_ulogic;			   
    rfi1_ren2        : out std_ulogic;			   
    rfi1_wren        : out std_ulogic;			   
    
    rfi2_rd1addr 	: out std_logic_vector(3 downto 0); 
    rfi2_rd2addr 	: out std_logic_vector(3 downto 0); 
    rfi2_wraddr 	: out std_logic_vector(3 downto 0); 
    rfi2_wrdata 	: out std_logic_vector(31 downto 0);
    rfi2_ren1        : out std_ulogic;
    rfi2_ren2        : out std_ulogic;			    
    rfi2_wren        : out std_ulogic;

    rfo1_data1    	: in std_logic_vector(31 downto 0);
    rfo1_data2    	: in std_logic_vector(31 downto 0);
    rfo2_data1    	: in std_logic_vector(31 downto 0);
    rfo2_data2    	: in std_logic_vector(31 downto 0)        
    );
  end component;

  component grfpw_net 
  generic (tech     : integer := 0;
           pclow    : integer range 0 to 2 := 2;
           dsu      : integer range 0 to 2 := 1;           
           disas    : integer range 0 to 2 := 0;
           pipe     : integer range 0 to 2 := 0
           );
  port (
    rst    : in  std_ulogic;			-- Reset
    clk    : in  std_ulogic;
    holdn  : in  std_ulogic;			-- pipeline hold
    cpi_flush  	: in std_ulogic;			  -- pipeline flush
    cpi_exack    	: in std_ulogic;			  -- FP exception acknowledge
    cpi_a_rs1  	: in std_logic_vector(4 downto 0);
    cpi_d_pc    : in std_logic_vector(31 downto 0);
    cpi_d_inst  : in std_logic_vector(31 downto 0);
    cpi_d_cnt   : in std_logic_vector(1 downto 0);
    cpi_d_trap  : in std_ulogic;
    cpi_d_annul : in std_ulogic;
    cpi_d_pv    : in std_ulogic;
    cpi_a_pc    : in std_logic_vector(31 downto 0);
    cpi_a_inst  : in std_logic_vector(31 downto 0);
    cpi_a_cnt   : in std_logic_vector(1 downto 0);
    cpi_a_trap  : in std_ulogic;
    cpi_a_annul : in std_ulogic;
    cpi_a_pv    : in std_ulogic;
    cpi_e_pc    : in std_logic_vector(31 downto 0);
    cpi_e_inst  : in std_logic_vector(31 downto 0);
    cpi_e_cnt   : in std_logic_vector(1 downto 0);
    cpi_e_trap  : in std_ulogic;
    cpi_e_annul : in std_ulogic;
    cpi_e_pv    : in std_ulogic;
    cpi_m_pc    : in std_logic_vector(31 downto 0);
    cpi_m_inst  : in std_logic_vector(31 downto 0);
    cpi_m_cnt   : in std_logic_vector(1 downto 0);
    cpi_m_trap  : in std_ulogic;
    cpi_m_annul : in std_ulogic;
    cpi_m_pv    : in std_ulogic;
    cpi_x_pc    : in std_logic_vector(31 downto 0);
    cpi_x_inst  : in std_logic_vector(31 downto 0);
    cpi_x_cnt   : in std_logic_vector(1 downto 0);
    cpi_x_trap  : in std_ulogic;
    cpi_x_annul : in std_ulogic;
    cpi_x_pv    : in std_ulogic;    
    cpi_lddata        : in std_logic_vector(31 downto 0);     -- load data
    cpi_dbg_enable : in std_ulogic;
    cpi_dbg_write  : in std_ulogic;
    cpi_dbg_fsr    : in std_ulogic;                            -- FSR access
    cpi_dbg_addr   : in std_logic_vector(4 downto 0);
    cpi_dbg_data   : in std_logic_vector(31 downto 0);
    cpo_data          : out std_logic_vector(31 downto 0); -- store data
    cpo_exc  	        : out std_logic;			 -- FP exception
    cpo_cc           : out std_logic_vector(1 downto 0);  -- FP condition codes
    cpo_ccv  	       : out std_ulogic;			 -- FP condition codes valid
    cpo_ldlock       : out std_logic;			 -- FP pipeline hold
    cpo_holdn         : out std_ulogic;
    cpo_dbg_data     : out std_logic_vector(31 downto 0);

    rfi1_rd1addr 	: out std_logic_vector(3 downto 0); 
    rfi1_rd2addr 	: out std_logic_vector(3 downto 0); 
    rfi1_wraddr 	: out std_logic_vector(3 downto 0); 
    rfi1_wrdata 	: out std_logic_vector(31 downto 0);
    rfi1_ren1        : out std_ulogic;			   
    rfi1_ren2        : out std_ulogic;			   
    rfi1_wren        : out std_ulogic;			   
    
    rfi2_rd1addr 	: out std_logic_vector(3 downto 0); 
    rfi2_rd2addr 	: out std_logic_vector(3 downto 0); 
    rfi2_wraddr 	: out std_logic_vector(3 downto 0); 
    rfi2_wrdata 	: out std_logic_vector(31 downto 0);
    rfi2_ren1        : out std_ulogic;
    rfi2_ren2        : out std_ulogic;			    
    rfi2_wren        : out std_ulogic;

    rfo1_data1    	: in std_logic_vector(31 downto 0);
    rfo1_data2    	: in std_logic_vector(31 downto 0);
    rfo2_data1    	: in std_logic_vector(31 downto 0);
    rfo2_data2    	: in std_logic_vector(31 downto 0)        
    );
  end component;

  component leon3ft_net
  generic (
    hindex    : integer               := 0;
    fabtech   : integer range 0 to NTECH  := DEFFABTECH;
    memtech   : integer range 0 to NTECH  := DEFMEMTECH;
    nwindows  : integer range 2 to 32 := 8;
    dsu       : integer range 0 to 1  := 0;
    fpu       : integer range 0 to 31 := 0;
    v8        : integer range 0 to 63 := 0;
    cp        : integer range 0 to 1  := 0;
    mac       : integer range 0 to 1  := 0;
    pclow     : integer range 0 to 2  := 2;
    notag     : integer range 0 to 1  := 0;
    nwp       : integer range 0 to 4  := 0;
    icen      : integer range 0 to 1  := 0;
    irepl     : integer range 0 to 2  := 2;
    isets     : integer range 1 to 4  := 1;
    ilinesize : integer range 4 to 8  := 4;
    isetsize  : integer range 1 to 256 := 1;
    isetlock  : integer range 0 to 1  := 0;
    dcen      : integer range 0 to 1  := 0;
    drepl     : integer range 0 to 2  := 2;
    dsets     : integer range 1 to 4  := 1;
    dlinesize : integer range 4 to 8  := 4;
    dsetsize  : integer range 1 to 256 := 1;
    dsetlock  : integer range 0 to 1  := 0;
    dsnoop    : integer range 0 to 6  := 0;
    ilram      : integer range 0 to 1 := 0;
    ilramsize  : integer range 1 to 512 := 1;
    ilramstart : integer range 0 to 255 := 16#8e#;
    dlram      : integer range 0 to 1 := 0;
    dlramsize  : integer range 1 to 512 := 1;
    dlramstart : integer range 0 to 255 := 16#8f#;
    mmuen     : integer range 0 to 1  := 0;
    itlbnum   : integer range 2 to 64 := 8;
    dtlbnum   : integer range 2 to 64 := 8;
    tlb_type  : integer range 0 to 3  := 1;
    tlb_rep   : integer range 0 to 1  := 0;
    lddel     : integer range 1 to 2  := 2;
    disas     : integer range 0 to 2  := 0;
    tbuf      : integer range 0 to 64 := 0;
    pwd       : integer range 0 to 2  := 2;     -- power-down
    svt       : integer range 0 to 1  := 1;     -- single vector trapping
    rstaddr   : integer               := 0;
    smp       : integer range 0 to 15 := 0;    -- support SMP systems
    iuft      : integer range 0 to 4  := 0;
    fpft      : integer range 0 to 4  := 0;
    cmft      : integer range 0 to 1  := 0;
    cached    : integer               := 0;
    scantest  : integer               := 0
  );

   port (
      clk     : in  std_ulogic;
      gclk    : in  std_ulogic;
      rstn    : in  std_ulogic;
      ahbi    : in  ahb_mst_in_type;
      ahbo    : out ahb_mst_out_type;
      ahbsi   : in  ahb_slv_in_type;
      ahbso   : in  ahb_slv_out_vector;
      irqi_irl:         in    std_logic_vector(3 downto 0);
      irqi_rst:         in    std_ulogic;
      irqi_run:         in    std_ulogic;

      irqo_intack:      out   std_ulogic;
      irqo_irl:         out   std_logic_vector(3 downto 0);
      irqo_pwd:         out   std_ulogic;

      dbgi_dsuen:       in    std_ulogic;                               -- DSU enable
      dbgi_denable:     in    std_ulogic;                               -- diagnostic register access enable
      dbgi_dbreak:      in    std_ulogic;                               -- debug break-in
      dbgi_step:        in    std_ulogic;                               -- single step
      dbgi_halt:        in    std_ulogic;                               -- halt processor
      dbgi_reset:       in    std_ulogic;                               -- reset processor
      dbgi_dwrite:      in    std_ulogic;                               -- read/write
      dbgi_daddr:       in    std_logic_vector(23 downto 2);            -- diagnostic address
      dbgi_ddata:       in    std_logic_vector(31 downto 0);            -- diagnostic data
      dbgi_btrapa:      in    std_ulogic;                               -- break on IU trap
      dbgi_btrape:      in    std_ulogic;                               -- break on IU trap
      dbgi_berror:      in    std_ulogic;                               -- break on IU error mode
      dbgi_bwatch:      in    std_ulogic;                               -- break on IU watchpoint
      dbgi_bsoft:       in    std_ulogic;                               -- break on software breakpoint (TA 1)
      dbgi_tenable:     in    std_ulogic;
      dbgi_timer:       in    std_logic_vector(30 downto 0);

      dbgo_data:        out   std_logic_vector(31 downto 0);
      dbgo_crdy:        out   std_ulogic;
      dbgo_dsu:         out   std_ulogic;
      dbgo_dsumode:     out   std_ulogic;
      dbgo_error:       out   std_ulogic;
      dbgo_halt:        out   std_ulogic;
      dbgo_pwd:         out   std_ulogic;
      dbgo_idle:        out   std_ulogic;
      dbgo_ipend:       out   std_ulogic;
      dbgo_icnt:        out   std_ulogic
);

  end component;

component ftmctrl_net
   generic (
    hindex    : integer := 0;
    pindex    : integer := 0;
    romaddr   : integer := 16#000#;
    rommask   : integer := 16#E00#;
    ioaddr    : integer := 16#200#;
    iomask    : integer := 16#E00#;
    ramaddr   : integer := 16#400#;
    rammask   : integer := 16#C00#;
    paddr     : integer := 0;
    pmask     : integer := 16#fff#;
    wprot     : integer := 0;
    invclk    : integer := 0;
    fast      : integer := 0;
    romasel   : integer := 28;
    sdrasel   : integer := 29;
    srbanks   : integer := 4;
    ram8      : integer := 0;
    ram16     : integer := 0;
    sden      : integer := 0;
    sepbus    : integer := 0;
    sdbits    : integer := 32;
    sdlsb     : integer := 2;          -- set to 12 for the GE-HPE board
    oepol     : integer := 0;
    edac      : integer := 0;
    syncrst   : integer := 0;
    pageburst : integer := 0;
    scantest  : integer := 0;
    writefb   : integer := 0;
    tech      : integer := 0
  );
   port (
      rst:     in    Std_ULogic;
      clk:     in    Std_ULogic;
      ahbsi:   in    ahb_slv_in_type;
      ahbso:   out   ahb_slv_out_type;
      apbi:    in    apb_slv_in_type;
      apbo:    out   apb_slv_out_type;
      memi_data:        in    Std_Logic_Vector(31 downto 0);
      memi_brdyn:       in    Std_Logic;
      memi_bexcn:       in    Std_Logic;
      memi_writen:      in    Std_Logic;
      memi_wrn:         in    Std_Logic_Vector(3 downto 0);
      memi_bwidth:      in    Std_Logic_Vector(1 downto 0);
      memi_sd:          in    Std_Logic_Vector(63 downto 0);
      memi_cb:          in    Std_Logic_Vector(15 downto 0);
      memi_scb:         in    Std_Logic_Vector(15 downto 0);
      memi_edac:        in    Std_Logic;
      memo_address:     out   Std_Logic_Vector(31 downto 0);
      memo_data:        out   Std_Logic_Vector(31 downto 0);
      memo_sddata:      out   Std_Logic_Vector(63 downto 0);
      memo_ramsn:       out   Std_Logic_Vector(7 downto 0);
      memo_ramoen:      out   Std_Logic_Vector(7 downto 0);
      memo_ramn:        out   Std_ULogic;
      memo_romn:        out   Std_ULogic;
      memo_mben:        out   Std_Logic_Vector(3 downto 0);
      memo_iosn:        out   Std_Logic;
      memo_romsn:       out   Std_Logic_Vector(7 downto 0);
      memo_oen:         out   Std_Logic;
      memo_writen:      out   Std_Logic;
      memo_wrn:         out   Std_Logic_Vector(3 downto 0);
      memo_bdrive:      out   Std_Logic_Vector(3 downto 0);
      memo_vbdrive:     out   Std_Logic_Vector(31 downto 0);
      memo_svbdrive:    out   Std_Logic_Vector(63 downto 0);
      memo_read:        out   Std_Logic;
      memo_sa:          out   Std_Logic_Vector(14 downto 0);
      memo_cb:          out   Std_Logic_Vector(15 downto 0);
      memo_scb:         out   Std_Logic_Vector(15 downto 0);
      memo_vcdrive:     out   Std_Logic_Vector(15 downto 0);
      memo_svcdrive:    out   Std_Logic_Vector(15 downto 0);
      memo_ce:          out   Std_ULogic;
      sdo_sdcke:        out   Std_Logic_Vector( 1 downto 0);
      sdo_sdcsn:        out   Std_Logic_Vector( 1 downto 0);
      sdo_sdwen:        out   Std_ULogic;
      sdo_rasn:         out   Std_ULogic;
      sdo_casn:         out   Std_ULogic;
      sdo_dqm:          out   Std_Logic_Vector( 7 downto 0);
      wpo_wprothit:     in    Std_ULogic);

end component;

component ssrctrl_net
   generic (
      tech:                   Integer := 0;
      bus16:                  Integer := 1);
   port (
      rst:              in    Std_Logic;
      clk:              in    Std_Logic;

      n_ahbsi_hsel:     in    Std_Logic_Vector(0 to 15);
      n_ahbsi_haddr:    in    Std_Logic_Vector(31 downto 0);
      n_ahbsi_hwrite:   in    Std_Logic;
      n_ahbsi_htrans:   in    Std_Logic_Vector(1 downto 0);
      n_ahbsi_hsize:    in    Std_Logic_Vector(2 downto 0);
      n_ahbsi_hburst:   in    Std_Logic_Vector(2 downto 0);
      n_ahbsi_hwdata:   in    Std_Logic_Vector(31 downto 0);
      n_ahbsi_hprot:    in    Std_Logic_Vector(3 downto 0);
      n_ahbsi_hready:   in    Std_Logic;
      n_ahbsi_hmaster:  in    Std_Logic_Vector(3 downto 0);
      n_ahbsi_hmastlock:in    Std_Logic;
      n_ahbsi_hmbsel:   in    Std_Logic_Vector(0 to 3);
      n_ahbsi_hcache:   in    Std_Logic;
      n_ahbsi_hirq:     in    Std_Logic_Vector(31 downto 0);

      n_ahbso_hready:   out   Std_Logic;
      n_ahbso_hresp:    out   Std_Logic_Vector(1 downto 0);
      n_ahbso_hrdata:   out   Std_Logic_Vector(31 downto 0);
      n_ahbso_hsplit:   out   Std_Logic_Vector(15 downto 0);
      n_ahbso_hcache:   out   Std_Logic;
      n_ahbso_hirq:     out   Std_Logic_Vector(31 downto 0);

      n_apbi_psel:      in    Std_Logic_Vector(0 to 15);
      n_apbi_penable:   in    Std_Logic;
      n_apbi_paddr:     in    Std_Logic_Vector(31 downto 0);
      n_apbi_pwrite:    in    Std_Logic;
      n_apbi_pwdata:    in    Std_Logic_Vector(31 downto 0);
      n_apbi_pirq:      in    Std_Logic_Vector(31 downto 0);

      n_apbo_prdata:    out   Std_Logic_Vector(31 downto 0);
      n_apbo_pirq:      out   Std_Logic_Vector(31 downto 0);

      n_sri_data:       in    Std_Logic_Vector(31 downto 0);
      n_sri_brdyn:      in    Std_Logic;
      n_sri_bexcn:      in    Std_Logic;
      n_sri_writen:     in    Std_Logic;
      n_sri_wrn:        in    Std_Logic_Vector(3 downto 0);
      n_sri_bwidth:     in    Std_Logic_Vector(1 downto 0);
      n_sri_sd:         in    Std_Logic_Vector(63 downto 0);
      n_sri_cb:         in    Std_Logic_Vector(7 downto 0);
      n_sri_scb:        in    Std_Logic_Vector(7 downto 0);
      n_sri_edac:       in    Std_Logic;

      n_sro_address:    out   Std_Logic_Vector(31 downto 0);
      n_sro_data:       out   Std_Logic_Vector(31 downto 0);
      n_sro_sddata:     out   Std_Logic_Vector(63 downto 0);
      n_sro_ramsn:      out   Std_Logic_Vector(7 downto 0);
      n_sro_ramoen:     out   Std_Logic_Vector(7 downto 0);
      n_sro_ramn:       out   Std_Logic;
      n_sro_romn:       out   Std_Logic;
      n_sro_mben:       out   Std_Logic_Vector(3 downto 0);
      n_sro_iosn:       out   Std_Logic;
      n_sro_romsn:      out   Std_Logic_Vector(7 downto 0);
      n_sro_oen:        out   Std_Logic;
      n_sro_writen:     out   Std_Logic;
      n_sro_wrn:        out   Std_Logic_Vector(3 downto 0);
      n_sro_bdrive:     out   Std_Logic_Vector(3 downto 0);
      n_sro_vbdrive:    out   Std_Logic_Vector(31 downto 0);
      n_sro_svbdrive:   out   Std_Logic_Vector(63 downto 0);
      n_sro_read:       out   Std_Logic;
      n_sro_sa:         out   Std_Logic_Vector(14 downto 0);
      n_sro_cb:         out   Std_Logic_Vector(7 downto 0);
      n_sro_scb:        out   Std_Logic_Vector(7 downto 0);
      n_sro_vcdrive:    out   Std_Logic_Vector(7 downto 0);
      n_sro_svcdrive:   out   Std_Logic_Vector(7 downto 0);
      n_sro_ce:         out   Std_Logic);
end component;

end;
