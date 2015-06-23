--------------------------------------------------------------------------
-- Package of bit sync and DPLL components
--
--
--

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;

library work;
use work.convert_pack.all;

package spi_pack is

  component spi_flash_interface
    generic(
      NUM_CS        : natural;  -- Number of SPI device selects
      DEF_R_0       : unsigned(31 downto 0); -- SPI Chip Selects
      DEF_R_1       : unsigned(31 downto 0); -- SPI Command byte
      DEF_R_2       : unsigned(31 downto 0)  -- SPI Address (24 bits)
    );
    port (
      -- System Clock and Clock Enable
      sys_rst_n  : in  std_logic;
      sys_clk    : in  std_logic;
      sys_clk_en : in  std_logic;

      -- Bus interface
      adr_i      : in  unsigned(3 downto 0);
      sel_i      : in  std_logic;
      we_i       : in  std_logic;
      dat_i      : in  unsigned(31 downto 0);
      dat_o      : out unsigned(31 downto 0);
      ack_o      : out std_logic;

      -- SPI interface
      -- "hold" and "WP" are not implemented.
      spi_cs_o   : out unsigned(NUM_CS-1 downto 0);
      spi_sck_o  : out std_logic;
      spi_so_o   : out std_logic;
      spi_si_i   : in  std_logic

    );
  end component;

  component spi_flash_sys_init
    generic(
      SYS_CLK_RATE : real;
      FLASH_IDLE   : natural;  -- Number of ms idle before RAM-mapped FLASH operation closeout
      DECODE_BITS  : natural;  -- Number of init address upper-bits decoded to select individual SPI devices.
      DEF_R_0      : unsigned(31 downto 0) := str2u("00000001",32); -- low-level SPI Chip Select control
      DEF_R_1      : unsigned(31 downto 0) := str2u("00000003",32); -- low-level SPI Command byte
      DEF_R_2      : unsigned(31 downto 0) := str2u("007F0000",32); -- low-level SPI Address
      DEF_R_3      : unsigned(31 downto 0) := str2u("007F0000",32); -- Init Address
      DEF_R_4      : unsigned(31 downto 0) := str2u("00000100",32); -- Init Bytes
      DEF_R_5      : unsigned(31 downto 0) := str2u("00000001",32)  -- Init Settings
    );
    port (
      -- System Clock and Clock Enable
      sys_rst_n  : in  std_logic;
      sys_clk    : in  std_logic;
      sys_clk_en : in  std_logic;

      -- Bus interface
      adr_i      : in  unsigned(3 downto 0);
      sel_i      : in  std_logic;
      we_i       : in  std_logic;
      dat_i      : in  unsigned(31 downto 0);
      dat_o      : out unsigned(31 downto 0);
      ack_o      : out std_logic;

      -- RAM mapped SPI FLASH access port
      -- (fl_ack_o may take ~5ms during page program)
      fl_adr_i   : in  unsigned(31 downto 0);
      fl_sel_i   : in  std_logic;
      fl_we_i    : in  std_logic;
      fl_dat_i   : in  unsigned(7 downto 0);
      fl_dat_o   : out unsigned(7 downto 0);
      fl_ack_o   : out std_logic;

      -- Init data output port
      init_adr_o : out unsigned(31 downto 0);
      init_dat_o : out unsigned(7 downto 0);
      init_cyc_o : out std_logic;
      init_ack_i : in  std_logic;
      init_fin_o : out std_logic; -- Stays high when init is finished

      -- SPI interface
      -- "hold" and "WP" are not implemented.
      spi_adr_o  : out unsigned(DECODE_BITS-1 downto 0);
      spi_cs_o   : out std_logic;
      spi_sck_o  : out std_logic;
      spi_so_o   : out std_logic;
      spi_si_i   : in  std_logic

    );
  end component;

  component spi_flash_simulator
    generic(
      SYS_CLK_RATE   : real;
      FLASH_ADR_BITS : natural; -- Flash memory size is based on this
      FLASH_INIT     : string   -- Default RX packet digestion settings
    );
    port (
      -- System Clock and Clock Enable
      sys_rst_n  : in  std_logic;
      sys_clk    : in  std_logic;
      sys_clk_en : in  std_logic;

      -- SPI interface
      -- "hold" and "WP" are not implemented.
      spi_cs_i   : in  std_logic;
      spi_sck_i  : in  std_logic;
      spi_si_i   : in  std_logic;
      spi_so_o   : out std_logic

    );
  end component;

end spi_pack;

-------------------------------------------------------------------------------
-- SPI Flash Interface
-------------------------------------------------------------------------------
--
-- Author: John Clayton
-- Date  : July 26, 2013 Created this module starting with code copied from
--                       another module.
--         July 31, 2013 Modified this module in simulation, until it looked
--                       correct.  Tested in hardware.  It works!
--         Aug. 10, 2013 Refined the design so that it enforces a minimum
--                       spi_cs_o high time between assertions, thus allowing
--                       the design to actually program SPI FLASH chips using
--                       a 50 MHz clock, instead of just at 25 MHz.
--
-- Description
-------------------------------------------------------------------------------
-- This module is an interface to a SPI serial FLASH memory.  The code was
-- written in order to keep it as generic as possible, but without many
-- extra frills.  The module was written by reading the Adesto Technologies
-- AT25DF641 and ST Micro M25P64 datasheets.
--
-- There are three registers involved in its use.  There is one for the
-- SPI command byte, one for the 24-bit SPI address, and one for data to
-- be read from, or written to, the SPI serial FLASH device.
--
-- The SPI serial FLASH interface is implemented using four signals:
--   spi_cs_o  = SPI chip select outputs
--   spi_sck_o = Serial Clock output
--   spi_si_i  = Serial Data input
--   spi_so_o  = Serial Data output
--
-- For multiple SPI devices, the spi_cs_o output is implemented as a bus
-- of register driven outputs.  The size of the bus is controlled by generics,
-- allowing any number of SPI devices to be selected.  Because these outputs
-- are not decoded as a 1-active-of-N type signal, it is possible to select
-- multiple devices simultaneously, which may work well for writing and
-- erasing, but not for reading.  You have been warned!
--
-- The spi_sck_o output is generated at half the sys_clk rate, and it is
-- not adjustable.  To obtain operation at lower clock rates without
-- using a lower sys_clk frequency, consider slowing down the operation
-- of this module by the use of the sys_clk_en signal.
--
-- This module takes the approach that the serial communication with the 
-- SPI device is not continuous.  Instead, the command is completed in
-- segments or phases.  To begin a command, a bus write to the SPI chip
-- select register asserts '0' on the desired chip select bits.  Then, a write
-- to the command register causes the command to be sent out, generating a
-- burst of eight clock pulses.  Another separate bus cycle is then required
-- in order to send out the address.  After that, bus cycles can be used to
-- either read or write data bytes.  At the conclusion of those activities,
-- the command can be terminated or executed by simply writing to the SPI
-- chip select register to raise the chip select bit back to a '1'.
--
-- This approach works because the spi_sck_o output is under control of
-- this module.
--
-- There are no provisions for use of the "hold" or "WP" (write protect)
-- signals.  If desired, it might be possible to use sys_clk_en as a hold
-- signal, although this has not been tested or investigated in any detail.
--
-- The registers are summarized as follows:
--
-- Address      Structure   Function
-- -------      ---------   -----------------------------------------------------
--   0x0           (N:0)    SPI chip Selects, where N=NUM_CS-1.
--   0x1           (7:0)    SPI Command Byte
--   0x2          (23:0)    SPI Address Bytes
--   0x3+          (7:0)    SPI Data
--
--   Notes on Registers:
--
--   (0x0) SPI Chip Selects
--
--     Writing to this register selects which associated spi_cs_o outputs are
--     active.  The spi_cs_o outputs are driven directly from the register,
--     and can be changed at any time.  SPI chip selects are low asserted,
--     so the bits in this register are loaded with all ones initially.
--     To initiate a command, the appropriate spi_cs_o bit must be cleared
--     to zero.  To conclude and execute a command, the spi_cs_o bit must
--     be set back to one.
--     Reading this register returns the contents, but does not affect the
--     SPI interface.
--     Care should be exercised when using this register with multiple SPI
--     devices, as it is possible to activate more than one device.  This
--     may work well for writing to the devices, but will result in data bit
--     collisions if multiple devices are read simultaneously.
--
--   (0x1) SPI Command Byte
--
--     Writing to this register causes the contents to be updated, and also
--     sends out the new contents in serial form, most significant bit first.
--     Reading this register returns the contents, but does not affect the
--     SPI interface.
--
--   (0x2) SPI Address Bytes
--
--     Writing to this register causes the contents to be updated, and also
--     sends out the new contents in serial form, most significant bit first.
--     Reading this register returns the contents, but does not affect the
--     SPI interface.
--
--   (0x3+) SPI Data Byte (Addresses in the range [0x3..0xF] access this.)
--
--     There is no local storage register inside the module for this address.
--     Writing to this address causes the data to be sent out in serial form,
--     most significant bit first.
--     Reading this address causes a burst of eight clock pulses to be issued
--     from the SPI interface, effectively reading in eight bits and returning
--     them in parallel over the bus interface.
--     Successive reads or writes therefore program or read successive locations
--     in the SPI device.
--     It should be noted that the SPI serial FLASH devices may allow continuous
--     reads which go on indefinitely, cycling through the entire contents of
--     the FLASH array.  On the other hand, writes are buffered inside the
--     FLASH device, so that a "Byte/Page Program" instruction may allow from
--     1 to 256 sequential bytes to be programmed.  If more bytes are sent to
--     the FLASH device, it may simply cause the FIFO buffer inside the FLASH
--     device to hold the last 256 bytes for programming, discarding the bytes
--     which were written at first.
--
-- The sys_rst_n input is an asynchronous reset.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;

