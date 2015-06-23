--##############################################################################
--
--  filter_tb
--      Testbench for digital lowpass filters
--
--      This testbench has one architecture per filter to test.
--      The tester itself is given in a separate file: "filter_tester.vhd".
--
--------------------------------------------------------------------------------
--
--  Versions / Authors
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
--      Choose the test architecture: comment-out the others or rely on the
--      possibilities of your EDA tool.
--
--      Compile and go.
--
--##############################################################################

LIBRARY ieee;
  USE ieee.std_logic_1164.all;
  USE ieee.numeric_std.ALL;

ENTITY filter_tb IS
END filter_tb ;

--==============================================================================

ARCHITECTURE butterworth3 OF filter_tb IS

  constant inputBitNb: positive := 16;
  constant outputBitNb: positive := 20;
  constant shiftBitNb: positive := 8;

  SIGNAL clock     : std_ulogic;
  SIGNAL en        : std_ulogic;
  SIGNAL filterIn  : signed(inputBitNb-1 DOWNTO 0);
  SIGNAL filterOut : signed(outputBitNb-1 DOWNTO 0);
  SIGNAL reset     : std_ulogic;

  COMPONENT butterworth3
  GENERIC (
    inputBitNb  : positive := 16;
    outputBitNb : positive := 16;
    shiftBitNb  : positive := 4
  );
  PORT (
    filterOut : OUT    signed (outputBitNb-1 DOWNTO 0);
    filterIn  : IN     signed (inputBitNb-1 DOWNTO 0);
    clock     : IN     std_ulogic ;
    reset     : IN     std_ulogic ;
    en        : IN     std_ulogic
  );
  END COMPONENT;

  COMPONENT filter_tester
  GENERIC (
    inputBitNb  : positive := 16;
    outputBitNb : positive := 16;
    shiftBitNb  : positive := 16
  );
  PORT (
    reset     : OUT    std_ulogic ;
    clock     : OUT    std_ulogic ;
    filterOut : IN     signed (outputBitNb-1 DOWNTO 0);
    en        : OUT    std_ulogic ;
    filterIn  : OUT    signed (inputBitNb-1 DOWNTO 0)
  );
  END COMPONENT;

BEGIN

  DUT : butterworth3
    GENERIC MAP (
      inputBitNb  => inputBitNb,
      outputBitNb => outputBitNb,
      shiftBitNb  => shiftBitNb
    )
    PORT MAP (
      filterOut => filterOut,
      filterIn  => filterIn,
      clock     => clock,
      reset     => reset,
      en        => en
    );

  Tester : filter_tester
    GENERIC MAP (
      inputBitNb  => inputBitNb,
      outputBitNb => outputBitNb,
      shiftBitNb  => shiftBitNb
    )
    PORT MAP (
      reset     => reset,
      clock     => clock,
      filterOut => filterOut,
      en        => en,
      filterIn  => filterIn
     );

END butterworth3;

--==============================================================================

ARCHITECTURE bessel6 OF filter_tb IS

  constant inputBitNb: positive := 16;
  constant outputBitNb: positive := 20;
  constant shiftBitNb: positive := 8;

  SIGNAL clock     : std_ulogic;
  SIGNAL en        : std_ulogic;
  SIGNAL filterIn  : signed(inputBitNb-1 DOWNTO 0);
  SIGNAL filterOut : signed(outputBitNb-1 DOWNTO 0);
  SIGNAL reset     : std_ulogic;

  COMPONENT bessel6
  GENERIC (
    inputBitNb  : positive := 16;
    outputBitNb : positive := 16;
    shiftBitNb  : positive := 4
  );
  PORT (
    filterOut : OUT    signed (outputBitNb-1 DOWNTO 0);
    filterIn  : IN     signed (inputBitNb-1 DOWNTO 0);
    clock     : IN     std_ulogic ;
    reset     : IN     std_ulogic ;
    en        : IN     std_ulogic
  );
  END COMPONENT;

  COMPONENT filter_tester
  GENERIC (
    inputBitNb  : positive := 16;
    outputBitNb : positive := 16;
    shiftBitNb  : positive := 16
  );
  PORT (
    reset     : OUT    std_ulogic ;
    clock     : OUT    std_ulogic ;
    filterOut : IN     signed (outputBitNb-1 DOWNTO 0);
    en        : OUT    std_ulogic ;
    filterIn  : OUT    signed (inputBitNb-1 DOWNTO 0)
  );
  END COMPONENT;

BEGIN

  DUT : bessel6
    GENERIC MAP (
      inputBitNb  => inputBitNb,
      outputBitNb => outputBitNb,
      shiftBitNb  => shiftBitNb
    )
    PORT MAP (
      filterOut => filterOut,
      filterIn  => filterIn,
      clock     => clock,
      reset     => reset,
      en        => en
    );

  Tester : filter_tester
    GENERIC MAP (
      inputBitNb  => inputBitNb,
      outputBitNb => outputBitNb,
      shiftBitNb  => shiftBitNb
    )
    PORT MAP (
      reset     => reset,
      clock     => clock,
      filterOut => filterOut,
      en        => en,
      filterIn  => filterIn
     );

