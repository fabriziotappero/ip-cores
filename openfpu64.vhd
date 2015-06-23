-------------------------------------------------------------------------------
-- Project    : openFPU64 - a double precision FPU (Toplevel Modul for Avalon)
-------------------------------------------------------------------------------
-- File       : openfpu64.vhd
-- Author     : Peter Huewe  <peterhuewe@gmx.de>
-- Created    : 2010-02-09
-- Last update: 2010-04-19
-- Platform   : CycloneII, CycloneIII.
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: This module contains the bus logic for the Avalon Interface of 
--              the openFPU64.
--              the openFPU64 currently features: 
--                    - double precision
--                    - Addition/Subtraction
--                    - Multiplication
--                    - rounding (to nearest even)
--                    - subnormals/denormals
--                    - verified against IEEE754
--              New algorithms can be added easily, just modify the code marked 
--                    with ADD_ALGORITHMS_HERE
--              Everything marked with FUTURE is not yet implemented, 
--                    but already added for easier transition.
-------------------------------------------------------------------------------
-- Copyright (c) 2010 
-------------------------------------------------------------------------------
-- Licence: gpl v3 - see licence.txt
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.fpu_package.all;               -- contains import defines.

-------------------------------------------------------------------------------

entity openFPU64 is
  port(
    reset_n : in std_logic := '0';      -- reset, active low
    read    : in std_logic := '0';      -- indicates a read transfer (from fpu)
    write   : in std_logic := '1';      -- indicates a write tranfer (to fpu)

    -- address register, specifies where data comes from or is written to, #
    -- and also contains the desired operation while writing first operands high word
    -- see constants in fpu_package for more details
    address : in std_logic_vector (4 downto 0) := (others => '0');

    --readdata result (FUTURE: and exceptions), transfers hi and low words in 2 cycles
    readdata  : out std_logic_vector(31 downto 0) := (others => '0');
    writedata : in  std_logic_vector(31 downto 0) := (others => '0');  --operands and operator,2 cycles

    -- this signal indicates whether slave is stilly busy. When signal is asserted, bus signals have to remain stable
    -- CAUTION: Master may initiate a transfer though!
    waitrequest   : out std_logic := '0';
    begintransfer : in  std_logic := '0';  -- Master initiates a new transfer
    clk           : in  std_logic := '0'   -- clock
    );
end openFPU64;

-------------------------------------------------------------------------------

architecture rtl of openFPU64 is
  -----------------------------------------------------------------------------
  -- Internal signal declarations
  -----------------------------------------------------------------------------
  -- Internal Floating Point format S eEEE EEEE EEEE bOhM....MRGt
  -- S Sign bit 
  -- e xtra Exponent bit        (12)
  -- E biased exponent          (11 downto 0)
  -- b borrow for Subtraction   (57)
  -- O Overflow                 (56)
  -- h Hiddenbit                (55)
  -- M Mantissa bits            (54 downto 3)
  -- R Round bit                (2)
  -- G Guard bit                (1)
  -- t Sticky bit               (0)


  signal sign_a, sign_b                       : std_logic;  -- signs of first/second operand
  signal exponent_a, exponent_b               : std_logic_vector (11 downto 0);  -- exponents of first/second operand
  signal mantissa_a, mantissa_b               : std_logic_vector (57 downto 0);  -- mantissas of first/second operand
  signal iwaitrequest                         : std_logic;  -- internal signal waitrequest, is connected to waitrequest.
  signal started                              : std_logic;  -- calculation can begin
  signal rounding_needed_1, rounding_needed_2 : std_logic;  -- FUTURE signal which indicates if rounding is necessary.

  signal opmode     : std_logic_vector (2 downto 0);  -- keeps value of operation.
  -- The operation is encoded in the address, for better readability we define two aliases to split the
  -- register address from the desired operation
  alias operation   : std_logic_vector (2 downto 0) is address(4 downto 2);  -- desired operation -> fpu_package.vhd
  alias op_register : std_logic_vector (1 downto 0) is address (1 downto 0);  -- register address of operand


  -- the next few signals are used for connecting components,
  -- if you like to add your own algorithm, please specify the necessary signals here,
  -- and document their usage.
  -- Notes: Add/Sub are one component, so some signals are shared.
  --         By using this technique a tristate bus for the components is avoided
-- ADD_ALGORITHMS_HERE --
  signal mode_1                         : std_logic;  -- ADD/SUB, switches between Addition ('0') and Subtraction ('1')
  signal cs_1, cs_2                     : std_logic;  -- chip select for each operation
  signal valid_1, valid_2               : std_logic;  -- operation asserts this if it has finished its calculation
  signal sign_res_1, sign_res_2         : std_logic;  -- sign of result for each operation.
  signal exponent_res_1, exponent_res_2 : std_logic_vector (11 downto 0);  -- exponent of result for each operation
  signal mantissa_res_1, mantissa_res_2 : std_logic_vector(57 downto 0);  -- mantissa of result, for each operation
