-------------------------------------------------------------------------------
-- File: rise.vhd
-- Author: Jakob Lechner, Urban Stadler, Harald Trinkl, Christian Walter
-- Created: 2006-11-29
-- Last updated: 2006-11-29

-- Description:
-- Top-Level entity of RISE CPU
-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;

use WORK.RISE_PACK.all;
use work.RISE_PACK_SPECIFIC.all;

entity rise is
  
  port (
    clk         : in  std_logic;
    reset       : in std_logic;
    -- uart
    rx          : in  std_logic;
    tx          : out std_logic);

end rise;


architecture rise_rtl of rise is

  -- if_stage signals
  signal if_id_register_sig        : IF_ID_REGISTER_T;
  signal branch_sig             : std_logic;
  signal branch_target_sig         : PC_REGISTER_T;
  signal stall_in_if_sig           : std_logic;
  signal clear_in_if_sig           : std_logic;
  signal pc_if_sig                 : PC_REGISTER_T;
  signal pc_next_if_sig            : PC_REGISTER_T;
  signal imem_addr_sig             : MEM_ADDR_T;
  signal imem_data_sig             : MEM_DATA_T;
  -- id_stage signals
  signal id_ex_register_sig        : ID_EX_REGISTER_T;
  signal rx_addr_sig               : REGISTER_ADDR_T;
  signal ry_addr_sig               : REGISTER_ADDR_T;
  signal rz_addr_sig               : REGISTER_ADDR_T;
  signal rx_sig                    : REGISTER_T;
  signal ry_sig                    : REGISTER_T;
  signal rz_sig                    : REGISTER_T; 
  signal sr_id_sig                 : SR_REGISTER_T;
  signal lock_register_sig         : LOCK_REGISTER_T;
  signal stall_in_id_sig           : std_logic;
  signal stall_out_id_sig          : std_logic;
  signal clear_in_id_sig           : std_logic;
  -- ex_stage signals
  signal ex_mem_register_sig       :  EX_MEM_REGISTER_T;
  signal stall_in_ex_sig           : std_logic;
  signal clear_in_ex_sig           : std_logic;
  signal clear_out_ex_sig          : std_logic;
  signal clear_locks_sig           : std_logic;
  -- mem_stage signals
  signal mem_wb_register_sig       : MEM_WB_REGISTER_T;
  signal dmem_addr_sig             : MEM_ADDR_T;
  signal dmem_data_in_sig          : MEM_DATA_T;
  signal dmem_data_out_sig         : MEM_DATA_T;
  signal stall_out_mem_sig         : std_logic;
  signal clear_in_mem_sig          : std_logic;
  signal clear_out_mem_sig         : std_logic;
  -- wb_stage signals
  signal dreg_addr_sig             : REGISTER_ADDR_T;
  signal dreg_sig                  : REGISTER_T;
  signal dreg_enable_sig           : std_logic;
  signal lr_sig                    : PC_REGISTER_T;
  signal lr_enable_sig             : std_logic;
  signal sr_wb_sig                 : SR_REGISTER_T;
  signal sr_enable_sig             : std_logic;
  signal clear_out_wb_sig          : std_logic;
  -- imem signals
  signal data_in_imem_sig          : MEM_DATA_T;  -- unused at the moment
  signal wr_enable_imem_sig        : std_logic;   -- unused at the moment
  -- dmem signals
  signal wr_enable_dmem_sig        : std_logic;	
  signal dmem_rxd_sig      		  : std_logic;
  signal dmem_txd_sig        		  : std_logic;
  -- rlu signals
  signal clear_lock0_sig      : std_logic := '0';
  signal clear_lock_addr0_sig : REGISTER_ADDR_T;

  signal clear_lock1_sig      : std_logic := '0';
  signal clear_lock_addr1_sig : REGISTER_ADDR_T;

  signal set_lock0_sig      : std_logic := '0';
  signal set_lock_addr0_sig : REGISTER_ADDR_T;

  signal set_lock1_sig      : std_logic := '0';
  signal set_lock_addr1_sig : REGISTER_ADDR_T;
  
  component if_stage
    port (
      clk            : in std_logic;
      reset          : in std_logic;

      if_id_register : out IF_ID_REGISTER_T;

      branch         : in std_logic;
      branch_target  : in PC_REGISTER_T;
      clear_in       : in std_logic;
      stall_in       : in std_logic;

      pc             : in PC_REGISTER_T;
      pc_next        : out PC_REGISTER_T;

      imem_addr      : out MEM_ADDR_T;
      imem_data      : in MEM_DATA_T);
  end component;

  component id_stage  
    port (
      clk            : in std_logic;
      reset          : in std_logic;

      if_id_register : in IF_ID_REGISTER_T;
      id_ex_register : out ID_EX_REGISTER_T;

      rx_addr        : out REGISTER_ADDR_T;
      ry_addr        : out REGISTER_ADDR_T;
      rz_addr        : out REGISTER_ADDR_T;
      
      rx             : in REGISTER_T;
      ry             : in REGISTER_T;
      rz             : in REGISTER_T; 
      sr             : in SR_REGISTER_T;

      lock_register  : in LOCK_REGISTER_T;
      set_reg_lock0  : out std_logic;
      lock_reg_addr0 : out REGISTER_ADDR_T;
      set_reg_lock1  : out std_logic;
      lock_reg_addr1 : out REGISTER_ADDR_T;
      
      stall_in       : in std_logic;
      stall_out      : out std_logic;
      clear_in       : in std_logic);
  end component;

  component ex_stage
    port (
      clk                 : in std_logic;
      reset               : in std_logic;

      id_ex_register      : in ID_EX_REGISTER_T;
      ex_mem_register     : out EX_MEM_REGISTER_T;

      branch              : out std_logic;
      stall_in            : in std_logic;
      clear_in            : in std_logic;
      clear_out           : out std_logic;
      clear_locks         : out std_logic);
  end component;

  component mem_stage
    port (
      clk                 : in std_logic;
      reset               : in std_logic;

      ex_mem_register     : in EX_MEM_REGISTER_T;
      mem_wb_register     : out MEM_WB_REGISTER_T;

      dmem_addr           : out MEM_ADDR_T;
      dmem_data_in        : in MEM_DATA_T;
      dmem_data_out       : out MEM_DATA_T;
      dmem_wr_enable      : out std_logic;

      stall_out           : out std_logic;
      clear_in            : in std_logic;
      clear_out           : out std_logic);
  end component;
  
  component wb_stage
    port (
      clk                 : in std_logic;
      reset               : in std_logic;

      mem_wb_register     : in MEM_WB_REGISTER_T;
      
      dreg_addr           : out REGISTER_ADDR_T;
      dreg                : out REGISTER_T;
      dreg_enable         : out std_logic;
      
      lr                  : out PC_REGISTER_T;
      lr_enable           : out std_logic;
      
      sr                  : out SR_REGISTER_T;
      sr_enable           : out std_logic;
      
      clear_out           : out std_logic;
      
      clear_reg_lock0     : out std_logic;
      lock_reg_addr0      : out REGISTER_ADDR_T;
      clear_reg_lock1     : out std_logic;
      lock_reg_addr1      : out REGISTER_ADDR_T);
  end component;

  component register_file
    port (
      clk            : in std_logic;
      reset          : in std_logic;

      rx_addr        : in REGISTER_ADDR_T;
      ry_addr        : in REGISTER_ADDR_T;
      rz_addr        : in REGISTER_ADDR_T;
      
      rx_read        : out REGISTER_T;
      ry_read        : out REGISTER_T;
      rz_read        : out REGISTER_T;
      
      dreg_addr      : in REGISTER_ADDR_T; 
      dreg_write     : in REGISTER_T;
      dreg_enable    : in std_logic;	
      
      sr_read        : out SR_REGISTER_T;
      sr_write       : in SR_REGISTER_T;
      sr_enable      : in std_logic;
      
      lr_write       : in PC_REGISTER_T;
      lr_enable	     : in std_logic;
      
      pc_write       : in PC_REGISTER_T;
      pc_read        : out PC_REGISTER_T);
  end component;

  component imem
    port (
      clk            : in std_logic;
      reset          : in std_logic;
      wr_enable      : in std_logic;
      addr           : in MEM_ADDR_T;
      data_in        : in MEM_DATA_T;
      data_out       : out MEM_DATA_T);
  end component;

  component dmem
    port (
      clk            : in std_logic;
      reset          : in std_logic;
      wr_enable	   : in std_logic;
      addr           : in MEM_ADDR_T;
      data_in        : in MEM_DATA_T;
      data_out       : out MEM_DATA_T;
		uart_txd 		: out std_logic;
		uart_rxd 		: in std_logic);
  end component;

  component rlu   
    port (
      clk   : in std_logic;
      reset : in std_logic;
      clear_locks : in std_logic;
    
      lock_register       : out LOCK_REGISTER_T;

      set_lock0           : in std_logic;
      set_lock_addr0      : in REGISTER_ADDR_T;

      set_lock1           : in std_logic;
      set_lock_addr1      : in REGISTER_ADDR_T;
      
      clear_lock0         : in std_logic;
      clear_lock_addr0    : in REGISTER_ADDR_T;
      
      clear_lock1         : in std_logic;
      clear_lock_addr1    : in REGISTER_ADDR_T);

  end component;
  
