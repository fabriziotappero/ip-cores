-------------------------------------------------------------------------------------------------100
--| Modular Oscilloscope
--| UNSL - Argentine
--|
--| File: ctrl_pkg.vhd
--| Version: 0.1
--| Tested in: Actel A3PE1500
--|-------------------------------------------------------------------------------------------------
--| Description:
--|   CONTROL - Package
--|   Package for instantiate Control modules.
--|   
--|-------------------------------------------------------------------------------------------------
--| File history:
--|   0.01  | jul-2009 | First incomplete
--|   0.1   | aug-2009 | First incomplete
----------------------------------------------------------------------------------------------------
--| Copyright © 2009, Facundo Aguilera.
--|
--| This VHDL design file is an open design; you can redistribute it and/or
--| modify it and/or implement it after contacting the author.
----------------------------------------------------------------------------------------------------



-- Bloque completo
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.math_real.all;

package ctrl_pkg is 
  --------------------------------------------------------------------------------------------------
  -- Componentes  
  
  component generic_decoder is
    generic(
      INPUT_WIDTH: integer := 5 -- Input with for decoder (decodes INPUT_WIDTH to 2^INPUT_WIDTH)
    );
    Port(  
      enable_I:   in std_logic;
      data_I:     in std_logic_vector(INPUT_WIDTH-1 downto 0);
      decoded_O:  out std_logic_vector( integer(2**real(INPUT_WIDTH))-1  downto 0)
    );
  end component generic_decoder;
  
  
  component generic_counter is
    generic(
      OUTPUT_WIDTH: integer := 32 -- Output width for counter.
    );
    port(  
      clk_I:    in  std_logic;
      count_O:  out std_logic_vector( OUTPUT_WIDTH  downto 0);
      reset_I:  in  std_logic;
      enable_I: in  std_logic
    );
  end component generic_counter;
  
  component ctrl_output_manager is
  generic(
      MEM_ADD_WIDTH: integer :=  14
    );
    port(
      ------------------------------------------------------------------------------------------------
      -- MASTER (to memory) 
      DAT_I_mem: in std_logic_vector (15 downto 0);
      --DAT_O_mem: out std_logic_vector (15 downto 0);
      ADR_O_mem: out std_logic_vector (MEM_ADD_WIDTH - 1  downto 0);   
      CYC_O_mem: out std_logic;  
      STB_O_mem: out std_logic;  
      ACK_I_mem: in std_logic ;
      WE_O_mem:  out std_logic;
      ------------------------------------------------------------------------------------------------
      -- SLAVE (to I/O ports) 
      --DAT_I_port: in std_logic_vector (15 downto 0);
      DAT_O_port: out std_logic_vector (15 downto 0);
      --ADR_I_port: in std_logic_vector (7 downto 0); 
      CYC_I_port: in std_logic;  
      STB_I_port: in std_logic;  
      ACK_O_port: out std_logic ;
      WE_I_port:  in std_logic;
      ------------------------------------------------------------------------------------------------
      -- Common signals 
      RST_I: in std_logic;  
      CLK_I: in std_logic;  
      ------------------------------------------------------------------------------------------------
      -- Internal
      load_I:             in std_logic;                     
      -- load initial address
      enable_I:           in std_logic;                     
      -- continue reading from the actual address ('0' means pause, '1' means continue)
      initial_address_I:  in std_logic_vector (MEM_ADD_WIDTH - 1 downto 0);
      -- buffer starts and ends here 
      biggest_address_I:  in std_logic_vector (MEM_ADD_WIDTH - 1 downto 0);
      -- when the buffer arrives here, address is changed to 0 (buffer size)
      pause_address_I:    in std_logic_vector (MEM_ADD_WIDTH - 1 downto 0);
      -- address wich is being writed by control
      finish_O:           out std_logic
      -- this is set when communication ends and remains until next restart or actual address change                                                    
    );
  end component ctrl_output_manager;
  
  component ctrl_memory_writer is
    generic(
      MEM_ADD_WIDTH: integer :=  14
    );
    port(
      ----------------------------------------------------------------------------------------------
      -- to memory
      DAT_O_mem: out std_logic_vector (15 downto 0);
      ADR_O_mem: out std_logic_vector (MEM_ADD_WIDTH - 1  downto 0);   
      CYC_O_mem: out std_logic;  
      STB_O_mem: out std_logic;  
      ACK_I_mem: in std_logic ;
      WE_O_mem:  out std_logic;
      ----------------------------------------------------------------------------------------------
      -- to acquistion module
      DAT_I_adc: in std_logic_vector (15 downto 0);
      -- Using an address generator, commented
      -- ADR_O_adc: out std_logic_vector (ADC_ADD_WIDTH - 1  downto 0); 
      CYC_O_adc: out std_logic;  
      STB_O_adc: out std_logic;  
      ACK_I_adc: in std_logic ;
      --WE_O_adc:  out std_logic;
      ----------------------------------------------------------------------------------------------
      -- Common signals 
      RST_I: in std_logic;  
      CLK_I: in std_logic;  
      ----------------------------------------------------------------------------------------------
      -- Internal
      -- reset memory address to 0
      reset_I:            in std_logic;                     
      -- read in clk edge from the actual address ('0' means pause, '1' means continue)
      enable_I:           in std_logic;                     
      final_address_I:    in std_logic_vector (MEM_ADD_WIDTH - 1 downto 0);
      -- it is set when communication ends and remains until next restart or actual address change
      finished_O:         out std_logic;
      -- when counter finishes, restart
      continuous_I:       in  std_logic
    );
  end component ctrl_memory_writer;
  
  
  component ctrl_data_skipper is
    generic(
      -- max losses = 2**(2**SELECTOR_WIDTH). (i.e., if SELECTOR_WIDTH = 5: 4.2950e+09)
      SELECTOR_WIDTH: integer := 5 
    );
    port(
      -- enable output signal
      ack_O:            out  std_logic;   
      -- sinal from wishbone interface
      ack_I, stb_I:     in  std_logic;  
      -- selector from register, equation: losses = 2**(selector_I + 1) * enable_skipper_I
      selector_I:       in   std_logic_vector(SELECTOR_WIDTH-1 downto 0);
      -- enable from register 
      enable_skipper_I: in   std_logic;
      -- common signals
      reset_I, clk_I:   in   std_logic;
      -- set when returns to the first channel
      first_channel_I:  in   std_logic
    );
  end component ctrl_data_skipper;
  
  
  component ctrl_channel_selector is
    generic(
      CHANNEL_WIDTH: integer := 4 -- number of channels 2**CHANNEL_WIDTH, max. 4
    );
    port(
      channels_I:         in  std_logic_vector(integer(2**real(CHANNEL_WIDTH))-1 downto 0);
      channel_number_O:   out std_logic_vector(CHANNEL_WIDTH - 1 downto 0);
      first_channel_O:    out std_logic; 
      clk_I:              in  std_logic;
      enable_I:           in  std_logic;
      reset_I:            in  std_logic                                                        
    );
  end component ctrl_channel_selector;
  
  
  component ctrl_trigger_manager is
    generic (
      MEM_ADD_WIDTH:  integer := 14;
      DATA_WIDTH:     integer := 10;
      CHANNELS_WIDTH: integer := 4
    );
    port (
      data_I:           in  std_logic_vector (DATA_WIDTH - 1 downto 0);
      channel_I:        in  std_logic_vector (CHANNELS_WIDTH -1 downto 0);
      trig_channel_I:   in  std_logic_vector (CHANNELS_WIDTH -1 downto 0);
      address_I:        in  std_logic_vector (MEM_ADD_WIDTH - 1 downto 0);
      final_address_I:  in  std_logic_vector (MEM_ADD_WIDTH - 1 downto 0);
      -- offset from trigger address (signed). MUST BE: 
      -- -final_address_I < offset_I < final_address_I
      offset_I:         in  std_logic_vector (MEM_ADD_WIDTH  downto 0);
      -- trigger level (from max to min, not signed)
      level_I:          in  std_logic_vector (DATA_WIDTH - 1 downto 0);
      -- use falling edge when falling_I = '1', else rising edge
      falling_I:        in  std_logic; 
      clk_I:            in  std_logic;
      reset_I:          in  std_logic;
      enable_I:         in  std_logic;
      -- it is set when trigger condition occurs
      trigger_O:        out std_logic;
      -- address when trigger plus offset
      address_O:        out std_logic_vector (MEM_ADD_WIDTH - 1 downto 0)
    );
  end component ctrl_trigger_manager;
  
  
  component ctrl_address_allocation is
    port(
      ----------------------------------------------------------------------------------------------
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
      ----------------------------------------------------------------------------------------------
      -- To internal 
      CYC_O_int: out std_logic;  
      STB_O_int: out std_logic;  
      ACK_I_int: in std_logic ;
      DAT_I_int: in std_logic_vector(15 downto 0);
      ----------------------------------------------------------------------------------------------
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
      status_I:         in std_logic_vector(1 downto 0);
      
      write_in_adc_O:     out std_logic;
      stop_O:           out std_logic
    );
  end component ctrl_address_allocation;
  
  
  component ctrl is
  port(   
    ------------------------------------------------------------------------------------------------
    -- From port
    DAT_I_port: in  std_logic_vector (15 downto 0);
    DAT_O_port: out std_logic_vector (15 downto 0);
    ADR_I_port: in  std_logic_vector (3 downto 0); 
    CYC_I_port: in  std_logic;  
    STB_I_port: in  std_logic;  
    ACK_O_port: out std_logic ;
    WE_I_port:  in  std_logic; 
    CLK_I_port: in std_logic;
    RST_I_port: in std_logic;
    
    ------------------------------------------------------------------------------------------------
    -- To ADC
    DAT_I_daq: in  std_logic_vector (15 downto 0);
    DAT_O_daq: out std_logic_vector (15 downto 0);
    ADR_O_daq: out std_logic_vector (1 downto 0); 
    CYC_O_daq: out std_logic;  
    STB_O_daq: out std_logic;  
    ACK_I_daq: in  std_logic ;
    WE_O_daq:  out std_logic;
    
    CLK_I_daq: in std_logic;
    RST_I_daq: in std_logic;
    
    ------------------------------------------------------------------------------------------------
    -- To memory, A (writing) interface (Higer prioriry)
    --DAT_I_memw: in  std_logic_vector (15 downto 0);
    DAT_O_memw: out std_logic_vector (15 downto 0);
    ADR_O_memw: out  std_logic_vector (13 downto 0);
    CYC_O_memw: out  std_logic;  
    STB_O_memw: out  std_logic;  
    ACK_I_memw: in std_logic ;
    WE_O_memw:  out  std_logic;
    
    ------------------------------------------------------------------------------------------------
    -- To memory, B (reading) interface
    DAT_I_memr: in  std_logic_vector (15 downto 0);
    --DAT_O_memr: out std_logic_vector (15 downto 0);
    ADR_O_memr: out  std_logic_vector (13 downto 0);
    CYC_O_memr: out  std_logic;  
    STB_O_memr: out  std_logic;  
    ACK_I_memr: in std_logic ;
    WE_O_memr:  out  std_logic

  );
  end component ctrl;
  
end package ctrl_pkg;
  