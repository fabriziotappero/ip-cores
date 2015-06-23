-- $Id: ibdr_rk11.vhd 672 2015-05-02 21:58:28Z mueller $
--
-- Copyright 2008-2015 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Module Name:    ibdr_rk11 - syn
-- Description:    ibus dev(rem): RK11-A/B
--
-- Dependencies:   ram_1swar_gen
-- Test bench:     -
-- Target Devices: generic
-- Tool versions:  ise 8.2-14.7; viv 2014.4; ghdl 0.18-0.31
--
-- Synthesized (xst):
-- Date         Rev  ise         Target      flop lutl lutm slic t peri
-- 2014-06-08   561 14.7  131013 xc6slx16-2    44  139    9   60 s  5.6
-- 2010-10-17   333 12.1    M53d xc3s1000-4    46  248   16  137 s  7.2
-- 2009-06-01   221 10.1.03 K39  xc3s1000-4    46  249   16  148 s  7.1
-- 2008-01-06   111  8.2.03 I34  xc3s1000-4    36  189   16  111 s  6.0
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2015-05-01   672   1.3    BUGFIX: interrupt after dreset,seek command start
-- 2011-11-18   427   1.2.2  now numeric_std clean
-- 2010-10-23   335   1.2.1  rename RRI_LAM->RB_LAM;
-- 2010-10-17   333   1.2    use ibus V2 interface
-- 2010-06-11   303   1.1    use IB_MREQ.racc instead of RRI_REQ
-- 2009-05-24   219   1.0.9  add CE_MSEC input; inc sector counter every msec
--                           BUGFIX: sector counter now counts 000,...,013.
-- 2009-05-21   217   1.0.8  cancel pending interrupt requests when IE=0
-- 2009-05-16   216   1.0.7  BUGFIX: correct interrupt on IE 0->1 logic
--                           BUGFIX: re-work the seek complete handling
-- 2008-08-22   161   1.0.6  use iblib
-- 2008-05-30   151   1.0.5  BUGFIX: do control reset locally now, add CRDONE
-- 2008-03-30   131   1.0.4  issue interrupt when IDE bit set with GO=0
-- 2008-02-23   118   1.0.3  remove redundant condition in rkda access code
--                           fix bug in control reset logic (we's missing)
-- 2008-01-20   113   1.0.2  Fix busy handling when control reset done
-- 2008-01-20   112   1.0.1  Fix scp handling; use BRESET
-- 2008-01-06   111   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.memlib.all;
use work.iblib.all;

-- ----------------------------------------------------------------------------
entity ibdr_rk11 is                     -- ibus dev(rem): RK11
                                        -- fixed address: 177400
  port (
    CLK : in slbit;                     -- clock
    CE_MSEC : in slbit;                 -- msec pulse
    BRESET : in slbit;                  -- ibus reset
    RB_LAM : out slbit;                 -- remote attention
    IB_MREQ : in ib_mreq_type;          -- ibus request
    IB_SRES : out ib_sres_type;         -- ibus response
    EI_REQ : out slbit;                 -- interrupt request
    EI_ACK : in slbit                   -- interrupt acknowledge
  );
end ibdr_rk11;

architecture syn of ibdr_rk11 is

  constant ibaddr_rk11 : slv16 := slv(to_unsigned(8#177400#,16));

  constant ibaddr_rkds : slv3 := "000";  -- rkds address offset
  constant ibaddr_rker : slv3 := "001";  -- rker address offset
  constant ibaddr_rkcs : slv3 := "010";  -- rkcs address offset
  constant ibaddr_rkwc : slv3 := "011";  -- rkwc address offset
  constant ibaddr_rkba : slv3 := "100";  -- rkba address offset
  constant ibaddr_rkda : slv3 := "101";  -- rkda address offset
  constant ibaddr_rkmr : slv3 := "110";  -- rkmr address offset
  constant ibaddr_rkdb : slv3 := "111";  -- rkdb address offset
  
  subtype  rkds_ibf_id      is integer range 15 downto 13;
  constant rkds_ibf_adry  : integer :=  6;
  constant rkds_ibf_scsa  : integer :=  4;
  subtype  rkds_ibf_sc      is integer range  3 downto  0;

  subtype  rker_ibf_he      is integer range 15 downto  5;
  constant rker_ibf_cse   : integer :=  1;
  constant rker_ibf_wce   : integer :=  0;

  constant rkcs_ibf_err   : integer := 15;
  constant rkcs_ibf_he    : integer := 14;
  constant rkcs_ibf_scp   : integer := 13;
  constant rkcs_ibf_maint : integer := 12;
  constant rkcs_ibf_rdy   : integer :=  7;
  constant rkcs_ibf_ide   : integer :=  6;
  subtype  rkcs_ibf_mex     is integer range  5 downto  4;
  subtype  rkcs_ibf_func    is integer range  3 downto  1;
  constant rkcs_ibf_go    : integer :=  0;

  subtype  rkda_ibf_drsel   is integer range 15 downto 13;

  subtype  rkmr_ibf_rid     is integer range 15 downto 13;  -- rem id
  constant rkmr_ibf_crdone: integer := 11;                  -- contr. reset done
  constant rkmr_ibf_sbclr : integer := 10;                  -- clear sbusy's 
  constant rkmr_ibf_creset: integer :=  9;                  -- control reset
  constant rkmr_ibf_fdone : integer :=  8;                  -- func done
  subtype  rkmr_ibf_sdone   is integer range  7 downto  0;  -- seek done

  constant func_creset : slv3 := "000";   -- func: control reset
  constant func_write  : slv3 := "001";   -- func: write
  constant func_read   : slv3 := "010";   -- func: read
  constant func_wchk   : slv3 := "011";   -- func: write check
  constant func_seek   : slv3 := "100";   -- func: seek
  constant func_rchk   : slv3 := "101";   -- func: read check
  constant func_dreset : slv3 := "110";   -- func: drive reset
  constant func_wlock  : slv3 := "111";   -- func: write lock

  type state_type is (
    s_idle,
    s_init
  );

  type regs_type is record              -- state registers
    ibsel : slbit;                      -- ibus select
    state : state_type;                 -- state
    id : slv3;                          -- rkds: drive id of search done
    sc : slv4;                          -- rkds: sector counter
    cse : slbit;                        -- rker: check sum error
    wce : slbit;                        -- rker: write check error
    he : slbit;                         -- rkcs: hard error
    scp : slbit;                        -- rkcs: seek complete
    maint : slbit;                      -- rkcs: maintenance mode
    rdy   : slbit;                      -- rkcs: control ready
    ide   : slbit;                      -- rkcs: interrupt on done enable
    drsel : slv3;                       -- rkda: currently selected drive
    fireq : slbit;                      -- func done interrupt request flag
    sireq : slv8;                       -- seek done interrupt request flags
    sbusy : slv8;                       -- seek busy flags
    rid   : slv3;                       -- drive id for rem ds reads
    icnt  : slv3;                       -- init state counter
    creset : slbit;                     -- control reset flag
    crdone : slbit;                     -- control reset done since last fdone
  end record regs_type;

  constant regs_init : regs_type := (
    '0',                                -- ibsel
    s_init,                             -- state
    (others=>'0'),                      -- id
    (others=>'0'),                      -- sc
    '0','0',                            -- cse, wce
    '0','0','0',                        -- he, scp, maint
    '1',                                -- rdy (SET TO 1)
    '0',                                -- ide
    (others=>'0'),                      -- drsel
    '0',                                -- fireq
    (others=>'0'),                      -- sireq
    (others=>'0'),                      -- sbusy
    (others=>'0'),                      -- rid
    (others=>'0'),                      -- icnt
    '0','1'                             -- creset, crdone
  );

  signal R_REGS : regs_type := regs_init;
  signal N_REGS : regs_type := regs_init;

  signal MEM_1_WE : slbit := '0';
  signal MEM_0_WE : slbit := '0';
  signal MEM_ADDR : slv4  := (others=>'0');
  signal MEM_DIN  : slv16 := (others=>'0');
  signal MEM_DOUT : slv16 := (others=>'0');
  
begin
  
  MEM_1 : ram_1swar_gen
    generic map (
      AWIDTH => 4,
      DWIDTH => 8)
    port map (
      CLK  => CLK,
      WE   => MEM_1_WE,
      ADDR => MEM_ADDR,
      DI   => MEM_DIN(ibf_byte1),
      DO   => MEM_DOUT(ibf_byte1));

  MEM_0 : ram_1swar_gen
    generic map (
      AWIDTH => 4,
      DWIDTH => 8)
    port map (
      CLK  => CLK,
      WE   => MEM_0_WE,
      ADDR => MEM_ADDR,
      DI   => MEM_DIN(ibf_byte0),
      DO   => MEM_DOUT(ibf_byte0));

  proc_regs: process (CLK)
  begin
    if rising_edge(CLK) then
      if BRESET='1' or R_REGS.creset='1' then
        R_REGS <= regs_init;
        if R_REGS.creset = '1' then
          R_REGS.sbusy <= N_REGS.sbusy;
        end if;
      else
        R_REGS <= N_REGS;
      end if;
    end if;
  end process proc_regs;

  proc_next : process (R_REGS, CE_MSEC, IB_MREQ, MEM_DOUT, EI_ACK)
    variable r : regs_type := regs_init;
    variable n : regs_type := regs_init;
    variable ibhold : slbit := '0';
    variable icrip  : slbit := '0';
    variable idout  : slv16 := (others=>'0');
    variable ibrem  : slbit := '0';
    variable ibreq  : slbit := '0';
    variable ibrd   : slbit := '0';
    variable ibw0   : slbit := '0';
    variable ibw1   : slbit := '0';
    variable ibwrem : slbit := '0';
    variable ilam   : slbit := '0';
    variable iscval : slbit := '0';
    variable iscid : slv3 := (others=>'0');
    variable iei_req : slbit := '0';
    
    variable imem_we0 : slbit := '0';
    variable imem_we1 : slbit := '0';
    variable imem_addr : slv4 := (others=>'0');
    variable imem_din : slv16 := (others=>'0');
  begin

    r := R_REGS;
    n := R_REGS;

    ibhold := '0';
    icrip  := '0';
    idout  := (others=>'0');
    ibrem  := IB_MREQ.racc or r.maint;
    ibreq  := IB_MREQ.re or IB_MREQ.we;
    ibrd   := IB_MREQ.re;
    ibw0   := IB_MREQ.we and IB_MREQ.be0;
    ibw1   := IB_MREQ.we and IB_MREQ.be1;
    ibwrem := IB_MREQ.we and ibrem;
    ilam   := '0';
    iscval := '0';
    iscid  := (others=>'0');
    iei_req := '0';

    imem_we0  := '0';
    imem_we1  := '0';
    imem_addr := '0' & IB_MREQ.addr(3 downto 1);
    imem_din  := IB_MREQ.din;
    
    -- ibus address decoder
    n.ibsel := '0';
    if IB_MREQ.aval = '1' and
       IB_MREQ.addr(12 downto 4)=ibaddr_rk11(12 downto 4) then
      n.ibsel := '1';
    end if;

    -- internal state machine (for control reset)
    case r.state is
      when s_idle =>
        null;

      when s_init =>
        ibhold := r.ibsel;              -- hold ibus when controller busy
        icrip  := '1';
        n.icnt := slv(unsigned(r.icnt) + 1);
        if unsigned(r.icnt) = 7 then
          n.state := s_idle;
        end if;
        
      when others => null;
    end case;

    
    -- ibus transactions
    
    if r.ibsel='1' and ibhold='0' then  -- selected and not holding
      idout := MEM_DOUT;
      imem_we0 := ibw0;
      imem_we1 := ibw1;
        
      case IB_MREQ.addr(3 downto 1) is

        when ibaddr_rkds =>              -- RKDS -- drive status register ----
          if ibrem = '0' then
            imem_addr := '1' & r.drsel;  -- loc read ds data: drsel as addr.
          else
            imem_addr := '1' & r.rid;    -- rem read ds data: rid as addr.
          end if;
          idout(rkds_ibf_id) := r.id;
          if ibrem = '0' then            -- loc ? simulate drive sector monitor
            if r.sc = MEM_DOUT(rkds_ibf_sc) then
              idout(rkds_ibf_scsa) := '1';
            else
              idout(rkds_ibf_scsa) := '0';
            end if;
            idout(rkds_ibf_sc) := r.sc;
          end if;

          if r.sbusy(to_integer(unsigned(imem_addr(2 downto 0))))='1' then
            idout(rkds_ibf_adry) := '0';             -- clear drive access rdy
          end if;
          
          if ibwrem = '1' then            -- rem write ? than update ds data
            imem_addr := '1' & IB_MREQ.din(rkds_ibf_id); -- use id field as addr
          else                          -- loc write ?
            imem_we0 := '0';              -- suppress we, is read-only
            imem_we1 := '0';
          end if;
          
        when ibaddr_rker =>             -- RKER -- error register ------------
          idout(4 downto 2) := (others=>'0');  -- unassigned bits
          idout(rker_ibf_cse) := r.cse; -- use state bits (cleared at go !) 
          idout(rker_ibf_wce) := r.wce;
          
          if ibwrem = '1' then          -- rem write ?
            if unsigned(IB_MREQ.din(rker_ibf_he)) /= 0 then -- hard errors set ?
              n.he := '1';
            else
              n.he := '0';
            end if;
            n.cse := IB_MREQ.din(rker_ibf_cse); -- mirror cse bit
            n.wce := IB_MREQ.din(rker_ibf_wce); -- mirror wce bit
          else                          -- loc write ?
            imem_we0 := '0';              -- suppress we, is read-only
            imem_we1 := '0';
          end if;
          
        when ibaddr_rkcs =>             -- RKCS -- control status register ---
          idout(rkcs_ibf_err) := r.he or r.cse or r.wce;
          idout(rkcs_ibf_he)  := r.he;
          idout(rkcs_ibf_scp) := r.scp;
          idout(rkcs_ibf_rdy) := r.rdy;
          idout(rkcs_ibf_go)  := not r.rdy;

          if ibw1 = '1' then
            n.maint := IB_MREQ.din(rkcs_ibf_maint); -- mirror maint bit
          end if;

          if ibw0 = '1' then
            n.ide   := IB_MREQ.din(rkcs_ibf_ide);   -- mirror ide bit
            if n.ide = '0' then                     -- if IE set to 0
              n.fireq := '0';                         -- cancel all pending
              n.sireq := (others=>'0');               -- interrupt requests
            end if;

            if IB_MREQ.din(rkcs_ibf_go) = '1' then    -- GO=1 ?
              if r.rdy = '1' then                       -- ready and GO ?
                n.scp := '0';                             -- go clears scp !
                n.rdy := '0';                             -- mark busy
                n.cse := '0';                             -- clear soft errors
                n.wce := '0';
                n.fireq := '0';                           -- cancel pend. int

                if IB_MREQ.din(rkcs_ibf_func)=func_creset then -- control reset?
                  n.creset := '1';                        -- handle locally
                else
                  ilam  := '1';                           -- issue lam
                end if;
                
                if IB_MREQ.din(rkcs_ibf_func)=func_seek or   -- if seek
                   IB_MREQ.din(rkcs_ibf_func)=func_dreset then -- or drive reset
                  n.sbusy(to_integer(unsigned(r.drsel))) := '1'; -- drive busy
                  if n.ide = '1' then                         -- if enabled
                    n.fireq := '1';                              -- interrupt !
                  end if;
                end if;

              end if;
            else                                      -- GO=0
              if r.ide='0' and n.ide='1' and          -- if IDE 0->1 transition
                 r.rdy='1' then                         -- and controller ready
                n.fireq := '1';                           -- issue interrupt
              end if;
            end if;
          end if;
          
        when ibaddr_rkda =>             -- RKDA -- disk address register -----
          if ibrem = '0' then           -- loc access ?
            if r.rdy = '0' then           -- controller busy ?
              imem_we0 := '0';              -- suppress write
              imem_we1 := '0';
            end if;
          end if;
          if imem_we1 = '1' then
            n.drsel := IB_MREQ.din(rkda_ibf_drsel); -- mirror drsel bits
          end if;

        when ibaddr_rkmr =>             -- RKMR -- maintenance register ------
          idout := (others=>'0');
          idout(rkmr_ibf_rid)    := r.rid;
          idout(rkmr_ibf_crdone) := r.crdone;
          idout(rkmr_ibf_sdone)  := r.sbusy;
          if ibwrem = '1' then          -- rem write ?
            n.rid := IB_MREQ.din(rkmr_ibf_rid);

            if r.ide='1' and IB_MREQ.din(rkmr_ibf_sbclr)='0' then
              n.sireq := r.sireq or (IB_MREQ.din(rkmr_ibf_sdone) and r.sbusy);
            end if;
            n.sbusy := r.sbusy and not IB_MREQ.din(rkmr_ibf_sdone);
            
            if IB_MREQ.din(rkmr_ibf_fdone) = '1' then -- func completed
              n.rdy    := '1';
              n.crdone := '0';
              if r.ide = '1' then
                n.fireq  := '1';
              end if;
            end if;
            if IB_MREQ.din(rkmr_ibf_creset) = '1' then -- control reset
              n.creset := '1';
            end if;
          end if;
          
        when others =>                  -- all other regs
          null;
          
      end case;
      
    end if;

    iscval := '1';
       if r.sireq(7) = '1' then  iscid := "111";
    elsif r.sireq(6) = '1' then  iscid := "110";
    elsif r.sireq(5) = '1' then  iscid := "101";
    elsif r.sireq(4) = '1' then  iscid := "100";
    elsif r.sireq(3) = '1' then  iscid := "011";
    elsif r.sireq(2) = '1' then  iscid := "010";
    elsif r.sireq(1) = '1' then  iscid := "001";
    elsif r.sireq(0) = '1' then  iscid := "000";
    else
      iscval := '0';
    end if;

    if r.ide = '1' then
      if r.fireq='1' or iscval='1' then 
        iei_req := '1';
      end if;
    end if;

    if EI_ACK = '1' then                -- interrupt executed
      if r.fireq = '1' then
        n.scp   := '0';                   -- clear scp flag, is command end
        n.fireq := '0';
      elsif iscval = '1' then             -- was a seek done
        n.scp := '1';                     -- signal seek complete interrupt
        n.id := iscid;                        -- load id
        n.sireq(to_integer(unsigned(iscid))) := '0';  -- reset sireq bit
      end if;
    end if;
    
    if icrip = '1' then                 -- control reset in progress ?
      imem_addr := '0' & r.icnt;          -- use icnt as addr
      imem_din  := (others=>'0');         -- force data to zero
      imem_we0  := '1';                   -- enable writes
      imem_we1  := '1';
    end if;

    if CE_MSEC = '1' then               -- advance sector counter every msec
      if unsigned(r.sc) = 8#13# then      -- sector counter (count to 8#13#)
        n.sc := (others=>'0');
      else
        n.sc := slv(unsigned(r.sc) + 1);
      end if;      
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
