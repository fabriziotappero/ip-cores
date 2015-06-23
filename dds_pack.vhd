--------------------------------------------------------------------------
-- Package of dds components
--
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.sine_lut_pkg.all;

package dds_pack is

  component dds_constant_squarewave
    generic (
      OUTPUT_FREQ  : real;   -- Desired output frequency
      SYS_CLK_RATE : real;   -- underlying clock rate
      ACC_BITS     : integer -- Bit width of DDS phase accumulator
    );
    port ( 
       
      sys_rst_n    : in  std_logic;
      sys_clk      : in  std_logic;
      sys_clk_en   : in  std_logic;

      -- Output
      pulse_o      : out std_logic;
      squarewave_o : out std_logic
    );
  end component;

  component dds_squarewave
    generic (
      ACC_BITS     : integer -- Bit width of DDS phase accumulator
    );
    port ( 
       
      sys_rst_n    : in  std_logic;
      sys_clk      : in  std_logic;
      sys_clk_en   : in  std_logic;

      -- Frequency setting
      freq_i       : in  unsigned(ACC_BITS-1 downto 0);

      -- Output
      pulse_o      : out std_logic;
      squarewave_o : out std_logic
    );
  end component;

  component dds_sine_non_power_of_two
    generic(
      PHI_WIDTH : integer  -- Bits in phase accumulator.  Must hold numbers greater than full sinewave lut length...
      );
    port(
      clk_i     : in  std_logic;
      rst_n_i   : in  std_logic;
      clk_en_i  : in  std_logic;
      ftw_i     : in  unsigned(PHI_WIDTH-1 downto 0);
      accum_o   : out unsigned(PHI_WIDTH-1 downto 0);
      sine_o    : out signed(AMPL_WIDTH-1 downto 0)
      );
  end component;

end dds_pack;

package body dds_pack is
end dds_pack;

-------------------------------------------------------------------------------
-- Direct Digital Synthesizer Constant Squarewave module
-------------------------------------------------------------------------------
--
-- Author: John Clayton
-- Update: Sep.  5, 2002 copied this file from "auto_baud_pack.vhd"
--                       Added tracking functions, and debugged them.
--
-- Description
-------------------------------------------------------------------------------
-- This is a simple direct digital synthesizer module.  It includes a phase
-- accumulator which increments in order to produce the desired output
-- frequency in its most significant bit, which is the squarewave output.
--
-- In addition to the squarewave output there is a pulse output which is
-- high for one sys_clk period, during the sys_clk period immediately
-- preceding the rising edge of the squarewave output.
--
-- NOTES:
--   The accumulator increment word is:
--        increment = Fout*2^N/Fsys_clk
--
--   Where N is the number of bits in the phase accumulator.
--
--   There will always be jitter with this type of clock source, but the
--   long time average frequency can be made arbitrarily close to whatever
--   value is desired, simply by increasing N.
--
--   To reduce jitter, use a higher underlying system clock frequency, and
--   for goodness sakes, try to keep the desired output frequency much lower
--   than the system clock frequency.  The closer it gets to Fsys_clk/2, the
--   closer it is to the Nyquist limit, and the output jitter is much more
--   significant at that point.
--
--


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;

  entity dds_constant_squarewave is
    generic (
      OUTPUT_FREQ  : real := 8000.0;     -- Desired output frequency
      SYS_CLK_RATE : real := 48000000.0; -- underlying clock rate
      ACC_BITS     : integer := 16       -- Bit width of DDS phase accumulator
    );
    port ( 
       
      sys_rst_n    : in  std_logic;
      sys_clk      : in  std_logic;
      sys_clk_en   : in  std_logic;

      -- Output
      pulse_o      : out std_logic;
      squarewave_o : out std_logic
    );
  end dds_constant_squarewave;

architecture beh of dds_constant_squarewave is

-- Constants
constant DDS_INCREMENT : integer := integer(OUTPUT_FREQ*(2**real(ACC_BITS))/SYS_CLK_RATE);

signal dds_phase      : unsigned(ACC_BITS-1 downto 0); -- phase accumulator register
signal dds_phase_next : unsigned(ACC_BITS-1 downto 0);

