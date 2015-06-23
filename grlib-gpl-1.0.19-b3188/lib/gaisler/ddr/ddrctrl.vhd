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
-- Entity:      ddrctrl
-- File:        ddrctrl.vhd
-- Author:      David Lindh - Gaisler Research
-- Description: DDR-RAM memory controller with AMBA interface
------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.amba.all;
use grlib.stdlib.all;
library gaisler;
use grlib.devices.all;
use gaisler.memctrl.all;
library techmap;
use techmap.gencomp.all;
use techmap.allmem.all;
use gaisler.ddrrec.all;


entity ddrctrl is
  generic (
    hindex1    :     integer := 0;
    haddr1     :     integer := 0;
    hmask1     :     integer := 16#f80#;
    hindex2    :     integer := 0;
    haddr2     :     integer := 0;
    hmask2     :     integer := 16#f80#;
    pindex     :     integer := 3;
    paddr      :     integer := 0;
    numahb     :     integer := 1;       -- Allowed: 1, 2
    ahb1sepclk :     integer := 0;       -- Allowed: 0, 1
    ahb2sepclk :     integer := 0;       -- Allowed: 0, 1
    modbanks   :     integer := 1;       -- Allowed: 1, 2
    numchips   :     integer := 2;       -- Allowed: 1, 2, 4, 8, 16
    chipbits   :     integer := 16;      -- Allowed: 4, 8, 16
    chipsize   :     integer := 256;     -- Allowed: 64, 128, 256, 512, 1024 (MB)
    plldelay   :     integer := 0;       -- Allowed: 0, 1 (Use 200us start up delay)
    tech       :     integer := virtex2;
    clkperiod  :     integer := 10);     -- (ns)
  port (
    rst       : in  std_ulogic;
    clk0      : in  std_ulogic;
    clk90     : in  std_ulogic;
    clk180    : in  std_ulogic;
    clk270    : in  std_ulogic;
    hclk1     : in  std_ulogic;
    hclk2     : in  std_ulogic;
    pclk      : in  std_ulogic;
    ahb1si    : in  ahb_slv_in_type;
    ahb1so    : out ahb_slv_out_type;
    ahb2si    : in  ahb_slv_in_type;
    ahb2so    : out ahb_slv_out_type;
    apbsi     : in  apb_slv_in_type;
    apbso     : out apb_slv_out_type;
    ddsi      : out ddrmem_in_type;
    ddso      : in  ddrmem_out_type);
end ddrctrl;

architecture rtl of ddrctrl is



-------------------------------------------------------------------------------
  -- Constants
-------------------------------------------------------------------------------

  constant DELAY_15600NS   : integer := (15600 / clkperiod);
  constant DELAY_7800NS    : integer := (7800 / clkperiod);
  constant DELAY_7_15600NS : integer := (7*(15600 / clkperiod));
  constant DELAY_7_7800NS  : integer := (7*(7800 / clkperiod));
  constant DELAY_200US : integer := (200000 / clkperiod);
    
  constant REVISION : integer := 0;
  constant pmask    : integer := 16#fff#;
  constant pconfig  : apb_config_type := (
  0 => ahb_device_reg ( VENDOR_GAISLER, GAISLER_DDRMP, 0, REVISION, 0),
  1 => apb_iobar(paddr, pmask));

  constant dqsize     : integer := numchips*chipbits;
  constant dmsize     : integer := (dqsize/8);
  constant strobesize : integer := (dqsize/8) * dmvector(chipbits); 
    
-------------------------------------------------------------------------------
-- Signals
-------------------------------------------------------------------------------
  
  signal toAHB        : two_ahb_ctrl_in_type;
  signal fromAHB      : two_ahb_ctrl_out_type;
  signal fromAHB2Main : two_ahb_ctrl_out_type;   
  signal apbr         : apb_reg_type;
  signal apbri        : apb_reg_type;
  signal fromAPB      : apb_ctrl_out_type;
  signal fromAPB2Main : apb_ctrl_out_type;    
  signal mainr        : main_reg_type;
  signal mainri       : main_reg_type;
  signal fromMain     : main_ctrl_out_type;
  signal fromMain2APB : apb_ctrl_in_type;     
  signal fromMain2AHB : two_ahb_ctrl_in_type;
  signal fromMain2HS  : hs_in_type; 
  signal toHS         : hs_in_type;
  signal fromHS       : hs_out_type;
  
begin  -- achitecture rtl

