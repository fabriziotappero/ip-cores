--##############################################################################
--
--  filter_tester
--      Signal generator for digital lowpass filters testbench
--
--      This tester has 2 architectures:
--        - one providing a step input,
--        - one generating a sine sweep.
--
--------------------------------------------------------------------------------
--
--  Versions / Authors
--      1.1 Francois Corthay    logarithmic step for frequency sweep
--      1.0 Francois Corthay    first implementation
--
--  Provided under GNU LGPL licence: <http://www.gnu.org/copyleft/lesser.html>
--
--  by the electronics group of "HES-SO//Valais Wallis", in Switzerland:
--  <http://isi.hevs.ch/switzerland/robust-electronics.html>.
--
--------------------------------------------------------------------------------
--
--  Usage
--      The usage can vary from on EDA tool to another. However, it can be
--      used with a minimal preparation in the standard library "work".
--
--      Compile the filter to test and the filter tester (see
--      "filter_tester.vhd").
--
--      Choose the test architecture: comment-out the other or rely on the
--      possibilities of your EDA tool.
--
--      Compile and continue with the testbench "filter_tb.vhd".
--
--##############################################################################

LIBRARY ieee;
  USE ieee.std_logic_1164.all;
  USE ieee.numeric_std.ALL;

ENTITY filter_tester IS
  GENERIC(
    inputBitNb  : positive := 16;
    outputBitNb : positive := 16;
    shiftBitNb  : positive := 16
  );
  PORT(
    reset     : OUT    std_ulogic;
    clock     : OUT    std_ulogic;
    en        : OUT    std_ulogic;
    filterIn  : OUT    signed (inputBitNb-1 DOWNTO 0);
    filterOut : IN     signed (outputBitNb-1 DOWNTO 0)
  );
END filter_tester ;


--==============================================================================

ARCHITECTURE step OF filter_tester IS

  constant clockFrequency: real := 66.0E6;
  constant clockPeriod: time := (1.0/clockFrequency) * 1 sec;
  signal sClock: std_uLogic := '1';

  constant enablePeriod: positive := 10;
  signal sEn: std_uLogic;

  constant stepPeriod: time := 10000 * enablePeriod * clockPeriod;
  signal filterIn_int: integer;

BEGIN
  ------------------------------------------------------------------------------
                                                              -- clock and reset
  sClock <= not sClock after clockPeriod/2;
  clock <= transport sClock after clockPeriod*9/10;
  reset <= '1', '0' after 2*clockPeriod;

  ------------------------------------------------------------------------------
                                                                -- enable signal
  process
  begin
    sEn <= '0';
    for index in 1 to (enablePeriod-1) loop
      wait until rising_edge(sClock);
    end loop;
    sEn <= '1';
    wait until rising_edge(sClock);
  end process;

  en <= sEn;

  ------------------------------------------------------------------------------
                                                                  -- time signal
  filterIn <= (others => '0'),
              (filterIn'high => '0', others => '1') after 0.1*stepPeriod,
              (filterIn'high => '1', others => '0') after 1.1*stepPeriod;

END ARCHITECTURE step;

--==============================================================================

library ieee;
  use ieee.math_real.all;

ARCHITECTURE sweep OF filter_tester IS

  constant clockFrequency: real := 66.0E6;
  constant clockPeriod: time := (1.0/clockFrequency) * 1 sec;
  signal sClock: std_uLogic := '1';

  constant enablePeriod: positive := 4;
  signal sEn: std_uLogic := '0';

  constant minFrequencyLog: real := 3.0;
  constant maxFrequencyLog: real := 5.0;
  constant frequencyStepLog: real := 1.0/5.0;
  constant frequencyStepPeriod: time := 1.0 * (1.0/(10.0**minFrequencyLog)) * 1 sec;
  signal tReal: real := 0.0;
  signal phase: real := 0.0;
  signal sineFrequency: real;
  signal outAmplitude: real := 1.0;
  signal outReal: real := 0.0;
  signal outSigned: signed(filterIn'range);

BEGIN
  ------------------------------------------------------------------------------
                                                              -- clock and reset
  sClock <= not sClock after clockPeriod/2;
  clock <= transport sClock after clockPeriod*9/10;
  reset <= '1', '0' after 2*clockPeriod;

  ------------------------------------------------------------------------------
                                                                -- enable signal
  process
  begin
    sEn <= '0';
    for index in 1 to (enablePeriod-1) loop
      wait until rising_edge(sClock);
    end loop;
    sEn <= '1';
    wait until rising_edge(sClock);
  end process;

  en <= sEn;

  ------------------------------------------------------------------------------
                                                              -- frequency sweep
  process
    variable sineFrequencyLog: real;
  begin
    sineFrequencyLog := minFrequencyLog;
    sineFrequency <= 10**sineFrequencyLog;
    while sineFrequencyLog <= maxFrequencyLog loop
      wait for frequencyStepPeriod;
      sineFrequencyLog := sineFrequencyLog + frequencyStepLog;
      sineFrequency <= 10**sineFrequencyLog;
    end loop;
  end process;

  ------------------------------------------------------------------------------
                                                                 -- time signals
  process(sClock)
  begin
    if rising_edge(sClock) then
      if sEn = '1' then
        tReal <= tReal + real(enablePeriod)/clockFrequency;
        phase <= phase + 2.0*math_pi*sineFrequency*real(enablePeriod)/clockFrequency;
      end if;
    end if;
  end process;

  outReal <= outAmplitude * sin(phase);

  outSigned <= to_signed(
    integer(outReal * ( 2.0**(outSigned'length-1) - 1.0 )),
    outSigned'length
  );
  filterIn <= outSigned;

END ARCHITECTURE sweep;
