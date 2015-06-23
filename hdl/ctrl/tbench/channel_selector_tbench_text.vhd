-------------------------------------------------------------------------------------------------100
--| Modular Oscilloscope
--| UNSL - Argentine
--|
--| File: channel_selector_tbench_text.vhd
--| Version: 0.01
--| Tested in: Actel A3PE1500
--|-------------------------------------------------------------------------------------------------
--| Description:
--|   Adquisition control module. 
--|   This file is only for test purposes. Testing daq. Test bench.
--|   It may not work for other than Actel Libero software.
--|-------------------------------------------------------------------------------------------------
--| File history:
--|   0.01  | apr-2009 | First release
----------------------------------------------------------------------------------------------------
--| Copyright © 2009, Facundo Aguilera.
--|
--| This VHDL design file is an open design; you can redistribute it and/or
--| modify it and/or implement it after contacting the author.
----------------------------------------------------------------------------------------------------


-- NOTE:  It may not work for other than Actel Libero software.
--        You can download Libero for free from Actel website (it is not a free software).



library ieee, std;
use ieee.std_logic_1164.all;
library syncad_vhdl_lib;
use syncad_vhdl_lib.TBDefinitions.all;

-- Additional libraries used by Model Under Test.
-- ...



----------------------------------------------------------------------------------------------------
entity stimulus is
  port (

    channels_I:   inout  std_logic_vector(15 downto 0);
    clk_I:        inout  std_logic;
    enable_I:     inout  std_logic;
    reset_I:      inout  std_logic     
  
  );

end stimulus;

architecture STIMULATOR of stimulus is

  -- Control Signal Declarations
  signal tb_status : TStatus;
  signal tb_ParameterInitFlag : boolean := false;

  -- Parm Declarations
  signal clk_MinHL :  time := 0 ns;
  signal clk_MaxHL :  time := 0 ns;
  signal clk_MinLH :  time := 0 ns;
  signal clk_MaxLH :  time := 0 ns;
  signal clk_JFall :  time := 0 ns;
  signal clk_JRise :  time := 0 ns;
  signal clk_Duty :   real := 0.0;
  signal clk_Period : time := 0 ns;
  signal clk_Offset : time := 0 ns;

  

