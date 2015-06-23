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
                                        -- The serial/parallel conversion has been made somewhere else
    FCS_out : out std_logic_vector(31 downto 0));

end CRC_top;

architecture structural of CRC_top is

  -- Structural description of the CRC
  -- We will describe all the pipelining steps as different components in
  -- order to force a certain implementation in the synthesised circuit

  -- These first pipelining steps are the "waiting" steps. The data will flow
  -- through the registers.

  -- The nomenclature can be explained in the following way:
  -- Input<stage no.>_<clock phase>  => Registers in the "wait" region

  -- For the Galois Field multiplier:
  -- GF<stage no.>_<clock phase>     => Registers of the GF multiplier
  -- GF<stage no.>_xor_<clock phase> => Combinational logic of the GF mult.
  
  component Input1_2
    port (
      reset     : in  std_logic;
      phi2      : in  std_logic;
      input1_2  : in  std_logic_vector (15 downto 0);   -- Directly from the serial/parallel register
      output1_2 : out std_logic_vector (15 downto 0));  -- To the next step
  end component;

  component Input2_1
    port (
      reset     : in  std_logic;
      phi1      : in  std_logic;
      input2_1  : in  std_logic_vector (15 downto 0);
      output2_1 : out std_logic_vector (15 downto 0));
  end component;

  component Input3_2
    port (
      reset     : in  std_logic;
      phi2      : in  std_logic;
      input3_2  : in  std_logic_vector (15 downto 0);   
      output3_2 : out std_logic_vector (15 downto 0));
  end component;

  component Input4_1
    port (
      reset     : in  std_logic;
      phi1      : in  std_logic;
      input4_1  : in  std_logic_vector (15 downto 0);
      output4_1 : out std_logic_vector (15 downto 0));
  end component;

  component Input5_2
    port (
      reset     : in  std_logic;
      phi2      : in  std_logic;
      input5_2  : in  std_logic_vector (15 downto 0);   
      output5_2 : out std_logic_vector (15 downto 0));
  end component;

  component Input6_1
    port (
      reset     : in  std_logic;
      phi1      : in  std_logic;
      input6_1  : in  std_logic_vector (15 downto 0);
      output6_1 : out std_logic_vector (15 downto 0));
  end component;

  component Input7_2
    port (
      reset     : in  std_logic;
      phi2      : in  std_logic;
      input7_2  : in  std_logic_vector (15 downto 0);   
      output7_2 : out std_logic_vector (15 downto 0));
  end component;

  component Input8_1
    port (
      reset     : in  std_logic;
      phi1      : in  std_logic;
      input8_1  : in  std_logic_vector (15 downto 0);
      output8_1 : out std_logic_vector (15 downto 0));
  end component;

  component Input9_2
    port (
      reset     : in  std_logic;
      phi2      : in  std_logic;
      input9_2  : in  std_logic_vector (15 downto 0);   
      output9_2 : out std_logic_vector (15 downto 0));
  end component;

  component Input10_1
    port (
      reset      : in  std_logic;
      phi1       : in  std_logic;
      input10_1  : in  std_logic_vector (15 downto 0);
      output10_1 : out std_logic_vector (15 downto 0));
  end component;

  component Input11_2
    port (
      reset      : in  std_logic;
      phi2       : in  std_logic;
      input11_2  : in  std_logic_vector (15 downto 0);   
      output11_2 : out std_logic_vector (15 downto 0));
  end component;

  component Input12_1
    port (
      reset      : in  std_logic;
      phi1       : in  std_logic;
      input12_1  : in  std_logic_vector (15 downto 0);
      output12_1 : out std_logic_vector (15 downto 0));
  end component;

  -- Galois Field pipelining registers and combinational stuff

  component GF1_xor_2
    port (
      input_gf1x_2  : in  std_logic_vector (31 downto 0);   -- Inputs = WIP + "Original data"
      output_gf1x_2 : out std_logic_vector (31 downto 0));  -- The new WIP
  end component;

  component GF2_1
    port (
      reset       : in  std_logic;
      phi1        : in  std_logic;
      input_gf2_1  : in  std_logic_vector (63 downto 0);
      output_gf2_1 : out std_logic_vector (63 downto 0));
  end component;

  component GF2_xor_1
    port (
      input_gf2x_1  : in  std_logic_vector (31 downto 0);   -- Inputs = WIP + "Original data"
      output_gf2x_1 : out std_logic_vector (31 downto 0));  -- The new WIP
  end component;

  component GF3_2
    port (
      reset       : in  std_logic;
      phi2        : in  std_logic;
      input_gf3_2  : in  std_logic_vector (63 downto 0);
      output_gf3_2 : out std_logic_vector (63 downto 0));
  end component;

  component GF3_xor_2
    port (
      input_gf3x_2  : in  std_logic_vector (31 downto 0);   -- Inputs = WIP + "Original data"
      output_gf3x_2 : out std_logic_vector (31 downto 0));  -- The new WIP
  end component;

  component GF4_1
    port (
      reset  : in  std_logic;
      phi1   : in  std_logic;
      input_gf4_1  : in  std_logic_vector (63 downto 0);
      output_gf4_1 : out std_logic_vector (63 downto 0));
  end component;

  component GF4_xor_1
    port (
      input_gf4x_1  : in  std_logic_vector (31 downto 0);   -- Inputs = WIP + "Original data"
      output_gf4x_1 : out std_logic_vector (31 downto 0));  -- The new WIP
  end component;

  component GF5_2
    port (
      reset       : in  std_logic;
      phi2        : in  std_logic;
      input_gf5_2  : in  std_logic_vector (63 downto 0);
      output_gf5_2 : out std_logic_vector (63 downto 0));
  end component;

  component GF5_xor_2
    port (
      input_gf5x_2  : in  std_logic_vector (31 downto 0);   -- Inputs = WIP + "Original data"
      output_gf5x_2 : out std_logic_vector (31 downto 0));  -- The new WIP
  end component;

  component GF6_1
    port (
      reset       : in  std_logic;
      phi1        : in  std_logic;
      input_gf6_1  : in  std_logic_vector (63 downto 0);
      output_gf6_1 : out std_logic_vector (63 downto 0));
  end component;

  component GF6_xor_1
    port (
      input_gf6x_1  : in  std_logic_vector (31 downto 0);   -- Inputs = WIP + "Original data"
      output_gf6x_1 : out std_logic_vector (31 downto 0));  -- The new WIP
  end component;

  component GF7_2
    port (
      reset       : in  std_logic;
      phi2        : in  std_logic;
      input_gf7_2  : in  std_logic_vector (63 downto 0);
      output_gf7_2 : out std_logic_vector (63 downto 0));
  end component;

  component GF7_xor_2
    port (
      input_gf7x_2  : in  std_logic_vector (31 downto 0);   -- Inputs = WIP + "Original data"
      output_gf7x_2 : out std_logic_vector (31 downto 0));  -- The new WIP
  end component;

  component GF8_1
    port (
      reset       : in  std_logic;
      phi1        : in  std_logic;
      input_gf8_1  : in  std_logic_vector (63 downto 0);
      output_gf8_1 : out std_logic_vector (63 downto 0));
  end component;

  component GF8_xor_1
    port (
      input_gf8x_1  : in  std_logic_vector (31 downto 0);   -- Inputs = WIP + "Original data"
      output_gf8x_1 : out std_logic_vector (31 downto 0));  -- The new WIP
  end component;

  component GF9_2
    port (
      reset       : in  std_logic;
      phi2        : in  std_logic;
      input_gf9_2  : in  std_logic_vector (63 downto 0);
      output_gf9_2 : out std_logic_vector (63 downto 0));
  end component;

  component GF9_xor_2
    port (
      input_gf9x_2  : in  std_logic_vector (31 downto 0);   -- Inputs = WIP + "Original data"
      output_gf9x_2 : out std_logic_vector (31 downto 0));  -- The new WIP
  end component;

  component GF10_1
    port (
      reset        : in  std_logic;
      phi1         : in  std_logic;
      input_gf10_1  : in  std_logic_vector (63 downto 0);
      output_gf10_1 : out std_logic_vector (63 downto 0));
  end component;

  component GF10_xor_1
    port (
      input_gf10x_1  : in  std_logic_vector (31 downto 0);   -- Inputs = WIP + "Original data"
      output_gf10x_1 : out std_logic_vector (31 downto 0));  -- The new WIP
  end component;

  component GF11_2
    port (
      reset        : in  std_logic;
      phi2         : in  std_logic;
      input_gf11_2  : in  std_logic_vector (63 downto 0);
      output_gf11_2 : out std_logic_vector (63 downto 0));
  end component;

