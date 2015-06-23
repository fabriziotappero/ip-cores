-- $Id: ibdr_tm11.vhd 686 2015-06-04 21:08:08Z mueller $
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
-- Module Name:    ibdr_tm11 - syn
-- Description:    ibus dev(rem): TM11
--
-- Dependencies:   -
-- Test bench:     -
-- Target Devices: generic
-- Tool versions:  ise 14.7; viv 2014.4; ghdl 0.31
--
-- Synthesized (xst):
-- Date         Rev  ise         Target      flop lutl lutm slic t peri
-- 2015-06-04   686 14.7  131013 xc6slx16-2    79  144    0   53 s  4.4
-- 2015-05-15   682 14.7  131013 xc6slx16-2   117  209    0   76 s  3.7
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2015-06-04   686   1.0    Initial version
-- 2015-05-15   682   0.1    First draft 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.iblib.all;

-- ----------------------------------------------------------------------------
entity ibdr_tm11 is                     -- ibus dev(rem): TM11
                                        -- fixed address: 172520
  port (
    CLK : in slbit;                     -- clock
    BRESET : in slbit;                  -- ibus reset
    RB_LAM : out slbit;                 -- remote attention
    IB_MREQ : in ib_mreq_type;          -- ibus request
    IB_SRES : out ib_sres_type;         -- ibus response
    EI_REQ : out slbit;                 -- interrupt request
    EI_ACK : in slbit                   -- interrupt acknowledge
  );
end ibdr_tm11;

