-- $Id: ibdr_rl11.vhd 655 2015-03-04 20:35:21Z mueller $
--
-- Copyright 2014-2015 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Module Name:    ibdr_rl11 - syn
-- Description:    ibus dev(rem): RL11
--
-- Dependencies:   ram_1swar_gen
-- Test bench:     -
-- Target Devices: generic
-- Tool versions:  ise 14.7; viv 2014.4; ghdl 0.31
--
-- Synthesized (xst):
-- Date         Rev  ise         Target      flop lutl lutm slic t peri
-- 2015-02-28   653 14.7  131013 xc6slx16-2    80  197   12   80 s  7.9
-- 2014-06-15   562 14.7  131013 xc6slx16-2    81  199   13   78 s  8.0
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2015-03-04   655   1.0.1  seek: ignore da(6:5), don't check for 0 anymore
-- 2015-02-28   653   1.0    Initial verison
-- 2014-06-09   561   0.1    First draft
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.memlib.all;
use work.iblib.all;

-- ----------------------------------------------------------------------------
entity ibdr_rl11 is                     -- ibus dev(rem): RL11
                                        -- fixed address: 174400
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
end ibdr_rl11;

architecture syn of ibdr_rl11 is

  constant ibaddr_rl11 : slv16 := slv(to_unsigned(8#174400#,16));

  constant ibaddr_rlcs : slv2 := "00";  -- rlcs address offset
  constant ibaddr_rlba : slv2 := "01";  -- rlba address offset
  constant ibaddr_rlda : slv2 := "10";  -- rlda address offset
  constant ibaddr_rlmp : slv2 := "11";  -- rlmp address offset

  -- usage of 16x16 memory bank
  --      0  0000   unused (but mirrors rlcs)
  --      1  0001   rlba
  --      2  0010   unused (but mirrors rlda)
  --      3  0011   rlmp (1st value)
  --      4  0100   rlmp (3rd value after gs; the crc)
  --      5  0101   unused
  --      6  0110   unused
  --      7  0111   unused (target for bad mprem states)
  --  11: 8  10--   sta(ds)  (drive status)
  --  15:12  11--   pos(ds)  (drive disk address)
  constant imem_cs  : slv4 := "0000";   -- unused
  constant imem_ba  : slv4 := "0001";
  constant imem_da  : slv4 := "0010";   -- unused
  constant imem_mp  : slv4 := "0011";
  constant imem_crc : slv4 := "0100";
  constant imem_bad : slv4 := "0111";   -- target for bad mprem states
  constant imem_sta : slv4 := "1000";
  constant imem_pos : slv4 := "1100";

  subtype  imf_typ  is integer range 3 downto 2;
  subtype  imf_ds   is integer range 1 downto 0;

  constant rlcs_ibf_err   : integer := 15;
  constant rlcs_ibf_de    : integer := 14;
  subtype  rlcs_ibf_e       is integer range 13 downto 10;
  subtype  rlcs_ibf_ds      is integer range  9 downto  8;
  constant rlcs_ibf_crdy  : integer :=  7;
  constant rlcs_ibf_ie    : integer :=  6;
  subtype  rlcs_ibf_bae     is integer range  5 downto  4;
  subtype  rlcs_ibf_func    is integer range  3 downto  1;
  constant rlcs_ibf_drdy  : integer :=  0;  

  constant func_noop  : slv3 := "000";   -- func: noop
  constant func_wchk  : slv3 := "001";   -- func: write check
  constant func_gs    : slv3 := "010";   -- func: get status
  constant func_seek  : slv3 := "011";   -- func: seek
  constant func_rhdr  : slv3 := "100";   -- func: read header
  constant func_write : slv3 := "101";   -- func: write data
  constant func_read  : slv3 := "110";   -- func: read data
  constant func_rnhc  : slv3 := "111";   -- func: read data without header check

  constant e_ok     : slv4 := "0000";   -- e code: ok
  constant e_incomp : slv4 := "0001";   -- e code: operation incomplete

  -- defs for rem access of rlcs; func codes
  constant rfunc_wcs     : slv3 := "001";  -- rem func: write cs (err,de,e,drdy)
  constant rfunc_wmp     : slv3 := "010";  -- rem func: write mprem or mploc

  -- rlcs usage or rem func=wmp
  subtype  rlcs_ibf_mprem   is integer range 15 downto 11;
  subtype  rlcs_ibf_mploc   is integer range 10 downto  8;
  constant rlcs_ibf_ena_mprem : integer := 5;
  constant rlcs_ibf_ena_mploc : integer := 4;

  subtype  rlda_ibf_seek_df    is integer range 15 downto  7;
  constant rlda_ibf_seek_hs  : integer :=  4;
  constant rlda_ibf_seek_dir : integer :=  2;
  constant rlda_msk_seek : slv16 := "0000000000001011";
  constant rlda_val_seek : slv16 := "0000000000000001";

  constant rlda_ibf_gs_rst   : integer :=  3;
  constant rlda_msk_gs : slv16 := "0000000011110111";
  constant rlda_val_gs : slv16 := "0000000000000011";

  constant sta_ibf_wde   : integer := 15;     -- Write data error   - always 0
  constant sta_ibf_che   : integer := 14;     -- Current head error - always 0
  constant sta_ibf_wl    : integer := 13;     -- Write lock         -    used 
  constant sta_ibf_sto   : integer := 12;     -- Seek time out      -    used
  constant sta_ibf_spe   : integer := 11;     -- Spin error         -    used
  constant sta_ibf_wge   : integer := 10;     -- Write gate error   -    used
  constant sta_ibf_vce   : integer :=  9;     -- Volume check       -    used
  constant sta_ibf_dse   : integer :=  8;     -- Drive select error -    used
  constant sta_ibf_dt    : integer :=  7;     -- Drive type         -    used
  constant sta_ibf_hs    : integer :=  6;     -- Head select        -    used
  constant sta_ibf_co    : integer :=  5;     -- Cover open         -    used
  constant sta_ibf_ho    : integer :=  4;     -- Heads out          -    used
  constant sta_ibf_bh    : integer :=  3;     -- Brush home         - always 1
  subtype  sta_ibf_st      is integer range  2 downto  0;  -- Drive state

  constant st_load  : slv3 := "000";    -- st: Load(ing) cartidge -    used
  constant st_spin  : slv3 := "001";    -- st: Spin(ing) up       - !unused!
  constant st_brush : slv3 := "010";    -- st: Brush(ing) cycle   - !unused!
  constant st_hload : slv3 := "011";    -- st: Load(ing) heads    - !unused!
  constant st_seek  : slv3 := "100";    -- st: Seek(ing)          - may be used
  constant st_lock  : slv3 := "101";    -- st: Lock(ed) on        -    used
  constant st_unl   : slv3 := "110";    -- st: Unload(ing) heads  - !unused!
  constant st_down  : slv3 := "111";    -- st: Spin(ing) down     - !unused!
  -- only two mayor drive states are used
  --   on: st=lock; ho=1; co=0;    (   file connected in backend)
  --  off: st=load; ho=0; co=1;    (no file connected in backend)

  subtype  pos_ibf_ca      is integer range 15 downto  7;
  constant pos_ibf_hs    : integer :=  6;
  subtype  pos_ibf_sa      is integer range  5 downto  0;
  
  constant mploc_mp   : slv3 := "000";  -- return imem(mp)
  constant mploc_sta  : slv3 := "001";  -- return sta(ds)
  constant mploc_pos  : slv3 := "010";  -- return pos(ds)
  constant mploc_zero : slv3 := "011";  -- return 0
  constant mploc_crc  : slv3 := "100";  -- return imem(crc)

  constant mprem_f_map  : integer := 4;    -- mprem map enable
  subtype  mprem_f_addr   is integer range 3 downto 0;
  constant mprem_f_seq  : integer := 3;    -- mprem seq enable
  subtype  mprem_f_state  is integer range 2 downto 0;
  constant mprem_mapseq : slv2 := "11";    -- enable map + seq
  constant mprem_s_mp   : slv3 := "000";   -- access imem(mp)
  constant mprem_s_sta  : slv3 := "001";   -- access sta(ds)
  constant mprem_s_pos  : slv3 := "010";   -- access pos(ds)
  constant mprem_init   : slv5 := "10000"; -- enable map,fix, show mp
      
  constant ca_max_rl01 : slv9 := "011111111"; -- max cylinder for RL01 (255)
  constant ca_max_rl02 : slv9 := "111111111"; -- max cylinder for RL02 (511)
  
  type state_type is (
    s_idle,                             -- idle: handle ibus
    s_csread,                           -- csread: handle cs read
    s_gs_rpos,                          -- gs_rpos: read pos(ds)
    s_gs_sta,                           -- gs_sta: handle status
    s_seek_rsta,                        -- seek_rsta: read sta(ds)
    s_seek_rpos,                        -- seek_rpos: read pos(ds)
    s_seek_clip,                        -- seek_clip: clip new ca
    s_seek_wpos,                        -- seek_wpos: write pos(ds)
    s_init                              -- init: handle init
  );

  type regs_type is record              -- state registers
    ibsel  : slbit;                     -- ibus select
    state  : state_type;                -- state
    iaddr  : slv4;                      -- init addr counter
    cserr  : slbit;                     -- rlcs: composite error
    csde   : slbit;                     -- rlcs: drive error
    cse    : slv4;                      -- rlcs: error
    csds   : slv2;                      -- rlcs: drive select
    cscrdy : slbit;                     -- rlcs: controller ready
    csie   : slbit;                     -- rlcs: interrupt enable
    csbae  : slv2;                      -- rlcs: bus address extenstion
    csfunc : slv3;                      -- rlcs: function code
    csdrdy : slbit;                     -- rlcs: drive ready
    da     : slv16;                     -- rlda shadow reg
    gshs   : slbit;                     -- gs: pos(ds)(hs) (head select)
    seekdt : slbit;                     -- seek: drive type: 0=RL01, 1=RL02
    seekcan: slv10;                     -- seek: cylinder address, new
    seekcac: slv9;                      -- seek: cylinder address, clipped
    ireq   : slbit;                     -- interrupt request flag
    mploc  : slv3;                      -- mp loc state
    mprem  : slv5;                      -- mp rem state
    crdone : slbit;                     -- control reset done since last fdone
  end record regs_type;

  constant regs_init : regs_type := (
    '0',                                -- ibsel
    s_init,                             -- state
    imem_ba,                            -- iaddr
    '0','0',                            -- cserr,csde
    (others=>'0'),                      -- cse
    (others=>'0'),                      -- csds
    '1','0',                            -- cscrdy, csie
    (others=>'0'),                      -- csbae
    (others=>'0'),                      -- csfunc
    '0',                                -- csdrdy
    (others=>'0'),                      -- da
    '0',                                -- gshs
    '0',                                -- seekdt
    (others=>'0'),                      -- seekcan
    (others=>'0'),                      -- seekcac
    '0',                                -- ireq
    mploc_mp,                           -- mploc
    mprem_init,                         -- mprem
    '1'                                 -- crdone
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
      if BRESET='1' then
        R_REGS <= regs_init;
      else
        R_REGS <= N_REGS;
      end if;
    end if;
  end process proc_regs;

  proc_next : process (R_REGS, CE_MSEC, IB_MREQ, MEM_DOUT, EI_ACK)
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
    variable imem_addr : slv4 := (others=>'0');
    variable imem_din : slv16 := (others=>'0');
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
    iei_req := '0';

    imem_we0  := '0';
    imem_we1  := '0';
    imem_addr := "00" & IB_MREQ.addr(2 downto 1);
    imem_din  := IB_MREQ.din;
    
    -- ibus address decoder
    n.ibsel := '0';
    if IB_MREQ.aval = '1' and
       IB_MREQ.addr(12 downto 3)=ibaddr_rl11(12 downto 3) then
      n.ibsel := '1';
    end if;

    -- internal state machine
    case r.state is
      when s_idle =>                    -- idle: handle ibus -----------------

        if r.ibsel='1' then               -- selected
          idout := MEM_DOUT;
          imem_we0 := ibw0;
          imem_we1 := ibw1;

          case IB_MREQ.addr(2 downto 1) is

            when ibaddr_rlcs =>           -- RLCS - control register -------
              imem_we0 := '0';              -- MEM not used for rlcs
              imem_we1 := '0';
              imem_addr := imem_sta(imf_typ) & r.csds;  -- get sta(ds)

              -- determine DRDY
              n.csdrdy := '1';
              if MEM_DOUT(sta_ibf_st) /= st_lock or -- drive not on and locked
                 MEM_DOUT(sta_ibf_vce) = '1' then   -- or volume check
                                                    -- ??? also CRDY=0 here ???
                n.csdrdy := '0';
              end if;

              -- determine DE and ERR
              n.cserr := '0';
              if MEM_DOUT(sta_ibf_st) = st_load or -- drive off
                 MEM_DOUT(sta_ibf_vce) = '1'  then -- or volume check
                n.csde := '1';
                n.cserr := '1';
              end if;
              if r.csde = '1' or r.cse /= e_ok then
                n.cserr := '1';
              end if;
  
              if ibrd = '1' then            -- cs read
                ibhold := '1';
                n.state := s_csread;

              elsif IB_MREQ.we = '1' then    -- cs write 

                if ibrem = '0' then             -- loc write access

                  if IB_MREQ.be1 = '1' then
                    if r.cscrdy = '1' then        -- freeze csds when busy
                      n.csds := IB_MREQ.din(rlcs_ibf_ds);
                    end if;
                  end if;

                  if IB_MREQ.be0 = '1' then
                    n.csie   := IB_MREQ.din(rlcs_ibf_ie);
                    n.csbae  := IB_MREQ.din(rlcs_ibf_bae);

                    if r.cscrdy = '1' then      -- controller ready 

                      n.csfunc := IB_MREQ.din(rlcs_ibf_func); -- latch func
                      if IB_MREQ.din(rlcs_ibf_crdy) = '1' then  --  no crdy clr
                        if IB_MREQ.din(rlcs_ibf_ie) = '1' and r.csie = '0' then
                          n.ireq := '1';
                        end if;
                      else                          -- crdy clr --> handle func

                        n.cserr := '0';                     -- clear errors
                        n.csde  := '0';
                        n.cse   := "0000";

                        case IB_MREQ.din(rlcs_ibf_func) is
                          when func_noop =>                 -- noop -------
                            n.ireq := r.csie;                 -- interrupt

                          when func_gs =>                   -- get status -
                            if (r.da and rlda_msk_gs) /= rlda_val_gs then
                              n.cserr := '1';
                              n.cse   := e_incomp;
                              n.ireq  := IB_MREQ.din(rlcs_ibf_ie);
                            else
                              ibhold := '1';
                              n.state := s_gs_rpos;
                            end if;
                          
                          when func_seek =>                 -- seek -------
                            if (r.da and rlda_msk_seek) /= rlda_val_seek then
                              n.cserr := '1';
                              n.cse   := e_incomp;
                              n.ireq  := IB_MREQ.din(rlcs_ibf_ie);
                            else
                              ibhold := '1';
                              n.state := s_seek_rsta;
                            end if;

                          when others =>                    -- all other funcs
                            n.cscrdy := '0';                  -- signal cntl busy
                            ilam := '1';                      -- issue lam
                        end case;
                        
                      end if; -- else IB_MREQ.din(rlcs_ibf_crdy) = '1'
                    end if; -- r.cscrdy = '1'
                  end if; -- IB_MREQ.be0 = '1'
                    
                else                          -- rem write access
                  case IB_MREQ.din(rlcs_ibf_func) is

                    when rfunc_wcs =>
                      n.csde   := IB_MREQ.din(rlcs_ibf_de);
                      n.cse    := IB_MREQ.din(rlcs_ibf_e);
                      n.cscrdy := IB_MREQ.din(rlcs_ibf_crdy);
                      n.csbae  := IB_MREQ.din(rlcs_ibf_bae);
                      if r.cscrdy = '0' and IB_MREQ.din(rlcs_ibf_crdy) = '1' then
                        n.ireq := r.csie;
                      end if;
                      
                    when rfunc_wmp =>
                      if IB_MREQ.din(rlcs_ibf_ena_mprem) = '1' then
                        n.mprem := IB_MREQ.din(rlcs_ibf_mprem);
                      end if;
                      if IB_MREQ.din(rlcs_ibf_ena_mploc) = '1' then
                        n.mploc := IB_MREQ.din(rlcs_ibf_mploc);
                      end if;

                    when others => null;
                  end case;
                  
                end if;
              end if;

            when ibaddr_rlba =>           -- RLBA - bus address register ---
              imem_din(0) := '0';           -- lsb forced 0
              null;

            when ibaddr_rlda =>           -- RLDA - disk address register --
              if ibw1 = '1' then
                n.da(15 downto 8) := IB_MREQ.din(15 downto 8);
              end if;
              if ibw0 = '1' then
                n.da( 7 downto 0) := IB_MREQ.din( 7 downto 0);
              end if;

            when ibaddr_rlmp =>           -- RLMP - multipurpose register --

              if ibrem = '0' then           -- loc access
                if ibrd = '1' then            -- loc mp read
                  case r.mploc is
                    when mploc_mp =>            -- return imem(mp)
                      null;
                    when mploc_sta =>           -- return sta(ds)
                      imem_addr := imem_sta(imf_typ) & r.csds;
                    when mploc_pos =>           -- return pos(ds)
                      imem_addr := imem_pos(imf_typ) & r.csds;
                      n.mploc := mploc_zero;
                    when mploc_zero =>          -- return 0
                      idout := (others => '0');
                      n.mploc := mploc_crc;
                    when mploc_crc  =>          -- return imem(crc)
                      imem_addr := imem_crc;
                    when others => null;
                  end case;
                elsif IB_MREQ.we = '1' then   -- loc mp write
                  n.mploc := mploc_mp;          -- use main mp reg in future
                end if;

              else                          -- rem access
                if r.mprem(mprem_f_map) = '0' then      -- map off - fixed addr
                  imem_addr := r.mprem(mprem_f_addr);
                else                                    -- sequence
                  case r.mprem(mprem_f_state) is
                    when mprem_s_mp =>                    -- mp {used as wc}
                      imem_addr := imem_mp;
                      if r.mprem(mprem_f_seq) = '1' then -- ??? check re&we !!!
                        n.mprem := mprem_mapseq & mprem_s_sta;
                      end if;
                    when mprem_s_sta =>                   -- sta(ds)
                      imem_addr := imem_sta(imf_typ) & r.csds;
                      if r.mprem(mprem_f_seq) = '1' then -- ??? check re&we !!!
                        n.mprem := mprem_mapseq & mprem_s_pos;
                      end if;
                    when mprem_s_pos =>                   -- pos(ds)
                      imem_addr := imem_pos(imf_typ) & r.csds;
                    when others =>                        -- bad state
                      imem_addr := imem_bad;
                      
                  end case;
                end if;
              end if;
              
            when others => null;
          
          end case;
          
        end if;

      when s_csread =>                  -- csread: handle cs read  -----------
        idout(rlcs_ibf_err)  := r.cserr;
        idout(rlcs_ibf_de)   := r.csde;
        idout(rlcs_ibf_e)    := r.cse;
        idout(rlcs_ibf_ds)   := r.csds;
        idout(rlcs_ibf_crdy) := r.cscrdy;
        idout(rlcs_ibf_ie)   := r.csie;
        idout(rlcs_ibf_bae)  := r.csbae;
        idout(rlcs_ibf_func) := r.csfunc;
        idout(rlcs_ibf_drdy) := r.csdrdy;
        n.state := s_idle;
        
      when s_gs_rpos =>                 -- gs_rpos: read pos(ds) -----------
        imem_addr := imem_pos(imf_typ) & r.csds;  -- get pos(ds)
        n.gshs := MEM_DOUT(pos_ibf_hs);           -- get hs bit
        ibhold := r.ibsel;
        n.state := s_gs_sta;

      when s_gs_sta =>                  -- gs_sta: handle status -----------
        imem_addr := imem_sta(imf_typ) & r.csds;  -- get sta(ds)
        imem_we0 := '1';                  -- always update
        imem_we1 := '1';
        imem_din := MEM_DOUT;
        imem_din(sta_ibf_hs) := r.gshs;
        if r.da(rlda_ibf_gs_rst) = '1' then  -- if RST set
          imem_din(sta_ibf_wde) := '0';        -- clear error bits
          imem_din(sta_ibf_che) := '0';
          imem_din(sta_ibf_sto) := '0';
          imem_din(sta_ibf_spe) := '0';
          imem_din(sta_ibf_wge) := '0';
          imem_din(sta_ibf_vce) := '0';
          imem_din(sta_ibf_dse) := '0';
        end if;
        n.mploc := mploc_sta;                     -- use sta(ds) as mp
        n.ireq := r.csie;                         -- interrupt
        n.state := s_idle;
        
      when s_seek_rsta =>               -- seek_rsta: read sta(ds) -----------
        imem_addr := imem_sta(imf_typ) & r.csds;  -- get sta(ds)
        n.seekdt := MEM_DOUT(sta_ibf_dt);
        imem_din := MEM_DOUT;
        if MEM_DOUT(sta_ibf_st) /= st_lock then   -- drive off
          imem_we0 := '1';                          -- update sta
          imem_we1 := '1';
          imem_din(sta_ibf_sto) := '1';             -- set STO (seek time out)
          n.cse := e_incomp;
          n.ireq := r.csie;                         -- interrupt
          n.state := s_idle;          
        else                                      -- drive on
          ibhold := r.ibsel;
          n.state := s_seek_rpos;
        end if;
        
      when s_seek_rpos =>               -- seek_rpos: read pos(ds) -----------
        imem_addr := imem_pos(imf_typ) & r.csds;  -- get pos(ds)
        if r.da(rlda_ibf_seek_dir) = '1' then
          n.seekcan := slv(unsigned('0' & MEM_DOUT(pos_ibf_ca)) +
                           unsigned('0' & r.da(rlda_ibf_seek_df)) );
        else
          n.seekcan := slv(unsigned('0' & MEM_DOUT(pos_ibf_ca)) -
                           unsigned('0' & r.da(rlda_ibf_seek_df)) );
        end if;
        ibhold := r.ibsel;
        n.state := s_seek_clip;

      when s_seek_clip =>               -- seek_clip: clip new ca ------------
        n.seekcac := r.seekcan(8 downto 0);
        -- new ca overflowed ? for RL02 (9) and for RL01 (9:8) must be "00"
        if r.seekcan(9) = '1' or
           (r.seekdt = '0' and r.seekcan(8) = '1') then
          if r.da(rlda_ibf_seek_dir) = '1' then  -- outward seek
            if r.seekdt = '1' then                  -- is RL02
              n.seekcac := ca_max_rl02;               -- clip to RL02 max ca
            else                                    -- is RL01
              n.seekcac := ca_max_rl01;               -- clip to RL01 max ca
            end if;
          else                                   -- inward seek
            n.seekcac := "000000000";               -- clip to 0
          end if;
        end if;
        ibhold := r.ibsel;
        n.state := s_seek_wpos;

      when s_seek_wpos =>               -- seek_wpos: write pos(ds) ----------
        imem_addr := imem_pos(imf_typ) & r.csds;  -- get pos(ds)
        imem_we0 := '1';
        imem_we1 := '1';
        imem_din := MEM_DOUT;
        imem_din(pos_ibf_ca) := r.seekcac;
        imem_din(pos_ibf_hs) := r.da(rlda_ibf_seek_hs);
        n.ireq := r.csie;                         -- interrupt
        n.state := s_idle;
        
      when s_init =>                    -- init: handle init -----------------
        ibhold := r.ibsel;              -- hold ibus when controller busy        
        imem_addr := r.iaddr;
        imem_din  := (others=>'0');
        imem_we0 := '1';
        imem_we1 := '1';
        if r.iaddr(imf_typ) = imem_sta(imf_typ) then  -- if sta(x)
          imem_din  := MEM_DOUT;                        -- keep state 
          imem_din(sta_ibf_wde) := '0';                 -- and clear err
          imem_din(sta_ibf_che) := '0';
          imem_din(sta_ibf_sto) := '0';
          imem_din(sta_ibf_spe) := '0';
          imem_din(sta_ibf_wge) := '0';
          imem_din(sta_ibf_vce) := '0';
          imem_din(sta_ibf_dse) := '0';          
        end if;
        n.iaddr := slv(unsigned(r.iaddr) + 1);
        if unsigned(r.iaddr) = unsigned(imem_sta)+3 then -- stop after sta(3)
          n.state := s_idle;
        end if;
        
      when others => null;
    end case;    

    iei_req := r.ireq;                  -- ??? simplify, use r.ireq directly

    if EI_ACK = '1' or r.csie = '0' then  -- interrupt executed or ie disabled
      n.ireq := '0';                      -- cancel request
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
