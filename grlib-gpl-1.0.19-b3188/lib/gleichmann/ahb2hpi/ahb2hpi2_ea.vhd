-------------------------------------------------------------------------------
-- Title      : AHB2HPI bus bridge (bidirectional)
-- Project    : LEON3MINI
-------------------------------------------------------------------------------
-- $Id: ahb2hpi2.vhd,v 1.2 2006/12/08 10:22:18 tame Exp $
-------------------------------------------------------------------------------
-- Author     : Thomas Ameseder
-- Company    : Gleichmann Electronics
-- Created    : 2005-08-19
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description:
--
-- This module implements an AHB slave that communicates with a
-- Host Peripheral Interface (HPI) device such as the CY7C67300 USB controller.
-- Supports Big Endian and Little Endian.
--
-- This is a modified version of the original AHB2HPI core with a bidirectional
-- data bus to be usable on-chip.
--
-- Restrictions: Do not use a data width other than 16 at the moment.
-------------------------------------------------------------------------------
-- Copyright (c) 2005 
-------------------------------------------------------------------------------



library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
--use ieee.std_logic_unsigned.all;
library grlib;
use grlib.amba.all;
use grlib.stdlib.all;
use grlib.devices.all;


entity ahb2hpi2 is
  generic (
    counter_width : integer := 4;
    data_width    : integer := 16;
    address_width : integer := 2;
    hindex        : integer := 0;
    haddr         : integer := 0;
    hmask         : integer := 16#fff#;
    hirq          : integer := 5
    );

  port (
    -- AHB port
    HCLK    : in  std_ulogic;
    HRESETn : in  std_ulogic;
    ahbso   : out ahb_slv_out_type;
    ahbsi   : in  ahb_slv_in_type;

    -- HPI port
    ADDR  : out std_logic_vector(address_width-1 downto 0);
    WDATA : out std_logic_vector(data_width-1 downto 0);
    RDATA : in  std_logic_vector(data_width-1 downto 0);
    nCS   : out std_ulogic;
    nWR   : out std_ulogic;
    nRD   : out std_ulogic;
    INT   : in  std_ulogic;

    drive_bus : out std_ulogic;

    -- debug port
    dbg_equal : out std_ulogic

    );
end ahb2hpi2;


architecture rtl of ahb2hpi2 is

  constant CONFIGURATION_VERSION : integer := 0;
  constant VERSION               : integer := 1;
