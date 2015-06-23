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
-- File:        ddrrec.vhd
-- Author:      David Lindh - Gaisler Research
-- Description: DDR-RAM memory controller interface records
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

package ddrrec is

-------------------------------------------------------------------------------
-- Options
-------------------------------------------------------------------------------
    -- This can be changed
   constant buffersize : integer := 4;  -- Data buffer size, 2,4,8.,.-1024 (8 word) bursts
-------------------------------------------------------------------------------
-- Data sizes, should not haveto be changed
-------------------------------------------------------------------------------   
   type dm_arr is array(4 to 16) of integer;
   constant dmvector   : dm_arr  := (2,others => 1);
   constant maxdqsize : integer := 64;
   constant maxdmsize : integer := 16;
   constant maxstrobesize : integer := 16;
   constant adrbits    : integer := 16;    -- BA + row/col address -1 (2+14-1)
   constant ahbadr     : integer := 32;     -- AHB addressbits
   constant ahbdata    : integer := 32;     -- AHB databits
   constant bufferadr  : integer := log2(buffersize)+2;
   constant ddrcfg_reset : std_logic_vector(31 downto 0):=
     '1'  &                              --refresh
     "00" &                              -- CAS
     "00" &                              -- Memcmd
     "10" &                              -- Burst length
     '0'  &                              -- Auto Precharge
     "11" &                              -- Read prediction
     "00" &                              -- Write protection
      x"00000";

   --Memory commands (RAS, CAS, WE)
  constant CMD_READ   : std_logic_vector(2 downto 0) := "101";
  constant CMD_WRITE  : std_logic_vector(2 downto 0) := "100";
  constant CMD_NOP    : std_logic_vector(2 downto 0) := "111";
  constant CMD_ACTIVE : std_logic_vector(2 downto 0) := "011";
  constant CMD_BT     : std_logic_vector(2 downto 0) := "110";
  constant CMD_PRE    : std_logic_vector(2 downto 0) := "010";
  constant CMD_AR     : std_logic_vector(2 downto 0) := "001";
  constant CMD_LMR    : std_logic_vector(2 downto 0) := "000";

  constant BANK0  : std_logic_vector(1 downto 0) := "10";
  constant BANK1  : std_logic_vector(1 downto 0) := "01";
  constant BANK01 : std_logic_vector(1 downto 0) := "00";

  type burst_mask_type is array (buffersize-1 downto 0) of integer range 1 to 8;
  type two_burst_mask_type is array (1 downto 0) of burst_mask_type;
  type two_buf_adr_type is array (1 downto 0) of std_logic_vector((log2(buffersize)-1) downto 0);
  type two_buf_data_type is array (1 downto 0) of std_logic_vector((bufferadr-1) downto 0);
  type pre_row_type is array (7 downto 0) of std_logic_vector(adrbits-1 downto 0);
  type two_ddr_adr_type is array (1 downto 0) of std_logic_vector(adrbits-1 downto 0);
  type two_ddr_bank_type is array (1 downto 0) of std_logic_vector(1 downto 0);
  type two_pre_bank_type is array (1 downto 0) of integer range 0 to 7;
  type blwaittype is array (6 downto 0) of integer range 2 to 8;
  type mlwaittype is array (1 downto 0) of integer range 1 to 8; 
  type bufwaittype is array (6 downto 0) of std_logic_vector((log2(buffersize)-1) downto 0);
  type ahbwaittype is array (6 downto 0) of integer range 0 to 1;
 
-------------------------------------------------------------------------------
-- Records
-------------------------------------------------------------------------------  
   -- APB controller
  type apb_ctrl_in_type is record
    apbsi : apb_slv_in_type;
    apb_cmd_done : std_ulogic;
    ready    : std_ulogic;
  end record;
  type apb_ctrl_out_type is record
    apbso   : apb_slv_out_type;
    ddrcfg_reg : std_logic_vector(31 downto 0);
  end record;

-------------------------------------------------------------------------------
  -- Sync ram dp (data-fifo)
  type syncram_dp_in_type is record
    address1 :  std_logic_vector((bufferadr -1) downto 0);
    datain1  :  std_logic_vector(2*(maxdqsize+maxdmsize)-1 downto 0);
    enable1  :  std_ulogic;
    write1   :  std_ulogic;
    address2 :  std_logic_vector((bufferadr-1) downto 0);
    datain2  :  std_logic_vector(2*(maxdqsize+maxdmsize)-1 downto 0);
    enable2  :  std_ulogic;
    write2   :  std_ulogic;
  end record;
  type syncram_dp_out_type is record
    dataout1 :  std_logic_vector(2*(maxdqsize+maxdmsize)-1 downto 0);
    dataout2 :  std_logic_vector(2*(maxdqsize+maxdmsize)-1 downto 0);
  end record;
  type two_syncram_dp_out_type is array (1 downto 0) of  syncram_dp_out_type;
  type two_syncram_dp_in_type is array (1 downto 0) of  syncram_dp_in_type;
   
