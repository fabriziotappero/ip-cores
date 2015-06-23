-- $Id: rlink_core.vhd 641 2015-02-01 22:12:15Z mueller $
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
-- Module Name:    rlink_core - syn
-- Description:    rlink core with 9bit interface (with rlmon+rbmon)
--
-- Dependencies:   memlib/ram_2swsr_rfirst_gen
--                 memlib/fifo_1c_dram
--                 comlib/crc16
--                 rb_sel
--                 rb_sres_or_2
--                 rlink_mon_sb    [sim only]
--                 rbus/rb_mon_sb  [sim only]
--
-- Test bench:     tb/tb_rlink_direct
--                 tb/tb_rlink_serport
--                 tb/tb_rlink_tba_ttcombo
--
-- Target Devices: generic
-- Tool versions:  ise 8.2-14.7; viv 2014.4; ghdl 0.18-0.31
--
-- Synthesized (xst):
-- Date         Rev  ise         Target      flop lutl lutm slic t peri
-- 2014-12-20   614 14.7  131013 xc6slx16-2   310  453   16  146 s  6.8 ver 4.0
-- 2014-08-13   581 14.7  131013 xc6slx16-2   160  230    0   73 s  6.0 ver 3.0
-- 2014-08-13   581 14.7  131013 xc3s1000-4   160  358    0  221 s  8.9 ver 3.0
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2014-12-21   617   4.1    use stat(_rbf_rbtout) to signal rbus timeout
-- 2014-12-20   614   4.0    largely rewritten; 2 FSMs; v3 protocol; 4 bit STAT
-- 2014-08-15   583   3.5    rb_mreq addr now 16 bit; add s_rxaddrl state
-- 2011-11-19   427   3.1.3  now numeric_std clean
-- 2010-12-25   348   3.1.2  drop RL_FLUSH support, add RL_MONI for rlink_core;
-- 2010-12-24   347   3.1.1  rename: CP_*->RL->*
-- 2010-12-22   346   3.1    wblk dcrc error: send nak, transit to s_error now;
--                           rename stat flags: [cd]crc->[cd]err, ioto->rbnak,
--                           ioerr->rberr; '111' cmd now aborts via s_txnak and
--                           sets cerr flag; set [cd]err on eop/nak aborts;
-- 2010-12-04   343   3.0    renamed rri_ -> rlink_; rbus V3 interface: use now
--                           aval,re,we; add new states: s_rstart, s_wstart
-- 2010-06-20   308   2.6    use rbinit,rbreq,rbwe state flops to drive rb_mreq;
--                           now nak on reserved cmd 111; use do_comma_abort();
-- 2010-06-18   306   2.5.1  rename rbus data fields to _rbf_
-- 2010-06-06   302   2.5    use sop/eop framing instead of soc+chaining
-- 2010-06-03   299   2.1.2  drop unneeded unsigned casts; change init encoding
-- 2010-05-02   287   2.1.1  ren CE_XSEC->CE_INT,RP_STAT->RB_STAT,AP_LAM->RB_LAM
--                           drop RP_IINT signal from interfaces
-- 2010-04-03   274   2.1    add CP_FLUSH output
-- 2009-07-12   233   2.0.1  remove snoopers
-- 2008-08-24   162   2.0    with new rb_mreq/rb_sres interface
-- 2008-03-02   121   1.1.1  comment out snoopers
-- 2007-11-24    98   1.1    new internal init handling (addr=11111111)
-- 2007-10-12    88   1.0.1  avoid ieee.std_logic_unsigned, use cast to unsigned
-- 2007-09-15    82   1.0    Initial version, fully functional
-- 2007-06-17    58   0.5    First preliminary version
------------------------------------------------------------------------------
--  7 supported commands:
--    nak aborts to _txnak are indicated as [nak:<nakcode>]
--    commands to rbus engine are indicated as [bcmd:<bfunc>]
--
--   000 read reg (rreg):
--        rx: cmd al ah ccrcl ccrch
--        tx: cmd dl dh stat crcl crch
--       seq: _rxcmd _rxaddrl _rxaddrh
--            _rxccrcl[nak:ccrc] _rxccrch[nak:ccrc] _txcmd
--            _rstart[bcmd:rblk] {_txdat}*
--            _txstat _txcrcl[nak:rtovfl] -> _txcrch -> _rxcmd
--
--   001 read blk (rblk):
--        rx: cmd al ah cl ch ccrcl ccrch
--        tx: cmd cnt dl dh ... dcl dch stat crcl crch
--       seq: _rxcmd _rxaddrl _rxaddrh _rxcntl _rxcnth
--            _rxccrcl[nak:ccrc] _rxccrch[nak:ccrc] _txcmd
--            _txcntl _txcnth _rstart[bcmd:rblk] {_txdat}* _txdcntl _txdcnth
--            _txstat _txcrcl[nak:rtovfl] -> _txcrch -> _rxcmd
--
--   010 write reg (wreg):
--        rx: cmd al ah dl dh ccrcl ccrch
--        tx: cmd stat crcl crch
--       seq: _rxcmd _rxaddrl _rxaddrh _rxdatl _rxdath
--            _rxccrcl[nak:ccrc] _rxccrch[nak:ccrc] _txcmd
--            _txcmd[bcmd:wblk] _wwait0
--            _txstat _txcrcl[nak:rtovfl] -> _txcrch -> _rxcmd
--
--   011 write blk (wblk):
--        rx: cmd al ah cnt ccrcl ccrch dl dh ... dcrcl dcrch
--        tx: cmd dcl dch stat crcl crch
--       seq: _rxcmd _rxaddrl _rxaddrh _rxcntl _rxcnth
--            _rxccrcl[nak:ccrc] _rxccrch[nak:ccrc] _txcmd
--            _wblk {_rxwblk}* _rxdcrc[nak:dcrc,rtwblk]
--            _wblk0 _wblk1 _wblk2[bcmd:wblk] {_wblkl _wblkh}*
--            _wwait0 _wwait1 _txdcntl _txdcnth
--            _txstat _txcrcl[nak:rtovfl] -> _txcrch -> _rxcmd
--
--   100 list abort (labo):
--        rx: cmd ccrcl ccrch
--        tx: cmd babo stat crcl crch
--       seq: _rxcmd 
--            _rxccrcl[nak:ccrc] _rxccrch[nak:ccrc] _txcmd
--            _txlabo
--            _txstat_txcrcl[nak:rtovfl] -> _txcrch -> [_rxcmd|_rxeop]
--
--   101 read attn (attn):
--        rx: cmd ccrcl ccrch
--        tx: cmd dl dh stat crcl crch
--       seq: _rxcmd
--            _rxccrcl[nak:ccrc] _rxccrch[nak:ccrc] _txcmd
--            _attn _txcntl _txcnth
--            _txstat _txcrcl[nak:rtovfl] -> _txcrch -> _rxcmd
--
--   110 write init (init):
--        rx: cmd al ah dl dh ccrcl ccrch
--        tx: cmd stat crcl crch
--       seq: _rxcmd _rxaddrl _rxaddrh _rxdatl _rxdath
--            _rxccrcl[nak:ccrc] _rxccrch[nak:ccrc] _txcmd[bcmd:init]
--            _txstat _txcrc[nak:rtovfl] -> _rxcmd
--
--   111 is currently not a legal command and causes a nak
--       seq: _txnak
--
-- The different rbus cycle types are encoded as:
--
--        init aval re we
--          0    0   0  0   idle
--          0    1   1  0   read 
--          0    1   0  1   write
--          1    0   0  0   init
--          0    0   1  0   not allowed
--          0    0   0  1   not allowed
--          1    0   0  1   not allowed
--          1    0   1  0   not allowed
--          *    *   1  1   not allowed
--          1    1   *  *   not allowed
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.memlib.all;
use work.comlib.all;
use work.rblib.all;
use work.rlinklib.all;

entity rlink_core is                    -- rlink core with 9bit interface
  generic (
    BTOWIDTH : positive :=  5;          -- rbus timeout counter width
    RTAWIDTH : positive :=  12;         -- retransmit buffer address width
    SYSID : slv32 := (others=>'0');     -- rlink system id
    ENAPIN_RLMON : integer := -1;       -- SB_CNTL for rlmon  (-1=none)
    ENAPIN_RBMON : integer := -1);      -- SB_CNTL for rbmon  (-1=none)
  port (
    CLK  : in slbit;                    -- clock      
    CE_INT : in slbit := '0';           -- rri ato time unit clock enable
    RESET  : in slbit;                  -- reset
    RL_DI : in slv9;                    -- rlink 9b: data in
    RL_ENA : in slbit;                  -- rlink 9b: data enable
    RL_BUSY : out slbit;                -- rlink 9b: data busy
    RL_DO : out slv9;                   -- rlink 9b: data out
    RL_VAL : out slbit;                 -- rlink 9b: data valid
    RL_HOLD : in slbit;                 -- rlink 9b: data hold
    RL_MONI : out rl_moni_type;         -- rlink: monitor port
    RB_MREQ : out rb_mreq_type;         -- rbus: request
    RB_SRES : in rb_sres_type;          -- rbus: response
    RB_LAM : in slv16;                  -- rbus: look at me
    RB_STAT : in slv4                   -- rbus: status flags
  );

  attribute fsm_encoding : string;
  attribute fsm_encoding of rlink_core : entity is "one-hot";

