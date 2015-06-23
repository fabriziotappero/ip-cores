-- $Id: tb_rlink.vhd 596 2014-10-17 19:50:07Z mueller $
--
-- Copyright 2007-2014 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Module Name:    tb_rlink - sim
-- Description:    Test bench for rlink_core
--
-- Dependencies:   simlib/simclk
--                 simlib/simclkcnt
--                 genlib/clkdivce
--                 rbus/tbd_tester
--                 tbd_rlink_gen [UUT]
--
-- To test:        rlink_core     (via tbd_rlink_direct)
--                 rlink_base     (via tbd_rlink_serport)
--                 rlink_serport  (via tbd_rlink_serport)
--
-- Target Devices: generic
-- Tool versions:  xst 8.2-14.7; ghdl 0.18-0.31
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2014-10-12   596   4.1    use readgen_ea; add get_cmd_ea; labo instead of stat
--                           add txblk,rxblk,rxrbeg,rxrend,rxcbs,anmsg commands
-- 2014-08-28   588   4.0    now rlink v4 iface -> txcac has 16 bit; 4 bit STAT
-- 2014-08-15   583   3.5    rb_mreq addr now 16 bit; adopt txca,txcad,txcac
-- 2011-12-23   444   3.1    use new simclk/simclkcnt
-- 2011-11-19   427   3.0.7  fix crc8_update_tbl usage; now numeric_std clean
-- 2010-12-29   351   3.0.6  use new rbd_tester addr 111100xx (from 111101xx)
-- 2010-12-26   348   3.0.5  use simbus to export clkcycle (for tbd_..serport)
-- 2010-12-23   347   3.0.4  use rb_mon, rlink_mon directly; rename CP_*->RL_*
-- 2010-12-22   346   3.0.3  add .rlmon and .rbmon commands
-- 2010-12-21   345   3.0.2  rename commands .[rt]x... to [rt]x...;
--                           add .[rt]x(idle|attn) cmds; remove 'bbbbbbbb' cmd
-- 2010-12-12   344   3.0.1  add .attn again; add .txbad, .txoof; ren oob->oof
-- 2010-12-05   343   3.0    rri->rlink renames; port to rbus V3 protocol;
--                           use rbd_tester instead of sim target;
-- 2010-06-06   302   2.5    use sop/eop framing instead of soc+chaining
-- 2010-06-03   299   2.2.2  new init encoding (WE=0/1 int/ext);use sv_ prefix
--                           for shared variables 
-- 2010-05-02   287   2.2.1  ren CE_XSEC->CE_INT,RP_STAT->RB_STAT,AP_LAM->RB_LAM
--                           drop RP_IINT signal from interfaces
-- 2010-04-03   274   2.2    add CE_USEC in tbd_rri_gen interface
-- 2009-03-14   197   2.1    remove records in interface to allow _ssim usage
-- 2008-08-24   162   2.0    with new rb_mreq/rb_sres interface
-- 2008-03-24   129   1.1.2  CLK_CYCLE now 31 bits
-- 2008-01-20   112   1.1.1  rename clkgen->clkdivce
-- 2007-11-24    98   1.1    add RP_IINT support, add checkmiss_tx to test
--                           for missing responses
-- 2007-10-26    92   1.0.2  add DONE timestamp at end of execution
-- 2007-10-12    88   1.0.1  avoid ieee.std_logic_unsigned, use cast to unsigned
-- 2007-09-09    81   1.0    Initial version 
------------------------------------------------------------------------------
-- command set:
--   .reset                               assert RESET for 1 clk
--   .rlmon ien                           enable rlink monitor (9 bit)
--   .rlbmo ien                           enable rlink monitor (8 bit)
--   .rbmon ien                           enable rbus monitor
--   .wait  n                             wait n clks
--   .iowt  n                             wait n clks for rlink i/o; auto-extend
--   .attn  dat(16)                       pulse attn lines with dat
--
-- - high level ---
--   anmsg apat                           attn notify message
--   sop                                  start packet
--   eop                                  end packet
--   rreg  seq  addr  data  stat          rreg cmd
--   wreg  seq  addr  data  stat          wreg cmd
--   init  seq  addr  data  stat          init cmd
--   attn  seq        data  stat          attn cmd
--   labo  seq        data  stat          labo cmd
--   rblks seq  addr  nblk  data  stat    rblk cmd (with seq)
--   wblks seq  addr  nblk  data  stat    wblk cmd (with seq)
--   rblkd seq  addr  ndone  stat         rblk cmd (with data list)
--   wblkd seq  addr  ndone  stat         wblk cmd (with data list)
--   .dclr                                clear data list
--   .dwrd  data                          add word to data list
--   .dseq  nblk  data                    add sequence to data list
--
-- - low level ---
--   txcrc                                send crc
--   txbad                                send bad (inverted) crc
--   txc    cmd(8)                        send cmd - crc
--   txca   cmd(8) addr(16)               send cmd - al ah - crcl crch
--   txcad  cmd(8) addr(16) dat(16)       send cmd - al ah - dl dh - crcl crch
--   txcac  cmd(8) addr(16) cnt(16)       send cmd - al ah - cl ch - crcl crch
--   txoof  dat(9)                        send out-of-frame symbol
--   rxcrc                                expect crc
--   rxcs   cmd(8) stat(8)                expect cmd - stat - crcl crch
--   rxcds  cmd(8) dat(16) stat(8)        expect cmd - dl dh - stat - crcl crch
--   rxcbs  cmd(8)  dat(8) stat(8)        expect cmd - dl - stat - crcl crch
--   rxrbeg cmd(8) cnt(16)                expect cmd - cl ch 
--   rxrend dcnt(16)                      expect dcl dch - stat - crcl crch
--   rxoof  dat(9)                        expect out-of-frame symbol
--
-- - raw level ---
--   txsop                                send <sop>
--   txeop                                send <eop>
--   txnak                                send <nak>
--   txattn                               send <attn>
--   tx8    dat(8)                        send  8 bit value
--   tx16   dat(16)                       send 16 bit value
--   txblk  n start                       send n 16 values
--   rxsop                                reset rx list; expect sop
--   rxeop                                expect <eop>
--   rxnak                                expect <nak>
--   rxattn                               expect <attn>
--   rx8    dat(8)                        expect  8 bit value
--   rx16   dat(16)                       expect 16 bit value
--   rxblk  n start                       expect n 16 values
--
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;

