-- $Id: pdp11_mmu.vhd 677 2015-05-09 21:52:32Z mueller $
--
-- Copyright 2006-2011 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Module Name:    pdp11_mmu - syn
-- Description:    pdp11: mmu - memory management unit
--
-- Dependencies:   pdp11_mmu_sadr
--                 pdp11_mmu_ssr12
--                 ibus/ib_sres_or_3
--                 ibus/ib_sel
--
-- Test bench:     tb/tb_pdp11_core (implicit)
-- Target Devices: generic
-- Tool versions:  ise 8.2-14.7; viv 2014.4; ghdl 0.18-0.31
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2011-11-18   427   1.4.2  now numeric_std clean
-- 2010-10-23   335   1.4.1  use ib_sel
-- 2010-10-17   333   1.4    use ibus V2 interface
-- 2010-06-20   307   1.3.7  rename cpacc to cacc in mmu_cntl_type
-- 2009-05-30   220   1.3.6  final removal of snoopers (were already commented)
-- 2009-05-09   213   1.3.5  BUGFIX: tie inst_compl permanentely '0'
--                           BUGFIX: set ssr0 trap_mmu even when traps disabled
-- 2008-08-22   161   1.3.4  rename pdp11_ibres_ -> ib_sres_, ubf_ -> ibf_
-- 2008-04-27   139   1.3.3  allow ssr1/2 tracing even with mmu_ena=0
-- 2008-04-25   138   1.3.2  add BRESET port, clear ssr0/3 with BRESET
-- 2008-03-02   121   1.3.1  remove snoopers
-- 2008-02-24   119   1.3    return always mapped address in PADDRH; remove
--                           cpacc handling; PADDR generation now on _vmbox
-- 2008-01-05   110   1.2.1  rename _mmu_regs -> _mmu_sadr
--                           rename IB_MREQ(ena->req) SRES(sel->ack, hold->busy)
-- 2008-01-01   109   1.2    use pdp11_mmu_regs (rather than _regset)
-- 2007-12-31   108   1.1.1  remove SADR memory address mux (-> _mmu_regfile)
-- 2007-12-30   107   1.1    use IB_MREQ/IB_SRES interface now
-- 2007-06-14    56   1.0.1  Use slvtypes.all
-- 2007-05-12    26   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.iblib.all;
use work.pdp11.all;

-- ----------------------------------------------------------------------------

entity pdp11_mmu is                     -- mmu - memory management unit
  port (
    CLK : in slbit;                     -- clock
    CRESET : in slbit;                  -- cpu reset
    BRESET : in slbit;                  -- bus reset
    CNTL : in mmu_cntl_type;            -- control port
    VADDR : in slv16;                   -- virtual address
    MONI : in mmu_moni_type;            -- monitor port
    STAT : out mmu_stat_type;           -- status port
    PADDRH : out slv16;                 -- physical address (upper 16 bit)
    IB_MREQ: in ib_mreq_type;           -- ibus request
    IB_SRES: out ib_sres_type           -- ibus response
  );
end pdp11_mmu;