-------------------------------------------------------------------------------
-- Error reports
  assert (tech = virtex2 or tech = virtex4 or tech = lattice) report "Unsupported technology by DDR controller (generic tech)" severity failure;
  assert (modbanks=1 or modbanks=2) report "Only 1 or 2 module banks is supported (generic modbanks)" severity failure;
  assert (chipbits=4 or chipbits=8 or chipbits=16) report "DDR chips either have 4, 8 or 16 bits output (generic chipbits)" severity failure;
  assert (chipsize=64 or chipsize=128 or chipsize=256 or chipsize=512 or chipsize=1024) report "DDR chips either have 64, 128, 256, 512 or 1024 Mbit size" severity failure;
  assert (buffersize>=2) report "Buffer must have room for at least 2 bursts (generic buffersize)" severity failure;
  assert (plldelay=0 or plldelay=1) report "Invalid setting for DDRRAM PLL delay (generic plldelay)" severity failure; 
  assert (numahb=1 or numahb=2) report "Only one or two AHB interfaces can be used (generic numahb)" severity failure;


-------------------------------------------------------------------------------
-- APB control
    -- Controls APB bus. Contains the DDRCFG register. Clear memcmd
    -- bits when a memory command requested on APB is complete.
   apbcomb : process(apbr, apbsi, fromMain2APB, rst)
     variable v : apb_reg_type;
   begin
     v:= apbr;
     if rst = '0' then -- Reset
       v.ddrcfg_reg := ddrcfg_reset; 
     elsif fromMain2APB.apb_cmd_done = '1' then -- Clear memcmd bits
       v.ddrcfg_reg(28 downto 27) := "00";
     elsif (apbsi.psel(pindex) and apbsi.penable and apbsi.pwrite) = '1' then -- Write
       v.ddrcfg_reg := apbsi.pwdata(31 downto 1) & fromMain2APB.ready;
     else
       v.ddrcfg_reg(0) := fromMain2APB.ready;
     end if;
     apbri <= v;
     fromAPB.ddrcfg_reg <= v.ddrcfg_reg; 
   end process apbcomb;

   apbclk : process(pclk)
     begin
       if rising_edge(pclk) then apbr <= apbri; end if;
   end process;
      
   apbso.prdata <= fromAPB.ddrcfg_reg; apbso.pirq <= (others => '0');
   apbso.pindex <= pindex; apbso.pconfig <= pconfig;

  
-------------------------------------------------------------------------------
 -- Main controller
-------------------------------------------------------------------------------
   maincomb     : process(mainr, fromAHB, fromAHB2Main, fromAPB2Main, rst, fromHS)
     variable v : main_reg_type;
   begin
     v := mainr; v.loadcmdbuffer := '0'; -- Clear Cmd loading bit

