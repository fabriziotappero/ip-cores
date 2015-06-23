----------------------------------------------------------------------------------------------------
--| Modular Oscilloscope
--| UNSL - Argentina
--|
--| File: daq.vhd
--| Version: 0.40
--| Tested in: Actel A3PE1500
--|   Board: RVI Prototype Board + LP Data Conversion Daughter Board
--|-------------------------------------------------------------------------------------------------
--| Description:
--|   Acquisition control module. 
--|   It drives the ADC chip.
--|-------------------------------------------------------------------------------------------------
--| File history:
--|   0.01   | apr-2008 | First testing
--|   0.10   | apr-2009 | First release
--|   0.40   | jul-2009 | Added a read flag for each channel and adc_clk_I input
----------------------------------------------------------------------------------------------------
--| Copyright © 2009, Facundo Aguilera.
--|
--| This VHDL design file is an open design; you can redistribute it and/or
--| modify it and/or implement it after contacting the author.

--| Wishbone Rev. B.3 compatible
----------------------------------------------------------------------------------------------------

--==================================================================================================
-- TODO
-- · Access to both channels in consecutive reads  
--==================================================================================================




-- Esta primera versión está realizada específicamente para controlar el ADC AD9201. Otras
-- versiones podrán ser más genéricas. 


-- ADR    configuración (señal config)
-- ADR+1  datos canal 1
-- ADR+2  datos canal 2
-- ADR+3  sin usar

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
--use IEEE.STD_LOGIC_ARITH.all;
use IEEE.NUMERIC_STD.ALL;
--use work.adq_pgk.all;

entity daq is
  generic (
    DEFALT_CONFIG : std_logic_vector := "0000001000000000"
                                      -- 5432109876543210
                                      -- bits 8 a 0       clk_pre_scaler
                                      -- bits 9           clk_pre_scaler_ena
                                      -- bit 10           adc sleep
                                      -- bit 11           adc_chip_sel
                                      -- bits 12 a 15     sin usar
                                      
                                      -- si clk_pre_scaler_ena = 1
                                      -- frecuencia_adc = frecuencia_wbn / ((clk_pre_scaler+1)*2)
                                      -- sino frecuencia_adc = frecuencia_wbn
  );
  port(
    -- Externo
    adc_data_I:     in    std_logic_vector (9 downto 0);
    adc_sel_O:      out   std_logic;
    adc_clk_O:      out   std_logic;
    adc_sleep_O:    out   std_logic;
    adc_chip_sel_O: out   std_logic;  -- '1' disable, '0' select
    

    --  Interno
    RST_I:  in  std_logic;  
    CLK_I:  in  std_logic;  
    DAT_I:  in  std_logic_vector (15 downto 0);
    ADR_I:  in  std_logic_vector (1 downto 0);
    CYC_I:  in  std_logic;  
    STB_I:  in  std_logic; 
    WE_I:   in  std_logic;
    DAT_O:  out std_logic_vector (15 downto 0);
    ACK_O:  out std_logic; 
    
    adc_clk_I: std_logic
  );