-- ADD_ALGORITHMS_HERE_END--


  -----------------------------------------------------------------------------
  -- Component declarations
  -----------------------------------------------------------------------------

  -- Add/Sub component, reset active low
  component fpu_add
    port (
      -- input operands
      sign_a, sign_b         : in  std_logic;
      exponent_a, exponent_b : in  std_logic_vector (11 downto 0);
      mantissa_a, mantissa_b : in  std_logic_vector (57 downto 0);
      -- output result
      sign_res               : out std_logic;
      exponent_res           : out std_logic_vector(11 downto 0);
      mantissa_res           : out std_logic_vector (57 downto 0);
      -- misc signals
      rounding_needed        : out std_logic;   -- FUTURE
      mode                   : in  std_logic;   -- Switch mode Add=0 Sub=1
      cs                     : in  std_logic;   -- Chip Select
      valid                  : out std_logic;   -- calculation is finished
      clk                    : in  std_logic;   -- Clock
      reset_n                : in  std_logic);  -- reset active low
  end component;

  -- Multiplication unit
  -- FUTURE: can be replaced by other implementations of Multiplication,
  --     e.g. one that uses only one embedded Multiplier, see fpu_mul_single.vhd
  --     Interface should remain stable for all implementations
  component fpu_mul
    port (
      -- input operands
      sign_a, sign_b         : in  std_logic;
      exponent_a, exponent_b : in  std_logic_vector (11 downto 0);
      mantissa_a, mantissa_b : in  std_logic_vector (57 downto 0);
      -- output results
      sign_res               : out std_logic;
      exponent_res           : out std_logic_vector(11 downto 0);
      mantissa_res           : out std_logic_vector (57 downto 0);
-- misc signals
      rounding_needed        : out std_logic;   -- FUTURE
      valid                  : out std_logic;   -- calculation is finished
      cs                     : in  std_logic;   -- Chip Select
      clk                    : in  std_logic;   -- Clock
      reset_n                : in  std_logic);  -- Reset active low
  end component;


-----------------------------------------------------------------------------
-- Component instantiations
-- connect everything
-----------------------------------------------------------------------------
begin
  fpu_addsub_1 : fpu_add
    port map (
      sign_a          => sign_a,
      sign_b          => sign_b,
      exponent_a      => exponent_a,
      exponent_b      => exponent_b,
      mantissa_a      => mantissa_a,
      mantissa_b      => mantissa_b,
      sign_res        => sign_res_1,
      exponent_res    => exponent_res_1,
      mantissa_res    => mantissa_res_1,
      rounding_needed => rounding_needed_1,
      mode            => mode_1,
      cs              => cs_1,
      valid           => valid_1,
      clk             => clk,
      reset_n         => reset_n);

  fpu_mul_1 : fpu_mul
    port map (
      clk             => clk,
      reset_n         => reset_n,
      cs              => cs_2,
      sign_a          => sign_a,
      sign_b          => sign_b,
      exponent_a      => exponent_a,
      exponent_b      => exponent_b,
      mantissa_a      => mantissa_a,
      mantissa_b      => mantissa_b,
      sign_res        => sign_res_2,
      exponent_res    => exponent_res_2,
      mantissa_res    => mantissa_res_2,
      rounding_needed => rounding_needed_2,
      valid           => valid_2);

