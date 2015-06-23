------------------------------------------------------------------------------
--  This file is a part of the GRLIB VHDL IP LIBRARY
--  Copyright (C) 2003, Gaisler Research
--
--  This program is free software; you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation; either version 2 of the License, or
--  (at your option) any later version.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
--
--  You should have received a copy of the GNU General Public License
--  along with this program; if not, write to the Free Software
--  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA 
-------------------------------------------------------------------------------
-- Entity:     spictrl
-- File:       spictrl.vhd
-- Author:     Jan Andersson - Gaisler Research AB
--             jan@gaisler.com
--
-- Description: SPI controller with an interface compatible with MPC83xx SPI.
--              Relies on APB's wait state between back-to-back transfers.
--
-- Revision 1 of this core introduces 3-wire mode. The core can be placed in 3-wire
-- mode by writing bit 15 in the mode register.

library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

library grlib;
use grlib.amba.all;
use grlib.devices.all;
use grlib.stdlib.all;
library gaisler;
use gaisler.misc.all;

entity spictrl is
  generic (
    -- APB generics
    pindex : integer := 0;                -- slave bus index
    paddr  : integer := 0;
    pmask  : integer := 16#fff#;
    pirq   : integer := 0;                -- interrupt index
    
    -- SPI controller configuration
    fdepth    : integer range 1 to 7  := 1;  -- FIFO depth is 2^fdepth
    slvselen  : integer range 0 to 1  := 0;  -- Slave select register enable
    slvselsz  : integer range 1 to 32 := 1;  -- Number of slave select signals
    oepol     : integer range 0 to 1  := 0); -- Output enable polarity 
  port (
    rstn   : in std_ulogic;
    clk    : in std_ulogic;
    
    -- APB signals
    apbi   : in  apb_slv_in_type;
    apbo   : out apb_slv_out_type;

    -- SPI signals
    spii   : in  spi_in_type;
    spio   : out spi_out_type;
    slvsel : out std_logic_vector((slvselsz-1) downto 0)
    );
end entity spictrl;

