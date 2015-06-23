-- $Id: nx_cram_memctl_as.vhd 644 2015-02-08 22:56:54Z mueller $
--
-- Copyright 2010-2011 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Module Name:    nx_cram_memctl_as - syn
-- Description:    nexys2/3: CRAM driver - async and page mode
--
-- Dependencies:   vlib/xlib/iob_reg_o
--                 vlib/xlib/iob_reg_o_gen
--                 vlib/xlib/iob_reg_io_gen
-- Test bench:     tb/tb_nx_cram_memctl_as
--                 sys_gen/tst_sram/nexys2/tb/tb_tst_sram_n2
-- Target Devices: generic
-- Tool versions:  ise 11.4-14.7; viv 2014.4; ghdl 0.26-0.31
--
-- Synthesized (xst):
-- Date         Rev  ise         Target      flop lutl lutm slic t peri
-- 2010-06-03   299  11.4   L68  xc3s1200e-4   91  100    0   96 s  6.7
-- 2010-05-24   294  11.4   L68  xc3s1200e-4   91   99    0   95 s  6.7
-- 2010-05-23   293  11.4   L68  xc3s1200e-4   91  139    0   99 s  6.7
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2011-11-26   433   1.2    renamed from n2_cram_memctl_as
-- 2011-11-19   432   1.1    remove O_FLA_CE_N port
-- 2011-11-19   427   1.0.5  now numeric_std clean
-- 2010-11-22   339   1.0.4  cntdly now 3 bit; add assert for DELAY generics
-- 2010-06-03   299   1.0.3  add "KEEP" for data iob; MEM_OE='1' on first read
--                           cycle;
-- 2010-05-30   297   1.0.2  use READ(0|1)DELAY generic
-- 2010-05-24   294   1.0.1  more compact n.memdi logic; extra wait in s_rdwait1
-- 2010-05-23   293   1.0    Initial version 
--
-- Notes:
--  1. READ1DELAY of 2 is needed even though the timing of the memory suggests
--     that 1 cycle is enough (T_apa is 20 ns, so 40 ns round trip is ok). A
--     short READ1 delay works in sim, but not on fpga where the data of the
--     ADDR(0)=0 cycle is re-read (see notes_tst_sram_n2.txt).
--     tb_n2_cram_memctl_as_ISim_tsim works with full sdf even when T_apa is
--     40ns or 50 ns, only T_apa 60 ns fails !
--     Unclear what is wrong here, the timing of the memory model seems ok.
--  2. There is no 'bus-turn-around' cycle needed for a write->read change
--     FPGA_OE goes 1->0 and MEM_OE goes 0->1 on the s_wrput1->s_rdinit
--     transition simultaneously. The FPGA will go high-Z quickly, the memory
--     low-Z delay by the IOB and internal memory delays. No clash.
--  3. There is a hidden 'bus-turn-around' cycle for a read->write change.
--     MEM_OE goes 1->0 on s_rdget1->s_wrinit and the memory will go high-z with
--     some delay. FPGA_OE goes 0->1 in the next cycle at s_wrinit->s_wrwait0.
--     Again no clash due to the 1 cycle delay.
--
-- Nominal timings:
--     READ0/1 = N_rd_cycle - 2
--     WRITE   = N_wr_cycle - 1
--
-- from notes_nexys2.txt (Rev 339):
--         clksys        RD  WR     < use for >               Test case
--                                                            MHz div mul
--        <51.20          2   3     <-- 50                     50   1   1
--         51.20- 54.80   3   3     <-- 52,54                  54  25  27
--         54.80- 64.10   3   4     <-- 55,56,58,60,62,64      64  25  32
--         64.10- 68.50   4   4     <-- 65                     65  10  13
--         68.50- 76.92   4   5     <-- 70,75                  75   2   3
--         76.92- 82.19   5   5     <-- 80                     80   5   8
--         82.19- 89.74   5   6     <-- 85                     85  10  17
--         89.74- 95.89   6   6     <-- 90,95                  95  10  19
--         95.89-102.56   6   7     <-- 100                   100   1   2
--
-- Timing of some signals:
--
-- single read request:
--
-- state      |_idle  |_rdinit|_rdwt0 |_rdwt0 |_rdget0|_rdwt1 |_rdget1|
--                      0      20      40      60      80      100     120
-- CLK      __|^^^|___|^^^|___|^^^|___|^^^|___|^^^|___|^^^|___|^^^|___|^^^|___|
-- 
-- REQ      _______|^^^^^|_____________________________________________
-- WE       ___________________________________________________________
-- 
-- IOB_CE   __________|^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^|_
-- IOB_OE    _________|^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^|_
-- 
-- DO       oooooooooooooooooooooooooooooooooooooooooo|lllllll|lllllll|h
-- BUSY     __________|^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^|________________
-- ACK_R   ___________________________________________________________|^^^^^^^|_
-- 
-- single write request:
-- 
-- state       |_idle  |_wrinit|_wrwt0 |_wrwt0 |_wrwt0 |_wrput0|_idle  |
--                       0      20      40      60      80      100     120
-- CLK       __|^^^|___|^^^|___|^^^|___|^^^|___|^^^|___|^^^|___|^^^|___|^^^|___|
-- 
-- REQ       _______|^^^^^|______________________________________
-- WE        _______|^^^^^|______________________________________
-- 
-- IOB_CE    __________|^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^|_
-- IOB_BE    __________|^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^|_
-- IOB_OE    ____________________________________________________
-- IOB_WE    ______________|^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^|_____
-- 
-- BUSY      __________|^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^|_________
-- ACK_W     __________________________________________|^^^^^^^|_
-- 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.xlib.all;

