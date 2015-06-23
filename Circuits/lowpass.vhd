--##############################################################################
--
--  lowpass
--      generic all-pole lowpass filter
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
--      In order to define the filter function, the first lines of the
--      architecture have to be edited:
--          constant "filterOrder" obviously gives the filter order.
--          constant "coefficientBitNb" obviously gives the number of bits of
--              the coefficients.
--          constant "coefficient" give the time constants as unsigned numbers
--              ranging from 1 to (2**coefficientBitNb)-1. The relative values
--              of the coefficients give the shape of the transfer function.
--              The cutoff frequency is furthermore given by the "shiftBitNb"
--              generic.
--          constant "additionalInternalWBitNb" gives the number of additional
--              bits assigned to the internal signals corresponding to the state
--              variables of the analog filter. They are used to avoid overflows
--              on these signals.
--      The values for "shiftBitNb" and "constant additionalInternalWBitNb" can
--      be dertermined analytically, but a frequency sweep simulation allows to
--      set them iteratively.
--
--      The input samples are read from the signal "filterIn" at the rising edge
--      of "clock" when "en" is '1'.
--
--      With this, a new output sample is calculated and provided on
--      "filterOut". The output changes at the end of the iterative calculation
--      of the multiplication, which is roughly n clock periods after "en"
--      was '1'. The number of clock periods, n, is equal to the number of bits
--      of the coefficients. The output sample remains stable until the next
--      sample has been calculated.
--
--      The "reset" signal is active high.
--
--------------------------------------------------------------------------------
--
--  Synthesis results
--
--      A 3rd order filter with 16 bit input, 16 bit output and 4 bit shift
--      gives the following synthesis result on a Xilinx Spartan3-1000:
--          Number of Slice Flip Flops:           162 out of  15,360    1%
--          Number of 4 input LUTs:               282 out of  15,360    1%
--          Average Fanout of Non-Clock Nets:    2.73
--
--      A 6th order filter with 16 bit input, 16 bit output and 4 bit shift
--      gives the following synthesis result on a Xilinx Spartan3-1000:
--          Number of Slice Flip Flops:           333 out of  15,360    2%
--          Number of 4 input LUTs:               604 out of  15,360    3%
--          Average Fanout of Non-Clock Nets:    2.81
--
--##############################################################################

LIBRARY ieee;
  USE ieee.std_logic_1164.all;
  USE ieee.numeric_std.all;

ENTITY lowpass IS
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
END butterworth3 ;

--==============================================================================

ARCHITECTURE RTL OF lowpass IS

-- 3rd order Butterworth
--
--  constant filterOrder : natural := 3;
--  constant coefficientBitNb : natural := 8;
--  type unsigned_vector_c is array(1 to filterOrder)
--    of unsigned(coefficientBitNb-1 downto 0);
--  constant coefficient : unsigned_vector_c := (
--    to_unsigned(2**7, coefficientBitNb),
--    to_unsigned(2**6, coefficientBitNb),
--    to_unsigned(2**7, coefficientBitNb)
--  );
--  constant additionalInternalWBitNb: positive := 2;

