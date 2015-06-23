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
--|   MODULAR OSCILLOSCOPE - Main
--|   This is the top top module.
--|   
--|-------------------------------------------------------------------------------------------------
--| File history:
--|   0.1   | aug-2009 | First testing
----------------------------------------------------------------------------------------------------
--| Copyright © 2009, Facundo Aguilera (budinero at gmail.com).
--|
--| This VHDL design file is an open design; you can redistribute it and/or
--| modify it and/or implement it after contacting the author.
----------------------------------------------------------------------------------------------------


-- NOTES: 
-- · daq clock: 40 MHz
-- · epp clock: 2.5 MHz
-- · (!) normal high reset button, inverted here

--==================================================================================================
-- TO DO
-- · Full full test
--==================================================================================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.math_real.all;

use work.ctrl_pkg.all;
use work.daq_pkg.all;
use work.memory_pkg.all;
use work.eppwbn_pkg.all;

entity modular_oscilloscope is
  port(   
    -- ADC
    adc_data_I:     in    std_logic_vector (9 downto 0);
    adc_sel_O:      out   std_logic;
    adc_clk_O:      out   std_logic;
    adc_sleep_O:    out   std_logic;
    adc_chip_sel_O: out   std_logic;

    -- EPP
    nStrobe_I:      in std_logic;                       --  HostClk/nWrite 
    Data_IO:        inout std_logic_vector (7 downto 0);--   AD8..1 (Data1..Data8)
    nAck_O:         out std_logic;                      --  PtrClk/PeriphClk/Intr
    busy_O:         out std_logic;                      --  PtrBusy/PeriphAck/nWait
    PError_O:       out std_logic;                      --  AckData/nAckReverse
    Sel_O:          out std_logic;                      --  XFlag (Select)
    nAutoFd_I:      in std_logic;                       --  HostBusy/HostAck/nDStrb
    PeriphLogicH_O: out std_logic;                      --  (Periph Logic High)
    nInit_I:        in std_logic;                       --  nReverseRequest
    nFault_O:       out std_logic;                      --  nDataAvail/nPeriphRequest
    nSelectIn_I:    in std_logic;                       --  1284 Active/nAStrb
    
    -- Peripherals
    reset_I:    in std_logic; 
    pll_clk_I:  in std_logic  -- clock signal go to pll, and is divided in two clocks

  );
end entity modular_oscilloscope;

architecture structural1 of modular_oscilloscope is

    ------------------------------------------------------------------------------------------------
    -- From port
    signal ctrl_dat_i_port: std_logic_vector (15 downto 0);
    signal ctrl_dat_o_port: std_logic_vector (15 downto 0);
    signal ctrl_adr_i_port: std_logic_vector (7 downto 0); 
    signal ctrl_cyc_i_port: std_logic;  
    signal ctrl_stb_i_port: std_logic;  
    signal ctrl_ack_o_port: std_logic ;
    signal ctrl_we_i_port:  std_logic; 

    signal ctrl_dat_i_daq: std_logic_vector (15 downto 0);
    signal ctrl_dat_o_daq: std_logic_vector (15 downto 0);
    signal ctrl_adr_o_daq: std_logic_vector (1 downto 0); 
    signal ctrl_cyc_o_daq: std_logic;  
    signal ctrl_stb_o_daq: std_logic;  
    signal ctrl_ack_i_daq: std_logic;
    signal ctrl_we_o_daq:  std_logic;

    signal ctrl_dat_o_memw:  std_logic_vector (15 downto 0);
    signal ctrl_adr_o_memw:  std_logic_vector (13 downto 0);
    signal ctrl_cyc_o_memw:  std_logic;  
    signal ctrl_stb_o_memw:  std_logic;  
    signal ctrl_ack_i_memw:  std_logic ;
    signal ctrl_we_o_memw:   std_logic;
    
    signal ctrl_dat_i_memr:   std_logic_vector (15 downto 0);
    signal ctrl_adr_o_memr:   std_logic_vector (13 downto 0);
    signal ctrl_cyc_o_memr:   std_logic;  
    signal ctrl_stb_o_memr:   std_logic;  
    signal ctrl_ack_i_memr:   std_logic ;
    signal ctrl_we_o_memr:    std_logic;
    
    signal clk_daq, clk_port:  std_logic;
    
    signal inverted_reset: std_logic;

