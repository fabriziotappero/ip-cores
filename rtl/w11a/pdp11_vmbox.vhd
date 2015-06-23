-- $Id: pdp11_vmbox.vhd 677 2015-05-09 21:52:32Z mueller $
--
-- Copyright 2006-2015 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Module Name:    pdp11_vmbox - syn
-- Description:    pdp11: virtual memory
--
-- Dependencies:   pdp11_mmu
--                 pdp11_ubmap
--                 ibus/ib_sres_or_4
--                 ibus/ib_sres_or_2
--                 ibus/ib_sel
--
-- Test bench:     tb/tb_pdp11_core (implicit)
-- Target Devices: generic
-- Tool versions:  ise 8.2-14.7; viv 2014.4; ghdl 0.18-0.31
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2015-04-04   662   1.6.4  atowidth now 6 (was 5) to support ibdr_rprm reset
-- 2011-11-18   427   1.6.3  now numeric_std clean
-- 2010-10-23   335   1.6.2  add r.paddr_iopage, use ib_sel
-- 2010-10-22   334   1.6.1  deassert ibus be's at end-cycle; fix rmw logic
-- 2010-10-17   333   1.6    implement ibus V2 interface
-- 2010-06-27   310   1.5    redo ibus driver logic, now ibus driven from flops
-- 2010-06-20   307   1.4.2  rename cpacc to cacc in vm_cntl_type, mmu_cntl_type
-- 2010-06-18   306   1.4.1  for cpacc: set cacc in ib_mreq, forward racc,be
--                           from CP_ADDR; now all ibr handling via vmbox
-- 2010-06-13   305   1.4    rename CPADDR -> CP_ADDR
-- 2009-06-01   221   1.3.8  add dip signal in ib_mreq (set in s_ib)
-- 2009-05-30   220   1.3.7  final removal of snoopers (were already commented)
-- 2009-05-01   211   1.3.6  BUGFIX: add 177776 stack protect (SCCE)
-- 2008-08-22   161   1.3.5  rename pdp11_ibres_ -> ib_sres_, ubf_ -> ibf_
-- 2008-04-25   138   1.3.4  add BRESET port, clear stklim with BRESET
-- 2008-04-20   137   1.3.3  add DM_STAT_VM port
-- 2008-03-19   127   1.3.2  ignore ack state when waiting on a busy IB in s_ib
-- 2008-03-02   121   1.3.1  remove snoopers
-- 2008-02-24   119   1.3    revamp paddr generation; add _ubmap
-- 2008-02-23   118   1.2.1  use sys_conf_mem_losize
-- 2008-02-17   117   1.2    use em_(mreq|sres) interface for external memory
-- 2008-01-26   114   1.1.4  rename 'ubus' to 'ib' (proper name of intbus now)
-- 2008-01-05   110   1.1.3  update snooper.
--                           rename IB_MREQ(ena->req) SRES(sel->ack, hold->busy)
-- 2008-01-01   109   1.1.2  Use IB_SRES_(CPU|EXT); use r./n. coding style, move
--                           all status into regs_type. add intbus HOLD support.
-- 2007-12-30   108   1.1.1  use ubf_byte[01]
-- 2007-12-30   107   1.1    Use IB_MREQ/IB_SRES interface now; remove DMA port
-- 2007-09-16    83   1.0.2  Use ram_1swsr_wfirst_gen, not ram_2swsr_wfirst_gen
--                           2nd port was unused, connected ADDR caused slow net
-- 2007-06-14    56   1.0.1  Use slvtypes.all
-- 2007-05-12    26   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.iblib.all;
use work.pdp11.all;
use work.sys_conf.all;

-- ----------------------------------------------------------------------------