--  constant INTERRUPT_NUMBER      : integer := hirq;
  -- register file address is the base address plus the
  -- ahb memory space reserved for the device itself
  -- its size is 64 bytes as defined with 16#fff# for its
  -- mask below
  constant REGFILE_ADDRESS       : integer := 16#340#;
  -- big endian/little endian architecture selection
  constant BIG_ENDIAN            : boolean := true;


  constant hconfig : ahb_config_type := (
    0      => ahb_device_reg
    (VENDOR_GLEICHMANN, GLEICHMANN_HPI,
     CONFIGURATION_VERSION, VERSION, hirq),
    4      => ahb_iobar(haddr, hmask),
    5      => ahb_iobar(REGFILE_ADDRESS, 16#fff#),
    others => (others => '0'));

  type reg_type is
    record
      hwrite           : std_ulogic;
      hready           : std_ulogic;
      hsel             : std_ulogic;
      addr             : std_logic_vector(address_width-1 downto 0);
      counter          : unsigned(counter_width-1 downto 0);
      Din              : std_logic_vector(data_width-1 downto 0);
      Dout             : std_logic_vector(data_width-1 downto 0);
      nWR, nRD, nCS    : std_ulogic;
      INT              : std_ulogic;
      ctrlreg          : std_logic_vector(data_width-1 downto 0);
      data_acquisition : std_ulogic;
      drive_bus : std_ulogic;
    end record;


  -- combinatorial, registered and
  -- double-registered signals
  signal c, r, rr : reg_type;

  -- signals for probing input and output data
  signal in_data_probe, out_data_probe : std_logic_vector(data_width-1 downto 0);
  signal equality_probe                : std_ulogic;

-- signal data_acquisition : std_ulogic;

  -- keep registers for debug purposes
  attribute syn_preserve                                                  : boolean;
  attribute syn_preserve of in_data_probe, out_data_probe, equality_probe : signal is true;


begin

  comb : process (INT, RDATA, HRESETn, ahbsi, r, rr)
    variable v            : reg_type;
    -- register fields
    variable tAtoCSlow    : unsigned(1 downto 0);  -- address to chip select (CS) low
    variable tCStoCTRLlow : unsigned(1 downto 0);  -- CS low to control (read/write) low

    variable tCTRLlowDvalid : unsigned(1 downto 0);  -- control (read) low to data valid
    variable tCTRLlow       : unsigned(1 downto 0);  -- control low to control high

    variable tCTRLhighCShigh : unsigned(1 downto 0);  -- control high to CS high
    variable tCShighREC      : unsigned(1 downto 0);  -- CS high to next CS recovery

    variable tCNT : unsigned(counter_width-1 downto 0);  -- timing counter

  begin

    -- assign values from the register in the beginning
    -- lateron, assign new values by looking at the new
    -- inputs from the bus
    v := r;

--    data_acquisition <= '0';

    if HRESETn = '0' then
      v.hwrite                := '0';
      v.hready                := '1';
      v.hsel                  := '0';
      v.addr                  := (others => '-');
      v.counter               := conv_unsigned(0, counter_width);
      v.Din                   := (others => '-');
      v.Dout                  := (others => '-');
      v.nWR                   := '1';
      v.nRD                   := '1';
      v.nCS                   := '1';
      v.INT                   := '0';
      -- bit 12 is reserved for the interrupt
      v.ctrlreg(15 downto 13) := (others => '0');
      v.ctrlreg(11 downto 0)  := (others => '0');
--      v.data_acquisition := '0';
	  v.drive_bus := '1';
    end if;

    -- assert data_acquisition for not longer than one cycle
    v.data_acquisition := '0';

    -- bit 12 of control register holds registered interrupt
    v.ctrlreg(12) := INT;
    v.INT         := INT;

    -- assign register fields to signals
    tAtoCSlow    := (unsigned(r.ctrlreg(11 downto 10)));
    tCStoCTRLlow := (unsigned(r.ctrlreg(9 downto 8)));

    tCTRLlowDvalid := (unsigned(r.ctrlreg(7 downto 6)));
    tCTRLlow       := (unsigned(r.ctrlreg(5 downto 4)));

    tCTRLhighCShigh := (unsigned(r.ctrlreg(3 downto 2)));
    tCShighREC      := (unsigned(r.ctrlreg(1 downto 0)));

    tCNT := conv_unsigned(conv_unsigned(0, counter_width) + tAtoCSlow + tCStoCTRLlow + tCTRLlow + tCTRLhighCShigh + tCShighREC + '1', counter_width);


    -- is bus free to use?
    if ahbsi.hready = '1' then
      -- gets selected when HSEL signal for the right slave
      -- is asserted and the transfer type is SEQ or NONSEQ
      v.hsel := ahbsi.hsel(hindex) and ahbsi.htrans(1);
    else
      v.hsel := '0';
    end if;

    -- a valid cycle starts, so all relevant bus signals
    -- are registered and the timer is started
    if v.hsel = '1' and v.counter = conv_unsigned(0, counter_width) then
      v.hwrite  := ahbsi.hwrite and v.hsel;
      v.hready  := '0';
      v.counter := conv_unsigned(tCNT, counter_width);
      v.nWR     := '1';                 --not v.hwrite;
      v.nRD     := '1';                 --v.hwrite;
      v.nCS     := '1';
      if (conv_integer(ahbsi.haddr(19 downto 8)) = REGFILE_ADDRESS) then
        if ahbsi.haddr(7 downto 0) = X"00" then
          -- disable HPI signals, read/write register data
          -- and manage AHB handshake
          if v.hwrite = '1' then
            -- take data from AHB write data bus but skip interrupt bit
            if BIG_ENDIAN then
--              v.ctrlreg := ahbsi.hwdata(31 downto 31-data_width+1);
              v.ctrlreg(15 downto 13) := ahbsi.hwdata(31 downto 29);
              v.ctrlreg(11 downto 0)  := ahbsi.hwdata(27 downto 16);
            else
--              v.ctrlreg := ahbsi.hwdata(31-data_width downto 0);
              v.ctrlreg(15 downto 13) := ahbsi.hwdata(15 downto 13);
              v.ctrlreg(11 downto 0)  := ahbsi.hwdata(11 downto 0);
            end if;
          else
            v.Din := v.ctrlreg;
          end if;
        end if;
        -- go to last cycle which signals ahb ready
        v.counter := conv_unsigned(0, counter_width);  --(tCNT - tAtoCSlow - tCStoCTRLlow - tCTRLlow - tCTRLhighCShigh - tCShighREC);
      else
        -- the LSB of 16-bit AHB addresses is always zero,
        -- so the address is shifted in order to be able
        -- to access data with a short* in C
        v.addr := ahbsi.haddr(address_width downto 1);
--        v.size := ahbsi.hsize(1 downto 0);



      end if;
    end if;

        -- fetch input data according to the AMBA specification
        -- for big/little endian architectures
        -- only relevant for 16-bit accesses
        if v.counter = tCNT - 1 then
          if BIG_ENDIAN then
            v.Dout := ahbsi.hwdata(31 downto 31-data_width+1);
          else
            v.Dout := ahbsi.hwdata(31-data_width downto 0);
          end if;
        else
          if BIG_ENDIAN then
            v.Dout := r.Dout;
          else
            v.Dout := r.Dout;
      end if;
    end if;

    -- check if counter has just been re-initialized; if so,
    -- decrement it until it reaches zero and set control signals
    -- accordingly
    if v.counter > conv_unsigned(0, counter_width) then
      if v.counter = (tCNT - tAtoCSlow) then
        v.nCS := '0';
      end if;
      if v.counter = (tCNT - tAtoCSlow - tCStoCTRLlow) then
        v.nWR := not v.hwrite;
        v.nRD := v.hwrite;
      end if;
      if v.counter = (tCNT - tAtoCSlow - tCStoCTRLlow - tCTRLlowDvalid) then
        if v.nRD = '0' then
          v.Din              := RDATA;
          v.data_acquisition := '1';
--          in_data_probe <= DATA;
        end if;
      end if;
      if v.counter = (tCNT - tAtoCSlow - tCStoCTRLlow - tCTRLlow) then
        v.nWR := '1';
        v.nRD := '1';
      end if;
      if v.counter = (tCNT - tAtoCSlow - tCStoCTRLlow - tCTRLlow - tCTRLhighCShigh) then
        v.nCS := '1';
      end if;
      if v.counter = (tCNT - tAtoCSlow - tCStoCTRLlow - tCTRLlow
                      - tCTRLhighCShigh - tCShighREC) then
        v.hready := '1';
      end if;
      -- note: since the counter is queried and immediately
      -- decremented afterwards, the value in hardware
      -- is one lower than given in the if statement
      v.counter := v.counter - 1;
    else
      v.hready := '1';
    end if;

    -- three-state buffer: drive bus during a write cycle
    -- and hold data for one more clock cycle, then
    -- shut off from the bus
--    if ((r.nCS = '0' and r.nWR = '0') or (rr.nCS = '0' and r.nWR = '0') or
--        (r.nCS = '0' and rr.nWR = '0') or (rr.nCS = '0' and rr.nWR = '0')) then
--      WDATA <= r.Dout;
--      drive_bus <= '1';
--    else
      --WDATA <= (others => '-');
--	WDATA <= (others => 'Z');
--	  drive_bus <= '0';
--    end if;


	if r.nCS='0' and r.nWR='0' then
		v.drive_bus := '1';
	elsif ((r.nCS='0' and rr.nCS='1') or ((r.Addr xor rr.Addr) /= "00")) then
		v.drive_bus := '0';
	end if;

    -- assign variable to a signal
    c <= v;

    -- HPI outputs
    ADDR <= r.addr;
    nCS  <= r.nCS;
    nWR  <= r.nWR;
    nRD  <= r.nRD;

    -- output data is assigned to the both the high and the
    -- low word of the 32-bit data bus
    ahbso.hrdata(31 downto 31-data_width+1) <= r.Din;
    ahbso.hrdata(31-data_width downto 0)    <= r.Din;  --(others => '-');

--    if v.addr(0) = '0' then
--      if BIG_ENDIAN then
--        ahbso.hrdata(31 downto 31-data_width+1) <= r.Din;
--        ahbso.hrdata(31-data_width downto 0) <= (others => '-');
--      else
--        ahbso.hrdata(31 downto 31-data_width+1) <= (others => '-');
--        ahbso.hrdata(31-data_width downto 0) <= r.Din;
--      end if;
--    else
--      if BIG_ENDIAN then
--        ahbso.hrdata(31 downto 31-data_width+1) <= (others => '-');
--        ahbso.hrdata(31-data_width downto 0) <= r.Din;
--      else
--        ahbso.hrdata(31 downto 31-data_width+1) <= r.Din;
--        ahbso.hrdata(31-data_width downto 0) <= (others => '-');
--      end if;
--    end if;

    ahbso.hready <= r.hready;

--    ahbso.hirq <= (hirq => r.ctrlreg(12), others => '0');  -- propagate registered interrupt
    ahbso.hirq       <= (others => '0');
    ahbso.hirq(hirq) <= r.ctrlreg(12);
  end process comb;


	WDATA <= r.Dout;
	drive_bus <=  (r.drive_bus or (not r.nWR)) when ((r.Addr xor rr.Addr) = "00") else'0';

  -- constant AHB outputs
  ahbso.hresp   <= "00";                -- answer OK by default
  ahbso.hsplit  <= (others => '0');     -- no SPLIT transactions
  ahbso.hcache  <= '0';                 -- cacheable yes/no
  ahbso.hconfig <= hconfig;
  ahbso.hindex  <= hindex;


  reg : process (HCLK)
  begin
    if rising_edge(HCLK) then
      r  <= c;
      rr <= r;
    end if;
  end process;

  ---------------------------------------------------------------------------------------
  -- DEBUG SECTION for triggering on read/write inconsistency
  -- use a C program that writes data AND reads it immediately afterwards
  -- dbg_equal start with being '0' after reset, then goes high during the transaction
  -- it should not have a falling edge during the transactions
  -- -> trigger on that event
  -- note regarding HPI data transactions:
  --       the address is written first before writing/reading at address B"10"
  --       the data register is at address B"00"
  ---------------------------------------------------------------------------------------

  -- read at the rising edge of the read signal
  -- (before the next read data is received)
--  data_acquisition <=  '1' when rr.nrd = '1' and r.nrd = '0' else
--                       '0';

  -- read data to compare to
  in_data_probe <= r.din;

  check_data : process (HCLK, HRESETn)
  begin
    if HRESETn = '0' then
      out_data_probe <= (others => '0');
      equality_probe <= '0';
    elsif rising_edge(HCLK) then
      -- is data being written to the *data* register?
      if r.nwr = '0' and r.ncs = '0' and r.addr = "00" then
        out_data_probe <= r.dout;
      end if;
      if r.data_acquisition = '1' then
        if in_data_probe = out_data_probe then
          equality_probe <= '1';
        else
          equality_probe <= '0';
        end if;
      end if;
    end if;
  end process;

  dbg_equal <= equality_probe;

-- pragma translate_off
  bootmsg : report_version
    generic map ("ahb2hpi2" & tost(hindex) &
                 ": AHB-to-HPI Bridge, irq " &
                 tost(hirq));
-- pragma translate_on

end rtl;
