--------------------------------------------------------------------------
-- Package of auto_baud components
--
-- Contains the following components:
--
--   auto_baud_with_tracking
--   auto_baud_with_tracking_slv
--
-- the version with the suffix _slv attached to the name provides
-- IO busses of the "std_logic_vector" type instead of "unsigned."
-- In all other ways, these components are identical.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

package auto_baud_pack is

  component auto_baud_with_tracking
    generic (
      CLOCK_FACTOR    : natural; -- Output is this factor times the baud rate
      FPGA_CLKRATE    : integer; -- FPGA system clock rate
      MIN_BAUDRATE    : integer; -- Minimum expected incoming Baud rate
      DELTA_THRESHOLD : integer  -- Max. number of sys_clks difference allowed between
                                 -- "half_measurement" and "measurement"
    );
    port ( 
       
      sys_rst_n    : in  std_logic;
      sys_clk      : in  std_logic;

      -- rate and parity
      rx_parity_i  : in  unsigned(1 downto 0); -- 0=none, 1=even, 2=odd

      -- serial input
      rx_stream_i  : in  std_logic;

      -- Output
      baud_lock_o  : out std_logic;
      baud_clk_o   : out std_logic
    );
  end component;

  component auto_baud_with_tracking_slv
    generic (
      CLOCK_FACTOR    : natural; -- Output is this factor times the baud rate
      FPGA_CLKRATE    : integer; -- FPGA system clock rate
      MIN_BAUDRATE    : integer; -- Minimum expected incoming Baud rate
      DELTA_THRESHOLD : integer  -- Max. number of sys_clks difference allowed between
                                 -- "half_measurement" and "measurement"
    );
    port ( 
       
      sys_rst_n    : in  std_logic;
      sys_clk      : in  std_logic;

      -- rate and parity
      rx_parity_i  : in  std_logic_vector(1 downto 0); -- 0=none, 1=even, 2=odd

      -- serial input
      rx_stream_i  : in  std_logic;

      -- Output
      baud_lock_o  : out std_logic;
      baud_clk_o   : out std_logic
    );
  end component;

end auto_baud_pack;

package body auto_baud_pack is
end auto_baud_pack;