use work.slvtypes.all;
use work.genlib.all;
use work.comlib.all;
use work.rblib.all;
use work.rbdlib.all;
use work.rlinklib.all;
use work.simlib.all;
use work.simbus.all;

entity tb_rlink is
end tb_rlink;

architecture sim of tb_rlink is
  
  constant d_f_cflag   : integer := 8;                -- d9: comma flag
  subtype  d_f_data   is integer range  7 downto  0;  -- d9: data field

  subtype  f_byte1    is integer range 15 downto 8;
  subtype  f_byte0    is integer range  7 downto 0;

  signal CLK : slbit := '0';
  signal CE_USEC : slbit := '0';
  signal CE_MSEC : slbit := '0';
  signal RESET : slbit := '0';
  signal RL_DI : slv9 := (others=>'0');
  signal RL_ENA : slbit := '0';
  signal RL_BUSY : slbit := '0';
  signal RL_DO : slv9 := (others=>'0');
  signal RL_VAL : slbit := '0';
  signal RL_HOLD : slbit := '0';
  signal RB_MREQ_aval : slbit := '0';
  signal RB_MREQ_re : slbit := '0';
  signal RB_MREQ_we : slbit := '0';
  signal RB_MREQ_initt: slbit := '0';
  signal RB_MREQ_addr : slv16 := (others=>'0');
  signal RB_MREQ_din : slv16 := (others=>'0');
  signal RB_SRES_ack : slbit := '0';
  signal RB_SRES_busy : slbit := '0';
  signal RB_SRES_err : slbit := '0';
  signal RB_SRES_dout : slv16 := (others=>'0');
  signal RB_LAM_TBENCH : slv16 := (others=>'0');
  signal RB_LAM_TESTER : slv16 := (others=>'0');
  signal RB_LAM : slv16 := (others=>'0');
  signal RB_STAT : slv4 := (others=>'0');
  signal TXRXACT : slbit := '0';

  signal RB_MREQ : rb_mreq_type := rb_mreq_init;
  signal RB_SRES : rb_sres_type := rb_sres_init;
  
  signal CLK_STOP : slbit := '0';
  signal CLK_CYCLE : integer := 0;

  constant rxlist_size  : positive := 4096;  -- size of rxlist
  constant txlist_size  : positive := 4096;  -- size of txlist
  constant datlist_size : positive := 2048;  -- size of datlist

  constant slv9_zero  : slv9  := (others=>'0');
  constant slv16_zero : slv16 := (others=>'0');

  type rxlist_array_type  is array (0 to rxlist_size-1)  of slv9;
  type txlist_array_type  is array (0 to txlist_size-1)  of slv9;
  type datlist_array_type is array (0 to datlist_size-1) of slv16;

  shared variable sv_rxlist : rxlist_array_type := (others=>slv9_zero);
  shared variable sv_nrxlist : natural := 0;
  shared variable sv_rxind : natural := 0;

  constant clock_period : time :=  20 ns;
  constant clock_offset : time := 200 ns;
  constant setup_time : time :=  5 ns;
  constant c2out_time : time := 10 ns;