entity nx_cram_memctl_as is             -- CRAM driver (async+page mode)
  generic (
    READ0DELAY : positive := 2;         -- read word 0 delay in clock cycles
    READ1DELAY : positive := 2;         -- read word 1 delay in clock cycles
    WRITEDELAY : positive := 3);        -- write delay in clock cycles
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit;                   -- reset
    REQ   : in slbit;                   -- request
    WE    : in slbit;                   -- write enable
    BUSY : out slbit;                   -- controller busy
    ACK_R : out slbit;                  -- acknowledge read
    ACK_W : out slbit;                  -- acknowledge write
    ACT_R : out slbit;                  -- signal active read
    ACT_W : out slbit;                  -- signal active write
    ADDR : in slv22;                    -- address  (32 bit word address)
    BE : in slv4;                       -- byte enable
    DI : in slv32;                      -- data in  (memory view)
    DO : out slv32;                     -- data out (memory view)
    O_MEM_CE_N : out slbit;             -- cram: chip enable   (act.low)
    O_MEM_BE_N : out slv2;              -- cram: byte enables  (act.low)
    O_MEM_WE_N : out slbit;             -- cram: write enable  (act.low)
    O_MEM_OE_N : out slbit;             -- cram: output enable (act.low)
    O_MEM_ADV_N : out slbit;            -- cram: address valid (act.low)
    O_MEM_CLK : out slbit;              -- cram: clock
    O_MEM_CRE : out slbit;              -- cram: command register enable
    I_MEM_WAIT : in slbit;              -- cram: mem wait
    O_MEM_ADDR  : out slv23;            -- cram: address lines
    IO_MEM_DATA : inout slv16           -- cram: data lines
  );
end nx_cram_memctl_as;