-------------------------------------------------------------------------------
     -- DDRCFG control
     -- Reads DDRCFG from APB controller. Handles refresh command from refresh
     -- timer and memoory comand requested on APB.
    
     case v.apbstate is
       when idle =>
         v.apb_cmd_done := '0';
         -- Refresh timer signals refresh
         if v.doRefresh = '1' and v.ddrcfg.refresh = '1' then
           v.apbstate := refresh;
         -- LMR cmd on APB bus
         elsif fromAPB2Main.ddrcfg_reg(28 downto 27) = "11" then 
            v.lockAHB := "11";
            v.apbstate := wait_lmr1;
         -- Refresh or Precharge cmd on APB BUS
         elsif fromAPB2Main.ddrcfg_reg(28 downto 27) > "00" then
           v.apbstate := cmd;
           -- Nothing to be done
         else
           v.ddrcfg.memcmd  := "00";
         end if;

       -- Refresh from Timer
       when refresh =>
         if v.mainstate = idle then v.ddrcfg.memcmd := "10"; end if;
         if v.dorefresh = '0' then v.ddrcfg.memcmd := "00"; v.apbstate := idle; end if;

       -- Refresh or Precharge from APB BUS
       when cmd =>
         if v.mainstate = idle then v.ddrcfg.memcmd := fromAPB2Main.ddrcfg_reg(28 downto 27); end if;
         v.apbstate := cmdDone;
         
      -- Wait until no more cmd can arrive from AHB ctrl 
       when wait_lmr1 => v.apbstate := wait_lmr2;
       when wait_lmr2 => v.apbstate := cmdlmr;

       when cmdlmr => 
         -- Check that no new R/W cmd is to be performed
         if fromAHB2Main(0).rw_cmd_valid = v.rw_cmd_done(0) and
           fromAHB2Main(1).rw_cmd_valid = v.rw_cmd_done(1)  and v.mainstate = idle then
           v.ddrcfg.memcmd := "11";
           v.ddrcfg.cas := fromAPB2Main.ddrcfg_reg(30 downto 29);
           v.ddrcfg.bl := fromAPB2Main.ddrcfg_reg(26 downto 25);
           v.apbstate := cmdDone;
         end if;
         
       when cmdDone =>
         v.lockAHB := "00";
         if v.memCmdDone = '1' then
           v.ddrcfg.memcmd := "00"; v.apb_cmd_done := '1'; v.apbstate := cmdDone2;
         end if;

       when cmdDone2 =>    
           if fromAPB2Main.ddrcfg_reg(28 downto 27) = "00" then
             v.apb_cmd_done := '0'; v.apbstate := idle;
           end if;
     end case;

     
     if v.mainstate = idle  then
       v.ddrcfg.refresh    := fromAPB2Main.ddrcfg_reg(31);
       v.ddrcfg.autopre    := fromAPB2Main.ddrcfg_reg(24);
       v.ddrcfg.r_predict  := fromAPB2Main.ddrcfg_reg(23 downto 22);
       v.ddrcfg.w_prot     := fromAPB2Main.ddrcfg_reg(21 downto 20);
       v.ddrcfg.ready      := fromAPB2Main.ddrcfg_reg(0);
     end if;
 -------------------------------------------------------------------------------
     -- Calcualtes burst length
     case v.ddrcfg.bl is
       when "00"   => v.burstlength := 2;
       when "01"   => v.burstlength := 4;
       when "10"   => v.burstlength := 8;
       when others => v.burstlength := 8;
     end case;

 -------------------------------------------------------------------------------
     -- Calculates row and column address
     
     v.tmpcoladdress := (others => (others => '0'));
     v.rowaddress    := (others => (others => '0'));
     v.coladdress    := (others => (others => '0'));
     v.tmpcolbits := 0; v.colbits := 0; v.rowbits := 0;

     -- Based on the size of the chip its organization can be calculated
     case chipsize is
       when 64     => v.tmpcolbits := 10; v.rowbits := 12; v.refreshTime := DELAY_15600NS; v.maxRefreshTime := DELAY_7_15600NS;  -- 64Mbit
       when 128    => v.tmpcolbits := 11; v.rowbits := 12; v.refreshTime := DELAY_15600NS; v.maxRefreshTime := DELAY_7_15600NS;  -- 128Mbit
       when 256    => v.tmpcolbits := 11; v.rowbits := 13; v.refreshTime := DELAY_7800NS; v.maxRefreshTime := DELAY_7_7800NS;  -- 256Mbit
       when 512    => v.tmpcolbits := 12; v.rowbits := 13; v.refreshTime := DELAY_7800NS; v.maxRefreshTime := DELAY_7_7800NS;  -- 512Mbit
       when 1024   => v.tmpcolbits := 12; v.rowbits := 14; v.refreshTime := DELAY_7800NS; v.maxRefreshTime := DELAY_7_7800NS;  -- 1Gbit                 
       when others => v.tmpcolbits := 10; v.rowbits := 12; v.refreshTime := DELAY_7800NS; v.maxRefreshTime := DELAY_7_7800NS;  -- Others 64Mbit
     end case;
     case chipbits is
       when 4      => v.colbits := v.tmpcolbits;      -- x4 bits
       when 8      => v.colbits := (v.tmpcolbits-1);  -- x8 bits
       when 16     => v.colbits := (v.tmpcolbits-2);  -- x16 bits
       when others => null;
     end case;
     v.addressrange := v.colbits + v.rowbits;

      -- AHB controller 1 --
      for i in 0 to ahbadr loop
       if (i < v.colbits) then
         v.tmpcoladdress(0)(i) := fromAHB(0).asramso.dataout(i); end if;
       if (i < (v.addressrange) and i >= v.colbits) then
         v.rowaddress(0)(i-v.colbits)  := fromAHB(0).asramso.dataout(i); end if;
       if (i < (v.addressrange+2) and i >= v.addressrange) then
         v.intbankbits(0)(i - v.addressrange) := fromAHB(0).asramso.dataout(i); end if;
     end loop;
    
     -- Inserts bank address and auto precharge bit as A10
     v.coladdress(0)(adrbits-1 downto 0)           := v.intbankbits(0) &
                                                 v.tmpcoladdress(0)(12 downto 10) &  -- Bit 13 to 11
                                                 v.ddrcfg.autopre &  -- Bit 10
                                                 v.tmpcoladdress(0)(9 downto 0);  --Bit 9 to 0
     v.rowaddress(0)(adrbits-1 downto (adrbits-2)) := v.intbankbits(0);

     -- Calculate total numer of useable address bits
     if modbanks = 2 then
       -- Calculate memory module bank (CS signals)
       if fromAHB(0).asramso.dataout(v.addressrange +2) = '0' then
         v.bankselect(0) := BANK0; 
       else
         v.bankselect(0) := BANK1;
       end if;
     else
       v.bankselect(0)   := BANK0;
     end if;

     -- This is for keeping track of which banks has a active row
     v.pre_bankadr(0):= conv_integer(v.bankselect(0)(0) & v.rowaddress(0)(adrbits-1 downto (adrbits-2)));


     -- AHB Controller 2 --
     for i in 0 to ahbadr loop
       if (i < v.colbits) then
         v.tmpcoladdress(1)(i) := fromAHB(1).asramso.dataout(i); end if;
       if (i < (v.addressrange) and i >= v.colbits) then
         v.rowaddress(1)(i-v.colbits)  := fromAHB(1).asramso.dataout(i); end if;
       if (i < (v.addressrange+2) and i >= v.addressrange) then
         v.intbankbits(1)(i - v.addressrange) := fromAHB(1).asramso.dataout(i); end if;
     end loop;
    
     -- Inserts bank address and auto precharge bit as A10
     v.coladdress(1)(adrbits-1 downto 0)         := v.intbankbits(1) &
                                                 v.tmpcoladdress(1)(12 downto 10) &  -- Bit 13 to 11
                                                 v.ddrcfg.autopre &  -- Bit 10
                                                 v.tmpcoladdress(1)(9 downto 0);  --Bit 9 to 0
     v.rowaddress(1)(adrbits-1 downto (adrbits-2)) := v.intbankbits(1);

     -- Calculate total numer of useable address bits
     if modbanks = 2 then
       -- Calculate memory module bank (CS signals)
       if fromAHB(1).asramso.dataout(v.addressrange +2) = '0' then
         v.bankselect(1) := BANK0;
       else
         v.bankselect(1) := BANK1;
       end if;
     else
       v.bankselect(1)   := BANK0;
     end if;

     -- This is for keeping track of which banks has a active row
     v.pre_bankadr(1):= conv_integer(v.bankselect(1)(0) & v.rowaddress(1)(adrbits-1 downto (adrbits-2)));
     -- ((1bit(Lower/upper half if 32 bit mode))) + 1bit(module bank select) +
     -- 2bits(Chip bank selekt) + Xbits(address, depending on chip size)



       
 -------------------------------------------------------------------------------
 -- Calculate LMR command address
     v.lmradr(adrbits-1 downto 7) := (others => '0');
     -- CAS value
     case v.ddrcfg.cas is
       when "00" => v.lmradr(6 downto 4) := "010";
       when "01" => v.lmradr(6 downto 4) := "110";
       when "10" => v.lmradr(6 downto 4) := "011";
       when others => v.lmradr(6 downto 4) := "010";
     end case;
     -- Burst type, seqencial or interleaved (fixed att seqencial)
     v.lmradr(3) := '0';
     -- Burst length
     case v.ddrcfg.bl is
       when "00" => v.lmradr(2 downto 0) := "001";
       when "01" => v.lmradr(2 downto 0) := "010";
       when "10" => v.lmradr(2 downto 0) := "011";
       when others => v.lmradr(2 downto 0) := "010";
     end case;



       
 -------------------------------------------------------------------------------
 -- Auto refresh timer
     case v.timerstate is
       when t1 =>
         v.doRefresh  := '0'; v.refreshcnt := v.refreshTime; v.timerstate := t2;
       when t2 =>
         v.doRefresh  := '0'; v.refreshcnt := mainr.refreshcnt -1;
         if v.refreshcnt < 50 then v.timerstate := t3; end if;
       when t3 =>
         if mainr.refreshcnt > 1 then v.refreshcnt := mainr.refreshcnt -1; end if;
         v.doRefresh    := '1';
         if v.refreshDone = '1' then
           v.refreshcnt := mainr.refreshcnt + v.refreshTime;
           v.timerstate := t4;
         end if;
       when t4 =>
         v.doRefresh  := '0'; v.timerstate := t2; when others => null;
     end case;



       
 -------------------------------------------------------------------------------
 -- Init statemachine
     case v.initstate is
       when idle =>
         v.memInitDone := '0';
         if v.doMemInit = '1' then
           if plldelay = 1 then
             -- Using refrshtimer for initial wait
             v.refreshcnt := DELAY_200US +50; v.timerstate := t2; v.initstate := i1;
           else v.initstate := i2; end if;
         end if;
       when i1 =>
         if v.doRefresh = '1' then v.initstate := i2; end if;
       when i2 =>
         v.cs := "00";
         if fromHS.hs_busy = '0' then
           v.cmdbufferdata := CMD_NOP; v.loadcmdbuffer := '1'; v.initstate := i3;
         end if;
       when i3 =>
         if fromHS.hs_busy = '0' then
           v.cmdbufferdata := CMD_PRE; v.loadcmdbuffer := '1';
           v.adrbufferdata(10) := '1'; v.initstate := i4;
         end if;
       when i4 =>
         if fromHS.hs_busy = '0' then
           v.cmdbufferdata := CMD_LMR; v.loadcmdbuffer := '1';
           v.adrbufferdata(adrbits-1 downto (adrbits-2)) := "01";
           v.adrbufferdata((adrbits -3) downto 0)      := (others => '0');
           v.initstate := i5;
         end if;
       when i5 =>
         if fromHS.hs_busy = '0' then
           v.cmdbufferdata := CMD_LMR; v.loadcmdbuffer := '1'; v.adrbufferdata := v.lmradr;
           v.refreshcnt := 250; v.timerstate := t2;  --200 cycle count
           v.adrbufferdata(8) := '1'; v.initstate := i6;
         end if;
       when i6 =>
         if fromHS.hs_busy = '0' then
           v.cmdbufferdata := CMD_PRE; v.loadcmdbuffer := '1';
           v.adrbufferdata(10) := '1'; v.initstate := i7;
         end if;
       when i7 =>
         if fromHS.hs_busy = '0' then
           v.cmdbufferdata := CMD_AR; v.loadcmdbuffer := '1'; v.initstate := i8;
         end if;
       when i8 =>
         if fromHS.hs_busy = '0' then
           v.cmdbufferdata := CMD_AR; v.loadcmdbuffer := '1'; v.initstate := i9;
         end if;
       when i9 =>
         if fromHS.hs_busy = '0' then
           v.cmdbufferdata   := CMD_LMR; v.loadcmdbuffer := '1'; v.adrbufferdata := v.lmradr;
           v.initstate := i10;
         end if;
       when i10 =>
         if v.doRefresh = '1' then v.initstate := i11; end if;
       when i11 =>
         v.memInitDone := '1';
         if v.doMemInit = '0' then v.initstate := idle; end if;
       when others => null;
     end case;



       
 -------------------------------------------------------------------------------
 -- Main controller statemachine
     case v.mainstate is
       -- Initialize memory
       when init   =>
         v.doMemInit   := '1';
         v.ready       := '0';
         if v.memInitDone = '1' then
           v.mainstate := idle;
         end if;

         -- Await command 
       when idle =>
         v.doMemInit   := '0';
         v.RefreshDone := '0';
         v.memCmdDone  := '0';
         v.ready       := '1';
         v.use_bl      := mainr.burstlength;
         v.use_cas     := mainr.ddrcfg.cas; 
                
         if v.ddrcfg.memcmd /= "00" then
           v.mainstate := c1;
         elsif fromAHB2Main(0).rw_cmd_valid /= v.rw_cmd_done(0) or
               fromAHB2Main(1).rw_cmd_valid /= v.rw_cmd_done(1) then

           -- This code is to add read priority between the ahb controllers
           
