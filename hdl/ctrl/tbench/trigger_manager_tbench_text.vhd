-------------------------------------------------------------------------------------------------100
--| Modular Oscilloscope
--| UNSL - Argentine
--|
--| File: trigger_manager_tbench_text.vhd
--| Version: 0.01
--| Tested in: Actel A3PE1500
--|-------------------------------------------------------------------------------------------------
--| Description:
--|   This file is only for test purposes. 
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
use ieee.std_logic_unsigned.all;
library syncad_vhdl_lib;
use syncad_vhdl_lib.TBDefinitions.all;
use IEEE.NUMERIC_STD.ALL;



-- Additional libraries used by Model Under Test.
use ieee.math_real.all;



----------------------------------------------------------------------------------------------------
entity stimulus is
  generic (
    MEM_ADD_WIDTH:  integer := 14;
    DATA_WIDTH:     integer := 10;
    CHANNELS_WIDTH: integer := 4
  );
  port (
    data_I:           inout  std_logic_vector (DATA_WIDTH - 1 downto 0);
    channel_I:        inout  std_logic_vector (CHANNELS_WIDTH -1 downto 0);
    trig_channel_I:   inout  std_logic_vector (CHANNELS_WIDTH -1 downto 0);
    address_I:        inout  std_logic_vector (MEM_ADD_WIDTH - 1 downto 0);
    final_address_I:  inout  std_logic_vector (MEM_ADD_WIDTH - 1 downto 0);
    offset_I:         inout std_logic_vector (MEM_ADD_WIDTH  downto 0);
    level_I:          inout  std_logic_vector (DATA_WIDTH - 1 downto 0);
    falling_I:        inout  std_logic; 
    clk_I:            inout  std_logic;
    reset_I:          inout  std_logic;
    enable_I:         inout  std_logic
   
  );

end stimulus;

