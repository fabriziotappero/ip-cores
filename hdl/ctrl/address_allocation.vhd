-------------------------------------------------------------------------------------------------100
--| Modular Oscilloscope
--| UNSL - Argentine
--|
--| File: ctrl_address_allocation.vhd
--| Version: 0.21
--| Tested in: Actel A3PE1500
--|   Board: RVI Prototype Board + LP Data Conversion Daughter Board
--|-------------------------------------------------------------------------------------------------
--| Description:
--|   CONTROL - Address allocations
--|   Registers and intercomunications.
--|   
--|-------------------------------------------------------------------------------------------------
--| File history:
--|   0.1   | jul-2009 | First testing
--|   0.2   | aug-2009 | New status flag
--|   0.21  | sep-2009 | Smarter stop signal
----------------------------------------------------------------------------------------------------
--| Copyright © 2009, Facundo Aguilera.
--|
--| This VHDL design file is an open design; you can redistribute it and/or
--| modify it and/or implement it after contacting the author.

--| Wishbone Rev. B.3 compatible
----------------------------------------------------------------------------------------------------



--==================================================================================================
-- TO DO
-- [OK] Finish ADC conf write
-- ·    Define error codes
--==================================================================================================


--==================================================================================================
-- Allocations
-- ADR  NAME        MODE   [     15|     14|     13|     12|     11|     10|      9|      8|
--                                7|      6|      5|      4|      3|      2|      1|      0]    bits
-- 
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
-- 08   Data_O      R      [StatF01|StatF00|       |       |       |  DCh00|  Dat09|  Dat08|
--                            Dat07|  Dat06|  Dat05|  Dat04|  Dat03|  Dat02|  Dat01|  Dat00] 
-- 
-- 09   Error_O     R      [       |       |       |       |       |       |       |       |
--                                 |       |       |       |       | ErrN02| ErrN01| ErrN00] 
--      
-- 
-- 
-- Description
-- StatF01|StatF00|
--   00     Stoped
--   01     Running, odd buffer
--   11     Running, pair buffer
--   10     Stoped, with error
--==================================================================================================



library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
--use IEEE.NUMERIC_STD.ALL;



----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
entity ctrl_address_allocation is
--   generic(
--     MEM_ADD_WIDTH: integer :=  14
--   );
  port(
    ------------------------------------------------------------------------------------------------
    -- From port
    DAT_I_port: in std_logic_vector (15 downto 0);
    DAT_O_port: out std_logic_vector (15 downto 0);
    ADR_I_port: in std_logic_vector (3 downto 0); 
    CYC_I_port: in std_logic;  
    STB_I_port: in std_logic;  
    ACK_O_port: out std_logic ;
    WE_I_port:  in std_logic;
    RST_I: in std_logic;  
    CLK_I: in std_logic;  
    
    ------------------------------------------------------------------------------------------------
    -- To internal
    --DAT_I_int: in std_logic_vector (15 downto 0);
    --DAT_O_int: out std_logic_vector (15 downto 0);
    --ADR_O_int: in std_logic_vector (3 downto 0); 
    CYC_O_int: out std_logic;  
    STB_O_int: out std_logic;  
    ACK_I_int: in  std_logic ;
    DAT_I_int: in  std_logic_vector(15 downto 0);
    --DAT_O_int: out std_logic_vector(15 downto 0);
    -- WE_O_int:  out std_logic;
    
    ------------------------------------------------------------------------------------------------
    -- Internal
    start_O:          out std_logic;
    continuous_O:     out std_logic;
    trigger_en_O:     out std_logic;
    trigger_edge_O:   out std_logic;
    trigger_channel_O:out std_logic_vector(0 downto 0);
    time_scale_O:     out std_logic_vector(4 downto 0);
    time_scale_en_O:  out std_logic;
    channels_sel_O:   out std_logic_vector(1 downto 0);
    buffer_size_O:    out std_logic_vector(13 downto 0);
    trigger_level_O:  out std_logic_vector(9 downto 0);
    trigger_offset_O: out std_logic_vector(14 downto 0);
    
    adc_conf_O:       out std_logic_vector(15 downto 0);    
    
    error_number_I:   in std_logic_vector (2 downto 0); 
    --data_channel_I:   in std_logic; 
    status_I:        in std_logic_vector(1 downto 0);
    
    write_in_adc_O:     out std_logic;
    stop_O:           out std_logic 
    -- Stop the current conversion when reading
	);
end entity ctrl_address_allocation;

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
architecture ARCH01 of ctrl_address_allocation is 
 
  -- Tipos
  type data_array is array(0 to 9) of std_logic_vector(15 downto 0);
   
  
                --   type arr is array(0 to 3) of std_logic_vector(15 downto 0);
                -- 
                -- signal arr_a : arr;
                -- signal vec_0, vec_1, vec_2, vec_3 : std_logic vector(15 downto 0);
                -- ....
                -- arr_a(0) <= vec_0;
                -- arr_a(1) <= vec_1;
  signal o_selector: data_array;
  
  signal start_R:          std_logic;
  signal continuous_R:     std_logic;
  signal trigger_on_R:     std_logic;
  signal trigger_edge_R:   std_logic;
  signal time_scale_en_R:  std_logic;
  signal time_scale_R:     std_logic_vector(4 downto 0);
  signal channels_sel_R:   std_logic_vector(1 downto 0);
  signal buffer_size_R:    std_logic_vector(13 downto 0);
  signal trigger_level_R:  std_logic_vector(9 downto 0);
  signal trigger_offset_R: std_logic_vector(14 downto 0);
  signal trigger_channel_R: std_logic_vector(0 downto 0);
  
  signal adc_conf_R:       std_logic_vector(15 downto 0);
  signal write_in_adc_R:   std_logic;
  
  signal data:            std_logic_vector(9 downto 0);
  signal data_channel:    std_logic;

