-- $Id: ibd_ibmon.vhd 672 2015-05-02 21:58:28Z mueller $
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
-- Module Name:    ibd_ibmon - syn
-- Description:    ibus dev: ibus monitor
--
-- Dependencies:   memlib/ram_1swsr_wfirst_gen
--
-- Test bench:     -
--
-- Target Devices: generic
-- Tool versions:  xst 14.7; viv 2014.4; ghdl 0.31
--
-- Synthesized (xst):
-- Date         Rev  ise         Target      flop lutl lutm slic t peri
-- 2015-04-24   668 14.7  131013 xc6slx16-2   112  235    0   83 s  5.6
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2015-05-02   672   1.0.1  use natural for AWIDTH to work around a ghdl issue
-- 2015-04-24   668   1.0    Initial version (derived from rbd_rbmon)
------------------------------------------------------------------------------
--
-- Addr   Bits  Name        r/w/f  Function
--  000         cntl        r/w/f  Control register
--          05    conena    r/w/-    con enable
--          04    remena    r/w/-    rem enable
--          03    locena    r/w/-    loc enable
--          02    wena      r/w/-    wrap enable
--          01    stop      r/w/f    writing 1 stops  moni
--          00    start     r/w/f    writing 1 starts moni and clears addr
--  001         stat        r/w/-  Status register
--       15:13    bsize     r/-/-    buffer size (AWIDTH-9)
--          00    wrap      r/-/-    line address wrapped (cleared on go)
--  010  12:01  hilim       r/w/-  upper address limit, inclusive (def: 177776)
--  011  12:01  lolim       r/w/-  lower address limit, inclusive (def: 160000)
--  100         addr        r/w/-  Address register
--        *:02    laddr     r/w/-    line address
--       01:00    waddr     r/w/-    word address
--  101         data        r/w/-  Data register
--
--     data format:
--     word 3     15 : burst      (2nd re/we in a aval sequence)
--                14 : tout       (busy in last re-we cycle)
--                13 : nak        (no ack in last non-busy cycle)
--                12 : ack        (ack  seen)
--                11 : busy       (busy seen)
--                10 : --         (reserved in case err is implemented)
--                09 : we         (write cycle)
--                08 : rmw        (read-modify-write)
--             07:00 : delay to prev (msb's)
--     word 2  15:10 : delay to prev (lsb's)
--             09:00 : number of busy cycles
--     word 1        : data
--     word 0     15 : be1        (byte enable low)
--                14 : be0        (byte enable high)
--                13 : racc       (remote access)
--             12:01 : addr       (word address)
--                 0 : cacc       (console access)
-- 


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.memlib.all;
use work.iblib.all;

-- Note: AWIDTH has type natural to allow AWIDTH=0 can be used in if generates
--       to control the instantiation. ghdl checks even for not instantiated
--       entities the validity of generics, that's why natural needed here ....

entity ibd_ibmon is                     -- ibus dev: ibus monitor
  generic (
    IB_ADDR : slv16 := slv(to_unsigned(8#160000#,16));  -- base address
    AWIDTH : natural := 9);                             -- buffer size
  port (
    CLK  : in slbit;                    -- clock
    RESET : in slbit;                   -- reset
    IB_MREQ : in ib_mreq_type;          -- ibus: request
    IB_SRES : out ib_sres_type;         -- ibus: response
    IB_SRES_SUM : in ib_sres_type       -- ibus: response (sum for monitor)
  );
end entity ibd_ibmon;


architecture syn of ibd_ibmon is

  constant ibaddr_cntl  : slv3 := "000";   -- cntl  address offset
  constant ibaddr_stat  : slv3 := "001";   -- stat  address offset
  constant ibaddr_hilim : slv3 := "010";   -- hilim address offset
  constant ibaddr_lolim : slv3 := "011";   -- lolim address offset
  constant ibaddr_addr  : slv3 := "100";   -- addr  address offset
  constant ibaddr_data  : slv3 := "101";   -- data  address offset

  constant cntl_ibf_conena   : integer :=     5;
  constant cntl_ibf_remena   : integer :=     4;
  constant cntl_ibf_locena   : integer :=     3;
  constant cntl_ibf_wena     : integer :=     2;
  constant cntl_ibf_stop     : integer :=     1;
  constant cntl_ibf_start    : integer :=     0;
  subtype  stat_ibf_bsize   is integer range 15 downto 13;
  constant stat_ibf_wrap     : integer :=     0;
  subtype  addr_ibf_laddr   is integer range 2+AWIDTH-1 downto  2;
  subtype  addr_ibf_waddr   is integer range  1 downto  0;

  subtype  iba_ibf_pref     is integer range 15 downto 13;
  subtype  iba_ibf_addr     is integer range 12 downto  1;

  constant dat3_ibf_burst    : integer :=    15;
  constant dat3_ibf_tout     : integer :=    14;
  constant dat3_ibf_nak      : integer :=    13;
  constant dat3_ibf_ack      : integer :=    12;
  constant dat3_ibf_busy     : integer :=    11;
  constant dat3_ibf_we       : integer :=     9;
  constant dat3_ibf_rmw      : integer :=     8;
  subtype  dat3_ibf_ndlymsb is integer range  7 downto  0;
  subtype  dat2_ibf_ndlylsb is integer range 15 downto 10;
  subtype  dat2_ibf_nbusy   is integer range  9 downto  0;
  constant dat0_ibf_be1      : integer :=    15;
  constant dat0_ibf_be0      : integer :=    14;
  constant dat0_ibf_racc     : integer :=    13;
  subtype  dat0_ibf_addr    is integer range 12 downto  1;
  constant dat0_ibf_cacc     : integer :=     0;

  type regs_type is record              -- state registers
    ibsel : slbit;                      -- ibus select
    conena : slbit;                     -- conena flag (record console access)
    remena : slbit;                     -- remena flag (record remote access)
    locena : slbit;                     -- locena flag (record local access)
    wena : slbit;                       -- wena flag (wrap enable)
    go : slbit;                         -- go flag
    hilim : slv13_1;                    -- upper address limit
    lolim : slv13_1;                    -- lower address limit
    wrap : slbit;                       -- laddr wrap flag
    laddr : slv(AWIDTH-1 downto 0);     -- line address
    waddr : slv2;                       -- word address
    ibtake_1 : slbit;                   -- ib capture active in last cycle
    ibaddr  : slv13_1;                  -- ibus trace: addr
    ibwe    : slbit;                    -- ibus trace: we
    ibrmw   : slbit;                    -- ibus trace: rmw
    ibbe0   : slbit;                    -- ibus trace: be0
    ibbe1   : slbit;                    -- ibus trace: be1
    ibcacc  : slbit;                    -- ibus trace: cacc
    ibracc  : slbit;                    -- ibus trace: racc
    iback   : slbit;                    -- ibus trace: ack  seen
    ibbusy  : slbit;                    -- ibus trace: busy seen
    ibnak   : slbit;                    -- ibus trace: nak  detected
    ibtout  : slbit;                    -- ibus trace: tout detected
    ibburst : slbit;                    -- ibus trace: burst detected
    ibdata  : slv16;                    -- ibus trace: data
    ibnbusy : slv10;                    -- ibus number of busy cycles
    ibndly  : slv14;                    -- ibus delay to prev. access
  end record regs_type;

  constant laddrzero : slv(AWIDTH-1 downto 0) := (others=>'0');
  constant laddrlast : slv(AWIDTH-1 downto 0) := (others=>'1');
  
  constant regs_init : regs_type := (
    '0',                                -- ibsel
    '1','1','1','1','1',                -- conena,remena,locena,wena,go
    (others=>'1'),                      -- hilim (def: 177776)
    (others=>'0'),                      -- lolim (def: 160000)
    '0',                                -- wrap
    laddrzero,                          -- laddr
    "00",                               -- waddr
    '0',                                -- ibtake_1
    (others=>'0'),                      -- ibaddr
    '0','0','0','0','0','0',            -- ibwe,ibrmw,ibbe0,ibbe1,ibcacc,ibracc
    '0','0',                            -- iback,ibbusy
    '0','0','0',                        -- ibnak,ibtout,ibburst
    (others=>'0'),                      -- ibdata
    (others=>'0'),                      -- ibnbusy
    (others=>'0')                       -- ibndly
  );

  constant ibnbusylast : slv10 := (others=>'1');
  constant ibndlylast  : slv14 := (others=>'1');

  signal R_REGS : regs_type := regs_init;
  signal N_REGS : regs_type := regs_init;

  signal BRAM_EN : slbit := '0';
  signal BRAM_WE : slbit := '0';
  signal BRAM0_DI : slv32 := (others=>'0');
  signal BRAM1_DI : slv32 := (others=>'0');
  signal BRAM0_DO : slv32 := (others=>'0');
  signal BRAM1_DO : slv32 := (others=>'0');
  
begin

  assert AWIDTH>=9 and AWIDTH<=14 
    report "assert(AWIDTH>=9 and AWIDTH<=14): unsupported AWIDTH"
    severity failure;

  BRAM1 : ram_1swsr_wfirst_gen
    generic map (
      AWIDTH => AWIDTH,
      DWIDTH => 32)
    port map (
      CLK   => CLK,
      EN    => BRAM_EN,
      WE    => BRAM_WE,
      ADDR  => R_REGS.laddr,
      DI    => BRAM1_DI,
      DO    => BRAM1_DO
    );

  BRAM0 : ram_1swsr_wfirst_gen
    generic map (
      AWIDTH => AWIDTH,
      DWIDTH => 32)
    port map (
      CLK   => CLK,
      EN    => BRAM_EN,
      WE    => BRAM_WE,
      ADDR  => R_REGS.laddr,
      DI    => BRAM0_DI,
      DO    => BRAM0_DO
    );

  proc_regs: process (CLK)
  begin
    if rising_edge(CLK) then
      if RESET = '1' then
        R_REGS <= regs_init;
      else
        R_REGS <= N_REGS;
      end if;
    end if;
  end process proc_regs;

  proc_next : process (R_REGS, IB_MREQ, IB_SRES_SUM, BRAM0_DO, BRAM1_DO)
    variable r : regs_type := regs_init;
    variable n : regs_type := regs_init;
    variable iib_ack  : slbit := '0';
    variable iib_busy : slbit := '0';
    variable iib_dout  : slv16 := (others=>'0');
    variable iibena  : slbit := '0';
    variable ibramen : slbit := '0';    -- BRAM enable
    variable ibramwe : slbit := '0';    -- BRAN we
    variable ibtake : slbit := '0';
    variable laddr_inc : slbit := '0';
    variable idat0 : slv16 := (others=>'0');
    variable idat1 : slv16 := (others=>'0');
    variable idat2 : slv16 := (others=>'0');
    variable idat3 : slv16 := (others=>'0');
  begin

    r := R_REGS;
    n := R_REGS;

    iib_ack  := '0';
    iib_busy := '0';
    iib_dout := (others=>'0');

    iibena  := IB_MREQ.re or IB_MREQ.we;
        
    ibramen := '0';
    ibramwe := '0';

    laddr_inc := '0';
    
    -- ibus address decoder
    n.ibsel := '0';
    if IB_MREQ.aval='1' and IB_MREQ.addr(12 downto 4)=IB_ADDR(12 downto 4) then
      n.ibsel := '1';
      ibramen := '1';
    end if;

    -- ibus transactions (react only on console (this includes racc))
    if r.ibsel = '1' and IB_MREQ.cacc='1' then

      iib_ack := iibena;                -- ack all accesses

      case IB_MREQ.addr(3 downto 1) is

        when ibaddr_cntl =>                 -- cntl ------------------
          if IB_MREQ.we = '1' then 
            n.conena := IB_MREQ.din(cntl_ibf_conena);
            n.remena := IB_MREQ.din(cntl_ibf_remena);
            n.locena := IB_MREQ.din(cntl_ibf_locena);
            n.wena   := IB_MREQ.din(cntl_ibf_wena);
            if IB_MREQ.din(cntl_ibf_start) = '1' then
              n.go    := '1';
              n.wrap  := '0';
              n.laddr := laddrzero;
              n.waddr := "00";
            end if;
            if IB_MREQ.din(cntl_ibf_stop) = '1' then
              n.go    := '0';
            end if;
          end if;
          
        when ibaddr_stat => null;           -- stat ------------------

        when ibaddr_hilim =>                -- hilim -----------------
          if IB_MREQ.we = '1' then
            n.hilim := IB_MREQ.din(iba_ibf_addr);
          end if;
          
        when ibaddr_lolim =>                -- lolim -----------------
          if IB_MREQ.we = '1' then
            n.lolim := IB_MREQ.din(iba_ibf_addr);
          end if;
          
        when ibaddr_addr =>                 -- addr ------------------
          if IB_MREQ.we = '1' then
            n.go    := '0';
            n.wrap  := '0';
            n.laddr := IB_MREQ.din(addr_ibf_laddr);
            n.waddr := IB_MREQ.din(addr_ibf_waddr);
          end if;

        when ibaddr_data =>                 -- data ------------------
          if r.go='1' or IB_MREQ.we='1' then
            iib_ack := '0';                   -- error, do nak
          end if;
          if IB_MREQ.re = '1' then
            n.waddr := slv(unsigned(r.waddr) + 1);
            if r.waddr = "11" then
              laddr_inc := '1';
            end if;
          end if;

        when others =>                      -- <> --------------------
          iib_ack := '0';                     -- error, do nak
          
      end case;
    end if;

    -- ibus output driver
    if r.ibsel = '1' then
      case IB_MREQ.addr(3 downto 1) is
        when ibaddr_cntl =>                 -- cntl ------------------
          iib_dout(cntl_ibf_conena) := r.conena;
          iib_dout(cntl_ibf_remena) := r.remena;
          iib_dout(cntl_ibf_locena) := r.locena;
          iib_dout(cntl_ibf_wena)   := r.wena;
          iib_dout(cntl_ibf_start)  := r.go;
        when ibaddr_stat =>                 -- stat ------------------
          iib_dout(stat_ibf_bsize) := slv(to_unsigned(AWIDTH-9,3));
          iib_dout(stat_ibf_wrap)  := r.wrap;
        when ibaddr_hilim =>                -- hilim -----------------
          iib_dout(iba_ibf_pref)   := (others=>'1');
          iib_dout(iba_ibf_addr)   := r.hilim;
        when ibaddr_lolim =>                -- lolim -----------------
          iib_dout(iba_ibf_pref)   := (others=>'1');
          iib_dout(iba_ibf_addr)   := r.lolim;
        when ibaddr_addr =>                 -- addr ------------------
          iib_dout(addr_ibf_laddr) := r.laddr;
          iib_dout(addr_ibf_waddr) := r.waddr;
        when ibaddr_data =>                 -- data ------------------
          case r.waddr is
            when "11" => iib_dout := BRAM1_DO(31 downto 16);
            when "10" => iib_dout := BRAM1_DO(15 downto  0);
            when "01" => iib_dout := BRAM0_DO(31 downto 16);
            when "00" => iib_dout := BRAM0_DO(15 downto  0);
            when others => null;
          end case;
        when others => null;
      end case;
    end if;

    -- ibus monitor 
    --   a ibus transaction are captured if the address is in alim window
    --   and the access is not refering to ibd_ibmon itself
    
    ibtake := '0';
    if IB_MREQ.aval='1' and iibena='1' then              -- aval and (re or we)
      if unsigned(IB_MREQ.addr)>=unsigned(r.lolim) and   -- and in addr window
         unsigned(IB_MREQ.addr)<=unsigned(r.hilim) and
         r.ibsel='0' then                                -- and not self
        if (r.locena='1' and IB_MREQ.cacc='0' and IB_MREQ.racc='0') or
           (r.remena='1' and IB_MREQ.racc='1') or
           (r.conena='1' and IB_MREQ.cacc='1') then
          ibtake := '1';
        end if;
      end if;
    end if;

    if ibtake = '1' then                -- if capture active
      n.ibaddr := IB_MREQ.addr;           -- keep track of some state
      n.ibwe   := IB_MREQ.we;
      n.ibrmw  := IB_MREQ.rmw;
      n.ibbe0  := IB_MREQ.be0;
      n.ibbe1  := IB_MREQ.be1;
      n.ibcacc := IB_MREQ.cacc;
      n.ibracc := IB_MREQ.racc;
      if IB_MREQ.we='1' then                -- for write of din
        n.ibdata := IB_MREQ.din;
      else                                  -- for read of dout
        n.ibdata := IB_SRES_SUM.dout;
      end if;
      
      if r.ibtake_1 = '0' then            -- if initial cycle of a transaction
        n.iback  := IB_SRES_SUM.ack;
        n.ibbusy := IB_SRES_SUM.busy;
        n.ibnbusy := (others=>'0');
      else                                -- if non-initial cycles
        if r.ibnbusy /= ibnbusylast then      -- and count  
          n.ibnbusy := slv(unsigned(r.ibnbusy) + 1);
        end if;
      end if;
      n.ibnak  := not IB_SRES_SUM.ack;
      n.ibtout := IB_SRES_SUM.busy;

    else                                -- if capture not active
      if r.go='1' and r.ibtake_1='1' then -- active and transaction just ended
        ibramen := '1';
        ibramwe := '1';
        laddr_inc := '1';
        n.ibburst := '1';                   -- assume burst
      end if;
      if r.ibtake_1 = '1' then            -- ibus transaction just ended
        n.ibndly := (others=>'0');          -- clear delay counter
      else                                -- just idle
        if r.ibndly /= ibndlylast then      -- count cycles
          n.ibndly := slv(unsigned(r.ibndly) + 1);
        end if;
      end if;
    end if;

    if IB_MREQ.aval = '0' then          -- if aval gone
      n.ibburst := '0';                   -- clear burst flag
    end if;
    
    if laddr_inc = '1' then
      n.laddr := slv(unsigned(r.laddr) + 1);
      if r.go='1' and r.laddr=laddrlast then
        if r.wena = '1' then
          n.wrap := '1';
        else
          n.go   := '0';
        end if;
      end if;
    end if;
    
    idat3 := (others=>'0');
    idat3(dat3_ibf_burst)  := r.ibburst;
    idat3(dat3_ibf_tout)   := r.ibtout;
    idat3(dat3_ibf_nak)    := r.ibnak;
    idat3(dat3_ibf_ack)    := r.iback;
    idat3(dat3_ibf_busy)   := r.ibbusy;
    idat3(dat3_ibf_we)     := r.ibwe;
    idat3(dat3_ibf_rmw)    := r.ibrmw;
    idat3(dat3_ibf_ndlymsb):= r.ibndly(13 downto 6);
    idat2(dat2_ibf_ndlylsb):= r.ibndly( 5 downto 0);
    idat2(dat2_ibf_nbusy)  := r.ibnbusy;
    idat1                  := r.ibdata;
    idat0(dat0_ibf_be1)    := r.ibbe1;
    idat0(dat0_ibf_be0)    := r.ibbe0;
    idat0(dat0_ibf_racc)   := r.ibracc;
    idat0(dat0_ibf_addr)   := r.ibaddr;
    idat0(dat0_ibf_cacc)   := r.ibcacc;
    
    n.ibtake_1 := ibtake;
    
    N_REGS <= n;

    BRAM_EN <= ibramen;
    BRAM_WE <= ibramwe;

    BRAM1_DI <= idat3 & idat2;
    BRAM0_DI <= idat1 & idat0;
      
    IB_SRES.dout <= iib_dout;
    IB_SRES.ack  <= iib_ack;
    IB_SRES.busy <= iib_busy;

  end process proc_next;

end syn;