end entity rlink_core;  

architecture syn of rlink_core is
   -- core config registers (top 4 in rbus space)
  constant rbaddr : slv16 := x"fffc";    -- fffc/4: 1111 1111 1111 11xx
  constant rbaddr_cntl : slv2 := "11";   -- cntl address offset
  constant rbaddr_stat : slv2 := "10";   -- stat address offset
  constant rbaddr_id1  : slv2 := "01";   -- id1  address offset
  constant rbaddr_id0  : slv2 := "00";   -- id0  address offset

  constant d_f_cflag   : integer := 8;                -- d9: comma flag
  subtype  d_f_ctyp   is integer range  2 downto  0;  -- d9: comma type
  subtype  d_f_data   is integer range  7 downto  0;  -- d9: data field

  subtype  f_byte1    is integer range 15 downto 8;
  subtype  f_byte0    is integer range  7 downto 0;
  
  constant cntl_rbf_anena    : integer := 15;               -- anena flag
  constant cntl_rbf_atoena   : integer := 14;               -- atoena flag
  subtype  cntl_rbf_atoval  is integer range  7 downto  0;  -- atoval value
  subtype  stat_rbf_lcmd    is integer range 15 downto  8;  -- lcmd
  constant stat_rbf_babo     : integer :=  7;               -- block abort flag
  constant stat_rbf_arpend   : integer :=  6;               -- attn read pend
  subtype  stat_rbf_rbsize  is integer range  2 downto  0;  -- rbuf size

  -- following 4 constants can derived from c_rlink_dat_sop,...
  -- defined directly here to work around a ghdl bug
  constant c_sop  : slv3 := "000";
  constant c_eop  : slv3 := "001";
  constant c_nak  : slv3 := "010";
  constant c_attn : slv3 := "011";

  constant c_bcmd_stat : slv2 := "00";
  constant c_bcmd_init : slv2 := "01";
  constant c_bcmd_rblk : slv2 := "10";
  constant c_bcmd_wblk : slv2 := "11";

  constant cntawidth : positive := RTAWIDTH-1;        -- cnt is word count
  subtype  cnt_f_dat  is integer range cntawidth-1 downto  0;   -- cnt data
    
  -- link FSM states and state vector ----------------------------------------
  type lstate_type is (
    sl_idle,                            -- sl_idle: wait for sop
    sl_txanot,                          -- sl_txanot: send attn notify
    sl_txsop,                           -- sl_txsop: send sop
    sl_txnak,                           -- sl_txnak: send nak
    sl_txnakcode,                       -- sl_txnakcode: send nakcode
    sl_txrtbuf,                         -- sl_txrtbuf: send rtbuf
    sl_txeop,                           -- sl_txeop: send eop
    sl_rxeop,                           -- sl_rxeop: wait for eop
    sl_rxcmd,                           -- sl_rxcmd: wait for cmd
    sl_rxaddrl,                         -- sl_rxaddrl: wait for addr low
    sl_rxaddrh,                         -- sl_rxaddrh: wait for addr high
    sl_rxdatl,                          -- sl_rxdatl: wait for data low
    sl_rxdath,                          -- sl_rxdath: wait for data high
    sl_rxcntl,                          -- sl_rxcntl: wait for count low
    sl_rxcnth,                          -- sl_rxcnth: wait for count low
    sl_rxccrcl,                         -- sl_rxccrcl: wait for command crc low
    sl_rxccrch,                         -- sl_rxccrcl: wait for command crc high
    sl_txcmd,                           -- sl_txcmd: send cmd
    sl_txcntl,                          -- sl_txcntl: send cnt lsb
    sl_txcnth,                          -- sl_txcnth: send cnt msb
    sl_rstart,                          -- sl_rstart: start rreg or rblk
    sl_txdat,                           -- sl_txdat: send data
    sl_wblk,                            -- sl_wblk: setup rx wblk data
    sl_rxwblk,                          -- sl_rxwblk: wait for wblk data
    sl_rxdcrcl,                         -- sl_rxdcrcl: wait for data crc low
    sl_rxdcrch,                         -- sl_rxdcrch: wait for data crc high
    sl_wblk0,                           -- sl_wblk0: start wblk pipe
    sl_wblk1,                           -- sl_wblk1: start wblk data lsb
    sl_wblk2,                           -- sl_wblk2: start wblk data msb
    sl_wblkl,                           -- sl_wblkl: wblk data lsb
    sl_wblkh,                           -- sl_wblkh: wblk data msb
    sl_wwait0,                          -- sl_wwait0: wait for wdone
    sl_wwait1,                          -- sl_wwait1: wait for dcnt
    sl_txdcntl,                         -- sl_txdcntl: send dcnt lsb
    sl_txdcnth,                         -- sl_txdcnth: send dcnt lsb
    sl_txlabo,                          -- sl_txlabo: send labo flag
    sl_attn,                            -- sl_attn: handle attention flags
    sl_txstat,                          -- sl_txstat: send status
    sl_txcrcl,                          -- sl_txcrcl: send crc low
    sl_txcrch                           -- sl_txcrch: send crc high
  );

  type lregs_type is record
    state : lstate_type;                -- state
    rcmd : slv8;                        -- received command
    lcmd : slv8;                        -- last command
    addr : slv16;                       -- rbus register address
    din : slv16;                        -- rbus input data
    cnt : slv16;                        -- block transfer count
    bcnt : slv(RTAWIDTH-1 downto 0);    -- blk counter (byte and word)
    attn : slv16;                       -- attn mask
    anreq : slbit;                      -- attn notify request
    anact : slbit;                      -- attn notify active
    arpend : slbit;                     -- attn read pending
    atocnt : slv8;                      -- attn timeout counter
    babo : slbit;                       -- last blk aborted
    nakdone : slbit;                    -- nak done
    nakcode : slv3;                     -- nak code
    cmdseen : slbit;                    -- 1st command seen
    doretra : slbit;                    -- do a retransmit
    dinl : slv8;                        -- din lsb for wblk pipeline
    rtaddra : slv(RTAWIDTH-1 downto 0); -- rtbuf port a addr (write pointer)
    rtaddra_red : slbit;                -- rtaddra red (at max)
    rtaddra_bad : slbit;                -- rtaddra bad (inc beyond max)
    rtaddrb : slv(RTAWIDTH-1 downto 0); -- rtbuf port b addr (aux pointer)
    rtaddrb_red : slbit;                -- rtaddrb red (at max)
    rtaddrb_bad : slbit;                -- rtaddrb bad (inc beyond max)
    moneop : slbit;                     -- rl_moni: eop send pulse
    monattn : slbit;                    -- rl_moni: attn send pulse
  end record lregs_type;

  constant bcnt_zero   : slv(RTAWIDTH-1 downto 0) := (others=>'0');
  constant rtaddr_zero : slv(RTAWIDTH-1 downto 0) := (others=>'0');
  constant rtaddr_tred : slv(RTAWIDTH-1 downto 0) := (0=>'0', others=>'1');

  constant lregs_init : lregs_type := (
    sl_idle,                            -- state
    (others=>'0'),                      -- rcmd
    (others=>'1'),                      -- lcmd
    (others=>'0'),                      -- addr
    (others=>'0'),                      -- din
    (others=>'0'),                      -- cnt
    bcnt_zero,                          -- bcnt
    (others=>'0'),                      -- attn
    '0','0','0',                        -- anreq,anact,arpend
    (others=>'0'),                      -- atocnt
    '0',                                -- babo
    '0',                                -- nakdone
    (others=>'0'),                      -- nakcode
    '0','0',                            -- cmdseen,doretra
    (others=>'0'),                      -- dinl
    rtaddr_zero,                        -- rtaddra
    '0','0',                            -- rtaddra_red, rtaddra_bad
    rtaddr_zero,                        -- rtaddrb
    '0','0',                            -- rtaddrb_red, rtaddrb_bad
    '0','0'                             -- moneop,monattn
  );

  -- bus FSM states and state vector -----------------------------------------
  type bstate_type is (
    sb_idle,                            -- sb_idle: wait for cmd
    sb_rstart,                          -- sb_rstart: start rblk
    sb_rreg0,                           -- sb_rreg0: rbus read cycle
    sb_rreg1,                           -- sb_rreg1: send read data
    sb_rwait,                           -- sb_rwait: wait for fifo
    sb_rend,                            -- sb_rend: send last read data
    sb_rabo0,                           -- sb_rabo0: rblk abort, lsb data
    sb_rabo1,                           -- sb_rabo1: rblk abort, msb data
    sb_wstart,                          -- sb_wstart: start wblk
    sb_wreg0,                           -- sb_wreg0: rbus write cycle
    sb_wreg1,                           -- sb_wreg1: wait write data
    sb_wabo0,                           -- sb_wabo0: wblk abort, drop data
    sb_wabo1                            -- sb_wabo1: wblk abort, wait
  );

  type bregs_type is record
    state : bstate_type;                -- state
    rbinit : slbit;                     -- rbus init signal
    rbaval : slbit;                     -- rbus aval signal
    rbre : slbit;                       -- rbus re signal
    rbwe : slbit;                       -- rbus we signal
    rbdout : slv16;                     -- rbus dout
    rbtout: slbit;                      -- rbus timeout
    rbnak: slbit;                       -- rbus no ack
    rberr : slbit;                      -- rbus err bit set
    blkabo : slbit;                     -- blk abort
    cnt : slv(cntawidth-1 downto 0);    -- word count for rblk and wblk
    dcnt : slv(cntawidth-1 downto 0);   -- done count for rblk and wblk
    btocnt : slv(BTOWIDTH-1 downto 0);  -- rbus timeout counter
    dathpend : slbit;                   -- dat msb pending
    wfifo : slbit;                      -- wait for fifo
    stat : slv4;                        -- external status flags
  end record bregs_type;

  constant btocnt_init : slv(BTOWIDTH-1 downto 0) := (others=>'1');
  constant cnt_zero    : slv(cntawidth-1 downto 0) := (others=>'0');

  constant bregs_init : bregs_type := (
    sb_idle,                            -- state
    '0','0','0','0',                    -- rbinit,rbaval,rbre,rbwe
    (others=>'0'),                      -- rbdout
    '0','0','0',                        -- rbtout,rbnak,rberr
    '0',                                -- blkabo
    cnt_zero,                           -- cnt
    cnt_zero,                           -- dcnt
    btocnt_init,                        -- btocnt
    '0','0',                            -- dathpend,wfifo
    (others=>'0')                       -- stat
  );

  -- config state regs --------------------------------------------------------
  type cregs_type is record
    anena : slbit;                      -- attn notification enable flag
    atoena : slbit;                     -- attn timeout enable flag
    atoval : slv8;                      -- attn timeout value
  end record cregs_type;
  
  constant cregs_init : cregs_type := (
    '0','0',                            -- anena,atoena
    (others=>'0')                       -- atoval
  );

  signal R_LREGS : lregs_type := lregs_init;  -- state registers link FSM
  signal N_LREGS : lregs_type := lregs_init;  -- next value state regs link FSM
  signal R_BREGS : bregs_type := bregs_init;  -- state registers bus FSM
  signal N_BREGS : bregs_type := bregs_init;  -- next value state regs bus FSM
  signal R_CREGS : cregs_type := cregs_init;  -- state registers config
  signal N_CREGS : cregs_type := cregs_init;  -- next value state regs config

  signal RTBUF_ENB : slbit := '0';
  signal RTBUF_WEA : slbit := '0';
  signal RTBUF_WEB : slbit := '0';
  signal RTBUF_DIA : slv8 := (others=>'0');
  signal RTBUF_DIB : slv8 := (others=>'0');
  signal RTBUF_DOB : slv8 := (others=>'0');

  signal DOFIFO_DI   : slv8  := (others=>'0');
  signal DOFIFO_ENA  : slbit := '0';
  signal DOFIFO_DO   : slv8  := (others=>'0');
  signal DOFIFO_VAL  : slbit := '0';
  signal DOFIFO_HOLD : slbit := '0';
  signal DOFIFO_SIZE : slv6  := (others=>'0');

  signal CRC_RESET : slbit := '0';
  signal ICRC_ENA  : slbit := '0';
  signal OCRC_ENA  : slbit := '0';
  signal ICRC_OUT  : slv16 := (others=>'0');
  signal OCRC_OUT  : slv16 := (others=>'0');
  signal OCRC_IN   : slv8  := (others=>'0');

  signal RBSEL : slbit := '0';

  signal RB_MREQ_L    : rb_mreq_type := rb_mreq_init;  -- internal mreq
  signal RB_SRES_CONF : rb_sres_type := rb_sres_init;  -- config sres
  signal RB_SRES_TOT  : rb_sres_type := rb_sres_init;  -- total  sres

  signal RL_BUSY_L : slbit := '0';
  signal RL_DO_L   : slv9  := (others=>'0');
  signal RL_VAL_L  : slbit := '0';

  signal L2B_GO    : slbit := '0';
  signal L2B_CMD  : slv2 := (others=>'0');
  signal B2L_WDONE : slbit := '0';

