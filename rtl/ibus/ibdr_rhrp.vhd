-- $Id: ibdr_rhrp.vhd 682 2015-05-15 18:35:29Z mueller $
--
-- Copyright 2015- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
-- This program is free software; you may redistribute and/or modify it under
-- the terms of the GNU General Public License as published by the Free
-- Software Foundation, either version 2, or at your option any later version.
--
-- This program is distributed in the hope that it will be useful, but
-- WITHOUT ANY WARRANTY, without even the implied warranty of MERCHANTABILITY
-- or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
-- for complete details.
--
------------------------------------------------------------------------------
-- Module Name:    ibdr_rhrp - syn
-- Description:    ibus dev(rem): RHRP
--
-- Dependencies:   ram_1swar_gen
-- Test bench:     -
-- Target Devices: generic
-- Tool versions:  ise 14.7; viv 2014.4; ghdl 0.31
--
-- Synthesized (xst):
-- Date         Rev  ise         Target      flop lutl lutm slic t peri
-- 2015-05-14   680 14.7  131013 xc6slx16-2   211  408    8  131 s  8.8
-- 2015-04-06   664 14.7  131013 xc6slx16-2   177  331    8  112 s  8.7
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2015-05-15   682   1.0.1  correct ibsel range select logic
-- 2015-05-14   680   1.0    Initial version
-- 2015-03-15   658   0.1    First draft
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.memlib.all;
use work.iblib.all;

-- ----------------------------------------------------------------------------
entity ibdr_rhrp is                     -- ibus dev(rem): RH+RP
                                        -- fixed address: 176700
  port (
    CLK : in slbit;                     -- clock
    CE_USEC : in slbit;                 -- usec pulse
    BRESET : in slbit;                  -- ibus reset
    ITIMER : in slbit;                  -- instruction timer
    RB_LAM : out slbit;                 -- remote attention
    IB_MREQ : in ib_mreq_type;          -- ibus request
    IB_SRES : out ib_sres_type;         -- ibus response
    EI_REQ : out slbit;                 -- interrupt request
    EI_ACK : in slbit                   -- interrupt acknowledge
  );

  -- by default xst uses a binary encoding for the main fsm.
  -- that give quite sub-optimal results, so force one-hot
  attribute fsm_encoding : string;
  attribute fsm_encoding of ibdr_rhrp : entity is "one-hot";
  
end entity ibdr_rhrp;

