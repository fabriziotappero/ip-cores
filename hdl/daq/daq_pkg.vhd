----------------------------------------------------------------------------------------------------
--| Modular Oscilloscope
--| UNSL - Argentine
--|
--| File: daq_pkg.vhd
--| Version: 0.01
--| Tested in: Actel A3PE1500
--|-------------------------------------------------------------------------------------------------
--| Description:
--|   Adquisition control module.
--|	  Package for instantiate all adq modules.
--|-------------------------------------------------------------------------------------------------
--| File history:
--|   0.01  | apr-2009 | First release
----------------------------------------------------------------------------------------------------
--| Copyright © 2009, Facundo Aguilera.
--|
--| This VHDL design file is an open design; you can redistribute it and/or
--| modify it and/or implement it after contacting the author.
----------------------------------------------------------------------------------------------------


-- Bloque completo
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package daq_pkg is	
	--------------------------------------------------------------------------------------------------
	-- Componentes  
  
  component daq is
    generic (
    DEFALT_CONFIG : std_logic_vector := "0000100000000000"
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
    adc_chip_sel_O: out   std_logic;
    

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
  end component daq;
  
end package daq_pkg;
	