-- 6th order Bessel
--
  constant filterOrder : natural := 6;
  constant coefficientBitNb : natural := 8;
  type unsigned_vector_c is array(1 to filterOrder)
    of unsigned(coefficientBitNb-1 downto 0);
  constant coefficient : unsigned_vector_c := (
    to_unsigned(215, coefficientBitNb),
    to_unsigned( 88, coefficientBitNb),
    to_unsigned( 81, coefficientBitNb),
    to_unsigned( 61, coefficientBitNb),
    to_unsigned( 38, coefficientBitNb),
    to_unsigned( 13, coefficientBitNb)
  );
  constant additionalInternalWBitNb: positive := 4;

  constant internalWBitNb: positive := filterOut'length + additionalInternalWBitNb;
  signal inputSignalScaled : signed(internalWBitNb-1 downto 0);

  constant internalAccumulatorBitNb : positive := internalWBitNb + shiftBitNb;
  type signed_vector_accumulator is array(1 to filterOrder)
    of signed(internalAccumulatorBitNb-1 downto 0);
  type signed_vector_w is array(0 to filterOrder+1)
    of signed(internalWBitNb-1 downto 0);
  signal accumulator : signed_vector_accumulator;
  signal w : signed_vector_w;

  type unsigned_vector_coeffShiftReg is array(1 to filterOrder)
    of unsigned(coefficientBitNb-1 downto 0);
  signal coefficientShiftRegister: unsigned_vector_coeffShiftReg;
  signal multiplicandBit: std_ulogic_vector(1 to filterOrder);
  type signed_vector_multAcc is array(1 to filterOrder)
    of signed(internalAccumulatorBitNb+coefficientBitNb-1 downto 0);
  signal multiplicationAccumulator: signed_vector_multAcc;

  signal cycleCounterShiftReg: unsigned(coefficientBitNb downto 0);
  signal endOfCycle: std_ulogic;
  signal calculating: std_ulogic;

  signal wDebug : signed_vector_w;

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
                                                      -- Multiplication sequence

                                                            -- Coefficient shift
  process(reset, clock)
  begin
    if reset = '1' then
      coefficientShiftregister <= (others => (others => '0'));
    elsif rising_edge(clock) then
      for index in 1 to filterOrder loop
        if en = '1' then
          coefficientShiftregister(index) <= coefficient(index);
        else
          coefficientShiftregister(index) <=
            shift_right(coefficientShiftregister(index), 1);
        end if;
      end loop;
    end if;
  end process;

  process(coefficientShiftregister)
  begin
    for index in 1 to filterOrder loop
      multiplicandBit(index) <= coefficientShiftregister(index)(0);
    end loop;
  end process;

                                                 -- Multiplication accumulator
  process(reset, clock)
  begin
    if reset = '1' then
      multiplicationAccumulator <= (others => (others => '0'));
    elsif rising_edge(clock) then
      for index in 1 to filterOrder loop
        if en = '1' then
          multiplicationAccumulator(index) <= (others => '0');
        elsif calculating = '1' then
          if multiplicandBit(index) = '0' then
            multiplicationAccumulator(index) <=
              shift_right(multiplicationAccumulator(index), 1);
          else
            multiplicationAccumulator(index) <=
              shift_right(multiplicationAccumulator(index), 1) +
              shift_left(
                resize(accumulator(index), multiplicationAccumulator(index)'length),
                coefficientBitNb
              );
          end if;
        end if;
      end loop;
    end if;
  end process;

  ------------------------------------------------------------------------------
                                                -- Analog filter state variables
  process(multiplicationAccumulator, w, inputSignalScaled)
  begin
    for index in 1 to filterOrder loop
      w(index) <= RESIZE(
        SHIFT_RIGHT(
          multiplicationAccumulator(index),
          coefficientBitNb + shiftBitNb
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
                          -- Scale last state variables to output size and latch
  process(reset, clock)
  begin
    if reset = '1' then
      filterOut <= (others => '0');
    elsif rising_edge(clock) then
      if calculating = '0' then
        filterOut <= RESIZE(w(w'high), filterOut'length);
      end if;
    end if;
  end process;

  ------------------------------------------------------------------------------
                                                 -- Multiplication cycle counter
  process(reset, clock)
  begin
    if reset = '1' then
      cycleCounterShiftReg <= (others => '0');
    elsif rising_edge(clock) then
      cycleCounterShiftReg <= shift_right(cycleCounterShiftReg, 1);
      cycleCounterShiftReg(cycleCounterShiftReg'high) <= en;
    end if;
  end process;

  endOfCycle <= cycleCounterShiftReg(0);
  calculating <= '1' when cycleCounterShiftReg /= 0
    else '0';

  ------------------------------------------------------------------------------
                                                            -- Debug information
  process(reset, clock)
  begin
    if reset = '1' then
      wDebug <= (others => (others => '0'));
    elsif rising_edge(clock) then
      for index in 1 to filterOrder loop
        if calculating = '0' then
          wDebug <= w;
        end if;
      end loop;
    end if;
  end process;

END ARCHITECTURE RTL;