architecture syn of nx_cram_memctl_as is

  type state_type is (
    s_idle,                             -- s_idle: wait for req
    s_rdinit,                           -- s_rdinit:  read init cycle
    s_rdwait0,                          -- s_rdwait0: read wait low word
    s_rdget0,                           -- s_rdget0:  read get low word
    s_rdwait1,                          -- s_rdwait1: read wait high word
    s_rdget1,                           -- s_rdget1:  read get high word
    s_wrinit,                           -- s_wrinit:  write init cycle
    s_wrwait0,                          -- s_rdwait0: write wait 1st word
    s_wrput0,                           -- s_rdput0:  write put 1st word
    s_wrini1,                           -- s_wrini1:  write init 2nd word
    s_wrwait1,                          -- s_wrwait1: write wait 2nd word
    s_wrput1                            -- s_wrput1:  write put 2nd word
  );
  
  type regs_type is record
    state : state_type;                 -- state
    ackr : slbit;                       -- signal ack_r
    addr0 : slbit;                      -- current addr0
    be2nd : slv2;                       -- be's of 2nd write cycle
    cntdly : slv3;                      -- wait delay counter
    cntce : slv7;                       -- ce counter
    fidle : slbit;                      -- force idle flag
    memdo0 : slv16;                     -- mem data out, low word
    memdi : slv32;                      -- mem data in
  end record regs_type;

  constant regs_init : regs_type := (
    s_idle,                             -- state
    '0',                                -- ackr
    '0',                                -- addr0
    "00",                               -- be2nd
    (others=>'0'),                      -- cntdly
    (others=>'0'),                      -- cntce
    '0',                                -- fidle
    (others=>'0'),                      -- memdo0
    (others=>'0')                       -- memdi
  );
    
  signal R_REGS : regs_type := regs_init;  -- state registers
  signal N_REGS : regs_type := regs_init;  -- next value state regs
  
  signal CLK_180  : slbit := '0';
  signal MEM_CE_N : slbit := '1';
  signal MEM_BE_N : slv2  := "11";
  signal MEM_WE_N : slbit := '1';
  signal MEM_OE_N : slbit := '1';
  signal BE_CE    : slbit := '0';
  signal ADDRH_CE : slbit := '0';
  signal ADDR0_CE : slbit := '0';
  signal ADDR0    : slbit := '0';
  signal DATA_CEI : slbit := '0';
  signal DATA_CEO : slbit := '0';
  signal DATA_OE  : slbit := '0';
  signal MEM_DO   : slv16 := (others=>'0');
  signal MEM_DI   : slv16 := (others=>'0');

-- these attributes aren't accepted by ghdl 0.26
--  attribute s : string;
--  attribute s of I_MEM_WAIT : signal is "true";