--  component GF11_xor_2
--    port (
--      input_gf11x_2  : in  std_logic_vector (31 downto 0);   -- Inputs = WIP + "Original data"
--      output_gf11x_2 : out std_logic_vector (31 downto 0));  -- The new WIP
--  end component;

  component GF12_1
    port (
      reset         : in  std_logic;
      phi1          : in  std_logic;
      input_gf12_1  : in  std_logic_vector (31 downto 0);
      output_gf12_1 : out std_logic_vector (31 downto 0));
  end component;
  
  -- Big XOR and output register (FCS)

  component Big_XOR12_1
    port (
      input_bigx12_1  : in  std_logic_vector (15 downto 0);
      output_bigx12_1 : out std_logic_vector (15 downto 0));
  end component;

  component FCS_out13_2
    port (
      reset          : in std_logic;
      phi2           : in std_logic;
      input_fcs13_2  : in  std_logic_vector (31 downto 0);
      output_fcs13_2 : out std_logic_vector (31 downto 0));  -- FCS_out and feedback to the GF multiplier
    
  end component;

begin

Input1 : Input1_2 port map (
    reset     => reset,
    phi2      => phi2,
    input1_2  => input,
    output1_2 => input2_1);

Input2 : Input2_1 port map (
    reset     => reset,
    phi1      => phi1,
    input2_1  => output1_2,
    output2_1 => input3_1);

Input3 : Input3_2 port map (
    reset     => reset,
    phi2      => phi2,
    input3_2  => output2_1,
    output3_2 => input4_1);

Input4 : Input4_1 port map (
    reset     => reset,
    phi1      => phi1,
    input4_1  => output3_2,
    output4_1 => input5_2);

Input5 : Input5_2 port map (
    reset     => reset,
    phi2      => phi2,
    input5_2  => output4_1,
    output5_2 => input6_1);

Input6 : Input6_1 port map (
    reset     => reset,
    phi1      => phi1,
    input6_1  => output5_2,
    output6_1 => input7_2);

Input7 : Input7_2 port map (
    reset     => reset,
    phi2      => phi2,
    input7_2  => output6_1,
    output7_2 => input8_1);

Input8 : Input8_1 port map (
    reset     => reset,
    phi1      => phi1,
    input8_1  => output7_2,
    output8_1 => input9_2);

Input9 : Input9_2 port map (
    reset     => reset,
    phi2      => phi2,
    input9_2  => output8_1,
    output9_2 => input10_1);

Input10 : Input10_2 port map (
    reset     => reset,
    phi1      => phi1,
    input10_1  => output9_2,
    output10_1 => input11_2);

Input11 : Input11_2 port map (
    reset     => reset,
    phi2      => phi2,
    input11_2  => output10_1,
    output11_2 => input12_1);

Input12 : Input12_1 port map (
    reset     => reset,
    phi1      => phi1,
    input12_1  => output11_2,
    output12_1 => input_bigx_1);        -- Big "final" XOR


end structural;

-- Now it is time to define each component and the way they work

architecture Input1_2 of CRC_top is
  
begin  -- Input1_2

  if reset='0' then output1_2 <= X'00000000'
     elsif phi2='1' and phi2'event then output1_2 <= input1_2;
  end if;
    
end Input1_2;


architecture Input2_1 of CRC_top is

begin  -- Input2_1
 
  if reset='0' then output2_1 <= X'00000000'
     elsif phi1='1' and phi1'event then output2_1 <= input2_1;
  end if;
                    
end Input2_1;


architecture Input3_2 of CRC_top is

