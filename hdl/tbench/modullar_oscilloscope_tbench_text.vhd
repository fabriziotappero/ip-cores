-------------------------------------------------------------------------------------------------100
--| Modular Oscilloscope
--| UNSL - Argentine
--|
--| File: modullar_oscilloscope_tbench_text.vhd
--| Version: 0.1
--| Tested in: Actel A3PE1500
--|   Board: RVI Prototype Board + LP Data Conversion Daughter Board
--|-------------------------------------------------------------------------------------------------
--| Description:
--|   This file is only for test purposes. 
--|
--|-------------------------------------------------------------------------------------------------
--| File history:
--|   0.1   | aug-2009 | First release
----------------------------------------------------------------------------------------------------
--| Copyright © 2009, Facundo Aguilera (budinero at gmail.com.
--|
--| This VHDL design file is an open design; you can redistribute it and/or
--| modify it and/or implement it after contacting the author.
----------------------------------------------------------------------------------------------------

--==================================================================================================
-- TO DO
-- · Full full test
--==================================================================================================

-- NOTES
-- · Board clock freq = 25 MHz
-- · PLL clocks: clk_epp freq = 10 MHz, clk_epp freq = 40 MHz

-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> 
-->> Virtual clock
library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;


  
entity tb_simple_clock is
  port ( 
    CLK_PERIOD: in time;-- := 20 ns;
    CLK_DUTY:  in  real; -- := 0.5;
    active:  in     boolean;
    clk_o:   out    std_logic
  );
end entity tb_simple_clock ;
 
architecture beh of tb_simple_clock is
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
-->> Virtual ADC
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity virtual_adc is
  port ( 
    clk_I:        in  std_logic;
    sel_I:        in  std_logic;
    chip_sel_I:   in  std_logic;
    sleep_I:      in  std_logic;
    data_O:       out std_logic_vector(9 downto 0)
  );
end entity virtual_adc ;
 
architecture beh of virtual_adc is
    signal data1: std_logic_vector(9 downto 0) := "0000000001"; -- odd
    signal data2: std_logic_vector(9 downto 0) := (others => '0'); -- pair  
begin

  P_virtual_adc: process (clk_I, sel_I, chip_sel_I, sleep_I)

  begin                                             
    if clk_I'event and clk_I = '1' then
      data1 <= data1 + 2;
      data2 <= data2 + 2;
    end if;  
  
    if sleep_I = '1' or chip_sel_I = '1' then
      data_O <= (others => '0');
    else
      case sel_I is
        when '0' => 
          data_O <= data1;
        when others => 
          data_O <= data2;   
      end case;
    end if;
    
  end process;

end architecture beh;

-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-->> Stimulus
library ieee, std;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
--use IEEE.NUMERIC_STD.ALL;
use ieee.math_real.all;


-- Additional libraries used by Model Under Test.
use work.ctrl_pkg.all;
use work.daq_pkg.all;
use work.memory_pkg.all;
use work.eppwbn_pkg.all;

entity stimulus is
  port(
 -- ADC
    adc_data_I:     inout    std_logic_vector (9 downto 0) := (others => '0');
    adc_sel_O:      in   std_logic;
    adc_clk_O:      in   std_logic;
    adc_sleep_O:    in   std_logic;
    adc_chip_sel_O: in   std_logic;

    -- EPP
    nStrobe_I:      inout std_logic;                       --  HostClk/nWrite 
    Data_IO:        inout std_logic_vector (7 downto 0);--   AD8..1 (Data1..Data8)
    nAck_O:         in std_logic;                      --  PtrClk/PeriphClk/Intr
    Busy_O:         in std_logic;                      --  PtrBusy/PeriphAck/nWait
    PError_O:       in std_logic;                      --  AckData/nAckReverse
    Sel_O:          in std_logic;                      --  XFlag (Select)
    nAutoFd_I:      inout std_logic;                       --  HostBusy/HostAck/nDStrb
    PeriphLogicH_O: in std_logic;                      --  (Periph Logic High)
    nInit_I:        inout std_logic;                       --  nReverseRequest
    nFault_O:       in std_logic;                      --  nDataAvail/nPeriphRequest
    nSelectIn_I:    inout std_logic;                       --  1284 Active/nAStrb
    
    -- Peripherals
    reset_I:    inout std_logic; 
    pll_clk_I:  inout std_logic;  -- clock signal go to pll, and is divided in two clocks
    
    test_number: out integer range 0 to 20
  );

end stimulus;

architecture STIMULATOR of stimulus is
  -- PLL clocks
  constant CLK_DAQ_PERIOD: time := 25  ns;
  constant CLK_EPP_PERIOD: time := 100 ns;
  
  -- Control Signal Declarations
  signal tb_InitFlag : boolean := false;
  signal tb_ParameterInitFlag : boolean := false;
  
  signal runflag: std_logic;
  
  -- Parm Declarations
  signal clk_Duty :   real := 0.0;
  signal clk_Period : time := 0 ns;
  
begin
  --------------------------------------------------------------------------------------------------
  -- Parm Assignment Block
  P_AssignParms : process
    variable clk_Duty_real :    real;
    variable clk_Period_real :  real;
  begin
    -- Basic parameters
    clk_Period_real := 40.0; --<--<--<--<--<--<--<--<--<--<--<--<--<--<--<--<--
    clk_Period <= clk_Period_real * 1 ns;
    clk_Duty_real := 50.0;
    clk_Duty <= clk_Duty_real;

    tb_ParameterInitFlag <= true;
    
    wait;
  end process;
  
  
  --------------------------------------------------------------------------------------------------
  -- Instantiation
  -- Clock Instantiation
  U_TB_CLK: entity work.tb_simple_clock 
  port map ( 
    clk_Period => clk_Period,
    clk_Duty => clk_Duty,
    active => tb_InitFlag,
    clk_o => pll_clk_I
  );
 
  -- ADC Instantiation
  U_TB_ADC: entity work.virtual_adc 
  port map( 
    clk_I => adc_clk_O,
    sel_I => adc_sel_O,
    chip_sel_I => adc_chip_sel_O,
    sleep_I => adc_sleep_O,
    data_O => adc_data_I
  );
 
  
  --------------------------------------------------------------------------------------------------
  -- Main process
  P_Unclocked : process
    variable i: integer range 0 to 1200;
    
    ------------------------------------------------------------------------------------------------
    -- Procedure for write in epp port
    procedure WriteData(
      constant in_address: in  std_logic_vector(7 downto 0);
      constant in_data:    in  std_logic_vector(15 downto 0);
      signal Data_IO:      out std_logic_vector(7 downto 0);
      signal nStrobe_I:    out std_logic;
      signal nSelectIn_I:  out std_logic;      
      signal nAutoFd_I:    out std_logic;
      signal Busy_O:       in  std_logic
    ) is 
    begin
      nStrobe_I <= '0'; -- '0' -> is write

      Data_IO <= in_address;          -- Address
      nSelectIn_I <= '0';             -- addStb      
      wait until Busy_O = '1';
      --wait for 30 ns;
      nSelectIn_I <= '1';     
      wait until Busy_O = '0';
      Data_IO <= (others => '0');
      wait for 30 ns;
      
      Data_IO <= in_data(7 downto 0); -- Data1
      nAutoFd_I <= '0';                -- datStb
      wait until Busy_O = '1';
      nAutoFd_I <= '1';
      wait until Busy_O = '0';
      Data_IO <= (others => '0');
      wait for 30 ns;
      
      Data_IO <= in_data(15 downto 8); -- Data0  
      nAutoFd_I <= '0';               -- datStb
      wait until Busy_O = '1';
      nAutoFd_I <= '1';
      wait until Busy_O = '0';
      
    end procedure WriteData;
    ------------------------------------------------------------------------------------------------
    -- Procedure for read from epp port
    procedure ReadData(
      signal out_runflag:  out std_logic;
      constant in_address: in  std_logic_vector(7 downto 0);
      signal Data_IO:      inout std_logic_vector(7 downto 0);
      signal nStrobe_I:    out std_logic;
      signal nSelectIn_I:  out std_logic;      
      signal nAutoFd_I:    out std_logic;
      signal Busy_O:       in  std_logic
    ) is 
    begin
     
      nStrobe_I <= '0'; -- '0' -> is write
      Data_IO <= in_address;          -- Address
      nSelectIn_I <= '0';             -- addStb
      wait until Busy_O = '1';
      wait for 30 ns; -- default
     -- wait for 150 ns;
      nSelectIn_I <= '1'; 
      wait until Busy_O = '0';
      wait for 30 ns;
      
      nStrobe_I <= '1'; -- '1' -> is read
      Data_IO <= (others => 'Z');     -- Data1
      nAutoFd_I <= '0';               -- datStb
    --  wait for 150 ns;
      wait until (Busy_O = '1');
      wait for 150 ns;
      nAutoFd_I <= '1';
   --   wait for 40 ns;
      wait until (Busy_O = '0');
      wait for 30 ns;
      
      Data_IO <= (others => 'Z');     -- Data0
      nAutoFd_I <= '0';               -- datStb
   --   wait for 150 ns;
      wait until (Busy_O = '1');
      wait for 150 ns;
      out_runflag <= Data_IO(6);
      nAutoFd_I <= '1';
      wait until (Busy_O = '0');
      wait for 30 ns;
      
    end procedure ReadData;
    
    
     ------------------------------------------------------------------------------------------------
    -- Procedure for read from epp port
    procedure ReadData2(
      signal out_runflag:  out std_logic;
      --constant in_address: in  std_logic_vector(7 downto 0);
      signal Data_IO:      inout std_logic_vector(7 downto 0);
      signal nStrobe_I:    out std_logic;
      signal nSelectIn_I:  out std_logic;      
      signal nAutoFd_I:    out std_logic;
      signal Busy_O:       in  std_logic
    ) is 
    begin
     
      
      nStrobe_I <= '1'; -- '1' -> is read
      Data_IO <= (others => 'Z');     -- Data1
      nAutoFd_I <= '0';               -- datStb
     -- wait for 150 ns;
      wait until (Busy_O = '1');
     -- wait for 150 ns;
      nAutoFd_I <= '1';
      --wait for 40 ns;
      wait until (Busy_O = '0');
    --  wait for 40 ns;
      
      Data_IO <= (others => 'Z');     -- Data0
      nAutoFd_I <= '0';               -- datStb
    --  wait for 150 ns;
      wait until (Busy_O = '1');
    --  wait for 150 ns;
      out_runflag <= Data_IO(6);
      nAutoFd_I <= '1';
      --wait for 40 ns;
      wait until (Busy_O = '0');
    --  wait for 40 ns;
      
    end procedure ReadData2;
    
  begin
    ------------------------------------------------------------------------------------------------
    -- Init
    test_number <= 0;
    wait until tb_ParameterInitFlag;
    tb_InitFlag <= true;
    
    nSelectIn_I <= '0';
    nStrobe_I   <= '0';
    Data_IO     <= (others => '0');
    nAutoFd_I   <= '1';
    nInit_I     <= '1';
    reset_I     <= '0';
    wait for 700 ns; -- PLL delay
    
    reset_I     <= '1';
    
    -- EPP Mode Negotiation
    -- Standar timing and handshake
    nStrobe_I <= '1';
    wait for 500 ns;
    
    Data_IO <= X"40";
    wait for 500 ns;
    
    nSelectIn_I <= '1';
    nAutoFd_I <= '0';
    wait until (PError_O = '1' and nAck_O = '0' and nFault_O = '1' and Sel_O = '1');
    
    nStrobe_I <= '0';
    wait for 500 ns;
    
    nAutoFd_I <= '1';
    nStrobe_I <= '1';
    wait until (nAck_O = '1' and Sel_O = '1'); 
    
    ------------------------------------------------------------------------------------------------
    -- Test 1
    -- Writing in all control register
    
    -- 00   RunConf_R   RW     [       |       |       |       |       |TScal04|TScal03|TScal02|
    --                          TScal01|TScal00|TScalEn|   TrCh|  TrEdg|   TrOn|   Cont|  Start]    
    --      
    -- 01   Channels_R  RW     [       |       |       |       |       |       |       |       |
    --                                 |       |       |       |       |       |  RCh01|  RCh00] 
    --      
    -- 02   BuffSize_R  RW     [       |       |BuffS13|BuffS12|BuffS11|BuffS10|BuffS09|BuffS08|
    --                          BuffS07|BuffS06|BuffS05|BuffS04|BuffS03|BuffS02|BuffS01|BuffS00]
    --      
    -- 03   TrigLvl_R   RW     [       |       |       |       |       |       |TrLvl09|TrLvl08|
    --                          TrLvl07|TrLvl06|TrLvl05|TrLvl04|TrLvl03|TrLvl02|TrLvl01|TrLvl00]
    --           
    -- 04   TrigOff_R   RW     [       |TrOff14|TrOff13|TrOff12|TrOff11|TrOff10|TrOff09|TrOff08|
    --                          TrOff07|TrOff06|TrOff00|TrOff00|TrOff00|TrOff00|TrOff00|TrOff00]  
    --
    -- 05   ADCConf     RW     [       |       |       |       |   ADCS|ADSleep| ADPSEn| ADPS08|
    --                           ADPS07| ADPS06| ADPS05| ADPS04| ADPS03| ADPS02| ADPS01| ADPS00]  
    --
    -- 08   Data_O      R      [ErrFlag|RunFlag|       |       |       |  DCh00|  Dat09|  Dat08|
    --                            Dat07|  Dat06|  Dat05|  Dat04|  Dat03|  Dat02|  Dat01|  Dat00] 
    -- 
    -- 09   Error_O     R      [       |       |       |       |       |       |       |       |
    --                                 |       |       |       |       | ErrN02| ErrN01| ErrN00] 
--     test_number <= 1;
--     
--     WriteData(X"00", X"FFFE", Data_IO, nStrobe_I, nSelectIn_I, nAutoFd_I, Busy_O);
--     WriteData(X"01", X"FFFF", Data_IO, nStrobe_I, nSelectIn_I, nAutoFd_I, Busy_O);
--     WriteData(X"02", X"FFFF", Data_IO, nStrobe_I, nSelectIn_I, nAutoFd_I, Busy_O);
--     WriteData(X"03", X"FFFF", Data_IO, nStrobe_I, nSelectIn_I, nAutoFd_I, Busy_O);
--     WriteData(X"04", X"FFFF", Data_IO, nStrobe_I, nSelectIn_I, nAutoFd_I, Busy_O);
--     
--     ReadData(runflag, X"00", Data_IO, nStrobe_I, nSelectIn_I, nAutoFd_I, Busy_O);
--     ReadData(runflag, X"01", Data_IO, nStrobe_I, nSelectIn_I, nAutoFd_I, Busy_O);
--     ReadData(runflag, X"02", Data_IO, nStrobe_I, nSelectIn_I, nAutoFd_I, Busy_O);
--     ReadData(runflag, X"03", Data_IO, nStrobe_I, nSelectIn_I, nAutoFd_I, Busy_O);
--     ReadData(runflag, X"04", Data_IO, nStrobe_I, nSelectIn_I, nAutoFd_I, Busy_O);
--     
--     wait for 50 ns;
--     ------------------------------------------------------------------------------------------------
--     -- Test 2 - DAQ Config
--     -- Writing in daq config register
--     test_number <= 2;
--     
--     WriteData(X"05", X"07FF", Data_IO, nStrobe_I, nSelectIn_I, nAutoFd_I, Busy_O);
--     ReadData(runflag, X"05", Data_IO, nStrobe_I, nSelectIn_I, nAutoFd_I, Busy_O);
--     
--     WriteData(X"05", X"0A00", Data_IO, nStrobe_I, nSelectIn_I, nAutoFd_I, Busy_O);
--     ReadData(runflag, X"05", Data_IO, nStrobe_I, nSelectIn_I, nAutoFd_I, Busy_O);
--     
--     wait for 50 ns;
--     ------------------------------------------------------------------------------------------------
--     -- Test 3 - Test basic
--     -- daq freq = ctrl freq/2 (default), w/o trigger, w/o skipper, channels 1 and 2, 
--     -- buffer size = 50h, continuous
--     test_number <= 3;
--     
--     WriteData(X"01", X"0003", Data_IO, nStrobe_I, nSelectIn_I, nAutoFd_I, Busy_O); -- Channels_R
--     WriteData(X"02", X"0050", Data_IO, nStrobe_I, nSelectIn_I, nAutoFd_I, Busy_O); -- BuffSize_R
--     WriteData(X"03", X"0000", Data_IO, nStrobe_I, nSelectIn_I, nAutoFd_I, Busy_O); -- TrigLvl_R
--     WriteData(X"04", X"0000", Data_IO, nStrobe_I, nSelectIn_I, nAutoFd_I, Busy_O); -- TrigOff_R
--     WriteData(X"00", X"0001", Data_IO, nStrobe_I, nSelectIn_I, nAutoFd_I, Busy_O); -- RunConf_R
--     
--     
--     ReadData(runflag, X"08", Data_IO, nStrobe_I, nSelectIn_I, nAutoFd_I, Busy_O);
--     while (runflag = '1') loop
--       ReadData(runflag, X"08", Data_IO, nStrobe_I, nSelectIn_I, nAutoFd_I, Busy_O);    
--     end loop;
--     
--     wait for 50 ns;
--     ------------------------------------------------------------------------------------------------
--     -- Test 4 - Skipper
--     -- daq freq = ctrl freq/2 (default), w/o trigger, skipper = 3, channels 1 and 2, 
--     -- buffer size = 80h, no continuous
--     test_number <= 4;
--     
--     WriteData(X"01", X"0003", Data_IO, nStrobe_I, nSelectIn_I, nAutoFd_I, Busy_O); -- Channels_R
--     WriteData(X"02", X"0080", Data_IO, nStrobe_I, nSelectIn_I, nAutoFd_I, Busy_O); -- BuffSize_R
--     WriteData(X"03", X"0000", Data_IO, nStrobe_I, nSelectIn_I, nAutoFd_I, Busy_O); -- TrigLvl_R
--     WriteData(X"04", X"0000", Data_IO, nStrobe_I, nSelectIn_I, nAutoFd_I, Busy_O); -- TrigOff_R
--     WriteData(X"00", B"00000_00011_1_0_0_0_0_1", Data_IO, nStrobe_I, nSelectIn_I, nAutoFd_I, Busy_O); -- RunConf_R
--                        
--     
--     
--     ReadData(runflag, X"08", Data_IO, nStrobe_I, nSelectIn_I, nAutoFd_I, Busy_O);
--     while (runflag = '1') loop
--       ReadData(runflag, X"08", Data_IO, nStrobe_I, nSelectIn_I, nAutoFd_I, Busy_O);    
--     end loop;
--     
--     -- Some samples
--     --     011011001  0  217
--     --     011110110  1  246
--     --     011111001  0  249  32
--     --     100010110  1  278  32
--     --     100011001  0  281  32
--     --     100110110  1  310  32
--     --     100111001  0  313  32
--     --     101010110  1  342  32
--     
--     
--     
--     wait for 50 ns;
--     
--     ------------------------------------------------------------------------------------------------
--     -- Test 5 - Trigger - one shot
--     -- daq freq = ctrl freq/2 (default), trigger channel 1, level 30 %, not continuous, skipper = 5, 
--     -- channels 1 and 2, buffer size = 100h, rissing edge, trigg offset = 0
--     test_number <= 5;
--     
--     WriteData(X"01", X"0003", Data_IO, nStrobe_I, nSelectIn_I, nAutoFd_I, Busy_O); -- Channels_R
--     WriteData(X"02", X"0100", Data_IO, nStrobe_I, nSelectIn_I, nAutoFd_I, Busy_O); -- BuffSize_R
--     WriteData(X"03", X"0133", Data_IO, nStrobe_I, nSelectIn_I, nAutoFd_I, Busy_O); -- TrigLvl_R
--     WriteData(X"04", X"0000", Data_IO, nStrobe_I, nSelectIn_I, nAutoFd_I, Busy_O); -- TrigOff_R
--     WriteData(X"00", B"00000_00101_1_1_0_1_0_1", Data_IO, nStrobe_I, nSelectIn_I, nAutoFd_I, Busy_O); -- RunConf_R
--     
--     
--     ReadData(runflag, X"08", Data_IO, nStrobe_I, nSelectIn_I, nAutoFd_I, Busy_O);
--     while (runflag = '1') loop
--       ReadData(runflag, X"08", Data_IO, nStrobe_I, nSelectIn_I, nAutoFd_I, Busy_O);    
--     end loop;
    
    
    ------------------------------------------------------------------------------------------------
    -- Test 6 - Trigger 
    -- daq freq = ctrl freq/2 (default), trigger channel 1, level 70 %, continuous, skipper = 3, 
    -- channels 1, buffer size = 150h, falling edge, full negative trigger offset
    -- test_number <= 6;
    
    -- WriteData(X"01", X"0002", Data_IO, nStrobe_I, nSelectIn_I, nAutoFd_I, Busy_O); -- Channels_R
    -- WriteData(X"02", X"0150", Data_IO, nStrobe_I, nSelectIn_I, nAutoFd_I, Busy_O); -- BuffSize_R
    -- WriteData(X"03", X"02CD", Data_IO, nStrobe_I, nSelectIn_I, nAutoFd_I, Busy_O); -- TrigLvl_R
    -- WriteData(X"04", X"FF6A", Data_IO, nStrobe_I, nSelectIn_I, nAutoFd_I, Busy_O); -- TrigOff_R -150
    -- WriteData(X"00", B"00000_00011_1_1_1_1_1_1", Data_IO, nStrobe_I, nSelectIn_I, nAutoFd_I, Busy_O); -- RunConf_R
    
    
    -- ReadData(runflag, X"08", Data_IO, nStrobe_I, nSelectIn_I, nAutoFd_I, Busy_O);
    -- i := 0;
    -- while (i <= 200) loop
      -- ReadData(runflag, X"08", Data_IO, nStrobe_I, nSelectIn_I, nAutoFd_I, Busy_O);    
      -- i := i + 1;
    -- end loop;
    
    
    -- WriteData(X"01", X"0002", Data_IO, nStrobe_I, nSelectIn_I, nAutoFd_I, Busy_O);
    
   
    ------------------------------------------------------------------------------------------------
    -- Test 7 - One channel
    -- daq freq = ctrl freq/2 (default), trigger channel 0, level 30 %, continuous, skipper = 5, 
    -- channels 1, buffer size = 30, trigger offset 29, skipper = 10
    --11101101010
--     test_number <= 7;
--     
--     WriteData(X"01", X"0001", Data_IO, nStrobe_I, nSelectIn_I, nAutoFd_I, Busy_O); -- Channels_R
--     WriteData(X"02", X"0030", Data_IO, nStrobe_I, nSelectIn_I, nAutoFd_I, Busy_O); -- BuffSize_R
--     WriteData(X"03", X"0010", Data_IO, nStrobe_I, nSelectIn_I, nAutoFd_I, Busy_O); -- TrigLvl_R
--     WriteData(X"04", X"0029", Data_IO, nStrobe_I, nSelectIn_I, nAutoFd_I, Busy_O); -- TrigOff_R -150
--     WriteData(X"00", B"00000_01010_1_0_1_1_1_1", Data_IO, nStrobe_I, nSelectIn_I, nAutoFd_I, Busy_O); -- RunConf_R
--     
--     
--     ReadData(runflag, X"08", Data_IO, nStrobe_I, nSelectIn_I, nAutoFd_I, Busy_O);
--     while (i <= 1200) loop
--       ReadData(runflag, X"08", Data_IO, nStrobe_I, nSelectIn_I, nAutoFd_I, Busy_O);    
--       i = i + 1;
--     end loop;
    
    
    ------------------------------------------------------------------------------------------------
    -- Test 8  - Test write while working
    -- daq freq = ctrl freq/2 (default), trigger channel 1, level 30 %, continuous, skipper = 5, 
    -- channels 1, buffer size = 50
--     
--         test_number <= 8;
--     
--     WriteData(X"01", X"0002", Data_IO, nStrobe_I, nSelectIn_I, nAutoFd_I, Busy_O); -- Channels_R
--     WriteData(X"02", X"0150", Data_IO, nStrobe_I, nSelectIn_I, nAutoFd_I, Busy_O); -- BuffSize_R
--     WriteData(X"03", X"02CD", Data_IO, nStrobe_I, nSelectIn_I, nAutoFd_I, Busy_O); -- TrigLvl_R
--     WriteData(X"04", X"FF6A", Data_IO, nStrobe_I, nSelectIn_I, nAutoFd_I, Busy_O); -- TrigOff_R -150
--     WriteData(X"00", B"00000_00011_1_1_1_1_1_1", Data_IO, nStrobe_I, nSelectIn_I, nAutoFd_I, Busy_O); -- RunConf_R
--     
--     wait for 800 ns;
--     WriteData(X"01", X"0002", Data_IO, nStrobe_I, nSelectIn_I, nAutoFd_I, Busy_O);
--     
--     ReadData(runflag, X"08", Data_IO, nStrobe_I, nSelectIn_I, nAutoFd_I, Busy_O);
--     i := 0;
--     while (i <= 200) loop
--       ReadData(runflag, X"08", Data_IO, nStrobe_I, nSelectIn_I, nAutoFd_I, Busy_O);    
--       i := i + 1;
--     end loop;
    
    
    -- ------------------------------------------------------------------------------------------------
    -- Test 9 - Test read with full buffer
    -- daq freq = ctrl freq/2 (default), w/o trigger, w/o skipper, channels 1 and 2, 
    -- buffer size = 50h, continuous
--     test_number <= 9;
--     
--     WriteData(X"01", X"0003", Data_IO, nStrobe_I, nSelectIn_I, nAutoFd_I, Busy_O); -- Channels_R
--     WriteData(X"02", X"0050", Data_IO, nStrobe_I, nSelectIn_I, nAutoFd_I, Busy_O); -- BuffSize_R
--     WriteData(X"03", X"0000", Data_IO, nStrobe_I, nSelectIn_I, nAutoFd_I, Busy_O); -- TrigLvl_R
--     WriteData(X"04", X"0000", Data_IO, nStrobe_I, nSelectIn_I, nAutoFd_I, Busy_O); -- TrigOff_R
--     WriteData(X"00", X"0001", Data_IO, nStrobe_I, nSelectIn_I, nAutoFd_I, Busy_O); -- RunConf_R
--     
--     wait for 5000 ns;
--     i := 0;
--     ReadData(runflag, X"08", Data_IO, nStrobe_I, nSelectIn_I, nAutoFd_I, Busy_O);
--     while (i <= 25) loop
--       ReadData(runflag, X"08", Data_IO, nStrobe_I, nSelectIn_I, nAutoFd_I, Busy_O);    
--       i := i + 1;
--     end loop;
--     
--     -- big buffer
--     WriteData(X"01", X"0003", Data_IO, nStrobe_I, nSelectIn_I, nAutoFd_I, Busy_O); -- Channels_R
--     WriteData(X"02", X"03E8", Data_IO, nStrobe_I, nSelectIn_I, nAutoFd_I, Busy_O); -- BuffSize_R
--     WriteData(X"03", X"0000", Data_IO, nStrobe_I, nSelectIn_I, nAutoFd_I, Busy_O); -- TrigLvl_R
--     WriteData(X"04", X"0000", Data_IO, nStrobe_I, nSelectIn_I, nAutoFd_I, Busy_O); -- TrigOff_R
--     WriteData(X"00", X"0001", Data_IO, nStrobe_I, nSelectIn_I, nAutoFd_I, Busy_O); -- RunConf_R
--     
-- 
--     ReadData(runflag, X"08", Data_IO, nStrobe_I, nSelectIn_I, nAutoFd_I, Busy_O);
--     while (runflag = '1') loop
--       ReadData(runflag, X"08", Data_IO, nStrobe_I, nSelectIn_I, nAutoFd_I, Busy_O);    
--     end loop;
--     


    ------------------------------------------------------------------------------------------------
    -- Test 10 - Test simple continuous
    -- daq freq = ctrl freq/2 (default), trigger channel 1, level 70 %, continuous, skipper = 3, 
    -- channels 1, buffer size = 150h, falling edge, full negative trigger offset
    test_number <= 10;
    
    WriteData(X"01", X"0002", Data_IO, nStrobe_I, nSelectIn_I, nAutoFd_I, Busy_O); -- Channels_R
    WriteData(X"02", X"0050", Data_IO, nStrobe_I, nSelectIn_I, nAutoFd_I, Busy_O); -- BuffSize_R
    WriteData(X"03", X"02CD", Data_IO, nStrobe_I, nSelectIn_I, nAutoFd_I, Busy_O); -- TrigLvl_R
    WriteData(X"04", X"FF6A", Data_IO, nStrobe_I, nSelectIn_I, nAutoFd_I, Busy_O); -- TrigOff_R -150
    WriteData(X"00", X"FFC1", Data_IO, nStrobe_I, nSelectIn_I, nAutoFd_I, Busy_O); -- RunConf_R
                      --1111111111000011
    --wait for 5000 ns;  
    
    
    
    test_number <= 11;
    
    ReadData(runflag, X"08", Data_IO, nStrobe_I, nSelectIn_I, nAutoFd_I, Busy_O);
    while (runflag = '1') loop
      ReadData(runflag, X"08", Data_IO, nStrobe_I, nSelectIn_I, nAutoFd_I, Busy_O);    
    end loop;
    
--     ReadData(runflag, X"08", Data_IO, nStrobe_I, nSelectIn_I, nAutoFd_I, Busy_O);
--     i := 0;
--     while (i <= 50) loop
--       ReadData2(runflag,  Data_IO, nStrobe_I, nSelectIn_I, nAutoFd_I, Busy_O);    
--       i := i + 1;
--     end loop;
--     
--     
--    
--     test_number <= 12;
--     WriteData(X"01", X"0002", Data_IO, nStrobe_I, nSelectIn_I, nAutoFd_I, Busy_O); -- Channels_R
--     WriteData(X"02", X"0050", Data_IO, nStrobe_I, nSelectIn_I, nAutoFd_I, Busy_O); -- BuffSize_R
--     WriteData(X"03", X"01FF", Data_IO, nStrobe_I, nSelectIn_I, nAutoFd_I, Busy_O); -- TrigLvl_R
--     WriteData(X"04", X"0000", Data_IO, nStrobe_I, nSelectIn_I, nAutoFd_I, Busy_O); -- TrigOff_R -150
--     WriteData(X"00", X"FFC3", Data_IO, nStrobe_I, nSelectIn_I, nAutoFd_I, Busy_O); -- RunConf_R
--                       --1111 1111 1100 0011
--     ReadData(runflag, X"08", Data_IO, nStrobe_I, nSelectIn_I, nAutoFd_I, Busy_O);
--     i := 0;
--     while (i <= 150) loop
--       ReadData(runflag, X"08", Data_IO, nStrobe_I, nSelectIn_I, nAutoFd_I, Busy_O);    
--       i := i + 1;
--     end loop;
    
    
    WriteData(X"01", X"0002", Data_IO, nStrobe_I, nSelectIn_I, nAutoFd_I, Busy_O);

     wait for 1000 ns;
--     
--     -- reading an address
--     
     WriteData(X"09", X"0002", Data_IO, nStrobe_I, nSelectIn_I, nAutoFd_I, Busy_O);
       nStrobe_I <= '1'; -- '1' -> is read
      Data_IO <= (others => 'Z');     -- Data0          -- Address
      nSelectIn_I <= '0';             -- addStb
      wait until Busy_O = '1';
      wait for 30 ns; -- default
     -- wait for 150 ns;
      nSelectIn_I <= '1'; 
      wait until Busy_O = '0';
      wait for 30 ns;
    
    
    wait for 100 ns;
    
    tb_InitFlag <= false;
    wait;
    
    
  end process;
  
  
  
end architecture STIMULATOR;


 






-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 library ieee, std;
 use ieee.std_logic_1164.all;
 
 
-- Additional libraries used by Model Under Test.
-- ...
entity testbench is
end testbench;

architecture tbGeneratedCode of testbench is
    -- ADC
    signal adc_data_I:      std_logic_vector (9 downto 0);
    signal adc_sel_O:       std_logic;
    signal adc_clk_O:       std_logic;
    signal adc_sleep_O:     std_logic;
    signal adc_chip_sel_O:  std_logic;
    -- EPP
    signal nStrobe_I:       std_logic;
    signal Data_IO:         std_logic_vector (7 downto 0);  
    signal nAck_O:          std_logic;
    signal busy_O:          std_logic;
    signal PError_O:        std_logic;
    signal Sel_O:           std_logic;
    signal nAutoFd_I:       std_logic;
    signal PeriphLogicH_O:  std_logic;
    signal nInit_I:         std_logic;
    signal nFault_O:        std_logic;
    signal nSelectIn_I:     std_logic;
    -- Peripherals
    signal reset_I:     std_logic; 
    signal pll_clk_I:   std_logic;
    
    
    signal test_number: integer range 0 to 20;
begin
  --------------------------------------------------------------------------------------------------
  -- Instantiation of Stimulus.
  U_stimulus_0 : entity work.stimulus
    port map (
      -- ADC
      adc_data_I => adc_data_I,
      adc_sel_O => adc_sel_O,
      adc_clk_O => adc_clk_O,
      adc_sleep_O => adc_sleep_O,
      adc_chip_sel_O => adc_chip_sel_O,
      -- EPP
      nStrobe_I => nStrobe_I,
      Data_IO => Data_IO,
      nAck_O => nAck_O,
      busy_O => busy_O,
      PError_O => PError_O,
      Sel_O => Sel_O,
      nAutoFd_I => nAutoFd_I,
      PeriphLogicH_O =>PeriphLogicH_O ,
      nInit_I => nInit_I,
      nFault_O => nFault_O,
      nSelectIn_I => nSelectIn_I,
      -- Peripherals
      reset_I => reset_I,
      pll_clk_I => pll_clk_I,
      
      test_number => test_number
    );

  --------------------------------------------------------------------------------------------------
  -- Instantiation of Model Under Test.
  U_OSC0 : entity work.modular_oscilloscope --<--<--<--<--<--<--<--<--<--<--<--<--<--<--<--<--
    port map (
      -- ADC
      adc_data_I => adc_data_I,
      adc_sel_O => adc_sel_O,
      adc_clk_O => adc_clk_O,
      adc_sleep_O => adc_sleep_O,
      adc_chip_sel_O => adc_chip_sel_O,
      -- EPP
      nStrobe_I => nStrobe_I,
      Data_IO => Data_IO,
      nAck_O => nAck_O,
      busy_O => busy_O,
      PError_O => PError_O,
      Sel_O => Sel_O,
      nAutoFd_I => nAutoFd_I,
      PeriphLogicH_O =>PeriphLogicH_O ,
      nInit_I => nInit_I,
      nFault_O => nFault_O,
      nSelectIn_I => nSelectIn_I,
      -- Peripherals
      reset_I => reset_I,
      pll_clk_I => pll_clk_I
    );
    
end tbGeneratedCode;
----------------------------------------------------------------------------------------------------