--            if fromAHB2Main(0).rw_cmd_valid /= v.rw_cmd_done(0) and
--             fromAHB(0).asramso.dataout(ahbadr) = '0' then
--              v.use_ahb := 0;
--              v.use_buf := v.rw_cmd_done(0)+1;
--            elsif fromAHB2Main(1).rw_cmd_valid /= v.rw_cmd_done(1) and
--             fromAHB(1).asramso.dataout(ahbadr) = '0' then
--              v.use_ahb := 1;
--              v.use_buf := v.rw_cmd_done(1)+1;
           if fromAHB2Main(0).rw_cmd_valid /= v.rw_cmd_done(0) then
             v.use_ahb := 0;
             v.use_buf := v.rw_cmd_done(0)+1;
           else
             v.use_ahb := 1;
             v.use_buf := v.rw_cmd_done(1)+1;
           end if;

            -- Check if the chip bank which is to be R/W has a row open
            if mainr.pre_chg(v.pre_bankadr(v.use_ahb)) = '1' then
              -- Check if the row which is open is the same that will be R/W
              if mainr.pre_row(v.pre_bankadr(v.use_ahb)) = v.rowaddress(v.use_ahb) then
                v.mainstate := rw;

                -- R/W to a different row then the one open, has to precharge and
                -- activate new row
              else
                v.mainstate := pre1;
              end if;
              -- No row open, has to activate row
            else
              v.mainstate := act1;
            end if;
         end if;
           -- Nothing to do, if 10 idle cycles, run Refreash (if needed)
         if v.idlecnt = 10 and v.refreshcnt < v.maxRefreshTime then
           v.doRefresh  := '1';
           v.idlecnt    := 0;
           v.timerstate := t3;
           v.refreshcnt := mainr.refreshcnt + v.refreshTime;
         elsif v.idlecnt = 10 then
           v.idlecnt    := 0;
         else
           v.idlecnt    := mainr.idlecnt + 1;
         end if;

         

         -- Precharge memory
       when pre1 =>
         if fromHS.hs_busy = '0' then
         v.cs := v.bankselect(mainr.use_ahb);
         -- Select chip bank to precharge
         v.adrbufferdata := (others => '0');
         v.adrbufferdata(adrbits-1 downto (adrbits-2)) := v.rowaddress(mainr.use_ahb)(adrbits-1 downto (adrbits-2));
         v.cmdbufferdata := CMD_PRE;
         -- Clear bit in register for active rows
         v.pre_chg(v.pre_bankadr(mainr.use_ahb)):= '0';
         v.loadcmdbuffer := '1';
         v.mainstate := act1;
       end if;


       
         -- Activate row in  memory
       when act1 =>                      -- Get adr and cmd from AHB, set to HS
         if fromHS.hs_busy = '0' then
           v.cs            := v.bankselect(mainr.use_ahb); 
           v.cmdbufferdata := CMD_ACTIVE;
           v.adrbufferdata := v.rowaddress(mainr.use_ahb);
           v.loadcmdbuffer := '1';

         -- Set bit in register for active row if auto-precharge is disabled
           if v.ddrcfg.autopre = '0' then
             v.pre_chg(v.pre_bankadr(mainr.use_ahb)) := '1';
             v.pre_row(v.pre_bankadr(mainr.use_ahb)) := v.rowaddress(mainr.use_ahb);
           end if;
           v.mainstate := rw;
         end if;


       
       -- Issu read or write to HS part
       when rw =>
        if fromAHB(mainr.use_ahb).asramso.dataout(ahbadr) = '1' then
          v.cmdbufferdata   := CMD_WRITE;
        else
          v.cmdbufferdata   := CMD_READ;
        end if;
        if v.ddrcfg.autopre = '1' then
           v.pre_chg(v.pre_bankadr(mainr.use_ahb)) := '0';
        end if;
        v.adrbufferdata   := v.coladdress(mainr.use_ahb);
        v.cs            := v.bankselect(mainr.use_ahb);
        v.idlecnt   := 0;
        if fromHS.hs_busy = '0' then
          if fromAHB2Main(mainr.use_ahb).w_data_valid /= v.rw_cmd_done(mainr.use_ahb) then
            v.loadcmdbuffer := '1';
            v.rw_cmd_done(mainr.use_ahb)   := v.rw_cmd_done(mainr.use_ahb)+1;
            v.sync2_adr(mainr.use_ahb)     := v.rw_cmd_done(mainr.use_ahb)+1;
            v.mainstate     := idle;
          end if;
        end if;

       -- Issue prechare, auto refresh or LMR to HS part
       when c1 =>
        v.idlecnt   := 0;
        if fromHS.hs_busy = '0' then
         v.cs                    := BANK01;      
         case v.ddrcfg.memCmd is
           when "01"                        =>  -- Precharge all
             v.cmdbufferdata     := CMD_PRE;
             v.adrbufferdata(10) := '1';
             v.pre_chg           := (others => '0');
             v.memCmdDone        := '1';
             v.mainstate         := c2;

           when "10" =>                  -- AutoRefresh
             -- All banks have to be precharged before AR
             if v.pre_chg = "00000000" then
               v.cmdbufferdata := CMD_AR;
               v.memCmdDone        := '1';
               v.mainstate         := c2;
               v.refreshDone       := '1';
              
             else                        -- Run Precharge, and let AR begin when finished
               v.cmdbufferdata     := CMD_PRE;
               v.adrbufferdata(10) := '1';
               v.pre_chg           := (others => '0');
               v.mainstate         := idle; 
             end if;

           when "11"   =>                -- LMR
            -- All banks have to be precharged before LMR
            if v.pre_chg = "00000000" then
             v.cmdbufferdata := CMD_LMR;
             v.adrbufferdata := v.lmradr;
             v.memCmdDone    := '1';
             v.mainstate     := c2;
            else
               v.cmdbufferdata     := CMD_PRE;
               v.adrbufferdata(10) := '1';
               v.pre_chg           := (others => '0');
               v.mainstate         := idle;
            end if;
           when others => null;
         end case;
         v.loadcmdbuffer     := '1';
       end if;
         
       when c2 =>
         if v.ddrcfg.memCmd = "00" then
           v.refreshDone := '0';
           v.mainstate   := idle;
         end if;

       when others =>
         v.mainstate := init;
     end case;

     -- Reset
     if rst = '0' then
       -- Main controller
       v.mainstate        := init;
       v.loadcmdbuffer    := '0';
       v.cmdbufferdata    := CMD_NOP;
       v.adrbufferdata    := (others => '0');
       v.use_ahb          := 0;
       v.use_bl           := 4;
       v.use_cas          := "00";
       v.use_buf          := (others => '1');
       v.burstlength      := 8;
       v.rw_cmd_done      := (others => (others => '1'));
       v.lmradr           := (others => '0');
       v.memCmdDone       := '0';
       v.lockAHB          := "00";
       v.pre_row          := (others => (others => '0'));
       v.pre_chg          := (others => '0');
       v.pre_bankadr      := (0,0);
       v.sync2_adr        := (others =>(others => '0'));

       -- For init statemachine
       v.initstate   := idle;
       v.doMemInit   := '0';
       v.memInitDone := '0';
       v.initDelay   := 0;
       v.cs          := "11";

       -- For address calculator
       v.coladdress    := (others => (others => '0'));
       v.tmpcoladdress := (others => (others => '0'));
       v.rowaddress    := (others => (others => '0'));
       v.addressrange  := 0;
       v.tmpcolbits    := 0;
       v.colbits       := 0;
       v.rowbits       := 0;
       v.bankselect    := ("11","11");
       v.intbankbits   := ("00","00");

       -- For refresh timer statemachine
       v.timerstate     := t2;
       v.doRefresh      := '0';
       v.refreshDone    := '0';
       v.refreshTime    := 0;
       v.maxRefreshTime := 0;
       v.idlecnt        := 0;
       v.refreshcnt     := DELAY_200us;

       -- For DDRCFG register
       v.apbstate       := idle;
       v.apb_cmd_done   := '0';
       v.ready          := '0';
       v.ddrcfg := (ddrcfg_reset(31),ddrcfg_reset(30 downto 29),ddrcfg_reset(28 downto 27),
                    ddrcfg_reset(26 downto 25),ddrcfg_reset(24),ddrcfg_reset(23 downto 22),
                    ddrcfg_reset(21 downto 20),'0');
       
     end if;


     -- Set output signals
     mainri  <= v;

     fromMain.hssi.bl           <= v.use_bl;
     fromMain.hssi.ml           <= fromAHB(mainr.use_ahb).burst_dm(conv_integer(mainr.use_buf));
     fromMain.hssi.cas          <= v.use_cas;
     fromMain.hssi.buf          <= v.use_buf;
     fromMain.hssi.ahb          <= v.use_ahb;  
     fromMain.hssi.cs           <= v.cs;
     fromMain.hssi.cmd          <= v.cmdbufferdata;
     fromMain.hssi.cmd_valid    <= v.loadcmdbuffer;
     fromMain.hssi.adr          <= v.adrbufferdata;
     fromMain.ahbctrlsi(0).burstlength      <= v.burstlength;
     fromMain.ahbctrlsi(1).burstlength      <= v.burstlength;
     fromMain.ahbctrlsi(0).r_predict        <= v.ddrcfg.r_predict(0);
     fromMain.ahbctrlsi(1).r_predict        <= v.ddrcfg.r_predict(1);
     fromMain.ahbctrlsi(0).w_prot           <= v.ddrcfg.w_prot(0);
     fromMain.ahbctrlsi(1).w_prot           <= v.ddrcfg.w_prot(1);  
     fromMain.ahbctrlsi(0).locked           <= v.lockAHB(0);
     fromMain.ahbctrlsi(1).locked           <= v.lockAHB(1);  
     fromMain.ahbctrlsi(0).asramsi.raddress <= v.sync2_adr(0);
     fromMain.ahbctrlsi(1).asramsi.raddress <= v.sync2_adr(1);   
     fromMain.apbctrlsi.apb_cmd_done     <= v.apb_cmd_done;
     fromMain.apbctrlsi.ready            <= v.ready;  
   end process;

  
 --Main clocked register
   mainclk : process(clk0)
   begin

     if rising_edge(clk0) then
       mainr <= mainri;
       
       -- Register to sync between different clock domains
       fromAPB2Main.ddrcfg_reg <= fromAPB.ddrcfg_reg;
            
       -- Makes signals from main to AHB, ABP, HS registerd
       fromMain2AHB <= fromMain.ahbctrlsi;
       fromMain2APB <= fromMain.apbctrlsi;
       fromMain2HS <= fromMain.hssi;
     end if;
   end process;



  -- Sync of incoming data valid signals from AHB
  -- Either if separate clock domains or if syncram_2p
  -- doesn't support write through (write first)
  a1rt : if ahb1sepclk = 1 or syncram_2p_write_through(tech) = 0 generate
    regip1 : process(clk0)
    begin
      if rising_edge(clk0) then
        fromAHB2Main(0).rw_cmd_valid <= fromAHB(0).rw_cmd_valid;
        fromAHB2Main(0).w_data_valid <= fromAHB(0).w_data_valid; 
      end if;
    end process;
  end generate;
  arf : if not (ahb1sepclk = 1 or syncram_2p_write_through(tech) = 0) generate
    fromAHB2Main(0).rw_cmd_valid <= fromAHB(0).rw_cmd_valid;
    fromAHB2Main(0).w_data_valid <= fromAHB(0).w_data_valid; 
  end generate;
  
  a2rt : if ahb2sepclk = 1 or syncram_2p_write_through(tech) = 0 generate
    regip2 : process(clk0)
    begin
      if rising_edge(clk0) then
        fromAHB2Main(1).rw_cmd_valid <= fromAHB(1).rw_cmd_valid;
        fromAHB2Main(1).w_data_valid <= fromAHB(1).w_data_valid;
      end if;
    end process;
  end generate;
  a2rf : if  not (ahb1sepclk = 1 or syncram_2p_write_through(tech) = 0) generate
    fromAHB2Main(1).rw_cmd_valid <= fromAHB(1).rw_cmd_valid;
    fromAHB2Main(1).w_data_valid <= fromAHB(1).w_data_valid;
  end generate;
           