begin  -- Input3_2

  if reset='0' then output3_2 <= X'00000000'
     elsif phi2='1' and phi2'event then output3_2 <= input3_2;
  end if;
                    
end Input3_2;


architecture Input4_1 of CRC_top is

begin  -- Input4_1

  if reset='0' then output4_1 <= X'00000000'
     elsif phi1='1' and phi1'event then output4_1 <= input4_1;
  end if;
                    
end Input4_1;


architecture Input5_2 of CRC_top is

begin  -- Input5_2

  if reset='0' then output5_2 <= X'00000000'
     elsif phi2='1' and phi2'event then output5_2 <= input5_2;
  end if;
                    
end Input5_2;


architecture Input6_1 of CRC_top is

begin  -- Input6_1

  if reset='0' then output6_1 <= X'00000000'
     elsif phi1='1' and phi1'event then output6_1 <= input6_1;
  end if;
                    
end Input6_1;


architecture Input7_2 of CRC_top is

begin  -- Input7_2

  if reset='0' then output7_2 <= X'00000000'
     elsif phi2='1' and phi2'event then output7_2 <= input7_2;
  end if;
                    
end Input7_2;


architecture Input8_1 of CRC_top is

begin  -- Input8_1

  if reset='0' then output8_1 <= X'00000000'
     elsif phi1='1' and phi1'event then output8_1 <= input8_1;
  end if;
                    
end Input8_1;


architecture Input9_2 of CRC_top is

begin  -- Input9_2

  if reset='0' then output9_2 <= X'00000000'
     elsif phi2='1' and phi2'event then output9_2 <= input9_2;
  end if;
                    
end Input9_2;


architecture Input10_1 of CRC_top is

begin  -- Input10_1

  if reset='0' then output10_1 <= X'00000000'
     elsif phi1='1' and phi1'event then output10_1 <= input10_1;
  end if;
                    
end Input10_1;


architecture Input11_2 of CRC_top is

begin  -- Input11_2

  if reset='0' then output11_2 <= X'00000000'
     elsif phi2='1' and phi2'event then output11_2 <= input11_2;
  end if;
                    
end Input11_2;


architecture Input12_1 of CRC_top is

begin  -- Input12_1

  if reset='0' then output12_1 <= X'00000000'
     elsif phi1='1' and phi1'event then output12_1 <= input12_1;
  end if;
                    
end Input2_1;

-- Galois Field multiplier

architecture GF1_xor_2 of CRC_top is

begin  -- GF1_xor_2

  port map (
    input_gf1x_2  => fcs_out13_2,
    output_gf1x_2 => input_gf2_1 (31 downto 0));

  -- Some area optimizations could be done, since we don't use all
  -- the 32 bits of the fcs
  
  output_gf1x_2 (31 => (input_gf1x_2(9) xor input_gf1x_2(15)),
                 30 => (input_gf1x_2(8) xor input_gf1x_2(9)),
                 29 => (input_gf1x_2(7) xor input_gf1x_2(8)),
                 28 => (input_gf1x_2(6) xor input_gf1x_2(7)),
                 27 => (input_gf1x_2(5) xor input_gf1x_2(6)),
                 26 => (input_gf1x_2(4) xor input_gf1x_2(5)),
                 25 => (input_gf1x_2(3) xor input_gf1x_2(4)),
                 24 => (input_gf1x_2(2) xor input_gf1x_2(3)),
                 23 => (input_gf1x_2(1) xor input_gf1x_2(1)),
                 22 => (input_gf1x_2(0) xor input_gf1x_2(1)),
                 21 => (input_gf1x_2(0) xor input_gf1x_2(1)),
                 20 => (input_gf1x_2(0) xor input_gf1x_2(2)),
                 19 => (input_gf1x_2(1) xor input_gf1x_2(2)),
                 18 => (input_gf1x_2(0) xor input_gf1x_2(1)),
                 17 => (input_gf1x_2(0) xor input_gf1x_2(1)),
                 16 => (input_gf1x_2(0) xor input_gf1x_2(6)),
                 15 => (input_gf1x_2(5) xor input_gf1x_2(6)),
                 14 => (input_gf1x_2(4) xor input_gf1x_2(5)),
                 13 => (input_gf1x_2(3) xor input_gf1x_2(4)),
                 12 => (input_gf1x_2(2) xor input_gf1x_2(3)),
                 11 => (input_gf1x_2(1) xor input_gf1x_2(2)),
                 10 => (input_gf1x_2(0) xor input_gf1x_2(1)),
                 9 => (input_gf1x_2(0) xor input_gf1x_2(1)),
                 8 => (input_gf1x_2(0) xor input_gf1x_2(3)),
                 7 => (input_gf1x_2(2) xor input_gf1x_2(3)),
                 6 => (input_gf1x_2(1) xor input_gf1x_2(2)),
                 5 => (input_gf1x_2(0) xor input_gf1x_2(1)),
                 4 => (input_gf1x_2(0) xor input_gf1x_2(5)),
                 3 => (input_gf1x_2(4) xor input_gf1x_2(7)),
                 2 => (input_gf1x_2(3) xor input_gf1x_2(6)),
                 1 => (input_gf1x_2(2) xor input_gf1x_2(5)),
                 0 => (input_gf1x_2(1) xor input_gf1x_2(4)));
                 

end GF1_xor_2;

architecture GF2_1 of CRC_top is

begin  -- GF2_1

  port map (
    reset                         => reset,
    phi1                          => phi1,
    input_gf2_1 (63 downto 32)    => fcs_13_2,
    input_gf2_1 (31 downto 0)     => output_gf1x_2,
    output_gf2_1 (63 downto 32)   => input_gf3_2,
    output_gf2_1 (31 downto 0)    => input_gf2x_1);

  if reset='0' then output_gf2_1 <= X'0000000000000000'
     elsif phi1='1' and phi1'event then output_gf2_1 <= input_gf2_1;
  end if;

end GF2_1;


architecture GF2_xor_1 of CRC_top is

