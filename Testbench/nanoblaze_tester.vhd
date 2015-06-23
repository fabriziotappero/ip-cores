--##############################################################################
--
--  nanoblaze_tb
--      Stimuli generator for the NanoBlaze processor testbench
--
--      Provides clock and reset to the DUT.
--      Inverts I/O data out to I/O data in for test purpose.
--
--      Waits for the end of the test signalled by the processor by writing
--      at I/O address 0. The data signals if the tests were successful or not.
--
--------------------------------------------------------------------------------
--
--  Versions / Authors
--      1.0 Francois Corthay    first implementation
--
--  Provided under GNU LGPL licence: <http://www.gnu.org/copyleft/lesser.html>
--
--  by the electronics group of "HES-SO//Valais Wallis", in Switzerland:
--  <http://www.hevs.ch/en/rad-instituts/institut-systemes-industriels/>.
--
--------------------------------------------------------------------------------
--
--  Hierarchy
--      Used by "nanoblaze_tb".
--
--##############################################################################

LIBRARY ieee;
  USE ieee.std_logic_1164.all;
  USE ieee.numeric_std.all;

ENTITY nanoBlaze_tester IS
  GENERIC( 
    addressBitNb : positive := 8;
    dataBitNb    : positive := 8
  );
  PORT( 
    reset       : OUT std_ulogic 
    clock       : OUT std_uLogic;
    en          : OUT std_uLogic;
    dataAddress : IN  unsigned(addressBitNb-1 DOWNTO 0);
    dataOut     : IN  std_ulogic_vector(dataBitNb-1 DOWNTO 0);
    dataIn      : OUT std_ulogic_vector(dataBitNb-1 DOWNTO 0);
    readStrobe  : IN  std_uLogic;
    writeStrobe : IN  std_uLogic;
    int         : OUT std_uLogic;
    intAck      : IN  std_uLogic;
  );

END nanoBlaze_tester ;

--==============================================================================

ARCHITECTURE test OF nanoBlaze_tester IS

  constant clockFrequency: real := 100.0E6;
  constant clockPeriod: time := (1.0/clockFrequency) * 1 sec;
  signal clock_int: std_uLogic := '1';

  signal dataReg: std_ulogic_vector(dataOut'range);

BEGIN
  ------------------------------------------------------------------------------
                                                              -- reset and clock
  reset <= '1', '0' after 2*clockPeriod;

  clock_int <= not clock_int after clockPeriod/2;
  clock <= transport clock_int after clockPeriod*9.0/10.0;

  ------------------------------------------------------------------------------
                                                                       -- enable
  en <= '1';

  ------------------------------------------------------------------------------
                                                                         -- data
  storeData: process(clock_int)
  begin
    if rising_edge(clock_int) then
      if writeStrobe = '1' then
        dataReg <= dataOut;
      end if;
    end if;
  end process storeData;

  dataIn <= not dataReg;

  ------------------------------------------------------------------------------
                                                               -- error checking
  checkBus: process(clock_int)
  begin
    if rising_edge(clock_int) then
      if writeStrobe = '1' then
        if (dataAddress = 0) and (unsigned(dataOut) = 0) then
          assert false
            report "Testbench reports error (output value 0 at address 0)"
            severity failure;
        end if;
        if (dataAddress = 0) and (unsigned(dataOut) = 1) then
          assert false
            report
              cr & cr &
              "--------------------------------------------------------------------------------" & cr &
              "Testbench reports successful end of simulation (output value 1 at address 0)" & cr &
              "--------------------------------------------------------------------------------" & cr &
              cr
            severity failure;
        end if;
      end if;
    end if;
  end process checkBus;

END ARCHITECTURE test;
