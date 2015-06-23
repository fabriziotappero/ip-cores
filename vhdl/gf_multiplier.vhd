library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.all;

entity gf_multiplier is
  
  port (
    reset  : in  std_logic;             -- #RESET
    phi1   : in  std_logic;
    phi2   : in  std_logic;
    input  : in  std_logic_vector(31 downto 0);
                                        -- Input to the Galois Field multiplier. It
                                        -- comes from the feedback of the FCS
    output_fcs : out std_logic_vector(15 downto 0);  -- LS Word 
    -- "inout" to be able to read the signal (feedback)
    output_xor : out std_logic_vector(15 downto 0));   -- MS Word
  
end gf_multiplier;



architecture structural of gf_multiplier is

  -- The output register is half the size of the rest
  component gf_phi1_register_out
    port (
      reset        : in  std_logic;           -- #RESET
      phi1         : in  std_logic;           -- Clock
      input_wip    : in  std_logic_vector(31 downto 0);
      output_final : out std_logic_vector(31 downto 0));
  end component;

  -- These components below are the best example of bad VHDL coding

  component gf_phi1_register_2
    port (
      reset      : in  std_logic;                      -- #RESET
      phi1       : in  std_logic;                      -- Clock
      input_wip  : in  std_logic_vector(31 downto 0);  -- The incoming WIP
      input_fcs  : in  std_logic_vector(31 downto 0);
                    -- The original data for that step. Since we are using pipelining
                    -- we have to grant that we will have the original FCS data
                    -- available.
      output_wip : out std_logic_vector(31 downto 0);
                    -- The modified data -our "WIP"-
      output_fcs : out std_logic_vector(31 downto 0));
                    -- The original data is kept untouched
  end component;

  component gf_phi2_register_3
    port (
      reset      : in  std_logic;                      -- #RESET
      phi2       : in  std_logic;                      -- Clock
      input_wip  : in  std_logic_vector(31 downto 0);  -- The incoming WIP
      input_fcs  : in  std_logic_vector(31 downto 0);
                    -- The original data for that step. Since we are using pipelining
                    -- we have to grant that we will have the original FCS data
                    -- available.
      output_wip : out std_logic_vector(31 downto 0);
                    -- The modified data -our "WIP"-
      output_fcs : out std_logic_vector(31 downto 0));
                    -- The original data is kept untouched
  end component;

  component gf_phi1_register_4
    port (
      reset      : in  std_logic;                      -- #RESET
      phi1       : in  std_logic;                      -- Clock
      input_wip  : in  std_logic_vector(31 downto 0);  -- The incoming WIP
      input_fcs  : in  std_logic_vector(31 downto 0);
                    -- The original data for that step. Since we are using pipelining
                    -- we have to grant that we will have the original FCS data
                    -- available.
      output_wip : out std_logic_vector(31 downto 0);
                    -- The modified data -our "WIP"-
      output_fcs : out std_logic_vector(31 downto 0));
                    -- The original data is kept untouched
  end component;

  component gf_phi2_register_5
    port (
      reset      : in  std_logic;                      -- #RESET
      phi2       : in  std_logic;                      -- Clock
      input_wip  : in  std_logic_vector(31 downto 0);  -- The incoming WIP
      input_fcs  : in  std_logic_vector(31 downto 0);
                    -- The original data for that step. Since we are using pipelining
                    -- we have to grant that we will have the original FCS data
                    -- available.
      output_wip : out std_logic_vector(31 downto 0);
                    -- The modified data -our "WIP"-
      output_fcs : out std_logic_vector(31 downto 0));
                    -- The original data is kept untouched
  end component;

  component gf_phi1_register_6
    port (
      reset      : in  std_logic;                      -- #RESET
      phi1       : in  std_logic;                      -- Clock
      input_wip  : in  std_logic_vector(31 downto 0);  -- The incoming WIP
      input_fcs  : in  std_logic_vector(31 downto 0);
                    -- The original data for that step. Since we are using pipelining
                    -- we have to grant that we will have the original FCS data
                    -- available.
      output_wip : out std_logic_vector(31 downto 0);
                    -- The modified data -our "WIP"-
      output_fcs : out std_logic_vector(31 downto 0));
                    -- The original data is kept untouched
  end component;

  component gf_phi2_register_7
    port (
      reset      : in  std_logic;                      -- #RESET
      phi2       : in  std_logic;                      -- Clock
      input_wip  : in  std_logic_vector(31 downto 0);  -- The incoming WIP
      input_fcs  : in  std_logic_vector(31 downto 0);
                    -- The original data for that step. Since we are using pipelining
                    -- we have to grant that we will have the original FCS data
                    -- available.
      output_wip : out std_logic_vector(31 downto 0);
                    -- The modified data -our "WIP"-
      output_fcs : out std_logic_vector(31 downto 0));
                    -- The original data is kept untouched
  end component;

  component gf_phi1_register_8
    port (
      reset      : in  std_logic;                      -- #RESET
      phi1       : in  std_logic;                      -- Clock
      input_wip  : in  std_logic_vector(31 downto 0);  -- The incoming WIP
      input_fcs  : in  std_logic_vector(31 downto 0);
                    -- The original data for that step. Since we are using pipelining
                    -- we have to grant that we will have the original FCS data
                    -- available.
      output_wip : out std_logic_vector(31 downto 0);
                    -- The modified data -our "WIP"-
      output_fcs : out std_logic_vector(31 downto 0));
                    -- The original data is kept untouched
  end component;

  component gf_phi2_register_9
    port (
      reset      : in  std_logic;                      -- #RESET
      phi2       : in  std_logic;                      -- Clock
      input_wip  : in  std_logic_vector(31 downto 0);  -- The incoming WIP
      input_fcs  : in  std_logic_vector(31 downto 0);
                    -- The original data for that step. Since we are using pipelining
                    -- we have to grant that we will have the original FCS data
                    -- available.
      output_wip : out std_logic_vector(31 downto 0);
                    -- The modified data -our "WIP"-
      output_fcs : out std_logic_vector(31 downto 0));
                    -- The original data is kept untouched
  end component;

  -- These components below are the best example of bad VHDL coding
  
  component gf_xor_2x
    port (
      input_wip  : in  std_logic_vector(31 downto 0);
      input_fcs  : in  std_logic_vector(31 downto 0);
      output_wip : out  std_logic_vector(31 downto 0));
  end component;

  component gf_xor_3x
    port (
      input_wip  : in  std_logic_vector(31 downto 0);
      input_fcs  : in  std_logic_vector(31 downto 0);
      output_wip : out  std_logic_vector(31 downto 0));
  end component;

  component gf_xor_4x
    port (
      input_wip  : in  std_logic_vector(31 downto 0);
      input_fcs  : in  std_logic_vector(31 downto 0);
      output_wip : out  std_logic_vector(31 downto 0));
  end component;

  component gf_xor_5x
    port (
      input_wip  : in  std_logic_vector(31 downto 0);
      input_fcs  : in  std_logic_vector(31 downto 0);
      output_wip : out  std_logic_vector(31 downto 0));
  end component;

  component gf_xor_6x
    port (
      input_wip  : in  std_logic_vector(31 downto 0);
      input_fcs  : in  std_logic_vector(31 downto 0);
      output_wip : out  std_logic_vector(31 downto 0));
  end component;

  component gf_xor_7x
    port (
      input_wip  : in  std_logic_vector(31 downto 0);
      input_fcs  : in  std_logic_vector(31 downto 0);
      output_wip : out  std_logic_vector(31 downto 0));
  end component;

  component gf_xor_8x
    port (
      input_wip  : in  std_logic_vector(31 downto 0);
      input_fcs  : in  std_logic_vector(31 downto 0);
      output_wip : out  std_logic_vector(31 downto 0));
  end component;

  component gf_xor_9x
    port (
      input_wip  : in  std_logic_vector(31 downto 0);
      input_fcs  : in  std_logic_vector(31 downto 0);
      output_wip : out  std_logic_vector(31 downto 0));
  end component;