-------------------------------------------------------------------------------
-- High speed interface (Physical layer towards memory)
-------------------------------------------------------------------------------

  D0 : hs
    generic map(
      tech      => tech,
      dqsize    => dqsize,
      dmsize    => dmsize,
      strobesize => strobesize,
      clkperiod => clkperiod)
    port map(
      rst       => rst,
      clk0      => clk0,
      clk90     => clk90,
      clk180    => clk180,
      clk270    => clk270,
      hclk      => pclk,
      hssi      => toHS,
      hsso      => fromHS);
     
  A0 : ahb_slv
    generic map(
      hindex          => hindex1,
      haddr           => haddr1,
      hmask           => hmask1,
      sepclk          => ahb1sepclk,
      dqsize          => dqsize,
      dmsize          => dmsize,
      tech            => tech)
    port map (
      rst             => rst,
      hclk            => hclk1,
      clk0            => clk0,
      csi             => toAHB(0),
      cso             => fromAHB(0));

  B1: if numahb = 2 generate
     A1 : ahb_slv
    generic map(
      hindex          => hindex2,
      haddr           => haddr2,
      hmask           => hmask2,
      sepclk          => ahb2sepclk,
      dqsize          => dqsize,
      dmsize          => dmsize)
    port map (
      rst             => rst,
      hclk            => hclk2,
      clk0            => clk0,
      csi             => toAHB(1),
      cso             => fromAHB(1));
  end generate;

  B2 : if numahb /= 2 generate
    fromAHB(1).rw_cmd_valid <= (others => '1');
  end generate;