architecture STIMULATOR of stimulus is

  -- Control Signal Declarations
  signal tb_status : TStatus;
  signal tb_ParameterInitFlag : boolean := false;

  -- Parm Declarations
  signal T : real := 10.0;
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
    clk_Period_real := T; --<--<--<--<--<--<--<--<--<--<--<--<--<--<--<--<--
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
  Var: process
  begin
    data_I <= (others => '0');
    channel_I <= (others => '0');
    
    while tb_status /= TB_DONE loop
      wait for T * 1 ns;    
      data_I <= std_logic_vector(unsigned(data_I)+1);
      channel_I <= std_logic_vector(unsigned(channel_I)+1);
    end loop;
    wait;
  
  end process;

  
  --------------------------------------------------------------------------------------------------
  -- Sequence: Unclocked
  Unclocked : process
    variable i: natural range 0 to integer(2.0**real(address_I'length));
    variable j: natural range 0 to 500;
    --variable max: integer range<>;
  begin
    wait until tb_ParameterInitFlag;
    tb_status <= TB_ONCE;
    ------------------------------------------------------------------------------------------------
    -- Initial
    

    trig_channel_I  <=            "0010";
    address_I       <= (others => '0');
    final_address_I <=  "11110000000000";
    offset_I        <= "001110001111011";
    level_I         <=      "1101000101";
    falling_I       <= '0';
    reset_I         <= '1';
    enable_I        <= '1';
      wait for 3.5 * T * 1 ns;     
    
    reset_I <= '0';
      wait for T * 1 ns;     
      
    for j in 0 to 1 loop
      for i in 0 to to_integer(unsigned(final_address_I)) loop
      
        address_I <= std_logic_vector(to_unsigned(i, address_I'length ));
          wait for T * 1 ns;
      end loop;
    end loop;
    
    ------------------------------------------------------------------------------------------------
    -- test falling
    reset_I         <= '1';
    falling_I       <= '1';
      wait for T * 1 ns;
    
    reset_I         <= '0';
      
    for j in 0 to 1 loop
      for i in 0 to to_integer(unsigned(final_address_I)) loop
        address_I <= std_logic_vector(to_unsigned(i, address_I'length ));
          wait for T * 1 ns;
      end loop;
    end loop;
    
    ------------------------------------------------------------------------------------------------
    -- test big offset
    reset_I         <= '1';
    falling_I       <= '0';
   -- address_I       <=  "10011111111111";
    offset_I        <= "011101010011000";
      wait for T * 1 ns;
    
    reset_I         <= '0';
      
    --for j in 0 to 1 loop
      for i in 0 to to_integer(unsigned(final_address_I)) loop
        address_I <= std_logic_vector(to_unsigned(i, address_I'length ));
          wait for T * 1 ns;
      end loop;
    --end loop;
    
   ------------------------------------------------------------------------------------------------
    -- test negative offset
    reset_I         <= '1';
    falling_I       <= '0';
    -- address_I       <=  "10011111111111";
    offset_I        <= "111101001010110";
      wait for T * 1 ns;
    
    reset_I         <= '0';
      
    --for j in 0 to 1 loop
      for i in 0 to to_integer(unsigned(final_address_I)) loop
        address_I <= std_logic_vector(to_unsigned(i, address_I'length ));
          wait for T * 1 ns;
      end loop;
    --end loop;
    
    ------------------------------------------------------------------------------------------------
    -- test zero offset
    
    reset_I         <= '1';
    falling_I       <= '0';
    -- address_I       <=  "10011111111111";
    offset_I        <= "000000000000000";
      wait for T * 1 ns;
    
    reset_I         <= '0';
      
    --for j in 0 to 1 loop
      for i in 0 to to_integer(unsigned(final_address_I)) loop
        address_I <= std_logic_vector(to_unsigned(i, address_I'length ));
          wait for T * 1 ns;
      end loop;
    --end loop;
    
    ------------------------------------------------------------------------------------------------
    -- test big offset
    
    reset_I         <= '1';
    falling_I       <= '0';
    -- address_I       <=  "10011111111111";
    offset_I        <= "100010000000000";
      wait for T * 1 ns;
    
    reset_I         <= '0';
      
    --for j in 0 to 1 loop
      for i in 0 to to_integer(unsigned(final_address_I)) loop
        address_I <= std_logic_vector(to_unsigned(i, address_I'length ));
          wait for T * 1 ns;
      end loop;
    --end loop;
    
    ------------------------------------------------------------------------------------------------
    -- test big final_address_I
                  
    final_address_I <=  "11111111111111";
    reset_I         <= '1';
    falling_I       <= '0';
    -- address_I         <=  "10011111111111";
    offset_I        <= "011111010000000";
      wait for T * 1 ns;
    
    reset_I         <= '0';
      
    --for j in 0 to 1 loop
      for i in 0 to to_integer(unsigned(final_address_I)) loop
        address_I <= std_logic_vector(to_unsigned(i, address_I'length ));
          wait for T * 1 ns;
      end loop;
    --end loop;
    
    tb_status <= TB_DONE;  -- End of simulation
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
  generic (
    MEM_ADD_WIDTH:  integer := 14;
    DATA_WIDTH:     integer := 10;
    CHANNELS_WIDTH: integer := 4
  );
end testbench;

architecture tbGeneratedCode of testbench is
    signal data_I:             std_logic_vector (DATA_WIDTH - 1 downto 0);
    signal channel_I:          std_logic_vector (CHANNELS_WIDTH -1 downto 0);
    signal trig_channel_I:     std_logic_vector (CHANNELS_WIDTH -1 downto 0);
    signal address_I:          std_logic_vector (MEM_ADD_WIDTH - 1 downto 0);
    signal final_address_I:    std_logic_vector (MEM_ADD_WIDTH - 1 downto 0);
    signal offset_I:          std_logic_vector (MEM_ADD_WIDTH  downto 0);
    signal level_I:            std_logic_vector (DATA_WIDTH - 1 downto 0);
    signal falling_I:        std_logic; 
    signal clk_I:            std_logic;
    signal reset_I:          std_logic;
    signal enable_I:         std_logic;
    signal trigger_O:         std_logic;
    signal address_O:         std_logic_vector (MEM_ADD_WIDTH - 1 downto 0);

begin
  --------------------------------------------------------------------------------------------------
  -- Instantiation of Stimulus.
  stimulus_0 : entity work.stimulus
    generic map (
     
    MEM_ADD_WIDTH=> MEM_ADD_WIDTH,
    DATA_WIDTH => DATA_WIDTH,
    CHANNELS_WIDTH => CHANNELS_WIDTH
    )
    port map (
    data_I => data_I,
    channel_I => channel_I,
    trig_channel_I => trig_channel_I,
    address_I => address_I,
    final_address_I => final_address_I,
    offset_I => offset_I,
    level_I => level_I,
    falling_I => falling_I,
    clk_I => clk_I,
    reset_I => reset_I,
    enable_I => enable_I
    );

  --------------------------------------------------------------------------------------------------
  -- Instantiation of Model Under Test.
  trig_0 : entity work.trigger_manager --<--<--<--<--<--<--<--<--<--<--<--<--<--<--<--<--
    generic map (
     
    MEM_ADD_WIDTH=> MEM_ADD_WIDTH,
    DATA_WIDTH => DATA_WIDTH,
    CHANNELS_WIDTH => CHANNELS_WIDTH
    )
    port map (
    data_I => data_I,
    channel_I => channel_I,
    trig_channel_I => trig_channel_I,
    address_I => address_I,
    final_address_I => final_address_I,
    offset_I => offset_I,
    level_I => level_I,
    falling_I => falling_I,
    clk_I => clk_I,
    reset_I => reset_I,
    enable_I => enable_I, 
        trigger_O => trigger_O,
    
    address_O => address_O
    );
end tbGeneratedCode;
----------------------------------------------------------------------------------------------------
