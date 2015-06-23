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
-- Entity: atactrl_nodma 
-- File: atactrl_nodma.vhd
-- Author:  Nils-Johan Wessman, Gaisler Research
-- Description: ATA controller
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library grlib;
use grlib.amba.all;
use grlib.stdlib.all;
library gaisler;
use gaisler.ata.all;
library opencores;
use opencores.occomp.all;

entity atactrl_nodma is
 generic (
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
   dmack      : out std_logic
 );
end; 


architecture rtl of atactrl_nodma is
   -- Device ID
   constant DeviceId : integer := 2;
   constant RevisionNo : integer := 0;
   constant VERSION : integer := 0;
   
   component ocidec2_amba_slave is
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
      DMAsel    : out std_logic;
      DMAtip,                                     -- DMA transfer in progress
      DMAack,                                     -- DMA transfer acknowledge
      DMARxEmpty,                                 -- DMA receive buffer empty
      DMATxFull,                                  -- DMA transmit buffer full
      DMA_dmarq : in std_logic;                   -- wishbone DMA request
      DMAq      : in std_logic_vector(31 downto 0);
    
      -- outputs
      -- control register outputs
      IDEctrl_rst,
      IDEctrl_IDEen,
      IDEctrl_FATR1,
      IDEctrl_FATR0,
      IDEctrl_ppen,
      DMActrl_DMAen,
      DMActrl_dir,
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
      DMA_dev1_Teoc    : out std_logic_vector(7 downto 0)
   );
   end component; 
   
   -- asynchronous reset signal
   signal arst_signal : std_logic;
   
   -- primary address decoder
   signal PIOsel  : std_logic;  -- controller select, IDE devices select
   
   -- control signal 
   signal IDEctrl_rst, IDEctrl_IDEen, IDEctrl_FATR0, IDEctrl_FATR1 : std_logic;
   -- compatible mode timing 
   signal PIO_cmdport_T1, PIO_cmdport_T2, PIO_cmdport_T4, PIO_cmdport_Teoc : std_logic_vector(7 downto 0);
   signal PIO_cmdport_IORDYen : std_logic;
   -- data port0 timing 
   signal PIO_dport0_T1, PIO_dport0_T2, PIO_dport0_T4, PIO_dport0_Teoc : std_logic_vector(7 downto 0);
   signal PIO_dport0_IORDYen : std_logic;
   -- data port1 timing 
   signal PIO_dport1_T1, PIO_dport1_T2, PIO_dport1_T4, PIO_dport1_Teoc : std_logic_vector(7 downto 0);
   signal PIO_dport1_IORDYen : std_logic;
   
   signal PIOack : std_logic;
   signal PIOq   : std_logic_vector(15 downto 0);
   signal PIOa   : std_logic_vector(3 downto 0);
   signal PIOd   : std_logic_vector(15 downto 0);
   signal PIOwe  : std_logic;
   
   signal irq : std_logic; -- ATA bus IRQ signal

   signal reset   : std_logic;
   signal gnd,vcc : std_logic;
   signal gnd32   : std_logic_vector(31 downto 0);

