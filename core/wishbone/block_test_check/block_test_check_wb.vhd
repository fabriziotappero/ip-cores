----------------------------------------------------------------------------------
-- Company:         ;)
-- Engineer:        Kuzmi4
-- 
-- Create Date:     17:40:25 05/21/2010 
-- Design Name:     
-- Module Name:     block_test_check_wb - rtl 
-- Project Name:    DS_DMA
-- Target Devices:  any
-- Tool versions:   any
-- Description:     
--                  
--                  Top-level module for TEST_CHECK_WB functionality
--                  (NB!!! --> module contain syb-modules with restrictions)
--
-- Revision: 
-- Revision 0.01 - File Created 
-- Revision 0.02 - update BLOCK_ID/BLOCK_VER logic - now it's inner ID of component
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package block_test_check_wb_pkg is

component block_test_check_wb is
port 
( 
    --
    -- SYS_CON
    i_clk : in  STD_LOGIC;
    i_rst : in  STD_LOGIC;
    --
    -- WB CFG SLAVE IF
    iv_wbs_cfg_addr     :   in  std_logic_vector(  7 downto 0 );
    iv_wbs_cfg_data     :   in  std_logic_vector( 63 downto 0 );
    iv_wbs_cfg_sel      :   in  std_logic_vector(  7 downto 0 );
    i_wbs_cfg_we        :   in  std_logic;
    i_wbs_cfg_cyc       :   in  std_logic;
    i_wbs_cfg_stb       :   in  std_logic;
    iv_wbs_cfg_cti      :   in  std_logic_vector(  2 downto 0 );
    iv_wbs_cfg_bte      :   in  std_logic_vector(  1 downto 0 );
    
    ov_wbs_cfg_data     :   out std_logic_vector( 63 downto 0 );
    o_wbs_cfg_ack       :   out std_logic;
    o_wbs_cfg_err       :   out std_logic;
    o_wbs_cfg_rty       :   out std_logic;
    --
    -- WB BURST SLAVE IF (WRITE-ONLY IF)
    iv_wbs_burst_addr   :   in  std_logic_vector( 11 downto 0 );
    iv_wbs_burst_data   :   in  std_logic_vector( 63 downto 0 );
    iv_wbs_burst_sel    :   in  std_logic_vector(  7 downto 0 );
    i_wbs_burst_we      :   in  std_logic;
    i_wbs_burst_cyc     :   in  std_logic;
    i_wbs_burst_stb     :   in  std_logic;
    iv_wbs_burst_cti    :   in  std_logic_vector(  2 downto 0 );
    iv_wbs_burst_bte    :   in  std_logic_vector(  1 downto 0 );
    
    o_wbs_burst_ack     :   out std_logic;
    o_wbs_burst_err     :   out std_logic;
    o_wbs_burst_rty     :   out std_logic;
    --
    -- WB IRQ lines
    o_wbs_irq_0         :   out std_logic;
    o_wbs_irq_dmar      :   out std_logic
);
end component block_test_check_wb;

end package block_test_check_wb_pkg;
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library work;
use work.cl_test_check_pkg.all;
use work.block_check_wb_config_slave_pkg.all;
use work.block_check_wb_pkg.all;