-------------------------------------------------------------------------------
  -- Sync ram 2p (adr-fifo)
  type syncram_2p_in_type is record
    renable  :  std_ulogic;
    raddress :  std_logic_vector((log2(buffersize) -1) downto 0); 
    write    :  std_ulogic;
    waddress :  std_logic_vector((log2(buffersize)-1) downto 0);
    datain   :  std_logic_vector((ahbadr-1+1) downto 0);
  end record;
  type syncram_2p_out_type is record
    dataout  :  std_logic_vector((ahbadr-1+1) downto 0);
  end record;  

-----------------------------------------------------------------------------
  -- High speed interface towards memory
  type hs_in_type is record
    bl        : integer range 2 to 8;
    ml        : integer range 1 to 8;
    cas       : std_logic_vector(1 downto 0);
    buf       : std_logic_vector((log2(buffersize)-1) downto 0);
    ahb       : integer range 0 to 1;
    cs        : std_logic_vector(1 downto 0);
    adr       : std_logic_vector(adrbits-1 downto 0);
    cmd       : std_logic_vector(2 downto 0);
    cmd_valid : std_ulogic;
    dsramso   : two_syncram_dp_out_type;
    ddso      : ddrmem_out_type;                            
  end record;
  type hs_out_type is record
    hs_busy   : std_ulogic;
    cmdDone   : two_buf_adr_type;
    dsramsi   : two_syncram_dp_in_type;
    ddsi      : ddrmem_in_type;
  end record;
                                                              
-----------------------------------------------------------------------------
  -- AHB controller  
  type ahb_ctrl_in_type is record
    ahbsi        : ahb_slv_in_type;
    asramsi      : syncram_2p_in_type;
    dsramsi      : syncram_dp_in_type;
    burstlength  : integer range 2 to 8;
    r_predict    : std_ulogic;
    w_prot       : std_ulogic;
    locked       : std_ulogic;
    rw_cmd_done  : std_logic_vector((log2(buffersize) -1) downto 0);
  end record;
  type ahb_ctrl_out_type is record
    ahbso        : ahb_slv_out_type;
    asramso      : syncram_2p_out_type;
    dsramso      : syncram_dp_out_type;
    rw_cmd_valid : std_logic_vector((log2(buffersize) -1) downto 0);
    w_data_valid : std_logic_vector((log2(buffersize) -1) downto 0);
    burst_dm     : burst_mask_type;
  end record;
  type two_ahb_ctrl_out_type is array (1 downto 0) of ahb_ctrl_out_type;
  type two_ahb_ctrl_in_type is array (1 downto 0) of ahb_ctrl_in_type;
  
-----------------------------------------------------------------------------
  -- Main controller
  type main_ctrl_in_type is record
    apbctrlso  : apb_ctrl_out_type;
    ahbctrlso  : two_ahb_ctrl_out_type;
    hsso       : hs_out_type;
  end record;
  type main_ctrl_out_type is record
    apbctrlsi : apb_ctrl_in_type;
    ahbctrlsi : two_ahb_ctrl_in_type;
    hssi      : hs_in_type;
  end record;

-------------------------------------------------------------------------------
  -- DDRCFG register
  type config_out_type is record
    refresh  : std_ulogic;
    cas      : std_logic_vector(1 downto 0);
    memcmd   : std_logic_vector(1 downto 0);
    bl       : std_logic_vector(1 downto 0);
    autopre  : std_ulogic;
    r_predict : std_logic_vector(1 downto 0);
    w_prot   : std_logic_vector(1 downto 0);
    ready    : std_ulogic;
  end record;
   
-------------------------------------------------------------------------------
 -- State machines
