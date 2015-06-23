-- $Id: pdp11_core_rbus.vhd 677 2015-05-09 21:52:32Z mueller $
--
-- Copyright 2007-2015 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Module Name:    pdp11_core_rbus - syn
-- Description:    pdp11: core to rbus interface
--
-- Dependencies:   -
-- Test bench:     tb/tb_rlink_tba_pdp11core
--
-- Target Devices: generic
-- Tool versions:  ise 8.2-14.7; viv 2014.4; ghdl 0.18-0.31
--
-- Synthesized (xst):
-- Date         Rev  ise         Target      flop lutl lutm slic t peri
-- 2014-12-21   591 14.7  131013 xc6slx16-2    52  118    0   58 s  4.9
--
-- Revision History: -
-- Date         Rev Version  Comment
-- 2015-05-09   677   1.5    start/stop/suspend overhaul; reset overhaul
-- 2014-12-26   621   1.4    use full size 4k word ibus window
-- 2014-12-21   617   1.3.1  use separate RB_STAT bits for cmderr and cmdmerr
-- 2014-09-05   591   1.3    use new rlink v4 iface and 4 bit STAT
-- 2014-08-15   583   1.2    rb_mreq addr now 16 bit
-- 2011-11-18   427   1.1.1  now numeric_std clean
-- 2010-12-29   351   1.1    renamed from pdp11_core_rri; ported to rbv3
-- 2010-10-23   335   1.2.3  rename RRI_LAM->RB_LAM;
-- 2010-06-20   308   1.2.2  use c_ibrb_ibf_ def's
-- 2010-06-18   306   1.2.1  rename RB_ADDR->RB_ADDR_CORE, add RB_ADDR_IBUS;
--                           add ibrb register and ibr window logic
-- 2010-06-13   305   1.2    add CP_ADDR in port; mostly rewritten for new
--                           rri <-> cp mapping
-- 2010-06-03   299   1.1.2  correct rbus init logic (use we, din, RB_ADDR)
-- 2010-05-02   287   1.1.1  rename RP_STAT->RB_STAT; remove unneeded unsigned()
-- 2010-05-01   285   1.1    port to rri V2 interface, add RB_ADDR generic;
--                           rename c_rp_addr_* -> c_rb_addr_*
-- 2008-05-03   143   1.0.8  rename _cpursta->_cpurust
-- 2008-04-27   140   1.0.7  use cpursta interface, remove cpufail
-- 2008-03-02   121   1.0.6  set RP_ERR when cmderr or cmdmerr status seen
-- 2008-02-24   119   1.0.5  support lah,rps,wps cp commands
-- 2008-01-20   113   1.0.4  use single LAM; change to RRI_LAM interface
-- 2007-10-12    88   1.0.3  avoid ieee.std_logic_unsigned, use cast to unsigned
-- 2007-08-16    74   1.0.2  add AP_LAM interface to pdp11_core_rri
-- 2007-08-12    73   1.0.1  use def's; add stat command; wait for step complete
-- 2007-07-08    65   1.0    Initial version 
------------------------------------------------------------------------------
--
-- rbus registers:
--
--  Addr   Bits  Name        r/w/f  Function
--
-- 00000         conf        r/w/-  cpu configuration (e.g. cpu type)
--                                   (currently unused, all bits MBZ)
-- 00001         cntl        -/f/-  cpu control
--         3:00    func               function code
--                                       0000: noop
--                                       0001: start
--                                       0010: stop
--                                       0011: step
--                                       0100: creset
--                                       0101: breset
--                                       0110: suspend
--                                       0111: resume
-- 00010         stat        r/-/-  cpu status
--            9    suspext   r/-/-    cp_stat: statext
--            8    suspint   r/-/-    cp_stat: statint
--         7:04    cpurust   r/-/-    cp_stat: cpurust
--            3    cpususp   r/-/-    cp_stat: cpususp
--            2    cpugo     r/-/-    cp_stat: cpugo
--            1    cmdmerr   r/-/-    cp_stat: cmdmerr
--            0    cmderr    r/-/-    cp_stat: cmderr
-- 00011         psw         r/w/-  processor status word access
-- 00100         al          r/w/-  address register, low
-- 00101         ah          r/w/-  address register, high
--            7    ubm       r/w/-    ubmap access
--            6    p22       r/w/-    22bit access
--         5:00    addr      r/w/-    addr(21:16)  
-- 00110         mem         r/w/-  memory access
-- 00111         memi        r/w/-  memory access, inc address
-- 01rrr         gpr[]       r/w/-  general purpose regs
-- 10000         membe       r/w/-  memory write byte enables
--            3    stick     r/w/-    sticky flag
--         1:00    be        r/w/-    byte enables
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.rblib.all;
use work.pdp11.all;

