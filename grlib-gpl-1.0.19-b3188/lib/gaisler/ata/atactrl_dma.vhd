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
-- Entity: atactrl 
-- File: atactrl.vhd
-- Author:  Nils-Johan Wessman, Gaisler Research
-- Description: ATA controller
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library grlib;
use grlib.stdlib.all;
use grlib.amba.all;
use grlib.devices.all;
library gaisler;
use gaisler.memctrl.all;
use gaisler.ata.all;
use gaisler.misc.all; --2007-1-16
use gaisler.ata_inf.all;
library opencores;
use opencores.occomp.all;

entity atactrl_dma is
 generic (
   tech    : integer := 0;
   fdepth  : integer := 8;
   mhindex : integer := 0;
   hindex  : integer := 0;
   haddr   : integer := 0;
   hmask   : integer := 16#ff0#;
   pirq    : integer := 0;
  
   TWIDTH : natural := 8;                      -- counter width
   
   -- PIO mode 0 settings (@100MHz clock)
   PIO_mode0_T1 : natural := 6;                -- 70ns
   PIO_mode0_T2 : natural := 28;               -- 290ns
   PIO_mode0_T4 : natural := 2;                -- 30ns
   PIO_mode0_Teoc : natural := 23              -- 240ns ==> T0 - T1 - T2 = 600 - 70 - 290 = 240
    
 );
 port (
   rst     : in  std_ulogic;
   arst    : in  std_ulogic;
   clk     : in  std_ulogic;
   ahbsi   : in  ahb_slv_in_type;
   ahbso   : out ahb_slv_out_type;
   ahbmi   : in  ahb_mst_in_type;
   ahbmo   : out ahb_mst_out_type;
   cfo     : out cf_out_type;
   
   -- ATA signals
   ddin       : in  std_logic_vector(15 downto 0);
   iordy      : in  std_logic;
   intrq      : in  std_logic;
   ata_resetn : out std_logic;
   ddout      : out std_logic_vector(15 downto 0);
   ddoe       : out std_logic;
   da         : out std_logic_vector(2 downto 0);
   cs0n       : out std_logic;
   cs1n       : out std_logic;
   diorn      : out std_logic;
   diown      : out std_logic;
   dmack      : out std_logic;
   dmarq      : in std_logic
 );
end; 


