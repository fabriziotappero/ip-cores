-------------------------------------------------------------------------------
-- This file contains the code for the "wait states" of the input. It is also
-- one of the three main blocks of the generator.
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity input_wait is port (
    phi1      : in  std_logic;            -- Two phase discipline
    phi2      : in  std_logic;
    reset     : in  std_logic;            -- #RESET
    input     : in  std_logic_vector(15 downto 0);
                                        -- The serial/parallel conversion has
                                        -- been made somewhere else
    output    : out std_logic_vector(15 downto 0));

end input_wait;

architecture structural of input_wait is


  component input_phi1_register
    port (
      reset  : in  std_logic;           -- #RESET
      phi1   : in  std_logic;           -- Clock
      input  : in  std_logic_vector(15 downto 0);
      output : out std_logic_vector(15 downto 0));
  end component;

  component input_phi2_register
    port (
      reset  : in  std_logic;           -- #RESET
      phi2   : in  std_logic;           -- Clock
      input  : in  std_logic_vector(15 downto 0);
      output : out std_logic_vector(15 downto 0));
  end component;

  signal btw1and2   : std_logic_vector(15 downto 0);
  signal btw2and3   : std_logic_vector(15 downto 0);
  signal btw3and4   : std_logic_vector(15 downto 0);
  signal btw4and5   : std_logic_vector(15 downto 0);
  signal btw5and6   : std_logic_vector(15 downto 0);
  signal btw6and7   : std_logic_vector(15 downto 0);
  signal btw7and8   : std_logic_vector(15 downto 0);
--  signal btw8and9   : std_logic_vector(15 downto 0);
--  signal btw9and10  : std_logic_vector(15 downto 0);
--  signal btw10and11 : std_logic_vector(15 downto 0);
--  signal btw11and12 : std_logic_vector(15 downto 0);
  
begin  -- structural

Input1:  input_phi2_register port map (reset  => reset, phi2   => phi2,
                                       input  => input, output => btw1and2);

Input2:  input_phi1_register port map (reset  => reset,    phi1   => phi1,
                                       input  => btw1and2, output => btw2and3);

Input3:  input_phi2_register port map (reset  => reset,    phi2   => phi2,
                                       input  => btw2and3, output => btw3and4);

Input4:  input_phi1_register port map (reset  => reset,    phi1   => phi1,
                                       input  => btw3and4, output => btw4and5);

Input5:  input_phi2_register port map (reset  => reset,    phi2   => phi2,
                                       input  => btw4and5, output => btw5and6);

Input6:  input_phi1_register port map (reset  => reset,    phi1   => phi1,
                                       input  => btw5and6, output => btw6and7);

Input7:  input_phi2_register port map (reset  => reset,    phi2   => phi2,
                                       input  => btw6and7, output => btw7and8);

Input8:  input_phi1_register port map (reset  => reset,    phi1   => phi1,
                                       input  => btw7and8, output => output);

-- Input9:  input_phi2_register port map (reset  => reset,    phi2   => phi2,
--                                       input  => btw8and9, output => btw9and10);

-- Input10:  input_phi1_register port map (reset  => reset,    phi1   => phi1,
--                                       input  => btw9and10, output => output);

-- Input11:  input_phi2_register port map (reset  => reset,    phi2   => phi2,
--                                       input  => btw10and11, output => btw11and12);

-- Input12:  input_phi1_register port map (reset  => reset,    phi1   => phi1,
--                                       input  => btw11and12, output => output);

end structural;


configuration cfg_input_wait_structural of input_wait is

  for structural
    for Input1 : input_phi2_register
      use entity work.input_phi2_register(behavior);
    end for;
    
    for Input2 : input_phi1_register
      use entity work.input_phi1_register(behavior);
    end for;

    for Input3 : input_phi2_register
      use entity work.input_phi2_register(behavior);
    end for;

    for Input4 : input_phi1_register
      use entity work.input_phi1_register(behavior);
    end for;

    for Input5 : input_phi2_register
      use entity work.input_phi2_register(behavior);
    end for;

    for Input6 : input_phi1_register
      use entity work.input_phi1_register(behavior);
    end for;

    for Input7 : input_phi2_register
      use entity work.input_phi2_register(behavior);
    end for;

    for Input8 : input_phi1_register
      use entity work.input_phi1_register(behavior);
    end for;

--    for Input9 : input_phi2_register
--      use entity work.input_phi2_register(behavior);
--    end for;

--    for Input10 : input_phi1_register
--      use entity work.input_phi1_register(behavior);
--    end for;

--    for Input11 : input_phi2_register
--      use entity work.input_phi2_register(behavior);
--    end for;

--    for Input12 : input_phi1_register
--      use entity work.input_phi1_register(behavior);
--    end for;
    
  end for;

end cfg_input_wait_structural;