entity pdp11_vmbox is                   -- virtual memory
  port (
    CLK : in slbit;                     -- clock
    GRESET : in slbit;                  -- general reset
    CRESET : in slbit;                  -- cpu reset
    BRESET : in slbit;                  -- bus reset
    CP_ADDR : in cp_addr_type;          -- console port address
    VM_CNTL : in vm_cntl_type;          -- vm control port
    VM_ADDR : in slv16;                 -- vm address
    VM_DIN : in slv16;                  -- vm data in
    VM_STAT : out vm_stat_type;         -- vm status port
    VM_DOUT : out slv16;                -- vm data out
    EM_MREQ : out em_mreq_type;         -- external memory: request
    EM_SRES : in em_sres_type;          -- external memory: response
    MMU_MONI : in mmu_moni_type;        -- mmu monitor port
    IB_MREQ_M : out ib_mreq_type;       -- ibus request  (master)
    IB_SRES_CPU : in ib_sres_type;      -- ibus response (CPU registers)
    IB_SRES_EXT : in ib_sres_type;      -- ibus response (external devices)
    DM_STAT_VM : out dm_stat_vm_type    -- debug and monitor status
  );
end pdp11_vmbox;

architecture syn of pdp11_vmbox is

  constant ibaddr_slim : slv16 := slv(to_unsigned(8#177774#,16)); 
  constant atowidth : natural := 6;     -- size of access timeout counter
  
  type state_type is (
    s_idle,                             -- s_idle: wait for vm_cntl request
    s_mem_w,                            -- s_mem_w: check mmu, wait for memory
    s_ib_w,                             -- s_ib_w: wait for ibus
    s_ib_wend,                          -- s_ib_wend: ibus write completion
    s_ib_rend,                          -- s_ib_rend: ibus read completion
    s_idle_mw_ib,                       -- s_idle_mw_ib: wait macc write (ibus)
    s_idle_mw_mem,                      -- s_idle_mw_mem: wait macc write (mem)
    s_mem_mw_w,                         -- s_mem_mw_w: wait for memory (macc)
    s_fail,                             -- s_fail: vmbox fatal error catcher
    s_errrsv,                           -- s_errrsv: red stack violation
    s_errib                             -- s_errib: ibus error handler
  );

  type regs_type is record              -- state registers
    state : state_type;                 -- state
    wacc : slbit;                       -- write access
    macc : slbit;                       -- modify access (r-m-w sequence)
    cacc : slbit;                       -- console access
    bytop : slbit;                      -- byte operation
    kstack : slbit;                     -- access through kernel stack
    ysv : slbit;                        -- yellow stack violation detected
    vaok : slbit;                       -- virtual address valid (from MMU)
    trap_mmu : slbit;                   -- mmu trace trap requested
    mdin : slv16;                       -- data input (memory order)
    paddr : slv22;                      -- physical address register
    paddr_iopage : slv9;                -- iopage base (upper 9 bits of paddr)
    atocnt : slv(atowidth-1 downto 0);  -- access timeout counter
    ibre : slbit;                       -- ibus re signal
    ibwe : slbit;                       -- ibus we signal
    ibbe : slv2;                        -- ibus be0,be1 signals
    ibrmw : slbit;                      -- ibus rmw signal
    ibcacc : slbit;                     -- ibus cacc signal
    ibracc : slbit;                     -- ibus racc signal
    ibdout : slv16;                     -- ibus dout register
  end record regs_type;

  constant atocnt_init : slv(atowidth-1 downto 0) := (others=>'1');
  constant regs_init : regs_type := (
    s_idle,                             -- state
    '0','0','0','0',                    -- wacc,macc,cacc,bytop
    '0','0','0','0',                    -- kstack,ysv,vaok,trap_mmu
    (others=>'0'),                      -- mdin
    (others=>'0'),                      -- paddr
    (others=>'0'),                      -- paddr_iopage
    atocnt_init,                        -- atocnt
    '0','0',"00",                       -- ibre,ibwe,ibbe
    '0','0','0',                        -- ibrmw,ibcacc,ibracc
    (others=>'0')                       -- ibdout
  );

  signal R_REGS : regs_type := regs_init;
  signal N_REGS : regs_type := regs_init;

  signal R_SLIM : slv8 := (others=>'0');   -- stack limit register

  signal MMU_CNTL : mmu_cntl_type := mmu_cntl_init;
  signal MMU_STAT : mmu_stat_type := mmu_stat_init;
  signal PADDRH   : slv16 := (others=>'0');

  signal IBSEL_SLIM :slbit := '0';      -- select stack limit reg
  signal IB_SRES_SLIM  : ib_sres_type := ib_sres_init;
  signal IB_SRES_MMU   : ib_sres_type := ib_sres_init;
  signal IB_SRES_UBMAP : ib_sres_type := ib_sres_init;

  signal UBMAP_MREQ : slbit := '0';
  signal UBMAP_ADDR_PM : slv22_1 := (others=>'0');

  signal IB_MREQ : ib_mreq_type := ib_mreq_init; -- ibus request  (local)
  signal IB_SRES : ib_sres_type := ib_sres_init; -- ibus response (local)
  signal IB_SRES_INT : ib_sres_type := ib_sres_init; -- ibus response (cpu)
  
begin

  MMU : pdp11_mmu
    port map (
      CLK     => CLK,
      CRESET  => CRESET,
      BRESET  => BRESET,
      CNTL    => MMU_CNTL,
      VADDR   => VM_ADDR,
      MONI    => MMU_MONI,
      STAT    => MMU_STAT,
      PADDRH  => PADDRH,
      IB_MREQ => IB_MREQ,
      IB_SRES => IB_SRES_MMU
    );

  UBMAP : pdp11_ubmap
    port map (
      CLK     => CLK,
      MREQ    => UBMAP_MREQ,
      ADDR_UB => CP_ADDR.addr(17 downto 1),
      ADDR_PM => UBMAP_ADDR_PM,
      IB_MREQ => IB_MREQ,
      IB_SRES => IB_SRES_UBMAP
    );

  SRES_OR_INT : ib_sres_or_4
    port map (
      IB_SRES_1  => IB_SRES_CPU,
      IB_SRES_2  => IB_SRES_SLIM,
      IB_SRES_3  => IB_SRES_MMU,
      IB_SRES_4  => IB_SRES_UBMAP,
      IB_SRES_OR => IB_SRES_INT
    );

  SRES_OR_ALL : ib_sres_or_2
    port map (
      IB_SRES_1  => IB_SRES_INT,
      IB_SRES_2  => IB_SRES_EXT,
      IB_SRES_OR => IB_SRES
    );

  SEL : ib_sel
    generic map (
      IB_ADDR => ibaddr_slim)
    port map (
      CLK     => CLK,
      IB_MREQ => IB_MREQ,
      SEL     => IBSEL_SLIM
    );

  proc_ibres : process (IBSEL_SLIM, IB_MREQ, R_SLIM)
    variable idout : slv16 := (others=>'0');
  begin
    idout := (others=>'0');
    if IBSEL_SLIM = '1' then
      idout(ibf_byte1) := R_SLIM;
    end if;
    IB_SRES_SLIM.dout <= idout;
    IB_SRES_SLIM.ack  <= IBSEL_SLIM and (IB_MREQ.re or IB_MREQ.we); -- ack all
    IB_SRES_SLIM.busy <= '0';
  end process proc_ibres;

  proc_slim: process (CLK)
  begin
    if rising_edge(CLK) then
      if BRESET = '1' then
        R_SLIM <= (others=>'0');
      elsif IBSEL_SLIM='1' and IB_MREQ.we='1' then
        if IB_MREQ.be1 = '1' then
          R_SLIM <= IB_MREQ.din(ibf_byte1);
        end if;
      end if;
    end if;
  end process proc_slim;

  proc_regs: process (CLK)
  begin
    if rising_edge(CLK) then
      if GRESET = '1' then
        R_REGS <= regs_init;
     else
        R_REGS <= N_REGS;
      end if;
    end if;
  end process proc_regs;

  proc_next: process (R_REGS, R_SLIM, CP_ADDR, VM_CNTL, VM_DIN, VM_ADDR,
                      IB_SRES, UBMAP_ADDR_PM,
                      EM_SRES, MMU_STAT, PADDRH)

    variable r : regs_type := regs_init;
    variable n : regs_type := regs_init;

    variable ivm_stat : vm_stat_type := vm_stat_init;
    variable ivm_dout : slv16 := (others=>'0');
    variable iem_mreq : em_mreq_type := em_mreq_init;
    variable immu_cntl : mmu_cntl_type := mmu_cntl_init;

    variable ipaddr        : slv22 := (others=>'0');
    variable ipaddr_iopage : slv9 := (others=>'0');

    variable iib_aval : slbit := '0';
    
    variable ato_go : slbit := '0';
    variable ato_end : slbit := '0';

    variable is_stackyellow : slbit := '1'; -- VM_ADDR in yellow stack zone
    variable is_stackred : slbit := '1';    -- VM_ADDR in red stack zone

    variable iubmap_mreq : slbit := '0';
    variable paddr_mmu : slbit := '0';
    variable paddr_sel : slv2  := "00";
    constant c_paddr_sel_vmaddr : slv2 := "00";
    constant c_paddr_sel_rpaddr : slv2 := "01";
    constant c_paddr_sel_cacc   : slv2 := "10";
    constant c_paddr_sel_ubmap  : slv2 := "11";

    
  begin
    
    r := R_REGS;
    n := R_REGS;

    n.state := s_fail;

    ivm_stat  := vm_stat_init;
    ivm_dout  := EM_SRES.dout;
    immu_cntl := mmu_cntl_init;

    iib_aval  := '0';
    
    iem_mreq  := em_mreq_init;
    iem_mreq.din  := VM_DIN;

    if VM_CNTL.bytop = '0' then         -- if word access
      iem_mreq.be := "11";                -- both be's
    else
      if VM_ADDR(0) = '0' then            -- if low byte
        iem_mreq.be := "01";
      else                                -- if high byte
        iem_mreq.be := "10";
        iem_mreq.din(ibf_byte1) := VM_DIN(ibf_byte0);
      end if;
    end if;

    iubmap_mreq :='0';

    paddr_mmu := '1';                   -- ipaddr selector, used in s_idle
                                        -- and overwritten in s_idle_mw_mem
    paddr_sel := "00";
    if MMU_STAT.ena_mmu='0' or VM_CNTL.cacc='1' then
      paddr_mmu := '0';
      paddr_sel := c_paddr_sel_vmaddr;
      if VM_CNTL.cacc = '1' then
        if CP_ADDR.ena_ubmap='1' and MMU_STAT.ena_ubmap='1' then
          paddr_sel := c_paddr_sel_ubmap;
        else
          paddr_sel := c_paddr_sel_cacc;
        end if;
      end if;
    end if;

    -- the iopage base is determined based on mmu regs and request type
    -- r.paddr_iopage is updated during s_idle. This way the iopage base
    -- address is determined in parallel to paddr and latched at end of s_idle.
    -- Note: is VM_CNTL.cacc here, the status in s_idle is relevant !
    
    ipaddr_iopage := "111111111";       -- iopage match pattern (for 22 bit)
    if VM_CNTL.cacc = '1' then
      if CP_ADDR.ena_22bit = '0' then
        ipaddr_iopage := "000000111";   -- 16 bit cacc
      end if;
    else
      if MMU_STAT.ena_mmu = '0' then
        ipaddr_iopage := "000000111";   -- 16 bit mode
      else
        if MMU_STAT.ena_22bit = '0' then
          ipaddr_iopage := "000011111"; -- 18 bit mode
        end if;
      end if;
    end if;
    
    ato_go := '0';                      -- default: keep access timeout in reset
    ato_end := '0';
    if unsigned(r.atocnt) = 0 then      -- if access timeout count at zero
      ato_end := '1';                   -- signal expiration
    end if;

    is_stackyellow := '0';
    is_stackred := '0';
    if unsigned(VM_ADDR(15 downto 8)) <= unsigned(R_SLIM) then
      is_stackyellow := '1';
      if unsigned(VM_ADDR(7 downto 5)) /= 7 then  -- below 340
        is_stackred := '1';
      end if;
    end if;

    if VM_ADDR(15 downto 1) = "111111111111111" then  -- vaddr == 177776
      is_stackred := '1';      
    end if;

    immu_cntl.wacc      := VM_CNTL.wacc;
    immu_cntl.macc      := VM_CNTL.macc;
    immu_cntl.cacc      := VM_CNTL.cacc;
    immu_cntl.dspace    := VM_CNTL.dspace;
    immu_cntl.mode      := VM_CNTL.mode;
    immu_cntl.trap_done := VM_CNTL.trap_done;
      
    case r.state is
      when s_idle =>                    -- s_idle: wait for vm_cntl request --
        n.state := s_idle;
        iubmap_mreq := '1';             -- activate ubmap always in s_idle

        if VM_CNTL.req = '1' then
          n.wacc   := VM_CNTL.wacc;
          n.macc   := VM_CNTL.macc;
          n.cacc   := VM_CNTL.cacc;
          n.bytop  := VM_CNTL.bytop;
          n.kstack := VM_CNTL.kstack;
          n.ysv    := '0';
          n.vaok   := MMU_STAT.vaok;
          n.trap_mmu := MMU_STAT.trap;
          n.mdin   := iem_mreq.din;
          -- n.paddr assignment handled separately in 'if state=s_idle' at the
          -- end. 
          
          immu_cntl.req := '1';
          
          if VM_CNTL.wacc='1' and VM_CNTL.macc='1' then
            n.state := s_fail;
            
          elsif VM_CNTL.kstack='1' and VM_CNTL.intrsv='0' and
                is_stackred='1' then
            n.state := s_errrsv;
            
          else
            iem_mreq.req := '1';
            iem_mreq.we  := VM_CNTL.wacc;
            if VM_CNTL.kstack='1'and VM_CNTL.intrsv='0'  then
              n.ysv := is_stackyellow;
            end if;
            n.state := s_mem_w;
          end if;
        end if;

      when s_mem_w =>                   -- s_mem_w: check mmu, wait for memory
        
        if r.bytop='0' and r.paddr(0)='1' then -- odd address ?
          ivm_stat.err := '1';
          ivm_stat.err_odd := '1';
          ivm_stat.err_rsv := r.kstack;      -- escalate to rsv if kstack
          iem_mreq.cancel  := '1';           -- cancel pending mem request
          n.state := s_idle;            

        elsif r.vaok = '0' then          -- MMU abort ?
          ivm_stat.err := '1';
          ivm_stat.err_mmu := '1';
          ivm_stat.err_rsv := r.kstack;      -- escalate to rsv if kstack
          iem_mreq.cancel  := '1';           -- cancel pending mem request
          n.state := s_idle;

        else
          if r.paddr(21 downto 13) = r.paddr_iopage then
                                             -- I/O page decoded
            iem_mreq.cancel  := '1';         -- cancel pending mem request
            iib_aval := '1';                 -- declare ibus addr valid
            n.ibre   := not r.wacc;
            n.ibwe   := r.wacc;
            n.ibcacc := r.cacc;
            n.ibracc := r.cacc and CP_ADDR.racc;
            n.ibbe   := "11";
            if r.cacc = '1' then               -- console access ?
              n.ibbe   := CP_ADDR.be;
            else                               -- cpu access ?
              if r.bytop = '1' then
                if r.paddr(0) = '0' then
                  n.ibbe(1) := '0';
                else
                  n.ibbe(0) := '0';
                end if;
              end if;
            end if;
            n.ibrmw  := r.macc;
            n.state  := s_ib_w;

          else
            if unsigned(r.paddr(21 downto 6)) > sys_conf_mem_losize then
              ivm_stat.err := '1';
              ivm_stat.err_nxm := '1';
              ivm_stat.err_rsv := r.kstack;   -- escalate to rsv if kstack
              iem_mreq.cancel  := '1';        -- cancel pending mem request
              n.state := s_idle;

            else

              if EM_SRES.ack_r='1' or EM_SRES.ack_w='1' then
                ivm_stat.ack := '1';
                ivm_stat.trap_ysv := r.ysv;
                ivm_stat.trap_mmu := r.trap_mmu;
                if r.macc='1' and r.wacc='0' then
                  n.state := s_idle_mw_mem;
                else
                  n.state := s_idle;
                end if;
              else
                n.state := s_mem_w;     -- keep waiting
              end if;
        
            end if;
          end if;
        end if;
                  
      when s_ib_w =>                    -- s_ib_w: wait for ibus -------------
        ato_go := '1';                    -- activate timeout counter

        iib_aval := '1';                  -- declare ibus addr valid

        n.ibre   := '0';                  -- end cycle, unless busy seen
        n.ibwe   := '0';
        n.ibrmw  := '0';
        n.ibbe   := "00";
        n.ibcacc := '0';
        n.ibracc := '0';
          
        if IB_SRES.ack='1' and IB_SRES.busy='0' then -- ibus cycle finished
          if r.wacc = '1' then
            n.state := s_ib_wend;
          else
            if r.macc = '1' then          -- if first part of rmw
              n.ibrmw  := r.macc;           -- keep rmw 
              n.ibbe   := r.ibbe;           -- keep be's
              n.ibcacc := r.ibcacc;
              n.ibracc := r.ibracc;
            end if;
            n.ibdout := IB_SRES.dout;
            n.state  := s_ib_rend;
          end if;
        elsif IB_SRES.busy='1' and ato_end='0' then
          n.ibre   := r.ibre;             -- continue ibus cycle
          n.ibwe   := r.ibwe;
          n.ibrmw  := r.ibrmw;
          n.ibbe   := r.ibbe;
          n.ibcacc := r.ibcacc;
          n.ibracc := r.ibracc;
          n.state := s_ib_w;
        else
          n.state := s_errib;
        end if;
        
      when s_ib_wend =>                 -- s_ib_wend: ibus write completion --
        ivm_stat.ack := '1';
        n.state := s_idle;

      when s_ib_rend =>                 -- s_ib_rend: ibus read completion ---
        ivm_stat.ack := '1';
        ivm_dout := r.ibdout;
        if r.macc='1' then                -- first part of read-mod-write
          iib_aval := '1';                  -- keep ibus addr valid
          n.state := s_idle_mw_ib;
        else
          n.state := s_idle;
        end if;

      when s_idle_mw_ib =>              -- s_idle_mw_ib: wait macc write (ibus)
        n.state := s_idle_mw_ib;
        iib_aval := '1';                  -- keep ibus addr valid
        if r.ibbe = "10" then
          iem_mreq.din(ibf_byte1) := VM_DIN(ibf_byte0);
        end if;
        if VM_CNTL.req = '1' then
          n.wacc  := VM_CNTL.wacc;
          n.macc  := VM_CNTL.macc;
          n.mdin  := iem_mreq.din;
          if VM_CNTL.wacc='0' or VM_CNTL.macc='0' then
            n.state := s_fail;
          else
            n.ibwe  := '1';                 -- Note: all other ibus drivers
                                            --   already set in 1st part
            n.state := s_ib_w;
          end if;
        end if;

      when s_idle_mw_mem =>             -- s_idle_mw_mem: wait macc write (mem)
        n.state := s_idle_mw_mem;

        paddr_mmu := '0';
        paddr_sel := c_paddr_sel_rpaddr;

        if VM_CNTL.bytop = '0' then     -- if word access
          iem_mreq.be := "11";            -- both be's
        else
          if r.paddr(0) = '0' then        -- if low byte
            iem_mreq.be := "01";
          else                            -- if high byte
            iem_mreq.be := "10";
            iem_mreq.din(ibf_byte1) := VM_DIN(ibf_byte0);
          end if;
        end if;
        
        if VM_CNTL.req = '1' then
          n.wacc  := VM_CNTL.wacc;
          n.macc  := VM_CNTL.macc;
          n.bytop := VM_CNTL.bytop;
          n.mdin  := iem_mreq.din;
          
          if VM_CNTL.wacc='0' or VM_CNTL.macc='0' then
            n.state := s_fail;
          else
            iem_mreq.req := '1';
            iem_mreq.we  := '1';              
            n.state := s_mem_mw_w;
          end if;
        end if;

      when s_mem_mw_w =>                -- s_mem_mw_w: wait for memory (macc)
        if EM_SRES.ack_w = '1' then
          ivm_stat.ack := '1';
          n.state := s_idle;
        else
          n.state := s_mem_mw_w;        -- keep waiting
        end if;

      when s_fail =>                    -- s_fail: vmbox fatal error catcher
        ivm_stat.fail := '1';
        n.state := s_idle;

      when s_errrsv =>                  -- s_errrsv: red stack violation -----
        ivm_stat.err := '1';
        ivm_stat.err_rsv := '1';
        n.state := s_idle;

      when s_errib =>                   -- s_errib: ibus error handler -------
        ivm_stat.err := '1';
        ivm_stat.err_iobto := '1';
        ivm_stat.err_rsv := r.kstack;    -- escalate to rsv if kstack
        n.state := s_idle;

      when others => null;
    end case;

    if r.bytop='1' and r.paddr(0)='1' then
      ivm_dout(ibf_byte0) := ivm_dout(ibf_byte1);
    end if;

    if ato_go = '0' then                -- handle access timeout counter
      n.atocnt := atocnt_init;          -- if ato_go=0, keep in reset
    else
      n.atocnt := slv(unsigned(r.atocnt) - 1);-- otherwise count down
    end if;

    ipaddr := (others=>'0');            
    if paddr_mmu = '1' then
      ipaddr( 5 downto 0) := VM_ADDR(5 downto 0);
      ipaddr(21 downto 6) := PADDRH;
      if MMU_STAT.ena_22bit = '0' then
        ipaddr(21 downto 18) := (others=>'0');
      end if;
    else
      case paddr_sel is
        when c_paddr_sel_vmaddr  =>
          ipaddr(15 downto 0) := VM_ADDR(15 downto 0);
        when c_paddr_sel_rpaddr => 
          ipaddr := r.paddr;
        when c_paddr_sel_cacc  =>
          ipaddr := CP_ADDR.addr & '0';
          if CP_ADDR.ena_22bit = '0' then
            ipaddr(21 downto 16) := (others=>'0');
          end if;
        when c_paddr_sel_ubmap  => 
          ipaddr := UBMAP_ADDR_PM & '0';
        when others => null;
      end case;
    end if;

    if r.state = s_idle then
      n.paddr        := ipaddr;
      n.paddr_iopage := ipaddr_iopage;
    end if;
    
    iem_mreq.addr := ipaddr(21 downto 1);
    
    N_REGS <= n;

    UBMAP_MREQ <= iubmap_mreq;

    IB_MREQ.aval <= iib_aval;
    IB_MREQ.re   <= r.ibre;
    IB_MREQ.we   <= r.ibwe;
    IB_MREQ.be0  <= r.ibbe(0);
    IB_MREQ.be1  <= r.ibbe(1);
    IB_MREQ.rmw  <= r.ibrmw;
    IB_MREQ.cacc <= r.ibcacc;
    IB_MREQ.racc <= r.ibracc;
    IB_MREQ.addr <= r.paddr(12 downto 1);
    IB_MREQ.din  <= r.mdin;
    
    VM_DOUT  <= ivm_dout;    
    VM_STAT  <= ivm_stat;
    MMU_CNTL <= immu_cntl;

    EM_MREQ  <= iem_mreq;
    
  end process proc_next;   

  IB_MREQ_M <= IB_MREQ;                 -- external drive master port

  DM_STAT_VM.ibmreq <= IB_MREQ;
  DM_STAT_VM.ibsres <= IB_SRES;

end syn;
