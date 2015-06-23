-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity CRC_top is
  
  port (
    phi1    : in  std_logic;
                                        -- We will use the two phase discipline
                                        -- which we don't generate.
    phi2    : in  std_logic;
    reset   : in  std_logic;            -- #RESET
    input   : in  std_logic_vector(15 downto 0);
                                        -- The serial/parallel conversion has
                                        -- been made somewhere else
    fcs_out : out std_logic_vector(31 downto 0));
    -- "inout" because we have to read this value (feedback to the multiplier)

end CRC_top;

architecture structural of CRC_top is

  component input_wait
    port (
      reset  : in  std_logic;
      phi1   : in  std_logic;
      phi2   : in  std_logic;
      input  : in  std_logic_vector(15 downto 0);
      output : out std_logic_vector(15 downto 0));
  end component;

  component gf_multiplier
    port (
      reset      : in  std_logic;
      phi1       : in  std_logic;
      phi2       : in  std_logic;
      input      : in  std_logic_vector(31 downto 0);
      output_fcs : out std_logic_vector(15 downto 0);     -- LS Word
      -- "inout" since we have to read this value (feedback)
      output_xor : out std_logic_vector(15 downto 0));    -- MS Word
  end component;

  component big_xor
    port (
      reset       : in  std_logic;
      phi2        : in  std_logic;
      input_input : in  std_logic_vector(15 downto 0);
      fcs_input   : in  std_logic_vector(15 downto 0);
      gf_input    : in  std_logic_vector(15 downto 0);
      output      : out std_logic_vector(31 downto 0));
  end component;

  component ff_reset is
    port (
      phi2         : in  std_logic;
      reset_glitch : in  std_logic;
      reset_clean  : out std_logic);
  end component;

  signal wait_intermediate : std_logic_vector(15 downto 0);  
  -- Connects the input_wait component with the big_xor one
  signal fcs_intermediate : std_logic_vector(15 downto 0);  
  -- Connects the multiplier with the output register
  signal xor_intermediate : std_logic_vector(15 downto 0);  
  -- Connects the multiplier with the final XOR
  signal fcs_out_read : std_logic_vector (31 downto 0);
  -- This signal will avoid the use of "inout" ports
  signal reset_intermediate : std_logic;
  -- Clean reset to feed the whole circuit

begin 

  ff_reset_1 : ff_reset port map (phi2 => phi2, reset_glitch => reset,
                                  reset_clean => reset_intermediate);

  input_wait_1 : input_wait port map (reset => reset_intermediate, phi1 => phi1, 
                                      phi2 => phi2, input  => input, 
                                      output => wait_intermediate);

  gf_multiplier_1 : gf_multiplier port map (reset => reset_intermediate,
                                            phi1 => phi1, phi2=> phi2,
                                            input => fcs_out_read,
                                            output_xor => xor_intermediate,
                                            output_fcs => fcs_intermediate);

  big_xor_1 : big_xor port map (reset => reset_intermediate, phi2 => phi2,
                                input_input => wait_intermediate,
                                fcs_input   => fcs_intermediate,
                                gf_input    => xor_intermediate,
				output      => fcs_out_read);
  
  fcs_out <= fcs_out_read;

end structural;

configuration cfg_CRC_top_structural of CRC_top is

  for structural
    for input_wait_1 : input_wait use entity work.input_wait(structural); end for;
    for gf_multiplier_1 : gf_multiplier use entity work.gf_multiplier(structural); end for;
    for big_xor_1 : big_xor use entity work.big_xor(behavior); end for;
    for ff_reset_1 : ff_reset use entity work.ff_reset(behavior); end for;
  end for;

end cfg_CRC_top_structural;