--  component gf_xor_10x
--    port (
--      input_wip  : in  std_logic_vector(31 downto 0);
--      input_fcs  : in  std_logic_vector(31 downto 0);
--      output_wip : out  std_logic_vector(31 downto 0));
--  end component;


  -- The XOR right after the input is smaller
  component gf_xor_input
    port (
      input_fcs  : in  std_logic_vector(31 downto 0);
      output_wip : out std_logic_vector(31 downto 0));
  end component;

  -- We now declare all the signals needed to comunicate the
  -- different components
  signal btw2_3   : std_logic_vector(31 downto 0);  -- Original data
  signal btw3_4   : std_logic_vector(31 downto 0);  -- Original data
  signal btw4_5   : std_logic_vector(31 downto 0);  -- Original data
  signal btw5_6   : std_logic_vector(31 downto 0);  -- Original data
  signal btw6_7   : std_logic_vector(31 downto 0);  -- Original data
  signal btw7_8   : std_logic_vector(31 downto 0);  -- Original data
  signal btw8_9   : std_logic_vector(31 downto 0);  -- Original data
  signal btw9_10  : std_logic_vector(31 downto 0);  -- Original data
--  signal btw10_11 : std_logic_vector(31 downto 0);  -- Original data

  signal btw1x_2   : std_logic_vector(31 downto 0);  -- WIP data
  signal btw2_2x   : std_logic_vector(31 downto 0);  -- WIP data
  signal btw2x_3   : std_logic_vector(31 downto 0);  -- WIP data
  signal btw3_3x   : std_logic_vector(31 downto 0);  -- WIP data
  signal btw3x_4   : std_logic_vector(31 downto 0);  -- WIP data
  signal btw4_4x   : std_logic_vector(31 downto 0);  -- WIP data
  signal btw4x_5   : std_logic_vector(31 downto 0);  -- WIP data
  signal btw5_5x   : std_logic_vector(31 downto 0);  -- WIP data
  signal btw5x_6   : std_logic_vector(31 downto 0);  -- WIP data
  signal btw6_6x   : std_logic_vector(31 downto 0);  -- WIP data
  signal btw6x_7   : std_logic_vector(31 downto 0);  -- WIP data
  signal btw7_7x   : std_logic_vector(31 downto 0);  -- WIP data
  signal btw7x_8   : std_logic_vector(31 downto 0);  -- WIP data
  signal btw8_8x   : std_logic_vector(31 downto 0);  -- WIP data
  signal btw8x_9   : std_logic_vector(31 downto 0);  -- WIP data
  signal btw9_9x   : std_logic_vector(31 downto 0);  -- WIP data
  signal btw9x_10  : std_logic_vector(31 downto 0);  -- WIP data
