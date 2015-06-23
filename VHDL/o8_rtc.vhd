-- VHDL Units :  realtime_clock
-- Description:  Provides automatically updated registers that maintain the
--            :   time of day. Keeps track of the day of week, hours, minutes
--            :   seconds, and tenths of a second. Module is doubled buffered
--            :   to ensure time consistency during accesses. Also provides
--            :   a programmable periodic interrupt timer, as well as a uSec
--            :    tick for external use.
-- 
-- Register Map:
-- Offset  Bitfield Description                        Read/Write
--   0x0   AAAAAAAA Periodic Interval Timer in uS      (RW)
--   0x1   -AAAAAAA Tenths  (0x00 - 0x63)              (RW)
--   0x2   --AAAAAA Seconds (0x00 - 0x3B)              (RW)
--   0x3   --AAAAAA Minutes (0x00 - 0x3B)              (RW)
--   0x4   ---AAAAA Hours   (0x00 - 0x17)              (RW)
--   0x5   -----AAA Day of Week (0x00 - 0x06)          (RW)
--   0x6   -------- Update RTC regs from Shadow Regs   (WO)
--   0x7   A------- Update Shadow Regs from RTC regs   (RW)
--                  A = Update is Busy

library ieee;
use ieee.std_logic_1164.all;
  use ieee.std_logic_unsigned.all;
  use ieee.std_logic_arith.all;
  use ieee.std_logic_misc.all;

library work;
  use work.open8_pkg.all;

entity o8_rtc is
generic(
  Sys_Freq              : real;
  Reset_Level           : std_logic;
  Address               : ADDRESS_TYPE
);
port(
  Clock                 : in  std_logic;
  Reset                 : in  std_logic;
  uSec_Tick             : out std_logic;
  --
  Bus_Address           : in  ADDRESS_TYPE;
  Wr_Enable             : in  std_logic;
  Wr_Data               : in  DATA_TYPE;
  Rd_Enable             : in  std_logic;
  Rd_Data               : out DATA_TYPE;
  --
  Interrupt_PIT         : out std_logic;
  Interrupt_RTC         : out std_logic
);
end entity;

architecture behave of o8_rtc is

  -- The ceil_log2 function returns the minimum register width required to
  --  hold the supplied integer.
  function ceil_log2 (x : in natural) return natural is
    variable retval          : natural;
  begin
    retval                   := 1;
    while ((2**retval) - 1) < x loop
      retval                 := retval + 1;
    end loop;
    return retval;
  end ceil_log2;

  constant User_Addr    : std_logic_vector(15 downto 3)
                          := Address(15 downto 3);
  alias  Comp_Addr      is Bus_Address(15 downto 3);
  signal Addr_Match     : std_logic;

  alias  Reg_Addr       is Bus_Address(2 downto 0);
  signal Reg_Addr_q     : std_logic_vector(2 downto 0);

  signal Wr_En          : std_logic;
  signal Wr_Data_q      : DATA_TYPE;
  signal Rd_En          : std_logic;

  constant DLY_1USEC_VAL: integer := integer(Sys_Freq / 1000000.0);
  constant DLY_1USEC_WDT: integer := ceil_log2(DLY_1USEC_VAL - 1);
  constant DLY_1USEC    : std_logic_vector :=
                       conv_std_logic_vector( DLY_1USEC_VAL - 1, DLY_1USEC_WDT);

  signal uSec_Cntr      : std_logic_vector( DLY_1USEC_WDT - 1 downto 0 )
                          := (others => '0');
  signal uSec_Tick_i      : std_logic;

  type PIT_TYPE is record
    timer_cnt           : DATA_TYPE;
    timer_ro            : std_logic;
  end record;

  signal pit            : PIT_TYPE;

  type RTC_TYPE is record
    frac                : std_logic_vector(15 downto 0);
    frac_ro             : std_logic;

    tens_l              : std_logic_vector(3 downto 0);
    tens_l_ro           : std_logic;

    tens_u              : std_logic_vector(3 downto 0);
    tens_u_ro           : std_logic;

    secs_l              : std_logic_vector(3 downto 0);
    secs_l_ro           : std_logic;

    secs_u              : std_logic_vector(3 downto 0);
    secs_u_ro           : std_logic;

    mins_l              : std_logic_vector(3 downto 0);
    mins_l_ro           : std_logic;

    mins_u              : std_logic_vector(3 downto 0);
    mins_u_ro           : std_logic;

    hours_l             : std_logic_vector(3 downto 0);
    hours_l_ro          : std_logic;

    hours_u             : std_logic_vector(3 downto 0);
    hours_u_ro          : std_logic;

    dow                 : std_logic_vector(2 downto 0);
  end record;

  constant DECISEC      : std_logic_vector(15 downto 0) :=
                           conv_std_logic_vector(10000,16);

  signal rtc            : RTC_TYPE;

  signal interval       : DATA_TYPE;

  signal shd_tens       : DATA_TYPE;
  signal shd_secs       : DATA_TYPE;
  signal shd_mins       : DATA_TYPE;
  signal shd_hours      : DATA_TYPE;
  signal shd_dow        : DATA_TYPE;

  signal update_rtc     : std_logic;
  signal update_shd     : std_logic;
  signal update_ctmr    : std_logic_vector(3 downto 0);