begin  -- GF2_xor_1

  port map (
    input_gf2x_1  => output_gf2_1 (31 downto 0),
    output_gf2x_1 => input_gf3_2 (31 downto 0));

  -- Some area optimizations could be done, since we don't use all
  -- the 32 bits of the fcs
  
  output_gf2x_1 (31 => input_gf2x_1(31),
                 30 => (input_gf2x_1(30) xor output_gf2_1(14+32)),
                 29 => (input_gf2x_1(29) xor output_gf2_1(9+32)),
                 28 => (input_gf2x_1(28) xor output_gf2_1(8+32)),
                 27 => (input_gf2x_1(27) xor output_gf2_1(7+32)),
                 26 => (input_gf2x_1(26) xor output_gf2_1(6+32)),
                 25 => (input_gf2x_1(25) xor output_gf2_1(5+32)),
                 24 => (input_gf2x_1(24) xor output_gf2_1(4+32)),
                 23 => (input_gf2x_1(23) xor output_gf2_1(3+32)),
                 22 => (input_gf2x_1(22) xor output_gf2_1(2+32)),
                 21 => (input_gf2x_1(21) xor output_gf2_1(3+32)),
                 20 => (input_gf2x_1(20) xor output_gf2_1(3+32)),
                 19 => (input_gf2x_1(19) xor output_gf2_1(3+32)),
                 18 => (input_gf2x_1(18) xor output_gf2_1(2+32)),
                 17 => (input_gf2x_1(17) xor output_gf2_1(7+32)),
                 16 => (input_gf2x_1(16) xor output_gf2_1(7+32)),
                 15 => (input_gf2x_1(15) xor output_gf2_1(7+32)),
                 14 => (input_gf2x_1(14) xor output_gf2_1(6+32)),
                 13 => (input_gf2x_1(13) xor output_gf2_1(5+32)),
                 12 => (input_gf2x_1(12) xor output_gf2_1(4+32)),
                 11 => (input_gf2x_1(11) xor output_gf2_1(3+32)),
                 10 => (input_gf2x_1(10) xor output_gf2_1(2+32)),
                 9 => (input_gf2x_1(9) xor output_gf2_1(4+32)),
                 8 => (input_gf2x_1(8) xor output_gf2_1(4+32)),
                 7 => (input_gf2x_1(7) xor output_gf2_1(8+32)),
                 6 => (input_gf2x_1(6) xor output_gf2_1(7+32)),
                 5 => (input_gf2x_1(5) xor output_gf2_1(6+32)),
                 4 => (input_gf2x_1(4) xor output_gf2_1(8+32)),
                 3 => (input_gf2x_1(3) xor output_gf2_1(9+32)),
                 2 => (input_gf2x_1(2) xor output_gf2_1(8+32)),
                 1 => (input_gf2x_1(1) xor output_gf2_1(7+32)),
                 0 => (input_gf2x_1(0) xor output_gf2_1(6+32)));
                 

end GF2_xor_1;

architecture GF3_2 of CRC_top is

begin  -- GF3_2

  port map (
    reset                         => reset,
    phi2                          => phi2,
    input_gf3_2 (63 downto 32)    => output_gf2_1 (63 downto 32),
    input_gf3_2 (31 downto 0)     => output_gf2x_1,
    output_gf3_2 (63 downto 32)   => input_gf4_1,
    output_gf3_2 (31 downto 0)    => input_gf3x_2);

  if reset='0' then output_gf3_2 <= X'0000000000000000'
     elsif phi2='1' and phi2'event then output_gf3_2 <= input_gf3_2;
  end if;

end GF3_2;


architecture GF3_xor_2 of CRC_top is

begin  -- GF3_xor_2

  port map (
    input_gf3x_2  => output_gf3_2 (31 downto 0),
    output_gf3x_2 => input_gf4_1 (31 downto 0));

  -- Some area optimizations could be done, since we don't use all
  -- the 32 bits of the fcs
  
  output_gf3x_2 (31 => input_gf3x_1(31),
                 30 => (input_gf3x_1(30) xor output_gf3_2(15+32)),
                 29 => (input_gf3x_1(29) xor output_gf3_2(13+32)),
                 28 => (input_gf3x_1(28) xor output_gf3_2(12+32)),
                 27 => (input_gf3x_1(27) xor output_gf3_2(9+32)),
                 26 => (input_gf3x_1(26) xor output_gf3_2(8+32)),
                 25 => (input_gf3x_1(25) xor output_gf3_2(7+32)),
                 24 => (input_gf3x_1(24) xor output_gf3_2(6+32)),
                 23 => (input_gf3x_1(23) xor output_gf3_2(5+32)),
                 22 => (input_gf3x_1(22) xor output_gf3_2(4+32)),
                 21 => (input_gf3x_1(21) xor output_gf3_2(4+32)),
                 20 => (input_gf3x_1(20) xor output_gf3_2(4+32)),
                 19 => (input_gf3x_1(19) xor output_gf3_2(9+32)),
                 18 => (input_gf3x_1(18) xor output_gf3_2(8+32)),
                 17 => (input_gf3x_1(17) xor output_gf3_2(8+32)),
                 16 => (input_gf3x_1(16) xor output_gf3_2(8+32)),
                 15 => (input_gf3x_1(15) xor output_gf3_2(10+32)),
                 14 => (input_gf3x_1(14) xor output_gf3_2(9+32)),
                 13 => (input_gf3x_1(13) xor output_gf3_2(8+32)),
                 12 => (input_gf3x_1(12) xor output_gf3_2(7+32)),
                 11 => (input_gf3x_1(11) xor output_gf3_2(6+32)),
                 10 => (input_gf3x_1(10) xor output_gf3_2(5+32)),
                 9 => (input_gf3x_1(9) xor output_gf3_2(5+32)),
                 8 => (input_gf3x_1(8) xor output_gf3_2(9+32)),
                 7 => (input_gf3x_1(7) xor output_gf3_2(13+32)),
                 6 => (input_gf3x_1(6) xor output_gf3_2(12+32)),
                 5 => (input_gf3x_1(5) xor output_gf3_2(9+32)),
                 4 => (input_gf3x_1(4) xor output_gf3_2(10+32)),
                 3 => (input_gf3x_1(3) xor output_gf3_2(10+32)),
                 2 => (input_gf3x_1(2) xor output_gf3_2(9+32)),
                 1 => (input_gf3x_1(1) xor output_gf3_2(8+32)),
                 0 => (input_gf3x_1(0) xor output_gf3_2(7+32)));
                 