begin  -- rise_rtl

  if_stage_unit : if_stage
    port map (
      clk            => clk,
      reset          => reset,
      
      if_id_register => if_id_register_sig,

      branch         => branch_sig,
      branch_target  => branch_target_sig,
      clear_in       => clear_in_if_sig,
      stall_in       => stall_in_if_sig,

      pc             => pc_if_sig,
      pc_next        => pc_next_if_sig,

      imem_addr      => imem_addr_sig,
      imem_data      => imem_data_sig);

  id_stage_unit : id_stage      
    port map (
      clk            => clk,
      reset          => reset,

      if_id_register => if_id_register_sig,
      id_ex_register => id_ex_register_sig,

      rx_addr        => rx_addr_sig,
      ry_addr        => ry_addr_sig,
      rz_addr        => rz_addr_sig,
      
      rx             => rx_sig,
      ry             => ry_sig,
      rz             => rz_sig,
      sr             => sr_id_sig,

      lock_register  => lock_register_sig,
      
      set_reg_lock0  => set_lock0_sig,
      lock_reg_addr0 => set_lock_addr0_sig,
      set_reg_lock1  => set_lock1_sig,
      lock_reg_addr1 => set_lock_addr1_sig,
      
      stall_in       => stall_in_id_sig,
      stall_out      => stall_out_id_sig,
      clear_in       => clear_in_id_sig);

  ex_stage_unit : ex_stage
    port map (
      clk                 => clk,
      reset               => reset,

      id_ex_register      => id_ex_register_sig,
      ex_mem_register     => ex_mem_register_sig,

      branch              => branch_sig,
      stall_in            => stall_in_ex_sig,
      clear_in            => clear_in_ex_sig,
      clear_out           => clear_out_ex_sig,
      clear_locks         => clear_locks_sig);

  mem_stage_unit : mem_stage
    port map (
      clk                 => clk,
      reset               => reset,

      ex_mem_register     => ex_mem_register_sig,
      mem_wb_register     => mem_wb_register_sig,

      dmem_addr           => dmem_addr_sig,
      dmem_data_in        => dmem_data_in_sig,
      dmem_data_out       => dmem_data_out_sig,
      dmem_wr_enable      => wr_enable_dmem_sig,
      
      stall_out           => stall_out_mem_sig,
      clear_in            => clear_in_mem_sig,
      clear_out           => clear_out_mem_sig);
  
  wb_stage_unit : wb_stage
    port map (
      clk                 => clk,
      reset               => reset,

      mem_wb_register     => mem_wb_register_sig,
      
      dreg_addr           => dreg_addr_sig,
      dreg                => dreg_sig,
      dreg_enable         => dreg_enable_sig,
      
      lr                  => lr_sig,
      lr_enable           => lr_enable_sig,
      
      sr                  => sr_wb_sig,
      sr_enable           => sr_enable_sig,
      
      clear_out           => clear_out_wb_sig,
      
      clear_reg_lock0     => clear_lock0_sig,
      lock_reg_addr0      => clear_lock_addr0_sig,
      clear_reg_lock1     => clear_lock1_sig,
      lock_reg_addr1      => clear_lock_addr1_sig);

  register_file_unit : register_file
    port map (
      clk            => clk,
      reset          => reset,

      rx_addr        => rx_addr_sig,
      ry_addr        => ry_addr_sig,
      rz_addr        => rz_addr_sig,

      rx_read        => rx_sig,
      ry_read        => ry_sig,
      rz_read        => rz_sig,
      
      dreg_addr      => dreg_addr_sig,
      dreg_write     => dreg_sig,
      dreg_enable    => dreg_enable_sig,
      
      sr_read        => sr_id_sig,
      sr_write       => sr_wb_sig,
      sr_enable      => sr_enable_sig,
      
      lr_write       => lr_sig,
      lr_enable      => lr_enable_sig,
      
      pc_write       => pc_next_if_sig,
      pc_read        => pc_if_sig);

  imem_unit : imem
    port map (
      clk            => clk,
      reset          => reset,
      wr_enable      => wr_enable_imem_sig,
      addr           => imem_addr_sig,
      data_in        => data_in_imem_sig,
      data_out       => imem_data_sig);
  
  dmem_unit : dmem
    port map (
      clk            => clk,
      reset          => reset,
      wr_enable      => wr_enable_dmem_sig,
      addr           => dmem_addr_sig,
      data_in        => dmem_data_out_sig,
      data_out       => dmem_data_in_sig,
		uart_txd 		=> dmem_txd_sig,
		uart_rxd 		=> dmem_rxd_sig);
  
  rlu_unit : rlu port map(
    clk                 => clk,
    reset               => reset,
    clear_locks         => clear_locks_sig,
    
    lock_register       => lock_register_sig,

    set_lock0           => set_lock0_sig,
    set_lock_addr0      => set_lock_addr0_sig,

    set_lock1           => set_lock1_sig,
    set_lock_addr1      => set_lock_addr1_sig,

    clear_lock0         => clear_lock0_sig,
    clear_lock_addr0    => clear_lock_addr0_sig,

    clear_lock1         => clear_lock1_sig,
    clear_lock_addr1    => clear_lock_addr1_sig);

  
  clear_in_if_sig       <= clear_out_ex_sig or clear_out_mem_sig or clear_out_wb_sig;
  clear_in_id_sig       <= clear_in_if_sig;
  clear_in_ex_sig       <= clear_out_mem_sig or clear_out_wb_sig;
  clear_in_mem_sig      <= clear_out_wb_sig;
  
  stall_in_if_sig       <= stall_out_id_sig or stall_out_mem_sig;
  stall_in_id_sig       <= stall_out_mem_sig;
  stall_in_ex_sig       <= stall_out_mem_sig;

  branch_target_sig     <= ex_mem_register_sig.alu;

  data_in_imem_sig      <= (others => '-');  -- unused at the moment
  wr_enable_imem_sig    <= '-';  -- unused at the moment
  
  --  ports of top level entity
  tx 					<= dmem_txd_sig;
  dmem_rxd_sig		<= rx;
  
end rise_rtl;