begin

  uSec_Tick             <= uSec_Tick_i;
  Addr_Match            <= '1' when Comp_Addr = User_Addr else '0';

  Interrupt_PIT         <= pit.timer_ro;
  Interrupt_RTC         <= rtc.frac_ro;

  io_reg: process( Clock, Reset )
  begin
    if( Reset = Reset_Level )then
      uSec_Cntr         <= (others => '0');
      uSec_Tick_i       <= '0';

      pit.timer_cnt     <= x"00";
      pit.timer_ro      <= '0';

      rtc.frac          <= DECISEC;
      rtc.frac_ro       <= '0';

      rtc.tens_l        <= (others => '0');
      rtc.tens_l_ro     <= '0';

      rtc.tens_u        <= (others => '0');
      rtc.tens_u_ro     <= '0';

      rtc.secs_l        <= (others => '0');
      rtc.secs_l_ro     <= '0';

      rtc.secs_u        <= (others => '0');
      rtc.secs_u_ro     <= '0';

      rtc.mins_l        <= (others => '0');
      rtc.mins_l_ro     <= '0';

      rtc.mins_u        <= (others => '0');
      rtc.mins_u_ro     <= '0';

      rtc.hours_l       <= (others => '0');
      rtc.hours_l_ro    <= '0';

      rtc.hours_u       <= (others => '0');
      rtc.hours_u_ro    <= '0';

      rtc.dow           <= (others => '0');

      shd_tens          <= (others => '0');
      shd_secs          <= (others => '0');
      shd_mins          <= (others => '0');
      shd_hours         <= (others => '0');
      shd_dow           <= (others => '0');

      update_rtc        <= '0';
      update_shd        <= '0';
      update_ctmr       <= (others => '0');

      interval          <= x"00";

      Wr_Data_q         <= (others => '0');
      Reg_Addr_q        <= (others => '0');
      Wr_En             <= '0';
      Rd_En             <= '0';
      Rd_Data           <= x"00";

    elsif( rising_edge( Clock ) )then

      uSec_Cntr         <= uSec_Cntr - 1;
      uSec_Tick_i       <= '0';
      if( uSec_Cntr = 0 )then
        uSec_Cntr       <= DLY_1USEC;
        uSec_Tick_i     <= or_reduce(Interval);
      end if;

      pit.timer_ro      <= '0';

      rtc.frac_ro       <= '0';
      rtc.tens_l_ro     <= '0';
      rtc.tens_u_ro     <= '0';
      rtc.secs_l_ro     <= '0';
      rtc.secs_u_ro     <= '0';
      rtc.mins_l_ro     <= '0';
      rtc.mins_u_ro     <= '0';
      rtc.hours_l_ro    <= '0';
      rtc.hours_u_ro    <= '0';

      -- Periodic Interval Timer
      pit.timer_cnt     <= pit.timer_cnt - uSec_Tick_i;
      if( or_reduce(pit.timer_cnt) = '0' )then
        pit.timer_cnt   <= interval;
        pit.timer_ro    <= or_reduce(interval); -- Only issue output on Int > 0
      end if;

      -- Fractional decisecond counter - cycles every 10k microseconds
      rtc.frac          <= rtc.frac - uSec_Tick_i;
      if( or_reduce(rtc.frac) = '0' or update_rtc = '1' )then
        rtc.frac        <= DECISEC;
        rtc.frac_ro     <= not update_rtc;
      end if;

      -- Decisecond counter (lower)
      rtc.tens_l        <= rtc.tens_l + rtc.frac_ro;
      if( update_rtc = '1' )then
        rtc.tens_l      <= shd_tens(3 downto 0);
      elsif( rtc.tens_l > x"9")then
        rtc.tens_l      <= (others => '0');
        rtc.tens_l_ro   <= '1';
      end if;

      -- Decisecond counter (upper)
      rtc.tens_u        <= rtc.tens_u + rtc.tens_l_ro;
      if( update_rtc = '1' )then
        rtc.tens_u      <= shd_tens(7 downto 4);
      elsif( rtc.tens_u > x"9")then
        rtc.tens_u      <= (others => '0');
        rtc.tens_u_ro   <= '1';
      end if;

      -- Second counter (lower)
      rtc.secs_l        <= rtc.secs_l + rtc.tens_u_ro;
      if( update_rtc = '1' )then
        rtc.secs_l      <= shd_secs(3 downto 0);
      elsif( rtc.secs_l > x"9")then
        rtc.secs_l      <= (others => '0');
        rtc.secs_l_ro   <= '1';
      end if;

      -- Second counter (upper)
      rtc.secs_u        <= rtc.secs_u + rtc.secs_l_ro;
      if( update_rtc = '1' )then
        rtc.secs_u      <= shd_secs(7 downto 4);
      elsif( rtc.secs_u > x"5")then
        rtc.secs_u      <= (others => '0');
        rtc.secs_u_ro   <= '1';
      end if;

      -- Minutes counter (lower)
      rtc.mins_l        <= rtc.mins_l + rtc.secs_u_ro;
      if( update_rtc = '1' )then
        rtc.mins_l      <= shd_mins(3 downto 0);
      elsif( rtc.mins_l > x"9")then
        rtc.mins_l      <= (others => '0');
        rtc.mins_l_ro   <= '1';
      end if;

      -- Minutes counter (upper)
      rtc.mins_u        <= rtc.mins_u + rtc.mins_l_ro;
      if( update_rtc = '1' )then
        rtc.mins_u      <= shd_mins(7 downto 4);
      elsif( rtc.mins_u > x"5")then
        rtc.mins_u      <= (others => '0');
        rtc.mins_u_ro   <= '1';
      end if;

      -- Hour counter (lower)
      rtc.hours_l       <= rtc.hours_l + rtc.mins_u_ro;
      if( update_rtc = '1' )then
        rtc.hours_l     <= shd_hours(3 downto 0);
      elsif( rtc.hours_l > x"9")then
        rtc.hours_l     <= (others => '0');
        rtc.hours_l_ro  <= '1';
      end if;

      -- Hour counter (upper)
      rtc.hours_u       <= rtc.hours_u + rtc.hours_l_ro;
      if( update_rtc = '1' )then
        rtc.hours_u     <= shd_hours(7 downto 4);
      end if;

      if( rtc.hours_u >= x"2" and rtc.hours_l > x"3" )then
        rtc.hours_l     <= (others => '0');
        rtc.hours_u     <= (others => '0');
        rtc.hours_u_ro  <= '1';
      end if;

      -- Day of Week counter
      rtc.dow           <= rtc.dow + rtc.hours_u_ro;
      if( update_rtc = '1' )then
        rtc.dow        <= shd_dow(2 downto 0);
      elsif( rtc.dow = x"07")then
        rtc.dow         <= (others => '0');
      end if;

      -- Copy the RTC registers to the shadow registers when the coherency
      --  timer is zero (RTC registers are static)
      if( update_shd = '1' and or_reduce(update_ctmr) = '0' )then
        shd_tens        <= rtc.tens_u & rtc.tens_l;
        shd_secs        <= rtc.secs_u & rtc.secs_l;
        shd_mins        <= rtc.mins_u & rtc.mins_l;
        shd_hours       <= rtc.hours_u & rtc.hours_l;
        shd_dow         <= "00000" & rtc.dow;
        update_shd      <= '0';
      end if;

      Reg_Addr_q        <= Reg_Addr;
      Wr_Data_q         <= Wr_Data;

      Wr_En             <= Addr_Match and Wr_Enable;
      update_rtc        <= '0';
      if( Wr_En = '1' )then
        case( Reg_Addr_q )is
          when "000" =>
            interval    <= Wr_Data_q;

          when "001" =>
            shd_tens    <= Wr_Data_q;

          when "010" =>
            shd_secs    <= Wr_Data_q;

          when "011" =>
            shd_mins    <= Wr_Data_q;

          when "100" =>
            shd_hours   <= Wr_Data_q;

          when "101" =>
            shd_dow     <= Wr_Data_q;

          when "110" =>
            update_rtc  <= '1';

          when "111" =>
            update_shd  <= '1';

          when others => null;
        end case;
      end if;

      -- Coherency timer - ensures that the shadow registers are updated with
      --  valid time data by delaying updates until the rtc registers have
      --  finished cascading.
      update_ctmr       <= update_ctmr - or_reduce(update_ctmr);
      if( rtc.frac_ro = '1' )then
        update_ctmr     <= (others => '1');
      end if;

      Rd_Data           <= (others => '0');
      Rd_En             <= Addr_Match and Rd_Enable;
      if( Rd_En = '1' )then
        case( Reg_Addr_q )is
          when "000" =>
            Rd_Data     <= interval;
          when "001" =>
            Rd_Data     <= shd_tens;
          when "010" =>
            Rd_Data     <= shd_secs;
          when "011" =>
            Rd_Data     <= shd_mins;
          when "100" =>
            Rd_Data     <= shd_hours;
          when "101" =>
            Rd_Data     <= shd_dow;
          when "110" =>
            null;
          when "111" =>
            Rd_Data     <= update_shd & "0000000";
          when others => null;
        end case;
      end if;

    end if;
  end process;

end architecture;