begin

  assert READ0DELAY<=2**R_REGS.cntdly'length and
         READ1DELAY<=2**R_REGS.cntdly'length and
         WRITEDELAY<=2**R_REGS.cntdly'length
    report "assert(READ0,READ1,WRITEDELAY <= 2**cntdly'length)"
    severity failure;

  CLK_180 <= not CLK;
  
  IOB_MEM_CE : iob_reg_o
    generic map (
      INIT   => '1')
    port map (
      CLK => CLK,
      CE  => '1',
      DO  => MEM_CE_N,
      PAD => O_MEM_CE_N
    );
  
  IOB_MEM_BE : iob_reg_o_gen
    generic map (
      DWIDTH => 2,
      INIT   => '1')
    port map (
      CLK => CLK,
      CE  => BE_CE,
      DO  => MEM_BE_N,
      PAD => O_MEM_BE_N
    );
  
  IOB_MEM_WE : iob_reg_o
    generic map (
      INIT   => '1')
    port map (
      CLK => CLK_180,
      CE  => '1',
      DO  => MEM_WE_N,
      PAD => O_MEM_WE_N
    );
  
  IOB_MEM_OE : iob_reg_o
    generic map (
      INIT   => '1')
    port map (
      CLK => CLK,
      CE  => '1',
      DO  => MEM_OE_N,
      PAD => O_MEM_OE_N
    );
  
  IOB_MEM_ADDRH : iob_reg_o_gen
    generic map (
      DWIDTH => 22)
    port map (
      CLK => CLK,
      CE  => ADDRH_CE,
      DO  => ADDR,
      PAD => O_MEM_ADDR(22 downto 1)
    );
  
  IOB_MEM_ADDR0 : iob_reg_o
    port map (
      CLK => CLK,
      CE  => ADDR0_CE,
      DO  => ADDR0,
      PAD => O_MEM_ADDR(0)
    );
  
  IOB_MEM_DATA : iob_reg_io_gen
    generic map (
      DWIDTH => 16,
      PULL   => "KEEP")
    port map (
      CLK => CLK,
      CEI => DATA_CEI,
      CEO => DATA_CEO,
      OE  => DATA_OE,
      DI  => MEM_DO,
      DO  => MEM_DI,
      PAD => IO_MEM_DATA
    );

  O_MEM_ADV_N <= '0';
  O_MEM_CLK   <= '0';
  O_MEM_CRE   <= '0';

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

  proc_next: process (R_REGS, REQ, WE, BE, DI, MEM_DO)

    variable r : regs_type := regs_init;
    variable n : regs_type := regs_init;
    variable ibusy : slbit := '0';
    variable iackw : slbit := '0';
    variable iactr : slbit := '0';
    variable iactw : slbit := '0';
    variable imem_ce : slbit := '0';
    variable imem_be : slv2  := "00";
    variable imem_we : slbit := '0';
    variable imem_oe : slbit := '0';
    variable ibe_ce    : slbit := '0';
    variable iaddrh_ce : slbit := '0';
    variable iaddr0_ce : slbit := '0';
    variable iaddr0    : slbit := '0';
    variable idata_cei : slbit := '0';
    variable idata_ceo : slbit := '0';
    variable idata_oe  : slbit := '0';
    
    procedure do_dispatch(nstate  : out state_type;
                          iaddrh_ce : out slbit;
                          iaddr0_ce : out slbit;
                          iaddr0  : out slbit;
                          ibe_ce  : out slbit;
                          imem_be : out slv2;
                          imem_ce : out slbit;
                          imem_oe : out slbit;
                          nbe2nd  : out slv2) is
    begin
      iaddrh_ce := '1';                 -- latch address (high part)
      iaddr0_ce := '1';                 -- latch address 0 bit
      ibe_ce    := '1';                 -- latch be's
      imem_ce   := '1';                 -- ce CRAM next cycle
      nbe2nd    := "00";                -- assume no 2nd write cycle
      if WE = '0' then                  -- if READ requested
        iaddr0  := '0';                   -- go first for low word
        imem_be := "11";                  -- on read always on
        imem_oe := '1';                   -- oe CRAM next cycle
        nstate  := s_rdinit;              -- next: read init part
      else                              -- if WRITE requested
        if BE(1 downto 0) /= "00" then    -- low word write
          iaddr0  := '0';                   -- access word 0 
          imem_be := BE(1 downto 0);        -- set be's for 1st cycle
          nbe2nd  := BE(3 downto 2);        -- keep be's for 2nd cycle
        else                              -- high word write
          iaddr0  := '1';                   -- access word 1 
          imem_be := BE(3 downto 2);        -- set be's for 1st cycle
        end if;
        nstate := s_wrinit;               -- next: write init part
      end if;
    end procedure do_dispatch;

  begin

    r := R_REGS;
    n := R_REGS;
    n.ackr := '0';

    ibusy := '0';
    iackw := '0';
    iactr := '0';
    iactw := '0';

    imem_ce := '0';
    imem_be := "11";
    imem_we := '0';
    imem_oe := '0';
    ibe_ce    := '0';
    iaddrh_ce := '0';
    iaddr0_ce := '0';
    iaddr0    := '0';
    idata_cei := '0';
    idata_ceo := '0';
    idata_oe  := '0';

    if unsigned(r.cntdly) /= 0 then
      n.cntdly := slv(unsigned(r.cntdly) - 1);
    end if;
    
    case r.state is
      when s_idle =>                    -- s_idle: wait for req
        if REQ = '1' then                 -- if IO requested
          do_dispatch(n.state, iaddrh_ce, iaddr0_ce, iaddr0,
                               ibe_ce, imem_be, imem_ce, imem_oe, n.be2nd);
        end if;
        
      when s_rdinit =>                  -- s_rdinit:  read init cycle
        ibusy   := '1';                   -- signal busy, unable to handle req
        iactr   := '1';                   -- signal mem read
        imem_ce := '1';                   -- ce CRAM next cycle
        imem_oe := '1';                   -- oe CRAM next cycle
        n.cntdly:= slv(to_unsigned(READ0DELAY-1, n.cntdly'length));
        n.state := s_rdwait0;             -- next: wait

      when s_rdwait0 =>                  -- s_rdwait0: read wait low word
        ibusy   := '1';                   -- signal busy, unable to handle req
        iactr   := '1';                   -- signal mem read
        imem_ce := '1';                   -- ce CRAM next cycle
        imem_oe := '1';                   -- oe CRAM next cycle
        if unsigned(r.cntdly) = 0 then    -- wait expired ?
          n.state := s_rdget0;              -- next: get low word
        end if;

      when s_rdget0 =>                  -- s_rdget0: read get low word
        ibusy   := '1';                   -- signal busy, unable to handle req
        iactr   := '1';                   -- signal mem read
        imem_ce := '1';                   -- ce CRAM next cycle
        imem_oe := '1';                   -- oe CRAM next cycle
        idata_cei := '1';                 -- latch input data
        iaddr0_ce := '1';                 -- latch address 0 bit
        iaddr0    := '1';                 -- now go for high word
        n.cntdly:= slv(to_unsigned(READ1DELAY-1, n.cntdly'length));
        n.state := s_rdwait1;             -- next: wait high word

      when s_rdwait1 =>                 -- s_rdwait1: read wait high word
        ibusy   := '1';                   -- signal busy, unable to handle req
        iactr   := '1';                   -- signal mem read
        imem_ce := '1';                   -- ce CRAM next cycle
        imem_oe := '1';                   -- oe CRAM next cycle
        if unsigned(r.cntdly) = 0 then    -- wait expired ?
          n.state := s_rdget1;              -- next: get low word
        end if;                             --

      when s_rdget1 =>                  -- s_rdget1: read get high word
        iactr   := '1';                   -- signal mem read
        n.memdo0:= MEM_DO;                -- save low word data
        idata_cei := '1';                 -- latch input data
        n.ackr  := '1';                   -- ACK_R next cycle
        n.state := s_idle;                -- next: wait next request
        if r.fidle = '1' then             -- forced idle cycle
          ibusy   := '1';                   -- signal busy, unable to handle req
        else
          if REQ = '1' then                 -- if IO requested            
            do_dispatch(n.state, iaddrh_ce, iaddr0_ce, iaddr0,
                                 ibe_ce, imem_be, imem_ce, imem_oe, n.be2nd);
          end if;
        end if;

      when s_wrinit =>                  -- s_wrinit:  write init cycle
        ibusy := '1';                     -- signal busy, unable to handle req
        iactw := '1';                     -- signal mem write
        iackw := '1';                     -- signal write done (all latched)
        idata_ceo:= '1';                  -- latch output data
        idata_oe := '1';                  -- oe FPGA next cycle
        imem_ce  := '1';                  -- ce CRAM next cycle
        imem_we  := '1';                  -- we CRAM in half cycle
        n.cntdly:= slv(to_unsigned(WRITEDELAY-1, n.cntdly'length));
        n.state := s_wrwait0;             -- next: wait

      when s_wrwait0 =>                 -- s_rdput0:  write wait 1st word
        ibusy := '1';                     -- signal busy, unable to handle req
        iactw := '1';                     -- signal mem write
        idata_oe := '1';                  -- oe FPGA next cycle
        imem_ce  := '1';                  -- ce CRAM next cycle
        imem_we  := '1';                  -- we CRAM next cycle
        if unsigned(r.cntdly) = 0 then    -- wait expired ?
          n.state := s_wrput0;            -- next: put 1st word
        end if;

      when s_wrput0 =>                  -- s_rdput0:  write put 1st word
        iactw := '1';                     -- signal mem write
        imem_we  := '0';                  -- deassert we CRAM in half cycle
        if r.be2nd /= "00" then
          ibusy := '1';                     -- signal busy, unable to handle req
          imem_ce  := '1';                  -- ce CRAM next cycle
          iaddr0_ce := '1';                 -- latch address 0 bit
          iaddr0    := '1';                 -- now go for high word
          ibe_ce    := '1';                 -- latch be's
          imem_be   := r.be2nd;             -- now be's of high word
          n.state := s_wrini1;              -- next: start 2nd write
        else
          n.state := s_idle;                -- next: wait next request
          if r.fidle = '1' then             -- forced idle cycle
            ibusy   := '1';                   -- signal busy
          else
            if REQ = '1' then                 -- if IO requested            
              do_dispatch(n.state, iaddrh_ce, iaddr0_ce, iaddr0,
                                   ibe_ce, imem_be, imem_ce, imem_oe, n.be2nd);
            end if;
          end if;
        end if;

      when s_wrini1 =>                  -- s_wrini1:  write init 2nd word
        ibusy := '1';                     -- signal busy, unable to handle req
        iactw := '1';                     -- signal mem write
        idata_ceo:= '1';                  -- latch output data
        idata_oe := '1';                  -- oe FPGA next cycle
        imem_ce  := '1';                  -- ce CRAM next cycle
        imem_we  := '1';                  -- we CRAM in half cycle
        n.cntdly:= slv(to_unsigned(WRITEDELAY-1, n.cntdly'length));
        n.state := s_wrwait1;             -- next: wait

      when s_wrwait1 =>                 -- s_wrwait1: write wait 2nd word
        ibusy := '1';                     -- signal busy, unable to handle req
        iactw := '1';                     -- signal mem write
        idata_oe := '1';                  -- oe FPGA next cycle
        imem_ce  := '1';                  -- ce CRAM next cycle
        imem_we  := '1';                  -- we CRAM next cycle
        if unsigned(r.cntdly) = 0 then    -- wait expired ?
          n.state := s_wrput1;            -- next: put 2nd word
        end if;

      when s_wrput1 =>                  -- s_wrput1:  write put 2nd word
        iactw := '1';                     -- signal mem write
        imem_we  := '0';                  -- deassert we CRAM in half cycle
        n.state := s_idle;                -- next: wait next request
        if r.fidle = '1' then             -- forced idle cycle
          ibusy   := '1';                   -- signal busy, unable to handle req
        else
          if REQ = '1' then                 -- if IO requested            
            do_dispatch(n.state, iaddrh_ce, iaddr0_ce, iaddr0,
                                 ibe_ce, imem_be, imem_ce, imem_oe, n.be2nd);
          end if;
        end if;
                
      when others => null;
    end case;

    if imem_ce = '0' then               -- if cmem not active
      n.cntce := (others=>'0');           -- clear counter 
      n.fidle := '0';                     -- clear force idle flag
    else                                -- if cmem active
      if unsigned(r.cntce) >= 127 then    -- if max ce count expired
        n.fidle := '1';                     -- set forced idle flag
      else                                -- if max ce count not yet reached
        n.cntce := slv(unsigned(r.cntce) + 1);   -- increment counter
      end if;
    end if;
    
    if iaddrh_ce = '1' then             -- if addresses are latched
      n.memdi := DI;                      -- latch data too...
    end if;
    
    if iaddr0_ce = '1' then             -- if address bit 0 changed
      n.addr0 := iaddr0;                  -- mirror it in state regs
    end if;
    
    N_REGS <= n;

    MEM_CE_N <= not imem_ce;
    MEM_WE_N <= not imem_we;
    MEM_BE_N <= not imem_be;
    MEM_OE_N <= not imem_oe;

    if r.addr0 = '0' then
      MEM_DI <= r.memdi(15 downto 0);
    else
      MEM_DI <= r.memdi(31 downto 16);
    end if;

    BE_CE    <= ibe_ce;
    ADDRH_CE <= iaddrh_ce;
    ADDR0_CE <= iaddr0_ce;
    ADDR0    <= iaddr0;
    DATA_CEI <= idata_cei;
    DATA_CEO <= idata_ceo;
    DATA_OE  <= idata_oe;

    BUSY  <= ibusy;
    ACK_R <= r.ackr;
    ACK_W <= iackw;
    ACT_R <= iactr;
    ACT_W <= iactw;
    
    DO    <= MEM_DO & r.memdo0;
    
  end process proc_next;
  
end syn;