-------------------------------------------------------------------------------
-- Mapping signals

  -- Signals to HS
  toHS.bl <=  fromMain.hssi.bl;
  toHS.ml <= fromMain.hssi.ml;
  toHS.cas <= fromMain.hssi.cas;
  toHS.buf <= fromMain.hssi.buf;
  toHS.ahb <= fromMain.hssi.ahb;
  toHS.cs <=  fromMain.hssi.cs;
  toHS.adr <= fromMain.hssi.adr;
  toHS.cmd <= fromMain.hssi.cmd;
  toHS.cmd_valid <= fromMain.hssi.cmd_valid;

  toHS.dsramso(0) <= fromAHB(0).dsramso;
  toHS.dsramso(1) <= fromAHB(1).dsramso;
  toHS.ddso <= ddso;

  
  -- Signals to AHB ctrl 1
  toAHB(0).ahbsi <= ahb1si;
  toAHB(0).asramsi <= fromMain.ahbctrlsi(0).asramsi;
  toAHB(0).dsramsi <= fromHS.dsramsi(0);
  toAHB(0).burstlength <= fromMain2AHB(0).burstlength;
  toAHB(0).r_predict <= fromMain2AHB(0).r_predict;
  toAHB(0).w_prot <= fromMain2AHB(0).w_prot;
  toAHB(0).locked <= fromMain2AHB(0).locked;
  toAHB(0).rw_cmd_done <=  fromHS.cmdDone(0);

   -- Signals to AHB ctrl 2
  toAHB(1).ahbsi <= ahb2si;
  toAHB(1).asramsi <= fromMain.ahbctrlsi(1).asramsi;
  toAHB(1).dsramsi <= fromHS.dsramsi(1);
  toAHB(1).burstlength <= fromMain2AHB(1).burstlength;
  toAHB(1).r_predict <= fromMain2AHB(1).r_predict;
  toAHB(1).w_prot <= fromMain2AHB(1).w_prot;
  toAHB(1).locked <= fromMain2AHB(1).locked;
  toAHB(1).rw_cmd_done <=  fromHS.cmdDone(1);


  -- Ouput signals
  ahb1so <= fromAHB(0).ahbso; 
  ahb2so <= fromAHB(1).ahbso;
  ddsi <= fromHS.ddsi;

  
end rtl;