-- purpose: Implements the Avalon logic and transfers data from/to submodules
-- inputs : clk, reset_n,read, write, address, writedata, begintransfer
-- outputs: readdata, waitrequest
-- Note: Process is not coded using states on purpose in order to prevent 
--         lockups in case of bus resets or undefined accesses
  avalon_bus_logic : process (clk, reset_n)
  begin
    if reset_n = '0' then  -- active low, switch of subcomponents, reset everything
      cs_1         <= '0';
      cs_2         <= '0';
      iwaitrequest <= '0';
      started      <= '0';
      opmode       <= (others => '0');
      mantissa_a   <= (others => '0');
      mantissa_b   <= (others => '0');
      exponent_a   <= (others => '0');
      exponent_b   <= (others => '0');
      sign_a       <= '0';
      sign_b       <= '0';
      readdata     <= x"AAAAC0C0";
    elsif rising_edge(clk) then
      waitrequest <= iwaitrequest;
      cs_1        <= cs_1;
      cs_2        <= cs_2;
      opmode      <= opmode;
      mantissa_a  <= mantissa_a;
      mantissa_b  <= mantissa_b;
      exponent_a  <= exponent_a;
      exponent_b  <= exponent_b;
      sign_a      <= sign_a;
      sign_b      <= sign_b;

      -- Dummy value which indicates wrong reads, deadbeef was already taken
      readdata <= x"AAAAC0C0";
      started  <= started;

      if started = '0'  -- calculation is in progress, keep signals
      then
        iwaitrequest <= '0';
      else
        iwaitrequest <= '1';
      end if;

      if begintransfer = '1' and write = '1' then  -- new write transfert
        case op_register is
          -- hi word is written, populate first operand and set opmode to desired operation
          when addr_a_hi =>
            sign_a     <= writedata(31);
            exponent_a <= '0' & writedata(30 downto 20);
            -- check for denormals, if not, set _h_idden bit in internal format.
            if unsigned(writedata(30 downto 20)) = ZEROS(30 downto 20) then
              mantissa_a(57 downto 35) <= "000" & writedata(19 downto 0);
            else
              mantissa_a(57 downto 35) <= "001" & writedata(19 downto 0);
            end if;
            opmode <= operation;

          -- lo word is written, populate rest of mantissa with clear RGS
          when addr_a_lo =>
            mantissa_a(34 downto 0) <= writedata(31 downto 0) & "000";

          -- hi word of second operand, populate fields  
          when addr_b_hi =>
            sign_b     <= writedata(31);
            exponent_b <= '0' & writedata(30 downto 20);
            -- check for denormals, if not, set _h_idden bit in internal format.
            if unsigned(writedata(30 downto 20)) = ZEROS(30 downto 20) then
              mantissa_b(57 downto 35) <= "000" & writedata(19 downto 0);
            else
              mantissa_b(57 downto 35) <= "001" & writedata(19 downto 0);
            end if;


          -- lo word is written, populate rest of mantissa with clear RGS
          -- after low word is written, calculation starts
          when addr_b_lo =>
            mantissa_b(34 downto 0) <= writedata(31 downto 0) & "000";
            -- perform calculation by enabling component
            case opmode is
              -- ADD_ALGORITHMS_HERE
              when mode_add =>
                cs_1   <= '1';
                mode_1 <= '0';
              when mode_sub =>
                cs_1   <= '1';
                mode_1 <= '1';
                opmode <= mode_add;  -- result will be read from same location
              when mode_mul =>
                cs_2 <= '1';
--                when mode_div =>  -- FUTURE not implemented yet 
--                 cs_3             <= '1'; -- FUTURE
              -- ADD_ALGORITHMS_HERE_END
              when others => null;
            end case;
            started <= '1';             -- calculation has started
          when others => null;
        end case;
      end if;

      -- results requested
      if read = '1' and started = '1' then
        if begintransfer = '1' then
          iwaitrequest <= '1';
          waitrequest  <= '1';
        end if;
        -- ADD_ALGORITHMS_HERE --
        -- if any of the operation returns with a valid result
        if valid_1 = '1' or valid_2 = '1' then
          -- ADD_ALGORITHMS_HERE_END--
          iwaitrequest <= '1';
          waitrequest  <= '0';

          -- read hi word of result
          if op_register = addr_result_hi then
            case opmode is
              -- ADD_ALGORITHMS_HERE --
              -- generate result, skip internal format bits.
              when mode_add => readdata <= sign_res_1 & exponent_res_1 (10 downto 0) & mantissa_res_1(54 downto 35);  -- ADD and SUB
              when mode_mul => readdata <= sign_res_2 & exponent_res_2 (10 downto 0) & mantissa_res_2(54 downto 35);
              --  when mode_div => readdata <= result_2(63 downto 32); -- not implemented yet
              -- ADD_ALGORITHMS_HERE_END--
              when others   => null;
            end case;

          -- read low word of result
          else                          -- op_register = add_result_lo
            case opmode is
              -- ADD_ALGORITHMS_HERE --
              when mode_add => readdata <= mantissa_res_1(34 downto 3);  -- ADD and SUB
              when mode_mul => readdata <= mantissa_res_2(34 downto 3);
              --  when mode_div => readdata <= result_2(31 downto 0); --Not implemented yet
              -- ADD_ALGORITHMS_HERE_END --
              when others   => null;
            end case;

            -- read is finished, return to "reset_state"
            -- ADD_ALGORITHMS_HERE --
            cs_1    <= '0';
            cs_2    <= '0';
            mode_1  <= '0';
            -- ADD_ALGORITHMS_HERE_END --
            started <= '0';
            opmode  <= (others => '0');
          end if;
        else
        end if;
      end if;
    end if;
  end process avalon_bus_logic;
end rtl;

-------------------------------------------------------------------------------