begin


  --------------------------------------------------------------------------------------------------
  -- Reading allocation
  o_selector(0) <= (15 downto 11 => '0') & time_scale_R & time_scale_en_R & trigger_channel_R & 
                   trigger_edge_R & trigger_on_R & continuous_R & start_R;
  o_selector(1) <= (15 downto 2 => '0') & channels_sel_R;
  o_selector(2) <= (15 downto 14 => '0') & buffer_size_R;
  o_selector(3) <= (15 downto 10 => '0') & trigger_level_R;
  o_selector(4) <= (15 downto 15 => '0') & trigger_offset_R;
  o_selector(5) <= adc_conf_R;
  o_selector(6) <= (others => '0');
  o_selector(7) <= (others => '0');
  
  
  o_selector(8) <= status_I & (13 downto 11 => '0') & data_channel & data;
  o_selector(9) <= (15 downto 3 => '0') & error_number_I;
  
  DAT_O_port <= o_selector(conv_integer(ADR_I_port));
  
  
  --------------------------------------------------------------------------------------------------
  -- Read asignments
  -- if reading registers, do ack, else use internal ack
  ACK_O_port <= (CYC_I_port and STB_I_port) and 
                ((not(ADR_I_port(3)) or ACK_I_int or not(status_I(0))));
  
  
  --------------------------------------------------------------------------------------------------
  -- Internal wishbone allocation
  STB_O_int <= STB_I_port and ADR_I_port(3);
  CYC_O_int <= CYC_I_port and ADR_I_port(3);
  
  --------------------------------------------------------------------------------------------------
  -- Stop signal
  -- It asserts when there is a write in the confing registers
  P_stop: process (CLK_I, STB_I_port, WE_I_port, status_I, ADR_I_port)
  begin
    if CLK_I'event and CLK_I = '1' then
      if status_I(0) = '0' then
        stop_O <= '0';
      elsif  CYC_I_port = '1' and STB_I_port = '1' and WE_I_port = '1' and ADR_I_port(3) = '0' then
        stop_O <= '1';
      end if;
    end if;
  end process;
  
  --------------------------------------------------------------------------------------------------
  -- DAT_I 
  data <= DAT_I_int(9 downto 0);
  data_channel <= DAT_I_int(10);
  
  
  --------------------------------------------------------------------------------------------------
  -- Writing allocation
  P_wr: process(CLK_I, CYC_I_port, DAT_I_port, ADR_I_port, STB_I_port, WE_I_port, RST_I)
  begin
  if CLK_I'event and CLK_I = '1' then
    -- Defaul values
    if RST_I = '1' then
      start_R <= '0';
      continuous_R <= '0';
      trigger_on_R <= '0';
      trigger_edge_R <= '0';
      time_scale_en_R <= '0';
      time_scale_R <= (others => '0');
      channels_sel_R <= (others => '0');
      buffer_size_R <= (others => '0');
      trigger_level_R <= (others => '0');
      trigger_offset_R <= (others => '0');
      trigger_channel_R <= (others => '0');
      write_in_adc_R <= '0';
      adc_conf_R <= (others => '0');
    
    
    
    -- Assignments
    elsif CYC_I_port = '1' and STB_I_port = '1' and WE_I_port = '1' and ADR_I_port(3) = '0' then 
      
      case ADR_I_port(2 downto 0) is
        when O"0" =>
          start_R <=           DAT_I_port(0);
          continuous_R <=      DAT_I_port(1);
          trigger_on_R <=      DAT_I_port(2);
          trigger_edge_R <=    DAT_I_port(3);
          trigger_channel_R <= DAT_I_port(4 downto 4);
          time_scale_en_R <=   DAT_I_port(5);
          time_scale_R <=      DAT_I_port(10 downto 6);
          
        when O"1" =>
          channels_sel_R <=   DAT_I_port(1 downto 0);
          
        when O"2" =>
          buffer_size_R <=    DAT_I_port(13 downto 0);
          
        when O"3" =>
          trigger_level_R <=  DAT_I_port(9 downto 0);
        
        when O"4" =>
          trigger_offset_R <= DAT_I_port(14 downto 0);
          
        when O"5" =>
          adc_conf_R   <=     DAT_I_port;
          write_in_adc_R <=     '1';
          
        when others =>
        
      end case;
    
    -- Auto restart signals 
    else
      start_R <= '0';
      write_in_adc_R <= '0';
      
    end if;
  end if;
          
  end process;
  
  start_O <= start_R;
  continuous_O <= continuous_R;
  trigger_en_O <= trigger_on_R;
  trigger_edge_O <= trigger_edge_R;
  time_scale_en_O <= time_scale_en_R;
  time_scale_O <= time_scale_R;
  channels_sel_O <= channels_sel_R;
  buffer_size_O <= buffer_size_R;
  trigger_level_O <= trigger_level_R;
  trigger_offset_O <= trigger_offset_R;
  trigger_channel_O <= trigger_channel_R;
  write_in_adc_O <= write_in_adc_R;
  adc_conf_O <= adc_conf_R;
          
  
end architecture;