-------------------------------------------------------------------------------------------------100
--| Modular Oscilloscope
--| UNSL - Argentine
--|
--| File: ctrl.vhd
--| Version: 0.1
--| Tested in: Actel A3PE1500
--|   Board: RVI Prototype Board + LP Data Conversion Daughter Board
--|-------------------------------------------------------------------------------------------------
--| Description:
--|   CONTROL - Control system
--|   This is the tom modules in the folder.
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


--==================================================================================================
-- TO DO
-- · 
--==================================================================================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.math_real.all;

use work.ctrl_pkg.all;

entity ctrl is
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
end entity ctrl;



architecture WSM of ctrl is
  -- machine
  type StateType is (
          ST_IDLE,
          ST_INIT,
          ST_RUNNING,
          ST_ADCWRITE_INIT,
          ST_ADCWRITE
          );
  signal next_state, present_state: StateType;
  

  -- trigger
  signal trigger_reset:           std_logic;
  signal trigger_en:              std_logic;
  signal trigger_out_adr:         std_logic_vector(13 downto 0);
  signal trigger_act:              std_logic;
  signal reg_trigger_en:          std_logic;
  signal reg_trigger_edge:        std_logic;
  signal reg_trigger_level:       std_logic_vector(9 downto 0);
  signal reg_trigger_offset:      std_logic_vector(14 downto 0);
  signal reg_trigger_channel:     std_logic_vector(0 downto 0);
  
  -- channels
  signal reg_channels_selection:  std_logic_vector(1 downto 0);
  signal chsel_first_channel:     std_logic;
  signal chsel_channel:           std_logic_vector(0 downto 0);
  signal chsel_reset:             std_logic;
  --signal chsel_en:                std_logic;
  
  -- address
  signal reg_buffer_size:         std_logic_vector(13 downto 0);
  
  -- skipper
  --signal dskip_en:         std_logic;
  signal dskip_reset:        std_logic;
  signal dskip_out_ack:      std_logic;
  signal reg_time_scale:     std_logic_vector(4 downto 0);
  signal reg_time_scale_en:  std_logic;
  
  -- Memory writer
  signal memwr_en:          std_logic;
  signal memwr_reset:       std_logic;
  --signal memwr_ack:         std_logic;
  --signal memwr_continuous:  std_logic;
  signal memwr_out_stb_daq: std_logic;
  signal memwr_in_ack_mem:  std_logic;
  signal memwr_out_cyc_daq: std_logic;
  signal memwr_out_adr:     std_logic_vector (13 downto 0);
  signal memwr_in_dat:      std_logic_vector (15 downto 0);
  signal memwr_out_dat:     std_logic_vector (15 downto 0);
  
  -- Outmgr
  --signal outmgr_reset:       std_logic;
  signal outmgr_en:          std_logic;
  signal outmgr_load:        std_logic;
  signal outmgr_initial_adr: std_logic_vector(13 downto 0);
  --signal outmgr_pause_adr:    std_logic; -- ??
  signal outmgr_finish:      std_logic;
  signal outmgr_in_cyc:      std_logic;
  signal outmgr_in_stb:      std_logic;
  signal outmgr_out_akc:     std_logic;
  signal outmgr_out_dat:     std_logic_vector(15 downto 0);
  
  --------------------------------------------------------------------------------------------------
  -- DAQ config
  signal dat_to_adc: std_logic_vector(15 downto 0);
  signal strobe_adc: std_logic;
  signal write_in_adc: std_logic;
  
  
  --------------------------------------------------------------------------------------------------
  -- Flags
  signal status: std_logic_vector(1 downto 0);
  signal next_status1: std_logic;
  signal stop: std_logic;
  signal start: std_logic;
  signal continuous: std_logic;
  
  

  
  