library work;
use work.convert_pack.all;

  entity spi_flash_interface is
    generic(
      NUM_CS        : natural := 1;  -- Number of SPI device selects
      DEF_R_0       : unsigned(31 downto 0) := str2u("00000001",32); -- SPI Chip Selects
      DEF_R_1       : unsigned(31 downto 0) := str2u("00000003",32); -- SPI Command byte
      DEF_R_2       : unsigned(31 downto 0) := str2u("007F0000",32)  -- SPI Address (24 bits)
    );
    port (
      -- System Clock and Clock Enable
      sys_rst_n  : in  std_logic;
      sys_clk    : in  std_logic;
      sys_clk_en : in  std_logic;

      -- Bus interface
      adr_i      : in  unsigned(3 downto 0);
      sel_i      : in  std_logic;
      we_i       : in  std_logic;
      dat_i      : in  unsigned(31 downto 0);
      dat_o      : out unsigned(31 downto 0);
      ack_o      : out std_logic;

      -- SPI interface
      -- "hold" and "WP" are not implemented.
      spi_cs_o   : out unsigned(NUM_CS-1 downto 0);
      spi_sck_o  : out std_logic;
      spi_so_o   : out std_logic;
      spi_si_i   : in  std_logic

    );
end spi_flash_interface;

architecture beh of spi_flash_interface is

-- Constants
constant DAT_SIZE     : natural := 32;

-- Internal signal declarations
signal reg_cs    : unsigned(NUM_CS-1 downto 0);
signal reg_cmd   : unsigned(7 downto 0);
signal reg_adr   : unsigned(23 downto 0);
signal sr        : unsigned(7 downto 0);
signal clk_count : unsigned(4 downto 0);
signal ack       : std_logic;
  -- For the state machine
type FSM_STATE_TYPE is (IDLE, SEND_CMD, SEND_ADR, SHIFT_A2, SHIFT_A1, SHIFT_A0, GET_BYTE, GIVE_ACK);
signal fsm_state      : FSM_STATE_TYPE;