end GF3_xor_2;

architecture GF4_1 of CRC_top is

begin  -- GF4_1

  port map (
    reset                         => reset,
    phi1                          => phi1,
    input_gf4_1 (63 downto 32)    => output_gf3_2 (63 downto 32),
    input_gf4_1 (31 downto 0)     => output_gf3x_2,
    output_gf4_1 (63 downto 32)   => input_gf5_2,
    output_gf4_1 (31 downto 0)    => input_gf4x_1);

  if reset='0' then output_gf4_1 <= X'0000000000000000'
     elsif phi1='1' and phi1'event then output_gf4_1 <= input_gf4_1;
  end if;

end GF4_1;


architecture GF4_xor_1 of CRC_top is

begin  -- GF4_xor_1

  port map (
    input_gf4x_1  => output_gf4_1 (31 downto 0),
    output_gf4x_1 => input_gf5_2 (31 downto 0));

  -- Some area optimizations could be done, since we don't use all
  -- the 32 bits of the fcs
  
  output_gfx4_1 (31 => input_gf4x_1(31),
                 30 => input_gf4x_1(30),
                 29 => (input_gf4x_1(29) xor output_gf4_1(14+32)),
                 28 => (input_gf4x_1(28) xor output_gf4_1(13+32)),
                 27 => (input_gf4x_1(27) xor output_gf4_1(11+32)),
                 26 => (input_gf4x_1(26) xor output_gf4_1(9+32)),
                 25 => (input_gf4x_1(25) xor output_gf4_1(8+32)),
                 24 => (input_gf4x_1(24) xor output_gf4_1(7+32)),
                 23 => (input_gf4x_1(23) xor output_gf4_1(6+32)),
                 22 => (input_gf4x_1(22) xor output_gf4_1(5+32)),
                 21 => (input_gf4x_1(21) xor output_gf4_1(5+32)),
                 20 => (input_gf4x_1(20) xor output_gf4_1(11+32)),
                 19 => (input_gf4x_1(19) xor output_gf4_1(10+32)),
                 18 => (input_gf4x_1(18) xor output_gf4_1(9+32)),
                 17 => (input_gf4x_1(17) xor output_gf4_1(9+32)),
                 16 => (input_gf4x_1(16) xor output_gf4_1(10+32)),
                 15 => (input_gf4x_1(15) xor output_gf4_1(11+32)),
                 14 => (input_gf4x_1(14) xor output_gf4_1(10+32)),
                 13 => (input_gf4x_1(13) xor output_gf4_1(9+32)),
                 12 => (input_gf4x_1(12) xor output_gf4_1(8+32)),
                 11 => (input_gf4x_1(11) xor output_gf4_1(7+32)),
                 10 => (input_gf4x_1(10) xor output_gf4_1(6+32)),
                 9 => (input_gf4x_1(9) xor output_gf4_1(15+32)),
                 8 => (input_gf4x_1(8) xor output_gf4_1(14+32)),
                 7 => (input_gf4x_1(7) xor output_gf4_1(14+32)),
                 6 => (input_gf4x_1(6) xor output_gf4_1(13+32)),
                 5 => (input_gf4x_1(5) xor output_gf4_1(11+32)),
                 4 => (input_gf4x_1(4) xor output_gf4_1(11+32)),
                 3 => (input_gf4x_1(3) xor output_gf4_1(13+32)),
                 2 => (input_gf4x_1(2) xor output_gf4_1(12+32)),
                 1 => (input_gf4x_1(1) xor output_gf4_1(11+32)),
                 0 => (input_gf4x_1(0) xor output_gf4_1(10+32)));
                 

end GF4_xor_1;

architecture GF5_2 of CRC_top is

begin  -- GF5_2

  port map (
    reset                         => reset,
    phi2                          => phi2,
    input_gf5_2 (63 downto 32)    => output_gf4_1 (63 downto 32),
    input_gf5_2 (31 downto 0)     => output_gf4x_1,
    output_gf5_2 (63 downto 32)   => input_gf6_1 (63 downto 32),
    output_gf5_2 (31 downto 0)    => input_gf5x_2);

  if reset='0' then output_gf5_2 <= X'0000000000000000'
     elsif phi2='1' and phi2'event then output_gf5_2 <= input_gf5_2;
  end if;

end GF5_2;


architecture GF5_xor_2 of CRC_top is

begin  -- GF5_xor_2

  port map (
    input_gf5x_2  => output_gf5_2 (31 downto 0),
    output_gf5x_2 => input_gf6_1 (31 downto 0));

  -- Some area optimizations could be done, since we don't use all
  -- the 32 bits of the fcs
  
  output_gf5x_2 (31 => input_gf5x_2(31),
                 30 => input_gf5x_2(30),
                 29 => (input_gf5x_2(29) xor output_gf5_2(15+32)),
                 28 => (input_gf5x_2(28) xor output_gf5_2(14+32)),
                 27 => (input_gf5x_2(27) xor output_gf5_2(12+32)),
                 26 => (input_gf5x_2(26) xor output_gf5_2(10+32)),
                 25 => (input_gf5x_2(25) xor output_gf5_2(9+32)),
                 24 => (input_gf5x_2(24) xor output_gf5_2(8+32)),
                 23 => (input_gf5x_2(23) xor output_gf5_2(7+32)),
                 22 => (input_gf5x_2(22) xor output_gf5_2(6+32)),
                 21 => (input_gf5x_2(21) xor output_gf5_2(10+32)),
                 20 => (input_gf5x_2(20) xor output_gf5_2(12+32)),
                 19 => (input_gf5x_2(19) xor output_gf5_2(11+32)),
                 18 => (input_gf5x_2(18) xor output_gf5_2(10+32)),
                 17 => (input_gf5x_2(17) xor output_gf5_2(11+32)),
                 16 => (input_gf5x_2(16) xor output_gf5_2(11+32)),
                 15 => (input_gf5x_2(15) xor output_gf5_2(15+32)),
                 14 => (input_gf5x_2(14) xor output_gf5_2(14+32)),
                 13 => (input_gf5x_2(13) xor output_gf5_2(13+32)),
                 12 => (input_gf5x_2(12) xor output_gf5_2(12+32)),
                 11 => (input_gf5x_2(11) xor output_gf5_2(11+32)),
                 10 => (input_gf5x_2(10) xor output_gf5_2(10+32)),
                 9 => (input_gf5x_2(9) xor output_gf5_2(25+32)),
                 8 => (input_gf5x_2(8) xor output_gf5_2(15+32)),
                 7 => (input_gf5x_2(7) xor output_gf5_2(23+32)),
                 6 => (input_gf5x_2(6) xor output_gf5_2(22+32)),
                 5 => (input_gf5x_2(5) xor output_gf5_2(12+32)),
                 4 => (input_gf5x_2(4) xor output_gf5_2(14+32)),
                 3 => (input_gf5x_2(3) xor output_gf5_2(19+32)),
                 2 => (input_gf5x_2(2) xor output_gf5_2(18+32)),
                 1 => (input_gf5x_2(1) xor output_gf5_2(17+32)),
                 0 => (input_gf5x_2(0) xor output_gf5_2(16+32)));
                 