begin
  --------------------------------------------------------------------------------------------------
  -- Status Control block.
  process
    -- variable good : boolean;
  begin
    wait until tb_ParameterInitFlag;
    tb_status <= TB_ONCE;
    wait for 3000 ns;
    tb_status <= TB_DONE;  -- End of simulation
    wait;
  end process;

  --------------------------------------------------------------------------------------------------
  -- Parm Assignment Block
  AssignParms : process
    variable clk_MinHL_real :   real;
    variable clk_MaxHL_real :   real;
    variable clk_MinLH_real :   real;
    variable clk_MaxLH_real :   real;
    variable clk_JFall_real :   real;
    variable clk_JRise_real :   real;
    variable clk_Duty_real :    real;
    variable clk_Period_real :  real;
    variable clk_Offset_real :  real;
  begin
    -- Basic parameters
    clk_Period_real := 20.0; --<--<--<--<--<--<--<--<--<--<--<--<--<--<--<--<--
    clk_Period <= clk_Period_real * 1 ns;
    clk_Duty_real := 50.0;
    clk_Duty <= clk_Duty_real;
    
    -- Aditionale parameters
    clk_MinHL_real := 0.0;
    clk_MinHL <= clk_MinHL_real * 1 ns;
    clk_MaxHL_real := 0.0;
    clk_MaxHL <= clk_MaxHL_real * 1 ns;
    clk_MinLH_real := 0.0;
    clk_MinLH <= clk_MinLH_real * 1 ns;
    clk_MaxLH_real := 0.0;
    clk_MaxLH <= clk_MaxLH_real * 1 ns;
    clk_JFall_real := 0.0;
    clk_JFall <= clk_JFall_real * 1 ns;
    clk_JRise_real := 0.0;
    clk_JRise <= clk_JRise_real * 1 ns;
    clk_Offset_real := 0.0;
    clk_Offset <= clk_Offset_real * 1 ns;
    tb_ParameterInitFlag <= true;
    
    wait;
  end process;
  
  
  --------------------------------------------------------------------------------------------------
  -- Clocks
  -- Clock Instantiation
  tb_clk : entity syncad_vhdl_lib.tb_clock_minmax
    generic map (name => "tb_clk",
                initialize => true,
                state1 => '1',
                state2 => '0')
    port map (tb_status,
              clk_I, --<--<--<--<--<--<--<--<--<--<--<--<--<--<--<--<--
              clk_MinLH,
              clk_MaxLH,
              clk_MinHL,
              clk_MaxHL,
              clk_Offset,
              clk_Period,
              clk_Duty,
              clk_JRise,
              clk_JFall);

  -- Clocked Sequences
  -- ...


  --------------------------------------------------------------------------------------------------
  -- Sequence: Unclocked
  Unclocked : process
  begin
    -- Initial values
    channels_I <= "1100011011000110";
    enable_I <= '1'; 
    
    -- Expected output
    -- 1
    -- 2
    -- 6
    -- 7
    -- 9
    -- 10
    -- 14
    -- 15
    -- 1
    -- 2
    -- 6
    -- ...
    
    
    
    -- Initial reset
    wait for 0 ns;
    reset_I <= '1';
    wait for 35 ns;
    reset_I <= '0';

    wait for 260 ns;  enable_I <= '0'; 
    wait for 40 ns;   enable_I <= '1'; 
    
    
    wait for 80 ns;   enable_I <= '0'; 
    wait for 80 ns;   enable_I <= '1'; 
    
    
    wait for 100 ns;  reset_I  <= '1'; 
    wait for 40 ns;   reset_I  <= '0'; 
    
    
    wait for 100 ns; channels_I <= "0000000000000001";
    wait for 200 ns; channels_I <= "0000000000001001";
    wait for 200 ns; channels_I <= "1000000000000010";
    
    wait for 100 ns;  reset_I  <= '1'; 
    wait for 40 ns;   reset_I  <= '0'; 
    
    wait for 200 ns; channels_I <= "0000000000000000";
    
 
    
    
    

    
    --wait for 3000 ns;
    wait;
    
  end process;
end STIMULATOR;
----------------------------------------------------------------------------------------------------




-- Test Bench wrapper for stimulus and Model Under Test
 library ieee, std;
 use ieee.std_logic_1164.all;
 library syncad_vhdl_lib;
 use syncad_vhdl_lib.TBDefinitions.all;

-- Additional libraries used by Model Under Test.
-- ...



----------------------------------------------------------------------------------------------------
entity testbench is
end testbench;

architecture tbGeneratedCode of testbench is
    signal channels_I:         std_logic_vector(15 downto 0);
    signal channel_number_O:   std_logic_vector(3 downto 0);
    signal clk_I:              std_logic;
    signal enable_I:           std_logic;
    signal reset_I:            std_logic;
    signal first_channel_O:    std_logic;

begin
  --------------------------------------------------------------------------------------------------
  -- Instantiation of Stimulus.
  stimulus_0 : entity work.stimulus
    port map (
      channels_I        => channels_I,
      clk_I             => clk_I,
      enable_I          => enable_I,
      reset_I           => reset_I
    );

  --------------------------------------------------------------------------------------------------
  -- Instantiation of Model Under Test.
  chsel_0 : entity work.channel_selector
  port map (
    channels_I        => channels_I,
    channel_number_O  => channel_number_O,
    clk_I             => clk_I,
    enable_I          => enable_I,
    reset_I           => reset_I,
    first_channel_O   => first_channel_O
   );
end tbGeneratedCode;
----------------------------------------------------------------------------------------------------