-------------------------------------------------------------------------------
-- Auto Baud with tracking core
-------------------------------------------------------------------------------
--
-- Author: John Clayton
-- Date  : Aug. 20, 2002 Began project
-- Update: Sep.  5, 2002 copied this file from "autobaud.v"
--                       Added tracking functions, and debugged them.
-- Update: Sep. 13, 2002 Added test data.  Module complete, it works well.
-- Update: Nov. 20, 2009 Began translation into VHDL
--
-- Description
-------------------------------------------------------------------------------
-- This is a state-machine driven core that measures transition intervals
-- in a particular character arriving via rs232 transmission (i.e. PC serial 
-- port.)  Measurements of time intervals between transitions in the received
-- character are then used to generate a baud rate clock for use in serial
-- communications back and forth with the device that originally transmitted
-- the measured character.  The clock which is generated is in reality a
-- clock enable pulse, one single clock wide, occurring at a rate suitable
-- for use in serial communications.  (This means that it will be generated
-- at 4x or 8x or 16x the actual measured baud rate of the received character.
-- The multiplication factor is called "CLOCK_FACTOR" and is a settable
-- parameter within this module.  The parameter "CLOCK_FACTOR" need not
-- be a power of two, but it should be a number between 2 and 16 inclusive.)
--
-- The particular character which is targeted for measurement and verification
-- in this module is: carriage return (CR) = 0x0d = 13.
-- This particular character was chosen because it is frequently used at the
-- end of a command line, as entered at a keyboard by a human user interacting
-- with a command interpreter.  It is anticipated that the user would press
-- the "enter" key once upon initializing communications with the electronic
-- device, and the resulting carriage return character would be used for 
-- determining BAUD rate, thus allowing the device to respond at the correct
-- rate, and to carry on further communications.  The electronic device using
-- this "auto_baud" module adjusts its baud rate to match the baud rate of
-- the received data.  This works for all baud rates, within certain limits,
-- and for all system clock rates, within certain limits.
--
-- Received serially, and with no parity bit, the carriage return appears as
-- the following waveform:
-- ________    __    ____          _______________
--         |__|d0|__|d2d3|________|stop
--        start   d1      d4d5d6d7
--
-- The waveform is shown with an identical "high" time and "low" time for
-- each bit.  However, actual measurements taken using a logic analyzer
-- on characters received from a PC show that the times are not equal.
-- The "high" times turned out shorter, and the "low" times longer...
-- Therefore, this module attempts to average out this discrepancy by
-- measuring one low time and one high time.
--
-- Since the transition measurements must unavoidably contain small amounts
-- of error, the measurements are made during the beginning 2 bits of
-- the received character, (that is, start bit and data bit zero).
-- Then the measurement is immediately transformed into a baud rate clock,
-- used to verify correct reception of the remaining 8 bits of the character.
-- If the entire character is not received correctly using the generated
-- baud rate, then the measurement is scrapped, and the unit goes into an
-- idle scanning mode waiting for another character to test.
--
-- This effectively filters out characters that the unit is not interested in
-- receiving (anything that is not a carriage return.)  There is a slight
-- possibility that a group of other characters could appear by random
-- chance in a configuration that resembles a carriage return closely enough
-- that the unit might accept the measurement and produce a baud clock too
-- low.  But the probability of this happening is remote enough that the
-- unit is considered highly "robust" in normal use, especially when used
-- for command entry by humans.  It would take a very clever user indeed, to
-- enter the correct series of characters with the correct intercharacter
-- timing needed to possibly "fool" the unit!
--
-- (Also, the baud rate produced falls within certain limits imposed by
--  the hardware of the unit, which prevents the auto_baud unit from mistaking
--  a series of short glitches on the serial data line for a really
--  fast CR character.)
--
-- This method of operation implies that each carriage return character
-- received will produce a correctly generated baud rate clock.  Therefore,
-- each and every carriage return actually causes a new baud rate clock to
-- be produced.  However, updates occur smoothly, and there should be no
-- apparent effect as an old BAUD clock is stopped and a new one started.
-- The transition is done smoothly.
--
-- For users who desire a single measurement at the beginning of a session
-- to produce a steady baud clock during the entire session, there is a
-- slightly smaller module called "auto_baud.v" which performs a single
-- measurement, but which requires a reset pulse in order to begin measuring
-- for a new BAUD rate.
--
-- NOTES:
-- - This module uses a counter to divide down the sys_clk signal to produce the
--   baud_clk_o signal.  Since the frequency of baud_clk_o is nominally
--   CLOCK_FACTOR * rx_baud_rate, where "rx_baud_rate" is the baud rate
--   of the received character, then the higher you make CLOCK_FACTOR, the
--   higher the generated baud_clk_o signal frequency, and hence the lower the
--   resolution of the divider.  Therefore, using a lower value for the
--   CLOCK_FACTOR will allow you to use a lower sys_clk with this module.
-- - The lower the minimum baud rate setting, the larger the counters will be.
--   This is so that the counters can accomodate the large count values needed
--   to divide the system clock into the low Baud rate output.
--
-- - If the percentage error for your highest desired baud rate is greater
--   than a few percent, you might want to use a higher Fsys_clk or else a 
--   lower CLOCK_FACTOR.
--
-- Note: Simply changing the template bits does not reconfigure the
--       module to look for a different character (because a new measurement
--       window might have to be defined for a different character...)
--       The template bits are the exact bits used during verify, against
--       which the incoming character is checked.
--       The LSB of the character is not used for verification, since it is
--       actually used in the measurement.
--


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;

entity auto_baud_with_tracking is
    generic (
      CLOCK_FACTOR    : natural := 16;        -- Output is this factor times the baud rate
      FPGA_CLKRATE    : integer := 25000000;  -- FPGA system clock rate
      MIN_BAUDRATE    : integer := 57600;     -- Minimum expected incoming Baud rate
      DELTA_THRESHOLD : integer := 6          -- Max. number of sys_clks difference allowed between
                                              -- "half_measurement" and "measurement"
    );
    port ( 
       
      sys_rst_n    : in  std_logic;
      sys_clk      : in  std_logic;

      -- rate and parity
      rx_parity_i  : in  unsigned(1 downto 0); -- 0=none, 1=even, 2=odd

      -- serial input
      rx_stream_i  : in  std_logic;

      -- Output
      baud_lock_o  : out std_logic;
      baud_clk_o   : out std_logic
    );
end auto_baud_with_tracking;

architecture beh of auto_baud_with_tracking is

-- Constants
constant TEMPLATE_BITS    : unsigned(7 downto 0) := "00001101";  -- Carriage return
constant MAIN_COUNT_WIDTH : integer := integer(ceil(log2(real(FPGA_CLKRATE)/real(MIN_BAUDRATE))));  -- Bit Width of timer.

-- Internal signal declarations
  -- State Machine