--  signal btw10_10x : std_logic_vector(31 downto 0);  -- WIP data
--  signal btw10x_11 : std_logic_vector(31 downto 0);  -- WIP data
--  signal btw11_11x : std_logic_vector(31 downto 0);  -- WIP data
--  signal btw11_12  : std_logic_vector(31 downto 0);  -- Not connected
  
begin  -- structural

  GF1x : gf_xor_input port map (input_fcs => input, output_wip => btw1x_2);
  GF2  : gf_phi1_register_2 port map (reset => reset, phi1 => phi1,
                                   input_wip  => btw1x_2, input_fcs  => input,
                                   output_wip => btw2_2x, output_fcs => btw2_3);

  GF2x : gf_xor_2x port map (input_wip  => btw2_2x, input_fcs  => btw2_3,
                          output_wip => btw2x_3);
  GF3  : gf_phi2_register_3 port map (reset => reset, phi2 => phi2,
                                   input_wip  => btw2x_3, input_fcs  => btw2_3,
                                   output_wip => btw3_3x, output_fcs => btw3_4);

  GF3x : gf_xor_3x port map (input_wip  => btw3_3x, input_fcs  => btw3_4,
                          output_wip => btw3x_4);
  GF4  : gf_phi1_register_4 port map (reset => reset, phi1 => phi1,
                                   input_wip  => btw3x_4, input_fcs  => btw3_4,
                                   output_wip => btw4_4x, output_fcs => btw4_5);

  GF4x : gf_xor_4x port map (input_wip  => btw4_4x, input_fcs  => btw4_5,
                          output_wip => btw4x_5);
  GF5  : gf_phi2_register_5 port map (reset => reset, phi2 => phi2,
                                   input_wip  => btw4x_5, input_fcs  => btw4_5,
                                   output_wip => btw5_5x, output_fcs => btw5_6);

  GF5x : gf_xor_5x port map (input_wip  => btw5_5x, input_fcs  => btw5_6,
                          output_wip => btw5x_6);
  GF6  : gf_phi1_register_6 port map (reset => reset, phi1 => phi1,
                                   input_wip  => btw5x_6, input_fcs  => btw5_6,
                                   output_wip => btw6_6x, output_fcs => btw6_7);

  GF6x : gf_xor_6x port map (input_wip  => btw6_6x, input_fcs  => btw6_7,
                          output_wip => btw6x_7);
  GF7  : gf_phi2_register_7 port map (reset => reset, phi2 => phi2,
                                   input_wip  => btw6x_7, input_fcs  => btw6_7,
                                   output_wip => btw7_7x, output_fcs => btw7_8);

  GF7x : gf_xor_7x port map (input_wip  => btw7_7x, input_fcs  => btw7_8,
                          output_wip => btw7x_8);
  GF8  : gf_phi1_register_8 port map (reset => reset, phi1 => phi1,
                                   input_wip  => btw7x_8, input_fcs  => btw7_8,
                                   output_wip => btw8_8x, output_fcs => btw8_9);

  GF8x : gf_xor_8x port map (input_wip  => btw8_8x, input_fcs  => btw8_9,
                          output_wip => btw8x_9);
  GF9  : gf_phi2_register_9 port map (reset => reset, phi2 => phi2,
                                   input_wip  => btw8x_9, input_fcs  => btw8_9,
                                   output_wip => btw9_9x, output_fcs => btw9_10);

  GF9x : gf_xor_9x port map (input_wip  => btw9_9x, input_fcs  => btw9_10,
                          output_wip => btw9x_10);
  GF10 : gf_phi1_register_out port map (reset => reset, phi1 => phi1,
                                   input_wip  => btw9x_10,
                                   output_final(15 downto 0) => output_xor, 
                                   output_final(31 downto 16)  => output_fcs);