architecture rtl of spictrl is

  -----------------------------------------------------------------------------
  -- Constants
  -----------------------------------------------------------------------------
  constant SPICTRL_REV : integer := 1;

  constant PCONFIG : apb_config_type := (
  0 => ahb_device_reg(VENDOR_GAISLER, GAISLER_SPICTRL, 0, SPICTRL_REV, pirq),
  1 => apb_iobar(paddr, pmask));

  constant OEPOL_LEVEL : std_ulogic := conv_std_logic(oepol = 1);

  
  constant OUTPUT : std_ulogic := OEPOL_LEVEL;      -- Enable outputs
  constant INPUT : std_ulogic := not OEPOL_LEVEL;   -- Tri-state outputs
  
  constant FIFO_DEPTH  : integer := 2**fdepth;
  constant SLVSEL_EN   : integer := slvselen;
  constant SLVSEL_SZ   : integer := slvselsz;

  constant CAP_ADDR    : std_logic_vector(7 downto 2) := "000000";  -- 0x00

  constant MODE_ADDR   : std_logic_vector(7 downto 2) := "001000";  -- 0x20
  constant EVENT_ADDR  : std_logic_vector(7 downto 2) := "001001";  -- 0x24
  constant MASK_ADDR   : std_logic_vector(7 downto 2) := "001010";  -- 0x28
  constant COM_ADDR    : std_logic_vector(7 downto 2) := "001011";  -- 0x2C
  constant TD_ADDR     : std_logic_vector(7 downto 2) := "001100";  -- 0x30
  constant RD_ADDR     : std_logic_vector(7 downto 2) := "001101";  -- 0x34
  constant SLVSEL_ADDR : std_logic_vector(7 downto 2) := "001110";  -- 0x38

  constant SPICTRLCAPREG : std_logic_vector(31 downto 0) :=
    conv_std_logic_vector(SLVSEL_SZ,8) & conv_std_logic_vector(SLVSEL_EN,8) &
    conv_std_logic_vector(FIFO_DEPTH,8) & conv_std_logic_vector(SPICTRL_REV,8);

  -----------------------------------------------------------------------------
  -- Types
  -----------------------------------------------------------------------------
  type spi_mode_rec is record           -- SPI Mode register
    loopb : std_ulogic;  -- loopback mode
    cpol  : std_ulogic;  -- clock polarity
    cpha  : std_ulogic;  -- clock phase
    div16 : std_ulogic;  -- Divide by 16
    rev   : std_ulogic;  -- Reverse data mode
    ms    : std_ulogic;  -- Master/slave
    en    : std_ulogic;  -- Enable SPI
    len   : std_logic_vector(3 downto 0);  -- Bits per character
    pm    : std_logic_vector(3 downto 0);  -- Prescale modulus
    tw    : std_ulogic;  -- 3-wire mode 
    cg    : std_logic_vector(4 downto 0);  -- Clock gap
  end record;

  type spi_em_rec is record             -- SPI Event and Mask registers
    lt  : std_ulogic;  -- last character transmitted
    ov  : std_ulogic;  -- slave/master overrun
    un  : std_ulogic;  -- slave/master underrun
    mme : std_ulogic;  -- Multiple-master error
    ne  : std_ulogic;  -- Not empty
    nf  : std_ulogic;  -- Not full
  end record;
  
  type spi_fifo is array (0 to (FIFO_DEPTH-1)) of std_logic_vector(31 downto 0);
   
  -- Two stage synchronizers on each input coming from off-chip
  type spi_in_array is array (1 downto 0) of spi_in_type;
  
  type spi_reg_type is record
    -- SPI registers
    mode     : spi_mode_rec;  -- Mode register
    event    : spi_em_rec;    -- Event register
    mask     : spi_em_rec;    -- Mask register
    lst      : std_ulogic;    -- Only field on command register
    td       : std_logic_vector(31 downto 0);  -- Transmit register
    rd       : std_logic_vector(31 downto 0);  -- Receive register
    slvsel   : std_logic_vector((SLVSEL_SZ-1) downto 0);  -- Slave select register
    --
    uf       : std_ulogic;    -- Slave in underflow condition 
    ov       : std_ulogic;    -- Receive overflow condition 
    td_occ   : std_ulogic;    -- Transmit register occupied
    rd_free  : std_ulogic;    -- Receive register free (empty)
    txfifo   : spi_fifo;      -- Transmit data FIFO
    rxfifo   : spi_fifo;      -- Receive data FIFO
    toggle   : std_ulogic;    -- SCK has toggled 
    sc       : std_ulogic;    -- Sample/Change
    psck     : std_ulogic;    -- Previous value of SC
    running  : std_ulogic; 
    twdir    : std_ulogic;    -- Direction in 3-wire mode
    -- counters
    tfreecnt : integer range 0 to FIFO_DEPTH; -- free td fifo slots
    rfreecnt : integer range 0 to FIFO_DEPTH; -- free td fifo slots
    tdfi     : integer range 0 to (FIFO_DEPTH-1);  -- First tx queue element
    rdfi     : integer range 0 to (FIFO_DEPTH-1);  -- First rx queue element
    tdli     : integer range 0 to (FIFO_DEPTH-1);  -- Last tx queue element
    rdli     : integer range 0 to (FIFO_DEPTH-1);  -- Last rx queue element
    bitcnt   : integer range 0 to 31;  -- Current bit
    divcnt   : unsigned(9 downto 0);   -- Clock scaler
    cgcnt    : unsigned(5 downto 0);   -- Clock gap counter
    --
    irq      :  std_ulogic;
    -- Sync registers for inputs
    spii     : spi_in_array;
    -- Output
    spio     : spi_out_type;
 end record;

  -----------------------------------------------------------------------------
  -- Sub programs
  -----------------------------------------------------------------------------
  -- Returns an integer containing the character length - 1 in bits as selected
  -- by the Mode field LEN. 
  function spilen (
    len : std_logic_vector(3 downto 0))
    return std_logic_vector is
  begin  -- spilen
    if len = zero32(3 downto 0) then
      return "11111";
    else
      return "0" & len;
    end if;
  end spilen;

  -- Write clear
  procedure wc (
    reg_o : out std_ulogic;
    reg_i : in  std_ulogic;
    b     : in  std_ulogic) is
  begin
    reg_o := reg_i and not b;
  end procedure wc;

  -- Reverses string. After this function has been called the first bit
  -- to send is always at position 0.
  function reverse(
    data : std_logic_vector)
    return std_logic_vector is
    variable rdata: std_logic_vector(data'reverse_range);
  begin
    for i in data'range loop
      rdata(i) := data(i);
    end loop;
    return rdata; 
  end function reverse;

  -- Performs a HWORD swap if len /= 0
  function condhwordswap (
    data : std_logic_vector(31 downto 0);
    len  : std_logic_vector(4 downto 0);
    rev  : std_ulogic)
    return std_logic_vector is
    variable rdata : std_logic_vector(31 downto 0);
  begin  -- condhwordswap
    if len = one32(4 downto 0) then
      rdata := data;
    else
      rdata := data(15 downto 0) & data(31 downto 16);
    end if;
    return rdata;
  end condhwordswap;

  -- Zeroes out unused part of receive vector.
  function select_data (
    data : std_logic_vector(31 downto 0);
    len  : std_logic_vector(4 downto 0))
    return std_logic_vector is
    variable rdata : std_logic_vector(31 downto 0) := (others => '0');
    variable length : integer range 0 to 31 := conv_integer(len);
  begin  -- select_data
    -- Quartus can not handle variable ranges
    -- rdata(conv_integer(len) downto 0) := data(conv_integer(len) downto 0);
    case length is
      when 31 => rdata := data;
      when 30 => rdata(30 downto 0) := data(30 downto 0);
      when 29 => rdata(29 downto 0) := data(29 downto 0);
      when 28 => rdata(28 downto 0) := data(28 downto 0);
      when 27 => rdata(27 downto 0) := data(27 downto 0);
      when 26 => rdata(26 downto 0) := data(26 downto 0);
      when 25 => rdata(25 downto 0) := data(25 downto 0);
      when 24 => rdata(24 downto 0) := data(24 downto 0);
      when 23 => rdata(23 downto 0) := data(23 downto 0);
      when 22 => rdata(22 downto 0) := data(22 downto 0);
      when 21 => rdata(21 downto 0) := data(21 downto 0);
      when 20 => rdata(20 downto 0) := data(20 downto 0);
      when 19 => rdata(19 downto 0) := data(19 downto 0);
      when 18 => rdata(18 downto 0) := data(18 downto 0);
      when 17 => rdata(17 downto 0) := data(17 downto 0);
      when 16 => rdata(16 downto 0) := data(16 downto 0);
      when 15 => rdata(15 downto 0) := data(15 downto 0);
      when 14 => rdata(14 downto 0) := data(14 downto 0);
      when 13 => rdata(13 downto 0) := data(13 downto 0);
      when 12 => rdata(12 downto 0) := data(12 downto 0);
      when 11 => rdata(11 downto 0) := data(11 downto 0);
      when 10 => rdata(10 downto 0) := data(10 downto 0);
      when 9 => rdata(9 downto 0) := data(9 downto 0);
      when 8 => rdata(8 downto 0) := data(8 downto 0);
      when 7 => rdata(7 downto 0) := data(7 downto 0);
      when 6 => rdata(6 downto 0) := data(6 downto 0);
      when 5 => rdata(5 downto 0) := data(5 downto 0);
      when 4 => rdata(4 downto 0) := data(4 downto 0);
      when 3 => rdata(3 downto 0) := data(3 downto 0);
      when 2 => rdata(2 downto 0) := data(2 downto 0);
      when 1 => rdata(1 downto 0) := data(1 downto 0);
      when others => rdata(0) := data(0);
    end case;
    return rdata;
  end select_data;
    
   -- purpose: Returns true when a slave is selected and the clock starts
  function slv_start (
    signal spisel  : std_ulogic;
    signal cpol    : std_ulogic;
    signal sck     : std_ulogic;
    signal prevsck : std_ulogic)
    return boolean is
  begin  -- slv_start
    if spisel = '0' then          -- Slave is selected
      if (sck xor prevsck) = '1' then  -- The clock has changed
        return (cpol xor sck) = '1';    -- The clock is not idle 
      end if;
    end if;
    return false;
  end slv_start;
  
  -----------------------------------------------------------------------------
  -- Signals
  -----------------------------------------------------------------------------
  
  signal r, rin : spi_reg_type;
  
begin

  -- SPI controller, register interface and related logic
  comb: process (r, rstn, apbi, spii)
    variable v       : spi_reg_type;
    variable irq     : std_logic_vector((NAHBIRQ-1) downto 0);
    variable apbaddr : std_logic_vector(7 downto 2);
    variable apbout  : std_logic_vector(31 downto 0);
    variable len     : std_logic_vector(4 downto 0);
    variable indata  : std_ulogic;
    variable change  : std_ulogic;
    variable sample  : std_ulogic;
    variable reload  : std_ulogic;
  begin  -- process comb
    v := r;  v.irq := '0'; irq := (others=>'0'); irq(pirq) := r.irq;
    apbaddr := apbi.paddr(7 downto 2); apbout := (others => '0');
    len := spilen(r.mode.len); v.toggle := '0';
    indata := '0'; sample := '0'; change := '0'; reload := '0';  
    
    -- read registers
    if (apbi.psel(pindex) and apbi.penable and (not apbi.pwrite)) = '1' then
      case apbaddr is
        when CAP_ADDR =>
          apbout := SPICTRLCAPREG;
        when MODE_ADDR =>
          apbout := zero32(31) & r.mode.loopb & r.mode.cpol & r.mode.cpha &
                    r.mode.div16 & r.mode.rev & r.mode.ms & r.mode.en &
                    r.mode.len & r.mode.pm & r.mode.tw & zero32(14 downto 12) &
                    r.mode.cg & zero32(6 downto 0);
        when EVENT_ADDR =>
          apbout := zero32(31 downto 15) & r.event.lt & zero32(13) &
                    r.event.ov & r.event.un & r.event.mme & r.event.ne &
                    r.event.nf & zero32(7 downto 0);
        when MASK_ADDR =>
          apbout := zero32(31 downto 15) & r.mask.lt & zero32(13) &
                    r.mask.ov & r.mask.un & r.mask.mme & r.mask.ne &
                    r.mask.nf & zero32(7 downto 0);
        when RD_ADDR  =>
          apbout := condhwordswap(r.rd, len, r.mode.rev);
          v.rd_free := '1';
        when SLVSEL_ADDR =>
         if SLVSEL_EN /= 0 then apbout((SLVSEL_SZ-1) downto 0) := r.slvsel;
         else null; end if;
         when others => null;
      end case;
    end if;

    -- write registers
    if (apbi.psel(pindex) and apbi.penable and apbi.pwrite) = '1' then
      case apbaddr is
        when MODE_ADDR =>
          v.mode.loopb := apbi.pwdata(30);
          v.mode.cpol  := apbi.pwdata(29);
          v.mode.cpha  := apbi.pwdata(28);
          v.mode.div16 := apbi.pwdata(27);
          v.mode.rev   := apbi.pwdata(26);
          v.mode.ms    := apbi.pwdata(25);
          v.mode.en    := apbi.pwdata(24);
          v.mode.len   := apbi.pwdata(23 downto 20);
          v.mode.pm    := apbi.pwdata(19 downto 16);
          v.mode.tw  := apbi.pwdata(15);
          v.mode.cg    := apbi.pwdata(11 downto 7);
        when EVENT_ADDR =>
          wc(v.event.lt, r.event.lt, apbi.pwdata(14));
          wc(v.event.ov, r.event.ov, apbi.pwdata(12));
          wc(v.event.un, r.event.un, apbi.pwdata(11));
          wc(v.event.mme, r.event.mme, apbi.pwdata(10));
        when MASK_ADDR =>
          v.mask.lt  := apbi.pwdata(14);
          v.mask.ov  := apbi.pwdata(12);
          v.mask.un  := apbi.pwdata(11);
          v.mask.mme := apbi.pwdata(10);
          v.mask.ne  := apbi.pwdata(9);
          v.mask.nf  := apbi.pwdata(8);
        when COM_ADDR =>
          v.lst := apbi.pwdata(22);
        when TD_ADDR =>
          -- The write is lost if the transmit register is written when
          -- the not full bit is zero.
          if r.event.nf = '1' then
            v.td := apbi.pwdata;
            v.td_occ := '1';
          end if;
        when SLVSEL_ADDR =>
          if SLVSEL_EN /= 0 then v.slvsel := apbi.pwdata((SLVSEL_SZ-1) downto 0);
          else null; end if;
        when others => null;
      end case;
    end if;
    
    -- Handle transmit FIFO
    if r.td_occ = '1' and r.tfreecnt /= 0 then
      if r.mode.rev = '0' then
        v.txfifo(r.tdli) := r.td;
      else
        v.txfifo(r.tdli) := reverse(r.td);
      end if;
      v.tdli := (r.tdli + 1) mod FIFO_DEPTH;
      v.tfreecnt := r.tfreecnt - 1;
      -- Safe since APB has one wait state between writes
      v.td_occ := '0';
    end if;
    
    -- Update receive register and FIFO
    if r.rd_free = '1' and r.rfreecnt /= FIFO_DEPTH then
      if r.mode.rev = '0' then
        v.rd := reverse(select_data(r.rxfifo(r.rdfi), len));
      else
        v.rd := select_data(r.rxfifo(r.rdfi), len);
      end if;
      v.rdfi := (r.rdfi + 1) mod FIFO_DEPTH;
      v.rfreecnt := r.rfreecnt + 1;
      v.rd_free := '0';
    end if;
    
    if r.mode.en = '1' then             -- Core is enabled
      -- Not full detection
      if r.tfreecnt /= 0 or r.td_occ /= '1' then
        v.event.nf := '1';
        if (r.mask.nf and not r.event.nf) = '1' then
          v.irq := '1';
        end if;
      else
        v.event.nf := '0';
      end if;
      
      -- Not empty detection
      if r.rfreecnt /= FIFO_DEPTH or r.rd_free /= '1' then
        v.event.ne := '1';
        if (r.mask.ne and not r.event.ne) = '1' then
          v.irq := '1';
        end if;
      else
        v.event.ne := '0';
      end if;      
    end if;
    
    ---------------------------------------------------------------------------
    -- SPI bus control
    ---------------------------------------------------------------------------
    if (r.mode.en and not r.running) = '1' then
      if r.mode.ms = '1' then
        if r.divcnt = 0 then
          v.spio.sck := r.mode.cpol;
        end if;
        v.spio.misooen := INPUT;
        if r.mode.tw = '0' then
          v.spio.mosioen := r.mode.loopb xor OEPOL_LEVEL; 
        else
          v.spio.mosioen := INPUT;
        end if;
        v.spio.sckoen := r.mode.loopb xor OEPOL_LEVEL; 
        v.twdir := OUTPUT;
      else
        if (r.spii(1).spisel or r.mode.tw) = '0' then
          v.spio.misooen := r.mode.loopb xor OEPOL_LEVEL;
        else
          v.spio.misooen := INPUT;
        end if;
        v.spio.mosioen := INPUT; 
        v.spio.sckoen := INPUT;
        v.twdir := INPUT;
      end if;
      if ((r.mode.ms = '1' and r.tfreecnt /= FIFO_DEPTH) or
          slv_start(r.spii(1).spisel, r.mode.cpol, r.spii(1).sck, r.psck)) then
        -- Slave underrun detection
        if r.tfreecnt = FIFO_DEPTH then
          v.uf := '1';
          if (r.mask.un and not v.event.un) = '1' then
            v.irq := '1';
          end if;
          v.event.un := '1';
        end if;
        v.running := '1';
        if r.mode.ms = '1' then
          v.spio.mosioen := r.mode.loopb xor OEPOL_LEVEL; 
        end if;
        change := not r.mode.cpha;
        -- Insert cycles when cpha = '0' to ensure proper setup
        -- time for first MOSI value in master mode.
        reload := r.mode.ms and not r.mode.cpha;
      end if;
      v.bitcnt := 0;
      v.cgcnt := (others => '0');
      if r.mode.ms = '0' then
        change := not (r.mode.cpha or (r.spii(1).sck xor r.mode.cpol));
      end if;
      -- sc should not be changed on b2b
      if r.spii(1).spisel /= '0' then
        v.sc := not r.mode.cpha;
        v.psck := r.mode.cpol;
      end if;
    end if;

    ---------------------------------------------------------------------------
    -- Clock generation, only in master mode
    ---------------------------------------------------------------------------
    if r.mode.ms = '1' and (r.running = '1' or r.divcnt /= 0) then
      -- The frequency of the SPI clock relative to the system clock is
      -- determined by the div16 and pm inputs. They have the same meaning as in
      -- the MPC83xx register interface. The clock is divided by 4*([PM]+1) and
      -- if div16 is set the clock is divided by 16*(4*([PM]+1)). The duty cycle
      -- is 50%.  
      if r.divcnt = 0 then
        -- Toggle SCK unless we are in a clock gap
        if r.cgcnt = 0 or r.spio.sck /= r.mode.cpol then          
          v.spio.sck := not r.spio.sck;
          v.toggle := r.running;
        end if;
        if r.cgcnt /= 0 then
          v.cgcnt := r.cgcnt - 1;
        end if;
        reload := '1';
      else
        v.divcnt := r.divcnt - 1;
      end if;
    else
      v.divcnt := (others => '0');
    end if;

    if reload = '1' then
      -- Reload clock scale counter
      v.divcnt(4 downto 0) := unsigned('0' & r.mode.pm) + 1;
      if r.mode.div16 = '1' then
        v.divcnt := shift_left(v.divcnt, 5) - 1;
      else
        v.divcnt := shift_left(v.divcnt, 1) - 1;
      end if;
    end if;
    
    ---------------------------------------------------------------------------
    -- Handle master operation.
    ---------------------------------------------------------------------------
    if r.mode.ms = '1' then
      -- The sc bit determines if the core should read or change the data on
      -- the upcoming flank.
      if r.toggle = '1' then
        v.sc := not r.sc;
      end if;
      
      -- Sample data
      if (r.toggle and r.sc) = '1' then
        sample := '1';
      end if;

      -- Change data on the clock flank...
      if (v.toggle and not r.sc) = '1' then
        change := '1';
      end if;
      
      -- Detect multiple-master errors (mode-fault)
      if r.spii(1).spisel = '0' then
        v.mode.en := '0';
        v.mode.ms := '0';
        v.event.mme := '1';
        if (r.mask.mme and not r.event.mme) = '1' then
          v.irq := '1';
        end if;
        v.running := '0';
      end if;
      if r.mode.tw = '1' then
        indata := spii.mosi;
      else
        indata := spii.miso;
      end if;
    end if;
    
    ---------------------------------------------------------------------------
    -- Handle slave operation
    ---------------------------------------------------------------------------
    if (r.mode.en and not r.mode.ms) = '1' then
      if r.spii(1).spisel = '0' then
        v.psck := r.spii(1).sck;
        if (r.psck xor r.spii(1).sck) = '1' then
          if r.sc = '1' then
            sample := '1';
          else
            change := '1';
          end if;
          v.sc := not r.sc;
        end if;
        indata := r.spii(1).mosi;
      end if;
    end if;

    ---------------------------------------------------------------------------
    -- Used in both master and slave operation
    ---------------------------------------------------------------------------
    if sample = '1' then
      -- Detect receive overflow
      if (r.rfreecnt = 0 and r.rd_free = '0') or r.ov = '1' then
        if r.mode.tw = '0' or r.twdir = INPUT then
          v.ov := '1';
          -- Overflow event and IRQ
          if r.ov = '0' then
            if (r.mask.ov and not r.event.ov) = '1' then
              v.irq := '1';
            end if;
            v.event.ov := '1';
          end if;
        end if;
      else
        if r.mode.loopb = '1' then
          v.rxfifo(r.rdli)(0) := r.spio.mosi;
        else
          v.rxfifo(r.rdli)(0) := indata;
        end if;
        v.rxfifo(r.rdli)(31 downto 1) := r.rxfifo(r.rdli)(30 downto 0);
      end if;
      if r.bitcnt = conv_integer(len) then
        if r.ov = '0' and (r.mode.tw = '0' or r.mode.loopb = '1' or
                           (r.mode.tw = '1' and r.twdir = INPUT)) then
          v.rdli := (r.rdli + 1) mod FIFO_DEPTH;
          v.rfreecnt := v.rfreecnt - 1;
        end if;
        v.bitcnt := 0;
        v.twdir := r.twdir xor not r.mode.loopb;
        v.cgcnt := unsigned(r.mode.cg & '0');
        if r.uf = '0' and (r.mode.tw = '0' or r.mode.loopb = '1' or
                           r.twdir = OUTPUT) then
          v.tfreecnt := v.tfreecnt + 1;
          v.tdfi := (v.tdfi + 1) mod FIFO_DEPTH;
          v.txfifo(r.tdfi)(0) := '1';
        end if;
        if v.tfreecnt /= FIFO_DEPTH then
          if not (r.mode.tw = '1' and r.mode.loopb = '0' and
                  r.mode.ms = '0' and r.twdir = INPUT) then
            v.running := r.mode.ms;
          end if;
        else
          if r.mode.tw = '1' and r.mode.loopb = '0' then
            if ((r.mode.ms = '1' and r.twdir = INPUT) or
                (r.mode.ms = '0' and r.twdir = OUTPUT)) then
              v.running := '0';
            end if;
          else
            v.running := '0';
          end if;
          if v.running = '0' then
            -- LST detection
            if r.lst = '1' then
              v.event.lt := '1';
              if (r.mask.lt and not r.event.lt) = '1' then
                v.irq := '1';
              end if;
            end if;
            v.lst := '0';
          end if;
        end if;
        v.ov := '0';
        if (r.mode.tw = '0' or (r.mode.ms = '0' and r.twdir = OUTPUT)) then
          v.uf := '0';
        end if;
      else
        v.bitcnt := r.bitcnt + 1;
      end if;      
    end if;

    if change = '1' then
      if v.uf = '0' then
        v.spio.miso := r.txfifo(r.tdfi)(r.bitcnt);
        v.spio.mosi := r.txfifo(r.tdfi)(r.bitcnt);
      else
        v.spio.miso := '1';
        v.spio.mosi := '1';
      end if;
      if (r.mode.tw and not r.mode.loopb) = '1' then
        v.spio.mosioen := r.twdir;
      end if;
    end if;
        
    if r.mode.en = '0' then             -- Core is disabled
      v.tfreecnt := FIFO_DEPTH;
      v.rfreecnt := FIFO_DEPTH;
      v.tdfi := 0; v.rdfi := 0;
      v.tdli := 0; v.rdli := 0;
      v.rd_free := '1';
      v.td_occ := '0';
      v.lst := '0';
      v.uf := '0';
      v.ov := '0';
      v.running := '0';
      v.twdir := INPUT;
      v.spio.miso := '1';
      v.spio.mosi := '1';
      v.spio.misooen := INPUT;
      v.spio.mosioen := INPUT; 
      v.spio.sckoen := INPUT;
      -- Need to assign sc and psck here if spisel is low when the core is
      -- enabled
      v.sc := not r.mode.cpha;
      v.psck := r.mode.cpol;
      -- Set all first bits in txfifo to idle value
      for i in 0 to (FIFO_DEPTH-1) loop
        v.txfifo(i)(0) := '1';
      end loop;  -- i
    end if;
    
    if rstn = '0' then
      v.mode := ('0','0','0','0','0','0','0',"0000","0000",'0',"00000");
      v.event := ('0','0','0','0','0','0');
      v.mask := ('0','0','0','0','0','0');
      v.lst := '0';
      v.slvsel := (others => '1');
    end if;

    -- Synchronize inputs
    v.spii(0) := spii;
    v.spii(1) := r.spii(0);
    
    -- Update registers
    rin <= v;

    -- Update outputs
    apbo.prdata <= apbout;
    apbo.pirq <= irq;
    apbo.pconfig <= PCONFIG;
    apbo.pindex <= pindex;
        
    slvsel <= r.slvsel;

    spio <= r.spio;
    
  end process comb;

  reg: process (clk)
  begin  -- process reg
    if rising_edge(clk) then
      r <= rin;
    end if;
  end process reg;

  -- Boot message
  -- pragma translate_off
  bootmsg : report_version 
    generic map (
      "spictrl" & tost(pindex) & ": SPI controller rev " &
      tost(0) & ", irq " & tost(pirq));
  -- pragma translate_on
  
end architecture rtl;