begin
    
    
    inverted_reset <= not(reset_I);
    
    
  U_DAQ: daq 
    generic map(
    DEFALT_CONFIG  => "0000001000000000"
    --                 5432109876543210 
    --: std_logic_vector := "0000100000000000"
                                      -- bits 8 a 0       clk_pre_scaler
                                      -- bits 9           clk_pre_scaler_ena
                                      -- bit 10           adc sleep
                                      -- bit 11           adc_chip_sel
                                      -- bits 12 a 15     sin usar
                                      
                                      -- si clk_pre_scaler_ena = 1
                                      -- frecuencia_adc = frecuencia_wbn / ((clk_pre_scaler+1)*2)
                                      -- sino frecuencia_adc = frecuencia_wbn
  )
  port map(
    -- Externo
    adc_data_I      => adc_data_I,
    adc_sel_O       => adc_sel_O,
    adc_clk_O       => adc_clk_O,
    adc_sleep_O     => adc_sleep_O,
    adc_chip_sel_O  => adc_chip_sel_O,
    --  Interno
    RST_I => inverted_reset,
    CLK_I => clk_daq,
    DAT_I => ctrl_dat_o_daq,
    ADR_I => ctrl_adr_o_daq,
    CYC_I => ctrl_cyc_o_daq,
    STB_I => ctrl_stb_o_daq,
    WE_I  => ctrl_we_o_daq,
    DAT_O => ctrl_dat_i_daq,
    ACK_O => ctrl_ack_i_daq,
    
    adc_clk_I => clk_daq
    );

  
  U_EPP16: eppwbn_16bit 
  port map (
    -- TEMPORAL
    --epp_mode_monitor: out std_logic_vector (1 downto 0);
    -- Externo
    nStrobe       => nStrobe_I,
    Data          => Data_IO,
    nAck          => nAck_O,
    busy          => busy_O,
    PError        => PError_O,
    Sel           => Sel_O,
    nAutoFd       => nAutoFd_I,
    PeriphLogicH  => PeriphLogicH_O,
    nInit         => nInit_I,
    nFault        => nFault_O,
    nSelectIn     => nSelectIn_I,
    --  Interno
    RST_I => inverted_reset,
    CLK_I => clk_port,
    DAT_I => ctrl_dat_o_port,
    DAT_O => ctrl_dat_i_port,
    ADR_O => ctrl_adr_i_port,
    CYC_O => ctrl_cyc_i_port,
    STB_O => ctrl_stb_i_port,
    ACK_I => ctrl_ack_o_port,
    WE_O  => ctrl_we_i_port
    );
  
  U_CTRL: ctrl
  port map(   
    
    DAT_I_port => ctrl_dat_i_port,
    DAT_O_port => ctrl_dat_o_port,
    ADR_I_port => ctrl_adr_i_port(3 downto 0),
    CYC_I_port => ctrl_cyc_i_port,
    STB_I_port => ctrl_stb_i_port,
    ACK_O_port => ctrl_ack_o_port,
    WE_I_port =>  ctrl_we_i_port,
    CLK_I_port => clk_port,
    RST_I_port => inverted_reset,
    
    DAT_I_daq => ctrl_dat_i_daq,
    DAT_O_daq => ctrl_dat_o_daq,
    ADR_O_daq => ctrl_adr_o_daq,
    CYC_O_daq => ctrl_cyc_o_daq,
    STB_O_daq => ctrl_stb_o_daq,
    ACK_I_daq => ctrl_ack_i_daq,
    WE_O_daq =>  ctrl_we_o_daq,
    CLK_I_daq => clk_daq,
    RST_I_daq => inverted_reset,
                 
    DAT_O_memw => ctrl_dat_o_memw,
    ADR_O_memw => ctrl_adr_o_memw,
    CYC_O_memw => ctrl_cyc_o_memw,
    STB_O_memw => ctrl_stb_o_memw,
    ACK_I_memw => ctrl_ack_i_memw,
    WE_O_memw =>  ctrl_we_o_memw,
    
    DAT_I_memr => ctrl_dat_i_memr,
    ADR_O_memr => ctrl_adr_o_memr,
    CYC_O_memr => ctrl_cyc_o_memr,
    STB_O_memr => ctrl_stb_o_memr,
    ACK_I_memr => ctrl_ack_i_memr,
    WE_O_memr =>  ctrl_we_o_memr
  );             
                 
  U_DPORTMEM: dual_port_memory_wb 
    port map(    
      -- Puerto A (Higer prioriry)
      RST_I_a => inverted_reset,
      CLK_I_a => clk_daq,
      DAT_I_a => ctrl_dat_o_memw,
      DAT_O_a => open,
      ADR_I_a => ctrl_adr_o_memw,
      CYC_I_a => ctrl_cyc_o_memw,
      STB_I_a => ctrl_stb_o_memw,
      ACK_O_a => ctrl_ack_i_memw,
      WE_I_a =>  ctrl_we_o_memw,
      -- Puerto B (Lower prioriry)
      RST_I_b => inverted_reset,
      CLK_I_b => clk_port,
      DAT_I_b => X"0000",
      DAT_O_b => ctrl_dat_i_memr,
      ADR_I_b => ctrl_adr_o_memr,
      CYC_I_b => ctrl_cyc_o_memr,
      STB_I_b => ctrl_stb_o_memr,
      ACK_O_b => ctrl_ack_i_memr,
      WE_I_b =>  ctrl_we_o_memr
    );
                 
  U_PLL0: entity work.A3PE_pll_2clk
    port map(    
      POWERDOWN       =>  '0',
      CLKA            =>  pll_clk_I,
      LOCK            =>  open,
      --SDIN            =>  '0',
      --SCLK            =>  '0',
      --SSHIFT          =>  '0',
      --SUPDATE         =>  '0',
      --MODE            =>  '0',
      GLA             =>  clk_daq,
      GLB             =>  clk_port
      --SDOUT           =>  open
    );

end architecture;
 