------------------------------------------------------------------------------
-- Project    : openFPU64 - Testbench for Avalon Bus
-------------------------------------------------------------------------------
-- File       : openfpu64_tb.vhd
-- Author     : Peter Huewe  <peterhuewe@gmx.de>
-- Created    : 2010-04-19
-- Last update: 2010-04-19
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: Testbench for openFPU64, Avalon Bus interface.
-- 
-------------------------------------------------------------------------------
-- Copyright (c) 2010 
-------------------------------------------------------------------------------
-- License: gplv3, see licence.txt
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.helpers.all;
use work.fpu_package.all;
-------------------------------------------------------------------------------

entity openFPU64_tb is

end openFPU64_tb;

-------------------------------------------------------------------------------

architecture openFPU64_tb of openFPU64_tb is

  component openFPU64
    port (
      reset_n       : in  std_logic                     := '0';
      read          : in  std_logic                     := '0';
      write         : in  std_logic                     := '1';
      address       : in  std_logic_vector (4 downto 0) := (others => '0');
      readdata      : out std_logic_vector(31 downto 0) := (others => '0');
      writedata     : in  std_logic_vector(31 downto 0) := (others => '0');
      waitrequest   : out std_logic                     := '0';
      begintransfer : in  std_logic                     := '0';
      --   out_port      : out std_logic_vector(9 downto 0);
      clk           : in  std_logic                     := '0');
  end component;

  -- component ports
  signal reset_n   : std_logic                     := '0';
  signal read      : std_logic                     := '0';
  signal write     : std_logic                     := '1';
  signal address   : std_logic_vector (4 downto 0) := (others => '0');
  signal readdata  : std_logic_vector(31 downto 0) := (others => '0');
  signal writedata : std_logic_vector(31 downto 0) := (others => '0');
--    signal data_in_a : std_logic_vector(63 downto 0) :=  x"AFAFAFAFEFEFEFEF";
--   signal data_in_b : std_logic_vector(63 downto 0) :=  x"BFBFBFBFCFCFCFCF";
  signal data_in_a : std_logic_vector(63 downto 0) := "0011111111110000000000000000000000000000000000000000000000000000";
  signal data_in_b : std_logic_vector(63 downto 0) := "0100000000000000000000000000000000000000000000000000000000000000";


  signal data_out      : std_logic_vector(63 downto 0);
  signal readback      : std_logic_vector(31 downto 0) := (others => '0');
  signal waitrequest   : std_logic                     := '0';
  signal begintransfer : std_logic                     := '0';
  signal clk           : std_logic                     := '0';
  signal out_port      : std_logic_vector(9 downto 0);
  -- clock
  -- signal Clk : std_logic := '1';
  constant clk_period  : time                          := 10 ns;
  constant mem_delay   : time                          := 10 ns;