begin
  --------------------------------------------------------------------------------------------------
  -- Instances
  
  U_CTRL_OUTMGR0: ctrl_output_manager
  generic map(
      MEM_ADD_WIDTH => 14 --: integer :=  14
    )
    port map(
      -- MASTER (to memory) 
      DAT_I_mem => DAT_I_memr, -- direct
      ADR_O_mem => ADR_O_memr, -- direct
      CYC_O_mem => CYC_O_memr, -- direct
      STB_O_mem => STB_O_memr, -- direct
      ACK_I_mem => ACK_I_memr, -- direct
      WE_O_mem  => WE_O_memr, -- direct
      -- SLAVE (to I/O ports) 
      DAT_O_port => outmgr_out_dat,
      CYC_I_port => outmgr_in_cyc,
      STB_I_port => outmgr_in_stb,
      ACK_O_port => outmgr_out_akc,
      WE_I_port  => '0',
      -- Common signals 
      RST_I      => RST_I_port, -- direct
      CLK_I      => CLK_I_port, -- direct
      -- Internal
      load_I            => outmgr_load,
      enable_I          => outmgr_en,
      initial_address_I => outmgr_initial_adr,
      biggest_address_I => reg_buffer_size,
      pause_address_I   => memwr_out_adr,
      finish_O          => outmgr_finish
    );

  U_CTRL_MEMWR0: ctrl_memory_writer
    generic map(
      MEM_ADD_WIDTH => 14--: integer :=  14
    )
    port map(
      -- to memory
      DAT_O_mem => memwr_out_dat,  -- direct
      ADR_O_mem => memwr_out_adr,   
      CYC_O_mem => CYC_O_memw,  -- direct
      STB_O_mem => STB_O_memw,  -- direct
      ACK_I_mem => memwr_in_ack_mem,  -- direct
      WE_O_mem  => WE_O_memw,   -- direct
      -- to acquistion module
      DAT_I_adc => memwr_in_dat,    
      CYC_O_adc => memwr_out_cyc_daq,   -- direct
      STB_O_adc => memwr_out_stb_daq,   -- direct
      ACK_I_adc => dskip_out_ack,
      -- Common signals 
      RST_I => RST_I_daq,       -- direct
      CLK_I => CLK_I_daq,       -- direct
      -- Internal
      reset_I         => memwr_reset,
      enable_I        => memwr_en,
      final_address_I => reg_buffer_size,
      finished_O      => open,            -- !
      continuous_I    => reg_trigger_en
    );
  
  
  U_CTRL_DSKIP0: ctrl_data_skipper
    generic map(
      SELECTOR_WIDTH    => 5--: integer := 5 
    )
    port map(
      ack_O             => dskip_out_ack,
      ack_I             => ACK_I_daq, -- direct
      stb_I             => memwr_out_stb_daq,
      selector_I        => reg_time_scale,
      enable_skipper_I  => reg_time_scale_en,
      reset_I           => dskip_reset,
      clk_I             => CLK_I_daq, -- direct
      first_channel_I   => chsel_first_channel
    );
  
  
  U_CTRL_CHSEL0: ctrl_channel_selector
    generic map(
      CHANNEL_WIDTH     => 1 -- number of channels 2**CHANNEL_WIDTH, max. 4 
    )
    port map(
      channels_I        => reg_channels_selection,
      channel_number_O  => chsel_channel,
      first_channel_O   => chsel_first_channel,
      clk_I             => CLK_I_daq,
      enable_I          => '1',
      reset_I           => chsel_reset
    );
  
  
  U_CTRL_TRIGGER0: ctrl_trigger_manager
    generic map(
      MEM_ADD_WIDTH   => 14,--:  integer := 14;
      DATA_WIDTH      => 10,--:  integer := 10;
      CHANNELS_WIDTH  => 1 --:   integer := 4
    )
    port map(
      data_I          => memwr_out_dat(9 downto 0),  -- values beign writed in memory
      channel_I       => memwr_out_dat(10 downto 10),
      trig_channel_I  => reg_trigger_channel,
      address_I       => memwr_out_adr,
      final_address_I => reg_buffer_size,
      offset_I        => reg_trigger_offset,
      level_I         => reg_trigger_level,
      falling_I       => reg_trigger_edge,
      clk_I           => CLK_I_daq,
      reset_I         => trigger_reset,
      enable_I        => trigger_en,
      trigger_O       => trigger_act,
      address_O       => trigger_out_adr
    );
  
  -- reg_: signals from conf registers
  U_CTRL_ADDALLOC0: ctrl_address_allocation
    port map(
      -- From port
      DAT_I_port        => DAT_I_port,
      DAT_O_port        => DAT_O_port,
      ADR_I_port        => ADR_I_port,
      CYC_I_port        => CYC_I_port,
      STB_I_port        => STB_I_port,
      ACK_O_port        => ACK_O_port,
      WE_I_port         => WE_I_port,
      RST_I             => RST_I_port,
      CLK_I             => CLK_I_port,
      -- To internal 
      CYC_O_int         => outmgr_in_cyc,
      STB_O_int         => outmgr_in_stb,
      ACK_I_int         => outmgr_out_akc,
      DAT_I_int         => outmgr_out_dat,
      -- Internal
      time_scale_O      => reg_time_scale,   
      time_scale_en_O   => reg_time_scale_en,
      channels_sel_O    => reg_channels_selection,
      buffer_size_O     => reg_buffer_size,  

      trigger_en_O      => reg_trigger_en,   
      trigger_edge_O    => reg_trigger_edge, 
      trigger_level_O   => reg_trigger_level,
      trigger_offset_O  => reg_trigger_offset,
      trigger_channel_O => reg_trigger_channel,

      error_number_I    => "000", -- not implemented yet

      adc_conf_O        => dat_to_adc,
      
      start_O           => start,
      continuous_O      => continuous,
      status_I         =>  status,
      write_in_adc_O    => write_in_adc,
      stop_O            => stop
    );

  ------------------------------------------------------------------------------------------------
  -- Assignments
  ADR_O_memw <= memwr_out_adr;
  DAT_O_memw <= memwr_out_dat;
  
  ADR_O_daq <= '0' & chsel_channel(0) when strobe_adc = '0' 
          else "10";
  DAT_O_daq <= dat_to_adc;
  CYC_O_daq <= strobe_adc or memwr_out_cyc_daq;
  STB_O_daq <= strobe_adc or memwr_out_stb_daq;
  WE_O_daq <= strobe_adc ;
  
  
  memwr_in_dat <= (15 downto 11 => '0') &  chsel_channel & DAT_I_daq(9 downto 0); 
  memwr_in_ack_mem <= ACK_I_memw;
  
  ------------------------------------------------------------------------------------------------
  -- Machine
  P_sm_comb: process (present_state, reg_trigger_en, trigger_out_adr, memwr_out_adr, 
  memwr_in_ack_mem, outmgr_finish, continuous, ack_i_daq,next_status1,trigger_act)
  begin
    -- signals from output manager are described in next process
    case present_state is
      when ST_INIT => 
        
        memwr_reset       <= '1';
        memwr_en          <= '-';
        
        dskip_reset   <= '1';
        
        chsel_reset   <= '0';
        
        trigger_reset <= '1';
        trigger_en    <= '-';
        
        status(0) <= '1';
        --  next_status1: above
        
        strobe_adc <= '0';
        
        -- -- -- --
        if outmgr_finish = '0' then 
          next_state <= ST_RUNNING;
          next_status1 <= not(status(1)); -- will be changed every buffer full read 
        else
          next_state <= ST_INIT;
          next_status1 <= status(1);
        end if;
        -- if there is an error manager, include "if" for errors in parameters
       
        
        
      when ST_RUNNING =>

        memwr_reset       <= '0';
        if reg_trigger_en = '1' and trigger_out_adr = memwr_out_adr and trigger_act = '1' then
          memwr_en        <= '0';
        else
          memwr_en        <= '1';
        end if;
        
        dskip_reset   <= '0';
        
        chsel_reset   <= '0';
        
        trigger_reset <= '0';
        trigger_en    <= reg_trigger_en and memwr_in_ack_mem;
        
        status(0) <= '1';
        next_status1 <= status(1);
        
        strobe_adc <= '0';
        
        -- -- -- --
        -- if there is an error manager, influde an if for errors in running, etc...
        if outmgr_finish = '1' then 
          if continuous = '1' then
            next_state <= ST_INIT;
          else
            next_state <= ST_IDLE;
          end if;
        else
          next_state <= ST_RUNNING;
        end if;
         
      when ST_ADCWRITE_INIT =>
        memwr_reset       <= '1';
        memwr_en          <= '-';
        
        dskip_reset   <= '1';
        
        chsel_reset   <= '1';
        
        trigger_reset <= '1';
        trigger_en    <= '-';
        
        status(0) <= '1'; -- aviod an ack if there is a read/write from port
        next_status1 <= status(1);
        
        strobe_adc <= '0';
        
        -- -- -- --
        next_state <= ST_ADCWRITE;
      
      
      when ST_ADCWRITE =>
        memwr_reset       <= '1';
        memwr_en          <= '-';
        
        dskip_reset   <= '1';
        
        chsel_reset   <= '1';
        
        trigger_reset <= '1';
        trigger_en    <= '-';
        
        status(0) <= '1'; -- aviod an ack if there is a read/write from port
        next_status1 <= status(1);
        
        strobe_adc <= '1';
        
        -- -- -- --
        if ACK_I_daq = '1' then
          next_state <= ST_IDLE;
        else
          next_state <= ST_ADCWRITE;
        end if;
      
      when others =>  --ST_IDLE
              
        memwr_reset       <= '1';
        memwr_en          <= '-';
        
        dskip_reset   <= '1';
        
        chsel_reset   <= '1';
        
        trigger_reset <= '1';
        trigger_en    <= '-';
        
        status(0) <= '0';
        next_status1 <= '0'; -- or error when there is an error manager
        
        strobe_adc <= '0';
        
        -- -- -- --
        next_state    <= ST_IDLE;
    end case;
  
  end process;
  
  

  P_sm_clkd: process (RST_I_daq, stop, start, CLK_I_daq, next_state, write_in_adc,next_status1)
  begin
  
    if RST_I_daq = '1' then
      present_state <= ST_IDLE;
      status(1) <= '0';
    elsif stop = '1' then
      present_state <= ST_IDLE;
      status(1) <= '0';
    elsif write_in_adc = '1' then
      present_state <= ST_ADCWRITE_INIT;
      status(1) <= next_status1;
    elsif start = '1' and present_state /= ST_ADCWRITE and present_state /= ST_ADCWRITE_INIT then
      present_state <= ST_INIT;
      status(1) <= next_status1;
    elsif CLK_I_daq'event and CLK_I_daq = '1' then
      present_state <= next_state;
      status(1) <= next_status1;
    end if; 
  
  
  end process;
  
  
  
  ------------------------------------------------------------------------------------------------
  -- Output
  
  P_OUTMGR: process (RST_I_port, stop, CLK_I_port, present_state, trigger_act, 
  reg_trigger_en, memwr_out_adr, outmgr_en)
  begin
    -- load must be '1' only for one cycle, enable must be set until the end
    if RST_I_port = '1' or present_state /= ST_RUNNING then
      outmgr_load <= '0';
      outmgr_en   <=  '0';
    elsif CLK_I_port'event and CLK_I_port = '1' then
      if stop = '1' then
        outmgr_load <=  '0';
        outmgr_en   <=  '0';
      elsif outmgr_en = '1' then
        outmgr_load <= '0';
      elsif present_state = ST_RUNNING and ( trigger_act = '1' or (reg_trigger_en = '0' and 
      memwr_out_adr /= 0 ) ) then
        outmgr_load <=  '1';
        outmgr_en   <=  '1';
        -- load must be set only one cycle
      end if;
    end if;
  end process;  
  
  outmgr_initial_adr <= trigger_out_adr     when reg_trigger_en = '1' else
                        (others => '0');

end architecture;
 