architecture syn of ibdr_tm11 is

  constant ibaddr_tm11 : slv16 := slv(to_unsigned(8#172520#,16));

  constant ibaddr_sr : slv3 := "000";    -- sr address offset
  constant ibaddr_cr : slv3 := "001";    -- cr address offset
  constant ibaddr_bc : slv3 := "010";    -- bc address offset
  constant ibaddr_ba : slv3 := "011";    -- ba address offset
  constant ibaddr_db : slv3 := "100";    -- db address offset
  constant ibaddr_rl : slv3 := "101";    -- rl address offset
  
  constant sr_ibf_icmd   : integer := 15;
  constant sr_ibf_eof    : integer := 14;
  constant sr_ibf_pae    : integer := 12;
  constant sr_ibf_eot    : integer := 10;
  constant sr_ibf_rle    : integer :=  9;
  constant sr_ibf_bte    : integer :=  8;
  constant sr_ibf_nxm    : integer :=  7;
  constant sr_ibf_onl    : integer :=  6;
  constant sr_ibf_bot    : integer :=  5;
  constant sr_ibf_wrl    : integer :=  2;
  constant sr_ibf_rew    : integer :=  1;
  constant sr_ibf_tur    : integer :=  0;

  constant cr_ibf_err    : integer := 15;
  subtype  cr_ibf_den      is integer range 14 downto 13;
  constant cr_ibf_ini    : integer := 12;
  constant cr_ibf_pevn   : integer := 11;
  constant cr_ibf_unit2  : integer := 10;
  subtype  cr_ibf_unit     is integer range  9 downto  8;
  constant cr_ibf_rdy    : integer :=  7;
  constant cr_ibf_ie     : integer :=  6;
  subtype  cr_ibf_ea       is integer range  5 downto  4;
  subtype  cr_ibf_func     is integer range  3 downto  1;
  constant cr_ibf_go     : integer :=  0;

  subtype  ba_ibf_ba       is integer range 15 downto  1;
  subtype  db_ibf_db       is integer range  7 downto  0;

  constant rl_ibf_reof    : integer := 10;
  constant rl_ibf_reot    : integer :=  9;
  constant rl_ibf_ronl    : integer :=  8;
  constant rl_ibf_rbot    : integer :=  7;
  constant rl_ibf_rwrl    : integer :=  6;
  constant rl_ibf_rrew    : integer :=  5;
  subtype  rl_ibf_runit    is integer range  2 downto  1;
  
  constant func_unload : slv3 := "000";   -- func: unload
  constant func_read   : slv3 := "001";   -- func: read
  constant func_write  : slv3 := "010";   -- func: write
  constant func_weof   : slv3 := "011";   -- func: write eof
  constant func_sforw  : slv3 := "100";   -- func: space forward
  constant func_sback  : slv3 := "101";   -- func: space backward
  constant func_wrteg  : slv3 := "110";   -- func: write extend interrec gap
  constant func_rewind : slv3 := "111";   -- func: rewind

  constant rfunc_wunit : slv3 := "001";   -- rem func: write runit
  constant rfunc_done  : slv3 := "010";   -- rem func: done (set rdy)

  -- cs1 usage for rem functions
  subtype  cr_ibf_runit   is integer range  5 downto  4;  -- new runit (_wunit)
  constant cr_ibf_ricmd   : integer := 15;                -- new icmd  (_done) 
  constant cr_ibf_rpae    : integer := 12;                -- new pae   (_done) 
  constant cr_ibf_rrle    : integer :=  9;                -- new rle   (_done) 
  constant cr_ibf_rbte    : integer :=  8;                -- new bte   (_done) 
  constant cr_ibf_rnxm    : integer :=  7;                -- new nxm   (_done) 
  constant cr_ibf_reaena  : integer :=  6;                -- ena ea    (_done) 
  subtype  cr_ibf_rea     is integer range  5 downto  4;  -- new ea    (_done)

  type regs_type is record              -- state registers
    ibsel : slbit;                      -- ibus select
    sricmd : slbit;                     -- sr: invalid command
    srpae: slbit;                       -- sr: parity error
    srrle: slbit;                       -- sr: record length error
    srbte: slbit;                       -- sr: bad tape error
    srnxm: slbit;                       -- sr: non-existant memory
    sreof: slv4;                        -- sr: eof-of-file
    sreot: slv4;                        -- sr: eof-of-tape
    sronl: slv4;                        -- sr: online
    srbot: slv4;                        -- sr: begin-of-tape
    srwrl: slv4;                        -- sr: write-locked
    srrew: slv4;                        -- sr: rewinding
    crden: slv2;                        -- cr: density
    crpevn: slbit;                      -- cr: even oarity
    crunit2: slbit;                     -- cr: unit[2]
    crunit: slv2;                       -- cr: unit[1:0]
    crrdy: slbit;                       -- cr: controller ready
    crie: slbit;                        -- cr: interrupt enable
    crea: slv2;                         -- cr: address extension
    crfunc: slv3;                       -- cr: func code
    bc : slv16;                         -- bc: byte count
    ba : slv16_1;                       -- ba: bus address
    runit : slv2;                       -- rem access unit
    resreq : slbit;                     -- reset requested
    ireq   : slbit;                     -- interrupt request flag
  end record regs_type;

  constant regs_init : regs_type := (
    '0',                                -- ibsel
    '0','0','0','0','0',                -- sricmd,srpae,srrle,srbte,srnxm
    (others=>'0'),                      -- sreof
    (others=>'0'),                      -- sreot
    (others=>'0'),                      -- sronl
    (others=>'0'),                      -- srbot
    (others=>'0'),                      -- srwrl
    (others=>'0'),                      -- srrew
    (others=>'0'),                      -- crden
    '0','0',                            -- crpevn,crunit2
    (others=>'0'),                      -- crunit
    '1','0',                            -- crrdy, crie
    (others=>'0'),                      -- crea
    (others=>'0'),                      -- crfunc
    (others=>'0'),                      -- bc
    (others=>'0'),                      -- ba
    (others=>'0'),                      -- runit
    '0',                                -- resreq
    '0'                                 -- ireq
  );

  signal R_REGS : regs_type := regs_init;
  signal N_REGS : regs_type := regs_init;

begin
  
  proc_regs: process (CLK)
  begin
    if rising_edge(CLK) then
      R_REGS <= N_REGS;
    end if;
  end process proc_regs;

  proc_next : process (R_REGS, IB_MREQ, EI_ACK)
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
    
    -- ibus address decoder
    n.ibsel := '0';
    if IB_MREQ.aval = '1' and
       IB_MREQ.addr(12 downto 4)=ibaddr_tm11(12 downto 4) and
       unsigned(IB_MREQ.addr(3 downto 1)) <= unsigned(ibaddr_rl) then
      n.ibsel := '1';
    end if;

    -- ibus transactions
    
    if r.ibsel='1' then                 -- selected
        
      case IB_MREQ.addr(3 downto 1) is

        when ibaddr_sr =>               -- SR  -- status register ----------
          idout(sr_ibf_icmd)  := r.sricmd;
          idout(sr_ibf_pae)   := r.srpae;
          idout(sr_ibf_rle)   := r.srrle;
          idout(sr_ibf_bte)   := r.srbte;
          idout(sr_ibf_nxm)   := r.srnxm;
          idout(sr_ibf_tur)   := r.crrdy; -- FIXME: is this correct ??
          -- only units 0,..3 supported, for unit 4,..,7 return 0 --> ONL=0
          if r.crunit2 = '0' then
            idout(sr_ibf_eof)   := r.sreof(to_integer(unsigned(r.crunit)));
            idout(sr_ibf_eot)   := r.sreot(to_integer(unsigned(r.crunit)));
            idout(sr_ibf_onl)   := r.sronl(to_integer(unsigned(r.crunit)));
            idout(sr_ibf_bot)   := r.srbot(to_integer(unsigned(r.crunit)));
            idout(sr_ibf_wrl)   := r.srwrl(to_integer(unsigned(r.crunit)));
            idout(sr_ibf_rew)   := r.srrew(to_integer(unsigned(r.crunit)));
          end if;
          
        when ibaddr_cr =>               -- CR  -- control register ---------
          idout(cr_ibf_err)   := r.sricmd or
                                 r.sreof(to_integer(unsigned(r.crunit))) or
                                 r.srpae or
                                 r.sreot(to_integer(unsigned(r.crunit))) or
                                 r.srrle or
                                 r.srnxm;
          idout(cr_ibf_den)   := r.crden;
          idout(cr_ibf_pevn)  := r.crpevn;
          idout(cr_ibf_unit2) := r.crunit2;
          idout(cr_ibf_unit)  := r.crunit;
          idout(cr_ibf_rdy)   := r.crrdy;
          idout(cr_ibf_ie)    := r.crie;
          idout(cr_ibf_ea)    := r.crea;
          idout(cr_ibf_func)  := r.crfunc;

          if IB_MREQ.we = '1' then
            if ibrem = '0' then

              if r.crrdy = '1' then
                if IB_MREQ.be1 = '1' then
                  n.crden   := IB_MREQ.din(cr_ibf_den);
                  if IB_MREQ.din(cr_ibf_ini) = '1' then
                    n.resreq := '1';
                  end if;
                  n.crpevn  := IB_MREQ.din(cr_ibf_pevn);
                  n.crunit2 := IB_MREQ.din(cr_ibf_unit2);
                  n.crunit  := IB_MREQ.din(cr_ibf_unit);
                end if;
                if IB_MREQ.be0 = '1' then
                  n.crie   := IB_MREQ.din(cr_ibf_ie);
                  if n.crie = '0' then     -- if IE set to 0
                    n.ireq := '0';           -- cancel pending interrupt
                  end if;
                  n.crea   := IB_MREQ.din(cr_ibf_ea);
                  n.crfunc := IB_MREQ.din(cr_ibf_func);
                  
                  if IB_MREQ.din(cr_ibf_go) = '1' then
                    n.sricmd := '0';       -- clear errors
                    n.srpae  := '0';
                    n.srrle  := '0';
                    n.srbte  := '0';
                    n.srnxm  := '0';
                    n.sreof  := (others=>'0'); -- clear position status flags
                    n.sreot  := (others=>'0');
                    n.srbot  := (others=>'0');
                    n.srrew  := (others=>'0');
                    n.crrdy := '0';        -- mark busy
                    ilam    := '1';        -- rri lam
                  else
                    if r.crie='0' and n.crie='1' then   -- if IDE 0->1 transition
                      n.ireq := '1';           -- issue software interrupt
                    end if;
                  end if;
                end if;
              else
                n.sricmd := '1';
              end if;
                
            else                        -- rem write access. GO not checked
                                        --   always treated as remote function
              case IB_MREQ.din(cr_ibf_func) is
                when rfunc_wunit =>       -- rfunc: wunit -----------------
                  n.runit := IB_MREQ.din(cr_ibf_runit);
                  
                when rfunc_done =>        -- rfunc: done ------------------
                  n.sricmd := IB_MREQ.din(cr_ibf_ricmd);
                  n.srpae  := IB_MREQ.din(cr_ibf_rpae);
                  n.srrle  := IB_MREQ.din(cr_ibf_rrle);
                  n.srbte  := IB_MREQ.din(cr_ibf_rbte);
                  n.srnxm  := IB_MREQ.din(cr_ibf_rnxm);
                  if IB_MREQ.din(cr_ibf_reaena) = '1' then
                    n.crea := IB_MREQ.din(cr_ibf_rea);
                  end if;
                  n.crrdy  := '1';
                  if r.crie = '1' then
                    n.ireq  := '1';
                  end if;
                  
                when others => null;      -- <> 
              end case;

            end if; --  if ibrem

          end if; --  if IB_MREQ.we='1'

        when ibaddr_bc =>               -- BC -- byte count register -------
          idout              := r.bc;
          if ibw1 = '1' then
            n.bc(15 downto 8) := IB_MREQ.din(15 downto 8);
          end if;
          if ibw0 = '1' then
            n.bc( 7 downto 0) := IB_MREQ.din( 7 downto 0);
          end if;
          
        when ibaddr_ba =>               -- BA -- bus address register ------
          idout(ba_ibf_ba)   := r.ba;
          if ibw1 = '1' then
            n.ba(15 downto 8) := IB_MREQ.din(15 downto 8);
          end if;
          if ibw0 = '1' then
            n.ba( 7 downto 1) := IB_MREQ.din( 7 downto 1);
          end if;

        when ibaddr_db =>               -- DB -- data buffer ---------------
          null;
          
        when ibaddr_rl =>               -- RL -- read lines ----------------
          if ibrem = '0' then
            null;
          else
            idout(rl_ibf_reof)  := r.sreof(to_integer(unsigned(r.runit)));
            idout(rl_ibf_reot)  := r.sreot(to_integer(unsigned(r.runit)));
            idout(rl_ibf_ronl)  := r.sronl(to_integer(unsigned(r.runit)));
            idout(rl_ibf_rbot)  := r.srbot(to_integer(unsigned(r.runit)));
            idout(rl_ibf_rwrl)  := r.srwrl(to_integer(unsigned(r.runit)));
            idout(rl_ibf_rrew)  := r.srrew(to_integer(unsigned(r.runit)));
            idout(rl_ibf_runit) := r.runit;
            if IB_MREQ.we = '1' then
              n.sreof(to_integer(unsigned(r.runit))) := IB_MREQ.din(rl_ibf_reof);
              n.sreot(to_integer(unsigned(r.runit))) := IB_MREQ.din(rl_ibf_reot);
              n.sronl(to_integer(unsigned(r.runit))) := IB_MREQ.din(rl_ibf_ronl);
              n.srbot(to_integer(unsigned(r.runit))) := IB_MREQ.din(rl_ibf_rbot);
              n.srwrl(to_integer(unsigned(r.runit))) := IB_MREQ.din(rl_ibf_rwrl);
              n.srrew(to_integer(unsigned(r.runit))) := IB_MREQ.din(rl_ibf_rrew);
            end if;
          end if;
          
        when others =>                  -- doesn't happen, ibsel only for
                                        -- subrange up to rl, and all regs are
                                        -- decoded above
          null;
          
      end case;
    end if;

    if BRESET = '1' then
      n.resreq := '1';
    end if;
    
    if r.resreq = '1' then
      n.sricmd  := '0';
      n.srpae   := '0';
      n.srrle   := '0';
      n.srbte   := '0';
      n.srnxm   := '0';
      n.sreof   := (others=>'0');
      n.sreot   := (others=>'0');
      n.crden   := (others=>'0');
      n.crpevn  := '0';
      n.crunit2 := '0';
      n.crunit  := (others=>'0');
      n.crrdy   := '1';
      n.crie    := '0';
      n.crea    := (others=>'0');
      n.crfunc  := (others=>'0');
      n.bc      := (others=>'0');
      n.ba      := (others=>'0');
      n.resreq  := '0';
      n.ireq    := '0';
    end if;
    
    if EI_ACK = '1' or n.crie = '0' then    -- interrupt executed or ie disabled
      n.ireq := '0';                          -- cancel request
    end if;

    N_REGS <= n;

    IB_SRES.dout <= idout;
    IB_SRES.ack  <= r.ibsel and ibreq;
    IB_SRES.busy <= ibhold  and ibreq;

    RB_LAM <= ilam;
    EI_REQ <= r.ireq;
    
  end process proc_next;

    
end syn;