end GF5_xor_2;

architecture GF6_1 of CRC_top is

begin  -- GF6_1

  port map (
    reset                         => reset,
    phi1                          => phi1,
    input_gf6_1 (63 downto 32)    => output_gf5_2 (63 downto 32),
    input_gf6_1 (31 downto 0)     => output_gf5x_2,
    output_gf6_1 (63 downto 32)   => input_gf7_2 (63 downto 32),
    output_gf6_1 (31 downto 0)    => input_gf6x_1);

  if reset='0' then output_gf6_1 <= X'0000000000000000'
     elsif phi1='1' and phi1'event then output_gf6_1 <= input_gf6_1;
  end if;

end GF6_1;


architecture GF6_xor_1 of CRC_top is

begin  -- GF5_xor_1

  port map (
    input_gf6x_1  => output_gf6_1 (31 downto 0),
    output_gf6x_1 => input_gf7_2 (31 downto 0));

  -- Some area optimizations could be done, since we don't use all
  -- the 32 bits of the fcs
  
  output_gf6x_1 (31 => input_gf6x_1(31),
                 30 => input_gf6x_1(30),
                 29 => input_gf6x_1(29),
                 28 => input_gf6x_1(28),
                 27 => (input_gf6x_1(27) xor output_gf6_1(13+32)),
                 26 => (input_gf6x_1(26) xor output_gf6_1(11+32)),
                 25 => (input_gf6x_1(25) xor output_gf6_1(10+32)),
                 24 => (input_gf6x_1(24) xor output_gf6_1(10+32)),
                 23 => (input_gf6x_1(23) xor output_gf6_1(11+32)),
                 22 => (input_gf6x_1(22) xor output_gf6_1(10+32)),
                 21 => (input_gf6x_1(21) xor output_gf6_1(12+32)),
                 20 => (input_gf6x_1(20) xor output_gf6_1(14+32)),
                 19 => (input_gf6x_1(19) xor output_gf6_1(13+32)),
                 18 => (input_gf6x_1(18) xor output_gf6_1(12+32)),
                 17 => (input_gf6x_1(17) xor output_gf6_1(12+32)),
                 16 => (input_gf6x_1(16) xor output_gf6_1(12+32)),
                 15 => (input_gf6x_1(15) xor output_gf6_1(31+32)),
                 14 => (input_gf6x_1(14) xor output_gf6_1(30+32)),
                 13 => (input_gf6x_1(13) xor output_gf6_1(29+32)),
                 12 => (input_gf6x_1(12) xor output_gf6_1(28+32)),
                 11 => (input_gf6x_1(11) xor output_gf6_1(27+32)),
                 10 => (input_gf6x_1(10) xor output_gf6_1(26+32)),
                 9 => (input_gf6x_1(9) xor '0'),
                 8 => (input_gf6x_1(8) xor output_gf6_1(24+32)),
                 7 => (input_gf6x_1(7) xor '0'),
                 6 => (input_gf6x_1(6) xor '0'),
                 5 => (input_gf6x_1(5) xor output_gf6_1(15+32)),
                 4 => (input_gf6x_1(4) xor output_gf6_1(20+32)),
                 3 => (input_gf6x_1(3) xor '0'),
                 2 => (input_gf6x_1(2) xor '0'),
                 1 => (input_gf6x_1(1) xor '0'),
                 0 => (input_gf6x_1(0) xor '0'));
                 

end GF6_xor_1;

architecture GF7_2 of CRC_top is

begin  -- GF7_2

  port map (
    reset                         => reset,
    phi2                          => phi2,
    input_gf7_2 (63 downto 32)    => output_gf6_1 (63 downto 32),
    input_gf7_2 (31 downto 0)     => output_gf6x_1,
    output_gf7_2 (63 downto 32)   => input_gf8_1 (63 downto 32),
    output_gf7_2 (31 downto 0)    => input_gf7x_2);

  if reset='0' then output_gf7_2 <= X'0000000000000000'
     elsif phi2='1' and phi2'event then output_gf7_2 <= input_gf7_2;
  end if;

end GF7_2;


architecture GF7_xor_2 of CRC_top is