component tbd_rlink_gen is              -- rlink, generic tb design interface
  port (
    CLK  : in slbit;                    -- clock
    CE_INT : in slbit;                  -- rlink ito time unit clock enable
    CE_USEC : in slbit;                 -- 1 usec clock enable
    RESET  : in slbit;                  -- reset
    RL_DI : in slv9;                    -- rlink: data in
    RL_ENA : in slbit;                  -- rlink: data enable
    RL_BUSY : out slbit;                -- rlink: data busy
    RL_DO : out slv9;                   -- rlink: data out
    RL_VAL : out slbit;                 -- rlink: data valid
    RL_HOLD : in slbit;                 -- rlink: data hold
    RB_MREQ_aval : out slbit;           -- rbus: request - aval
    RB_MREQ_re : out slbit;             -- rbus: request - re
    RB_MREQ_we : out slbit;             -- rbus: request - we
    RB_MREQ_initt: out slbit;           -- rbus: request - init; avoid name coll
    RB_MREQ_addr : out slv16;           -- rbus: request - addr
    RB_MREQ_din : out slv16;            -- rbus: request - din
    RB_SRES_ack : in slbit;             -- rbus: response - ack
    RB_SRES_busy : in slbit;            -- rbus: response - busy
    RB_SRES_err : in slbit;             -- rbus: response - err
    RB_SRES_dout : in slv16;            -- rbus: response - dout
    RB_LAM : in slv16;                  -- rbus: look at me
    RB_STAT : in slv4;                  -- rbus: status flags
    TXRXACT : out slbit                 -- txrx active flag
  );
end component;