architecture syn of ibdr_rhrp is

  constant ibaddr_rhrp : slv16 := slv(to_unsigned(8#176700#,16));

                                          --  nam  rw mb  rp     rm     storage
  constant ibaddr_cs1 : slv5 := "00000";  --  cs1  rw  0  rpcs1  rmcs1  m d,6+r
  constant ibaddr_wc  : slv5 := "00001";  --   wc  rw  -  rpwc   rmwc   m 0,7
  constant ibaddr_ba  : slv5 := "00010";  --   ba  rw  -  rpba   rmba   m 1,7
  constant ibaddr_da  : slv5 := "00011";  --   da  rw  5  rpda   rmda   m d,0
  constant ibaddr_cs2 : slv5 := "00100";  --  cs2  rw  -  rpcs2  rmcs2  r cs2*
  constant ibaddr_ds  : slv5 := "00101";  --   ds  r-  1  rpds   rmds   r ds*
  constant ibaddr_er1 : slv5 := "00110";  --  er1  rw  2  rper1  rmer1  r er1*
  constant ibaddr_as  : slv5 := "00111";  --   as  rw  4  rpas   rmas   r as*
  constant ibaddr_la  : slv5 := "01000";  --   la  r-  7  rpla   rmla   r sc
  constant ibaddr_db  : slv5 := "01001";  --   db  r?  -  rpdb   rmdb   m 2,7
  constant ibaddr_mr1 : slv5 := "01010";  --  mr1  rw  3  rpmr1  rmmr1  m d,3
  constant ibaddr_dt  : slv5 := "01011";  --   dt  r-  6  rpdt   rmdt   r dt*+map
  constant ibaddr_sn  : slv5 := "01100";  --   sn  r- 10  rpsn   rmsn   <map>
  constant ibaddr_of  : slv5 := "01101";  --   of  rw 11  rpof   rmof   m d,1
  constant ibaddr_dc  : slv5 := "01110";  --   dc  rw 12  rpdc   rmdc   m d,2
  constant ibaddr_m13 : slv5 := "01111";  --  m13  rw 13  rpcc          m =dc!
                                          --       rw 13         rmhr   m d,4
  constant ibaddr_m14 : slv5 := "10000";  --  m14  rw 14  rper2         =0
                                          --       rw 14         rmmr2  m d,5
  constant ibaddr_m15 : slv5 := "10001";  --  m15  rw 15  rper3         =0
                                          --       rw 15         rmer2  =0
  constant ibaddr_ec1 : slv5 := "10010";  --  ec1  r- 16  rpec1  rmec1  =0
  constant ibaddr_ec2 : slv5 := "10011";  --  ec1  r- 17  rpec2  rmec2  =0
  constant ibaddr_bae : slv5 := "10100";  --  bae  rw  -  rpbae  rmbae  r bae
  constant ibaddr_cs3 : slv5 := "10101";  --  cs3  rw  -  rpcs3  rmcs3  r cs3*

  constant omux_cs1  : slv4 := "0000";
  constant omux_cs2  : slv4 := "0001";
  constant omux_ds   : slv4 := "0010";
  constant omux_er1  : slv4 := "0011";
  constant omux_as   : slv4 := "0100";
  constant omux_la   : slv4 := "0101";
  constant omux_dt   : slv4 := "0110";
  constant omux_sn   : slv4 := "0111";
  constant omux_bae  : slv4 := "1000";
  constant omux_cs3  : slv4 := "1001";
  constant omux_mem  : slv4 := "1010";
  constant omux_zero : slv4 := "1111";

  constant amapc_da  : slv3 := "000";
  constant amapc_mr1 : slv3 := "011";
  constant amapc_of  : slv3 := "001";
  constant amapc_dc  : slv3 := "010";
  constant amapc_hr  : slv3 := "100";
  constant amapc_mr2 : slv3 := "101"; 
  constant amapc_cs1 : slv3 := "110"; 
  constant amapc_ext : slv3 := "111";

  constant amapr_wc  : slv2 := "00";
  constant amapr_ba  : slv2 := "01";
  constant amapr_db  : slv2 := "10";

  subtype  amap_f_unit     is integer range  4 downto  3;  -- unit part
  subtype  amap_f_reg      is integer range  2 downto  0;  -- reg  part

  constant clrmode_breset : slv2 := "00";
  constant clrmode_cs2clr : slv2 := "01";
  constant clrmode_fdclr  : slv2 := "10";
  constant clrmode_fpres  : slv2 := "11";
  
  constant cs1_ibf_sc    : integer := 15;     -- special condition
  constant cs1_ibf_tre   : integer := 14;     -- transfer error
  constant cs1_ibf_dva   : integer := 11;     -- drive available
  subtype  cs1_ibf_bae     is integer range  9 downto  8;  -- bus addr ext (1:0)
  constant cs1_ibf_rdy   : integer :=  7;     -- controller ready
  constant cs1_ibf_ie    : integer :=  6;     -- interrupt enable
  subtype  cs1_ibf_func    is integer range  5 downto  1;  -- function code
  constant cs1_ibf_go    : integer :=  0;     -- interrupt enable

  constant func_noop  : slv5 := "00000";   -- func: noop
  constant func_unl   : slv5 := "00001";   -- func: unload
  constant func_seek  : slv5 := "00010";   -- func: seek
  constant func_recal : slv5 := "00011";   -- func: recalibrate
  constant func_dclr  : slv5 := "00100";   -- func: drive clear
  constant func_pore  : slv5 := "00101";   -- func: port release
  constant func_offs  : slv5 := "00110";   -- func: offset
  constant func_retc  : slv5 := "00111";   -- func: return to center
  constant func_pres  : slv5 := "01000";   -- func: readin preset
  constant func_pack  : slv5 := "01001";   -- func: pack acknowledge
  constant func_sear  : slv5 := "01100";   -- func: search
  constant func_wcd   : slv5 := "10100";   -- func: write check data
  constant func_wchd  : slv5 := "10101";   -- func: write check header&data
  constant func_write : slv5 := "11000";   -- func: write 
  constant func_whd   : slv5 := "11001";   -- func: write header&data
  constant func_read  : slv5 := "11100";   -- func: read  
  constant func_rhd   : slv5 := "11101";   -- func: read header&data

  constant rfunc_wunit : slv5 := "00001";   -- rem func: write runit
  constant rfunc_cunit : slv5 := "00010";   -- rem func: copy funit->runit
  constant rfunc_done  : slv5 := "00011";   -- rem func: done (set rdy)
  constant rfunc_widly : slv5 := "00100";   -- rem func: write idly

  -- cs1 usage for rem functions
  subtype  cs1_ibf_runit   is integer range  9 downto  8;  -- new runit (_wunit)
  constant cs1_ibf_rata  : integer := 8;                   -- use ata   (_done)
  subtype  cs1_ibf_ridly   is integer range 15 downto  8;  -- new idly  (_widly)

  subtype  da_ibf_ta       is integer range 12 downto  8;  -- track  addr
  subtype  da_ibf_sa       is integer range  5 downto  0;  -- sector addr

  constant cs2_ibf_rwco  : integer := 15;     -- rem: write check odd word
  constant cs2_ibf_wce   : integer := 14;     -- write check error
  constant cs2_ibf_ned   : integer := 12;     -- non-existant drive
  constant cs2_ibf_nem   : integer := 11;     -- non-existant memory
  constant cs2_ibf_pge   : integer := 10;     -- programming error
  constant cs2_ibf_mxf   : integer :=  9;     -- missed transfer
  constant cs2_ibf_or    : integer :=  7;     -- output ready
  constant cs2_ibf_ir    : integer :=  6;     -- input ready
  constant cs2_ibf_clr   : integer :=  5;     -- clear controller
  constant cs2_ibf_pat   : integer :=  4;     -- parity test
  constant cs2_ibf_bai   : integer :=  3;     -- bus address inhibit
  constant cs2_ibf_unit2 : integer :=  2;     -- unit select msb
  subtype  cs2_ibf_unit    is integer range  1 downto  0;  -- unit select

  constant ds_ibf_ata    : integer := 15;     -- attention
  constant ds_ibf_erp    : integer := 14;     -- any errors in er1 or er2
  constant ds_ibf_pip    : integer := 13;     -- positioning in progress
  constant ds_ibf_mol    : integer := 12;     -- medium online (ATTACHED)
  constant ds_ibf_wrl    : integer := 11;     -- write locked
  constant ds_ibf_lbt    : integer := 10;     -- last block transfered
  constant ds_ibf_dpr    : integer :=  8;     -- drive present (ENABLED)
  constant ds_ibf_dry    : integer :=  7;     -- drive ready
  constant ds_ibf_vv     : integer :=  6;     -- volume valid
  constant ds_ibf_om     : integer :=  0;     -- offset mode

  constant er1_ibf_uns   : integer := 14;     -- drive unsafe
  constant er1_ibf_wle   : integer := 11;     -- write lock error
  constant er1_ibf_iae   : integer := 10;     -- invalid address error
  constant er1_ibf_aoe   : integer :=  9;     -- address overflow error
  constant er1_ibf_rmr   : integer :=  2;     -- register modification refused
  constant er1_ibf_ilf   : integer :=  0;     -- illegal function

  subtype  la_ibf_sc       is integer range 11 downto  6;  -- current sector

  constant dt_ibf_rm     : integer :=  2;     -- rm cntl
  constant dt_ibf_e1     : integer :=  1;     -- encoded type bit 1
  constant dt_ibf_e0     : integer :=  0;     -- encoded type bit 0

  constant dte_rp04      : slv3 :=  "000";    -- encoded dt for rp04 rm=0
  constant dte_rp06      : slv3 :=  "001";    -- encoded dt for rp06 rm=0
  constant dte_rm03      : slv3 :=  "100";    -- encoded dt for rm03 rm=1
  constant dte_rm80      : slv3 :=  "101";    -- encoded dt for rm80 rm=1
  constant dte_rm05      : slv3 :=  "110";    -- encoded dt for rm05 rm=1
  constant dte_rp07      : slv3 :=  "111";    -- encoded dt for rp07 rm=1

  subtype  dc_ibf_ca       is integer range  9 downto  0;  -- cyclinder addr

  subtype  bae_ibf_bae     is integer range  5 downto  0;  -- bus addr ext.

  constant cs3_ibf_wco       : integer := 12;     -- write check odd
  constant cs3_ibf_wce       : integer := 11;     -- write check even
  constant cs3_ibf_ie        : integer :=  6;     -- interrupt enable
  constant cs3_ibf_rseardone : integer :=  3;     -- rem: sear done flag
  constant cs3_ibf_rpackdone : integer :=  2;     -- rem: pack done flag
  constant cs3_ibf_rporedone : integer :=  1;     -- rem: pore done flag
  constant cs3_ibf_rseekdone : integer :=  0;     -- rem: seek done flag

  -- RP controller type disks
  constant rp04_dtyp   : slv6  := slv(to_unsigned(  8#20#,  6));
  constant rp04_camax  : slv10 := slv(to_unsigned(  411-1, 10));
  constant rp04_tamax  : slv5  := slv(to_unsigned(   19-1,  5));
  constant rp04_samax  : slv6  := slv(to_unsigned(   22-1,  6));
  
  constant rp06_dtyp   : slv6  := slv(to_unsigned(  8#22#,  6));
  constant rp06_camax  : slv10 := slv(to_unsigned(  815-1, 10));
  constant rp06_tamax  : slv5  := slv(to_unsigned(   19-1,  5));
  constant rp06_samax  : slv6  := slv(to_unsigned(   22-1,  6));
  
  -- RM controller type disks (Note: rp07 has a RM stype controller!)
  constant rm03_dtyp   : slv6  := slv(to_unsigned(  8#24#,  6));
  constant rm03_camax  : slv10 := slv(to_unsigned(  823-1, 10));
  constant rm03_tamax  : slv5  := slv(to_unsigned(    5-1,  5));
  constant rm03_samax  : slv6  := slv(to_unsigned(   32-1,  6));
  
  constant rm80_dtyp   : slv6  := slv(to_unsigned(  8#26#,  6));
  constant rm80_camax  : slv10 := slv(to_unsigned(  559-1, 10));
  constant rm80_tamax  : slv5  := slv(to_unsigned(   14-1,  5));
  constant rm80_samax  : slv6  := slv(to_unsigned(   31-1,  6));
  
  constant rm05_dtyp   : slv6  := slv(to_unsigned(  8#27#,  6));
  constant rm05_camax  : slv10 := slv(to_unsigned(  823-1, 10));
  constant rm05_tamax  : slv5  := slv(to_unsigned(   19-1,  5));
  constant rm05_samax  : slv6  := slv(to_unsigned(   32-1,  6));
  
  constant rp07_dtyp   : slv6  := slv(to_unsigned(  8#42#,  6));
  constant rp07_camax  : slv10 := slv(to_unsigned(  630-1, 10));
  constant rp07_tamax  : slv5  := slv(to_unsigned(   32-1,  5));
  constant rp07_samax  : slv6  := slv(to_unsigned(   50-1,  6));

  type state_type is (
    s_idle,                             -- idle: handle ibus
    s_wcs1,                             -- wcs1: write cs1
    s_wcs2,                             -- wcs2: write cs2
    s_wcs3,                             -- wcs3: write cs3
    s_wer1,                             -- wer1: write er1 (rem only)
    s_was,                              -- was:  write as
    s_wdt,                              -- wdt:  write dt  (rem only)
    s_wds,                              -- wdt:  write ds  (rem only)
    s_wbae,                             -- wbae: write bae
    s_wmem,                             -- wmem: write mem (DA,MR1,OF,DC,MR2)
    s_wmembe,                           -- wmem: write mem with be (WC,BA,DB)
    s_whr,                              -- whr:  write hr (holding reg only)
    s_funcgo,                           -- funcgo: handle function go
    s_chkdc,                            -- chkdc: handle dc check
    s_chkda,                            -- chksa: handle da check
    s_chkdo,                            -- chkdo: execute function
    s_read,                             -- read: all register reads
    s_setrmr,                           -- set rmr flag
    s_oot_clr0,                         -- OOT clr0: state 0
    s_oot_clr1,                         -- OOT clr1: state 1
    s_oot_clr2                          -- OOT clr2: state 2
  );

  type regs_type is record              -- state registers
    ibsel   : slbit;                    -- ibus select
    state   : state_type;               -- state
    amap    : slv5;                     -- mem mapped address
    omux    : slv4;                     -- omux select
    dinmsk  : slv16;                    -- mbreq.din masked
    dtrm    : slv4;                     -- dt: drive rm controller
    dte1    : slv4;                     -- dt: drive type bit 1
    dte0    : slv4;                     -- dt: drive type bit 0
    bae     : slv6;                     -- bae: bus addr extension (in cs1&bae)
    cs1sc   : slbit;                    -- cs1: special condition
    cs1tre  : slbit;                    -- cs1: transfer error
    cs1rdy  : slbit;                    -- cs1: controller ready
    cs1ie   : slbit;                    -- cs1: interrupt enable
    ffunc   : slv5;                     -- func code (frozen on ext func go)
    fxfer   : slbit;                    -- func is xfer
    cs2wce  : slbit;                    -- cs2: write check error
    cs2ned  : slbit;                    -- cs2: non-existant drive
    cs2nem  : slbit;                    -- cs2: non-existant memory
    cs2pge  : slbit;                    -- cs2: programming error
    cs2mxf  : slbit;                    -- cs2: missed transfer
    cs2pat  : slbit;                    -- cs2: parity test
    cs2bai  : slbit;                    -- cs2: bus address inhibit
    cs2unit2: slbit;                    -- cs2: unit lsb
    cs2unit : slv2;                     -- unit (ibus view)
    funit   : slv2;                     -- unit (frozen on ext func go)
    runit   : slv2;                     -- unit (remote view)
    eunit   : slv2;                     -- unit (effective)
    dsata   : slv4;                     -- ds: attention
    dserp   : slv4;                     -- ds: error summary (or of er1+er2)
    dspip   : slv4;                     -- ds: positioning in progress
    dsmol   : slv4;                     -- ds: medium online (ATTACHED)
    dswrl   : slv4;                     -- ds: write locked
    dslbt   : slv4;                     -- ds: last block transfered
    dsdpr   : slv4;                     -- ds: drive present (ENABLED)
    dsvv    : slv4;                     -- ds: volume valid
    dsom    : slv4;                     -- ds: offset mode
    er1uns  : slv4;                     -- er1: dive unsafe
    er1wle  : slv4;                     -- er1: write lock error
    er1iae  : slv4;                     -- er1: invalid address error
    er1aoe  : slv4;                     -- er1: address overflow error
    er1rmr  : slv4;                     -- er1: register modificaton refused
    er1ilf  : slv4;                     -- er1: illegal function
    cs3wco  : slbit;                    -- cs3: write check  odd word
    idlyval : slv8;                     -- int delay value
    idlycnt : slv8;                     -- int delay counter
    seekdone: slbit;                    -- cs3 rem: seek     done
    poredone: slbit;                    -- cs3 rem: port rel done
    packdone: slbit;                    -- cs3 rem: pack ack done
    seardone: slbit;                    -- cs3 rem: search   done
    ned     : slbit;                    -- current drive non-existant
    cerm    : slbit;                    -- current eff. drive rm controller
    dtyp    : slv6;                     -- current drive type (5:0)
    camax   : slv10;                    -- current max cylinder address
    tamax   : slv5;                     -- current max track  address
    samax   : slv6;                     -- current max sector address
    uscnt   : slv7;                     -- usec counter
    sc      : slv6;                     -- current sector counter
    clrmode : slv2;                     -- clear: mode
    clrreg  : slv3;                     -- clear: register counter
    ireq    : slbit;                    -- interrupt request flag
  end record regs_type;

  constant regs_init : regs_type := (
    '0',                                -- ibsel
    s_idle,                             -- state
    (others=>'0'),                      -- amap,
    (others=>'0'),                      -- omux,
    (others=>'0'),                      -- dinmsk,
    (others=>'0'),                      -- dtrm
    (others=>'0'),                      -- dte1
    (others=>'0'),                      -- dte0
    (others=>'0'),                      -- bae,
    '0','0','1','0',                    -- cs1sc,cs1tre,cs1rdy,cs1ie
    (others=>'0'),                      -- ffunc
    '0',                                -- fxfer
    '0','0','0','0',                    -- cs2wce,cs2ned,cs2nem,cs2pge
    '0','0','0',                        -- cs2mxf,cs2pat,cs2bai
    '0',                                -- cs2unit2
    (others=>'0'),                      -- cs2unit
    (others=>'0'),                      -- funit
    (others=>'0'),                      -- runit
    (others=>'0'),                      -- eunit
    (others=>'0'),                      -- dsata
    (others=>'0'),                      -- dserp
    (others=>'0'),                      -- dspip
    (others=>'0'),                      -- dsmol
    (others=>'0'),                      -- dswrl
    (others=>'0'),                      -- dslbt
    (others=>'0'),                      -- dsdpr
    (others=>'0'),                      -- dsvv
    (others=>'0'),                      -- dsom
    (others=>'0'),                      -- er1uns
    (others=>'0'),                      -- er1wle
    (others=>'0'),                      -- er1iae
    (others=>'0'),                      -- er1aoe
    (others=>'0'),                      -- er1rmr
    (others=>'0'),                      -- er1ilf
    '0',                                -- cs3wco
    x"0a",                              -- idlyval  (default delay=10)
    (others=>'0'),                      -- idlycnt
    '0','0','0','0',                    -- seekdone,poredone,packdone,seardone
    '0','0',                            -- ned,cerm
    (others=>'0'),                      -- dtyp
    (others=>'0'),                      -- camax
    (others=>'0'),                      -- tamax
    (others=>'0'),                      -- samax
    (others=>'0'),                      -- uscnt
    (others=>'0'),                      -- sc
    (others=>'0'),                      -- clrmode
    (others=>'0'),                      -- clrreg
    '0'                                 -- ireq
  );

  signal R_REGS : regs_type := regs_init;
  signal N_REGS : regs_type := regs_init;

  signal MEM_1_WE : slbit := '0';
  signal MEM_0_WE : slbit := '0';
  signal MEM_ADDR : slv5  := (others=>'0');
  signal MEM_DIN  : slv16 := (others=>'0');
  signal MEM_DOUT : slv16 := (others=>'0');

  -- the following is unfortunately not accepted by xst:
  -- attribute fsm_encoding : string;
  -- attribute fsm_encoding of R_REGS.state : signal is "one-hot";
  
begin
  
  MEM_1 : ram_1swar_gen
    generic map (
      AWIDTH =>  5,
      DWIDTH =>  8)
    port map (
      CLK  => CLK,
      WE   => MEM_1_WE,
      ADDR => MEM_ADDR,
      DI   => MEM_DIN(ibf_byte1),
      DO   => MEM_DOUT(ibf_byte1));

  MEM_0 : ram_1swar_gen
    generic map (
      AWIDTH =>  5,
      DWIDTH =>  8)
    port map (
      CLK  => CLK,
      WE   => MEM_0_WE,
      ADDR => MEM_ADDR,
      DI   => MEM_DIN(ibf_byte0),
      DO   => MEM_DOUT(ibf_byte0));

  proc_regs: process (CLK)
  begin
    -- BRESET handled in main fsm, not here !!
    if rising_edge(CLK) then
      R_REGS <= N_REGS;
    end if;
  end process proc_regs;

  proc_next : process (R_REGS, CE_USEC, BRESET, ITIMER, IB_MREQ, MEM_DOUT,
                       EI_ACK)
    variable r : regs_type := regs_init;
    variable n : regs_type := regs_init;
    variable ibhold : slbit := '0';
    variable idout  : slv16 := (others=>'0');
    variable ibrem  : slbit := '0';
    variable ibreq  : slbit := '0';
    variable ibrd   : slbit := '0';
    variable ibw0   : slbit := '0';
    variable ibw1   : slbit := '0';
    variable ibwrem : slbit := '0';
    variable ilam   : slbit := '0';
    variable iei_req : slbit := '0';

    variable imem_we0 : slbit := '0';
    variable imem_we1 : slbit := '0';
    variable imem_addr : slv5 := (others=>'0');
    variable imem_din : slv16 := (others=>'0');

    variable ieunit  : slv2 := (others=>'0');

    variable iomux  : slv4  := (others=>'0');   -- omux select
    variable iamap  : slv5  := (others=>'0');   -- mem mapped address
    variable imask  : slv16 := (others=>'0');   -- implemented bits mask
    variable imbreg : slbit := '0';             -- massbus register
    variable inormr : slbit := '0';             -- inhibit rmr protect

    variable idte   : slv3  := (others=>'0');   -- encoded drive type
    variable idtyp  : slv6  := (others=>'0');   -- drive type (5:0)
    variable icamax : slv10 := (others=>'0');   -- max cylinder address
    variable itamax : slv5  := (others=>'0');   -- max track    address
    variable isamax : slv6  := (others=>'0');   -- max sector   address

    variable ined   : slbit := '0';     -- non-existanrt drive
    variable icerm  : slbit := '0';     -- effectiv drive is rm

    variable iclrreg : slbit := '0';    -- clr enable

    variable iscinc  : slbit := '0';    -- increment r.sc enable

  begin

    r := R_REGS;
    n := R_REGS;

    ibhold := '0';
    idout  := (others=>'0');
    ibrem  := IB_MREQ.racc;
    ibreq  := IB_MREQ.re or IB_MREQ.we;
    ibrd   := IB_MREQ.re;
    ibw0   := IB_MREQ.we and IB_MREQ.be0;
    ibw1   := IB_MREQ.we and IB_MREQ.be1;
    ibwrem := IB_MREQ.we and ibrem;
    ilam   := '0';
    iei_req  := '0';
  
    imem_we0  := '0';
    imem_we1  := '0';
    imem_addr := r.amap;                -- default address (from mapper)
    imem_din  := r.dinmsk;              -- default input   (from masker)

    ieunit := (others=>'0');

    iomux  := (others=>'0');
    iamap  := (others=>'0');
    imask  := (others=>'1');            -- default: all bits ok
    imbreg := '0';
    inormr := '0';

    idte   := (others=>'0');
    idtyp  := (others=>'0');
    icamax := (others=>'0');
    itamax := (others=>'0');
    isamax := (others=>'0');

    ined   := '0';
    icerm  := '0';

    iclrreg := '0';

    iscinc  := '0';

    -- ibus address decoder, accept only offsets 0 to ibaddr_cs3
    n.ibsel := '0';
    if IB_MREQ.aval = '1' and
       IB_MREQ.addr(12 downto 6) = ibaddr_rhrp(12 downto 6) and
       unsigned(IB_MREQ.addr(5 downto 1)) <= unsigned(ibaddr_cs3) then
      n.ibsel := '1';
    end if;
    
    -- internal state machine
    case r.state is
      when s_idle =>                    -- idle: handle ibus -----------------

        if r.ibsel='1' then               -- selected

          -- determine effective unit number
          if ibrem = '1' then
            ieunit := r.runit;
          else
            ieunit := r.cs2unit;
          end if;
          n.eunit := ieunit;

          -- determine drive properties (always via iunit) FIXME: correct ??
          idte(2) := r.dtrm(to_integer(unsigned(r.cs2unit)));
          idte(1) := r.dte1(to_integer(unsigned(r.cs2unit)));
          idte(0) := r.dte0(to_integer(unsigned(r.cs2unit)));
          case idte is
            when dte_rp04 =>            -- RP04
              idtyp  := rp04_dtyp;
              icamax := rp04_camax;
              itamax := rp04_tamax;
              isamax := rp04_samax;
            when dte_rp06 =>            -- RP06
              idtyp  := rp06_dtyp;
              icamax := rp06_camax;
              itamax := rp06_tamax;
              isamax := rp06_samax;
            when dte_rm03 =>            -- RM03
              idtyp  := rm03_dtyp;
              icamax := rm03_camax;
              itamax := rm03_tamax;
              isamax := rm03_samax;
            when dte_rm80 =>            -- RM80
              idtyp  := rm80_dtyp;
              icamax := rm80_camax;
              itamax := rm80_tamax;
              isamax := rm80_samax;
            when dte_rm05 =>            -- RM05
              idtyp  := rm05_dtyp;
              icamax := rm05_camax;
              itamax := rm05_tamax;
              isamax := rm05_samax;
            when dte_rp07 =>            -- RP07
              idtyp  := rp07_dtyp;
              icamax := rp07_camax;
              itamax := rp07_tamax;
              isamax := rp07_samax;
            when others =>
              idtyp  := (others=>'0');
              icamax := (others=>'0');
              itamax := (others=>'0');     
              isamax := (others=>'0');     
          end case; -- case idte
          n.dtyp  := idtyp;
          n.camax := icamax;
          n.tamax := itamax;
          n.samax := isamax;

          -- consider drive non-existant if not 'DPR' or unit>=4 selected
          if r.dsdpr(to_integer(unsigned(r.cs2unit))) = '0' or
             r.cs2unit2 = '1' then
            ined := '1';
          end if;
          n.ned := ined;
          
          icerm   := r.dtrm(to_integer(unsigned(ieunit)));
          n.cerm  := icerm;
          
          -- setup mapper 
          case IB_MREQ.addr(5 downto 1) is

            when ibaddr_cs1  =>             -- RxCS1 control reg 1 
              -- cs1 not flagged mbreg !! ned handling done explicitely
              iamap  := ieunit & amapc_cs1;
              iomux  := omux_cs1;

            when ibaddr_wc   =>             -- RxWC  word count 
              iamap  := amapr_wc & amapc_ext;
              iomux  := omux_mem;

            when ibaddr_ba   =>             -- RxBA  bus address 
              imask  := "1111111111111110";     -- lsb ignored
              iamap  := amapr_ba & amapc_ext;
              iomux  := omux_mem;

            when ibaddr_da   =>             -- RxDA  disk address 
              imask  := "0001111100111111";    -- 000t tttt 00ss ssss
              iamap  := ieunit & amapc_da;
              iomux  := omux_mem;
              imbreg := '1';                   -- mb 5

            when ibaddr_cs2  =>             -- RxCS2 control reg 2
              iomux  := omux_cs2;

            when ibaddr_ds   =>             -- RxDS  drive status 
              iomux  := omux_ds;
              imbreg := '1';                   -- mb 1

            when ibaddr_er1  =>             -- RxER1 error status 1 
              iomux  := omux_er1;
              imbreg := '1';                  -- mb 2

            when ibaddr_as   =>             -- RxAS  attention summary 
              iomux  := omux_as;
              imbreg := '1';                  -- mb 4
              inormr := '1';                  -- AS writes allowed when RDY=0

            when ibaddr_la   =>             -- RxLA  look ahead 
              iomux  := omux_la;
              imbreg := '1';                  -- mb 7

            when ibaddr_db   =>             -- RxDB  data buffer 
              iamap  := amapr_db & amapc_ext;
              iomux  := omux_mem;

            when ibaddr_mr1  =>             -- RxMR1 maintenance reg 1 
              iamap  := ieunit & amapc_mr1;
              iomux  := omux_mem;
              imbreg := '1';                  -- mb 3
              inormr := '1';                  -- MR1 writes allowed when RDY=0

            when ibaddr_dt   =>             -- RxDT  drive type 
              iomux  := omux_dt;
              imbreg := '1';                  -- mb 6

            when ibaddr_sn   =>             -- RxSN  serial number 
              iomux  := omux_sn;
              imbreg := '1';                  -- mb 10

            when ibaddr_of   =>             -- RxOF  offset reg 
              imask  := "0001110011111111";   -- 000f eh00 d??? ????
              iamap  := ieunit & amapc_of;
              iomux  := omux_mem;
              imbreg := '1';                  -- mb 11

            when ibaddr_dc   =>             -- RxDC  desired cylinder 
              imask  := "0000001111111111";   -- 0000 00cc cccc cccc
              iamap  := ieunit & amapc_dc;
              iomux  := omux_mem;
              imbreg := '1';                  -- mb 12

            when ibaddr_m13  =>
              if icerm = '1' then
                iamap := ieunit & amapc_hr;  -- RMHR  holding reg
              else
                iamap := ieunit & amapc_dc;  -- RPDC  current cylinder
              end if;
              iomux  := omux_mem;
              imbreg := '1';                   -- mb 13

            when ibaddr_m14  =>
              if icerm = '1' then
                iamap := ieunit & amapc_mr2; -- RMMR2 maintenance reg 2
                iomux := omux_mem;
              else
                iomux := omux_zero;            -- RPER2 error status 2
              end if; 
              imbreg := '1';                  -- mb 14

            when ibaddr_m15  =>             -- RxER3 error status 3/2
              iomux  := omux_zero;
              imbreg := '1';                  -- mb 15

            when ibaddr_ec1  =>             -- RxEC1 ecc status 1 
              iomux  := omux_zero;
              imbreg := '1';                  -- mb 16

            when ibaddr_ec2  =>             -- RxEC2 ecc status 2 
              iomux  := omux_zero;
              imbreg := '1';                  -- mb 17

            when ibaddr_bae  =>             -- RxBAE bus addr extension
              iomux  := omux_bae;

            when ibaddr_cs3  =>             -- RxCS3 control reg 3 
              iomux  := omux_cs3;
              
            when others => null;            -- doesn't happen, ibsel only for
                                            -- subrange up to cs3, and all
                                            -- 22 regs are decoded above
              
          end case; -- case IB_MREQ.addr
          n.amap   := iamap;
          n.omux   := iomux;
          n.dinmsk := imask and IB_MREQ.din;

          if IB_MREQ.we = '1' then          -- write request
            ibhold := '1';                    -- assume follow-up state taken
            case IB_MREQ.addr(5 downto 1) is
              
              when ibaddr_cs1  => n.state := s_wcs1;   -- RxCS1
              when ibaddr_wc   => n.state := s_wmembe; -- RxWC
              when ibaddr_ba   => n.state := s_wmembe; -- RxBA
              when ibaddr_da   => n.state := s_wmem;   -- RxDA
              when ibaddr_cs2  => n.state := s_wcs2;   -- RxCS2
              when ibaddr_ds   => n.state := s_wds;    -- RxDS  (read-only)
              when ibaddr_er1  => n.state := s_wer1;   -- RxER1 (read-only)
              when ibaddr_as   => n.state := s_was;    -- RxAS
              when ibaddr_la   => n.state := s_whr;    -- RxLA  (read-only)
              when ibaddr_db   => n.state := s_wmembe; -- RxDB
              when ibaddr_mr1  => n.state := s_wmem;   -- RxMR1
              when ibaddr_dt   => n.state := s_wdt;    -- RxDT  (read-only)
              when ibaddr_sn   => n.state := s_whr;    -- RxSN  (read-only)
              when ibaddr_of   => n.state := s_wmem;   -- RxOF
              when ibaddr_dc   => n.state := s_wmem;   -- RxDC
              when ibaddr_m13  => n.state := s_whr;    -- RPCC|RMHR (fits both)
              when ibaddr_m14  =>
                if icerm = '1' then
                  n.state := s_wmem;                   -- RMMR2
                else
                  n.state := s_whr;                    -- RPER2
                end if;
              when ibaddr_m15  => n.state := s_whr;    -- RPER3|RMER2 (fits both)
              when ibaddr_ec1  => n.state := s_whr;    -- RxEC1
              when ibaddr_ec2  => n.state := s_whr;    -- RxEC2
              when ibaddr_bae  => n.state := s_wbae;   -- RxBAE
              when ibaddr_cs3  => n.state := s_wcs3;   -- RxCS3

              when others => null;           -- doesn't happen, ibsel only for
                                             -- subrange up to cs3, and all
                                             -- 22 regs are decoded above
          
            end case; -- case IB_MREQ.addr

            -- some general error catchers
            if ibrem = '0' and imbreg='1' then     -- local massbus write
                                                   --   for cs1: imbreg=0 !!
              if ined = '1' then
                n.cs2ned := '1';
              elsif inormr='0' and r.cs1rdy='0' then  -- rmr prot reg and RDY=0
                n.state := s_setrmr;
              end if;
            end if;
            
          elsif IB_MREQ.re = '1' then   -- read request
            if ibrem='0' and imbreg='1' and ined='1' then   
              n.cs2ned := '1';            -- signal error
            else
              ibhold  := '1';
              n.state := s_read;
            end if;

          end if; --  if IB_MREQ.we .. elsif IB_MREQ.re 

        -- BRESET and ITIMER can be handled in the 'else' because both can
        -- never come during an ibus transaction. Done here to keep logic
        -- path in the 'if' short.
        else -- if r.ibsel='1'
          if BRESET = '1' then
            n.eunit   := "00";
            n.clrmode := clrmode_breset;
            n.state   := s_oot_clr0;             -- OOT state, no hold!
          end if;

          if unsigned(r.idlycnt) = 0 then     -- interrupt delay expired
            n.dsata := r.dsata or r.dspip;      -- convert pip's to ata's
            n.dspip := (others=>'0');           -- and mark them done
          else
            if ITIMER = '1' then             -- not expired and ITIMER
              n.idlycnt := slv(unsigned(r.idlycnt) - 1); -- count down
            end if;
          end if;
          
        end if; -- if r.ibsel='1'

        -- s_idle goes up to here !!
        
      when s_wcs1 =>                    -- wcs1: write cs1 -------------------
        n.state := s_idle;                -- in general return to s_idle
        imem_addr := r.amap;              -- use mapped address
        imem_din  := r.dinmsk;            -- use masked input

        if ibrem = '0' then               -- loc write access

          if IB_MREQ.be1 = '1' then
            if IB_MREQ.din(cs1_ibf_tre) = '1' then  -- TRE=1 -> clear errors
              n.cs2wce := '0';
              n.cs2ned := '0';
              n.cs2nem := '0';
              n.cs2pge := '0';
              n.cs2mxf := '0';
            end if;
            if r.cs1rdy = '1' then              -- only if RDY
              n.bae(1 downto 0) := IB_MREQ.din(cs1_ibf_bae);  -- update bae
            end if;
          end if; -- IB_MREQ.be1 = '1'

          if IB_MREQ.be0 = '1' then
            n.cs1ie   := IB_MREQ.din(cs1_ibf_ie);
            if IB_MREQ.din(cs1_ibf_ie) = '1' and   -- if IE and RDY both 1
               IB_MREQ.din(cs1_ibf_rdy) = '1'then
              n.ireq := '1';                         -- issue software interrupt
            end if;
            
            if r.cs1rdy = '1' then              -- controller ready
              if r.ned = '0' and                     -- drive on
                 IB_MREQ.din(cs1_ibf_go) = '1' then  -- GO bit set
                ibhold  := '1';
                n.state := s_funcgo;
              end if;             
            else                                -- cntl not rdy
              n.cs2pge := '1';                    -- issue program error
            end if; 

            imem_we0 := IB_MREQ.be0;            -- remember func field per unit
            if r.ned = '1' then                 -- loc access and drive off
              n.cs2ned := '1';                    -- signal error
            end if;

          end if; -- IB_MREQ.be0 = '1'

        else                              -- rem write access. GO not checked
                                          --   always treated as remote function
          case IB_MREQ.din(cs1_ibf_func) is

            when rfunc_wunit =>             -- rfunc: wunit ---------------
              n.runit := IB_MREQ.din(cs1_ibf_runit);

            when rfunc_cunit =>             -- rfunc: cunit ---------------
              n.runit := r.funit;             -- use unit from last ext func go

            when rfunc_done  =>             -- rfunc: done ----------------
              n.cs1rdy := '1';
              if IB_MREQ.din(cs1_ibf_rata) = '0' then
                n.ireq   := r.cs1ie;          -- yes, ireq is set from ie !!
              else
                n.dsata(to_integer(unsigned(r.funit))) := '1';
              end if;

            when rfunc_widly =>             -- rfunc: widly ---------------
              n.idlyval := IB_MREQ.din(cs1_ibf_ridly);

            when others => null;

          end case;
        end if;
        
      when s_wcs2 =>                    -- wcs2: write cs2 -------------------
        n.state := s_idle;                -- in general return to s_idle
        if ibrem = '1' then                 -- rem access
          n.cs3wco := IB_MREQ.din(cs2_ibf_rwco);  -- cs3.wco rem set via cs2 !!
          n.cs2wce := IB_MREQ.din(cs2_ibf_wce);
          n.cs2nem := IB_MREQ.din(cs2_ibf_nem);
          n.cs2mxf := IB_MREQ.din(cs2_ibf_mxf);  -- FIXME: really used ???
        else
          if IB_MREQ.be0 = '1' then
            n.cs2pat   := IB_MREQ.din(cs2_ibf_pat);
            n.cs2bai   := IB_MREQ.din(cs2_ibf_bai);
            n.cs2unit2 := IB_MREQ.din(cs2_ibf_unit2);
            n.cs2unit  := IB_MREQ.din(cs2_ibf_unit);
            if IB_MREQ.din(cs2_ibf_clr) = '1' then
              n.eunit   := "00";
              n.clrmode := clrmode_cs2clr;
              n.state   := s_oot_clr0;             -- OOT state, no hold!
            end if;
          end if;
        end if;

      when s_wcs3 =>                    -- wcs3: write cs3 -------------------
        n.state := s_idle;                -- in general return to s_idle
        if ibrem = '0' then                 -- loc access
          if IB_MREQ.be0 = '1' then
            n.cs1ie  := IB_MREQ.din(cs3_ibf_ie);
          end if;
        end if;
        
      when s_wer1 =>                    -- wer1: write er1 (rem only) --------
        n.state := s_idle;                -- in general return to s_idle
        if ibrem = '1' then               -- rem access
          if IB_MREQ.din(er1_ibf_uns) = '1' then
            n.er1uns(to_integer(unsigned(r.eunit))) := '1';
          end if;
          if IB_MREQ.din(er1_ibf_wle) = '1' then
            n.er1wle(to_integer(unsigned(r.eunit))) := '1';
          end if;
          if IB_MREQ.din(er1_ibf_iae) = '1' then
            n.er1iae(to_integer(unsigned(r.eunit))) := '1';
          end if;
          if IB_MREQ.din(er1_ibf_aoe) = '1' then
            n.er1aoe(to_integer(unsigned(r.eunit))) := '1';
          end if;
          if IB_MREQ.din(er1_ibf_ilf) = '1' then
            n.er1ilf(to_integer(unsigned(r.eunit))) := '1';
          end if;
        else                              -- loc access
          ibhold  := '1';
          n.state := s_whr;
        end if;

      when s_was =>                     -- was: write as ---------------------
        n.state := s_idle;                -- in general return to s_idle
        -- clear the attention bits marked as '1' in data word (loc and rem !!)
        n.dsata := r.dsata and not IB_MREQ.din(r.dsata'range);
        if ibrem = '0' then               -- loc access
          ibhold  := '1';
          n.state := s_whr;          
        end if;
          
      when s_wdt =>                     -- wdt: write dt ---------------------
        n.state := s_idle;                -- in general return to s_idle
        if ibrem = '1' then               -- rem access
          n.dtrm(to_integer(unsigned(r.runit))) := IB_MREQ.din(dt_ibf_rm);
          n.dte1(to_integer(unsigned(r.runit))) := IB_MREQ.din(dt_ibf_e1);
          n.dte0(to_integer(unsigned(r.runit))) := IB_MREQ.din(dt_ibf_e0);
          n.state := s_idle;
        else                              -- loc access
          ibhold  := '1';
          n.state := s_whr;
        end if;
        
      when s_wds =>                     -- wdt: write ds ---------------------
        n.state := s_idle;                -- in general return to s_idle
        if ibrem = '1' then               -- rem access
          n.dsmol(to_integer(unsigned(r.runit))) := IB_MREQ.din(ds_ibf_mol);
          n.dswrl(to_integer(unsigned(r.runit))) := IB_MREQ.din(ds_ibf_wrl);
          n.dslbt(to_integer(unsigned(r.runit))) := IB_MREQ.din(ds_ibf_lbt);
          n.dsdpr(to_integer(unsigned(r.runit))) := IB_MREQ.din(ds_ibf_dpr);
          if IB_MREQ.din(ds_ibf_ata) = '1' then -- set ata on demand
            n.dsata(to_integer(unsigned(r.runit))) := '1';
          end if;
          if IB_MREQ.din(ds_ibf_vv) = '1' then  -- clr vv on demand
            n.dsvv(to_integer(unsigned(r.runit))) := '0';
          end if;
          if IB_MREQ.din(ds_ibf_erp) = '1'  then -- clr er1 on demand
            n.er1uns(to_integer(unsigned(r.eunit))) := '0';  -- clr all er1
            n.er1wle(to_integer(unsigned(r.eunit))) := '0';  -- "
            n.er1iae(to_integer(unsigned(r.eunit))) := '0';  -- "
            n.er1aoe(to_integer(unsigned(r.eunit))) := '0';  -- "
            n.er1rmr(to_integer(unsigned(r.eunit))) := '0';  -- "
            n.er1ilf(to_integer(unsigned(r.eunit))) := '0';  -- "
          end if;
          n.state := s_idle;
        else                              -- loc access
          ibhold  := '1';                   -- read-only reg, thus noop
          n.state := s_whr;
        end if;
        
      when s_wbae =>                    -- wbae: write bae -------------------
        n.state := s_idle;                -- in general return to s_idle
        if IB_MREQ.be0 = '1' then
          n.bae := IB_MREQ.din(bae_ibf_bae);
        end if;
        
      when s_wmem =>                    -- wmem: write mem (DA,MR1,OF,DC,MR2)-
        --  this state only handles massbus registers
        n.state := s_idle;                -- in general return to s_idle
        imem_addr := r.amap;              -- use mapped address
        imem_din  := r.dinmsk;            -- use masked input

        if ibrem = '0' then               -- loc access
          imem_we0 := '1';                  -- write memory
          imem_we1 := '1';
          ibhold  := '1';
          n.state := s_whr;
        else                              -- rem access
          imem_we0 := '1';                  -- write memory
          imem_we1 := '1';
        end if;
        
      when s_wmembe =>                  -- wmem: write mem with be (WC,BA,DB)-
        -- this state only handles controller registers --> no ned checking
        n.state := s_idle;                -- in general return to s_idle
        imem_we0 := IB_MREQ.be0;
        imem_we1 := IB_MREQ.be1;
        imem_addr := r.amap;
        imem_din  := r.dinmsk;
        
      when s_whr =>                     -- whr: write hr ---------------------
        n.state := s_idle;                -- in general return to s_idle
        imem_addr := r.cs2unit & amapc_hr;  -- mem address of holding reg
        imem_din  := not IB_MREQ.din;
        if ibrem = '0' then               -- loc access
          imem_we0 := '1';                  -- keep state
          imem_we1 := '1';          
        end if;
        
      when s_funcgo =>                  -- funcgo: handle function go --------
        n.state := s_idle;                -- in general return to s_idle
        n.dsata(to_integer(unsigned(r.cs2unit))) := '0';

        case IB_MREQ.din(cs1_ibf_func) is
          when func_noop =>                    -- func: noop --------------
            null;                                -- nothing done...
            
          when func_pore  =>                   -- func: port release-------
            n.poredone := '1';                   -- take note in done flag
            
          when func_unl   =>                   -- func: unload ------------
                                               -- only for RP, simply clears MOL
            if r.dtrm(to_integer(unsigned(r.cs2unit))) = '0' then
              n.dsmol(to_integer(unsigned(r.cs2unit))) := '0';
              n.dswrl(to_integer(unsigned(r.cs2unit))) := '0';
              n.dsvv(to_integer(unsigned(r.cs2unit)))  := '0';
              n.dsom(to_integer(unsigned(r.cs2unit)))  := '0';
            else
              n.er1ilf(to_integer(unsigned(r.cs2unit))) := '1';
            end if;
            n.dsata(to_integer(unsigned(r.cs2unit))) := '1';
             
          when func_dclr  =>                   -- func: drive clear -------
            n.eunit   := r.cs2unit;              -- for follow-up states
            n.clrmode := clrmode_fdclr;
            n.state   := s_oot_clr0;             -- OOT state, no hold!
            
          when func_offs  |                    -- func: offset ------------
               func_retc  =>                   -- func: return to center --

            -- currently always immediate completion, so ata set here
            n.dsata(to_integer(unsigned(r.cs2unit)))  := '1';

            if r.dsmol(to_integer(unsigned(r.cs2unit))) = '0' then
              n.er1uns(to_integer(unsigned(r.cs2unit))) := '1';
            else
              if IB_MREQ.din(cs1_ibf_func) = func_offs then
                n.dsom(to_integer(unsigned(r.cs2unit))) := '1';
              else
                n.dsom(to_integer(unsigned(r.cs2unit))) := '0';
              end if;
            end if;
            
          when func_pres  =>                   -- func: readin preset -----
            n.dsvv(to_integer(unsigned(r.cs2unit))) := '1';
            n.eunit   := r.cs2unit;              -- for follow-up states
            n.clrmode := clrmode_fpres;
            n.state   := s_oot_clr0;             -- OOT state, no hold!
            
          when func_pack  =>                   -- func: pack acknowledge --
            n.dsvv(to_integer(unsigned(r.cs2unit))) := '1';
            n.packdone := '1';                   -- take note in done flag
            
          -- seek like and data transfer functions
          when func_seek  |                    -- func: seek --------------
               func_recal |                    -- func: recalibrate -------
               func_sear  |                    -- func: search ------------
               func_wcd   |                    -- func: write check data --
               func_wchd  |                    -- func: write check h&d ---
               func_write |                    -- func: write  ------------
               func_whd   |                    -- func: write header&data -
               func_read  |                    -- func: read --------------
               func_rhd   =>                   -- func: read header&data --

            if  IB_MREQ.din(cs1_ibf_func) = func_seek then
              n.seekdone := '1';                 -- take note in done flag
            end if;
            if  IB_MREQ.din(cs1_ibf_func) = func_sear then
              n.seardone := '1';                 -- take note in done flag
            end if;

            -- check for transfer functions
            n.fxfer := '0';
            if unsigned(IB_MREQ.din(cs1_ibf_func)) >= unsigned(func_wcd)  then
              n.fxfer := '1';
              -- in case of write, check for write lock
              if IB_MREQ.din(cs1_ibf_func) = func_write or
                 IB_MREQ.din(cs1_ibf_func) = func_whd   then
                if r.dswrl(to_integer(unsigned(r.cs2unit))) = '1' then
                  n.er1wle(to_integer(unsigned(r.cs2unit))) := '1';
                end if;
              end if;
            end if;
            
            if r.dsmol(to_integer(unsigned(r.cs2unit))) = '0' then
              n.er1uns(to_integer(unsigned(r.cs2unit))) := '1';
              n.dsata(to_integer(unsigned(r.cs2unit)))  := '1';
            else
              ibhold  := '1';
              n.state := s_chkdc;
            end if;            
            
          -- illegal function codes
          when others =>
            n.er1ilf(to_integer(unsigned(r.cs2unit))) := '1';
            n.dsata(to_integer(unsigned(r.cs2unit))) := '1';
            
        end case; -- IB_MREQ.din(cs1_ibf_func)

      when s_chkdc =>                   -- chkdc: handle dc check ------------
        imem_addr := r.cs2unit & amapc_dc; -- mem address of dc reg
        if unsigned(MEM_DOUT(dc_ibf_ca)) > unsigned(r.camax) then
          n.er1iae(to_integer(unsigned(r.cs2unit))) := '1';
        end if;
        ibhold  := '1';
        n.state := s_chkda;

      when s_chkda =>                   -- chkda: handle da check ------------
        imem_addr := r.cs2unit & amapc_da; -- mem address of da reg
        if unsigned(MEM_DOUT(da_ibf_sa)) > unsigned(r.samax) or
           unsigned(MEM_DOUT(da_ibf_ta)) > unsigned(r.tamax) then
          n.er1iae(to_integer(unsigned(r.cs2unit))) := '1';
        end if;
        ibhold  := '1';
        n.state := s_chkdo;
        
      when s_chkdo =>                   -- chkdo: execute function -----------
        if r.er1iae(to_integer(unsigned(r.cs2unit))) = '1' or
           r.er1wle(to_integer(unsigned(r.cs2unit))) = '1' then
          n.dsata(to_integer(unsigned(r.cs2unit))) := '1'; -- ata and done
        else
          if r.fxfer = '0'  then            -- must be seek like function
            n.dspip(to_integer(unsigned(r.cs2unit))) := '1'; -- pip
            n.idlycnt := r.idlyval;                          -- start delay
          else                              -- must be transfer function
            n.ffunc  := IB_MREQ.din(cs1_ibf_func);  -- latch func
            n.funit  := r.cs2unit;                  -- latch unit
            n.cs1rdy := '0';                  -- controller busy
            n.cs2wce := '0';                  -- clear errors
            n.cs2ned := '0';
            n.cs2nem := '0';
            n.cs2pge := '0';
            n.cs2mxf := '0';
            ilam := '1';                      -- issue lam
          end if;
        end if;
        n.state := s_idle;
        
      when s_read =>                    -- read: all register reads ----------
        n.state := s_idle;                -- in general return to s_idle
        imem_addr := r.amap;

        case r.omux is

          when omux_cs1 =>                -- omux: cs1 reg ---------------
            idout(cs1_ibf_sc)   := r.cs1sc;
            idout(cs1_ibf_tre)  := r.cs1tre;
            idout(cs1_ibf_dva)  := '1';
            idout(cs1_ibf_bae)  := r.bae(1 downto 0);
            idout(cs1_ibf_rdy)  := r.cs1rdy;
            idout(cs1_ibf_ie)   := r.cs1ie;
            if ibrem = '0' then             -- loc access
              idout(cs1_ibf_func) := MEM_DOUT(cs1_ibf_func); --func per unit
              if r.ned = '1' then             -- drive off
                n.cs2ned := '1';                -- signal error
              end if;
            else                            -- rem access
              idout(cs1_ibf_func) := r.ffunc;
            end if;

          when omux_cs2 =>                -- omux: cs2 reg ---------------
            idout(cs2_ibf_wce)   := r.cs2wce;
            idout(cs2_ibf_ned)   := r.cs2ned;
            idout(cs2_ibf_nem)   := r.cs2nem;
            idout(cs2_ibf_pge)   := r.cs2pge;
            idout(cs2_ibf_mxf)   := r.cs2mxf;
            idout(cs2_ibf_or)    := '1';
            idout(cs2_ibf_ir)    := '1';
            idout(cs2_ibf_pat)   := r.cs2pat;
            idout(cs2_ibf_bai)   := r.cs2bai;
            idout(cs2_ibf_unit2) := r.cs2unit2;
            if ibrem = '0' then           -- loc access
              idout(cs2_ibf_unit)  := r.cs2unit;
            else                          -- rem access
              idout(cs2_ibf_unit)  := r.funit;
            end if;

          when omux_ds =>                 -- omux: ds  reg ---------------
            idout(ds_ibf_ata)  := r.dsata(to_integer(unsigned(r.eunit)));
            idout(ds_ibf_erp)  := r.dserp(to_integer(unsigned(r.eunit)));
            idout(ds_ibf_pip)  := r.dspip(to_integer(unsigned(r.eunit)));
            idout(ds_ibf_mol)  := r.dsmol(to_integer(unsigned(r.eunit)));
            idout(ds_ibf_wrl)  := r.dswrl(to_integer(unsigned(r.eunit)));
            idout(ds_ibf_lbt)  := r.dslbt(to_integer(unsigned(r.eunit)));
            idout(ds_ibf_dpr)  := r.dsdpr(to_integer(unsigned(r.eunit)));

            -- ds.dry is 0 if mol=0 or if transfer or seek is active on unit
            -- the logic below checks for the complement ...
            if r.dsmol(to_integer(unsigned(r.eunit))) = '1' then
              if (r.cs1rdy = '1' or r.funit /= r.eunit) and
                 r.dspip(to_integer(unsigned(r.eunit))) = '0' then
                idout(ds_ibf_dry)  := '1';
              end if;
            end if;

            idout(ds_ibf_vv)   := r.dsvv (to_integer(unsigned(r.eunit)));
            idout(ds_ibf_om)   := r.dsom (to_integer(unsigned(r.eunit)));

          when omux_er1 =>                -- omux: er1 reg ---------------
            idout(er1_ibf_uns)  := r.er1uns(to_integer(unsigned(r.eunit)));
            idout(er1_ibf_wle)  := r.er1wle(to_integer(unsigned(r.eunit)));
            idout(er1_ibf_iae)  := r.er1iae(to_integer(unsigned(r.eunit)));
            idout(er1_ibf_aoe)  := r.er1aoe(to_integer(unsigned(r.eunit)));
            idout(er1_ibf_rmr)  := r.er1rmr(to_integer(unsigned(r.eunit)));
            idout(er1_ibf_ilf)  := r.er1ilf(to_integer(unsigned(r.eunit)));

          when omux_as =>                 -- omux: as  reg ---------------
            idout(r.dsata'range) := r.dsata;

          when omux_la =>                 -- omux: la  reg ---------------
            idout(la_ibf_sc)    := r.sc;

          when omux_dt =>                 -- omux: dt  reg ---------------
            if ibrem = '0' then             -- loc access
              idout(13) := '1';               -- set bit 020000 (movable head)
              idout(r.dtyp'range) := r.dtyp;
            else                            -- rem access (read back rem side)
              idout(dt_ibf_rm) := r.dtrm(to_integer(unsigned(r.runit)));
              idout(dt_ibf_e1) := r.dte1(to_integer(unsigned(r.runit)));
              idout(dt_ibf_e0) := r.dte0(to_integer(unsigned(r.runit)));
            end if;

          when omux_sn =>                 -- omux: sn  reg ---------------
            -- the serial number is encoded as 4 digit BCD
            --   digit 3: always 1
            --   digit 2: 1 if RM type; 0 if RP type
            --   digit 1: 0-3 based on encoded drive type
            --   digit 0: 0-3 taken from unit
            idout(12) := '1';
            idout(8)  := r.dtrm(to_integer(unsigned(r.eunit)));
            idout(5)  := r.dte1(to_integer(unsigned(r.eunit)));
            idout(4)  := r.dte0(to_integer(unsigned(r.eunit)));
            idout(1)  := r.eunit(1);
            idout(0)  := r.eunit(0);
            
          when omux_bae =>                -- omux: bae reg ---------------
            idout(bae_ibf_bae) := r.bae;

          when omux_cs3 =>                -- omux: cs3 reg ---------------
            idout(cs3_ibf_wco) := r.cs2wce and     r.cs3wco;
            idout(cs3_ibf_wce) := r.cs2wce and not r.cs3wco;
            idout(cs3_ibf_ie)  := r.cs1ie;
            if ibrem = '1' then             -- rem access
              idout(cs3_ibf_rseardone) := r.seardone;
              idout(cs3_ibf_rpackdone) := r.packdone;
              idout(cs3_ibf_rporedone) := r.poredone;
              idout(cs3_ibf_rseekdone) := r.seekdone;
              if IB_MREQ.re = '1' then        -- if read, do read & clear
                n.seardone := '0';
                n.packdone := '0';
                n.poredone := '0';
                n.seekdone := '0';
              end if;
            end if;

          when omux_mem =>                -- omux: mem output ------------
            idout := MEM_DOUT;

          when omux_zero =>               -- omux: zero ------------------
            idout := (others=>'0');
            
          when others => null;            -- nxr caught before in mapper !
        end case;  -- case r.omux

      when s_setrmr =>                    -- set rmr flag ----------------------
        n.er1rmr(to_integer(unsigned(r.cs2unit))) := '1';
        n.state := s_idle;
        
      when s_oot_clr0 =>                  -- OOT clr0: state 0 -----------------
        if r.clrmode=clrmode_breset or r.clrmode=clrmode_cs2clr then
          n.cs1rdy   := '1';                 -- clear cs1
          n.cs1ie    := '0';
          n.cs2wce   := '0';                 -- clear cs2
          n.cs2ned   := '0';
          n.cs2nem   := '0';
          n.cs2pge   := '0';
          n.cs2mxf   := '0';
          n.cs2pat   := '0';
          n.cs2bai   := '0';
          n.cs2unit2 := '0';
          n.cs2unit  := (others=>'0');
          n.bae      := (others=>'0');       -- clear bae
          n.ireq     := '0';                 -- clear iff
        end if;
        
        if r.clrmode=clrmode_breset or r.clrmode=clrmode_fdclr then
          n.er1uns(to_integer(unsigned(r.eunit))) := '0';  -- clr all er1
          n.er1wle(to_integer(unsigned(r.eunit))) := '0';  -- "
          n.er1iae(to_integer(unsigned(r.eunit))) := '0';  -- "
          n.er1aoe(to_integer(unsigned(r.eunit))) := '0';  -- "
          n.er1rmr(to_integer(unsigned(r.eunit))) := '0';  -- "
          n.er1ilf(to_integer(unsigned(r.eunit))) := '0';  -- "
        end if;

        n.cerm  := r.dtrm(to_integer(unsigned(ieunit)));
   
        n.clrreg := "000";
        ibhold  := r.ibsel;                -- delay pending request
        n.state := s_oot_clr1;                

      when s_oot_clr1 =>                  -- OOT clr1: state 1 ----------------
        imem_addr := r.eunit & r.clrreg;
        imem_din  := (others=>'0');

        iclrreg := '0';
        case r.clrmode is

          when clrmode_breset =>        -- BRESET -------------------------
            iclrreg := '1';               -- simply clear all (cntl+drives)

          when clrmode_cs2clr =>        -- CS2.CLR (controller clr) -------
            case r.clrreg is
              when amapc_ext => iclrreg := '1';
              when amapc_mr1 => iclrreg := r.cerm;
              when others => null;
            end case;

          when clrmode_fdclr =>         -- func=DCLR (drive clr) ----------
            case r.clrreg is
              when amapc_mr1 => iclrreg := r.cerm;
              when others => null;
            end case;

          when clrmode_fpres =>         -- func=PRESET --------------------
            case r.clrreg is
              when amapc_da  => iclrreg := '1';
              when amapc_of  => iclrreg := '1';
              when amapc_dc  => iclrreg := '1';
              when others => null;
            end case;

          when others => null;
        end case;
        if iclrreg = '1' then
          imem_we0 := IB_MREQ.be0;
          imem_we1 := IB_MREQ.be1;
        end if;
        n.clrreg := slv(unsigned(r.clrreg) + 1);

        ibhold := r.ibsel;                   -- delay pending request
        if r.clrreg = "111" then             -- if last register done
          n.state := s_oot_clr2;               -- proceed with clr2
        end if;
        
      when s_oot_clr2 =>                  -- OOT clr2: state 2 ----------------
        n.eunit := slv(unsigned(r.eunit) + 1);

        ibhold := r.ibsel;                   -- delay pending request, so that
                                             -- s_idle can finally process it
        if (r.clrmode=clrmode_breset or r.clrmode=clrmode_cs2clr) and
           r.eunit /= "11" then
          n.state := s_oot_clr0;
        else
          n.state := s_idle;
        end if;
        
      when others => null;                -- <> ------------------------------
    end case;  -- case r.state

    -- update cs1tre and cs1sc
    n.cs1tre := r.cs2wce or r.cs2ned or r.cs2nem or r.cs2pge or r.cs2mxf;
    n.cs1sc  := n.cs1tre or r.dsata(0) or r.dsata(1) or r.dsata(2) or r.dsata(3);
    -- update dserp
    n.dserp  := r.er1uns or -- or all er1
                r.er1wle or -- "
                r.er1iae or -- "
                r.er1aoe or -- "
                r.er1rmr or -- "
                r.er1ilf;   -- "
    
    -- handle current sector counter (for RxLA emulation)
    -- advance every 128 usec, so generate a pulse every 128 usec
    if CE_USEC = '1' then
      n.uscnt := slv(unsigned(r.uscnt) + 1);
      if unsigned(r.uscnt) = 0 then
        iscinc := '1';
      end if;
    end if;

    -- if current sector larger or equal highest sector wrap to zero
    -- note: iscinc is also '1' when unit changes, this ensures that
    --       the sector counter is always in range when read to ibus.
    if iscinc = '1' then
      if unsigned(r.sc) >= unsigned(r.samax) then
        n.sc := (others=>'0');
      else
        n.sc := slv(unsigned(r.sc) + 1);
      end if;
    end if;

    -- the RH70 interrupt logic is very unusual
    --  1. done interrupts (rdy 0->1) are edge sensitive (via r.ireq)
    --  2. done interrupts are not canceled when IE is cleared
    --  3. attention interrupts are level sensitive      (via r.cs1sc)
    --  4. IE is disabled on interrupt acknowledge

    iei_req := r.ireq or (r.cs1sc and r.cs1ie and r.cs1rdy);

    if EI_ACK = '1'  then               -- interrupt executed
      n.ireq  := '0';                      -- cancel request
      n.cs1ie := '0';                      -- disable interrupts
    end if;
    
    N_REGS <= n;

    MEM_0_WE <= imem_we0;
    MEM_1_WE <= imem_we1;
    MEM_ADDR <= imem_addr;
    MEM_DIN  <= imem_din;
    
    IB_SRES.dout <= idout;
    IB_SRES.ack  <= r.ibsel and ibreq;
    IB_SRES.busy <= ibhold  and ibreq;

    RB_LAM <= ilam;
    EI_REQ <= iei_req;
    
  end process proc_next;

    
end syn;