begin

  -- allow 11 bit (1 x 18kbit BRAM) to 15 bit (8 x 36 kbit BRAMs)
  assert RTAWIDTH>=11 and RTAWIDTH<=14
    report "assert(RTAWIDTH>=11 and RTAWIDTH<=15): unsupported RTAWIDTH"
    severity failure;

  RTBUF : ram_2swsr_rfirst_gen
    generic map (
      AWIDTH => RTAWIDTH,
      DWIDTH =>  8)
    port map (
      CLKA  => CLK,
      CLKB  => CLK,
      ENA   => RTBUF_WEA,               -- port A write only, thus en=we
      ENB   => RTBUF_ENB,
      WEA   => RTBUF_WEA,
      WEB   => RTBUF_WEB,
      ADDRA => R_LREGS.rtaddra,
      ADDRB => R_LREGS.rtaddrb,
      DIA   => RTBUF_DIA,
      DIB   => RTBUF_DIB,
      DOA   => open,
      DOB   => RTBUF_DOB
      );

  DOFIFO : fifo_1c_dram
    generic map (
      AWIDTH => 5,
      DWIDTH => 8)
    port map (
      CLK   => CLK,
      RESET => RESET,
      DI    => DOFIFO_DI,
      ENA   => DOFIFO_ENA,
      BUSY  => open,
      DO    => DOFIFO_DO,
      VAL   => DOFIFO_VAL,
      HOLD  => DOFIFO_HOLD,
      SIZE  => DOFIFO_SIZE
    );
  
  ICRC : crc16                          -- crc generator for input data
    port map (
      CLK   => CLK,
      RESET => CRC_RESET,
      ENA   => ICRC_ENA,
      DI    => RL_DI(d_f_data),
      CRC   => ICRC_OUT
    );

  OCRC : crc16                          -- crc generator for output data
    port map (
      CLK   => CLK,
      RESET => CRC_RESET,
      ENA   => OCRC_ENA,
      DI    => OCRC_IN,
      CRC   => OCRC_OUT
    );

  SEL : rb_sel                          -- rbus address select for config regs
    generic map (
      RB_ADDR => rbaddr,
      SAWIDTH => 2)
    port map (
      CLK     => CLK,
      RB_MREQ => RB_MREQ_L,
      SEL     => RBSEL
    );

  RB_SRES_OR : rb_sres_or_2
    port map (
      RB_SRES_1  => RB_SRES,
      RB_SRES_2  => RB_SRES_CONF,
      RB_SRES_OR => RB_SRES_TOT
    );

  proc_regs: process (CLK)
  begin

    if rising_edge(CLK) then
      if RESET = '1' then
        R_LREGS <= lregs_init;
        R_BREGS <= bregs_init;
        R_CREGS <= cregs_init;
      else
        R_LREGS <= N_LREGS;
        R_BREGS <= N_BREGS;
        R_CREGS <= N_CREGS;
     end if;
    end if;

  end process proc_regs;

  -- link FSM ================================================================

  proc_lnext: process (R_LREGS, R_CREGS, R_BREGS,
                       CE_INT, RL_DI, RL_ENA, RL_HOLD, RB_LAM,
                       ICRC_OUT, OCRC_OUT, RTBUF_DOB,
                       DOFIFO_DO, DOFIFO_VAL,
                       B2L_WDONE)

    variable r : lregs_type := lregs_init;
    variable n : lregs_type := lregs_init;

    variable ival : slbit := '0';
    variable ibusy : slbit := '0';
    variable ido : slv9 := (others=>'0');
    variable crcreset : slbit := '0';
    variable icrcena : slbit := '0';
    variable ocrcena : slbit := '0';
    variable has_attn : slbit := '0';
    variable idi8 : slv8 := (others=>'0');
    variable is_comma : slbit := '0';
    variable comma_typ : slv3 := "000";
    variable idohold : slbit := '0';
    variable cnt_iszero : slbit := '0';
    variable bcnt_load : slbit := '0';
    variable bcnt_val : slv(RTAWIDTH-1 downto 0) := (others=>'0');
    variable bcnt_dec : slbit := '0';
    variable bcnt_end : slbit := '0';
    variable irtwea : slbit := '0';
    variable irtreb : slbit := '0';
    variable irtweb : slbit := '0';
    variable addra_clear : slbit := '0';
    variable addrb_load  : slbit := '0';
    variable addrb_sela  : slbit := '0';
    variable ibcmd : slv2 := (others=>'0');
    variable ibgo  : slbit := '0';

  begin

    r := R_LREGS;
    n := R_LREGS;

    n.moneop  := '0';                   -- default '0', only set by states
    n.monattn := '0';                   -- "

    ival := '0';
    ibusy := '1';                       -- default is to hold input
    ido  := (others=>'0');

    crcreset := '0';
    icrcena  := '0';
    ocrcena  := '0';

    has_attn := '0';

    is_comma  := RL_DI(d_f_cflag);      -- get comma marker
    comma_typ := RL_DI(d_f_ctyp);       -- get comma type
    idi8      := RL_DI(d_f_data);       -- get data part of RL_DI

    idohold := '1';                     -- default is to hold DOFIFO

    cnt_iszero := '0';
    if unsigned(r.cnt(cnt_f_dat)) = 0 then
      cnt_iszero := '1';
    end if;
    
    bcnt_load := '0';
    bcnt_val  := r.cnt(cnt_f_dat) & '0'; -- default: 2*cnt (most used)
    bcnt_dec  := '0';
    bcnt_end  := '0';
    if unsigned(r.bcnt) = 1 then
      bcnt_end := '1';
    end if;

    irtwea  := '0';
    irtreb  := '0';
    irtweb  := '0';
    addra_clear := '0';
    addrb_load  := '0';
    addrb_sela  := '1';           -- default: addra (most used)

    ibcmd := (others=>'0');
    ibgo := '0';

    -- handle attention "LAM's"
    n.attn := r.attn or RB_LAM;

    -- detect attn notify requests
    if unsigned(r.attn) /= 0 then       -- if any of the attn bits set
      has_attn  := '1';
      if R_CREGS.anena='1' and r.arpend='0' then -- if attn to be send
        n.anreq := '1';                      -- set notify request flag
      end if;
    end if;

    -- handle attn read timeouts
    --  atocnt is held in reset when no attn read is pending
    --    counting down in CE_INT cycles till zero
    --    when zero, an attn notify is requested when atoena is set
    --    the attn notify flag will reset atocnt to its start value
    --    --> when atoena='1' this creates a notify every atoval CE_INT periods
    --    --> when atoena='0' atocnt will count to zero and stay there
    
    if r.arpend = '0' or r.anreq = '1' then   -- if no attn read pending
      n.atocnt := R_CREGS.atoval;         -- keep at start value
    else                                -- otherwise
      if CE_INT = '1' then                -- if CE_INT
        if unsigned(r.atocnt) = 0 then      -- alread counted down 
          n.anreq :=  R_CREGS.atoena;         -- request attn notify if enabled
        else                                -- not yet down
          n.atocnt := slv(unsigned(r.atocnt) - 1);  -- decrement
        end if;
      end if;
    end if;
    
    case r.state is

      when sl_idle =>                   -- sl_idle: wait for sop -------------
        bcnt_val := r.rtaddra;            -- used for nak handling
        addrb_sela := '0';
        n.anact    := '0';
        n.doretra := '0';
        crcreset := '1';                  -- reset crc generators
        if r.anreq = '1' then             -- if attn notify requested
          n.anreq  := '0';                  -- acknowledge request
          n.arpend := '1';                  -- mark attn read pending
          n.state := sl_txanot;             -- next: send attn notify
        else
          ibusy := '0';                   -- accept input
          if RL_ENA = '1' then            -- if input
            if is_comma = '1' then          -- if comma
              case comma_typ is
                when c_sop =>                 -- if sop
                  n.cmdseen := '0';             -- clear cmd seen flag
                  n.state := sl_txsop;          -- next: echo it
                when c_attn =>                -- if attn
                  n.state := sl_txanot;         -- next: send attn notify
                when c_nak =>
                  addrb_load := '1';
                  bcnt_load  := '1';
                  n.doretra  := '1';
                  n.state := sl_txsop;          -- next: send sop
                when others => null;          -- other commas: silently ignore
                                                -- especially: eop is ignored
              end case;
            else                             -- if normal data
              n.state := sl_idle;              -- silently dropped
            end if;
          end if;
        end if;

      when sl_txanot =>                 -- sl_txanot: send attn notify -------
        n.cnt := r.attn;                  -- transfer attn to cnt for transmit
        n.anact := '1';                   -- signal attn notify active 
        ido  := c_rlink_dat_attn;         -- send attn symbol
        ival := '1';
        if RL_HOLD = '0' then             -- wait for accept
          n.monattn := '1';                 -- signal on rl_moni
          n.state := sl_txcntl;             -- next: send cnt lsb
        end if;

      when sl_txsop =>                  -- sl_txsop: send sop ----------------
        ido := c_rlink_dat_sop;           -- send sop character
        ival := '1';
        if RL_HOLD = '0' then             -- wait for accept
          if r.doretra = '1' then           -- if retra request
            irtreb := '1';                    -- request first byte
            n.state := sl_txrtbuf;            -- next: send rtbuf
          else                              -- or normal command
            n.state := sl_rxcmd;              -- next: read first command
          end if;
        end if;
        
      when sl_txnak =>                  -- sl_txnak: send nak ----------------
        n.nakdone := '1';                 -- set nakdone flag
        ido := c_rlink_dat_nak;           -- send nak character
        ival := '1';
        if RL_HOLD = '0' then             -- wait for accept
          n.state := sl_txnakcode;          -- next: send nakcode
        end if;
        
      when sl_txnakcode =>              -- sl_txnakcode: send nakcode --------
        ido := '0' & "10" & (not r.nakcode) & r.nakcode;
        ival := '1';
        if RL_HOLD = '0' then             -- wait for accept
          n.state := sl_rxeop;            -- next: wait for eop
        end if;
        
      when sl_rxeop =>                  -- sl_rxeop: wait for eop ------------
        ibusy := '0';                     -- accept input
        if RL_ENA = '1' then
          if is_comma = '1' and comma_typ = c_eop then  -- if eop seen
            n.state  := sl_txeop;          -- next: echo eop
          end if;
        end if;

      when sl_txrtbuf =>                -- sl_txrtbuf: send rtbuf ------------
        ido := '0' & RTBUF_DOB;           -- send rtbuf data
        ival := '1';
        if RL_HOLD = '0' then             -- wait for accept
          bcnt_dec := '1';
          if bcnt_end = '0' then            -- if not yet done
            irtreb := '1';                    -- request next byte
          else                              -- all done
            if r.nakdone = '0' then         -- if no nak active
              n.state := sl_txeop;              -- next: send eop
            else
              n.state := sl_txnak;              -- next: send nak
            end if;
          end if;
        end if;
        
      when sl_txeop =>                  -- sl_txeop: send eop ----------------
        ido := c_rlink_dat_eop;           -- send eop character
        ival := '1';
        if RL_HOLD = '0' then             -- wait for accept
          n.moneop := '1';                  -- signal on rl_moni
          n.state := sl_idle;               -- next: idle state, wait for sop
        end if;
        
       when sl_rxcmd =>                  -- sl_rxcmd: wait for cmd ------------
        ibusy := '0';                      -- accept input
        n.cnt := slv(to_unsigned(1,16));   -- preset cnt=1 (used for rreg)
        n.rcmd := idi8;                    -- latch cmd (follow till valid)
        if RL_ENA = '1' then
          if is_comma = '1' then          -- if comma
            if comma_typ = c_eop then       -- eop seen
              n.state  := sl_txeop;           -- next: echo eop
            else                            -- any other comma seen
              n.nakcode := c_rlink_nakcode_frame; -- signal framing error
              n.state  := sl_txnak;         -- next: send nak
            end if;
          else                            -- if not comma
            if r.cmdseen = '0' then         -- if first cmd
              n.nakdone := '0';               -- clear nakdone flag
              addra_clear := '1';             -- clear rtbuf
            end if;
            n.cmdseen := '1';               -- set cmd seen flag
            icrcena   := '1';               -- update input crc
            case RL_DI(c_rlink_cmd_rbf_code) is
              when c_rlink_cmd_rreg |
                   c_rlink_cmd_rblk |
                   c_rlink_cmd_wreg |
                   c_rlink_cmd_wblk |
                   c_rlink_cmd_init =>      -- for commands needing addr(data)
                n.state := sl_rxaddrl;        -- next: read address lsb
              when c_rlink_cmd_labo |
                   c_rlink_cmd_attn =>      -- labo and attn commands
                n.state := sl_rxccrcl;        -- next: read command crc low
              when others =>
                n.nakcode := c_rlink_nakcode_cmd; -- signal bad cmd
                n.state := sl_txnak;          -- next: send nak
            end case;
          end if;
        end if;

      when sl_rxaddrl =>                -- sl_rxaddrl: wait for addr lsb -----
        ibusy := '0';                     -- accept input
        n.addr(f_byte0) := idi8;          -- latch addr lsb (follow till valid)
        if RL_ENA = '1' then
          if is_comma = '1' then          -- if comma 
            n.nakcode := c_rlink_nakcode_frame; -- signal framing error
            n.state   := sl_txnak;          -- next: send nak,
         else
            icrcena  := '1';              -- update input crc
            n.state := sl_rxaddrh;          -- next: read addr msb
          end if;
        end if;

      when sl_rxaddrh =>                -- sl_rxaddrh: wait for addr msb -----
        ibusy := '0';                     -- accept input
        n.addr(f_byte1) := idi8;          -- latch addr msb (follow till valid)
        if RL_ENA = '1' then
          if is_comma = '1' then          -- if comma
            n.nakcode := c_rlink_nakcode_frame; -- signal framing error
            n.state   := sl_txnak;          -- next: send nak
          else
            icrcena  := '1';              -- update input crc
            case r.rcmd(c_rlink_cmd_rbf_code) is
              when c_rlink_cmd_rreg =>      -- for rreg command
                n.state := sl_rxccrcl;        -- next: read command crc low
              when c_rlink_cmd_wreg |
                   c_rlink_cmd_init =>      -- for wreg, init command
                n.state := sl_rxdatl;         -- next: read data lsb
              when others =>                -- for rblk or wblk
                n.state := sl_rxcntl;         -- next: read count lsb
            end case;
          end if;
        end if;
        
      when sl_rxdatl =>                 -- sl_rxdatl: wait for data low ------
        ibusy := '0';                     -- accept input
        n.din(f_byte0) := idi8;           -- latch data lsb (follow till valid)
        if RL_ENA = '1' then
          if is_comma = '1' then          -- if comma 
            n.nakcode := c_rlink_nakcode_frame; -- signal framing error
            n.state   := sl_txnak;          -- next: send nak
         else
            icrcena  := '1';              -- update input crc
            n.state := sl_rxdath;         -- next: read data msb
          end if;
        end if;
         
      when sl_rxdath =>                 -- sl_rxdath: wait for data high -----
        ibusy := '0';                     -- accept input
        n.din(f_byte1) := idi8;           -- latch data msb (follow till valid)
        if RL_ENA = '1' then
          if is_comma = '1' then          -- if comma
            n.nakcode := c_rlink_nakcode_frame; -- signal framing error
            n.state   := sl_txnak;          -- next: send nak
          else
            icrcena  := '1';              -- update input crc
            n.state := sl_rxccrcl;        -- next: read command crc low
          end if;
        end if;       
         
      when sl_rxcntl =>                 -- sl_rxcntl: wait for count lsb -----
        ibusy := '0';                     -- accept input
        n.cnt(f_byte0) := idi8;           -- latch count lsb (follow till valid)
        if RL_ENA = '1' then
          if is_comma = '1' then            -- if comma
            n.nakcode := c_rlink_nakcode_frame; -- signal framing error
            n.state   := sl_txnak;            -- next: send nak
          else
            icrcena  := '1';              -- update input crc
            n.state := sl_rxcnth;         -- next: read count msb
          end if;
        end if;
       
      when sl_rxcnth =>                 -- sl_rxcnth: wait for count msb -----
        ibusy := '0';                     -- accept input
        n.cnt(f_byte1) := idi8;           -- latch count lsb (follow till valid)
        if RL_ENA = '1' then
          if is_comma = '1' then            -- if comma
            n.nakcode := c_rlink_nakcode_frame; -- signal framing error
            n.state   := sl_txnak;            -- next: send nak
          else
            icrcena  := '1';              -- update input crc
            if unsigned(idi8(7 downto cntawidth-8)) = 0 then  -- if cnt ok
              n.state := sl_rxccrcl;        -- next: read command crc low
            else
              n.nakcode := c_rlink_nakcode_cnt; -- signal bad cnt
              n.state := sl_txnak;              -- next: send nak
            end if;
          end if;
        end if;       

      when sl_rxccrcl =>                -- sl_rxccrcl: wait for command crc low
        ibusy := '0';                     -- accept input
        if RL_ENA = '1' then
          if is_comma = '1' then            -- if comma
            n.nakcode := c_rlink_nakcode_frame;  -- signal framing error
            n.state   := sl_txnak;               -- next: send nak
          else
            if idi8 /= ICRC_OUT(f_byte0) then    -- if crc error (lsb)
              n.nakcode := c_rlink_nakcode_ccrc; -- signal bad ccrc
              n.state := sl_txnak;            -- next: send nak
            else                            -- if crc ok
              n.state := sl_rxccrch;          -- next: wait for command crc high
            end if;
          end if;
        end if;
        
      when sl_rxccrch =>                -- sl_rxccrcl: wait for command crc high
        ibusy := '0';                     -- accept input
        if RL_ENA = '1' then
          if is_comma = '1' then            -- if comma
            n.nakcode := c_rlink_nakcode_frame;  -- signal framing error
            n.state   := sl_txnak;               -- next: send nak
          else
            if idi8 /= ICRC_OUT(f_byte1) then   -- if crc error (msb)
              n.nakcode := c_rlink_nakcode_ccrc; -- signal bad ccrc
              n.state := sl_txnak;            -- next: send nak
            else                            -- if crc ok
              n.state := sl_txcmd;            -- next: echo command
            end if;
          end if;
        end if;
        
      when sl_txcmd =>                  -- sl_txcmd: send cmd -----------------
        ido := '0' & r.rcmd;              -- send read command
        ival := '1';
        if RL_HOLD = '0' then             -- wait for accept
          irtwea  := '1';
          ocrcena := '1';                  -- update output crc
          ibcmd   := c_bcmd_stat;          -- latch external status bits
          ibgo    := '1';

          case r.rcmd(c_rlink_cmd_rbf_code) is -- main command dispatcher
            when c_rlink_cmd_rreg  =>          -- rreg ----------------
              n.state := sl_rstart;              -- next: start rreg
            when c_rlink_cmd_rblk =>           -- rblk ----------------
              n.babo := '0';                    -- clear babo flag
              n.state := sl_txcntl; 
            when c_rlink_cmd_wreg =>           -- wreg ----------------
              ibcmd := c_bcmd_wblk;
              ibgo  := '1';
              n.state := sl_wwait0;              -- next: wait for wdone
            when c_rlink_cmd_wblk =>           -- wblk ----------------
              n.babo := '0';                    -- clear babo flag
              if cnt_iszero = '0' then            -- if cnt /= 0
                n.state := sl_wblk;                 -- next: read wblk data
              else                                -- otherwise cnt = 0
                n.state := sl_rxdcrcl;              -- next: wait for dcrc low
              end if;
            when c_rlink_cmd_labo =>           -- labo ----------------
              n.state := sl_txlabo;
            when c_rlink_cmd_attn =>           -- attn ----------------
              n.state := sl_attn;
            when c_rlink_cmd_init =>           -- init ----------------
              ibcmd := c_bcmd_init;
              ibgo  := '1';
              n.state := sl_txstat;
              
            when others =>                    -- '111' ---------------
              n.nakcode := c_rlink_nakcode_cmd; -- signal bad cmd
              n.state := sl_txnak;              -- send NAK on reserved command
          end case;
        end if;
              
      when sl_txcntl =>                 -- sl_txcntl: send cnt lsb ------------
        ido := '0' & r.cnt(f_byte0);      -- send cnt lsb
        ival := '1';
        if RL_HOLD = '0' then             -- wait for accept
          irtwea := not r.anact;            -- no rtbuf for attn notify
          ocrcena  := '1';                  -- update output crc
          n.state  := sl_txcnth;            -- next: send cnt msb
        end if;

      when sl_txcnth =>                 -- sl_txcnth: send cnt msb ------------
        ido := '0' & r.cnt(f_byte1);      -- send cnt msb
        ival := '1';
        if RL_HOLD = '0' then             -- wait for accept
          irtwea := not r.anact;            -- no rtbuf for attn notify
          ocrcena  := '1';                  -- update output crc
          if r.anact = '1' then              -- if in attn notify
            n.state := sl_txcrcl;             -- next: send crc low
          elsif r.rcmd(c_rlink_cmd_rbf_code) = c_rlink_cmd_rblk then -- if rblk
            if cnt_iszero = '0' then            -- if cnt /= 0
              n.state := sl_rstart;               -- next: start rblk
            else                                -- otherwise cnt = 0
              n.state := sl_txdcntl;              -- next: send dcnt lsb
            end if;
          else                                -- otherwise, must be attn
            n.state  := sl_txstat;            -- next: send stat
          end if;
        end if;

      when sl_rstart =>                 -- sl_rstart: start rreg or rblk -----
        ibcmd := c_bcmd_rblk;
        ibgo  := '1';
        bcnt_load := '1';
        bcnt_val  := r.cnt(cnt_f_dat) & '0';   -- 2*cnt
        n.state := sl_txdat;           

      when sl_txdat =>                  -- sl_txdat: send data ---------------
        ido := '0' & DOFIFO_DO;
        if DOFIFO_VAL = '1'  then         -- wait for input
          ival := '1';
          if RL_HOLD = '0' then             -- wait for accept
            idohold := '0';
            irtwea  := '1';
            ocrcena := '1';                   -- update output crc
            bcnt_dec := '1';
            if bcnt_end = '1' then
              if r.rcmd(c_rlink_cmd_rbf_code) = c_rlink_cmd_rblk then -- if rblk
                n.state := sl_txdcntl;
              else
                n.state := sl_txstat;
              end if;
            end if;
          end if;
        end if;
        
      when sl_wblk =>                   -- sl_wblk: setup rx wblk data -------
        addrb_load := '1';                -- must be done here because addra
        addrb_sela := '1';                -- is incremented in _txcmd 
        bcnt_load  := '1';
        bcnt_val   := r.cnt(cnt_f_dat) & '0';   -- 2*cnt
        n.state := sl_rxwblk;
        
      when sl_rxwblk =>                 -- sl_rxwblk: wait for wblk data -----
        ibusy := '0';                     -- accept input
        if RL_ENA = '1' then
          if is_comma = '1' then            -- if comma
            n.nakcode := c_rlink_nakcode_frame; -- signal framing error
            n.state   := sl_txnak;            -- next: send nak
          else
            icrcena := '1';               -- update input crc
            irtweb  := '1';               -- write into rtbuf via b port
            bcnt_dec := '1';
            if bcnt_end = '1' then        -- if all done
              n.state := sl_rxdcrcl;        -- next: wait for data crc low
            end if;
          end if;
        end if;

      when sl_rxdcrcl =>                -- sl_rxdcrcl: wait for data crc low -
        ibusy := '0';                     -- accept input
        bcnt_val  := r.cnt(cnt_f_dat) & '0';   -- 2 * cnt
        addrb_sela := '1';
        if RL_ENA = '1' then
          if is_comma = '1' then            -- if comma
            n.nakcode := c_rlink_nakcode_frame;  -- signal framing error
            n.state   := sl_txnak;               -- next: send nak
          else
            if idi8 /= ICRC_OUT(f_byte0) then    -- if crc error lsb
              n.nakcode := c_rlink_nakcode_dcrc; -- signal bad dcrc
              n.state := sl_txnak;            -- next: send nak
            else                            -- if crc ok
              n.state := sl_rxdcrch;           -- next: wait for data crc high
            end if;
          end if;
        end if;
        
      when sl_rxdcrch =>                -- sl_rxdcrch: wait for data crc high
        ibusy := '0';                     -- accept input
        bcnt_val  := r.cnt(cnt_f_dat) & '0';   -- 2 * cnt
        addrb_sela := '1';
        if RL_ENA = '1' then
          if is_comma = '1' then            -- if comma
            n.nakcode := c_rlink_nakcode_frame;  -- signal framing error
            n.state   := sl_txnak;               -- next: send nak
          else
            if idi8 /= ICRC_OUT(f_byte1) then    -- if crc error msb
              n.nakcode := c_rlink_nakcode_dcrc; -- signal bad dcrc
              n.state := sl_txnak;            -- next: send nak
            else                            -- if crc ok
              addrb_load := '1';
              bcnt_load  := '1';
              if r.rtaddrb_bad = '0' then     -- if rtbuf ok
                n.state := sl_wblk0;            -- next: start wblk pipe
              else                            -- else rtbuf ovfl
                n.nakcode := c_rlink_nakcode_rtwblk; -- signal ovfl in wblk
                n.state := sl_txnak;            -- next: send nak
              end if;
            end if;
          end if;
        end if;
        
      when sl_wblk0 =>                  -- sl_wblk0: start wblk pipe ---------
        if cnt_iszero = '0' then            -- if cnt /= 0
          irtreb := '1';                    -- request next byte
          n.state := sl_wblk1;              -- next: start data lsb
        else                                -- otherwise cnt = 0
          n.state := sl_txdcntl;              -- next: send dcnt lsb
        end if;
        
      when sl_wblk1 =>                  -- sl_wblk1: start wblk data lsb -----
        n.dinl := RTBUF_DOB;              -- latch data lsb
        irtreb := '1';                    -- request next byte
        bcnt_dec := '1';
        n.state := sl_wblk2;              -- next: start data msb
        
      when sl_wblk2 =>                  -- sl_wblk2: start wblk data msb -----
        n.din := RTBUF_DOB & r.dinl;      -- setup din
        bcnt_dec := '1';
        ibcmd := c_bcmd_wblk;             -- start rbus sequencer
        ibgo  := '1';
        if bcnt_end = '0' then            -- if not yet done
          irtreb := '1';                    -- request next byte
          n.state := sl_wblkl;              -- next: enter wblk pipe
        else                              -- all done
          n.state := sl_wwait0;             -- next: wait for wdone
        end if;

      when sl_wblkl =>                  -- sl_wblkl: pipe wblk data lsb ------
        n.dinl := RTBUF_DOB;              -- latch data lsb
        irtreb := '1';                    -- request next byte
        bcnt_dec := '1';
        n.state := sl_wblkh;              -- next: pipe msb
        
      when sl_wblkh =>                  -- sl_wblkh: pipe wblk data msb ------
        if B2L_WDONE = '1' then           -- if last write done
          n.din := RTBUF_DOB & r.dinl;      -- setup next din
          bcnt_dec := '1';
          if bcnt_end = '0' then            -- if not yet done
            irtreb := '1';
            n.state := sl_wblkl;              -- next: pipe lsb
          else                              -- all done
            n.state := sl_wwait0;             -- next: wait last wdone
          end if;
        end if;
        
      when sl_wwait0 =>                 -- sl_wwait0: wait for wdone ---------
        if B2L_WDONE = '1' then
          if r.rcmd(c_rlink_cmd_rbf_code) = c_rlink_cmd_wblk then  -- if wblk
            n.state := sl_wwait1;             -- next: wait for dcnt
          else
            n.state := sl_txstat;             -- next: send stat
          end if;
        end if;
        
      when sl_wwait1 =>                 -- sl_wwait1: wait for dcnt ----------
        n.state := sl_txdcntl;            -- next: send dcnt lsb

      when sl_txdcntl =>                -- sl_txdcntl: send dcnt lsb ---------
        n.babo := R_BREGS.blkabo;         -- remember blk abort
        ido := '0' & R_BREGS.dcnt(f_byte0); -- send dcnt lsb
        ival := '1';
        if RL_HOLD = '0' then             -- wait for accept
          irtwea := '1';
          ocrcena  := '1';                -- update output crc
          n.state := sl_txdcnth;          -- next: send dcnt msb
        end if;
        
      when sl_txdcnth =>                -- sl_txdcnth: send dcnt msb ---------
        ido := (others=>'0');             -- send dcnt msb
        ido(cntawidth-9 downto 0) := R_BREGS.dcnt(cntawidth-1 downto 8);
        ival := '1';
        if RL_HOLD = '0' then             -- wait for accept
          irtwea := '1';
          ocrcena  := '1';                -- update output crc
          n.state := sl_txstat;           -- next: send stat
        end if;
        
      when sl_txlabo =>                 -- sl_txlabo: send labo flag ---------
        ido := '0' & "0000000" & r.babo;   -- send babo
        ival := '1';
        if RL_HOLD = '0' then             -- wait for accept
          irtwea := '1';
          ocrcena  := '1';                -- update output crc
          n.state := sl_txstat;           -- next: send stat
        end if;
        
      when sl_attn =>                   -- sl_attn: handle attention flags ---
        n.cnt := r.attn;                  -- use cnt to latch attn status
        n.attn := RB_LAM;                 -- LAM in current cycle send next time
        n.arpend := '0';                  -- reenable attn nofification
        n.anreq := '0';                   -- cancel pending notify requests
        n.state := sl_txcntl;             -- next: send cnt lsb (holding attn)
        
      when sl_txstat =>                 -- sl_txstat: send status ------------
        ido(c_rlink_stat_rbf_stat)   := R_BREGS.stat;
        ido(c_rlink_stat_rbf_attn)   := has_attn;
        ido(c_rlink_stat_rbf_rbtout) := R_BREGS.rbtout;
        ido(c_rlink_stat_rbf_rbnak)  := R_BREGS.rbnak;
        ido(c_rlink_stat_rbf_rberr)  := R_BREGS.rberr;
        ival := '1';
        if RL_HOLD  ='0' then             -- wait for accept
          irtwea := '1';
          ocrcena  := '1';                -- update output crc
          n.state := sl_txcrcl;           -- next: send crc low
        end if;
        
      when sl_txcrcl =>                 -- sl_txcrcl: send crc low -----------
        ido := "0" & OCRC_OUT(f_byte0);   -- send crc code low
        ival := '1';
        if RL_HOLD = '0' then             -- wait for accept
          irtwea := not r.anact;            -- no rtbuf for attn notify
          n.state := sl_txcrch;             -- next: send crc high
        end if;

      when sl_txcrch =>                 -- sl_txcrch: send crc high ----------
        ido := "0" & OCRC_OUT(f_byte1);   -- send crc code high
        -- here check for rtbuf overflow
        -- if space for 1 byte complete command and write crc
        if r.rtaddra_red = '0' then       -- if space for 1 byte
          n.lcmd  := r.rcmd;                -- latch current command in lcmd
          ival := '1';
          if RL_HOLD = '0' then             -- wait for accept
            irtwea := not r.anact;            -- no rtbuf for attn notify
            -- if this was attn notify, back to idle
            if r.anact = '1' then
              n.state := sl_txeop;           -- next: send eop
            -- here handle labo: if labo cmd and babo set, eat rest of list
            elsif r.rcmd(c_rlink_cmd_rbf_code)=c_rlink_cmd_labo and
                  r.babo='1' then
              n.state := sl_rxeop;              -- next: wait for eop
            else
              n.state := sl_rxcmd;              -- next: read command or eop
            end if;
          end if;
        else
          n.nakcode := c_rlink_nakcode_rtovfl; -- signal rtbuf ovfl
          n.state := sl_txnak;            -- next: send nak
        end if;

      when others => null;              -- <> --------------------------------

    end case;

    -- addra logic (write pointer)
    if addra_clear = '1' then           -- clear
      n.rtaddra := (others=>'0');
      n.rtaddra_red := '0';
      n.rtaddra_bad := '0';
    else
      if irtwea = '1' then                -- inc when write on port a
        if r.rtaddra_red = '1' then         -- if already red
          n. rtaddra_bad := '1';              -- than flag bad
        else                                -- still ok
          n.rtaddra := slv(unsigned(r.rtaddra) + 1);  -- inc
          if r.rtaddra = rtaddr_tred then             -- if inc'ed to red
            n. rtaddra_red := '1';                      -- flag red
          end if;
        end if;
      end if;
    end if;

    -- addrb logic (write and read pointer)
    if addrb_load = '1' then            -- load
      if addrb_sela = '1' then
        n.rtaddrb := r.rtaddra;
        n.rtaddrb_red := r.rtaddra_red;
        n.rtaddrb_bad := r.rtaddra_bad;
      else
        n.rtaddrb := (others=>'0');
        n.rtaddrb_red := '0';
        n.rtaddrb_bad := '0';
      end if;
    else
      if irtreb = '1' or irtweb = '1' then  -- inc when read/write on port b
        if r.rtaddrb_red = '1' then           -- if already red
          n. rtaddrb_bad := '1';                -- than flag bad
        else                                  -- still ok
          n.rtaddrb := slv(unsigned(r.rtaddrb) + 1);  -- inc
          if r.rtaddrb = rtaddr_tred then             -- if inc'ed to red
            n. rtaddrb_red := '1';                      -- flag red
          end if;
        end if;
      end if;
    end if;

    -- bcnt logic
    if bcnt_load = '1' then
      n.bcnt := bcnt_val;
    else
      if bcnt_dec ='1' then
        n.bcnt := slv(unsigned(r.bcnt) - 1);
      end if;
    end if;

    N_LREGS <= n;

    RL_BUSY_L <= ibusy;
    RL_DO_L   <= ido;
    RL_VAL_L  <= ival;

    RL_MONI.eop  <= r.moneop;
    RL_MONI.attn <= r.monattn;
    RL_MONI.lamp <= r.arpend;

    DOFIFO_HOLD <= idohold;
    
    RTBUF_WEA <= irtwea;
    RTBUF_DIA <= ido(d_f_data);
    RTBUF_ENB <= irtreb or irtweb;
    RTBUF_WEB <= irtweb;
    RTBUF_DIB <= idi8;
    
    CRC_RESET <= crcreset;
    ICRC_ENA  <= icrcena;
    OCRC_ENA  <= ocrcena;
    OCRC_IN   <= ido(d_f_data);

    L2B_CMD <= ibcmd;
    L2B_GO  <= ibgo;
    
  end process proc_lnext;
  
  -- bus FSM =================================================================

  proc_bnext: process (R_BREGS, R_LREGS,
                       RB_STAT, RB_SRES_TOT,
                       DOFIFO_SIZE,
                       L2B_CMD, L2B_GO)

    variable r : bregs_type := bregs_init;
    variable n : bregs_type := bregs_init;

    variable bto_go : slbit := '0';
    variable bto_end : slbit := '0';
    variable cnt_load : slbit := '0';
    variable cnt_dec  : slbit := '0';
    variable cnt_end  : slbit := '0';
    variable dcnt_clear : slbit := '0';
    variable dcnt_inc   : slbit := '0';
    variable ival   : slbit := '0';
    variable ido    : slv8 := (others=>'0');
    variable iwdone : slbit := '0';
    
  begin

    r := R_BREGS;
    n := R_BREGS;

    bto_go := '0';                      -- default: keep rbus timeout in reset
    bto_end := '0';
    if unsigned(r.btocnt) = 0 then      -- if rbus timeout count at zero
      bto_end := '1';                   -- signal expiration
    end if;

    cnt_load := '0';
    cnt_dec  := '0';
    cnt_end  := '0';
    if unsigned(r.cnt) = 0 then
      cnt_end := '1';
    end if;

    dcnt_clear := '0';
    dcnt_inc   := '0';

    ival := '0';
    ido  := (others=>'0');
    
    iwdone := '0';

    -- FIXME: what is proper almost full limit ?
    if unsigned(DOFIFO_SIZE) >= 28 then   -- almost full
      n.wfifo := '1';
    elsif unsigned(DOFIFO_SIZE) <= 2 then -- almost empty
      n.wfifo := '0';
    end if;
    
    n.rbinit  := '0';                   -- clear rb(init|aval|re|we) by default
    n.rbaval  := '0';                   --   they must always be set by the
    n.rbre    := '0';                   --   'previous state'
    n.rbwe    := '0';                   -- 

    case r.state is

      when sb_idle =>                   -- sb_idle: wait for cmd ------------
        if L2B_GO = '1' then              -- if cmd seen 
          n.stat := RB_STAT;                -- always latch external status bits
          n.rbtout := '0';
          n.rbnak  := '0';
          n.rberr  := '0';
          n.blkabo := '0';
          n.dathpend := '0';
          dcnt_clear := '1';
          cnt_load := '1';
          case L2B_CMD is
            when c_bcmd_stat =>           -- stat ---------------------
              null;                         -- nothing else todo
            when c_bcmd_init =>           -- init ---------------------
              n.rbinit := '1';              -- send init pulse
            when c_bcmd_rblk =>           -- rblk ---------------------
              n.rbaval := '1';              -- start aval chunk
              n.state := sb_rstart;         -- next: start rblk
            when c_bcmd_wblk =>           -- wblk ---------------------
              n.rbaval := '1';              -- start aval chunk
              n.state := sb_wstart;         -- next: start wblk
            when others => null;
          end case;
        end if;

      when sb_rstart =>                 -- sb_rstart: start rblk -------------
        n.rbaval := '1';                  -- extend aval
        n.rbre := '1';                    -- start read cycle
        n.state := sb_rreg0;              -- next: do rreg

      when sb_rreg0 =>                  -- sb_rreg0: rbus read cycle ---------
        ido  := r.rbdout(f_byte1); 
        n.stat := RB_STAT;                -- follow external status bits
        if r.dathpend = '1' then          -- if pending data msb
          ival := '1';
          n.dathpend := '0';
        end if;
        n.rbaval := '1';                  -- extend aval
        bto_go := '1';                    -- activate rbus timeout counter
        if RB_SRES_TOT.err = '1' then       -- latch rbus error flag
          n.rberr  := '1';
          n.blkabo := '1';
        end if;
        n.rbdout := RB_SRES_TOT.dout;       -- latch data (follow till valid)
        if RB_SRES_TOT.busy='0' or bto_end='1' then -- wait non-busy or timeout
          if RB_SRES_TOT.busy='1' and bto_end='1' then -- if timeout and busy
            n.rbtout := '1';                    -- set rbus timeout flag
            n.blkabo := '1';
          elsif RB_SRES_TOT.ack = '0' then    -- if non-busy and no ack
            n.rbnak := '1';                     -- set rbus nak flag            
            n.blkabo := '1';
          end if;
          cnt_dec := '1';
          n.state := sb_rreg1;              -- next: send data lsb
        else                              -- otherwise rbus read continues
          n.rbre   := '1';                  -- extend read cycle
        end if;        
        
      when sb_rreg1 =>                  -- sb_rreg1: send read data ----------
        ido  := r.rbdout(f_byte0);
        ival := '1';                      -- send lsb
        n.dathpend := '1';                -- signal mdb pending
        dcnt_inc := not r.blkabo;         -- inc dcnt if no error
        if cnt_end = '0' then             -- if not yet done
          if r.blkabo = '0' then            -- if no errors
            if r.wfifo = '0' then             -- if fifo fine
              n.rbaval := '1';                  -- extend aval
              n.rbre := '1';                    -- start read cycle
              n.state := sb_rreg0;              -- next: do rreg
            else                              -- fifo is full
              n.state := sb_rwait;              -- next: fifo wait
            end if;
          else                              -- errors seen, rblk abort
            n.state := sb_rabo1;              -- next: send rblk abort msb data
          end if;
        else                              -- all done
          n.state := sb_rend;
        end if;

      when sb_rwait =>                  -- sb_rwait: wait for fifo -----------
        if r.wfifo = '0' then             -- if fifo fine
          n.rbaval := '1';                  -- start aval chunk
          n.state := sb_rstart;             -- restart rblk
        end if;
        
      when sb_rend =>                   -- sb_rend: send last read data ------
        ido  := r.rbdout(f_byte1);
        ival := '1';                      -- send msb
        n.dathpend := '0';
        n.state := sb_idle;               -- next: idle
        
      when sb_rabo0 =>                  -- sb_rabo0: rblk abort, lsb data ----
        ido  := (others=>'0');
        ival := '1'; 
        cnt_dec := '1';
        n.state := sb_rabo1;              -- next: send rblk abort, msb data

      when sb_rabo1 =>                  -- sb_rabo1: rblk abort, msb data ----
        ido  := (others=>'0');
        if r.wfifo = '0' then
          n.dathpend := '0';              -- cancel msb pend
          ival := '1'; 
          if cnt_end = '0' then           -- if not yet done
            n.state := sb_rabo0;            -- next: send rblk abort, lsb data
          else                            -- all done
            n.state := sb_idle;             -- next: idle
          end if;
        end if;
        
      when sb_wstart =>                 -- sb_wstart: start wblk
        n.rbaval := '1';                  -- start aval chunk
        n.rbwe := '1';                    -- start write cycle
        n.state := sb_wreg0;

      when sb_wreg0 =>                  -- sb_wreg0: rbus write cycle
        n.stat := RB_STAT;                -- follow external status bits
        n.rbaval := '1';                  -- extend aval
        bto_go := '1';                    -- activate rbus timeout counter
        if RB_SRES_TOT.err = '1' then     -- latch rbus error flag
          n.rberr  := '1';
          n.blkabo := '1';
        end if;
        if RB_SRES_TOT.busy='0' or bto_end='1' then -- wait non-busy or timeout
          if RB_SRES_TOT.busy='1' and bto_end='1' then -- if timeout and busy
            n.rbtout := '1';                     -- set rbus timeout flag
            n.blkabo := '1';
          elsif RB_SRES_TOT.ack='0' then       -- if non-busy and no ack
            n.rbnak := '1';                      -- set rbus nak flag            
            n.blkabo := '1';
          end if;
          cnt_dec := '1';
          iwdone := '1';
          n.state := sb_wreg1;
        else                              -- otherwise rbus write continues
          n.rbwe   := '1';                  -- extend write cycle
        end if;
        
      when sb_wreg1 =>                  -- sb_wreg1: wait write data
        dcnt_inc := not r.blkabo;         -- inc dcnt if no error
        if cnt_end = '0' then             -- if not yet done
          if r.blkabo = '0' then            -- if no errors
            n.rbaval := '1';                  -- extend aval
            n.rbwe := '1';                    -- start write cycle
            n.state := sb_wreg0;
          else                              -- errors seen, rblk abort
            n.state := sb_wabo0;              -- next: drop wblk rest
          end if;
        else                              -- all done
          n.state := sb_idle;               -- next: idle
        end if;
        
      when sb_wabo0 =>                  -- sb_wabo0: wblk abort, drop data --
        iwdone := '1';                    -- drop data
        cnt_dec := '1';
        n.state := sb_wabo1;              -- next: wblk abort, wair

      when sb_wabo1 =>                  -- sb_wabo1: wblk abort, wait --------
        if cnt_end = '0' then             -- if not yet done
          n.state := sb_wabo0;              -- next: wblk abort, drop 
        else                              -- all done
          n.state := sb_idle;               -- next: idle
        end if;
        
      when others => null;              -- <> --------------------------------

    end case;
    
    if bto_go = '0' then                -- handle access timeout counter
      n.btocnt := btocnt_init;          -- if bto_go=0, keep in reset
    else
      n.btocnt := slv(unsigned(r.btocnt) - 1);-- otherwise count down
    end if;

    if cnt_load = '1' then
      n.cnt := R_LREGS.cnt(cnt_f_dat);
    else
      if cnt_dec ='1' then
        n.cnt := slv(unsigned(r.cnt) - 1);
      end if;
    end if;

    if dcnt_clear = '1' then
      n.dcnt := (others=>'0');
    else
      if dcnt_inc ='1' then
        n.dcnt := slv(unsigned(r.dcnt) + 1);
      end if;
    end if;

    N_BREGS <= n;

    DOFIFO_DI  <= ido;
    DOFIFO_ENA <= ival;

    B2L_WDONE <= iwdone;
    
  end process proc_bnext;

  -- config rbus iface =======================================================

  proc_cnext: process (R_CREGS, R_LREGS, RBSEL, RB_MREQ_L)

    variable r : cregs_type := cregs_init;
    variable n : cregs_type := cregs_init;
    variable irb_ack  : slbit := '0';
    variable irb_dout : slv16 := (others=>'0');

  begin

    r := R_CREGS;
    n := R_CREGS;

    irb_ack  := '0';
    irb_dout := (others=>'0');

    -- rbus transactions
    if RBSEL = '1' then
      irb_ack := RB_MREQ_L.re or RB_MREQ_L.we;

      -- config register writes
      if RB_MREQ_L.we = '1' then 
        case RB_MREQ_L.addr(1 downto 0) is
          when rbaddr_cntl =>
            n.anena  := RB_MREQ_L.din(cntl_rbf_anena);
            n.atoena := RB_MREQ_L.din(cntl_rbf_atoena);
            n.atoval := RB_MREQ_L.din(cntl_rbf_atoval);
          when others => null;
        end case;
      end if;

      -- rbus output driver
      case RB_MREQ_L.addr(1 downto 0) is
        when rbaddr_cntl =>
          irb_dout(cntl_rbf_anena)  := r.anena;
          irb_dout(cntl_rbf_atoena) := r.atoena;
          irb_dout(cntl_rbf_atoval) := r.atoval;
        when rbaddr_stat =>
          irb_dout(stat_rbf_lcmd)   := R_LREGS.lcmd;
          irb_dout(stat_rbf_babo)   := R_LREGS.babo;
          irb_dout(stat_rbf_arpend) := R_LREGS.arpend;
          irb_dout(stat_rbf_rbsize) := slv(to_unsigned(RTAWIDTH-10,3));
        when rbaddr_id0  =>
          irb_dout := SYSID(15 downto  0);
        when rbaddr_id1  =>
          irb_dout := SYSID(31 downto 16);
        when others => null;
      end case;
 
    end if;

    N_CREGS <= n;

    RB_SRES_CONF.dout <= irb_dout;
    RB_SRES_CONF.ack  <= irb_ack;
    RB_SRES_CONF.err  <= '0';
    RB_SRES_CONF.busy <= '0';

  end process proc_cnext;

  -- rbus driver -----------------------------------------------------

  proc_mreq: process (R_LREGS, R_BREGS)
  begin

    RB_MREQ_L      <= rb_mreq_init;
    RB_MREQ_L.aval <= R_BREGS.rbaval;
    RB_MREQ_L.re   <= R_BREGS.rbre;
    RB_MREQ_L.we   <= R_BREGS.rbwe;
    RB_MREQ_L.init <= R_BREGS.rbinit;
    RB_MREQ_L.addr <= R_LREGS.addr;
    RB_MREQ_L.din  <= R_LREGS.din;

  end process proc_mreq;

  RB_MREQ <= RB_MREQ_L;

  RL_BUSY <= RL_BUSY_L;
  RL_DO   <= RL_DO_L;
  RL_VAL  <= RL_VAL_L;
  
-- synthesis translate_off

  RLMON: if ENAPIN_RLMON >= 0  generate
    MON : rlink_mon_sb
      generic map (
        DWIDTH => RL_DI'length,
        ENAPIN => ENAPIN_RLMON)
      port map (
        CLK     => CLK,
        RL_DI   => RL_DI,
        RL_ENA  => RL_ENA,
        RL_BUSY => RL_BUSY_L,
        RL_DO   => RL_DO_L,
        RL_VAL  => RL_VAL_L,
        RL_HOLD => RL_HOLD
      );
  end generate RLMON;

  RBMON: if ENAPIN_RBMON >= 0  generate
    MON : rb_mon_sb
      generic map (
        DBASE  => 8,
        ENAPIN => ENAPIN_RBMON)
      port map (
        CLK     => CLK,
        RB_MREQ => RB_MREQ_L,
        RB_SRES => RB_SRES_TOT,
        RB_LAM  => RB_LAM,
        RB_STAT => RB_STAT
      );
  end generate RBMON;
  
-- synthesis translate_on

end syn;
