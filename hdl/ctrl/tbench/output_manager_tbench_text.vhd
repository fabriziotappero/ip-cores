-------------------------------------------------------------------------------------------------100
--| Modular Oscilloscope
--| UNSL - Argentine
--|
--| File: ctrl_output_manager_tbench_text.vhd
--| Version: 0.01
--| Tested in: Actel A3PE1500
--|-------------------------------------------------------------------------------------------------
--| Description:
--|   This file is only for test purposes. 
--|-------------------------------------------------------------------------------------------------
--| File history:
--|   0.01  | jul-2009 | First release
----------------------------------------------------------------------------------------------------
--| Copyright © 2009, Facundo Aguilera.
--|
--| This VHDL design file is an open design; you can redistribute it and/or
--| modify it and/or implement it after contacting the author.
----------------------------------------------------------------------------------------------------





-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> 
library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;
  
entity ctrl_tb_simple_clock is
  port ( 
    CLK_PERIOD: in time;-- := 20 ns;
    CLK_DUTY:  in  real; -- := 0.5;
    active:  in     boolean;
    clk_o:   out    std_logic
  );
end entity ctrl_tb_simple_clock ;
 
architecture beh of ctrl_tb_simple_clock is
begin
  P_main: process
  begin
    wait until active;
    while (active = true) loop
      clk_o <= '0';
      wait for CLK_PERIOD * (100.0 - clk_Duty)/100.0;
      clk_o <= '1';
      wait for CLK_PERIOD * clk_Duty/100.0;
    end loop;                   
    clk_o <= '0';
    wait;      
  end process;
end architecture beh;



-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
library ieee, std;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use IEEE.NUMERIC_STD.ALL;


-- Additional libraries used by Model Under Test.
use ieee.math_real.all;

entity stimulus is
   generic(
    MEM_ADD_WIDTH: integer :=  14
  );
  port(
    ACK_I_mem: inout std_logic ;
    DAT_I_mem: inout std_logic_vector (15 downto 0);
    
    CYC_I_port: inout std_logic;  
    STB_I_port: inout std_logic;  
    WE_I_port:  inout std_logic;
    RST_I:      inout std_logic;  
    CLK_I:      inout std_logic;  
   
    load_I:             inout std_logic;                     
    enable_I:           inout std_logic;                     
    initial_address_I:  inout std_logic_vector (MEM_ADD_WIDTH - 1 downto 0);
    biggest_address_I:  inout std_logic_vector (MEM_ADD_WIDTH - 1 downto 0);
    pause_address_I:    inout std_logic_vector (MEM_ADD_WIDTH - 1 downto 0);
    
    finish_O:  in std_logic;
    CYC_O_mem:  in std_logic;
    STB_O_mem:  in std_logic;
    ADR_O_mem: in std_logic_vector (MEM_ADD_WIDTH - 1 downto 0)
  );

end stimulus;

architecture STIMULATOR of stimulus is

  -- Control Signal Declarations
  signal tb_InitFlag : boolean := false;
  signal tb_ParameterInitFlag : boolean := false;
  signal i: std_logic;

  
  -- Parm Declarations
  signal clk_Duty :   real := 0.0;
  signal clk_Period : time := 0 ns;
  

begin
  --------------------------------------------------------------------------------------------------
  -- Parm Assignment Block
  AssignParms : process
    variable clk_Duty_real :    real;
    variable clk_Period_real :  real;
  begin
    -- Basic parameters
    clk_Period_real := 20.0; --<--<--<--<--<--<--<--<--<--<--<--<--<--<--<--<--
    clk_Period <= clk_Period_real * 1 ns;
    clk_Duty_real := 50.0;
    clk_Duty <= clk_Duty_real;

    tb_ParameterInitFlag <= true;
    
    wait;
  end process;
  
  
  --------------------------------------------------------------------------------------------------
  -- Clocks
  -- Clock Instantiation
  tb_clk: entity work.tb_simple_clock 
  port map ( 
    clk_Period => clk_Period,
    clk_Duty => clk_Duty,
    active => tb_InitFlag,
    clk_o => CLK_I
  );
 
  
  --------------------------------------------------------------------------------------------------
  -- Clocked Sequences


  
  --------------------------------------------------------------------------------------------------
  -- Sequence: Unclocked
  Unclocked : process
    
  begin
    wait until tb_ParameterInitFlag;
    tb_InitFlag <= true;
    
    load_I <= '0';
    RST_I <= '1';
    STB_I_port <= '1';
    CYC_I_port <= '1';
    WE_I_port <= '0';
    initial_address_I <= B"01_0000_0000_0000";
    biggest_address_I <= B"11_1100_0000_0000";
    pause_address_I   <= B"00_0000_1000_0000";
    enable_I <= '1';
      wait for 1.5 * clk_Period;
    
    RST_I <= '0';
      wait for 1.0 * clk_Period;
    
    load_I <= '1';    
      wait for 1.0 * clk_Period;
    
      
      
    
    load_I <= '0';    
    wait until ADR_O_mem = B"00_0000_1000_0000";
      wait for 8.0 * clk_Period;
    
    pause_address_I   <= B"01_0000_0000_0000";
      wait for 20.0 * clk_Period;
      
    enable_I <= '0';
      wait for 8.0 * clk_Period;
    
    enable_I <= '1';
      
      
    wait until finish_O = '1';
      wait for 2.0 * clk_Period;
    
    tb_InitFlag <= false;
    wait;
    
    
  end process;
  
  
  
  --------------------------------------------------------------------------------------------------
  -- Conditional signals
  
  P_mem: process(STB_O_mem, DAT_I_mem, CYC_O_mem, CLK_I, RST_I,i)
    
  begin
    if STB_O_mem = '1' and CYC_O_mem = '1' and i = '1' then
      ACK_I_mem <= '1';
    else
      ACK_I_mem <= '0';
    end if;
    
    if CLK_I'event and CLK_I = '1' then 
      if RST_I = '1' then 
        DAT_I_mem <= (others => '0');
      elsif STB_O_mem = '1' and CYC_O_mem = '1' and i = '1' then 
        DAT_I_mem <= DAT_I_mem + 1;
      end if;
    end if;
    
    if CLK_I'event and CLK_I = '1' then 
      if RST_I = '1' then 
        i <= '0';
      elsif STB_O_mem = '1' and CYC_O_mem = '1' then 
        i <= not(i);
      end if;
    end if;
    
  end process;
  
  
  