------------------------------------------------------------------------------- 
  type apbcycletype is (idle, refresh, cmd, wait_lmr1, wait_lmr2, cmdlmr, cmdDone, cmdDone2);
  type timercycletype is (t1, t2, t3, t4);
  type initcycletype is (idle, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11);
  type maincycletype is (init, idle, pre1, act1, w1, r1, rw, c1, c2);
  type rwcycletype is (idle, r, w);
  type cmdbuffercycletype is (no_cmd, new_cmd);
  type cmdcycletype is(idle, hold);
  
 -----------------------------------------------------------------------------
 -- AHB - Local variables
   type ahb_reg_type is record
     readcounter      : integer range 0 to 8;
     writecounter     : integer range 0 to 8;
     blockburstlength : integer range 0 to 8;
     hready           : std_ulogic;
     hresp            : std_logic_vector(1 downto 0);
     rwadrbuffer      : std_logic_vector((ahbadr-1) downto 0);
     use_read_buffer  : std_logic_vector((log2(buffersize)-1) downto 0);
     pre_read_buffer  : std_logic_vector((log2(buffersize)-1) downto 0);
     pre_read_adr     : std_logic_vector((ahbadr-1) downto 0);
     pre_read_valid   : std_ulogic;
     use_write_buffer : std_logic_vector((log2(buffersize)-1) downto 0);
     rw_cmd_valid     : std_logic_vector((log2(buffersize)-1) downto 0);
     w_data_valid     : std_logic_vector((log2(buffersize)-1) downto 0);     

     sync_adr         : std_logic_vector((bufferadr-1) downto 0);
     sync_wdata       : std_logic_vector(2*(maxdqsize+maxdmsize)-1 downto 0);
     sync_write       : std_ulogic;
     sync_busy        : std_ulogic;
     sync_busy_adr    : std_logic_vector((bufferadr-1) downto 0);
     sync2_adr        : std_logic_vector((log2(buffersize)-1) downto 0);
     sync2_wdata      : std_logic_vector((ahbadr-1+1) downto 0);
     sync2_write      : std_ulogic;
     sync2_busy       : std_ulogic;

     doRead           : std_ulogic;
     doWrite          : std_ulogic;
     new_burst        : std_ulogic;
     startp           : integer range 0 to 7;
     ahbstartp        : integer range 0 to 7;
     even_odd_write   : integer range 0 to 1;
     burst_hsize      : integer range 1 to 8;
     offset           : std_logic_vector(2 downto 0);
     ahboffset        : std_logic_vector(2 downto 0);
     read_data        : std_logic_vector(maxdqsize-1 downto 0);
     cur_hrdata       : std_logic_vector((ahbdata-1) downto 0);
     cur_hready       : std_ulogic;
     cur_hresp        : std_logic_vector(1 downto 0);
     prev_retry       : std_ulogic;
     prev_error       : std_ulogic;
     burst_dm         : burst_mask_type;
   end record;

-------------------------------------------------------------------------------
 -- APB controller - Local variables
   type apb_reg_type is record
     ddrcfg_reg    : std_logic_vector(31 downto 0);
   end record;

-------------------------------------------------------------------------------
 -- High speed RW - Local variables
   type rw_reg_type is record
     cbufstate      : cmdbuffercycletype;
     cmdstate       : cmdcycletype;
     rwstate        : rwcycletype;
     cur_buf        : two_buf_adr_type;
     cur_ahb        : integer range 0 to 1;
     use_bl         : integer range 2 to 8;
     use_ml         : integer range 1 to 8;
     use_buf        : std_logic_vector((log2(buffersize)-1) downto 0);
     use_ahb        : integer range 0 to 1;
     use_cas        : std_ulogic;
     rw_cmd         : std_logic_vector(2 downto 0);
     rw_bl          : integer range 2 to 8;
     rw_cas         : integer range 2 to 3;
     next_bl        : integer range 2 to 8;
     next_ml        : integer range 1 to 8;
     next_buf       : std_logic_vector((log2(buffersize)-1) downto 0);
     next_ahb       : integer range 0 to 1;
     next_cas       : std_logic_vector(1 downto 0);
     next_adr       : std_logic_vector(adrbits-1 downto 0);
     next_cs        : std_logic_vector(1 downto 0);
     next_cmd       : std_logic_vector(2 downto 0);
     set_cmd        : std_logic_vector(2 downto 0);
     set_adr        : std_logic_vector(adrbits-1 downto 0);
     set_cs         : std_logic_vector(1 downto 0);
     set_cke        : std_ulogic;
     hs_busy        : std_ulogic;
     cmdDone        : two_buf_adr_type; 
     begin_read     : std_ulogic;
     begin_write    : std_ulogic;
     dq_dqs_oe      : std_ulogic;
     w_ce           : std_ulogic;
     r_ce           : std_ulogic; 
     cnt            : integer range 0 to 8;
     holdcnt        : integer range 0 to 31;
     r2wholdcnt     : integer range 0 to 15;
     act2precnt     : integer range 0 to 15;
     wait_time      : integer range 0 to 31;
     readwait       : std_logic_vector(6 downto 0);
     writewait      : std_logic_vector(1 downto 0);
     bufwait        : bufwaittype;
     ahbwait        : ahbwaittype;
     blwait         : blwaittype;
     mlwait         : mlwaittype;
     caswait        : std_logic_vector(6 downto 0);
     dm1_o          : std_logic_vector((maxdmsize-1) downto 0);
     dm2_o          : std_logic_vector((maxdmsize-1) downto 0);
     dqs1_o         : std_ulogic;
     sync_adr       : two_buf_data_type;
     sync_write     : std_logic_vector(1 downto 0);
     sync_wdata     : std_logic_vector(2*(maxdqsize+maxdmsize)-1 downto 0);             
   end record;