END bessel6;

--==============================================================================

ARCHITECTURE bessel8 OF filter_tb IS

   constant inputBitNb: positive := 16;
   constant outputBitNb: positive := 20;
   constant shiftBitNb: positive := 8;

   SIGNAL clock     : std_ulogic;
   SIGNAL en        : std_ulogic;
   SIGNAL filterIn  : signed(inputBitNb-1 DOWNTO 0);
   SIGNAL filterOut : signed(outputBitNb-1 DOWNTO 0);
   SIGNAL reset     : std_ulogic;

  COMPONENT bessel8
  GENERIC (
    inputBitNb  : positive := 16;
    outputBitNb : positive := 16;
    shiftBitNb  : positive := 4
  );
  PORT (
    filterOut : OUT    signed (outputBitNb-1 DOWNTO 0);
    filterIn  : IN     signed (inputBitNb-1 DOWNTO 0);
    clock     : IN     std_ulogic ;
    reset     : IN     std_ulogic ;
    en        : IN     std_ulogic
  );
  END COMPONENT;

  COMPONENT filter_tester
  GENERIC (
    inputBitNb  : positive := 16;
    outputBitNb : positive := 16;
    shiftBitNb  : positive := 16
  );
  PORT (
    reset     : OUT    std_ulogic ;
    clock     : OUT    std_ulogic ;
    filterOut : IN     signed (outputBitNb-1 DOWNTO 0);
    en        : OUT    std_ulogic ;
    filterIn  : OUT    signed (inputBitNb-1 DOWNTO 0)
  );
  END COMPONENT;

BEGIN

  DUT : bessel8
    GENERIC MAP (
      inputBitNb  => inputBitNb,
      outputBitNb => outputBitNb,
      shiftBitNb  => shiftBitNb
    )
    PORT MAP (
      filterOut => filterOut,
      filterIn  => filterIn,
      clock     => clock,
      reset     => reset,
      en        => en
    );

  Tester : filter_tester
    GENERIC MAP (
      inputBitNb  => inputBitNb,
      outputBitNb => outputBitNb,
      shiftBitNb  => shiftBitNb
    )
    PORT MAP (
      reset     => reset,
      clock     => clock,
      filterOut => filterOut,
      en        => en,
      filterIn  => filterIn
     );

END bessel8;

--==============================================================================

ARCHITECTURE lowpass OF filter_tb IS

   constant inputBitNb: positive := 16;
   constant outputBitNb: positive := 20;
   constant shiftBitNb: positive := 8;

   SIGNAL clock     : std_ulogic;
   SIGNAL en        : std_ulogic;
   SIGNAL filterIn  : signed(inputBitNb-1 DOWNTO 0);
   SIGNAL filterOut : signed(outputBitNb-1 DOWNTO 0);
   SIGNAL reset     : std_ulogic;

  COMPONENT lowpass
  GENERIC (
    inputBitNb  : positive := 16;
    outputBitNb : positive := 16;
    shiftBitNb  : positive := 4
  );
  PORT (
    filterOut : OUT    signed (outputBitNb-1 DOWNTO 0);
    filterIn  : IN     signed (inputBitNb-1 DOWNTO 0);
    clock     : IN     std_ulogic ;
    reset     : IN     std_ulogic ;
    en        : IN     std_ulogic
  );
  END COMPONENT;

  COMPONENT filter_tester
  GENERIC (
    inputBitNb  : positive := 16;
    outputBitNb : positive := 16;
    shiftBitNb  : positive := 16
  );
  PORT (
    reset     : OUT    std_ulogic ;
    clock     : OUT    std_ulogic ;
    filterOut : IN     signed (outputBitNb-1 DOWNTO 0);
    en        : OUT    std_ulogic ;
    filterIn  : OUT    signed (inputBitNb-1 DOWNTO 0)
  );
  END COMPONENT;

BEGIN

  DUT : lowpass
    GENERIC MAP (
      inputBitNb  => inputBitNb,
      outputBitNb => outputBitNb,
      shiftBitNb  => shiftBitNb
    )
    PORT MAP (
      filterOut => filterOut,
      filterIn  => filterIn,
      clock     => clock,
      reset     => reset,
      en        => en
    );

  Tester : filter_tester
    GENERIC MAP (
      inputBitNb  => inputBitNb,
      outputBitNb => outputBitNb,
      shiftBitNb  => shiftBitNb
    )
    PORT MAP (
      reset     => reset,
      clock     => clock,
      filterOut => filterOut,
      en        => en,
      filterIn  => filterIn
     );

END bessel8;