begin  -- GF7_xor_2

  port map (
    input_gf7x_2  => output_gf7_2 (31 downto 0),
    output_gf7x_2 => input_gf8_1 (31 downto 0));

  -- Some area optimizations could be done, since we don't use all
  -- the 32 bits of the fcs
  
  output_gf7x_2 (31 => input_gf7x_2(31),
                 30 => input_gf7x_2(30),
                 29 => input_gf7x_2(29),
                 28 => input_gf7x_2(28),
                 27 => (input_gf7x_2(27) xor output_gf7_2(15+32)),
                 26 => (input_gf7x_2(26) xor output_gf7_2(12+32)),
                 25 => (input_gf7x_2(25) xor output_gf7_2(11+32)),
                 24 => (input_gf7x_2(24) xor output_gf7_2(12+32)),
                 23 => (input_gf7x_2(23) xor output_gf7_2(12+32)),
                 22 => (input_gf7x_2(22) xor output_gf7_2(11+32)),
                 21 => (input_gf7x_2(21) xor output_gf7_2(13+32)),
                 20 => (input_gf7x_2(20) xor output_gf7_2(15+32)),
                 19 => (input_gf7x_2(19) xor output_gf7_2(14+32)),
                 18 => (input_gf7x_2(18) xor output_gf7_2(13+32)),
                 17 => (input_gf7x_2(17) xor output_gf7_2(13+32)),
                 16 => (input_gf7x_2(16) xor '0'),
                 15 => (input_gf7x_2(15) xor '0'),
                 14 => (input_gf7x_2(14) xor '0'),
                 13 => (input_gf7x_2(13) xor '0'),
                 12 => (input_gf7x_2(12) xor '0'),
                 11 => (input_gf7x_2(11) xor '0'),
                 10 => (input_gf7x_2(10) xor '0'),
                 9 => input_gf7x_2(9),
                 8 => (input_gf7x_2(8) xor '0'),
                 7 => input_gf7x_2(7),
                 6 => input_gf7x_2(6),
                 5 => (input_gf7x_2(5) xor '0'),
                 4 => (input_gf7x_2(4) xor '0'),
                 3 => input_gf7x_2(3),
                 2 => input_gf7x_2(2),
                 1 => input_gf7x_2(1),
                 0 => input_gf7x_2(0));
                 

end GF7_xor_2;

architecture GF8_1 of CRC_top is

begin  -- GF8_1

  port map (
    reset                         => reset,
    phi1                          => phi1,
    input_gf8_1 (63 downto 32)    => output_gf7_2 (63 downto 32),
    input_gf8_1 (31 downto 0)     => output_gf7x_2,
    output_gf8_1 (63 downto 32)   => input_gf9_2 (63 downto 32),
    output_gf8_1 (31 downto 0)    => input_gf8x_1);

  if reset='0' then output_gf8_1 <= X'0000000000000000'
     elsif phi1='1' and phi1'event then output_gf8_1 <= input_gf8_1;
  end if;

end GF8_1;


architecture GF8_xor_1 of CRC_top is

begin  -- GF8_xor_1

  port map (
    input_gf8x_1  => output_gf8_1 (31 downto 0),
    output_gf8x_1 => input_gf9_2 (31 downto 0));

  -- Some area optimizations could be done, since we don't use all
  -- the 32 bits of the fcs
  
  output_gf8x_1 (31 => input_gf8x_1(31),
                 30 => input_gf8x_1(30),
                 29 => input_gf8x_1(29),
                 28 => input_gf8x_1(28),
                 27 => input_gf8x_1(27),
                 26 => (input_gf8x_1(26) xor output_gf8_1(14+32)),
                 25 => (input_gf8x_1(25) xor output_gf8_1(13+32)),
                 24 => (input_gf8x_1(24) xor output_gf8_1(13+32)),
                 23 => (input_gf8x_1(23) xor output_gf8_1(14+32)),
                 22 => (input_gf8x_1(22) xor output_gf8_1(13+32)),
                 21 => (input_gf8x_1(21) xor output_gf8_1(15+32)),
                 20 => input_gf8x_1(20),
                 19 => (input_gf8x_1(19) xor output_gf8_1(15+32)),
                 18 => (input_gf8x_1(18) xor output_gf8_1(14+32)),
                 17 => (input_gf8x_1(17) xor '0'),
                 16 => input_gf8x_1(16),
                 15 => input_gf8x_1(15),
                 14 => input_gf8x_1(14),
                 13 => input_gf8x_1(13),
                 12 => input_gf8x_1(12),
                 11 => input_gf8x_1(11),
                 10 => input_gf8x_1(10),
                 9 => input_gf8x_1(9),
                 8 => input_gf8x_1(8),
                 7 => input_gf8x_1(7),
                 6 => input_gf8x_1(6),
                 5 => input_gf8x_1(5),
                 4 => input_gf8x_1(4),
                 3 => input_gf8x_1(3),
                 2 => input_gf8x_1(2),
                 1 => input_gf8x_1(1),
                 0 => input_gf8x_1(0));
                 

end GF8_xor_1;

architecture GF9_2 of CRC_top is

begin  -- GF9_2

  port map (
    reset                         => reset,
    phi2                          => phi2,
    input_gf9_2 (63 downto 32)    => output_gf8_1 (63 downto 32),
    input_gf9_2 (31 downto 0)     => output_gf8x_1,
    output_gf9_2 (63 downto 32)   => input_gf10_1 (63 downto 32),
    output_gf9_2 (31 downto 0)    => input_gf9x_2);

  if reset='0' then output_gf9_2 <= X'0000000000000000'
     elsif phi2='1' and phi2'event then output_gf9_2 <= input_gf9_2;
  end if;

end GF9_2;


architecture GF9_xor_2 of CRC_top is

begin  -- GF9_xor_2

  port map (
    input_gf9x_2  => output_gf9_2 (31 downto 0),
    output_gf9x_2 => input_gf10_1 (31 downto 0));

  -- Some area optimizations could be done, since we don't use all
  -- the 32 bits of the fcs
  
  output_gf9x_2 (31 => input_gf9x_2(31),
                 30 => input_gf9x_2(30),
                 29 => input_gf9x_2(29),
                 28 => input_gf9x_2(28),
                 27 => input_gf9x_2(27),
                 26 => (input_gf9x_2(26) xor output_gf9_2(15+32)),
                 25 => (input_gf9x_2(25) xor output_gf9_2(14+32)),
                 24 => (input_gf9x_2(24) xor output_gf9_2(15+32)),
                 23 => (input_gf9x_2(23) xor output_gf9_2(15+32)),
                 22 => (input_gf9x_2(22) xor output_gf9_2(14+32)),
                 21 => (input_gf9x_2(21) xor '0'),
                 20 => input_gf9x_2(20),
                 19 => (input_gf9x_2(19) xor '0'),
                 18 => (input_gf9x_2(18) xor '0'),
                 17 => (input_gf9x_2(17) xor '0'),
                 16 => input_gf9x_2(16),
                 15 => input_gf9x_2(15),
                 14 => input_gf9x_2(14),
                 13 => input_gf9x_2(13),
                 12 => input_gf9x_2(12),
                 11 => input_gf9x_2(11),
                 10 => input_gf9x_2(10),
                 9 => input_gf9x_2(9),
                 8 => input_gf9x_2(8),
                 7 => input_gf9x_2(7),
                 6 => input_gf9x_2(6),
                 5 => input_gf9x_2(5),
                 4 => input_gf9x_2(4),
                 3 => input_gf9x_2(3),
                 2 => input_gf9x_2(2),
                 1 => input_gf9x_2(1),
                 0 => input_gf9x_2(0));
                 