end architecture STIMULATOR;


 






-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 library ieee, std;
 use ieee.std_logic_1164.all;
 
 

-- Additional libraries used by Model Under Test.
-- ...

entity testbench is
  generic (
    MEM_ADD_WIDTH:  integer := 14
  );
end testbench;

architecture tbGeneratedCode of testbench is
    signal DAT_I_mem:  std_logic_vector (15 downto 0);
    signal ADR_O_mem:  std_logic_vector (MEM_ADD_WIDTH - 1  downto 0);   
    signal CYC_O_mem: std_logic;  
    signal STB_O_mem: std_logic;  
    signal ACK_I_mem: std_logic ;
    signal WE_O_mem:  std_logic;
    signal DAT_O_port: std_logic_vector (15 downto 0);
    signal CYC_I_port: std_logic;  
    signal STB_I_port: std_logic;  
    signal ACK_O_port: std_logic ;
    signal WE_I_port:  std_logic;
    signal RST_I: std_logic;  
    signal CLK_I:             std_logic;  
    signal load_I:             std_logic;                     
    signal enable_I:           std_logic;                     
    signal initial_address_I:  std_logic_vector (MEM_ADD_WIDTH - 1 downto 0);
    signal biggest_address_I:  std_logic_vector (MEM_ADD_WIDTH - 1 downto 0);
    signal pause_address_I:    std_logic_vector (MEM_ADD_WIDTH - 1 downto 0);
    signal finish_O:           std_logic;

begin
  --------------------------------------------------------------------------------------------------
  -- Instantiation of Stimulus.
  U_stimulus_0 : entity work.stimulus
    generic map (
    MEM_ADD_WIDTH=> MEM_ADD_WIDTH
    )
    port map (
      ACK_I_mem => ACK_I_mem,
      DAT_I_mem => DAT_I_mem,
      CYC_I_port => CYC_I_port,
      STB_I_port => STB_I_port,
      WE_I_port => WE_I_port,
      RST_I => RST_I,
      CLK_I => CLK_I,
      load_I => load_I,
      enable_I => enable_I,
      initial_address_I => initial_address_I,
      biggest_address_I => biggest_address_I,
      pause_address_I => pause_address_I,
      
      
      finish_O => finish_O,
      CYC_O_mem => CYC_O_mem,
      STB_O_mem => STB_O_mem,
      ADR_O_mem => ADR_O_mem
    );

  --------------------------------------------------------------------------------------------------
  -- Instantiation of Model Under Test.
  U_outman_0 : entity work.output_manager --<--<--<--<--<--<--<--<--<--<--<--<--<--<--<--<--
    generic map (
     
    MEM_ADD_WIDTH=> MEM_ADD_WIDTH
    )
    port map (
      DAT_I_mem => DAT_I_mem,
      ADR_O_mem => ADR_O_mem,
      CYC_O_mem => CYC_O_mem,
      STB_O_mem => STB_O_mem,
      ACK_I_mem => ACK_I_mem,
      WE_O_mem => WE_O_mem,
      DAT_O_port => DAT_O_port,
      CYC_I_port => CYC_I_port,
      STB_I_port => STB_I_port,
      ACK_O_port => ACK_O_port,
      WE_I_port => WE_I_port,
      RST_I => RST_I,
      CLK_I => CLK_I,
      load_I => load_I,
      enable_I => enable_I,
      initial_address_I => initial_address_I,
      biggest_address_I => biggest_address_I,
      pause_address_I => pause_address_I,
      finish_O => finish_O
    );
    
--   U_mem0: entity work.dual_port_memory_wb
--   port map(
--     -- Port A (Higer prioriry)
--     RST_I_a => '0',
--     CLK_I_a => '0',
--     DAT_I_a => (others => '0'),
--     DAT_O_a => open,
--     ADR_I_a => '0',
--     CYC_I_a => '0',
--     STB_I_a => '0',
--     ACK_O_a => open,
--     WE_I_a => '0',
--     
--     -- Port B (Lower prioriry)
--     RST_I_b => RST_I,
--     CLK_I_b => CLK_I,
--     DAT_I_b => (others => '0'),
--     DAT_O_b => DAT_I_mem,
--     ADR_I_b => ADR_O_mem,
--     CYC_I_b => CYC_O_mem,
--     STB_I_b => STB_O_mem,
--     ACK_O_b => ACK_I_mem,
--     WE_I_b => WE_O_mem
--     );
    
end tbGeneratedCode;
----------------------------------------------------------------------------------------------------