-- ----------------------------------------------------------------------------

entity pdp11_core_rbus is               -- core to rbus interface
  generic (
    RB_ADDR_CORE : slv16 := slv(to_unsigned(16#0000#,16));
    RB_ADDR_IBUS : slv16 := slv(to_unsigned(16#4000#,16)));
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit;                   -- reset
    RB_MREQ : in rb_mreq_type;          -- rbus: request
    RB_SRES : out rb_sres_type;         -- rbus: response
    RB_STAT : out slv4;                 -- rbus: status flags
    RB_LAM : out slbit;                 -- remote attention
    GRESET : out slbit;                 -- general reset
    CP_CNTL : out cp_cntl_type;         -- console control port
    CP_ADDR : out cp_addr_type;         -- console address port
    CP_DIN : out slv16;                 -- console data in
    CP_STAT : in cp_stat_type;          -- console status port
    CP_DOUT : in slv16                  -- console data out
  );
end pdp11_core_rbus;


architecture syn of pdp11_core_rbus is

  type state_type is (
    s_idle,                             -- s_idle: wait for rp access
    s_cpwait,                           -- s_cpwait: wait for cp port ack
    s_cpstep                            -- s_cpstep: wait for cpustep done
  );
  
  type regs_type is record
    state : state_type;                 -- state
    rbselc : slbit;                     -- rbus select for core
    rbseli : slbit;                     -- rbus select for ibus
    rbinit : slbit;                     -- rbus init seen (1 cycle pulse)
    cpreq : slbit;                      -- cp request flag
    cpfunc : slv5;                      -- cp function
    cpugo_1 : slbit;                    -- prev cycle cpugo
    addr : slv22_1;                     -- address register
    ena_22bit : slbit;                  -- 22bit enable
    ena_ubmap : slbit;                  -- ubmap enable
    membe : slv2;                       -- memory write byte enables
    membestick : slbit;                 -- memory write byte enables sticky
    doinc : slbit;                      -- at cmdack: do addr reg inc
    waitstep : slbit;                   -- at cmdack: wait for cpu step complete
  end record regs_type;

  constant regs_init : regs_type := (
    s_idle,                             -- state
    '0','0',                            -- rbselc,rbseli
    '0',                                -- rbinit
    '0',                                -- cpreq
    (others=>'0'),                      -- cpfunc
    '0',                                -- cpugo_1
    (others=>'0'),                      -- addr
    '0','0',                            -- ena_22bit, ena_ubmap
    "11",'0',                           -- membe,membestick
    '0','0'                             -- doinc, waitstep
  );

  signal R_REGS : regs_type := regs_init;  -- state registers
  signal N_REGS : regs_type := regs_init;  -- next value state regs

  begin
    
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

  proc_next: process (R_REGS, RB_MREQ, CP_STAT, CP_DOUT)

    variable r : regs_type := regs_init;
    variable n : regs_type := regs_init;

    variable irb_ack  : slbit := '0';
    variable irb_busy : slbit := '0';
    variable irb_err  : slbit := '0';
    variable irb_dout : slv16 := (others=>'0');
    variable irb_lam  : slbit := '0';
    variable irbena   : slbit := '0';

    variable icpreq    : slbit := '0';
    variable icpaddr   : cp_addr_type := cp_addr_init;
    
  begin

    r := R_REGS;
    n := R_REGS;

    irb_ack  := '0';
    irb_busy := '0';
    irb_err  := '0';
    irb_dout := (others=>'0');
    irb_lam  := '0';

    irbena  := RB_MREQ.re or RB_MREQ.we;

    icpreq    := '0';

    -- generate single cycle pulse in case init against rbus base address seen
    -- is used to generate some state machine resets via GRESET
    n.rbinit := '0';
    if RB_MREQ.init='1' and RB_MREQ.addr=RB_ADDR_CORE then
      n.rbinit := RB_MREQ.din(0);
    end if;    

    -- rbus address decoder
    n.rbseli := '0';
    n.rbselc := '0';
    if RB_MREQ.aval='1' then
      if RB_MREQ.addr(15 downto 5)=RB_ADDR_CORE(15 downto 5) then
        n.rbselc := '1';
      end if;
      if RB_MREQ.addr(15 downto 12)=RB_ADDR_IBUS(15 downto 12) then
        n.rbseli := '1';
      end if;
    end if;

    if (r.rbselc='1' or r.rbseli='1') and irbena='1' then
      irb_ack  := '1';                   -- ack all (maybe rejected later)
    end if;
    
    case r.state is

      when s_idle =>                    -- s_idle: wait for rbus access ------

        n.doinc    := '0';
        n.waitstep := '0';
        
        if r.rbseli = '1' then
          if irbena = '1' then
            n.cpfunc    := c_cpfunc_rmem;
            n.cpfunc(0) := RB_MREQ.we;
            icpreq := '1';
          end if;

        elsif r.rbselc = '1' then

          case RB_MREQ.addr(4 downto 0) is

            when c_rbaddr_conf =>         -- conf -------------------------
              null;                         -- currently no action

            when c_rbaddr_cntl =>         -- cntl -------------------------
              if irbena = '1' then
                n.cpfunc := RB_MREQ.din(n.cpfunc'range);
              end if;
              if RB_MREQ.we = '1' then
                icpreq := '1';
                if RB_MREQ.din(3 downto 0) = c_cpfunc_step(3 downto 0) then
                  n.waitstep := '1';
                end if;
              end if;
                
            when c_rbaddr_stat =>           -- stat ------------------
              irb_dout(c_stat_rbf_suspext) := CP_STAT.suspext;
              irb_dout(c_stat_rbf_suspint) := CP_STAT.suspint;
              irb_dout(c_stat_rbf_cpurust) := CP_STAT.cpurust;
              irb_dout(c_stat_rbf_cpususp) := CP_STAT.cpususp;
              irb_dout(c_stat_rbf_cpugo)   := CP_STAT.cpugo;
              irb_dout(c_stat_rbf_cmdmerr) := CP_STAT.cmdmerr;
              irb_dout(c_stat_rbf_cmderr)  := CP_STAT.cmderr;

            when c_rbaddr_psw  =>           -- psw -------------------
              if irbena = '1' then
                n.cpfunc    := c_cpfunc_rpsw;
                n.cpfunc(0) := RB_MREQ.we;
                icpreq := '1';
              end if;
              
            when c_rbaddr_al   =>           -- al --------------------
              irb_dout(c_al_rbf_addr) := r.addr(c_al_rbf_addr);
              if RB_MREQ.we = '1' then
                n.addr      := (others=>'0'); -- write to al clears ah !!
                n.ena_22bit := '0';
                n.ena_ubmap := '0';
                n.addr(c_al_rbf_addr) := RB_MREQ.din(c_al_rbf_addr);
              end if;

            when c_rbaddr_ah   =>           -- ah --------------------
              irb_dout(c_ah_rbf_ena_ubmap) := r.ena_ubmap;
              irb_dout(c_ah_rbf_ena_22bit) := r.ena_22bit;
              irb_dout(c_ah_rbf_addr)      := r.addr(21 downto 16);
              if RB_MREQ.we = '1' then
                n.addr(21 downto 16) := RB_MREQ.din(c_ah_rbf_addr);
                n.ena_22bit          := RB_MREQ.din(c_ah_rbf_ena_22bit);
                n.ena_ubmap          := RB_MREQ.din(c_ah_rbf_ena_ubmap);
              end if;

            when c_rbaddr_mem  =>           -- mem -------------------
              if irbena = '1' then
                n.cpfunc    := c_cpfunc_rmem;
                n.cpfunc(0) := RB_MREQ.we;
                icpreq   := '1';
              end if;
              
            when c_rbaddr_memi  =>          -- memi ------------------
              if irbena = '1' then
                n.cpfunc    := c_cpfunc_rmem;
                n.cpfunc(0) := RB_MREQ.we;
                n.doinc  := '1';
                icpreq   := '1';
              end if;
              
            when c_rbaddr_r0 | c_rbaddr_r1 |
                 c_rbaddr_r2 | c_rbaddr_r3 |
                 c_rbaddr_r4 | c_rbaddr_r5 |
                 c_rbaddr_sp | c_rbaddr_pc =>  -- r* -----------------
              if irbena = '1' then
                n.cpfunc    := c_cpfunc_rreg;
                n.cpfunc(0) := RB_MREQ.we;
                icpreq   := '1';
              end if;
              
            when c_rbaddr_membe  =>         -- membe -----------------
              irb_dout(c_membe_rbf_be)    := r.membe;
              irb_dout(c_membe_rbf_stick) := r.membestick;
              if RB_MREQ.we = '1' then
                n.membe      := RB_MREQ.din(c_membe_rbf_be);
                n.membestick := RB_MREQ.din(c_membe_rbf_stick);
              end if;
              
            when others =>
              irb_ack := '0';

          end case;

        end if; 
        
        if icpreq = '1' then
          irb_busy := '1';
          n.cpreq  := '1';
          n.state  := s_cpwait;              
        end if;          
          
      when s_cpwait =>                  -- s_cpwait: wait for cp port ack ----
        n.cpreq := '0';                   -- cpreq only for 1 cycle

        if (r.rbselc or r.rbseli)='0' or irbena='0' then -- rbus cycle abort
          if r.cpfunc = c_cpfunc_wmem and   -- if wmem command
               r.membestick = '0' then        --   and be's not sticky
            n.membe := "11";                  -- re-enable both bytes
          end if;
          n.state := s_idle;              -- quit
        else
          irb_dout := CP_DOUT;
          irb_err  := CP_STAT.cmderr or CP_STAT.cmdmerr;
          if CP_STAT.cmdack = '1' then       -- normal cycle end
            if r.cpfunc = c_cpfunc_wmem and   -- if wmem command
                 r.membestick = '0' then        --   and be's not sticky
              n.membe := "11";                  -- re-enable both bytes
            end if;
            if r.doinc = '1' then
              n.addr := slv(unsigned(r.addr) + 1);
            end if;
            if r.waitstep = '1' then
              irb_busy := '1';
              n.state := s_cpstep;            
            else
              n.state := s_idle;
            end if;
          else
            irb_busy := '1';
          end if;
        end if;

      when s_cpstep =>                  -- s_cpstep: wait for cpustep done ---
        if r.rbselc='0' or irbena='0' then -- rbus cycle abort
          n.state := s_idle;                -- quit
        else
          if CP_STAT.cpustep = '0' then      -- cpustep done
            n.state := s_idle;
          else
            irb_busy := '1';
          end if;
        end if;

      when others => null;
    end case;

    icpaddr    := cp_addr_init;
    icpaddr.be := r.membe;
      
    if r.rbseli = '0' then              -- access via cp
      icpaddr.addr      := r.addr;
      icpaddr.racc      := '0';
      icpaddr.ena_22bit := r.ena_22bit;
      icpaddr.ena_ubmap := r.ena_ubmap;
    else                                -- access via ibus window
      icpaddr.addr(15 downto 13) := "111";
      icpaddr.addr(12 downto 1)  := RB_MREQ.addr(11 downto 0);
      icpaddr.racc      := '1';
      icpaddr.ena_22bit := '0';
      icpaddr.ena_ubmap := '0';
    end if;
    
    n.cpugo_1 := CP_STAT.cpugo;         -- delay cpugo 
    if CP_STAT.cpugo='0' and r.cpugo_1='1' then  -- cpugo 1 -> 0 transition ?
      irb_lam := '1';
    end if;
    
    N_REGS <= n;
    
    RB_SRES.ack  <= irb_ack;
    RB_SRES.err  <= irb_err;
    RB_SRES.busy <= irb_busy;
    RB_SRES.dout <= irb_dout;
    
    RB_STAT(3) <= CP_STAT.cmderr;
    RB_STAT(2) <= CP_STAT.cmdmerr;
    RB_STAT(1) <= CP_STAT.cpususp;
    RB_STAT(0) <= CP_STAT.cpugo;

    RB_LAM     <= irb_lam;

    GRESET     <= R_REGS.rbinit;
    
    CP_CNTL.req  <= r.cpreq;
    CP_CNTL.func <= r.cpfunc;
    CP_CNTL.rnum <= RB_MREQ.addr(2 downto 0);

    CP_ADDR <= icpaddr;
    CP_DIN  <= RB_MREQ.din;
    
  end process proc_next;

end syn;