type FSM_STATE_TYPE is (IDLE, MEASURE_START_BIT, MEASURE_DATA_BIT, VERIFY);
signal fsm_state        : FSM_STATE_TYPE;

signal baud_lock        : std_logic; -- When high, indicates output can operate.
signal char_mismatch    : std_logic; -- Indicates character did not verify
signal baud_count       : unsigned(MAIN_COUNT_WIDTH-1 downto 0); -- BAUD counter register
signal baud_div         : unsigned(MAIN_COUNT_WIDTH-1 downto 0); -- measurement for running
signal measurement      : unsigned(MAIN_COUNT_WIDTH-1 downto 0); -- measurement for verify
signal half_check       : unsigned(MAIN_COUNT_WIDTH-1 downto 0); -- Half of measurement
signal half_measurement : unsigned(MAIN_COUNT_WIDTH-1 downto 0); -- measurement at end of start bit
signal delta            : unsigned(MAIN_COUNT_WIDTH-1 downto 0); -- Difference value
signal target_bits      : unsigned(8 downto 0); -- Character bits to compare
signal target_bit_count : unsigned(3 downto 0); -- Contains count of bits remaining to check
signal parity           : std_logic; -- The "template bit" for checking the received parity bit.

----------------------------------------------------------------------------
-- Functions
----------------------------------------------------------------------------
  function gen_even_parity(in_a : unsigned) return std_logic is
  variable i : natural;
  variable o : std_logic;

  begin
  
  o := '0'; -- Default value
  for i in 0 to in_a'length-1 loop
    o := o xor in_a(i);
  end loop;
  
  return(o);
  
  end;

-----------------------------------------------------------------------------
begin

parity <= '1' when (rx_parity_i="00") else
          gen_even_parity(TEMPLATE_BITS) when (rx_parity_i="01") else
          not gen_even_parity(TEMPLATE_BITS) when (rx_parity_i="10") else
          '1';
-- Form a difference between the measurement and twice the "half-measurement"
-- Take the absolute value.
half_check <= '0' & measurement(MAIN_COUNT_WIDTH-1 downto 1);
delta <= (half_check-half_measurement) when (half_check>half_measurement) else
         (half_measurement-half_check);

-- This is state machine.  It checks the status of the rx_stream_i line
-- and coordinates the measurement of the time interval of the first two
-- bits of the received character, which is the "measurement interval."
-- Following the measurement interval, the state machine enters a new
-- phase of bit verification.  If the measured time interval is accurate
-- enough to measure the remaining 8 or 9 bits of the character correctly, then
-- the measurement is accepted, and the baud rate clock is driven onto
-- the baud_clk_o output pin.  Incidentally, the process of verification
-- effectively filters out characters which are not the desired target
-- character for measurement.  In this case, the target character is the
-- carriage return.