architecture syn of pdp11_mmu is
  
  constant ibaddr_ssr0 : slv16 := slv(to_unsigned(8#177572#,16));
  constant ibaddr_ssr3 : slv16 := slv(to_unsigned(8#172516#,16));

  constant ssr0_ibf_abo_nonres : integer := 15;
  constant ssr0_ibf_abo_length : integer := 14;
  constant ssr0_ibf_abo_rdonly : integer := 13;
  constant ssr0_ibf_trap_mmu : integer := 12;
  constant ssr0_ibf_ena_trap : integer := 9;
  constant ssr0_ibf_inst_compl : integer := 7;
  subtype  ssr0_ibf_seg_mode is integer range 6 downto 5;
  constant ssr0_ibf_dspace : integer := 4;
  subtype  ssr0_ibf_seg_num is integer range 3 downto 1;
  constant ssr0_ibf_ena_mmu : integer := 0;
  
  constant ssr3_ibf_ena_ubmap : integer := 5;
  constant ssr3_ibf_ena_22bit : integer := 4;
  constant ssr3_ibf_dspace_km : integer := 2;
  constant ssr3_ibf_dspace_sm : integer := 1;
  constant ssr3_ibf_dspace_um : integer := 0;

  signal IBSEL_SSR0 : slbit := '0';     -- ibus select SSR0
  signal IBSEL_SSR3 : slbit := '0';     -- ibus select SSR3

  signal R_SSR0 : mmu_ssr0_type := mmu_ssr0_init;
  signal N_SSR0 : mmu_ssr0_type := mmu_ssr0_init;

  signal R_SSR3 : mmu_ssr3_type := mmu_ssr3_init;

  signal ASN : slv4 := "0000";          -- augmented segment number (1+3 bit)
  signal AIB_WE : slbit := '0';         -- update AIB
  signal AIB_SETA : slbit := '0';       -- set A bit in access information bits
  signal AIB_SETW : slbit := '0';       -- set W bit in access information bits

  signal TRACE : slbit := '0';          -- enable tracing in ssr1/2
  signal DSPACE : slbit := '0';         -- use dspace

  signal IB_SRES_SADR  : ib_sres_type := ib_sres_init;
  signal IB_SRES_SSR12 : ib_sres_type := ib_sres_init;
  signal IB_SRES_SSR03 : ib_sres_type := ib_sres_init;

  signal SARSDR : sarsdr_type := sarsdr_init;

begin

  SADR : pdp11_mmu_sadr port map (
    CLK      => CLK,
    MODE     => CNTL.mode,
    ASN      => ASN,
    AIB_WE   => AIB_WE,
    AIB_SETA => AIB_SETA,
    AIB_SETW => AIB_SETW,
    SARSDR   => SARSDR,
    IB_MREQ  => IB_MREQ,
    IB_SRES  => IB_SRES_SADR);

  SSR12 : pdp11_mmu_ssr12 port map (
    CLK     => CLK,
    CRESET  => CRESET,
    TRACE   => TRACE,
    MONI    => MONI,
    IB_MREQ => IB_MREQ,
    IB_SRES => IB_SRES_SSR12);

  SRES_OR : ib_sres_or_3
    port map (
      IB_SRES_1  => IB_SRES_SADR,
      IB_SRES_2  => IB_SRES_SSR12,
      IB_SRES_3  => IB_SRES_SSR03,
      IB_SRES_OR => IB_SRES);

  SEL_SSR0 : ib_sel
    generic map (
      IB_ADDR => ibaddr_ssr0)
    port map (
      CLK     => CLK,
      IB_MREQ => IB_MREQ,
      SEL     => IBSEL_SSR0
    );
  SEL_SSR3 : ib_sel
    generic map (
      IB_ADDR => ibaddr_ssr3)
    port map (
      CLK     => CLK,
      IB_MREQ => IB_MREQ,
      SEL     => IBSEL_SSR3
    );

  proc_ibres : process (IBSEL_SSR0, IBSEL_SSR3, IB_MREQ, R_SSR0, R_SSR3)

    variable ssr0out : slv16 := (others=>'0');
    variable ssr3out : slv16 := (others=>'0');

  begin

    ssr0out := (others=>'0');
    if IBSEL_SSR0 = '1' then
      ssr0out(ssr0_ibf_abo_nonres) := R_SSR0.abo_nonres;
      ssr0out(ssr0_ibf_abo_length) := R_SSR0.abo_length;
      ssr0out(ssr0_ibf_abo_rdonly) := R_SSR0.abo_rdonly;
      ssr0out(ssr0_ibf_trap_mmu)   := R_SSR0.trap_mmu;
      ssr0out(ssr0_ibf_ena_trap)   := R_SSR0.ena_trap;
      ssr0out(ssr0_ibf_inst_compl) := R_SSR0.inst_compl;
      ssr0out(ssr0_ibf_seg_mode)   := R_SSR0.seg_mode;
      ssr0out(ssr0_ibf_dspace)     := R_SSR0.dspace;
      ssr0out(ssr0_ibf_seg_num)    := R_SSR0.seg_num;
      ssr0out(ssr0_ibf_ena_mmu)    := R_SSR0.ena_mmu;
    end if;
    
    ssr3out := (others=>'0');
    if IBSEL_SSR3 = '1' then
      ssr3out(ssr3_ibf_ena_ubmap) := R_SSR3.ena_ubmap;
      ssr3out(ssr3_ibf_ena_22bit) := R_SSR3.ena_22bit;
      ssr3out(ssr3_ibf_dspace_km) := R_SSR3.dspace_km;
      ssr3out(ssr3_ibf_dspace_sm) := R_SSR3.dspace_sm;
      ssr3out(ssr3_ibf_dspace_um) := R_SSR3.dspace_um;
    end if;
 
    IB_SRES_SSR03.dout <= ssr0out or ssr3out;
    IB_SRES_SSR03.ack  <= (IBSEL_SSR0 or IBSEL_SSR3) and
                          (IB_MREQ.re or IB_MREQ.we); -- ack all
    IB_SRES_SSR03.busy <= '0';

  end process proc_ibres;

  proc_ssr0 : process (CLK)
  begin
    if rising_edge(CLK) then
      if BRESET = '1' then
        R_SSR0 <= mmu_ssr0_init;
      else
        R_SSR0 <= N_SSR0;
      end if;
    end if;
  end process proc_ssr0;

  proc_ssr3 : process (CLK)
  begin
    if rising_edge(CLK) then
      if BRESET = '1' then
        R_SSR3 <= mmu_ssr3_init;
      elsif IBSEL_SSR3='1' and IB_MREQ.we='1' then
        if IB_MREQ.be0 = '1' then
          R_SSR3.ena_ubmap <= IB_MREQ.din(ssr3_ibf_ena_ubmap);
          R_SSR3.ena_22bit <= IB_MREQ.din(ssr3_ibf_ena_22bit);
          R_SSR3.dspace_km <= IB_MREQ.din(ssr3_ibf_dspace_km);
          R_SSR3.dspace_sm <= IB_MREQ.din(ssr3_ibf_dspace_sm);
          R_SSR3.dspace_um <= IB_MREQ.din(ssr3_ibf_dspace_um);
        end if;
      end if;
    end if;
  end process proc_ssr3;

  proc_paddr : process (R_SSR0, R_SSR3, CNTL, SARSDR, VADDR)
    
    variable ipaddrh : slv16 := (others=>'0');
    variable dspace_ok : slbit := '0';
    variable dspace_en : slbit := '0';
    variable asf : slv3 := (others=>'0'); -- va: active segment field
    variable bn : slv7 := (others=>'0');  -- va: block number
    variable iasn : slv4 := (others=>'0');-- augmented segment number
    
  begin
    
    asf := VADDR(15 downto 13);
    bn := VADDR(12 downto 6);

    dspace_en := '0';
    case CNTL.mode is
      when "00" => dspace_en := R_SSR3.dspace_km;
      when "01" => dspace_en := R_SSR3.dspace_sm;
      when "11" => dspace_en := R_SSR3.dspace_um;
      when others => null;
    end case;
    dspace_ok := CNTL.dspace and dspace_en;
    
    iasn(3) := dspace_ok;
    iasn(2 downto 0) := asf;

    ipaddrh := slv(unsigned("000000000"&bn) + unsigned(SARSDR.saf));

    DSPACE <= dspace_ok;
    ASN    <= iasn;
    PADDRH <= ipaddrh;
    
  end process proc_paddr;
                         
  proc_nssr0 : process (R_SSR0, R_SSR3, IB_MREQ, IBSEL_SSR0, DSPACE, 
                        CNTL, MONI, SARSDR, VADDR)
    
    variable nssr0 : mmu_ssr0_type := mmu_ssr0_init;
    variable asf : slv3 := (others=>'0');
    variable bn : slv7 := (others=>'0'); 
    variable abo_nonres : slbit := '0';
    variable abo_length : slbit := '0';
    variable abo_rdonly : slbit := '0';
    variable ssr_freeze : slbit := '0';
    variable doabort : slbit := '0';
    variable dotrap : slbit := '0';
    variable dotrace : slbit := '0';
    
  begin
    
    nssr0 := R_SSR0;

    AIB_WE   <= '0';
    AIB_SETA <= '0';
    AIB_SETW <= '0';

    ssr_freeze := R_SSR0.abo_nonres or R_SSR0.abo_length or R_SSR0.abo_rdonly;
    dotrace := not(CNTL.cacc or ssr_freeze);
    
    asf := VADDR(15 downto 13);
    bn := VADDR(12 downto 6);

    abo_nonres := '0';
    abo_length := '0';
    abo_rdonly := '0';
    doabort := '0';
    dotrap := '0';
    
    if SARSDR.ed = '0' then             -- ed=0: upward expansion
      if unsigned(bn) > unsigned(SARSDR.slf) then
        abo_length := '1';
      end if;
    else                                -- ed=0: downward expansion
      if unsigned(bn) < unsigned(SARSDR.slf) then
        abo_length := '1';
      end if;
    end if;

    case SARSDR.acf is                  -- evaluate accecc control field

      when "000" =>                     -- segment non-resident
        abo_nonres := '1';

      when "001" =>                     -- read-only; trap on read
        if CNTL.wacc='1' or CNTL.macc='1' then
          abo_rdonly := '1';
        end if;
        dotrap := '1';

      when "010" =>                     -- read-only
        if CNTL.wacc='1'  or CNTL.macc='1' then
          abo_rdonly := '1';
        end if;

      when "100" =>                     -- read/write; trap on read&write
        dotrap := '1';

      when "101" =>                     -- read/write; trap on write
        dotrap := CNTL.wacc or CNTL.macc;

      when "110" => null;               -- read/write;

      when others =>                    -- unused codes: abort access
        abo_nonres := '1';
    end case;

    if IBSEL_SSR0='1' and IB_MREQ.we='1' then

      if IB_MREQ.be1 = '1' then
        nssr0.abo_nonres := IB_MREQ.din(ssr0_ibf_abo_nonres);
        nssr0.abo_length := IB_MREQ.din(ssr0_ibf_abo_length);
        nssr0.abo_rdonly := IB_MREQ.din(ssr0_ibf_abo_rdonly);
        nssr0.trap_mmu   := IB_MREQ.din(ssr0_ibf_trap_mmu);
        nssr0.ena_trap   := IB_MREQ.din(ssr0_ibf_ena_trap);
      end if;
      if IB_MREQ.be0 = '1' then
        nssr0.ena_mmu := IB_MREQ.din(ssr0_ibf_ena_mmu);
      end if;        
      
    elsif nssr0.ena_mmu='1' and CNTL.cacc='0' then

      if dotrace = '1' then
        if MONI.istart = '1' then
          nssr0.inst_compl := '0';
        elsif MONI.idone = '1' then
          nssr0.inst_compl := '0';      -- disable instr.compl logic 
        end if;
      end if;
      
      if CNTL.req = '1' then      
        AIB_WE <= '1';        
        if ssr_freeze = '0' then 
          nssr0.abo_nonres := abo_nonres;
          nssr0.abo_length := abo_length;
          nssr0.abo_rdonly := abo_rdonly;          
        end if;
        doabort := abo_nonres or abo_length or abo_rdonly;

        if doabort = '0' then
          AIB_SETA <= '1';
          AIB_SETW <= CNTL.wacc or CNTL.macc;
        end if;

        if ssr_freeze = '0' then
          nssr0.dspace   := DSPACE;
          nssr0.seg_num  := asf;
          nssr0.seg_mode := CNTL.mode;
        end if;
      end if;
    end if;

    if CNTL.req='1' and R_SSR0.ena_mmu='1' and CNTL.cacc='0' and
       dotrap='1' then
      nssr0.trap_mmu := '1';
    end if;

    nssr0.trace_prev := dotrace;

    if MONI.trace_prev = '0' then
      TRACE <= dotrace;
    else
      TRACE <= R_SSR0.trace_prev;
    end if;

    N_SSR0 <= nssr0;

    if R_SSR0.ena_mmu='1' and CNTL.cacc='0' then
      STAT.vaok <= not doabort;
    else
      STAT.vaok <= '1';
    end if;

    if R_SSR0.ena_mmu='1' and CNTL.cacc='0' and doabort='0' and
       R_SSR0.ena_trap='1' and R_SSR0.trap_mmu='0' and dotrap='1' then
      STAT.trap <= '1';
    else
      STAT.trap <= '0';
    end if;

    STAT.ena_mmu   <= R_SSR0.ena_mmu;
    STAT.ena_22bit <= R_SSR3.ena_22bit;
    STAT.ena_ubmap <= R_SSR3.ena_ubmap;
    
  end process proc_nssr0;

end syn;