begin

  CLKGEN : simclk
    generic map (
      PERIOD => clock_period,
      OFFSET => clock_offset)
    port map (
      CLK       => CLK,
      CLK_STOP  => CLK_STOP
    );

  CLKCNT : simclkcnt port map (CLK => CLK, CLK_CYCLE => CLK_CYCLE);

  CLKDIV : clkdivce
    generic map (
      CDUWIDTH => 6,
      USECDIV  => 4,
      MSECDIV  => 5)
    port map (
      CLK     => CLK,
      CE_USEC => CE_USEC,
      CE_MSEC => CE_MSEC
    );

  RB_MREQ.aval <= RB_MREQ_aval;
  RB_MREQ.re   <= RB_MREQ_re;
  RB_MREQ.we   <= RB_MREQ_we;
  RB_MREQ.init <= RB_MREQ_initt;
  RB_MREQ.addr <= RB_MREQ_addr;
  RB_MREQ.din  <= RB_MREQ_din;

  RB_SRES_ack   <= RB_SRES.ack;
  RB_SRES_busy  <= RB_SRES.busy;
  RB_SRES_err   <= RB_SRES.err;
  RB_SRES_dout  <= RB_SRES.dout;

  RBTEST : rbd_tester
    generic map (
      RB_ADDR => slv(to_unsigned(16#ffe0#,16)))
    port map (
      CLK      => CLK,
      RESET    => '0',
      RB_MREQ  => RB_MREQ,
      RB_SRES  => RB_SRES,
      RB_LAM   => RB_LAM_TESTER,
      RB_STAT  => RB_STAT
    );

  RB_LAM <= RB_LAM_TESTER or RB_LAM_TBENCH;
    
  UUT : tbd_rlink_gen
    port map (
      CLK          => CLK,
      CE_INT       => CE_MSEC,
      CE_USEC      => CE_USEC,
      RESET        => RESET,
      RL_DI        => RL_DI,
      RL_ENA       => RL_ENA,
      RL_BUSY      => RL_BUSY,
      RL_DO        => RL_DO,
      RL_VAL       => RL_VAL,
      RL_HOLD      => RL_HOLD,
      RB_MREQ_aval => RB_MREQ_aval,
      RB_MREQ_re   => RB_MREQ_re,
      RB_MREQ_we   => RB_MREQ_we,
      RB_MREQ_initt=> RB_MREQ_initt,
      RB_MREQ_addr => RB_MREQ_addr,
      RB_MREQ_din  => RB_MREQ_din,
      RB_SRES_ack  => RB_SRES_ack,
      RB_SRES_busy => RB_SRES_busy,
      RB_SRES_err  => RB_SRES_err,
      RB_SRES_dout => RB_SRES_dout,
      RB_LAM       => RB_LAM,
      RB_STAT      => RB_STAT,
      TXRXACT      => TXRXACT
    );

  proc_stim: process
    file fstim : text open read_mode is "tb_rlink_stim";
    variable iline : line;
    variable oline : line;
    variable ien   : slbit := '0';
    variable icmd  : slv8  := (others=>'0');
    variable iaddr : slv16 := (others=>'0');
    variable icnt  : slv16 := (others=>'0');
    variable ibabo : slv8  := (others=>'0');
    variable istat : slv8  := (others=>'0');
    variable iattn : slv16 := (others=>'0');
    variable idata : slv16 := (others=>'0');
    variable idat8 : slv8  := (others=>'0');
    variable ioof  : slv9 := (others=>'0');
    variable iblkval : slv16 := (others=>'0');
    variable iblkmsk : slv16 := (others=>'0');
    variable nblk  : natural := 1;
    variable ndone : natural := 1;
    variable rxlabo : boolean := false;
    variable ok : boolean;
    variable dname : string(1 to 6) := (others=>' ');
    variable idelta : integer := 0;
    variable iowait : integer := 0;
    variable txcrc,rxcrc : slv16 := (others=>'0');
    variable txlist : txlist_array_type := (others=>slv9_zero);
    variable ntxlist : natural := 0;
    variable datlist : datlist_array_type := (others=>slv16_zero);
    variable ndatlist : natural := 0;
    
    -- read command line  helpers ------------------------------------
    procedure get_cmd_ea (              -- ---- get_cmd_ea -----------
      L : inout line;
      icmd : out slv8)  is
      variable cname : string(1 to 4) := (others=>' ');
      variable ival : natural;
      variable ok : boolean;
      variable cmd : slv3;
      variable dat : slv8;
    begin
      readword_ea(L, cname);
      ival := 0;
      readoptchar(L, ',', ok);
      if ok then
        readint_ea(L, ival, 0, 31);
      end if;
      case cname is
        when  "rreg" => cmd := c_rlink_cmd_rreg;
        when  "rblk" => cmd := c_rlink_cmd_rblk;
        when  "wreg" => cmd := c_rlink_cmd_wreg;
        when  "wblk" => cmd := c_rlink_cmd_wblk;
        when  "labo" => cmd := c_rlink_cmd_labo;
        when  "attn" => cmd := c_rlink_cmd_attn;
        when  "init" => cmd := c_rlink_cmd_init;
        when others =>
          report "unknown cmd code" severity failure;
      end case;
      dat := (others=>'0');
      dat(c_rlink_cmd_rbf_seq)  := slv(to_unsigned(ival,5));
      dat(c_rlink_cmd_rbf_code) := cmd;
      icmd := dat;
    end procedure get_cmd_ea;
    
    procedure get_seq_ea (              -- ---- get_seq_ea -----------
      L : inout line;
      code : in slv3;
      icmd : out slv8)  is
      variable ival : natural;
      variable dat : slv8;
    begin
      readint_ea(L, ival, 0, 31);
      dat := (others=>'0');
      dat(c_rlink_cmd_rbf_seq)  := slv(to_unsigned(ival,5));
      dat(c_rlink_cmd_rbf_code) := code;
      icmd := dat;
    end procedure get_seq_ea;
    
    -- tx helpers ----------------------------------------------------
    procedure do_tx9 (data : in slv9)  is -- ---- do_tx9 -------------
    begin
      txlist(ntxlist) := data;
      ntxlist := ntxlist + 1;
    end procedure do_tx9;
    
    procedure do_tx8 (data : in slv8)  is -- ---- do_tx8 -------------
    begin
      do_tx9('0' & data);
      txcrc := crc16_update_tbl(txcrc, data);
    end procedure do_tx8;
    
    procedure do_tx16 (data : in slv16)  is -- ---- do_tx16 ----------
    begin
      do_tx8(data( f_byte0));
      do_tx8(data(f_byte1));
    end procedure do_tx16;

    procedure do_txcrc is               -- ---- do_txcrc -------------
    begin
      do_tx9('0' & txcrc(f_byte0));
      do_tx9('0' & txcrc(f_byte1));
    end procedure do_txcrc;
            
    procedure do_txsop is               -- ---- do_txsop -------------
    begin
      do_tx9(c_rlink_dat_sop);
      txcrc := (others=>'0');
    end procedure do_txsop;

    procedure do_txeop is               -- ---- do_txeop -------------
    begin
      do_tx9(c_rlink_dat_eop);
    end procedure do_txeop;
            
    procedure do_txc (icmd  : in slv8) is -- ---- do_txc -------------
    begin
      do_tx8(icmd);
      do_txcrc;
    end procedure do_txc;

    procedure do_txca (                 -- ---- do_txca --------------
      icmd  : in slv8; 
      iaddr : in slv16) is 
    begin
      do_tx8(icmd);
      do_tx16(iaddr);
      do_txcrc;
    end procedure do_txca;

    procedure do_txcad (                -- ---- do_txcad -------------
      icmd  : in slv8; 
      iaddr : in slv16;
      idata : in slv16) is 
    begin
      do_tx8(icmd);
      do_tx16(iaddr);
      do_tx16(idata);
      do_txcrc;
    end procedure do_txcad;

    procedure do_txblks (               -- ---- do_txblks ------------
      nblk  : in natural; 
      start : in slv16) is
      variable idata : slv16;
    begin
      idata := start;
      for i in 1 to nblk loop
        do_tx16(idata);
        idata := slv(unsigned(idata) + 1);
      end loop;
    end procedure do_txblks;

    -- rx helpers ----------------------------------------------------
    procedure checkmiss_rx is           -- ---- checkmiss_rx ---------
    begin
      if sv_rxind < sv_nrxlist then
        for i in sv_rxind to sv_nrxlist-1 loop
          writetimestamp(oline, CLK_CYCLE, ": moni ");
          write(oline, string'("             FAIL MISSING DATA="));
          write(oline, sv_rxlist(i)(d_f_cflag));
          write(oline, string'(" "));
          write(oline, sv_rxlist(i)(f_byte0));
          writeline(output, oline);
        end loop;

      end if;
    end procedure checkmiss_rx;
            
    procedure do_rx9 (data : in slv9)  is -- ---- do_rx9 -------------
    begin
      sv_rxlist(sv_nrxlist) := data;
      sv_nrxlist := sv_nrxlist + 1;
    end procedure do_rx9;

    procedure do_rx8 (data : in slv8)  is -- ---- do_rx8 -------------
    begin
      if not rxlabo then
        do_rx9('0' & data);
        rxcrc := crc16_update_tbl(rxcrc, data);        
      end if;
    end procedure do_rx8;

    procedure do_rx16 (data : in slv16)  is -- ---- do_rx16 ----------
    begin
      do_rx8(data(f_byte0));
      do_rx8(data(f_byte1));
    end procedure do_rx16;
            
    procedure do_rxattn is              -- ---- do_rxattn ------------
    begin
      do_rx9(c_rlink_dat_attn);
      rxcrc := (others=>'0');
    end procedure do_rxattn;

    procedure do_rxcrc is               -- ---- do_rxcrc -------------
    begin
      if not rxlabo then
        do_rx9('0' & rxcrc(f_byte0));
        do_rx9('0' & rxcrc(f_byte1));
      end if;
    end procedure do_rxcrc;
            
    procedure do_rxsop is               -- ---- do_rxsop -------------
    begin
      checkmiss_rx;
      sv_nrxlist := 0;
      sv_rxind   := 0;
      rxcrc      := (others=>'0');
      do_rx9(c_rlink_dat_sop);
    end procedure do_rxsop;

    procedure do_rxeop is               -- ---- do_rxeop -------------
    begin
      do_rx9(c_rlink_dat_eop);
    end procedure do_rxeop;

    procedure do_rxcs (                 -- ---- do_rxcs ----------
      icmd  : in slv8;
      istat : in slv8) is                                      
    begin
      do_rx8(icmd);
      do_rx8(istat);
      do_rxcrc;
    end procedure do_rxcs;

    procedure do_rxcds (                -- ---- do_rxcds ----------
      icmd  : in slv8;
      idata : in slv16;
      istat : in slv8) is                                      
    begin
      do_rx8(icmd);
      do_rx16(idata);
      do_rx8(istat);
      do_rxcrc;
    end procedure do_rxcds;

    procedure do_rxcbs (                -- ---- do_rxcbs ----------
      icmd  : in slv8;
      ibabo : in slv8;
      istat : in slv8) is                                      
    begin
      do_rx8(icmd);
      do_rx8(ibabo);
      do_rx8(istat);
      do_rxcrc;
    end procedure do_rxcbs;

    procedure do_rxrbeg (              -- ---- do_rxrbeg -------------
      icmd  : in slv8;
      nblk  : in natural) is
    begin
      do_rx8(icmd);
      do_rx16(slv(to_unsigned(nblk,16)));
    end procedure do_rxrbeg;

    procedure do_rxrend (              -- ---- do_rxrend -------------
      nblk  : in natural;
      istat  : in slv8) is
    begin
      do_rx16(slv(to_unsigned(nblk,16)));
      do_rx8(istat);  
      do_rxcrc;
    end procedure do_rxrend;

    procedure do_rxblks (               -- ---- do_rxblks ------------
      nblk  : in natural; 
      start : in slv16) is
      variable idata : slv16;
    begin
      idata := start;
      for i in 1 to nblk loop
        do_rx16(idata);
        idata := slv(unsigned(idata) + 1);
      end loop;
    end procedure do_rxblks;

  begin

    SB_CNTL <= (others=>'0');

    wait for clock_offset - setup_time;

    file_loop: while not endfile(fstim) loop

      readline (fstim, iline);
      
      readcomment(iline, ok);
      next file_loop when ok;

      readword(iline, dname, ok);
      
      if ok then
        case dname is
          when ".reset" =>              -- .reset 
            write(oline, string'(".reset"));
            writeline(output, oline);
            RESET <= '1';
            wait for clock_period;
            RESET <= '0';
            wait for 9*clock_period;

          when ".rlmon" =>              -- .rlmon
            read_ea(iline, ien);
            SB_CNTL(sbcntl_sbf_rlmon) <= ien;
            wait for 2*clock_period;      -- wait for monitor to start

          when ".rlbmo" =>              -- .rlbmo
            read_ea(iline, ien);
            SB_CNTL(sbcntl_sbf_rlbmon) <= ien;
            wait for 2*clock_period;      -- wait for monitor to start

          when ".rbmon" =>              -- .rbmon
            read_ea(iline, ien);
            SB_CNTL(sbcntl_sbf_rbmon) <= ien;
            wait for 2*clock_period;      -- wait for monitor to start

          when ".wait " =>              -- .wait
            read_ea(iline, idelta);
            wait for idelta*clock_period;
            
          when ".iowt " =>              -- .iowt
            read_ea(iline, iowait);
            idelta := iowait;
            while idelta > 0 loop       -- until time has expired
              if TXRXACT = '1' then       -- if any io activity
                idelta := iowait;         -- restart timer
              else
                idelta := idelta - 1;     -- otherwise count down time
              end if;
              wait for clock_period;
            end loop;

          when ".attn " =>              -- .attn
            read_ea(iline, iattn);
            RB_LAM_TBENCH <= iattn;       -- pulse attn lines
            wait for clock_period;        -- for 1 clock
            RB_LAM_TBENCH <= (others=>'0');

          when "txsop " =>              -- txsop   send sop
            do_txsop;
          when "txeop " =>              -- txeop   send eop
            do_txeop;

          when "txnak " =>              -- txnak   send nak
            do_tx9(c_rlink_dat_nak);
          when "txattn" =>              -- txattn  send attn
            do_tx9(c_rlink_dat_attn);

          when "tx8   " =>              -- tx8     send 8 bit value
            readgen_ea(iline, idat8, 2);
            do_tx8(idat8);
          when "tx16  " =>              -- tx16    send 16 bit value
            readgen_ea(iline, idata, 2);
            do_tx16(idata);

          when "txblk " =>              -- txblk   send n 16 bit values
            read_ea(iline, nblk);
            readgen_ea(iline, idata, 2);
            do_txblks(nblk, idata);
            
          when "txcrc " =>              -- txcrc   send crc  
            do_txcrc;
            
          when "txbad " =>              -- txbad   send bad crc
            do_tx9('0' & (not txcrc(f_byte0)));
            do_tx9('0' & (not txcrc(f_byte1)));

          when "txc   " =>              -- txc     send: cmd crc
            get_cmd_ea(iline, icmd);
            do_txc(icmd);

          when "txca  " =>              -- txc     send: cmd addr crc
            get_cmd_ea(iline, icmd);
            readgen_ea(iline, iaddr, 2);
            do_txca(icmd, iaddr);

          when "txcad " =>              -- txc     send: cmd addr data crc
            get_cmd_ea(iline, icmd);
            readgen_ea(iline, iaddr, 2);
            readgen_ea(iline, idata, 2);
            do_txcad(icmd, iaddr, idata);

          when "txcac " =>              -- txc     send: cmd addr cnt crc
            get_cmd_ea(iline, icmd);
            readgen_ea(iline, iaddr, 2);
            readgen_ea(iline, icnt, 2);
            do_txcad(icmd, iaddr, icnt);

          when "txoof " =>              -- txoof   send out-of-frame symbol
            readgen_ea(iline, txlist(0), 2);
            ntxlist := 1;
            
          when "rxsop " =>              -- rxsop   expect sop
            do_rxsop;
          when "rxeop " =>              -- rxeop   expect eop
            do_rxeop;
            
          when "rxnak " =>              -- rxnak   expect nak
            do_rx9(c_rlink_dat_nak);
          when "rxattn" =>              -- rxattn  expect attn
            do_rxattn;

          when "rx8   " =>              -- rx8     expect 8 bit value
            readgen_ea(iline, idat8, 2);
            do_rx8(idat8);
          when "rx16  " =>              -- rx16    expect 16 bit value
            readgen_ea(iline, idata, 2);
            do_rx16(idata);

          when "rxblk " =>              -- rxblk   expect n 16 bit values
            read_ea(iline, nblk);
            readgen_ea(iline, idata, 2);
            do_rxblks(nblk, idata);

          when "rxcrc " =>              -- rxcrc   expect crc
            do_rxcrc;

          when "rxcs  " =>              -- rxcs    expect: cmd stat crc
            get_cmd_ea(iline, icmd);
            readgen_ea(iline, istat, 2);
            do_rxcs(icmd, istat);

          when "rxcds " =>              -- rxcsd   expect: cmd data stat crc
            get_cmd_ea(iline, icmd);
            readgen_ea(iline, idata, 2); 
            readgen_ea(iline, istat, 2);
            do_rxcds(icmd, idata, istat);

          when "rxcbs " =>              -- rxcsd   expect: cmd babo stat crc
            get_cmd_ea(iline, icmd);
            readgen_ea(iline, ibabo, 2); 
            readgen_ea(iline, istat, 2);
            do_rxcbs(icmd, ibabo, istat);

          when "rxrbeg" =>              -- rxrbeg  expect: cmd - cl ch
            get_cmd_ea(iline, icmd);
            read_ea(iline, nblk);
            do_rxrbeg(icmd, nblk);

          when "rxrend" =>              -- rxrend  expect: dcl dch - stat - crc
            read_ea(iline, nblk); 
            readgen_ea(iline, istat, 2);
            do_rxrend(nblk, istat);
            
          when "rxoof " =>              -- rxoof   expect: out-of-frame symbol
            readgen_ea(iline, ioof, 2);
            sv_rxlist(sv_nrxlist) := ioof;
            sv_nrxlist := sv_nrxlist + 1;

          when "anmsg " =>              -- anmsg
            readgen_ea(iline, idata, 2);               -- apat
            do_rxattn;
            do_rx16(idata);
            do_rxcrc;
            do_rxeop;
            
          when "sop   " =>              -- sop
            do_rxsop;
            do_txsop;
            rxlabo := false;
          when "eop   " =>              -- eop
            do_rxeop;
            do_txeop;

          when "rreg  " =>              -- rreg   seq  addr  data  stat
            get_seq_ea(iline, c_rlink_cmd_rreg, icmd); -- seq
            readgen_ea(iline, iaddr, 2);               -- addr
            readgen_ea(iline, idata, 2);               -- data
            readgen_ea(iline, istat, 2);               -- stat
            do_rxcds(icmd, idata, istat);   -- rx: cmd dl sh stat ccsr
            do_txca (icmd, iaddr);          -- tx: cmd al ah ccsr
            
          when "wreg  " =>              -- wreg  seq  addr  data  stat
            get_seq_ea(iline, c_rlink_cmd_wreg, icmd); -- seq
            readgen_ea(iline, iaddr, 2);               -- addr
            readgen_ea(iline, idata, 2);               -- data
            readgen_ea(iline, istat, 2);               -- stat
            do_rxcs (icmd, istat);          -- rx: cmd stat ccsr
            do_txcad(icmd, iaddr, idata);   -- tx: cmd al ah dl dh ccsr

          when "init  " =>              -- init  seq  addr  data  stat
            get_seq_ea(iline, c_rlink_cmd_init, icmd); -- seq
            readgen_ea(iline, iaddr, 2);               -- addr
            readgen_ea(iline, idata, 2);               -- data
            readgen_ea(iline, istat, 2);               -- stat
            do_rxcs (icmd, istat);          -- rx: cmd stat ccsr
            do_txcad(icmd, iaddr, idata);   -- tx: cmd al ah dl dh ccsr

          when "attn  " =>              -- attn  seq  data  stat
            get_seq_ea(iline, c_rlink_cmd_attn, icmd); -- seq
            readgen_ea(iline, idata, 2);               -- data
            readgen_ea(iline, istat, 2);               -- stat
            do_rxcds (icmd, idata, istat);  -- rx: cmd dl dh stat ccsr
            do_txc   (icmd);                -- tx: cmd ccsr

          when "labo  " =>              -- labo  seq  babo  stat
            get_seq_ea(iline, c_rlink_cmd_labo, icmd); -- seq
            readgen_ea(iline, ibabo, 2);               -- babo
            readgen_ea(iline, istat, 2);               -- stat
            do_rxcbs (icmd, ibabo, istat);  -- rx: cmd dl stat ccsr
            do_txc   (icmd);                -- tx: cmd ccsr
            rxlabo := ibabo /= x"00";       -- set rxlabo flag
            
          when "rblks " =>              -- rblks seq  addr  nblk  data  stat
            get_seq_ea(iline, c_rlink_cmd_rblk, icmd); -- seq
            readgen_ea(iline, iaddr, 2);               -- addr
            read_ea(iline, nblk);                      -- nblk
            readgen_ea(iline, idata, 2);               -- start
            readgen_ea(iline, istat, 2);               -- stat
            do_rxrbeg(icmd, nblk);                --rx: cmd cl ch
            do_rxblks(nblk, idata);               --     nblk*(dl dh)
            do_rxrend(nblk, istat);               --     dcl dch stat ccrc
            do_txcad(icmd, iaddr,                 -- tx: cmd al ah cl ch ccrc
                     slv(to_unsigned(nblk,16)));
                    
          when "wblks " =>              -- wblks seq  addr  nblk  data  stat
            get_seq_ea(iline, c_rlink_cmd_wblk, icmd); -- seq
            readgen_ea(iline, iaddr, 2);               -- addr
            read_ea(iline, nblk);                      -- nblk
            readgen_ea(iline, idata, 2);               -- start
            readgen_ea(iline, istat, 2);               -- stat
            do_rxcds(icmd,                        -- rx: cmd dcl dch stat ccsr
                     slv(to_unsigned(nblk,16)),
                     istat);
            do_txcad(icmd, iaddr,                 -- tx: cmd al ah cl ch ccrc
                     slv(to_unsigned(nblk,16)));  
            do_txblks(nblk, idata);               --     nblk*(dl dh)
            do_txcrc;                             --     dcrc
                    
          when "rblkd " =>              -- rblkd seq  addr  ndone  stat 
            get_seq_ea(iline, c_rlink_cmd_rblk, icmd); -- seq
            readgen_ea(iline, iaddr, 2);               -- addr
            read_ea(iline, ndone);                     -- ndone
            readgen_ea(iline, istat, 2);               -- stat
            do_rxrbeg(icmd, ndatlist);            --rx: cmd cl ch
            for i in 0 to ndatlist-1 loop
              do_rx16(datlist(i));                --    nblk*(dl dh)
            end loop;  -- i
            do_rxrend(ndone, istat);              --     dcl dch stat ccrc
            do_txcad(icmd, iaddr,                 -- tx: cmd al ah cl ch ccrc
                     slv(to_unsigned(ndatlist,16)));
                    
          when "wblkd " =>              -- wblkd seq  addr  ndone  stat
            get_seq_ea(iline, c_rlink_cmd_wblk, icmd); -- seq
            readgen_ea(iline, iaddr, 2);               -- addr
            read_ea(iline, ndone);                     -- ndone
            readgen_ea(iline, istat, 2);               -- stat
            do_rxcds(icmd,                        -- rx: cmd dcl dch stat ccsr
                     slv(to_unsigned(ndone,16)),
                     istat);
            do_txcad(icmd, iaddr,                 -- tx: cmd al ah cl ch ccrc
                     slv(to_unsigned(ndatlist,16)));  
            for i in 0 to ndatlist-1 loop
              do_tx16(datlist(i));                --    nblk*(dl dh)
            end loop;  -- i
            do_txcrc;                             --     dcrc
                    
          when ".dclr " =>              -- .dclr
            ndatlist := 0;

          when ".dwrd " =>              -- .dwrd data
            readgen_ea(iline, idata, 2);
            datlist(ndatlist) := idata;
            ndatlist := ndatlist + 1;

          when ".dseq " =>              -- .dseq nblk start
            read_ea(iline, nblk);
            readgen_ea(iline, idata, 2);
            for i in 1 to nblk loop
              datlist(ndatlist) := idata;
              ndatlist := ndatlist + 1;
              idata := slv(unsigned(idata) + 1);
            end loop;

          when others =>                -- bad command
            write(oline, string'("?? unknown command: "));
            write(oline, dname);
            writeline(output, oline);
            report "aborting" severity failure;
        end case;

      else
        report "failed to find command" severity failure;
      end if;

      testempty_ea(iline);
      next file_loop when ntxlist=0;
      
      for i in 0 to ntxlist-1 loop
        
        RL_DI <= txlist(i);
        RL_ENA <= '1';

        writetimestamp(oline, CLK_CYCLE, ": stim");
        write(oline, txlist(i)(d_f_cflag), right, 3);
        write(oline, txlist(i)(d_f_data), right, 9);
        if txlist(i)(d_f_cflag) = '1' then
          case txlist(i) is
            when c_rlink_dat_sop =>
              write(oline, string'(" (sop) "));
            when c_rlink_dat_eop =>
              write(oline, string'(" (eop) "));
            when c_rlink_dat_nak =>
              write(oline, string'(" (nak) "));
            when c_rlink_dat_attn =>
              write(oline, string'(" (attn)"));
            when others => 
              write(oline, string'(" (????)"));
          end case;
        end if;
        writeline(output, oline);
      
        wait for clock_period;
        while RL_BUSY = '1' loop
          wait for clock_period;
        end loop;
        RL_ENA <= '0';
      
      end loop;  -- i

      ntxlist := 0;
      
    end loop; -- file fstim

    wait for 50*clock_period;

    checkmiss_rx;
    writetimestamp(oline, CLK_CYCLE, ": DONE ");
    writeline(output, oline);

    CLK_STOP <= '1';

    wait;                               -- suspend proc_stim forever
                                        -- clock is stopped, sim will end

  end process proc_stim;

  
  proc_moni: process
    variable oline : line;
  begin

    loop 
      wait until rising_edge(CLK);
      wait for c2out_time;

      if RL_VAL = '1' then
        writetimestamp(oline, CLK_CYCLE, ": moni");
        write(oline, RL_DO(d_f_cflag), right, 3);
        write(oline, RL_DO(d_f_data), right, 9);
        if RL_DO(d_f_cflag) = '1' then
          case RL_DO is
            when c_rlink_dat_sop =>
              write(oline, string'(" (sop) "));
            when c_rlink_dat_eop =>
              write(oline, string'(" (eop) "));
            when c_rlink_dat_nak =>
              write(oline, string'(" (nak) "));
            when c_rlink_dat_attn =>
              write(oline, string'(" (attn)"));
            when others => 
              write(oline, string'(" (????)"));
          end case;
        end if;
        if sv_nrxlist > 0 then
          write(oline, string'("  CHECK"));
          if sv_rxind < sv_nrxlist then
            if RL_DO = sv_rxlist(sv_rxind) then
              write(oline, string'(" OK"));
            else
              write(oline, string'(" FAIL, exp="));
              write(oline, sv_rxlist(sv_rxind)(d_f_cflag), right, 2);
              write(oline, sv_rxlist(sv_rxind)(d_f_data),  right, 9);
            end if;
            sv_rxind := sv_rxind + 1;
          else
            write(oline, string'(" FAIL, UNEXPECTED"));
          end if;
        end if;
        writeline(output, oline);
      end if;
      
    end loop;
    
  end process proc_moni;

end sim;