architecture rtl of atactrl_dma is
   -- Device ID
   constant DeviceId : integer := 2;
   constant RevisionNo : integer := 0;
   constant VERSION : integer := 0;
   
   component atahost_amba_slave is
   generic (
      hindex  : integer := 0;
      haddr   : integer := 0;
      hmask   : integer := 16#ff0#;
      pirq    : integer := 0;
      DeviceID   : integer := 0;
      RevisionNo : integer := 0;
   
      -- PIO mode 0 settings (@100MHz clock)
      PIO_mode0_T1 : natural := 6;                -- 70ns
      PIO_mode0_T2 : natural := 28;               -- 290ns
      PIO_mode0_T4 : natural := 2;                -- 30ns
      PIO_mode0_Teoc : natural := 23;             -- 240ns ==> T0 - T1 - T2 = 600 - 70 - 290 = 240
       
      -- Multiword DMA mode 0 settings (@100MHz clock)
      DMA_mode0_Tm : natural := 4;                -- 50ns
      DMA_mode0_Td : natural := 21;               -- 215ns
      DMA_mode0_Teoc : natural := 21              -- 215ns ==> T0 - Td - Tm = 480 - 50 - 215 = 215
   );
   port (
      rst     : in  std_ulogic;
      arst    : in  std_ulogic;
      clk     : in  std_ulogic;
      ahbsi   : in  ahb_slv_in_type;
      ahbso   : out ahb_slv_out_type;
      cf_power: out std_logic;
      
      -- ata controller signals
   
      -- PIO control input
      PIOsel     : out std_logic;
      PIOtip,                                         -- PIO transfer in progress
      PIOack     : in std_logic;                      -- PIO acknowledge signal
      PIOq       : in std_logic_vector(15 downto 0);  -- PIO data input
      PIOpp_full : in std_logic;                      -- PIO write-ping-pong buffers full
      irq        : in std_logic;                      -- interrupt signal input
      PIOa       : out std_logic_vector(3 downto 0);
      PIOd       : out std_logic_vector(15 downto 0);
      PIOwe      : out std_logic;

      -- DMA control inputs
--      DMAsel    : out std_logic;
      DMAtip,                                     -- DMA transfer in progress
--      DMAack,                                     -- DMA transfer acknowledge
      DMARxEmpty,                                 -- DMA receive buffer empty
      DMATxFull,                                  -- DMA transmit buffer full
      DMA_dmarq : in std_logic;                   -- wishbone DMA request
--      DMAq      : in std_logic_vector(31 downto 0);
    
      -- outputs
      -- control register outputs
      IDEctrl_rst,
      IDEctrl_IDEen,
      IDEctrl_FATR1,
      IDEctrl_FATR0,
      IDEctrl_ppen,
      DMActrl_DMAen,
      DMActrl_dir,
      DMActrl_Bytesw, --Jagre 2006-12-04      
      DMActrl_BeLeC0,
      DMActrl_BeLeC1 : out std_logic;
    
      -- CMD port timing registers
      PIO_cmdport_T1,
      PIO_cmdport_T2,
      PIO_cmdport_T4,
      PIO_cmdport_Teoc    : out std_logic_vector(7 downto 0);
      PIO_cmdport_IORDYen : out std_logic;
    
      -- data-port0 timing registers
      PIO_dport0_T1,
      PIO_dport0_T2,
      PIO_dport0_T4,
      PIO_dport0_Teoc    : out std_logic_vector(7 downto 0);
      PIO_dport0_IORDYen : out std_logic;
    
      -- data-port1 timing registers
      PIO_dport1_T1,
      PIO_dport1_T2,
      PIO_dport1_T4,
      PIO_dport1_Teoc    : out std_logic_vector(7 downto 0);
      PIO_dport1_IORDYen : out std_logic;
    
      -- DMA device0 timing registers
      DMA_dev0_Tm,
      DMA_dev0_Td,
      DMA_dev0_Teoc    : out std_logic_vector(7 downto 0);
    
      -- DMA device1 timing registers
      DMA_dev1_Tm,
      DMA_dev1_Td,
      DMA_dev1_Teoc    : out std_logic_vector(7 downto 0);

      -- Bus master edits     by Erik Jagre 2006-10-03 ------------------start-----
      fr_BM : in bm_to_slv_type;
      to_BM : out slv_to_bm_type
      -- Bus master edits     by Erik Jagre 2006-10-03 ------------------end-------

   );
   end component atahost_amba_slave; 
   

   component atahost_ahbmst is
   generic(fdepth : integer := 8);
   Port(clk : in std_logic;
        rst : in std_logic;
        i   : in bmi_type;
        o   : out bmo_type
     );
   end component atahost_ahbmst;
         
   -- asynchronous reset signal
   signal arst_signal : std_logic;
   
   -- primary address decoder
