-------------------------------------------------------------------------------------------------100
--| Modular Oscilloscope
--| UNSL - Argentine
--|
--| File: data_skipper_tbench_text.vhd
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
use IEEE.NUMERIC_STD.ALL;



-- Additional libraries used by Model Under Test.
use work.ctrl_pkg.all;
use ieee.math_real.all;



----------------------------------------------------------------------------------------------------
entity stimulus is
  generic(
    SELECTOR_WIDTH: integer :=  5  -- max looses = 2**(2**SELECTOR_WIDTH)
  );
  port(
    -- sinal from wishbone interface
    ack_I, stb_I:     inout  std_logic;  
    -- selector from register
    selector_I:       inout   std_logic_vector(SELECTOR_WIDTH-1 downto 0);
    -- enable from register 
    enable_skipper_I: inout   std_logic;
    -- common signals
    reset_I, clk_I:   inout   std_logic;
    first_channel_I:  inout   std_logic
  );

end stimulus;

architecture STIMULATOR of stimulus is
  -- Period
  constant T: real := 10.0;
  
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

  --<=============================================================================================
  -- Clocked Sequences
  -- ...
  --===============================================================================================>


  --<===============================================================================================
  -- Sequence: Unclocked
  P_FirstCh: process
  begin
    wait until tb_ParameterInitFlag;
    first_channel_I <= '0';
      wait for T*1.5 ns;
    while tb_status = TB_ONCE loop
      first_channel_I <= '1';
        wait for T * 1 ns; --<delay>
      first_channel_I <= '0';
        wait for 4.0 * T * 1 ns;
    end loop;
    
    wait;
  end process;
  
  P_Unclocked : process
    variable i: natural range 0 to 500;
  begin
       wait until tb_ParameterInitFlag;
    tb_status <= TB_ONCE;


    -- Initial
    reset_I <= '1' ;
    ack_I <= '0'; stb_I <= '0';
    enable_skipper_I <= '1';
    selector_I <= (others => '0');    
      wait for T*1.5 ns; --<delay>
    
    -- w/o en_skip
    reset_I <= '0';
      wait for T * 1 ns; --<delay>
      
    ack_I <= '1';
      wait for T * 1 ns; --<delay>
      
    ack_I <= '0'; stb_I <= '1';      
      wait for T * 1 ns; --<delay>
    
    ack_I <= '1'; stb_I <= '1';
      wait for (3.0*T) * 1 ns; --<delay>
      
    -- w/ en_skip
    enable_skipper_I <= '1';
      wait for 10.0*T * 1 ns; --<delay>

    ack_I <= '1'; stb_I <= '0';
      wait for 4.0 * T * 1 ns; --<delay>
    
    ack_I <= '0'; stb_I <= '1';
      wait for 4.0*T *4.0* 1 ns; --<delay>
    
    -- selector_I /= 0
    ack_I <= '1'; stb_I <= '1'; selector_I <= std_logic_vector(unsigned(selector_I) + 1);
      wait for 20.0*T*4.0 * 1 ns; --<delay>
    
    selector_I <= std_logic_vector(to_unsigned( integer(2**real(selector_I'length )/10.0), selector_I'length ));
      wait for 4000.0*T*4.0 * 1 ns;
    
    selector_I <= std_logic_vector(to_unsigned( integer(2**real(selector_I'length )/4.0), selector_I'length ));
      wait for 4000.0*T*4.0 * 1 ns; --<delay>
    
    selector_I <= std_logic_vector(to_unsigned( integer(2**real(selector_I'length )-1.0), selector_I'length ));
      wait for 100000.0*T *4.0* 1 ns; --<delay>
    

    
      
    
    
    tb_status <= TB_DONE;  -- End of simulation
    wait;
    
  end process;
  --===============================================================================================>
  
  
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
    constant SELECTOR_WIDTH: integer :=  5;
      -- enable output signal
    signal ack_O:              std_logic;   
    -- sinal from wishbone interface
    signal ack_I, stb_I:       std_logic;  
    -- selector from register
    signal selector_I:          std_logic_vector(SELECTOR_WIDTH-1 downto 0);
    -- enable from register 
    signal enable_skipper_I:    std_logic;
    -- common signals
    signal reset_I, clk_I:      std_logic;
    signal first_channel_I:     std_logic;

begin
  --------------------------------------------------------------------------------------------------
  -- Instantiation of Stimulus.
  U_stimulus_0 : entity work.stimulus --<--<--<--<--<--<--<--<--<--<--<--<--<--<--<--<--
  generic map(
    SELECTOR_WIDTH => SELECTOR_WIDTH
  )
  port map (
    ack_I => ack_I,
    stb_I => stb_I,
    selector_I => selector_I,
    enable_skipper_I => enable_skipper_I,
    reset_I => reset_I,
    clk_I => clk_I,
    first_channel_I => first_channel_I
  );

  --------------------------------------------------------------------------------------------------
  -- Instantiation of Model Under Test.
  U_skip_0 : entity work.data_skipper --<--<--<--<--<--<--<--<--<--<--<--<--<--<--<--<--
  generic map(
    SELECTOR_WIDTH => 5
  )
  port map (
    ack_O => ack_O,
    ack_I => ack_I,
    stb_I => stb_I,
    selector_I => selector_I,
    enable_skipper_I => enable_skipper_I,
    reset_I => reset_I,
    first_channel_I => first_channel_I,
    clk_I => clk_I
  );
end tbGeneratedCode;
----------------------------------------------------------------------------------------------------