--  GF10x : gf_xor_10x port map (input_wip  => btw10_10x, input_fcs  => btw10_11,
--                           output_wip => btw10x_11);
--  GF11  : gf_phi2_register port map (reset => reset, phi2 => phi2,
--                                   input_wip  => btw10x_11, input_fcs  => btw10_11,
--                                   output_wip => btw11_11x, output_fcs => btw11_12);

-- The last register is smaller since it just have to plug its output into
-- the FCS and the final big XOR
  
--  GF12 : gf_phi1_register_out port map (reset => reset, phi1 => phi1,
--                                       input_wip  => btw11_11x,
--                                       output_final(31 downto 16) => output_xor,
--                                       output_final(15 downto 0) => output_fcs);
  
end structural;


configuration cfg_gf_multiplier of gf_multiplier is

  for structural 
    for GF1x : gf_xor_input use entity work.gf_xor_input(behavior); end for;
    for GF2  : gf_phi1_register_2
              use entity work.gf_phi1_register_2(behavior); end for;
    for GF2x : gf_xor_2x
              use entity work.gf_xor_2x(behavior); end for;
    for GF3  : gf_phi2_register_3
              use entity work.gf_phi2_register_3(behavior); end for;
    for GF3x : gf_xor_3x
              use entity work.gf_xor_3x(behavior); end for;
    for GF4  : gf_phi1_register_4
              use entity work.gf_phi1_register_4(behavior); end for;
    for GF4x : gf_xor_4x
              use entity work.gf_xor_4x(behavior); end for;
    for GF5  : gf_phi2_register_5
              use entity work.gf_phi2_register_5(behavior); end for;
    for GF5x : gf_xor_5x
              use entity work.gf_xor_5x(behavior); end for;
    for GF6  : gf_phi1_register_6
              use entity work.gf_phi1_register_6(behavior); end for;
    for GF6x : gf_xor_6x
              use entity work.gf_xor_6x(behavior); end for;
    for GF7  : gf_phi2_register_7
              use entity work.gf_phi2_register_7(behavior); end for;
    for GF7x : gf_xor_7x
              use entity work.gf_xor_7x(behavior); end for;
    for GF8  : gf_phi1_register_8
              use entity work.gf_phi1_register_8(behavior); end for;
    for GF8x : gf_xor_8x
              use entity work.gf_xor_8x(behavior); end for;
    for GF9  : gf_phi2_register_9
              use entity work.gf_phi2_register_9(behavior); end for;
    for GF9x : gf_xor_9x
              use entity work.gf_xor_9x(behavior); end for;
    for GF10 : gf_phi1_register_out
              use entity work.gf_phi1_register_out(behavior); end for;
--    for GF10x : gf_xor_10x
--              use entity work.gf_xor_10x(behavior); end for;
--    for GF11  : gf_phi2_register
--              use entity work.gf_phi2_register(behavior); end for;
--    for GF12  : gf_phi1_register_out
--              use entity work.gf_phi1_register_out(behavior); end for;
  end for;

end cfg_gf_multiplier;