--   signal PIOsel,s_bmen  : std_logic;  -- controller select, IDE devices select
   signal PIOsel  : std_logic;  -- controller select, IDE devices select
   
   -- control signal 
   signal IDEctrl_rst, IDEctrl_IDEen, IDEctrl_FATR0, IDEctrl_FATR1 : std_logic;
   -- compatible mode timing 
   signal s_PIO_cmdport_T1, s_PIO_cmdport_T2, s_PIO_cmdport_T4, s_PIO_cmdport_Teoc : std_logic_vector(7 downto 0);
   signal s_PIO_cmdport_IORDYen : std_logic;
   -- data port0 timing 
   signal s_PIO_dport0_T1, s_PIO_dport0_T2, s_PIO_dport0_T4, s_PIO_dport0_Teoc : std_logic_vector(7 downto 0);
   signal s_PIO_dport0_IORDYen : std_logic;
   -- data port1 timing 
   signal s_PIO_dport1_T1, s_PIO_dport1_T2, s_PIO_dport1_T4, s_PIO_dport1_Teoc : std_logic_vector(7 downto 0);
   signal s_PIO_dport1_IORDYen : std_logic;
   
   signal PIOack : std_logic;
   signal PIOq   : std_logic_vector(15 downto 0);
   signal PIOa   : std_logic_vector(3 downto 0):="0000";
   signal PIOd   : std_logic_vector(15 downto 0) := X"0000";
   signal PIOwe  : std_logic;
   
   signal irq : std_logic; -- ATA bus IRQ signal

   signal reset   : std_logic;
   signal gnd,vcc : std_logic;
   signal gnd32   : std_logic_vector(31 downto 0);

  --**********************SIGNAL DECLARATION*****by Erik Jagre 2006-10-04*******
  signal s_PIOtip : std_logic:='0';                    -- PIO transfer in progress
  signal s_PIOpp_full : std_logic:='0';                   -- PIO Write PingPong full

  -- DMA registers
  signal s_DMA_dev0_Td,
  s_DMA_dev0_Tm,
  s_DMA_dev0_Teoc :  std_logic_vector(7 downto 0):= X"03";      -- DMA timing settings for device0

  signal s_DMA_dev1_Td,
  s_DMA_dev1_Tm,
  s_DMA_dev1_Teoc :  std_logic_vector(7 downto 0):= X"03";      -- DMA timing settings for device1

  signal s_DMActrl_DMAen,
  s_DMActrl_dir,
  s_DMActrl_Bytesw,
  s_DMActrl_BeLeC0,
  s_DMActrl_BeLeC1 :  std_logic:='0';                -- DMA settings

--  signal s_DMAsel :  std_logic:='0';                        -- DMA controller select
--  signal s_DMAack :  std_logic:='0';                       -- DMA controller acknowledge
--  signal s_DMAq :  std_logic_vector(31 downto 0);     -- DMA data out
--  signal s_DMAtip :  std_logic:='0';                    -- DMA transfer in progress
  signal s_DMA_dmarq :  std_logic:='0';                    -- Synchronized ATA DMARQ line

--  signal s_DMATxFull :  std_logic:='0';                 -- DMA transmit buffer full
--  signal s_DMARxEmpty :  std_logic:='0';                -- DMA receive buffer empty
--  signal s_DMA_req :  std_logic:='0';                      -- DMA request to external DMA engine
--  signal s_DMA_ack :  std_logic:='0';                       -- DMA acknowledge from external DMA engine
  
  signal s_IDEctrl_ppen : std_logic; --:='0';
  signal datemp : std_logic_vector(2 downto 0):="000";

--  signal s_mst_bm : ahb_dma_out_type;
--  signal s_bm_mst : ahb_dma_in_type;

--  signal s_slv_bm : slv_to_bm_type := SLV_TO_BM_RESET_VECTOR;
--  signal s_bm_slv : bm_to_slv_type := BM_TO_SLV_RESET_VECTOR;

--  signal s_bm_ctr : bm_to_ctrl_type;
--  signal s_ctr_bm : ctrl_to_bm_type;

  signal s_bmi : bmi_type;
  signal s_bmo : bmo_type;
  
  signal s_d : std_logic_vector(31 downto 0);
  signal s_we, s_irq : std_logic; 
  
  constant DMA_mode0_Tm : natural := 4;                -- 50ns
  constant DMA_mode0_Td : natural := 21;               -- 215ns
  constant DMA_mode0_Teoc : natural := 21;              -- 215ns ==> T0 - Td - Tm = 480 - 50 - 215 = 215
  constant SECTOR_LENGTH : integer := 16;
  
--  signal PIOa_temp : std_logic_vector(7 downto 0);
  --**********************END SIGNAL DECLARATION********************************