-----------------------------------------------------------------------------
begin

  -- Register read mux
  with (adr_i) select
  dat_o <=
    u_resize(reg_cs,DAT_SIZE)   when "0000",
    u_resize(reg_cmd,DAT_SIZE)  when "0001",
    u_resize(reg_adr,DAT_SIZE)  when "0010",
    u_resize(sr,DAT_SIZE)       when others;

  -- Create acknowledge signal
  ack   <= '1' when sel_i='1' and fsm_state=GIVE_ACK else '0';

  ack_o <= ack;

  -- Create SPI signals
  spi_cs_o  <= reg_cs;
  spi_so_o  <= sr(7);
  spi_sck_o <= clk_count(0);

  -- The main process
  main_proc: process(sys_clk, sys_rst_n)
  begin
    if (sys_rst_n='0') then
      reg_cs    <= DEF_R_0(NUM_CS-1 downto 0);
      reg_cmd   <= DEF_R_1(reg_cmd'length-1 downto 0);
      reg_adr   <= DEF_R_2(reg_adr'length-1 downto 0);
      sr        <= (others=>'0');
      clk_count <= to_unsigned(0,clk_count'length);
      fsm_state   <= IDLE;
    elsif (sys_clk'event and sys_clk='1') then
      if (sys_clk_en='1') then
        -- Decrement the clock counter
        if (clk_count>0) then
          clk_count <= clk_count-1;
          -- Handle the shift register
          if (fsm_state=GET_BYTE and clk_count(0)='0') or (fsm_state/=GET_BYTE and clk_count(0)='1') then
            sr <= sr(6 downto 0) & spi_si_i;
          end if;
        end if;
        -- Handle state transitions
        case (fsm_state) is

          when IDLE =>
            null;

          when SEND_CMD =>
            sr <= reg_cmd;
            clk_count <= to_unsigned(16,clk_count'length);
            fsm_state <= SHIFT_A0;

          when SEND_ADR =>
            sr <= reg_adr(23 downto 16);
            clk_count <= to_unsigned(16,clk_count'length);
            fsm_state <= SHIFT_A2;

          when SHIFT_A2 =>
            if (clk_count=0) then
              sr <= reg_adr(15 downto 8);
              clk_count <= to_unsigned(16,clk_count'length);
              fsm_state <= SHIFT_A1;
            end if;

          when SHIFT_A1 =>
            if (clk_count=0) then
              sr <= reg_adr(7 downto 0);
              clk_count <= to_unsigned(16,clk_count'length);
              fsm_state <= SHIFT_A0;
            end if;

          when SHIFT_A0 =>
            if (clk_count=0) then
              fsm_state <= GIVE_ACK;
            end if;

          when GET_BYTE =>
            if (clk_count=0) then
              fsm_state <= GIVE_ACK;
            end if;

          when GIVE_ACK =>
            fsm_state <= IDLE;

          --when others => 
          --  fsm_state <= IDLE;
        end case;

        -- Handle bus writes to registers
        if (fsm_state=IDLE and sel_i='1' and we_i='1') then
          case (adr_i) is
            when "0000" =>
              reg_cs <= dat_i(NUM_CS-1 downto 0);
              fsm_state <= GIVE_ACK;
            when "0001" =>
              reg_cmd <= dat_i(reg_cmd'length-1 downto 0);
              fsm_state <= SEND_CMD;
            when "0010" =>
              reg_adr <= dat_i(reg_adr'length-1 downto 0);
              fsm_state <= SEND_ADR;
            when others => null;
              sr <= dat_i(sr'length-1 downto 0);
              clk_count <= to_unsigned(16,clk_count'length);
              fsm_state <= SHIFT_A0;
          end case;
        end if;
        -- Handle SPI read cycle
        if (fsm_state=IDLE and sel_i='1' and we_i='0') then
          case (adr_i) is
            when "0000" =>
              fsm_state <= GIVE_ACK;
            when "0001" =>
              fsm_state <= GIVE_ACK;
            when "0010" =>
              fsm_state <= GIVE_ACK;
            when others =>
              clk_count <= to_unsigned(16,clk_count'length);
              fsm_state <= GET_BYTE;
          end case;
        end if;

      end if; -- sys_clk_en
    end if; -- sys_clk
  end process;


end beh;

-------------------------------------------------------------------------------
-- SPI Flash System Initializer
-------------------------------------------------------------------------------
--
-- Author: John Clayton
-- Date  : July 31, 2013 Created this module starting with code copied from
--                       another module.  Began writing description.
--         Aug.  5, 2013 Simulated the design.  Revamped the register
--                       structure, added init_chain feature.  Combined
--                       states in fl_state FSM.
--         Aug.  7, 2013 Added explicit reset bit.
--
-- Description
-------------------------------------------------------------------------------
-- This module uses an interface to SPI serial FLASH memory devices to allow
-- reading/writing/erasing of the FLASH.  It includes a state machine that
-- coordinates many of the required commands automatically, to make the
-- process of reading and writing SPI FLASH appear as though a simple RAM
-- is being used.  Moreover, the state machine has an initialization mode
-- which can read bytes out of the selected SPI FLASH device and present
-- them on an 8-bit parallel output port.
--
-- The actual rate of outputting "initialization bytes" is determined by
-- the init_ack_i input, up to the maximum available rate Fmax of approx.
-- 2.7 MBytes/second.  This maximum byte transfer rate is calculated
-- according to the following formula:
--
--   Fmax = (Fsys_clk / N)
--
-- Where N=18 sys_clks required per byte obtained, and Fsys_clk is
-- currently 50 MHz.  Other sys_clk rates would also work.
--
-- The init_adr_o output allows the outgoing bytes to be treated in
-- different ways, or stored into different places, depending on the address
-- setting being used.  Note that the init_adr_o output is taken directly
-- from the init address register, which refers to the addresses within
-- the SPI devices themselves.  This signal therefore not required to be
-- used as-is during initialization.  Feel free to substitute any addresses
-- you want, or re-map the initialization addresses as needed.
--
-- The idea is that the parallel output bytes can be used to send commands
-- on a system bus.  One way to do this is to attach a UART, which would
-- inject ASCII characters into an ASCII command interpreter, such as
-- "async_syscon" or "udp_ip_syscon".
--
-- Another way would be to send the bytes into a binary command interpreter.
--
-- Another way would be to attach the init port as a requester on the arbiter
-- for the target bus.
--
-- In addition to creating initialization commands at power on, the output
-- bytes can also be treated as DSP samples of a waveform.  Thus, the output
-- could be used to generate audio "sound bytes" [pun intended] at a set
-- sample rate and bits per sample.
--
-- In fact, it is conceivable that through the use of a command interpreter,
-- a final initialization command could reprogram the initialization address
-- and quantity, in order to begin a whole new initialization sequence!  Oh,
-- the sheer joy of it!  If there is no command interpreter being used, there
-- is an alternative method of achieving this serial-init-sequencing joy.
-- A chain enable bit is provided in the initialization settings register
-- which causes the initialization sequencer to "re-up" by using the last
-- eight bytes of the current initialization sequence as a new address and
-- quantity for the next one.  Isn't that simply grand?
--
-- Think of what you could do...  You could set up registers in the first
-- initialization sequence, and then invoke another sequence which would
-- play some kind of audio greeting.  It could be music, or perhaps a voice.
-- Like the audio might say "System is now fully functional, and ready!"
-- Like that.  You know, it isn't bad to have a healthy imagination.
-- At least, that's what I imagine.
--
-- As a corollary benefit of implementing the initialization function, an
-- additional SPI FLASH memory mapping "feature" is provided.  This means
-- that the entire contents of the SPI FLASH device is memory mapped, with a
-- separate address for each byte within the device.  Sequential reads and
-- writes are allowed within this address space, and the needed WREN and
-- other commands to perform the reads/writes are performed automatically.
-- This also means that the bus cycle acknowledge signal when using the
-- memory mapped region can take quite a long time to appear, on the order
-- of 5 ms.  Also note that the key word when using the memory mapped
-- region is "sequential."  This is so important that this module actually
-- enforces sequential accesses, by keeping a copy of the initial address
-- and incrementing that during the session.  The "session" begins when
-- an access is requested within the memory mapped region, and ends when
-- an "access idle" timeout is reached.  Therefore, temporally-sequential
-- accesses which attempt to decrement the address, or jump around in
-- other ways, will actually result in sequential bytes being read/written
-- during the session.
--
-- The system initializer is an extension of a much simpler register-based
-- "low-level" SPI Flash interface module.  The "low-level" features are
-- preserved in this module.
--
-- The original interface was written in order to be as generic as possible,
-- without many extra frills.  The module was written by and tested using
-- the Adesto Technologies AT25DF641 and ST Micro M25P64 datasheets.  Also,
-- hardware testing was initially done on the M25P64 mounted on a Lattice
-- Semiconductor "Versa" FPGA development board.  Nevertheless, this design
-- should work quite easily with other SPI FLASH devices and other FPGAs.
--
-- For the basic SPI interface, there are three registers involved.
-- There is one for the SPI command byte, one for the 24-bit SPI address, 
-- and one for data to be read from, or written to, the SPI serial FLASH 
-- device.  The basic interface was preserved in order to allow for any
-- desired command to be explicitly executed via register accesses.
--
-- The SPI serial FLASH interface is implemented using four signals:
--   spi_cs_o  = SPI chip select outputs
--   spi_sck_o = Serial Clock output
--   spi_si_i  = Serial Data input
--   spi_so_o  = Serial Data output
--
-- For multiple SPI devices, the spi_cs_o output is implemented as a bus
-- of register driven outputs.  The size of the bus is controlled by generics,
-- allowing any number of SPI devices to be selected.  Because these outputs
-- are not decoded as a 1-active-of-N type signal, it is possible to select
-- multiple devices simultaneously, which may work well for writing and
-- erasing, but not for reading.  You have been warned!
--
-- The spi_sck_o output is generated at half the sys_clk rate, and it is
-- not adjustable.  To obtain operation at lower clock rates without
-- using a lower sys_clk frequency, consider slowing down the operation
-- of this module by the use of the sys_clk_en signal.
--
-- This module takes the approach that the serial communication with the 
-- SPI device is not continuous.  Instead, the command is completed in
-- segments or phases.  To begin a command, a bus write to the SPI chip
-- select register asserts '0' on the desired chip select bits.  Then, a write
-- to the command register causes the command to be sent out, generating a
-- burst of eight clock pulses.  Another separate bus cycle is then required
-- in order to send out the address.  After that, bus cycles can be used to
-- either read or write data bytes.  At the conclusion of those activities,
-- the command can be terminated or executed by simply writing to the SPI
-- chip select register to raise the chip select bit back to a '1'.
--
-- This approach works because the spi_sck_o output is under control of
-- this module.
--
-- There are no provisions for use of the "hold" or "WP" (write protect)
-- signals.  If desired, it might be possible to use sys_clk_en as a hold
-- signal, although this has not been tested or investigated in any detail.
--
-- The registers are summarized as follows:
--
-- Address   Structure        Function
-- -------   --------------   -----------------------------------------------------
--   0x0     (N+16:16,N:0)    SPI chip Selects, where N=NUM_CS-1.
--   0x1             (7:0)    SPI Command Byte
--   0x2            (23:0)    SPI Address Bytes
--   0x3            (31:0)    Init Address
--   0x4            (31:0)    Init Quantity (bytes)
--   0x5             (3:0)    Init Settings
--   0x6+            (7:0)    SPI Data
--
--   Notes on Registers:
--
--   (0x0) low-level SPI Chip Select control
--
--     This register contains a single bit, which is directly mapped to the
--     spi_cs_o output during low-level SPI operations.  During ram mapped
--     operations and initialization sequences, the spi_cs_o output is
--     controlled automatically by a state machine so that during those
--     operations, this bit has no effect.
--
--   (0x1) low-level SPI Command Byte
--
--     This is part of the low-level SPI interface, and is not involved in
--     initialization or RAM mapping of the SPI devices.
--
--     Writing to this register causes the contents to be updated, and also
--     sends out the new contents in serial form, most significant bit first.
--     Reading this register returns the contents, but does not affect the
--     SPI interface.
--
--   (0x2) low-level SPI Address
--
--     This is part of the low-level SPI interface, and is not involved in
--     initialization or RAM mapping of the SPI devices.
--
--     Writing to this register causes the contents to be updated, and also
--     sends out the new contents in serial form, most significant bits first.
--     Reading this register returns the contents, but does not affect the
--     SPI interface.
--
--     The number of bytes used for SPI addresses is set by the constant
--     SPI_ADR_BYTES.
--
--   (0x3) Init Address
--
--     Bits (31:0) contain the initialization address, which consists of
--       four bytes: [decode][sector][page][byte]
--       This grouping of fields is actually based on the size of the
--       SPI FLASH devices being tested.  If larger devices are used,
--       for example, then the [decode] field may use fewer bits, and
--       the [sector] field may grow.  Similarly, the [page] field might
--       change if the devices being used have pages larger than 256
--       bytes.  So, it's a matter of interpretation.  The main idea is
--       for form a flat address space which maps all the attached SPI
--       devices.
--
--   (0x4) Initialization Quantity (Bytes)
--     This register contains the number of bytes to read from the SPI
--     FLASH device during an initialization operation.
--     The number can be quite large, up to 0x800000 (8 Mbytes) for the
--     AT25DF641 and M25P64.  In anticipation of larger future devices,
--     this field was made a full 32-bits, allowing up to 4 gigabytes.
--     Operation of the initialization cycle begins immediately once
--     this field is set to anything greater than zero.  Also, the
--     quantity is "live" and it decrements during initialization.
--
--   (0x5) Init Settings
--
--     Bit  (0) is the R/W Access Enable bit.  Set this bit in order to
--       freely read and write to the SPI FLASH via the memory mapped
--       interface.  When it is cleared, the memory mapped interface does
--       not respond with a bus cycle acknowledge, since it is not
--       operating.
--     Bit  (1) is the Initialization chain enable bit.  Setting this bit
--       causes the last eight bytes of the initialization to be withheld.
--       Instead of being sent out as bus cycles on the parallel init bus,
--       the bytes are used to reset the initializer for another run
--       using a new address and a new quantity.  Since the init_ack_i
--       input is used to throttle initialization cycles when delays are
--       required, no delay is provided within the eight "re-up" bytes.
--       The re-up bytes are composed of four address bytes, followed by
--       four quantity bytes.  The fields are stored least significant
--       byte first.
--     Bit  (2) is the Erase bit.  Set this bit to erase the sector
--       currently selected by the [sector] field in the address register.
--       Note that sector erase times can be on the order of seconds.
--       (Typically 1s, but up to 3s for M25P64.  Typically 400ms, but
--       up to 950ms for AT25DF641.)  Since the erase operation is
--       self-timed inside the device, this module polls the device status
--       register to see when the erase operation is completed.  When it
--       is, the erase bit is then cleared.  No other operations are
--       possible while this is occurring.  Because the sector erase can
--       take so long, there is a way to break out by using the explicit
--       reset bit.  Also, there is no automatic timeout from the sector
--       erase operation.
--     Bit  (3) is an explicit reset bit.  Setting it resets both state
--       machines.  It is a write only bit, and returns a '0' when read.
--       It can be used to "break out" of an operation, such as a long
--       sector erase.
--
--   (0x6+) SPI Data Byte (System cycles in the range [0x6..0xF] access this.)
--
--     This is part of the low-level SPI interface, and is not involved in
--     initialization or RAM mapping of the SPI devices.
--
--     There is no local storage register inside the module for this address.
--     Writing to this address causes the data to be sent out in serial form,
--     most significant bit first.
--     Reading this address causes a burst of eight clock pulses to be issued
--     from the SPI interface, effectively reading in eight bits and returning
--     them in parallel over the bus interface.
--     Successive reads or writes therefore program or read successive locations
--     in the SPI device.
--     It should be noted that the SPI serial FLASH devices may allow continuous
--     reads which go on indefinitely, cycling through the entire contents of
--     the FLASH array.  On the other hand, writes are buffered inside the
--     FLASH device, so that a "Byte/Page Program" instruction may allow from
--     1 to 256 sequential bytes to be programmed.  If more bytes are sent to
--     the FLASH device, it may simply cause the FIFO buffer inside the FLASH
--     device to hold the last 256 bytes for programming, discarding the bytes
--     which were written at first.
--
-- The sys_rst_n input is an asynchronous reset.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;

library work;
use work.dds_pack.all;
use work.convert_pack.all;

  entity spi_flash_sys_init is
    generic(
      SYS_CLK_RATE : real    := 50000000.0;
      FLASH_IDLE   : natural := 2;  -- Number of ms idle before RAM-mapped FLASH operation closeout
      DECODE_BITS  : natural := 8;  -- Number of init address upper-bits decoded to select individual SPI devices.
      DEF_R_0      : unsigned(31 downto 0) := str2u("00000001",32); -- low-level SPI Chip Select control
      DEF_R_1      : unsigned(31 downto 0) := str2u("00000003",32); -- low-level SPI Command byte
      DEF_R_2      : unsigned(31 downto 0) := str2u("007F0000",32); -- low-level SPI Address
      DEF_R_3      : unsigned(31 downto 0) := str2u("007F0000",32); -- Init Address
      DEF_R_4      : unsigned(31 downto 0) := str2u("00000100",32); -- Init Bytes
      DEF_R_5      : unsigned(31 downto 0) := str2u("00000001",32)  -- Init Settings
    );
    port (
      -- System Clock and Clock Enable
      sys_rst_n  : in  std_logic;
      sys_clk    : in  std_logic;
      sys_clk_en : in  std_logic;

      -- Bus interface
      adr_i      : in  unsigned(3 downto 0);
      sel_i      : in  std_logic;
      we_i       : in  std_logic;
      dat_i      : in  unsigned(31 downto 0);
      dat_o      : out unsigned(31 downto 0);
      ack_o      : out std_logic;

      -- RAM mapped SPI FLASH access port
      -- (fl_ack_o may take ~5ms during page program)
      fl_adr_i   : in  unsigned(31 downto 0);
      fl_sel_i   : in  std_logic;
      fl_we_i    : in  std_logic;
      fl_dat_i   : in  unsigned(7 downto 0);
      fl_dat_o   : out unsigned(7 downto 0);
      fl_ack_o   : out std_logic;

      -- Init data output port
      init_adr_o : out unsigned(31 downto 0);
      init_dat_o : out unsigned(7 downto 0);
      init_cyc_o : out std_logic;
      init_ack_i : in  std_logic;
      init_fin_o : out std_logic; -- Stays high when init is finished

      -- SPI interface
      -- "hold" and "WP" are not implemented.
      spi_adr_o  : out unsigned(DECODE_BITS-1 downto 0);
      spi_cs_o   : out std_logic;
      spi_sck_o  : out std_logic;
      spi_so_o   : out std_logic;
      spi_si_i   : in  std_logic

    );
end spi_flash_sys_init;

architecture beh of spi_flash_sys_init is

-- Constants
constant DAT_SIZE         : natural := 32;
constant IDLE_TB_FREQ     : real    := 1000.0; -- Timebase is millisecond resolution
constant IDLE_TB_ACC_BITS : natural := 24;
constant IDLE_TIMER_WIDTH : natural := timer_width(FLASH_IDLE);

constant SPI_ADR_BYTES    : natural := 3; -- Increase for larger size devices
constant SPI_ACNT_WIDTH   : natural := timer_width(SPI_ADR_BYTES);

constant SPI_CMD_PP       : natural := 16#02#;
constant SPI_CMD_READ     : natural := 16#03#;
constant SPI_CMD_RDSR     : natural := 16#05#;
constant SPI_CMD_WREN     : natural := 16#06#;
constant SPI_CMD_SE       : natural := 16#D8#;

constant CS_HIGH_CYCLES   : natural := 8; -- minimum # of sysclks spi_cs_o will be driven high.
constant CLK_COUNT_1BYTE  : natural := 16;
constant CLK_COUNT_DESEL  : natural := CLK_COUNT_1BYTE+CS_HIGH_CYCLES;

-- Internal signal declarations
signal reg_cs        : std_logic;
signal reg_cmd       : unsigned(7 downto 0);
signal reg_adr       : unsigned(31 downto 0);
signal reg_ispi_adr  : unsigned(31 downto 0);
signal adr_count     : unsigned(SPI_ACNT_WIDTH-1 downto 0);
signal adr_word      : unsigned(31 downto 0);
signal adr_byte      : unsigned(7 downto 0);
signal sr            : unsigned(7 downto 0);
signal clk_count     : unsigned(4 downto 0);
signal spi_ack       : std_logic;
signal reg_we        : std_logic;
signal reg_rw        : std_logic;
signal reg_chain     : std_logic;
signal reg_erasing   : std_logic;
signal reg_init_len  : unsigned(31 downto 0);
signal reg_new_len   : unsigned(31 downto 0);
signal idle_timer    : unsigned(IDLE_TIMER_WIDTH-1 downto 0);
signal idle_tb_pulse : std_logic;
signal idle_tb_ftw   : unsigned(IDLE_TB_ACC_BITS-1 downto 0);
signal idle_tb_hold  : std_logic;

  -- For the SPI state machine
type SPI_STATE_TYPE is (IDLE, SEND_CMD, SEND_ADR, SHIFT_ADR, SHIFT_BYTE,
                        GET_BYTE, GIVE_ACK);
signal spi_state     : SPI_STATE_TYPE;

  -- For the FLASH state machine
type FLASH_STATE_TYPE is (IDLE, R_WREN, R_CMD, R_ADR, R_DAT, R_WAIT,
                          R_STAT_1, R_STAT_2, INIT_CYCLE, INIT_CHAIN, INIT_RESTART);
signal fl_state      : FLASH_STATE_TYPE;
signal fl_ack        : std_logic;


-----------------------------------------------------------------------------
begin

  -- Register read mux
  with (adr_i) select
  dat_o <=
    to_unsigned(0,31) & reg_cs      when "0000",
    u_resize(reg_cmd,DAT_SIZE)      when "0001",
    reg_adr                         when "0010",
    reg_ispi_adr                    when "0011",
    u_resize(reg_init_len,DAT_SIZE) when "0100",
    to_unsigned(0,29) & reg_erasing & reg_chain & reg_rw when "0101",
    u_resize(sr,DAT_SIZE)           when others;

  -- Create acknowledge signals
  spi_ack  <= '1' when spi_state=GIVE_ACK else '0';
  ack_o    <= '1' when spi_ack='1' and sel_i='1' else '0';
  fl_ack_o <= fl_ack;

  -- Provide FLASH data output
  fl_dat_o <= sr;

  -- Provide initialization outputs
  init_adr_o <= reg_ispi_adr;
  init_cyc_o <= '1' when fl_state=INIT_CYCLE else '0';

  -- Create SPI signals
  spi_adr_o <= adr_word(adr_word'length-1 downto adr_word'length-DECODE_BITS);
  spi_cs_o  <= reg_cs when fl_state=IDLE else
               '0' when clk_count<=CLK_COUNT_1BYTE else
               '1';
  spi_so_o  <= sr(7);
  spi_sck_o <= clk_count(0) when clk_count<CLK_COUNT_1BYTE else '0';

  -- Select the correct address byte
  adr_word <= reg_adr when fl_state=IDLE else reg_ispi_adr;
--  with (to_integer(adr_count)) select
--  adr_byte <=
--    (others=>'0')      when 0,
--    adr_word(8*to_integer(adr_count)-1 downto 8*(to_integer(adr_count)-1)) when others;
  with (to_integer(adr_count)) select
  adr_byte <=
    (others=>'0')          when 0,
    adr_word(7 downto 0)   when 1,
    adr_word(15 downto 8)  when 2,
    adr_word(23 downto 16) when 3,
    adr_word(31 downto 24) when 4,
    (others=>'0')          when others;

  -- Create timebase for idle timer
  idle_tb_ftw  <= to_unsigned(integer(IDLE_TB_FREQ*(2**real(IDLE_TB_ACC_BITS))/SYS_CLK_RATE),idle_tb_ftw'length);
  idle_tb_hold <= '0' when (fl_state=IDLE or fl_state=R_WAIT or fl_state=INIT_CYCLE) else '1';
  timer_0 : dds_squarewave_phase_load
    generic map(
      ACC_BITS => IDLE_TB_ACC_BITS
    )
    port map(

      sys_rst_n   => sys_rst_n,
      sys_clk     => sys_clk,
      sys_clk_en  => sys_clk_en,

      -- Frequency setting
      freq_i      => idle_tb_ftw,

      -- Synchronous load
      phase_i     => to_unsigned(2**(IDLE_TB_ACC_BITS-1),IDLE_TB_ACC_BITS),
      phase_ld_i  => idle_tb_hold,

      -- Output
      pulse_o      => idle_tb_pulse,
      squarewave_o => open
    );

  -- Handle state machines and writes to registers
  reg_proc: process(sys_clk, sys_rst_n)
  begin
    if (sys_rst_n='0') then
      reg_cs    <= DEF_R_0(0);
      reg_cmd   <= DEF_R_1(reg_cmd'length-1 downto 0);
      reg_adr   <= DEF_R_2;
      reg_ispi_adr <= DEF_R_3;
      reg_rw       <= DEF_R_5(0);
      reg_chain    <= DEF_R_5(1);
      reg_init_len <= DEF_R_4(reg_init_len'length-1 downto 0);
      reg_new_len  <= (others=>'0');
      sr        <= (others=>'0');
      adr_count <= to_unsigned(1,adr_count'length);
      clk_count <= to_unsigned(CLK_COUNT_DESEL,clk_count'length);
      spi_state <= IDLE;
      fl_state  <= IDLE;
      fl_ack    <= '0';
      idle_timer  <= to_unsigned(FLASH_IDLE,idle_timer'length);
      init_dat_o  <= (others=>'0');
      reg_we    <= '0';
    elsif (sys_clk'event and sys_clk='1') then
      if (sys_clk_en='1') then
        -- Decrement the SPI clock counter
        if (clk_count>0) then
          clk_count <= clk_count-1;
          -- Handle the SPI shift register
          if (spi_state=GET_BYTE  and clk_count(0)='0' and clk_count<CLK_COUNT_1BYTE) or
             (spi_state/=GET_BYTE and clk_count(0)='1' and clk_count<CLK_COUNT_1BYTE) then
            sr <= sr(6 downto 0) & spi_si_i;
          end if;
        end if;
        -- Handle the FLASH idle timeout
        if (idle_timer>0 and idle_tb_pulse='1') then
          idle_timer <= idle_timer-1;
        end if;
        ----------------------------------
        -- Handle SPI state transitions --
        ----------------------------------
        case (spi_state) is

          when IDLE =>
            null;

          when SEND_CMD =>
            sr <= reg_cmd;
            clk_count <= to_unsigned(CLK_COUNT_1BYTE,clk_count'length);
            spi_state <= SHIFT_BYTE;

          -- adr_count must have already been set when going into this state,
          -- to ensure that sr is loaded with the correct bytes
          when SEND_ADR =>
            sr <= adr_byte;
            clk_count <= to_unsigned(CLK_COUNT_1BYTE,clk_count'length);
            spi_state <= SHIFT_ADR;

          when SHIFT_ADR =>
            if (clk_count=0) then
              if (adr_count=1) then
                spi_state <= GIVE_ACK;
              else
                adr_count <= adr_count-1;
                spi_state <= SEND_ADR;
              end if;
            end if;

          when SHIFT_BYTE =>
            if (clk_count=0) then
              spi_state <= GIVE_ACK;
            end if;

          when GET_BYTE =>
            if (clk_count=0) then
              spi_state <= GIVE_ACK;
            end if;

          when GIVE_ACK =>
            spi_state <= IDLE;

          --when others => 
          --  spi_state <= IDLE;
        end case;

        ------------------------------------
        -- Handle FLASH state transitions --
        ------------------------------------
        -- Default Values
        fl_ack  <= '0';
        case (fl_state) is

          when IDLE =>
            if (reg_rw='1' and spi_state=IDLE) then
              if (fl_sel_i='1') then
                -- Store local copy of requested address
                -- All subsequenct accesses within the SPI command session will be sequential
                -- The external address does not guarantee this, but the internal
                -- one does.
                reg_ispi_adr <= fl_adr_i;
                -- Store write/read indication
                reg_we       <= fl_we_i;
                idle_timer <= to_unsigned(FLASH_IDLE,idle_timer'length);
                if (fl_we_i='1') then
                  reg_cmd   <= to_unsigned(SPI_CMD_PP,reg_cmd'length);
                  fl_state  <= R_WREN;
                  sr <= to_unsigned(SPI_CMD_WREN,sr'length);
                  clk_count <= to_unsigned(CLK_COUNT_1BYTE,clk_count'length);
                  spi_state <= SHIFT_BYTE;
                else
                  reg_cmd   <= to_unsigned(SPI_CMD_READ,reg_cmd'length);
                  fl_state  <= R_CMD;
                  sr <= to_unsigned(SPI_CMD_READ,sr'length);
                  clk_count <= to_unsigned(CLK_COUNT_1BYTE,clk_count'length);
                  spi_state <= SHIFT_BYTE;
                end if;
              end if;
            end if;
            -- If there is initialization to do, get it done.
            -- This has priority over other operations.
            if (reg_init_len>0) then
              reg_cmd   <= to_unsigned(SPI_CMD_READ,reg_cmd'length);
              fl_state  <= R_CMD;
              sr <= to_unsigned(SPI_CMD_READ,sr'length);
              clk_count <= to_unsigned(CLK_COUNT_1BYTE,clk_count'length);
              spi_state <= SHIFT_BYTE;
            end if;

          when R_WREN =>
            if (spi_ack='1') then
              sr <= reg_cmd;
              -- Deselect SPI device to execute SPI command
              clk_count <= to_unsigned(CLK_COUNT_DESEL,clk_count'length);
              spi_state <= SHIFT_BYTE;
              fl_state  <= R_CMD;
            end if;

          when R_CMD =>
            if (spi_ack='1') then
              adr_count <= to_unsigned(SPI_ADR_BYTES,adr_count'length);
              spi_state <= SEND_ADR;
              fl_state  <= R_ADR;
            end if;

          when R_ADR =>
            if (spi_ack='1') then
              if (reg_cmd=SPI_CMD_SE) then
                sr <= to_unsigned(SPI_CMD_RDSR,sr'length);
                -- Deselect SPI device to execute SPI command
                clk_count <= to_unsigned(CLK_COUNT_DESEL,clk_count'length);
                spi_state <= SHIFT_BYTE;
                fl_state  <= R_STAT_1;
              else
                clk_count <= to_unsigned(CLK_COUNT_1BYTE,clk_count'length);
                spi_state <= SHIFT_BYTE;
                fl_state  <= R_DAT;
                sr        <= fl_dat_i; -- Needed for writes, and does not affect reads.
              end if;
            end if;

          when R_DAT =>
            if (reg_init_len>0) then
              -- Handle init case
              if (spi_ack='1') then
                if (reg_chain='1' and reg_init_len<=8) then
                  fl_state <= INIT_CHAIN;
                else
                  init_dat_o <= sr;
                  idle_timer <= to_unsigned(FLASH_IDLE,idle_timer'length);
                  fl_state <= INIT_CYCLE;
                end if;
              end if;
            else
            -- Handle memory mapped I/O case
              -- Await timeout, in case current cycle is not de-asserted in time.
              if (idle_timer=0) then
                if (reg_cmd=SPI_CMD_READ) then
                  fl_state <= IDLE;
                else
                  -- Deselect SPI device to execute SPI command
                  clk_count <= to_unsigned(CLK_COUNT_DESEL,clk_count'length);
                  idle_timer <= to_unsigned(FLASH_IDLE,idle_timer'length);
                  sr <= to_unsigned(SPI_CMD_RDSR,sr'length);
                  spi_state <= SHIFT_BYTE;
                  fl_state <= R_STAT_1;
                end if;
              end if;
              -- Acknowledge the memory mapped cycle
              if (spi_ack='1') then
                fl_ack <= '1';
              end if;
              -- Handle de-assertion of current cycle
              if (fl_sel_i='0') then
                idle_timer <= to_unsigned(FLASH_IDLE,idle_timer'length);
                fl_state <= R_WAIT;
              end if;
            end if;

          -- This is a "waiting state" to see if the current SPI session is
          -- going to continue.  It continues if another write is requested.
          -- within the allowed timeout window.
          when R_WAIT =>
            -- On timeout, terminate the SPI PP command.
            if (idle_timer=0) then
              if (reg_cmd=SPI_CMD_READ) then
                fl_state <= IDLE;
              else
                -- Deselect SPI device to execute SPI command
                clk_count <= to_unsigned(CLK_COUNT_DESEL,clk_count'length);
                idle_timer <= to_unsigned(FLASH_IDLE,idle_timer'length);
                sr <= to_unsigned(SPI_CMD_RDSR,sr'length);
                spi_state <= SHIFT_BYTE;
                fl_state <= R_STAT_1;
              end if;
            end if;
            -- If another similar cycle is requested, continue
            if (fl_sel_i='1' and fl_we_i=reg_we) then
              idle_timer <= to_unsigned(FLASH_IDLE,idle_timer'length);
              sr <= fl_dat_i;
              clk_count <= to_unsigned(CLK_COUNT_1BYTE,clk_count'length);
              spi_state <= SHIFT_BYTE;
              fl_state <= R_DAT;
            end if;
            -- If a different cycle is requested, terminate the SPI command
            if (fl_sel_i='1' and fl_we_i/=reg_we) then
              if (reg_cmd=SPI_CMD_READ) then
                fl_state <= IDLE;
              else
                -- Deselect SPI device to execute SPI command
                clk_count <= to_unsigned(CLK_COUNT_DESEL,clk_count'length);
                idle_timer <= to_unsigned(FLASH_IDLE,idle_timer'length);
                sr <= to_unsigned(SPI_CMD_RDSR,sr'length);
                spi_state <= SHIFT_BYTE;
                fl_state <= R_STAT_1;
              end if;
            end if;

          -- Timeout is disabled for sector erase.
          -- The erase register bit can be cleared to reset the state machine.
          -- (It can take a veeeerrrryy long time to erase a sector...)
          -- (Like up to a second!)
          when R_STAT_1 =>
            if (spi_ack='1') then
              clk_count <= to_unsigned(CLK_COUNT_1BYTE,clk_count'length);
              spi_state <= SHIFT_BYTE;
              fl_state <= R_STAT_2;
            end if;

          when R_STAT_2 =>
            if (idle_timer=0 and reg_cmd/=SPI_CMD_SE) then
              fl_state <= IDLE;
            elsif (spi_ack='1') then
              if (sr(0)='1') then -- If WIP is set, keep checking status.
                clk_count <= to_unsigned(CLK_COUNT_1BYTE,clk_count'length);
                spi_state <= SHIFT_BYTE;
              else
                fl_state <= IDLE;
              end if;
            end if;

          -- This state creates an init cycle
          when INIT_CYCLE =>
            -- Await timeout, in case current cycle is not acknowledged in time.
            if (idle_timer=0) then
              fl_state <= IDLE;
            end if;
            -- Await acknowledge of current cycle
            if (init_ack_i='1') then
              reg_ispi_adr <= reg_ispi_adr+1;
              reg_init_len <= reg_init_len-1;
              if (reg_init_len=1) then
                fl_state <= IDLE;
              else
                idle_timer <= to_unsigned(FLASH_IDLE,idle_timer'length);
                clk_count  <= to_unsigned(CLK_COUNT_1BYTE,clk_count'length);
                spi_state  <= SHIFT_BYTE;
                fl_state   <= R_DAT;
              end if;
            end if;

          when INIT_CHAIN =>
            if (reg_init_len>4) then
              reg_ispi_adr(7 downto 0) <= sr;
              reg_ispi_adr(31 downto 8) <= reg_ispi_adr(23 downto 0);
            else
              reg_new_len(7 downto 0) <= sr;
              reg_new_len(31 downto 8) <= reg_new_len(23 downto 0);
            end if;
            reg_init_len <= reg_init_len-1;
            if (reg_init_len=1) then
              fl_state <= INIT_RESTART;
            else
              idle_timer <= to_unsigned(FLASH_IDLE,idle_timer'length);
              clk_count  <= to_unsigned(CLK_COUNT_1BYTE,clk_count'length);
              spi_state  <= SHIFT_BYTE;
              fl_state   <= R_DAT;
            end if;

          when INIT_RESTART =>
            if (reg_new_len>0) then
              reg_init_len <= reg_new_len;
              -- Deselect SPI device to execute SPI command
              clk_count <= to_unsigned(CLK_COUNT_DESEL,clk_count'length);
              idle_timer <= to_unsigned(FLASH_IDLE,idle_timer'length);
              sr <= to_unsigned(SPI_CMD_RDSR,sr'length);
              spi_state <= SHIFT_BYTE;
              fl_state <= R_STAT_1;
            else
              fl_state <= IDLE;
            end if;

          when others => 
            spi_state <= IDLE;
        end case;

        -- Handle bus writes to registers
        if (spi_state=IDLE and fl_state=IDLE and sel_i='1' and we_i='1') then
          case (adr_i) is
            when "0000" =>
              reg_cs <= dat_i(0);
              spi_state <= GIVE_ACK;
            when "0001" =>
              reg_cmd <= dat_i(reg_cmd'length-1 downto 0);
              spi_state <= SEND_CMD;
            when "0010" =>
              reg_adr <= dat_i;
              adr_count <= to_unsigned(SPI_ADR_BYTES,adr_count'length);
              spi_state <= SEND_ADR;
            when "0011" =>
              reg_ispi_adr <= dat_i(reg_ispi_adr'length-1 downto 0);
              spi_state <= GIVE_ACK; -- A quick acknowledgment
            when "0100" =>
              reg_init_len <= dat_i(reg_init_len'length-1 downto 0);
              spi_state <= GIVE_ACK; -- A quick acknowledgment
            when "0101" =>
              reg_rw    <= dat_i(0);
              reg_chain <= dat_i(1);
              if (dat_i(2)='1') then
                if (reg_erasing='0') then
                  reg_cmd   <= to_unsigned(SPI_CMD_SE,reg_cmd'length);
                  fl_state  <= R_WREN;
                  sr <= to_unsigned(SPI_CMD_WREN,sr'length);
                  clk_count <= to_unsigned(CLK_COUNT_1BYTE,clk_count'length);
                  spi_state <= SHIFT_BYTE;
                end if;
              else
                spi_state <= GIVE_ACK; -- A quick acknowledgment
              end if;
              if (dat_i(3)='1') then
                spi_state <= IDLE;
                fl_state  <= IDLE;
                reg_init_len <= (others=>'0');
              end if;
            when others =>
              sr <= dat_i(sr'length-1 downto 0);
              clk_count <= to_unsigned(CLK_COUNT_1BYTE,clk_count'length);
              spi_state <= SHIFT_BYTE;
          end case;
        end if;
        -- Handle SPI read cycle
        if (spi_state=IDLE and fl_state=IDLE and sel_i='1' and we_i='0') then
          case (adr_i) is
            when "0000" =>
              spi_state <= GIVE_ACK;
            when "0001" =>
              spi_state <= GIVE_ACK;
            when "0010" =>
              spi_state <= GIVE_ACK;
            when "0011" =>
              spi_state <= GIVE_ACK;
            when "0100" =>
              spi_state <= GIVE_ACK;
            when "0101" =>
              spi_state <= GIVE_ACK;
            when others =>
              clk_count <= to_unsigned(CLK_COUNT_1BYTE,clk_count'length);
              spi_state <= GET_BYTE;
          end case;
        end if;

      end if; -- sys_clk_en
    end if; -- sys_clk
  end process;

  -- Create signal that is high during sector erase activity
  reg_erasing <= '1' when (fl_state/=IDLE and reg_cmd=SPI_CMD_SE) else '0';

  -- Create signal that is high whenever initialization is not active.
  init_fin_o <= '1' when reg_init_len=0 else '0';

end beh;

-------------------------------------------------------------------------------
-- SPI Flash Simulator
-------------------------------------------------------------------------------
--
-- Author: John Clayton
-- Date  : Aug.  7, 2013 Created this module starting with code copied from
--                       another module.
--         Aug. 10, 2013 Added and simulated page programming and sector erase
--                       with concurrent status register reads.  Only the
--                       WIP bit is implemented within the status register.
--
-- Description
-------------------------------------------------------------------------------
-- This module is a very simplistic SPI FLASH simulator.  It was created with
-- the intent of running a simulation, so that real data can be returned from
-- this module to a device which is accessing a SPI FLASH device.
--
-- Because of its simple intent, this module does not implement all the
-- functions of a typical SPI FLASH, but it does do reading and writing.
-- It implements the "write enable latch" instruction, and it can be erased
-- too.
--
-- The kind of device being simulated has 24 address bits, although the size
-- of the simulated FLASH memory is much smaller.  It will simply wrap around
-- to the beginning of the array if the end is passed.
--
-- Because the unit is for simulation only, a separate clock domain is created
-- for the spi_sclk_i input
--
-- The sys_rst_n input is an asynchronous reset.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;

library work;
use work.dds_pack.all;
use work.convert_pack.all;
use work.block_ram_pack.all;

  entity spi_flash_simulator is
    generic(
      SYS_CLK_RATE   : real    := 50000000.0;
      FLASH_ADR_BITS : natural := 8; -- Flash memory size is based on this
      FLASH_INIT     : string  := ".\flash_sim_init.txt"     -- Default RX packet digestion settings
    );
    port (
      -- System Clock and Clock Enable
      sys_rst_n  : in  std_logic;
      sys_clk    : in  std_logic;
      sys_clk_en : in  std_logic;

      -- SPI interface
      -- "hold" and "WP" are not implemented.
      spi_cs_i   : in  std_logic;
      spi_sck_i  : in  std_logic;
      spi_si_i   : in  std_logic;
      spi_so_o   : out std_logic

    );
  end spi_flash_simulator;

architecture beh of spi_flash_simulator is

-- Constants
constant SPI_CMD_NOP      : natural := 16#00#;
constant SPI_CMD_PP       : natural := 16#02#;
constant SPI_CMD_READ     : natural := 16#03#;
constant SPI_CMD_RDSR     : natural := 16#05#;
constant SPI_CMD_WREN     : natural := 16#06#;
constant SPI_CMD_SE       : natural := 16#D8#;

constant WIP_PP_TIMEOUT   : natural := 12; -- 1.2 milliseconds
--constant WIP_SE_TIMEOUT   : natural := 12000; -- 1.2 seconds (realistic number)
constant WIP_SE_TIMEOUT   : natural := 24; -- 2.4 milliseconds (for faster simulation)
constant WIP_TB_FREQ      : real    := 10000.0; -- Timebase is 100 microsecond resolution
constant WIP_TB_ACC_BITS  : natural := 24;
constant WIP_TIMER_WIDTH  : natural := timer_width(WIP_SE_TIMEOUT);
constant SECTOR_BITS      : natural := 16; -- Determines # of bytes to erase

-- Internal signal declarations
signal reg_cmd   : unsigned(7 downto 0);
signal reg_adr   : unsigned(23 downto 0);
signal flash_adr : unsigned(FLASH_ADR_BITS-1 downto 0);
signal array_adr : unsigned(FLASH_ADR_BITS-1 downto 0);
signal flash_we  : std_logic;
signal flash_dat : unsigned(7 downto 0);
signal sr        : unsigned(7 downto 0);
signal sr_full   : std_logic;
signal reg_wel   : std_logic; -- Write Enable Latch bit
signal reg_wip   : std_logic; -- Write In Progress bit
signal clk_count    : unsigned(2 downto 0);
signal clk_count_r1 : unsigned(2 downto 0);
signal clk_count_r2 : unsigned(2 downto 0);
signal wip_timer    : unsigned(WIP_TIMER_WIDTH-1 downto 0);
signal wip_tb_pulse : std_logic;
signal wip_tb_ftw   : unsigned(WIP_TB_ACC_BITS-1 downto 0);
signal wip_tb_hold  : std_logic;
signal sector_adr   : unsigned(SECTOR_BITS-1 downto 0);
signal sector_erase : std_logic;
signal erase_adr    : unsigned(23 downto 0);
signal array_dat_wr : unsigned(7 downto 0);

  -- For the state machine
type FSM_STATE_TYPE is (AWAIT_CMD, AWAIT_ADR_2, AWAIT_ADR_1, AWAIT_ADR_0,
                        AWAIT_CS_HI, STORE_BYTE);
signal fsm_state      : FSM_STATE_TYPE;


-----------------------------------------------------------------------------
begin

  -- Create SPI signals
  spi_so_o  <= sr(7);

  -- The shift register process
  -- Nothing is ever synchronously cleared, loaded or reset here.
  -- The shift register and counter simply "roll over" in a cyclical
  -- way, forever after the asynchronous reset.
  sr_proc: process(spi_sck_i, sys_rst_n)
  begin
    if (sys_rst_n='0') then
      sr <= (others=>'0');
      clk_count <= (others=>'0');
    elsif (spi_sck_i'event and spi_sck_i='1') then
      if (spi_cs_i='0') then
        sr <= sr(6 downto 0) & spi_si_i;
        clk_count <= clk_count+1;
        -- Here assign the shift register
        -- Action depends on command type
        case (to_integer(reg_cmd)) is
          when SPI_CMD_READ =>
            if (fsm_state=AWAIT_CS_HI and clk_count=0) then
              sr <= flash_dat;
            end if;
          when SPI_CMD_PP =>
            null;
          when SPI_CMD_SE =>
            null;
          when SPI_CMD_RDSR =>
            if (fsm_state=AWAIT_CS_HI and clk_count=0) then
              sr <= "0000000" & reg_wip;
            end if;
          when others =>
            null;
        end case;
      else
        clk_count <= (others=>'0');
      end if;
    end if; -- spi_sck_i
  end process;

  -- Create timebase for WIP timer
  wip_tb_ftw  <= to_unsigned(integer(WIP_TB_FREQ*(2**real(WIP_TB_ACC_BITS))/SYS_CLK_RATE),wip_tb_ftw'length);
  wip_tb_hold <= '0' when reg_wip='1' else '1';
  timer_0 : dds_squarewave_phase_load
    generic map(
      ACC_BITS => WIP_TB_ACC_BITS
    )
    port map(

      sys_rst_n   => sys_rst_n,
      sys_clk     => sys_clk,
      sys_clk_en  => sys_clk_en,

      -- Frequency setting
      freq_i      => wip_tb_ftw,

      -- Synchronous load
      phase_i     => to_unsigned(2**(WIP_TB_ACC_BITS-1),WIP_TB_ACC_BITS),
      phase_ld_i  => wip_tb_hold,

      -- Output
      pulse_o      => wip_tb_pulse,
      squarewave_o => open
    );
  reg_wip <= '1' when (wip_timer>0) else '0';

  -- Create signal which indicates when the shift register is done shifting a byte
  sr_full <= '1' when (clk_count_r1=0 and clk_count_r2=7) else '0';
  -- Since the simulated FLASH memory array may be much smaller than the address,
  -- select the salient part for use in addressing the array.
  flash_adr <= u_resize(reg_adr,flash_adr'length);

  -- The main process
  main_proc: process(sys_clk, sys_rst_n)
  begin
    if (sys_rst_n='0') then
      reg_cmd   <= to_unsigned(SPI_CMD_NOP,reg_cmd'length);
      reg_adr   <= (others=>'0');
      reg_wel   <= '0';
      fsm_state <= AWAIT_CMD;
      wip_timer <= to_unsigned(0,wip_timer'length);
      clk_count_r1 <= (others=>'0');
      clk_count_r2 <= (others=>'0');
      sector_adr   <= (others=>'0');
      sector_erase <= '0';
    elsif (sys_clk'event and sys_clk='1') then
      if (sys_clk_en='1') then
        -- default values

        -- Synchronize and capture the clk_count value, in order to
        -- detect changes to it.
        clk_count_r1 <= clk_count;
        clk_count_r2 <= clk_count_r1;

        -- Handle WIP timer count down
        if (wip_tb_pulse='1' and wip_timer>0) then
          wip_timer <= wip_timer-1;
        end if;

        -- Handle actual sector erase array storage operations
        if (sector_erase='1') then
          sector_adr <= sector_adr+1;
          if (sector_adr=(2**sector_adr'length)-1) then
            sector_erase <= '0';
          end if;
        end if;

        -- Handle state transitions
        case (fsm_state) is

          when AWAIT_CMD =>
            if (sr_full='1' and spi_cs_i='0') then
              if (reg_wip='0') then
                reg_cmd <= sr;
                if (sr=SPI_CMD_WREN) then
                  reg_wel   <= '1';
                  fsm_state <= AWAIT_CS_HI;
                else
                  fsm_state <= AWAIT_ADR_2;
                end if;
              else
                fsm_state <= AWAIT_CS_HI;
                -- Only RDSR is allowed when there is a write in progress (WIP)
                if (sr=SPI_CMD_RDSR) then
                  reg_cmd <= sr;
                else
                  reg_cmd <= to_unsigned(SPI_CMD_NOP,reg_cmd'length);
                end if;
              end if;
            end if;

          when AWAIT_ADR_2 =>
            if (sr_full='1') then
              reg_adr(23 downto 16) <= sr;
              fsm_state <= AWAIT_ADR_1;
            end if;

          when AWAIT_ADR_1 =>
            if (sr_full='1') then
              reg_adr(15 downto 8) <= sr;
              fsm_state <= AWAIT_ADR_0;
            end if;

          when AWAIT_ADR_0 =>
            if (sr_full='1') then
              reg_adr(7 downto 0) <= sr;
              fsm_state <= AWAIT_CS_HI;
            end if;

          when AWAIT_CS_HI =>
            if (sr_full='1') then
              -- Action depends on command type
              case (to_integer(reg_cmd)) is
                when SPI_CMD_READ =>
                  reg_adr <= reg_adr+1;
                when SPI_CMD_PP =>
                  if (reg_wel='1') then
                    fsm_state <= STORE_BYTE;
                  end if;
                when SPI_CMD_SE =>
                  null;
                when SPI_CMD_RDSR =>
                  null;
                when others =>
                  null;
              end case;
            end if;
            if (spi_cs_i='1') then
              fsm_state <= AWAIT_CMD;
              if (reg_cmd/=SPI_CMD_WREN) then
                reg_wel <= '0';
              end if;
              if (reg_cmd=SPI_CMD_PP) then
                wip_timer <= to_unsigned(WIP_PP_TIMEOUT,wip_timer'length);
              end if;
              if (reg_cmd=SPI_CMD_SE) then
                wip_timer <= to_unsigned(WIP_SE_TIMEOUT,wip_timer'length);
                sector_erase <= '1';
              end if;
            end if;

          -- Being in this state asserts the flash_we signal
          when STORE_BYTE =>
            reg_adr <= reg_adr+1;
            fsm_state <= AWAIT_CS_HI;

          --when others => 
          --  fsm_state <= IDLE;
        end case;

      end if; -- sys_clk_en
    end if; -- sys_clk
  end process;

  -- This BRAM contains the simulated FLASH contents
  flash_ram : block_ram_dp_writethrough_hexfile_init
    generic map(
      init_file  => FLASH_INIT,
      fil_width  => 8,
      adr_width  => FLASH_ADR_BITS,
      dat_width  => 8
    )
    port map (
       clk_a    => sys_clk,
       clk_b    => sys_clk,

       adr_a_i  => array_adr,
       adr_b_i  => to_unsigned(0,FLASH_ADR_BITS),

       we_a_i   => flash_we,
       en_a_i   => '1',
       dat_a_i  => array_dat_wr,
       dat_a_o  => flash_dat,

       we_b_i   => '0',
       en_b_i   => '0',
       dat_b_i  => to_unsigned(0,8),
       dat_b_o  => open
    );
  flash_we <= '1' when (fsm_state=STORE_BYTE or sector_erase='1') else '0';
  array_adr <= flash_adr when sector_erase='0' else u_resize(erase_adr,array_adr'length);
  erase_adr <= reg_adr(reg_adr'length-1 downto SECTOR_BITS) & sector_adr;
  array_dat_wr <= sr when sector_erase='0' else str2u("FF",8);

end beh;