fsm_proc: process(sys_clk, sys_rst_n, parity)
begin
  if (sys_rst_n='0') then
    fsm_state        <= IDLE;   -- asynchronous reset
    baud_clk_o       <= '0';
    baud_lock        <= '0';
    char_mismatch    <= '0';
    baud_count       <= (others=>'0');
    half_measurement <= (others=>'0'); -- The measurement at the end of the start bit
    measurement      <= (others=>'0'); -- The candidate divider value.
    baud_div         <= (others=>'0'); -- The "running" copy of measurement
    target_bits      <= '1' & parity & TEMPLATE_BITS(7 downto 1);
    target_bit_count <= (others=>'0');
  elsif (sys_clk'event and sys_clk='1') then

    -- Handle the baud clock output generation, if we have achieved "baud_lock"
    if (baud_lock='1') then
      if (baud_count + 2*CLOCK_FACTOR > baud_div) then
        baud_count <= to_unsigned(CLOCK_FACTOR,baud_count'length); 
--        baud_count <= baud_count + to_unsigned(CLOCK_FACTOR,baud_count'length) - baud_div; 
          -- (Compromised above for simplicity)
          -- (It could have been baud_count+CLOCK_FACTOR-baud_div)
        baud_clk_o <= '1';
      else
        baud_count   <= baud_count + 2*CLOCK_FACTOR;
        baud_clk_o   <= '0';
      end if;
    end if;

    case (fsm_state) is

      when IDLE =>
        char_mismatch    <= '0';
        measurement      <= (others=>'0');
        half_measurement <= (others=>'0');
        target_bits      <= '1' & parity & TEMPLATE_BITS(7 downto 1);
        if (rx_parity_i=0) then
          target_bit_count <= to_unsigned(8,target_bit_count'length);
        else
          target_bit_count <= to_unsigned(9,target_bit_count'length); -- ODD/EVEN parity means extra bit.
        end if;
        if (rx_stream_i = '0') then
          fsm_state <= MEASURE_START_BIT;
        end if;

      when MEASURE_START_BIT =>
        if (rx_stream_i = '1') then
          half_measurement <= measurement;
          fsm_state        <= MEASURE_DATA_BIT;
        else
          measurement <= measurement+1;
        end if;

      when MEASURE_DATA_BIT =>
        -- The duration of the data bit must not be significantly different
        -- than the duration of the start bit...
        measurement <= measurement+1;
        if (rx_stream_i='0') then  -- Look for the end of the least significant data bit.
          if (delta>DELTA_THRESHOLD) then
            fsm_state <= IDLE;
          else
            fsm_state <= VERIFY;            
          end if;
        end if;

      when VERIFY =>  -- Wait for verify operations to finish
        if (target_bit_count=0) then -- At the stop bit, check the status
          if (char_mismatch='0') then
            baud_div  <= measurement; -- Store final verified measurement for running
            baud_lock <= '1';
          end if;
          if (rx_stream_i='1') then -- Only return when there is a chance of making a valid new measurement...
            fsm_state <= IDLE; -- Whether successful, or not, return to IDLE ("autotracking" feature.)
          end if;
        else
          if (half_measurement>=measurement) then -- Initial setting leads to near mid-bit sampling.
            half_measurement <= (others=>'0');
            target_bits <= '0' & target_bits(target_bits'length-1 downto 1);
            target_bit_count <= target_bit_count-1;
            if (target_bits(0)/=rx_stream_i) then
              char_mismatch <= '1';
            end if;
          else
            half_measurement <= half_measurement+2;
          end if;
        end if;

      --when others => 
      --  fsm_state <= IDLE;
    end case;

  end if;
end process;

baud_lock_o <= baud_lock;



end beh;


--------------------------------------------------------------------
-- ...A wrapper to allow instantiating this module with
-- busses of type "std_logic_vector" for those who need that.
--
--------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.auto_baud_pack.all;

entity auto_baud_with_tracking_slv is
    generic (
      CLOCK_FACTOR    : natural := 16;        -- Output is this factor times the baud rate
      FPGA_CLKRATE    : integer := 25000000;  -- FPGA system clock rate
      MIN_BAUDRATE    : integer := 57600;     -- Minimum expected incoming Baud rate
      DELTA_THRESHOLD : integer := 6          -- Max. number of sys_clks difference allowed between
                                              -- "half_measurement" and "measurement"
    );
    port ( 
       
      sys_rst_n    : in  std_logic;
      sys_clk      : in  std_logic;

      -- rate and parity
      rx_parity_i  : in  std_logic_vector(1 downto 0); -- 0=none, 1=even, 2=odd

      -- serial input
      rx_stream_i  : in  std_logic;

      -- Output
      baud_lock_o  : out std_logic;
      baud_clk_o   : out std_logic
    );
end auto_baud_with_tracking_slv;

architecture beh of auto_baud_with_tracking_slv is

-- Internal signal declarations
signal rx_parity_u : unsigned(1 downto 0); -- The "template bit" for checking the received parity bit.

-----------------------------------------------------------------------------
begin

  -- This module generates a serial BAUD clock automatically.
  -- The unit synchronizes on the carriage return character, so the user
  -- only needs to press the "enter" key for serial communications to start
  -- working, no matter what BAUD rate and clk_i frequency are used!
  auto_baud1 : auto_baud_with_tracking
    generic map(
      CLOCK_FACTOR    => CLOCK_FACTOR,   -- Output is this factor times the baud rate
      FPGA_CLKRATE    => FPGA_CLKRATE,   -- FPGA system clock rate
      MIN_BAUDRATE    => MIN_BAUDRATE,   -- Minimum expected incoming Baud rate
      DELTA_THRESHOLD => DELTA_THRESHOLD -- Max. number of sys_clks difference allowed between
                                         -- "half_measurement" and "measurement"
    )
    port map( 
       
      sys_rst_n    => sys_rst_n,
      sys_clk      => sys_clk,

      -- rate and parity
      rx_parity_i  => rx_parity_u, -- 0=none, 1=even, 2=odd

      -- serial input
      rx_stream_i  => rx_stream_i,

      -- Output
      baud_lock_o  => baud_lock_o,
      baud_clk_o   => baud_clk_o
    );

rx_parity_u <= unsigned(rx_parity_i);

end beh;