begin
   gnd <= '0';vcc <= '1'; gnd32 <= zero32;
   -- generate asynchronous reset level
   arst_signal <= arst;-- xor ARST_LVL;
   reset <= not rst;
   
   dmack <= vcc; -- Disable DMA

   -- Generate CompactFlash signals
   --cfo.power connected to bit 31 of the control register
   cfo.atasel <= gnd;
   cfo.we <= vcc;
   cfo.csel <= gnd;
   cfo.da <= (others => gnd);

   u0: ocidec2_amba_slave 
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
         irq        => irq,
         PIOa       => PIOa,
         PIOd       => PIOd,
         PIOwe      => PIOwe,

         -- DMA control inputs (negate all of them)
         DMAtip     => gnd,
         DMAack     => gnd,
         DMARxEmpty => gnd,
         DMATxFull  => gnd,
         DMA_dmarq  => gnd,
         DMAq       => gnd32,

         -- outputs
         -- control register outputs
         IDEctrl_rst   => IDEctrl_rst,
         IDEctrl_IDEen => IDEctrl_IDEen,
         IDEctrl_FATR0 => IDEctrl_FATR0,
         IDEctrl_FATR1 => IDEctrl_FATR1,

         -- CMD port timing registers
         PIO_cmdport_T1 => PIO_cmdport_T1,
         PIO_cmdport_T2 => PIO_cmdport_T2,
         PIO_cmdport_T4 => PIO_cmdport_T4,
         PIO_cmdport_Teoc => PIO_cmdport_Teoc,
         PIO_cmdport_IORDYen => PIO_cmdport_IORDYen,

         -- data-port0 timing registers
         PIO_dport0_T1 => PIO_dport0_T1,
         PIO_dport0_T2 => PIO_dport0_T2,
         PIO_dport0_T4 => PIO_dport0_T4,
         PIO_dport0_Teoc => PIO_dport0_Teoc,
         PIO_dport0_IORDYen => PIO_dport0_IORDYen,

         -- data-port1 timing registers
         PIO_dport1_T1 => PIO_dport1_T1,
         PIO_dport1_T2 => PIO_dport1_T2,
         PIO_dport1_T4 => PIO_dport1_T4,
         PIO_dport1_Teoc => PIO_dport1_Teoc,
         PIO_dport1_IORDYen => PIO_dport1_IORDYen
      );

   u1: ocidec2_controller
      generic map(
         TWIDTH => TWIDTH,
         PIO_mode0_T1 => PIO_mode0_T1,
         PIO_mode0_T2 => PIO_mode0_T2,
         PIO_mode0_T4 => PIO_mode0_T4,
         PIO_mode0_Teoc => PIO_mode0_Teoc
      )
      port map(
         clk => clk,
         nReset => arst_signal,
         rst => reset,
         irq => irq,
         IDEctrl_rst => IDEctrl_rst,
         IDEctrl_IDEen => IDEctrl_IDEen,
         IDEctrl_FATR0 => IDEctrl_FATR0,
         IDEctrl_FATR1 => IDEctrl_FATR1,
         cmdport_T1 => PIO_cmdport_T1,
         cmdport_T2 => PIO_cmdport_T2,
         cmdport_T4 => PIO_cmdport_T4,
         cmdport_Teoc => PIO_cmdport_Teoc,
         cmdport_IORDYen => PIO_cmdport_IORDYen,
         dport0_T1 => PIO_dport0_T1,
         dport0_T2 => PIO_dport0_T2,
         dport0_T4 => PIO_dport0_T4,
         dport0_Teoc => PIO_dport0_Teoc,
         dport0_IORDYen => PIO_dport0_IORDYen,
         dport1_T1 => PIO_dport1_T1,
         dport1_T2 => PIO_dport1_T2,
         dport1_T4 => PIO_dport1_T4,
         dport1_Teoc => PIO_dport1_Teoc,
         dport1_IORDYen => PIO_dport1_IORDYen,
         PIOreq => PIOsel,
         PIOack => PIOack,
         PIOa => PIOa,
         PIOd => PIOd,
         PIOq => PIOq,
         PIOwe => PIOwe,
         
         RESETn => ata_resetn,
         DDi    => ddin,
         DDo    => ddout,
         DDoe   => ddoe,
         DA     => da,
         CS0n   => cs0n,
         CS1n   => cs1n,
         DIORn  => diorn,
         DIOWn  => diown,
         IORDY  => iordy,
         INTRQ  => intrq
      );

   -- pragma translate_off
   bootmsg : report_version 
   generic map ("atactrl" & tost(hindex) & 
                ": ATA controller rev " & tost(VERSION) & ", no DMA, irq " & tost(pirq));
   -- pragma translate_on
end;