entity block_test_check_wb is
port 
( 
    --
    -- SYS_CON
    i_clk : in  STD_LOGIC;
    i_rst : in  STD_LOGIC;
    --
    -- WB CFG SLAVE IF
    iv_wbs_cfg_addr     :   in  std_logic_vector(  7 downto 0 );
    iv_wbs_cfg_data     :   in  std_logic_vector( 63 downto 0 );
    iv_wbs_cfg_sel      :   in  std_logic_vector(  7 downto 0 );
    i_wbs_cfg_we        :   in  std_logic;
    i_wbs_cfg_cyc       :   in  std_logic;
    i_wbs_cfg_stb       :   in  std_logic;
    iv_wbs_cfg_cti      :   in  std_logic_vector(  2 downto 0 );
    iv_wbs_cfg_bte      :   in  std_logic_vector(  1 downto 0 );
    
    ov_wbs_cfg_data     :   out std_logic_vector( 63 downto 0 );
    o_wbs_cfg_ack       :   out std_logic;
    o_wbs_cfg_err       :   out std_logic;
    o_wbs_cfg_rty       :   out std_logic;
    --
    -- WB BURST SLAVE IF (WRITE-ONLY IF)
    iv_wbs_burst_addr   :   in  std_logic_vector( 11 downto 0 );
    iv_wbs_burst_data   :   in  std_logic_vector( 63 downto 0 );
    iv_wbs_burst_sel    :   in  std_logic_vector(  7 downto 0 );
    i_wbs_burst_we      :   in  std_logic;
    i_wbs_burst_cyc     :   in  std_logic;
    i_wbs_burst_stb     :   in  std_logic;
    iv_wbs_burst_cti    :   in  std_logic_vector(  2 downto 0 );
    iv_wbs_burst_bte    :   in  std_logic_vector(  1 downto 0 );
    
    o_wbs_burst_ack     :   out std_logic;
    o_wbs_burst_err     :   out std_logic;
    o_wbs_burst_rty     :   out std_logic;
    --
    -- WB IRQ lines
    o_wbs_irq_0         :   out std_logic;
    o_wbs_irq_dmar      :   out std_logic
);
end block_test_check_wb;

architecture rtl of block_test_check_wb is
----------------------------------------------------------------------------------
--
-- Define TEST_CHECK CTRL/STS stuff:
signal  sv_test_check_ctrl      :   std_logic_vector( 15 downto 0 );
signal  sv_test_check_size      :   std_logic_vector( 15 downto 0 );
signal  sv_test_check_bl_rd     :   std_logic_vector( 31 downto 0 );
signal  sv_test_check_bl_ok     :   std_logic_vector( 31 downto 0 );
signal  sv_test_check_bl_err    :   std_logic_vector( 31 downto 0 );
signal  sv_test_check_error     :   std_logic_vector( 31 downto 0 );
signal  sv_test_check_err_adr   :   std_logic_vector( 15 downto 0 );
signal  sv_test_check_err_data  :   std_logic_vector( 15 downto 0 );

signal  sv_wb_burst_control     :   std_logic_vector( 15 downto 0 );
-- Define TEST_CHECK Data-In stuff:
signal  sv_test_check_data      :   std_logic_vector( 63 downto 0 );
signal  s_test_check_data_ena   :   std_logic;
-- Define TEST_CHECK RST_n stuff:
signal  s_test_check_rst_n      :   std_logic;

