--##############################################################################
--
--  butterworth3
--      3rd order Butterworth lowpass filter
--
--      This circuit simulates an analog ladder filter by replacing the integral
--      relations of the LC elements by digital accumulators.
--
--------------------------------------------------------------------------------
--
--  Versions / Authors
--      1.1 Francois Corthay    added additional w(0) AND w(filterOrder+1)
--      1.0 Romain Cheviron     first implementation
--
--  Provided under GNU LGPL licence: <http://www.gnu.org/copyleft/lesser.html>
--
--  by the electronics group of "HES-SO//Valais Wallis", in Switzerland:
--  <http://isi.hevs.ch/switzerland/robust-electronics.html>.
--
--------------------------------------------------------------------------------
--
--  Usage
--      Set the input signal bit number with the generic "inputBitNb".
--
--      Set the output signal bit number with the generic "outputBitNb". This
--      value must be greater or equal than "inputBitNb". The additional bits
--      are added as LSBs. They allow to increas the resolution as the bandwidth
--      is reduced.
--
--      Define the cutoff frequency with the generic "shiftBitNb". Every
--      increment in this value shifts the cutoff frequency down by an octave
--      (a factor of 2).
--
--      The input samples are read from the signal "filterIn" at the rising edge
--      of "clock" when "en" is '1'.
--
--      With this, a new output sample is calculated and provided on
--      "filterOut". The output changes at the rising edge of "clock" when "en"
--      is '1'. It remains stable until the next time a sample is calculated.
--
--      The "reset" signal is active high.
--
--------------------------------------------------------------------------------
--
--  Synthesis results
--      A circuit with 16 bit input, 16 bit output and 4 bit shift gives the
--      following synthesis result on a Xilinx Spartan3-1000:
--          Number of Slice Flip Flops:            67 out of  15,360    1%
--          Number of 4 input LUTs:               141 out of  15,360    1%
--          Average Fanout of Non-Clock Nets:    2.20
--
--##############################################################################

LIBRARY ieee;
  USE ieee.std_logic_1164.all;
  USE ieee.numeric_std.all;

ENTITY butterworth3 IS
  GENERIC(
    inputBitNb  : positive := 16;
    outputBitNb : positive := 16;
    shiftBitNb  : positive := 4
  );
  PORT(
    clock     : IN     std_ulogic;
    reset     : IN     std_ulogic;
    en        : IN     std_ulogic;
    filterIn  : IN     signed (inputBitNb-1 DOWNTO 0);
    filterOut : OUT    signed (outputBitNb-1 DOWNTO 0)
  );
END butterworth3;

--==============================================================================

ARCHITECTURE RTL OF butterworth3 IS

  constant filterOrder : natural := 3;
  type natural_vector_t is array(1 to filterOrder) of natural;
  constant t : natural_vector_t := (0, 1, 0);

  constant additionalinternalWBitNb: positive := 2;
  constant internalWBitNb: positive := filterOut'length + additionalinternalWBitNb;
  signal inputSignalScaled : signed(internalWBitNb-1 downto 0);

  constant internalaccumulatorBitNb : positive := internalWBitNb + shiftBitNb;
  type signed_vector_accumulator is array(1 to filterOrder)
    of signed(internalaccumulatorBitNb-1 downto 0);
  type signed_vector_w is array(0 to filterOrder+1)
    of signed(internalWBitNb-1 downto 0);
  signal accumulator : signed_vector_accumulator;
  signal w : signed_vector_w;

BEGIN
  ------------------------------------------------------------------------------
                          -- Scale input signal to internal state variables size
  inputSignalScaled <= SHIFT_LEFT(
    RESIZE(filterIn, inputSignalScaled'length),
    filterOut'length - filterIn'length
  );

  ------------------------------------------------------------------------------
                                                            -- Accumulator chain
  process(reset, clock)
  begin
    if reset = '1' then
      accumulator <= (others => (others => '0'));
    elsif rising_edge(clock) then
      if en = '1' then
        for index in 1 to filterOrder loop
          accumulator(index) <= accumulator(index) + (
            RESIZE(w(index-1), w(index)'length+1) -
            RESIZE(w(index+1), w(index)'length+1)
          );
        end loop;
      end if;
    end if;
  end process;

  ------------------------------------------------------------------------------
                                                -- Analog filter state variables
  process(accumulator, w, inputSignalScaled)
  begin
    for index in 1 to filterOrder loop
      w(index) <= RESIZE(
        SHIFT_RIGHT(
          accumulator(index),
          t(index) + shiftBitNb
        ),
        w(index)'length
      );
    end loop;
                           -- w(0) combines input and w(1) for first accumulator
    w(0) <= inputSignalScaled - w(1);
            -- w(filterOrder+1) is a copy of w(filterOrder) for last accumulator
    w(filterOrder+1) <= w(filterOrder);
  end process;

  ------------------------------------------------------------------------------
                                    -- Scale last state variables to output size
  filterOut <= RESIZE(w(w'high), filterOut'length);

END ARCHITECTURE RTL;