end GF9_xor_2;

architecture GF10_1 of CRC_top is

begin  -- GF10_1

  port map (
    reset                          => reset,
    phi1                           => phi1,
    input_gf10_1 (63 downto 32)    => output_gf9_2 (63 downto 32),
    input_gf10_1 (31 downto 0)     => output_gf9x_2,
    output_gf10_1 (63 downto 32)   => input_gf11_2 (63 downto 32),
    output_gf10_1 (31 downto 0)    => input_gf10x_1);

  if reset='0' then output_gf10_1 <= X'0000000000000000'
     elsif phi1='1' and phi1'event then output_gf10_1 <= input_gf10_1;
  end if;

end GF10_1;


architecture GF10_xor_1 of CRC_top is

begin  -- GF10_xor_1

  port map (
    input_gf10x_1  => output_gf10_1 (31 downto 0),
    output_gf10x_1 => input_gf11_2 (31 downto 0));

  -- Some area optimizations could be done, since we don't use all
  -- the 32 bits of the fcs
  
  output_gf10x_1 (31 => input_gf10x_1(31),
                 30 => input_gf10x_1(30),
                 29 => input_gf10x_1(29),
                 28 => input_gf10x_1(28),
                 27 => input_gf10x_1(27),
                 26 => input_gf10x_1(26),
                 25 => input_gf10x_1(25),
                 24 => (input_gf10x_1(24) xor '0'),
                 23 => (input_gf10x_1(23) xor '0'),
                 22 => (input_gf10x_1(22) xor '0'),
                 21 => input_gf10x_1(21),
                 20 => input_gf10x_1(20),
                 19 => input_gf10x_1(19),
                 18 => input_gf10x_1(18),
                 17 => input_gf10x_1(17),
                 16 => input_gf10x_1(16),
                 15 => input_gf10x_1(15),
                 14 => input_gf10x_1(14),
                 13 => input_gf10x_1(13),
                 12 => input_gf10x_1(12),
                 11 => input_gf10x_1(11),
                 10 => input_gf10x_1(10),
                 9 => input_gf10x_1(9),
                 8 => input_gf10x_1(8),
                 7 => input_gf10x_1(7),
                 6 => input_gf10x_1(6),
                 5 => input_gf10x_1(5),
                 4 => input_gf10x_1(4),
                 3 => input_gf10x_1(3),
                 2 => input_gf10x_1(2),
                 1 => input_gf10x_1(1),
                 0 => input_gf10x_1(0));
                 

end GF10_xor_1;

architecture GF11_2 of CRC_top is

begin  -- GF11_2

  port map (
    reset         => reset,
    phi2          => phi2,
    input_gf11_2  => output_gf10x_1,
    output_gf11_2 => input_gf12_1;

  if reset='0' then output_gf11_2 <= X'0000000000000000'
     elsif phi2='1' and phi2'event then output_gf11_2 <= input_gf11_2;
  end if;

end GF11_2;


architecture GF12_1 of CRC_top is

begin  -- GF12_1

  port map (
    reset         => reset,
    phi1          => phi1,
    input_gf12_1  => output_gf11_2,
    output_gf12_1(15 downto 0) => input_bigx12_1,
    output_gf12_1(31 downto 16) => input_fcs13_2(31 downto 16);

  if reset='0' then output_gf12_1 <= X'0000000000000000'
     elsif phi1='1' and phi1'event then output_gf12_1 <= input_gf12_1;
  end if;

end GF12_1;

-- Final part of the circuit: XOR and output

architecture Big_XOR_12_1 of CRC_top is

begin  -- Big_XOR_12_1

  port map (
    input_bigx12_1  => input_bigx12_1,
    output_bigx12_1 => input_fcs13_2(15 downto 0));

  output_bigx12_1 (15 => (input_bigx12_1(15) xor output12_1(15)),
                   14 => (input_bigx12_1(14) xor output12_1(14)),
                   13 => (input_bigx12_1(13) xor output12_1(13)),
                   12 => (input_bigx12_1(12) xor output12_1(12)),
                   11 => (input_bigx12_1(11) xor output12_1(11)),
                   10 => (input_bigx12_1(10) xor output12_1(10)),
                    9 => (input_bigx12_1(9) xor output12_1(9)),
                    8 => (input_bigx12_1(8) xor output12_1(8)),
                    7 => (input_bigx12_1(7) xor output12_1(7)),
                    6 => (input_bigx12_1(6) xor output12_1(6)),
                    5 => (input_bigx12_1(5) xor output12_1(5)),
                    4 => (input_bigx12_1(4) xor output12_1(4)),
                    3 => (input_bigx12_1(3) xor output12_1(3)),
                    2 => (input_bigx12_1(2) xor output12_1(2)),
                    1 => (input_bigx12_1(1) xor output12_1(1)),
                    0 => (input_bigx12_1(0) xor output12_1(0)));

end Big_XOR_12_1;

architecture FCS_out_13_2 of CRC_top is

begin  -- FCS_out_13_2

  port map (
    reset                       => reset,
    phi2                        => phi2,
    input_fcs13_2(15 downto 0)  => output_bigx12_1,
    input_fcs13_2(31 downto 16) => output_gf12_1,
    output_fcs13_2              => input_gf1x_2, output_fcs13_2);

end FCS_out_13_2;