end daq;
  
  
architecture archdaq2 of daq is
  -- Tipos
  type config_array is array(0 to 2) of std_logic_vector(15 downto 0);
   
  
                --   type arr is array(0 to 3) of std_logic_vector(15 downto 0);
                -- 
                -- signal arr_a : arr;
                -- signal vec_0, vec_1, vec_2, vec_3 : std_logic vector(15 downto 0);
                -- ....
                -- arr_a(0) <= vec_0;
                -- arr_a(1) <= vec_1;
                -- ....
                
  type data_array is array(0 to 1) of std_logic_vector(adc_data_I'length - 1 downto 0);

  
  
  -- Registers
  signal config:   std_logic_vector (15 downto 0);
  signal count: std_logic_vector (8 downto 0);
  signal channel_data: data_array;
  signal read_flag_adc: std_logic_vector (1 downto 0); 
  signal read_flag_wb: std_logic_vector (1 downto 0); 
  -- The biggest limit must be the channels number (-1)
  -- There are two clocks becouse there are two clocks
    
  -- Signals
  signal selector: config_array;
  
  signal s_adc_clk, s_adc_sleep, s_adc_chip_sel: std_logic; -- previous to outputs
  signal reduced_clk, same_clk: std_logic;
  signal data_ack_ready:      std_logic; -- habilita confirmación de datos
  signal conf_ack_ready:      std_logic; -- habilita confirmación de escritura de configuración
  signal clk_pre_scaler:      std_logic_vector (8 downto 0);
  signal clk_pre_scaler_ena:  std_logic;
  signal channel_sel:         std_logic_vector(0 downto 0); -- max limit must be the number of channels
  signal count_reset:          std_logic;
  signal count_max:           std_logic;
  --signal clk_enable: std_logic_vector (9 downto 0);

begin
  --------------------------------------------------------------------------------------------------
  -- Asignaciones
  ---- Internal 
  selector(0) <= (config'length - 1 downto adc_data_I'length => '0' ) & 
                 channel_data(conv_integer(channel_sel));
  selector(1) <= (config'length - 1 downto adc_data_I'length => '0' ) & 
                 channel_data(conv_integer(channel_sel));
  selector(2) <= config;
  --selector(3) <= (others => '0' ); -- Unassigned


  
  ---- Config register
  clk_pre_scaler <= config(8 downto 0);
  clk_pre_scaler_ena <= config(9); 
  s_adc_sleep <= config(10);
  s_adc_chip_sel <= config(11);
  -- Unassigned <= config(13); 
  -- Unassigned <= config(14);
  -- Unassigned <= config(15);
  
  ---- External communication (AD)
  adc_sleep_O <= s_adc_sleep;
  adc_chip_sel_O <= s_adc_chip_sel;

  
  
   
  --------------------------------------------------------------------------------------------------
  -- Generación de adc_clk_O
  count_max <= '1' when count >= clk_pre_scaler else '0';
  count_reset <=  RST_I or count_max or not(clk_pre_scaler_ena);
  
  P_count: process (adc_clk_I, count, count_reset) 
  begin
    if adc_clk_I'event and adc_clk_I = '1'  then
      if count_reset = '1' then
        count <= (others => '0');
      else 
        count <= count + 1;
      end if;
    end if;
  end process;
  
  P_adcclk: process (adc_clk_I, RST_I, clk_pre_scaler_ena) 
  begin
    if adc_clk_I'event and adc_clk_I = '1'  then
      if RST_I = '1' or clk_pre_scaler_ena = '0' then
        reduced_clk <= '0';
      elsif count_max = '1' then
        reduced_clk <= not(reduced_clk);
      end if;
    end if;
    -- OLD     
    --     if RST_I = '1' then
    --       count <= (others => '0');
    --       s_adc_clk <= '0';
    --     elsif clk_pre_scaler_ena = '1' then
    --       if CLK_I'event and CLK_I = '1' then
    --         count <= count + 1;
    --         if count = clk_pre_scaler  then
    --           s_adc_clk <= not(s_adc_clk);
    --           count <= (others => '0');
    --         end if;        
    --       end if;
    --     else  
    --       count <= (others => '0');
    --       s_adc_clk <= CLK_I;
    --     end if;
  end process;
  same_clk <= adc_clk_I;
  
  with clk_pre_scaler_ena select    
    s_adc_clk <= reduced_clk  when '1',
                 same_clk      when others;
  
  adc_clk_O <= s_adc_clk;
                 
  --------------------------------------------------------------------------------------------------
  -- Generación ack
  
  -- When ADR_I(1) = '1', master will be accessing to confing register.
  
  ACK_O <= CYC_I and STB_I and (data_ack_ready or conf_ack_ready);
  
  data_ack_ready  <=  (read_flag_wb(conv_integer(channel_sel)) xnor read_flag_adc(conv_integer(channel_sel))) and not(WE_I);                  
  
  conf_ack_ready  <=  ADR_I(1);
  
  --------------------------------------------------------------------------------------------------
  -- Channel selection
  
  -- channel_data(0) --> Q channel
  -- channel_data(1) --> I channel (of ADC AD9201)
  
  channel_sel(0) <= ADR_I(0);
  
  P_dataread: process (s_adc_clk, adc_data_I)
  begin
    if s_adc_clk'event and s_adc_clk = '1' then
      channel_data(0) <= adc_data_I;
    end if;
    if s_adc_clk'event and s_adc_clk = '0' then
      channel_data(1) <= adc_data_I;
    end if;  
  end process;
  
  P_flags: process (s_adc_clk, CLK_I, CYC_I, STB_I, ADR_I, read_flag_adc, read_flag_wb,channel_sel)
  begin
    
    if s_adc_clk'event and s_adc_clk = '1' then
      read_flag_adc(0) <= read_flag_wb(0);
    end if;
    
    if s_adc_clk'event and s_adc_clk = '0' then
      read_flag_adc(1) <= read_flag_wb(1);
    end if;
    
    if CLK_I'event and CLK_I = '1' then 
      if RST_I = '1' then
        read_flag_wb <= (others => '0');
        --read_flag_adc <= (others => '1');
      elsif CYC_I = '1' and STB_I = '1' and ADR_I(1) = '0' then  -- read_flag(conv_integer(channel_sel)) = '0' and  
        read_flag_wb(conv_integer(channel_sel)) <= not(read_flag_adc(conv_integer(channel_sel)));
      end if;
    end if;
    
    
    
  end process;
  
  adc_sel_O <= s_adc_clk;     
  
  --------------------------------------------------------------------------------------------------
  -- Lectura y escritura de datos
  ---- Generación de DAT_O
  DAT_O   <=  selector(conv_integer(ADR_I));
  
  ---- Almacenado de registro de configuración
  P_output: process (CLK_I, ADR_I, RST_I, DAT_I) 
  begin
    
    if CLK_I'event and CLK_I = '1' then
      if RST_I = '1' then
        config <= DEFALT_CONFIG;
      elsif WE_I = '1' and  CYC_I = '1' and STB_I = '1' then
        if unsigned(ADR_I) = 2 then
          config <= DAT_I; 
        end if;
      end if;             
    end if;

  end process;


end architecture archdaq2;