-----------------------------------------------------------------------------
begin

  dds_proc: Process(sys_rst_n,sys_clk)
  begin
    if (sys_rst_n = '0') then
      dds_phase <= (others=>'0');
    elsif (sys_clk'event and sys_clk='1') then
      if (sys_clk_en='1') then
        dds_phase <= dds_phase_next;
      end if;
    end if; -- sys_clk
  end process dds_proc;
  dds_phase_next <= dds_phase + DDS_INCREMENT;
  pulse_o <= '1' when sys_clk_en='1' and dds_phase(dds_phase'length-1)='0' and dds_phase_next(dds_phase_next'length-1)='1' else '0';
  squarewave_o <= dds_phase(dds_phase'length-1);

end beh;


-------------------------------------------------------------------------------
-- Direct Digital Synthesizer Constant Squarewave module
-------------------------------------------------------------------------------
--
-- Author: John Clayton
-- Update: Jan. 31, 2013 copied code from dds_constant_squarewave, and
--                       modified it to accept a frequency setting input.
--
-- Description
-------------------------------------------------------------------------------
-- This is a simple direct digital synthesizer module.  It includes a phase
-- accumulator which increments in order to produce the desired output
-- frequency in its most significant bit, which is the squarewave output.
--
-- In addition to the squarewave output there is a pulse output which is
-- high for one sys_clk period, during the sys_clk period immediately
-- preceding the rising edge of the squarewave output.
--
-- NOTES:
--   The accumulator increment word is:
--        increment = Fout*2^N/Fsys_clk
--
--   Where N is the number of bits in the phase accumulator.
--
--   There will always be jitter with this type of clock source, but the
--   long time average frequency can be made arbitrarily close to whatever
--   value is desired, simply by increasing N.
--
--   To reduce jitter, use a higher underlying system clock frequency, and
--   for goodness sakes, try to keep the desired output frequency much lower
--   than the system clock frequency.  The closer it gets to Fsys_clk/2, the
--   closer it is to the Nyquist limit, and the output jitter is much more
--   significant at that point.
--
--


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;

  entity dds_squarewave is
    generic (
      ACC_BITS     : integer := 16       -- Bit width of DDS phase accumulator
    );
    port ( 
       
      sys_rst_n    : in  std_logic;
      sys_clk      : in  std_logic;
      sys_clk_en   : in  std_logic;

      -- Frequency setting
      freq_i       : in  unsigned(ACC_BITS-1 downto 0);

      -- Output
      pulse_o      : out std_logic;
      squarewave_o : out std_logic
    );
  end dds_squarewave;

architecture beh of dds_squarewave is

-- Constants
signal dds_phase      : unsigned(ACC_BITS-1 downto 0); -- phase accumulator register
signal dds_phase_next : unsigned(ACC_BITS-1 downto 0);

-----------------------------------------------------------------------------
begin

  dds_proc: Process(sys_rst_n,sys_clk)
  begin
    if (sys_rst_n = '0') then
      dds_phase <= (others=>'0');
    elsif (sys_clk'event and sys_clk='1') then
      if (sys_clk_en='1') then
        dds_phase <= dds_phase_next;
      end if;
    end if; -- sys_clk
  end process dds_proc;
  dds_phase_next <= dds_phase + freq_i;
  pulse_o <= '1' when sys_clk_en='1' and dds_phase(dds_phase'length-1)='0' and dds_phase_next(dds_phase_next'length-1)='1' else '0';
  squarewave_o <= dds_phase(dds_phase'length-1);

end beh;


-------------------------------------------------------------------------------
-- Direct Digital Synthesizer Arbitrary Length Sinewave Look Up Table module
-------------------------------------------------------------------------------
--
-- Author: John Clayton
-- Update: Jan. 24, 2013 Modified Matlab script "sine_arbitrary_length_lut_gen"
--                       to produce VHDL output which uses the "unsigned" type
--                       from ieee.numeric_std library.
--         Jan. 26, 2013 Rewrote accumulator folding logic.  Added saturation
--                       check to avoid indices beyond the end of the lookup
--                       table.
--
-- Description
-------------------------------------------------------------------------------
-- This is a direct digital synthesizer module, which uses a 1/4 wave lookup
-- to produce sinewave samples.  A Matlab script generates the samples to the
-- desired number of bits, number of samples and amplitude.
--
-- The generated file is the "sine_lut_pkg", although the filename may well
-- be different, such as "sine_lut_5000_x_16.vhd"
--
-- The generated file contains definitions for:
--   constant AMPL_WIDTH : integer
--   constant PHASE_LENGTH : integer
--   constant PHASE_WIDTH  : integer
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.sine_lut_pkg.all;
use work.convert_pack.all;

entity dds_sine_non_power_of_two is
  generic(
    PHI_WIDTH : integer  -- Bits in phase accumulator.  Must hold numbers greater than full sinewave lut length...
    );
  port(
    clk_i    : in  std_logic;
    rst_n_i  : in  std_logic;
    clk_en_i : in  std_logic;
    ftw_i    : in  unsigned(PHI_WIDTH-1 downto 0);
    accum_o  : out unsigned(PHI_WIDTH-1 downto 0);
    sine_o   : out signed(AMPL_WIDTH-1 downto 0)
    );
end dds_sine_non_power_of_two;

architecture dds_arch of dds_sine_non_power_of_two is

  constant FRAC_BITS     : natural := PHI_WIDTH - PHASE_WIDTH;
  constant Q_PHASE_WIDTH : integer := PHASE_WIDTH-2;  -- Quarter phase takes two bits less to represent
  constant Q_LENGTH      : unsigned(Q_PHASE_WIDTH-1 downto 0) := to_unsigned(PHASE_LENGTH/4,Q_PHASE_WIDTH); -- Quadrant Length
  constant Q_THRESH      : unsigned(PHI_WIDTH-1 downto 0) := to_unsigned(2**FRAC_BITS*PHASE_LENGTH/4,PHI_WIDTH); -- Quadrant Length

  signal accum        : unsigned(PHI_WIDTH-1 downto 0);
  signal q_accum      : unsigned(PHI_WIDTH-1 downto 0);
  signal q_accum_next : unsigned(PHI_WIDTH-1 downto 0);
  signal accum_incr   : unsigned(PHI_WIDTH-1 downto 0);
  signal accum_folded : unsigned(PHI_WIDTH-1 downto 0);
  signal lut_out      : unsigned(AMPL_WIDTH-1 downto 0);
  signal lut_out_neg  : unsigned(AMPL_WIDTH-1 downto 0);

  signal q_phase      : unsigned(Q_PHASE_WIDTH-1 downto 0);
  signal q_phase_sat  : unsigned(Q_PHASE_WIDTH-1 downto 0);
  signal q_count      : unsigned(1 downto 0);
  signal q_count_r1   : unsigned(1 downto 0);

begin

  accum_incr   <= unsigned(ftw_i);
  q_accum_next   <= q_accum + accum_incr;
  accum_folded <=            q_accum when q_count(0)='0' else
                  Q_THRESH - q_accum;
  q_phase      <= u_resize(u_resize_l(accum_folded,PHASE_WIDTH),q_phase'length); -- Discard the fractional portion
  lut_out      <= sine_lut(to_integer(q_phase_sat));
  lut_out_neg  <= (not lut_out) + 1;
  sine_o       <= signed(lut_out_neg) when q_count_r1(1) = '1' else signed(lut_out);
  accum_o      <= accum+q_accum;

  process (clk_i, rst_n_i)
  begin
    if (rst_n_i = '0') then
      accum       <= (others=>'0');
      q_accum     <= (others=>'0');
      q_count     <= (others=>'0');
      q_count_r1  <= (others=>'0');
      q_phase_sat <= (others=>'0');
    elsif (clk_i'event and clk_i = '1') then
      if (clk_en_i = '1') then
        if (q_accum_next > Q_THRESH) then
          q_accum <= q_accum_next - Q_THRESH;
          q_count <= q_count+1;
          if (q_count="11") then
            accum <= (others=>'0');
          else
            accum   <= accum + Q_THRESH;
          end if;
        else
          q_accum <= q_accum_next;
        end if;

        -- Delayed q_count, to match delayed q_phase
        q_count_r1 <= q_count;
        -- Saturate the quarter phase signal, to avoid overflows when looking up sine values
        if (q_phase>=(PHASE_LENGTH/4)) then
          q_phase_sat <= to_unsigned(PHASE_LENGTH/4-1,q_phase_sat'length);
        else
          q_phase_sat <= q_phase;
        end if;
      end if;
    end if;
  end process;

end dds_arch;