----------------------------------------------------------------------------------
begin
----------------------------------------------------------------------------------
--
-- Instaniate WB_CFG_SLAVE
--
WB_CFG_SLAVE    :   block_check_wb_config_slave
generic map
(
    BLOCK_ID   => x"001A", -- идентификатор модуля
    BLOCK_VER  => x"0100"  -- версия модуля
)
port map
( 
    --
    -- SYS_CON
    i_clk => i_clk,
    i_rst => i_rst,
    --
    -- WB CFG SLAVE IF
    iv_wbs_cfg_addr     => iv_wbs_cfg_addr,
    iv_wbs_cfg_data     => iv_wbs_cfg_data,
    iv_wbs_cfg_sel      => iv_wbs_cfg_sel,
    i_wbs_cfg_we        => i_wbs_cfg_we,
    i_wbs_cfg_cyc       => i_wbs_cfg_cyc,
    i_wbs_cfg_stb       => i_wbs_cfg_stb,
    iv_wbs_cfg_cti      => iv_wbs_cfg_cti,
    iv_wbs_cfg_bte      => iv_wbs_cfg_bte,
    
    ov_wbs_cfg_data     => ov_wbs_cfg_data,
    o_wbs_cfg_ack       => o_wbs_cfg_ack,
    o_wbs_cfg_err       => o_wbs_cfg_err,
    o_wbs_cfg_rty       => o_wbs_cfg_rty,
    --
    -- CONTROL Outputs
    ov_test_check_ctrl      => sv_test_check_ctrl,
    ov_test_check_size      => sv_test_check_size,
    ov_test_check_err_adr   => sv_test_check_err_adr,
    ov_wb_burst_control     => sv_wb_burst_control,
    --
    -- STATUS Input
    iv_test_check_bl_rd     => sv_test_check_bl_rd,
    iv_test_check_bl_ok     => sv_test_check_bl_ok,
    iv_test_check_bl_err    => sv_test_check_bl_err,
    iv_test_check_error     => sv_test_check_error,
    iv_test_check_err_data  => sv_test_check_err_data
);
----------------------------------------------------------------------------------
--
-- Instaniate TEST_CHECK
--
TEST_CHECK  :   cl_test_check
port map
(
        ---- Global ----
        reset       => s_test_check_rst_n,      -- 0 - сброс
        clk         => i_clk,                   -- тактовая частота
        
        ---- DIO_OUT ----
        do_clk      => i_clk,                   -- тактовая частота чтения из FIFO
        do_data     => sv_test_check_data, 
        do_data_en  => s_test_check_data_ena,   -- 1 - передача данных из dio_out
        
        ---- Управление ----
        test_check_ctrl     => sv_test_check_ctrl,      
        test_check_size     => sv_test_check_size,      -- размер в блоках по 512x64 (4096 байт)
        test_check_bl_rd    => sv_test_check_bl_rd,     
        test_check_bl_ok    => sv_test_check_bl_ok,     
        test_check_bl_err   => sv_test_check_bl_err,    
        test_check_error    => sv_test_check_error,     
        test_check_err_adr  => sv_test_check_err_adr,   
        test_check_err_data => sv_test_check_err_data   
);
----------------------------------------------------------------------------------
--
-- Instaniate WB_BURST_SLAVE (provide Input-Only Functionality)
--
WB_BURST_SLAVE  :   block_check_wb_burst_slave
port map
(
    --
    -- SYS_CON
    i_clk => i_clk,
    i_rst => i_rst,
    --
    -- WB BURST SLAVE IF (READ-ONLY IF)
    iv_wbs_burst_addr   => iv_wbs_burst_addr,
    iv_wbs_burst_data   => iv_wbs_burst_data,
    iv_wbs_burst_sel    => iv_wbs_burst_sel,
    i_wbs_burst_we      => i_wbs_burst_we,
    i_wbs_burst_cyc     => i_wbs_burst_cyc,
    i_wbs_burst_stb     => i_wbs_burst_stb,
    iv_wbs_burst_cti    => iv_wbs_burst_cti,
    iv_wbs_burst_bte    => iv_wbs_burst_bte,
    
    o_wbs_burst_ack     => o_wbs_burst_ack,
    o_wbs_burst_err     => o_wbs_burst_err,
    o_wbs_burst_rty     => o_wbs_burst_rty,
    --
    -- TEST_CHECK IF (Output data with ENA)
    ov_test_check_data      => sv_test_check_data,
    o_test_check_data_ena   => s_test_check_data_ena,
    --
    -- TEST_CHECK Controls (WBS_CFG)
    iv_control          => sv_wb_burst_control
    
);
----------------------------------------------------------------------------------
--
-- MODULE INNER wires routing:
--
-- define 

-- define TEST_CHECK.reset - it is RST_n signal 
s_test_check_rst_n  <= not i_rst;
----------------------------------------------------------------------------------
--
-- MODULE OUTPUTs routing:
--
-- DMAR WB IRQ deal
o_wbs_irq_dmar  <= sv_test_check_ctrl(5); -- TEST_CHECK_CTRL.START -> 1 - разрешение работы
-- WB IRQ deal
o_wbs_irq_0     <= '0'; -- No EVENTs for now
----------------------------------------------------------------------------------
end rtl;