begin
   gnd <= '0';vcc <= '1'; gnd32 <= zero32;
   -- generate asynchronous reset level
   arst_signal <= arst;-- xor ARST_LVL;
   reset <= not rst;
   da<=datemp;
   --PIOa_temp <= unsigned(PIOa);
   --dmack <= vcc; -- Disable DMA
   -- Generate CompactFlash signals
   --cfo.power connected to bit 31 of the control register
   cfo.atasel <= gnd;
   cfo.we <= vcc;
   cfo.csel <= gnd;
   cfo.da <= (others => gnd);
   
   --s_bmi.fr_mst<=s_mst_bm; s_bmi.fr_slv<=s_slv_bm; s_bmi.fr_ctr<=s_ctr_bm;
   --s_bmo.to_mst<=s_bm_mst; s_bmo.to_slv<=s_slv_bm; s_bmo.to_ctr<=s_bm_ctr;


   with s_bmi.fr_slv.en select
     s_d(15 downto 0)<=s_bmo.d(15 downto 0) when '1',
                       PIOd  when others;

   with s_bmi.fr_slv.en select
     s_d(31 downto 16)<=s_bmo.d(31 downto 16) when '1',
                        (others=>'0')  when others;

   with s_bmi.fr_slv.en select
     s_we<=s_bmo.we when '1',
           PIOwe  when others;
           
   with s_bmi.fr_slv.en select --for guaranteeing coherent memory before irq
     s_irq<=irq and (not s_bmo.to_mst.start) when '1',
            irq when others;

   s_bmi.fr_ctr.irq<=irq;

   slv: atahost_amba_slave 
      generic map(
         hindex  => hindex,
         haddr   => haddr,
         hmask   => hmask,
         pirq    => pirq,
         DeviceID   => DeviceID,
         RevisionNo => RevisionNo,

         -- PIO mode 0 settings
         PIO_mode0_T1 => PIO_mode0_T1,
         PIO_mode0_T2 => PIO_mode0_T2,
         PIO_mode0_T4 => PIO_mode0_T4,
         PIO_mode0_Teoc => PIO_mode0_Teoc,

         -- Multiword DMA mode 0 settings
         -- OCIDEC-1 does not support DMA, set registers to zero
         DMA_mode0_Tm   => 0,
         DMA_mode0_Td   => 0,
         DMA_mode0_Teoc => 0
      )
      port map(
         arst  => arst_signal,
         rst   => rst,
         clk   => clk,
         ahbsi => ahbsi,
         ahbso => ahbso,
         
         cf_power => cfo.power, -- power switch for compactflash 
         
         -- PIO control input
         -- PIOtip is only asserted during a PIO transfer (No shit! ;)
         -- Since it is impossible to read the status register and access the PIO registers at the same time
         -- this bit is useless (besides using-up resources)
         PIOtip     => gnd,
         PIOack     => PIOack,
         PIOq       => PIOq,
         PIOsel     => PIOsel,
         PIOpp_full => gnd, -- OCIDEC-1 does not support PIO-write PingPong, negate signal
         irq        => s_irq,
         PIOa       => PIOa,
         PIOd       => PIOd,
         PIOwe      => PIOwe,

         -- DMA control inputs (negate all of them)
         DMAtip     => s_bmi.fr_ctr.tip, --Erik Jagre 2006-11-13
--         DMAack     => gnd,
         DMARxEmpty => s_bmi.fr_ctr.rx_empty, --Erik Jagre 2006-11-13
         DMATxFull  => s_bmi.fr_ctr.fifo_rdy, --Erik Jagre 2006-11-13
         DMA_dmarq  => s_DMA_dmarq, --Erik Jagre 2006-11-13
--         DMAq       => gnd32,

         -- outputs
         -- control register outputs
         IDEctrl_rst   => IDEctrl_rst,
         IDEctrl_IDEen => IDEctrl_IDEen,
         IDEctrl_ppen => s_IDEctrl_ppen,
         IDEctrl_FATR0 => IDEctrl_FATR0,
         IDEctrl_FATR1 => IDEctrl_FATR1,

         -- CMD port timing registers
         PIO_cmdport_T1 => s_PIO_cmdport_T1,
         PIO_cmdport_T2 => s_PIO_cmdport_T2,
         PIO_cmdport_T4 => s_PIO_cmdport_T4,
         PIO_cmdport_Teoc => s_PIO_cmdport_Teoc,
         PIO_cmdport_IORDYen => s_PIO_cmdport_IORDYen,

         -- data-port0 timing registers
         PIO_dport0_T1 => s_PIO_dport0_T1,
         PIO_dport0_T2 => s_PIO_dport0_T2,
         PIO_dport0_T4 => s_PIO_dport0_T4,
         PIO_dport0_Teoc => s_PIO_dport0_Teoc,
         PIO_dport0_IORDYen => s_PIO_dport0_IORDYen,

         -- data-port1 timing registers
         PIO_dport1_T1 => s_PIO_dport1_T1,
         PIO_dport1_T2 => s_PIO_dport1_T2,
         PIO_dport1_T4 => s_PIO_dport1_T4,
         PIO_dport1_Teoc => s_PIO_dport1_Teoc,
         PIO_dport1_IORDYen => s_PIO_dport1_IORDYen,

         -- Bus master edits     by Erik Jagre 2006-10-04 ---------------start--
         DMActrl_Bytesw=> s_DMActrl_Bytesw,
         DMActrl_BeLeC0=> s_DMActrl_BeLeC0,
         DMActrl_BeLeC1=> s_DMActrl_BeLeC1,

         DMActrl_DMAen => s_DMActrl_DMAen,
         DMActrl_dir   => s_DMActrl_dir,
         
         DMA_dev0_Tm   => s_DMA_dev0_Tm,
         DMA_dev0_Td   => s_DMA_dev0_Td,
         DMA_dev0_Teoc => s_DMA_dev0_Teoc,

         DMA_dev1_Tm   => s_DMA_dev1_Tm,
         DMA_dev1_Td   => s_DMA_dev1_Td,
         DMA_dev1_Teoc => s_DMA_dev1_Teoc,

         fr_BM =>s_bmo.to_slv,
         to_BM =>s_bmi.fr_slv
         -- Bus master edits     by Erik Jagre 2006-10-04 ------------------end-------
  );

  ctr: atahost_controller
  generic map(
     fdepth => fdepth,
     tech => tech,
     TWIDTH => TWIDTH,
     PIO_mode0_T1   => PIO_mode0_T1,
     PIO_mode0_T2   => PIO_mode0_T2,
     PIO_mode0_T4   => PIO_mode0_T4,
     PIO_mode0_Teoc => PIO_mode0_Teoc,
     DMA_mode0_Tm   => DMA_mode0_Tm,
     DMA_mode0_Td   => DMA_mode0_Td,
     DMA_mode0_Teoc => DMA_mode0_Teoc
  )
  port map(
     clk    => clk,
     nReset => arst_signal,
     rst    => reset,
     irq    => irq,
     IDEctrl_IDEen => IDEctrl_IDEen,
     IDEctrl_rst   => IDEctrl_rst,
     IDEctrl_ppen  => s_IDEctrl_ppen, 
     IDEctrl_FATR0 => IDEctrl_FATR0,
     IDEctrl_FATR1 => IDEctrl_FATR1,
     a  => PIOa,
     d  => s_d,
     we => s_we,
     PIO_cmdport_T1   => s_PIO_cmdport_T1,
     PIO_cmdport_T2   => s_PIO_cmdport_T2,
     PIO_cmdport_T4   => s_PIO_cmdport_T4,
     PIO_cmdport_Teoc => s_PIO_cmdport_Teoc,
     PIO_cmdport_IORDYen => s_PIO_cmdport_IORDYen,
     PIO_dport0_T1   => s_PIO_dport0_T1,
     PIO_dport0_T2   => s_PIO_dport0_T2,
     PIO_dport0_T4   => s_PIO_dport0_T4,
     PIO_dport0_Teoc => s_PIO_dport0_Teoc,
     PIO_dport0_IORDYen => s_PIO_dport0_IORDYen,
     PIO_dport1_T1   => s_PIO_dport1_T1,
     PIO_dport1_T2   => s_PIO_dport1_T2,
     PIO_dport1_T4   => s_PIO_dport1_T4,
     PIO_dport1_Teoc => s_PIO_dport1_Teoc,
     PIO_dport1_IORDYen => s_PIO_dport1_IORDYen,
     PIOsel     => PIOsel,
     PIOack     => PIOack,
     PIOq       => PIOq,
     PIOtip     => s_PIOtip,
     PIOpp_full => s_PIOpp_full, 
     --DMA
     DMActrl_DMAen  => s_DMActrl_DMAen,
     DMActrl_dir    => s_DMActrl_dir,
     DMActrl_Bytesw => s_DMActrl_Bytesw,
     DMActrl_BeLeC0 => s_DMActrl_BeLeC0,
     DMActrl_BeLeC1 => s_DMActrl_BeLeC1,
     DMA_dev0_Td   => s_DMA_dev0_Td,
     DMA_dev0_Tm   => s_DMA_dev0_Tm,
     DMA_dev0_Teoc => s_DMA_dev0_Teoc,
     DMA_dev1_Td   => s_DMA_dev1_Td,
     DMA_dev1_Tm   => s_DMA_dev1_Tm,
     DMA_dev1_Teoc => s_DMA_dev1_Teoc,
     DMAsel     => s_bmo.to_ctr.sel,
     DMAack     => s_bmi.fr_ctr.ack,
     DMAq       => s_bmi.fr_ctr.q,
     DMAtip_out => s_bmi.fr_ctr.tip,
     DMA_dmarq  => s_DMA_dmarq,
     force_rdy => s_bmo.to_ctr.force_rdy,
     fifo_rdy  => s_bmi.fr_ctr.fifo_rdy,
     DMARxEmpty => s_bmi.fr_ctr.rx_empty,
     DMARxFull => s_bmi.fr_ctr.rx_full,
     DMA_req    => s_bmi.fr_ctr.req,
     DMA_ack    => s_bmo.to_ctr.ack,
     BM_en      => s_bmi.fr_slv.en, -- Bus mater enabled, for DMA reset Erik Jagre 2006-10-24
     --ATA
     RESETn => ata_resetn,
     DDi    => ddin,
     DDo    => ddout,
     DDoe   => ddoe,
     DA     => datemp,
     CS0n   => cs0n,
     CS1n   => cs1n,
     DIORn  => diorn,
     DIOWn  => diown,
     IORDY  => iordy,
     INTRQ  => intrq,
     DMARQ  => dmarq,
     DMACKn => dmack
   );

  mst : ahbmst
  generic map(
    hindex  => mhindex,
    hirq    => 0,
    venid   => VENDOR_GAISLER,
    devid   => GAISLER_ATACTRL,
    version => 0,
    chprot  => 3,
    incaddr => 4)
  port map (
    rst  => rst,
    clk  => clk,
    dmai => s_bmo.to_mst,
    dmao => s_bmi.fr_mst,
    ahbi => ahbmi,
    ahbo => ahbmo
  );

  bm : atahost_ahbmst
  generic map(fdepth=>fdepth)
  port map(
    clk => clk,
    rst => rst,
    i   => s_bmi,
    o   => s_bmo
  );

   -- pragma translate_off
   bootmsg : report_version 
   generic map ("atactrl" & tost(hindex) & 
                ": ATA controller rev " & tost(VERSION) & ", irq " & tost(pirq));
   -- pragma translate_on
end;