-------------------------------------------------------------------------------
 -- High speed CMD - Local variables
   type cmd_reg_type is record
     cur_cmd        : std_logic_vector(2 downto 0);
     cur_cs         : std_logic_vector(1 downto 0);
     cur_adr        : std_logic_vector(adrbits-1 downto 0);
     next_cmd       : std_logic_vector(2 downto 0);
     next_cs        : std_logic_vector(1 downto 0);
     next_adr       : std_logic_vector(adrbits-1 downto 0);
   end record;
-------------------------------------------------------------------------------
 -- Main controller - Local variables
   type main_reg_type is record
     -- For main controller
     mainstate        : maincycletype;    
     loadcmdbuffer    : std_ulogic;
     cmdbufferdata    : std_logic_vector(2 downto 0);
     adrbufferdata    : std_logic_vector(adrbits-1 downto 0);
     use_ahb          : integer range 0 to 1;
     use_bl           : integer range 2 to 8;
     use_cas          : std_logic_vector(1 downto 0);
     use_buf          : std_logic_vector((log2(buffersize)-1) downto 0);
     burstlength      : integer range 2 to 8;
     rw_cmd_done      : two_buf_adr_type;
     lmradr           : std_logic_vector(adrbits-1 downto 0);
     memCmdDone       : std_ulogic;
     lockAHB          : std_logic_vector(1 downto 0);
     pre_row          : pre_row_type;
     pre_chg          : std_logic_vector(7 downto 0);
     pre_bankadr      : two_pre_bank_type;
     sync2_adr        : two_buf_adr_type;

     -- For init statemachine
     initstate   : initcycletype;
     doMemInit   : std_ulogic;
     memInitDone : std_ulogic;
     initDelay   : integer range 0 to 255;
     cs          : std_logic_vector(1 downto 0);

      -- For address calculator
     coladdress    : two_ddr_adr_type;
     tmpcoladdress : two_ddr_adr_type;
     rowaddress    : two_ddr_adr_type;
     addressrange  : integer range 0 to 31;
     tmpcolbits    : integer range 0 to 15;
     colbits       : integer range 0 to 15;
     rowbits       : integer range 0 to 15;
     bankselect    : two_ddr_bank_type;
     intbankbits   : two_ddr_bank_type;
     
     -- For refresh timer statemachine
     timerstate     : timercycletype;
     doRefresh      : std_ulogic;
     refreshDone    : std_ulogic;
     refreshTime    : integer range 0 to 4095;
     maxRefreshTime : integer range 0 to 32767;
     idlecnt        : integer range 0 to 10;
     refreshcnt     : integer range 0 to 65535;

     -- For DDRCFG register (APB)
     apbstate         : apbcycletype;
     apb_cmd_done : std_ulogic;
     ready        : std_ulogic;
     ddrcfg       : config_out_type;
   end record;

-------------------------------------------------------------------------------
-- Components
-------------------------------------------------------------------------------
  
   component ahb_slv
     generic (
       hindex   :     integer := 0;
       haddr    :     integer := 0;
       hmask    :     integer := 16#f80#;
       sepclk   :     integer := 0;
       dqsize   :     integer := 64;
       dmsize   :     integer := 8;
       tech     :     integer := virtex2);
     port (
       rst      : in  std_ulogic;
       hclk     : in  std_ulogic;
       clk0     : in  std_ulogic;
       csi      : in  ahb_ctrl_in_type;
       cso      : out ahb_ctrl_out_type);
   end component;

   component ddr_in
     generic (
       tech     : integer);
     port (
       Q1       : out std_ulogic;
       Q2       : out std_ulogic;
       C1       : in std_ulogic;
       C2       : in std_ulogic;
       CE       : in std_ulogic;
--       DQS      : in std_logic; -- used for lattice
--       DDRCLKPOL: in std_logic; -- used for lattice
       D        : in std_ulogic;
       R        : in std_ulogic;
       S        : in std_ulogic);
   end component;


   component ddr_out
     generic (
       tech     : integer);
     port (
       Q        : out std_ulogic;
       C1       : in std_ulogic;
       C2       : in std_ulogic;
       CE       : in std_ulogic;
       D1       : in std_ulogic;
       D2       : in std_ulogic;
       R        : in std_ulogic;
       S        : in std_ulogic);
   end component;


   component hs
     generic(
       tech      : in integer;
       dqsize    : in integer;
       dmsize    : in integer;
       strobesize: in integer;
       clkperiod : in integer);
     port (
       rst       : in std_ulogic;
       clk0      : in std_ulogic;
       clk90     : in std_ulogic;
       clk180    : in std_ulogic;
       clk270    : in std_ulogic;
       hclk      : in std_ulogic;
       hssi      : in hs_in_type;
       hsso      : out hs_out_type);
   end component;
   
end ddrrec;