begin  -- openFPU64_tb

  -- component instantiation
  DUT : openFPU64
    port map (
      reset_n       => reset_n,
      read          => read,
      write         => write,
      address       => address,
      readdata      => readdata,
      writedata     => writedata,
      waitrequest   => waitrequest,
      begintransfer => begintransfer,
      clk           => clk);

  -- clock generation



  -- waveform generation
  tb : process
    procedure run_cycle
      (
        count : inout integer           -- cycle count for statistical purposes
        )
    is
    begin
      clk   <= '0';
      wait for clk_period / 2;
      clk   <= '1';
      wait for clk_period / 2;
      count := count+1;
    end procedure;

  procedure testcase
    (
      number    : in integer;           -- Testcase number, will be reported
      operand_a : in std_logic_vector(63 downto 0);   -- first operand
      operand_b : in std_logic_vector (63 downto 0);  -- second operand
      expected  : in std_logic_vector(63 downto 0);   -- expected result
      operation : in std_logic_vector (2 downto 0)    -- desired operation
      )
  is
    variable i           : integer;
    variable denormalA_n : std_logic;
    variable denormalB_n : std_logic;
  begin
    i :=0;




    -- reset the fpu
    begintransfer <= '0';
    reset_n       <= '0';
    run_cycle(i);
    reset_n       <= '1';
    run_cycle(i);
    -- begin transfer of first 32bit (MSB..) of first operand
    -- and specify operation (encoded in address, see fpu_package.vhd for details
    write         <= '1';
    begintransfer <= '1';
    writedata     <= operand_a(63 downto 32);
    address       <= operation & addr_a_hi;
    run_cycle(i);
    begintransfer <= '0';               --all other signals irrelevant/unstable
    run_cycle(i);

-- begin transfer of second 32bits (..LSB) of first operand
    write         <= '1';
    begintransfer <= '1';
    address       <= operation& addr_a_lo;
    writedata     <= operand_a(31 downto 0);
    run_cycle(i);
    begintransfer <= '0';
    run_cycle(i);

    -- begin transfer of first 32bits (MSB..) of second operand
    write         <= '1';
    address       <= operation& addr_b_hi;
    writedata     <= operand_b(63 downto 32);
    begintransfer <= '1';
    run_cycle(i);
    begintransfer <= '0';
    run_cycle(i);

    -- begin transfer of second 32bits (..LSB) of second operand
    address       <= operation& addr_b_lo;
    writedata     <= operand_b(31 downto 0);
    begintransfer <= '1';
    run_cycle(i);
    begintransfer <= '0';
    write         <= '0';
    run_cycle(i);

-- begin reading first 32bits of result
-- blocking read, all signals have to remain stable until waitrequest is deasserted
    read          <= '1';
    begintransfer <= '1';
    address       <= operation & addr_result_hi;
    run_cycle(i);
    begintransfer <= '0';
    L : while waitrequest = '1' loop
      run_cycle(i);
    end loop;
    data_out(63 downto 32) <= readdata;
    run_cycle(i);

    -- begin reading second 32bits of result
    -- blocking read, all signals have to remain stable until waitrequest is deasserted
    -- in practice waitrequest is already deasserted.
    read          <= '1';
    begintransfer <= '1';
    address       <= operation & addr_result_lo;
    run_cycle(i);
    begintransfer <= '0';
    K :while waitrequest = '1' loop
      run_cycle(i);
    end loop;
    data_out(31 downto 0) <= readdata;
    run_cycle(i);
-- Bus transfers complete

-- compare actual result with expected result
	if data_out /= expected
	then
	-- check if the _both_ expected and actual result is NaN,
	-- if this is the case don't check the sign - NaNs don't have a sign
	-- without this check false positives will be generated for NaNs with different signs.
		if data_out(62 downto 52) = expected(62 downto 52)
		and data_out(51 downto 0) = expected(51 downto 0)
		and data_out(62 downto 52) = std_logic_vector(ONES(62 downto 52))
		and data_out(51 downto 0) /= std_logic_vector(ZEROS(51 downto 0))
		then
			if DEBUG_MODE = '1' then -- if we are in DEBUG_MODE,print out the result anyway
				assert false report "NaN:"&integer'image(number)&" result was"&
				" S:"&std_logic'image(data_out(63)) &
				" E:"&to_string(data_out(62 downto 52)) &
				" M:"&to_string(data_out(51 downto 0)) &
				" expected" &
				" S:"&std_logic'image(expected(63)) &
				" E:"&to_string(expected(62 downto 52)) &
				" M:"&to_string(expected(51 downto 0)) severity error;
			end if;
		else
		-- if we reach here, we have a real error - printout the actual and the expected result
			assert false report "doh "&integer'image(number)&" result was"&
			" S:"&std_logic'image(data_out(63)) &
			" E:"&to_string(data_out(62 downto 52)) &
			" M:"&to_string(data_out(51 downto 0)) &
			" expected" &
			" S:"&std_logic'image(expected(63)) &
			" E:"&to_string(expected(62 downto 52)) &
			" M:"&to_string(expected(51 downto 0)) severity error;
		end if;
	end if;
-- print out statistics
    assert false report "Testcases "&integer'image(number)&" needed " &integer'image(i) &" cycles" severity note;
  end procedure;
  variable i : integer;
  begin
