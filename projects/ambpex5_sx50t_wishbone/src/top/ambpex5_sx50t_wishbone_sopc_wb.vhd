-------------------------------------------------------------------------------
--
-- Title       : pcie_core64_m1
-- Author      : Dmitry Smekhov
-- Company     : Instrumental Systems 
-- E-mail      : dsmv@insys.ru
--
-- Version     : 1.0
--
-------------------------------------------------------------------------------
--
-- Description :  Top-level module for PCIE_CORE64 WB SoPC
--                (System have 32Bit ADDR BUS and 64bit DATA BUS)
--
--                  Memory Map for SoPC (based on WB_CROSS setup):
--                      1) TEST_CHECK.WB_CFG_SLAVE:
--                          ADDR Range ==> 0x0000_0000 : 0x0000_0FFF ( Valid 1st 256B only, detailed MM at test_check_wb_config_slave.vhd)
--                      
--                      2) TEST_CHECK.WB_BURST_SLAVE
--                          ADDR Range ==> 0x0000_1000 : 0x0000_1FFF (support only Constant-Addr-Burst for 512x64bit cell (full 4KB range), Input ONLY)
--                      
--                      3) TEST_GEN.WB_CFG_SLAVE
--                          ADDR Range ==> 0x0000_2000 : 0x0000_2FFF ( Valid 1st 256B only, detailed MM at test_generate_wb_config_slave.vhd)
--                      
--                      4) TEST_GEN.WB_BURST_SLAVE
--                          ADDR Range ==> 0x0000_3000 : 0x0000_3FFF (support only Constant-Addr-Burst for 512x64bit cell (full 4KB range), Output ONLY)
--
-------------------------------------------------------------------------------
--
--	Version 1.0   20.04.2013
--				 Created from sp605_lx45t_wishbone_sopc_wb 
--
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

package ambpex5_sx50t_wishbone_sopc_wb_pkg is

component ambpex5_sx50t_wishbone_sopc_wb is
generic 
(
    
    is_simulation   :   integer     --! 0 - synthesis, 1 - simulation                            
);
port
(

		---- PCI-Express ----
		txp					: out std_logic_vector( 7 downto 0 );
		txn					: out std_logic_vector( 7 downto 0 );
		
		rxp					: in  std_logic_vector( 7 downto 0 ):=(others=>'0');
		rxn					: in  std_logic_vector( 7 downto 0 ):=(others=>'0');
		
		mgt250				: in  std_logic:='0';   -- reference clock 250 MHz from PCI_Express
		
		perst				: in  std_logic:='0';	-- 0 - reset
		
		tp					: out std_logic_vector(3 downto 1);	   -- testpoint
		
		---- Led ----
		led					: out std_logic_vector( 4 downto 1 )
    
);
end component ambpex5_sx50t_wishbone_sopc_wb;

end package ambpex5_sx50t_wishbone_sopc_wb_pkg;
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library work;
use work.wb_conmax_top_pkg.all;
use work.pcie_core64_wishbone_m8_pkg.all;
use work.block_test_check_wb_pkg.all;
use work.block_test_generate_wb_pkg.all;


entity ambpex5_sx50t_wishbone_sopc_wb is
generic 
(
    
    is_simulation   :   integer     --! 0 - synthesis, 1 - simulation                            
);
port
(

		---- PCI-Express ----
		txp					: out std_logic_vector( 7 downto 0 );
		txn					: out std_logic_vector( 7 downto 0 );
		
		rxp					: in  std_logic_vector( 7 downto 0 ):=(others=>'0');
		rxn					: in  std_logic_vector( 7 downto 0 ):=(others=>'0');
		
		mgt250				: in  std_logic:='0';   -- reference clock 250 MHz from PCI_Express
		
		perst				: in  std_logic:='0';	-- 0 - reset
		
		tp					: out std_logic_vector(3 downto 1);	   -- testpoint
		
		---- Led ----
		led					: out std_logic_vector( 4 downto 1 )
    
);
end ambpex5_sx50t_wishbone_sopc_wb;

architecture rtl of ambpex5_sx50t_wishbone_sopc_wb is
----------------------------------------------------------------------------------
--
-- Declare PCIE_CORE64_WB stuff:
signal  sv_control_points   :   std_logic_vector( 7 downto 0 );
signal  sv_pcie_lstatus     :   std_logic_vector( 15 downto 0 );
signal  s_pcie_link_up_n    :   std_logic;
-------------------------------------------------------------------------------
--
-- Declare WB_CROSS stuff:
signal  st_master_port_data_in  :   wb_master_port_data;
signal  st_master_port_data_out :   wb_master_port_data;
signal  st_master_port_addr     :   wb_master_port_addr;
signal  st_master_port_sel      :   wb_master_port_sel;
signal  st_master_port_we       :   wb_master_port_we;
signal  st_master_port_cyc      :   wb_master_port_cyc;
signal  st_master_port_stb      :   wb_master_port_stb;
signal  st_master_port_ack      :   wb_master_port_ack;
signal  st_master_port_err      :   wb_master_port_err;
signal  st_master_port_rty      :   wb_master_port_rty;
signal  st_master_port_cti      :   wb_master_port_cti;
signal  st_master_port_bte      :   wb_master_port_bte;

signal  st_slave_port_data_in   :   wb_slave_port_data;
signal  st_slave_port_data_out  :   wb_slave_port_data;
signal  st_slave_port_addr      :   wb_slave_port_addr;
signal  st_slave_port_sel       :   wb_slave_port_sel;
signal  st_slave_port_we        :   wb_slave_port_we;
signal  st_slave_port_cyc       :   wb_slave_port_cyc;
signal  st_slave_port_stb       :   wb_slave_port_stb;
signal  st_slave_port_ack       :   wb_slave_port_ack;
signal  st_slave_port_err       :   wb_slave_port_err;
signal  st_slave_port_rty       :   wb_slave_port_rty;
signal  st_slave_port_cti       :   wb_slave_port_cti;
signal  st_slave_port_bte       :   wb_slave_port_bte;
-------------------------------------------------------------------------------
--
-- Declare Module Output Req stuff:
signal  sv_pcie_line_num        :   std_logic_vector(2 downto 0);
-------------------------------------------------------------------------------
--
-- Declare WB stuff 
--  SYS_CON
signal  s_wb_clk                :   std_logic;
signal  s_wb_rst                :   std_logic;
--  PCIE_CORE64 wb 
signal  sv_wbm_addr_pcie_core64_wb      :   std_logic_vector(p_WB_CROSS_ADDR_W-1 downto 0);
signal  sv_wbm_data_out_pcie_core64_wb  :   std_logic_vector(p_WB_CROSS_DATA_W-1 downto 0);
signal  sv_wbm_sel_pcie_core64_wb       :   std_logic_vector(p_WB_CROSS_DATA_W/8-1 downto 0);
signal  s_wbm_we_pcie_core64_wb         :   std_logic;
signal  s_wbm_cyc_pcie_core64_wb        :   std_logic;
signal  s_wbm_stb_pcie_core64_wb        :   std_logic;
signal  sv_wbm_cti_pcie_core64_wb       :   std_logic_vector(2 downto 0);
signal  sv_wbm_bte_pcie_core64_wb       :   std_logic_vector(1 downto 0);
signal  sv_wbm_data_in_pcie_core64_wb   :   std_logic_vector(p_WB_CROSS_DATA_W-1 downto 0);
signal  s_wbm_ack_pcie_core64_wb        :   std_logic;
signal  s_wbm_err_pcie_core64_wb        :   std_logic;
signal  s_wbm_rty_pcie_core64_wb        :   std_logic;
signal  sv_wbm_dmar_irq_pcie_core64_wb  :   std_logic_vector(1 downto 0);
--  TEST_CHECK.WB_CFG_SLAVE
signal  sv_wbs_cfg_addr_test_check      :   std_logic_vector(p_WB_CROSS_ADDR_W-1 downto 0);
signal  sv_wbs_cfg_data_in_test_check   :   std_logic_vector(p_WB_CROSS_DATA_W-1 downto 0);
signal  sv_wbs_cfg_sel_test_check       :   std_logic_vector(p_WB_CROSS_DATA_W/8-1 downto 0);
signal  s_wbs_cfg_we_test_check         :   std_logic;
signal  s_wbs_cfg_cyc_test_check        :   std_logic;
signal  s_wbs_cfg_stb_test_check        :   std_logic;
signal  sv_wbs_cfg_cti_test_check       :   std_logic_vector(2 downto 0);
signal  sv_wbs_cfg_bte_test_check       :   std_logic_vector(1 downto 0);
signal  sv_wbs_cfg_data_out_test_check  :   std_logic_vector(p_WB_CROSS_DATA_W-1 downto 0);
signal  s_wbs_cfg_ack_test_check        :   std_logic;
signal  s_wbs_cfg_err_test_check        :   std_logic;
signal  s_wbs_cfg_rty_test_check        :   std_logic;
signal  s_wbs_irq_dmar_test_check       :   std_logic;  -- TEST_CHECK WB DMAR IRQ
--  TEST_CHECK.WB_BURST_SLAVE
signal  sv_wbs_burst_addr_test_check    :   std_logic_vector(p_WB_CROSS_ADDR_W-1 downto 0);
signal  sv_wbs_burst_data_in_test_check :   std_logic_vector(p_WB_CROSS_DATA_W-1 downto 0);
signal  sv_wbs_burst_sel_test_check     :   std_logic_vector(p_WB_CROSS_DATA_W/8-1 downto 0);
signal  s_wbs_burst_we_test_check       :   std_logic;
signal  s_wbs_burst_cyc_test_check      :   std_logic;
signal  s_wbs_burst_stb_test_check      :   std_logic;
signal  sv_wbs_burst_cti_test_check     :   std_logic_vector(2 downto 0);
signal  sv_wbs_burst_bte_test_check     :   std_logic_vector(1 downto 0);
signal  s_wbs_burst_ack_test_check      :   std_logic;
signal  s_wbs_burst_err_test_check      :   std_logic;
signal  s_wbs_burst_rty_test_check      :   std_logic;
--  TEST_GEN.WB_CFG_SLAVE
signal  sv_wbs_cfg_addr_test_gen        :   std_logic_vector(p_WB_CROSS_ADDR_W-1 downto 0);
signal  sv_wbs_cfg_data_in_test_gen     :   std_logic_vector(p_WB_CROSS_DATA_W-1 downto 0);
signal  sv_wbs_cfg_sel_test_gen         :   std_logic_vector(p_WB_CROSS_DATA_W/8-1 downto 0);
signal  s_wbs_cfg_we_test_gen           :   std_logic;
signal  s_wbs_cfg_cyc_test_gen          :   std_logic;
signal  s_wbs_cfg_stb_test_gen          :   std_logic;
signal  sv_wbs_cfg_cti_test_gen         :   std_logic_vector(2 downto 0);
signal  sv_wbs_cfg_bte_test_gen         :   std_logic_vector(1 downto 0);
signal  sv_wbs_cfg_data_out_test_gen    :   std_logic_vector(p_WB_CROSS_DATA_W-1 downto 0);
signal  s_wbs_cfg_ack_test_gen          :   std_logic;
signal  s_wbs_cfg_err_test_gen          :   std_logic;
signal  s_wbs_cfg_rty_test_gen          :   std_logic;
signal  s_wbs_irq_dmar_test_gen         :   std_logic;  -- TEST_GEN WB DMAR IRQ
--  TEST_GEN.WB_BURST_SLAVE
signal  sv_wbs_burst_addr_test_gen      :   std_logic_vector(p_WB_CROSS_ADDR_W-1 downto 0);
signal  sv_wbs_burst_data_out_test_gen  :   std_logic_vector(p_WB_CROSS_DATA_W-1 downto 0);
signal  sv_wbs_burst_sel_test_gen       :   std_logic_vector(p_WB_CROSS_DATA_W/8-1 downto 0);
signal  s_wbs_burst_we_test_gen         :   std_logic;
signal  s_wbs_burst_cyc_test_gen        :   std_logic;
signal  s_wbs_burst_stb_test_gen        :   std_logic;
signal  sv_wbs_burst_cti_test_gen       :   std_logic_vector(2 downto 0);
signal  sv_wbs_burst_bte_test_gen       :   std_logic_vector(1 downto 0);
signal  s_wbs_burst_ack_test_gen        :   std_logic;
signal  s_wbs_burst_err_test_gen        :   std_logic;
signal  s_wbs_burst_rty_test_gen        :   std_logic;
----------------------------------------------------------------------------------
begin
-------------------------------------------------------------------------------
-- 
-- Instantiate PCIE_CORE64_WB module (provide main PCIE finctionality):
-- 
PCIE_CORE64_WB  :   pcie_core64_wishbone_m8
generic map
(
    Device_ID       => x"0000",         -- идентификатор модуля
    Revision        => x"0000",         -- версия модуля
    PLD_VER         => x"0001",         -- версия ПЛИС
    
    is_simulation   => is_simulation    --! 0 - синтез, 1 - моделирование 
)
port map
(
    ---- PCI-Express ----
    txp             => txp,
    txn             => txn,
    
    rxp             => rxp,
    rxn             => rxn,
    
    mgt250          => mgt250,       -- тактовая частота 125 MHz от PCI_Express
    
    perst           => perst,       -- 0 - сброс 
    
    --px              => px,  		--! контрольные точки 
    
    pcie_lstatus    => sv_pcie_lstatus,     -- регистр LSTATUS
    pcie_link_up    => s_pcie_link_up_n,    -- 0 - завершена инициализация PCI-Express
    
    ---- Wishbone SYS_CON -----
    o_wb_clk        => s_wb_clk,                        
    o_wb_rst        => s_wb_rst,                        
    ---- Wishbone BUS -----
    ov_wbm_addr     => sv_wbm_addr_pcie_core64_wb,      
    ov_wbm_data     => sv_wbm_data_out_pcie_core64_wb,  
    ov_wbm_sel      => sv_wbm_sel_pcie_core64_wb,       
    o_wbm_we        => s_wbm_we_pcie_core64_wb,         
    o_wbm_cyc       => s_wbm_cyc_pcie_core64_wb,        
    o_wbm_stb       => s_wbm_stb_pcie_core64_wb,        
    ov_wbm_cti      => sv_wbm_cti_pcie_core64_wb,       -- Cycle Type Identifier Address Tag
    ov_wbm_bte      => sv_wbm_bte_pcie_core64_wb,       -- Burst Type Extension Address Tag
    
    iv_wbm_data     => sv_wbm_data_in_pcie_core64_wb,   
    i_wbm_ack       => s_wbm_ack_pcie_core64_wb,        
    i_wbm_err       => s_wbm_err_pcie_core64_wb,        -- error input - abnormal cycle termination
    i_wbm_rty       => s_wbm_rty_pcie_core64_wb,        -- retry input - interface is not ready
    
    i_wdm_irq_0     => '0',                             -- NC for now
    iv_wbm_irq_dmar =>  sv_wbm_dmar_irq_pcie_core64_wb  -- 
    
);
--  Construct DMAR WB IR Input:
sv_wbm_dmar_irq_pcie_core64_wb <= s_wbs_irq_dmar_test_gen & s_wbs_irq_dmar_test_check; -- Bit#1 - TEST_GEN, Bit#0 - TEST_CHECK
-------------------------------------------------------------------------------
--
-- Instantiate TEST_CHECK (provide check of input data):
--
TEST_CHECK  :   block_test_check_wb
port map
( 
    --
    -- SYS_CON
    i_clk => s_wb_clk,
    i_rst => s_wb_rst,
    --
    -- WB CFG SLAVE IF
    iv_wbs_cfg_addr     => sv_wbs_cfg_addr_test_check( 7 downto 0), -- Route only req addr wires: 256B ADDR Range
    iv_wbs_cfg_data     => sv_wbs_cfg_data_in_test_check,
    iv_wbs_cfg_sel      => sv_wbs_cfg_sel_test_check,
    i_wbs_cfg_we        => s_wbs_cfg_we_test_check,
    i_wbs_cfg_cyc       => s_wbs_cfg_cyc_test_check,
    i_wbs_cfg_stb       => s_wbs_cfg_stb_test_check,
    iv_wbs_cfg_cti      => sv_wbs_cfg_cti_test_check,
    iv_wbs_cfg_bte      => sv_wbs_cfg_bte_test_check,
    
    ov_wbs_cfg_data     => sv_wbs_cfg_data_out_test_check,
    o_wbs_cfg_ack       => s_wbs_cfg_ack_test_check,
    o_wbs_cfg_err       => s_wbs_cfg_err_test_check,
    o_wbs_cfg_rty       => s_wbs_cfg_rty_test_check,
    --
    -- WB BURST SLAVE IF (WRITE-ONLY IF)
    iv_wbs_burst_addr   => sv_wbs_burst_addr_test_check( 11 downto 0),  -- Route only req addr wires: 4KB ADDR Range
    iv_wbs_burst_data   => sv_wbs_burst_data_in_test_check,
    iv_wbs_burst_sel    => sv_wbs_burst_sel_test_check,
    i_wbs_burst_we      => s_wbs_burst_we_test_check,
    i_wbs_burst_cyc     => s_wbs_burst_cyc_test_check,
    i_wbs_burst_stb     => s_wbs_burst_stb_test_check,
    iv_wbs_burst_cti    => sv_wbs_burst_cti_test_check,
    iv_wbs_burst_bte    => sv_wbs_burst_bte_test_check,
    
    o_wbs_burst_ack     => s_wbs_burst_ack_test_check,
    o_wbs_burst_err     => s_wbs_burst_err_test_check,
    o_wbs_burst_rty     => s_wbs_burst_rty_test_check,
    --
    -- WB IRQ lines
    o_wbs_irq_0         => OPEN,                        -- NC for now
    o_wbs_irq_dmar      => s_wbs_irq_dmar_test_check    -- 
);
-------------------------------------------------------------------------------
--
-- Instantiate TEST_GEN (provide generation of test data):
--
TEST_GEN    :   block_test_generate_wb
port map
( 
    --
    -- SYS_CON
    i_clk => s_wb_clk,
    i_rst => s_wb_rst,
    --
    -- WB CFG SLAVE IF
    iv_wbs_cfg_addr     => sv_wbs_cfg_addr_test_gen( 7 downto 0), -- Route only req addr wires: 256B ADDR Range
    iv_wbs_cfg_data     => sv_wbs_cfg_data_in_test_gen,
    iv_wbs_cfg_sel      => sv_wbs_cfg_sel_test_gen,
    i_wbs_cfg_we        => s_wbs_cfg_we_test_gen,
    i_wbs_cfg_cyc       => s_wbs_cfg_cyc_test_gen,
    i_wbs_cfg_stb       => s_wbs_cfg_stb_test_gen,
    iv_wbs_cfg_cti      => sv_wbs_cfg_cti_test_gen,
    iv_wbs_cfg_bte      => sv_wbs_cfg_bte_test_gen,
    
    ov_wbs_cfg_data     => sv_wbs_cfg_data_out_test_gen,
    o_wbs_cfg_ack       => s_wbs_cfg_ack_test_gen,
    o_wbs_cfg_err       => s_wbs_cfg_err_test_gen,
    o_wbs_cfg_rty       => s_wbs_cfg_rty_test_gen,
    --
    -- WB BURST SLAVE IF (READ-ONLY IF)
    iv_wbs_burst_addr   => sv_wbs_burst_addr_test_gen( 11 downto 0),  -- Route only req addr wires: 4KB ADDR Range
    iv_wbs_burst_sel    => sv_wbs_burst_sel_test_gen,
    i_wbs_burst_we      => s_wbs_burst_we_test_gen,
    i_wbs_burst_cyc     => s_wbs_burst_cyc_test_gen,
    i_wbs_burst_stb     => s_wbs_burst_stb_test_gen,
    iv_wbs_burst_cti    => sv_wbs_burst_cti_test_gen,
    iv_wbs_burst_bte    => sv_wbs_burst_bte_test_gen,
    
    ov_wbs_burst_data   => sv_wbs_burst_data_out_test_gen,
    o_wbs_burst_ack     => s_wbs_burst_ack_test_gen,
    o_wbs_burst_err     => s_wbs_burst_err_test_gen,
    o_wbs_burst_rty     => s_wbs_burst_rty_test_gen,
    --
    -- WB IRQ lines
    o_wbs_irq_0         => OPEN,                    -- NC for now
    o_wbs_irq_dmar      => s_wbs_irq_dmar_test_gen  -- 
);
-------------------------------------------------------------------------------
--
-- Instantiate WB_CROSS
--  ==> MOST HEAVY PART of DESIGN (from port-quantity point of view)
--
WB_CROSS    :   wb_conmax_top
generic map
(
    dw  =>  p_WB_CROSS_DATA_W, -- WB_DATA_WIDTH==64bit (defined at wb_conmax_top_pkg.vhd)
    aw  =>  p_WB_CROSS_ADDR_W  -- WB_ADDR_WIDTH==32bit (defined at wb_conmax_top_pkg.vhd)
)
port map
( 
    --
    -- SYS_CON
    clk_i => s_wb_clk,
    rst_i => s_wb_rst,
    --
    -- Master 0 Interface
    m0_data_i   => st_master_port_data_in(0),
    m0_data_o   => st_master_port_data_out(0),
    m0_addr_i   => st_master_port_addr(0),
    m0_sel_i    => st_master_port_sel(0),
    m0_we_i     => st_master_port_we(0),
    m0_cyc_i    => st_master_port_cyc(0),
    m0_stb_i    => st_master_port_stb(0),
    m0_ack_o    => st_master_port_ack(0),
    m0_err_o    => st_master_port_err(0),
    m0_rty_o    => st_master_port_rty(0),
    m0_cti_i    => st_master_port_cti(0),
    m0_bte_i    => st_master_port_bte(0),
    --
    -- Master 1 Interface
    m1_data_i   => st_master_port_data_in(1),
    m1_data_o   => st_master_port_data_out(1),
    m1_addr_i   => st_master_port_addr(1),
    m1_sel_i    => st_master_port_sel(1),
    m1_we_i     => st_master_port_we(1),
    m1_cyc_i    => st_master_port_cyc(1),
    m1_stb_i    => st_master_port_stb(1),
    m1_ack_o    => st_master_port_ack(1),
    m1_err_o    => st_master_port_err(1),
    m1_rty_o    => st_master_port_rty(1),
    m1_cti_i    => st_master_port_cti(1),
    m1_bte_i    => st_master_port_bte(1),
    --
    -- Master 2 Interface
    m2_data_i   => st_master_port_data_in(2),
    m2_data_o   => st_master_port_data_out(2),
    m2_addr_i   => st_master_port_addr(2),
    m2_sel_i    => st_master_port_sel(2),
    m2_we_i     => st_master_port_we(2),
    m2_cyc_i    => st_master_port_cyc(2),
    m2_stb_i    => st_master_port_stb(2),
    m2_ack_o    => st_master_port_ack(2),
    m2_err_o    => st_master_port_err(2),
    m2_rty_o    => st_master_port_rty(2),
    m2_cti_i    => st_master_port_cti(2),
    m2_bte_i    => st_master_port_bte(2),
    --
    -- Master 3 Interface
    m3_data_i   => st_master_port_data_in(3),
    m3_data_o   => st_master_port_data_out(3),
    m3_addr_i   => st_master_port_addr(3),
    m3_sel_i    => st_master_port_sel(3),
    m3_we_i     => st_master_port_we(3),
    m3_cyc_i    => st_master_port_cyc(3),
    m3_stb_i    => st_master_port_stb(3),
    m3_ack_o    => st_master_port_ack(3),
    m3_err_o    => st_master_port_err(3),
    m3_rty_o    => st_master_port_rty(3),
    m3_cti_i    => st_master_port_cti(3),
    m3_bte_i    => st_master_port_bte(3),
    --
    -- Master 4 Interface
    m4_data_i   => st_master_port_data_in(4),
    m4_data_o   => st_master_port_data_out(4),
    m4_addr_i   => st_master_port_addr(4),
    m4_sel_i    => st_master_port_sel(4),
    m4_we_i     => st_master_port_we(4),
    m4_cyc_i    => st_master_port_cyc(4),
    m4_stb_i    => st_master_port_stb(4),
    m4_ack_o    => st_master_port_ack(4),
    m4_err_o    => st_master_port_err(4),
    m4_rty_o    => st_master_port_rty(4),
    m4_cti_i    => st_master_port_cti(4),
    m4_bte_i    => st_master_port_bte(4),
    --
    -- Master 5 Interface
    m5_data_i   => st_master_port_data_in(5),
    m5_data_o   => st_master_port_data_out(5),
    m5_addr_i   => st_master_port_addr(5),
    m5_sel_i    => st_master_port_sel(5),
    m5_we_i     => st_master_port_we(5),
    m5_cyc_i    => st_master_port_cyc(5),
    m5_stb_i    => st_master_port_stb(5),
    m5_ack_o    => st_master_port_ack(5),
    m5_err_o    => st_master_port_err(5),
    m5_rty_o    => st_master_port_rty(5),
    m5_cti_i    => st_master_port_cti(5),
    m5_bte_i    => st_master_port_bte(5),
    --
    -- Master 6 Interface
    m6_data_i   => st_master_port_data_in(6),
    m6_data_o   => st_master_port_data_out(6),
    m6_addr_i   => st_master_port_addr(6),
    m6_sel_i    => st_master_port_sel(6),
    m6_we_i     => st_master_port_we(6),
    m6_cyc_i    => st_master_port_cyc(6),
    m6_stb_i    => st_master_port_stb(6),
    m6_ack_o    => st_master_port_ack(6),
    m6_err_o    => st_master_port_err(6),
    m6_rty_o    => st_master_port_rty(6),
    m6_cti_i    => st_master_port_cti(6),
    m6_bte_i    => st_master_port_bte(6),
    --
    -- Master 7 Interface
    m7_data_i   => st_master_port_data_in(7),
    m7_data_o   => st_master_port_data_out(7),
    m7_addr_i   => st_master_port_addr(7),
    m7_sel_i    => st_master_port_sel(7),
    m7_we_i     => st_master_port_we(7),
    m7_cyc_i    => st_master_port_cyc(7),
    m7_stb_i    => st_master_port_stb(7),
    m7_ack_o    => st_master_port_ack(7),
    m7_err_o    => st_master_port_err(7),
    m7_rty_o    => st_master_port_rty(7),
    m7_cti_i    => st_master_port_cti(7),
    m7_bte_i    => st_master_port_bte(7),
    --
    --
    -- Slave 0 Interface
    s0_data_i   => st_slave_port_data_in(0),
    s0_data_o   => st_slave_port_data_out(0),
    s0_addr_o   => st_slave_port_addr(0),
    s0_sel_o    => st_slave_port_sel(0),
    s0_we_o     => st_slave_port_we(0),
    s0_cyc_o    => st_slave_port_cyc(0),
    s0_stb_o    => st_slave_port_stb(0),
    s0_ack_i    => st_slave_port_ack(0),
    s0_err_i    => st_slave_port_err(0),
    s0_rty_i    => st_slave_port_rty(0),
    s0_cti_o    => st_slave_port_cti(0),
    s0_bte_o    => st_slave_port_bte(0),
    --
    -- Slave 1 Interface
    s1_data_i   => st_slave_port_data_in(1),
    s1_data_o   => st_slave_port_data_out(1),
    s1_addr_o   => st_slave_port_addr(1),
    s1_sel_o    => st_slave_port_sel(1),
    s1_we_o     => st_slave_port_we(1),
    s1_cyc_o    => st_slave_port_cyc(1),
    s1_stb_o    => st_slave_port_stb(1),
    s1_ack_i    => st_slave_port_ack(1),
    s1_err_i    => st_slave_port_err(1),
    s1_rty_i    => st_slave_port_rty(1),
    s1_cti_o    => st_slave_port_cti(1),
    s1_bte_o    => st_slave_port_bte(1),
    --
    -- Slave 2 Interface
    s2_data_i   => st_slave_port_data_in(2),
    s2_data_o   => st_slave_port_data_out(2),
    s2_addr_o   => st_slave_port_addr(2),
    s2_sel_o    => st_slave_port_sel(2),
    s2_we_o     => st_slave_port_we(2),
    s2_cyc_o    => st_slave_port_cyc(2),
    s2_stb_o    => st_slave_port_stb(2),
    s2_ack_i    => st_slave_port_ack(2),
    s2_err_i    => st_slave_port_err(2),
    s2_rty_i    => st_slave_port_rty(2),
    s2_cti_o    => st_slave_port_cti(2),
    s2_bte_o    => st_slave_port_bte(2),
    --
    -- Slave 3 Interface
    s3_data_i   => st_slave_port_data_in(3),
    s3_data_o   => st_slave_port_data_out(3),
    s3_addr_o   => st_slave_port_addr(3),
    s3_sel_o    => st_slave_port_sel(3),
    s3_we_o     => st_slave_port_we(3),
    s3_cyc_o    => st_slave_port_cyc(3),
    s3_stb_o    => st_slave_port_stb(3),
    s3_ack_i    => st_slave_port_ack(3),
    s3_err_i    => st_slave_port_err(3),
    s3_rty_i    => st_slave_port_rty(3),
    s3_cti_o    => st_slave_port_cti(3),
    s3_bte_o    => st_slave_port_bte(3),
    -- 
    -- Slave 4 Interface
    s4_data_i   => st_slave_port_data_in(4),
    s4_data_o   => st_slave_port_data_out(4),
    s4_addr_o   => st_slave_port_addr(4),
    s4_sel_o    => st_slave_port_sel(4),
    s4_we_o     => st_slave_port_we(4),
    s4_cyc_o    => st_slave_port_cyc(4),
    s4_stb_o    => st_slave_port_stb(4),
    s4_ack_i    => st_slave_port_ack(4),
    s4_err_i    => st_slave_port_err(4),
    s4_rty_i    => st_slave_port_rty(4),
    s4_cti_o    => st_slave_port_cti(4),
    s4_bte_o    => st_slave_port_bte(4),
    -- 
    -- Slave 5 Interface
    s5_data_i   => st_slave_port_data_in(5),
    s5_data_o   => st_slave_port_data_out(5),
    s5_addr_o   => st_slave_port_addr(5),
    s5_sel_o    => st_slave_port_sel(5),
    s5_we_o     => st_slave_port_we(5),
    s5_cyc_o    => st_slave_port_cyc(5),
    s5_stb_o    => st_slave_port_stb(5),
    s5_ack_i    => st_slave_port_ack(5),
    s5_err_i    => st_slave_port_err(5),
    s5_rty_i    => st_slave_port_rty(5),
    s5_cti_o    => st_slave_port_cti(5),
    s5_bte_o    => st_slave_port_bte(5),
    --
    -- Slave 6 Interface
    s6_data_i   => st_slave_port_data_in(6),
    s6_data_o   => st_slave_port_data_out(6),
    s6_addr_o   => st_slave_port_addr(6),
    s6_sel_o    => st_slave_port_sel(6),
    s6_we_o     => st_slave_port_we(6),
    s6_cyc_o    => st_slave_port_cyc(6),
    s6_stb_o    => st_slave_port_stb(6),
    s6_ack_i    => st_slave_port_ack(6),
    s6_err_i    => st_slave_port_err(6),
    s6_rty_i    => st_slave_port_rty(6),
    s6_cti_o    => st_slave_port_cti(6),
    s6_bte_o    => st_slave_port_bte(6),
    --
    -- Slave 7 Interface
    s7_data_i   => st_slave_port_data_in(7),
    s7_data_o   => st_slave_port_data_out(7),
    s7_addr_o   => st_slave_port_addr(7),
    s7_sel_o    => st_slave_port_sel(7),
    s7_we_o     => st_slave_port_we(7),
    s7_cyc_o    => st_slave_port_cyc(7),
    s7_stb_o    => st_slave_port_stb(7),
    s7_ack_i    => st_slave_port_ack(7),
    s7_err_i    => st_slave_port_err(7),
    s7_rty_i    => st_slave_port_rty(7),
    s7_cti_o    => st_slave_port_cti(7),
    s7_bte_o    => st_slave_port_bte(7),
    --
    -- Slave 8 Interface
    s8_data_i   => st_slave_port_data_in(8),
    s8_data_o   => st_slave_port_data_out(8),
    s8_addr_o   => st_slave_port_addr(8),
    s8_sel_o    => st_slave_port_sel(8),
    s8_we_o     => st_slave_port_we(8),
    s8_cyc_o    => st_slave_port_cyc(8),
    s8_stb_o    => st_slave_port_stb(8),
    s8_ack_i    => st_slave_port_ack(8),
    s8_err_i    => st_slave_port_err(8),
    s8_rty_i    => st_slave_port_rty(8),
    s8_cti_o    => st_slave_port_cti(8),
    s8_bte_o    => st_slave_port_bte(8),
    -- 
    -- Slave 9 Interface
    s9_data_i   => st_slave_port_data_in(9),
    s9_data_o   => st_slave_port_data_out(9),
    s9_addr_o   => st_slave_port_addr(9),
    s9_sel_o    => st_slave_port_sel(9),
    s9_we_o     => st_slave_port_we(9),
    s9_cyc_o    => st_slave_port_cyc(9),
    s9_stb_o    => st_slave_port_stb(9),
    s9_ack_i    => st_slave_port_ack(9),
    s9_err_i    => st_slave_port_err(9),
    s9_rty_i    => st_slave_port_rty(9),
    s9_cti_o    => st_slave_port_cti(9),
    s9_bte_o    => st_slave_port_bte(9),
    -- 
    -- Slave 10 Interface
    s10_data_i  => st_slave_port_data_in(10),
    s10_data_o  => st_slave_port_data_out(10),
    s10_addr_o  => st_slave_port_addr(10),
    s10_sel_o   => st_slave_port_sel(10),
    s10_we_o    => st_slave_port_we(10),
    s10_cyc_o   => st_slave_port_cyc(10),
    s10_stb_o   => st_slave_port_stb(10),
    s10_ack_i   => st_slave_port_ack(10),
    s10_err_i   => st_slave_port_err(10),
    s10_rty_i   => st_slave_port_rty(10),
    s10_cti_o   => st_slave_port_cti(10),
    s10_bte_o   => st_slave_port_bte(10),
    -- 
    -- Slave 11 Interface
    s11_data_i  => st_slave_port_data_in(11),
    s11_data_o  => st_slave_port_data_out(11),
    s11_addr_o  => st_slave_port_addr(11),
    s11_sel_o   => st_slave_port_sel(11),
    s11_we_o    => st_slave_port_we(11),
    s11_cyc_o   => st_slave_port_cyc(11),
    s11_stb_o   => st_slave_port_stb(11),
    s11_ack_i   => st_slave_port_ack(11),
    s11_err_i   => st_slave_port_err(11),
    s11_rty_i   => st_slave_port_rty(11),
    s11_cti_o   => st_slave_port_cti(11),
    s11_bte_o   => st_slave_port_bte(11),
    -- 
    -- Slave 12 Interface
    s12_data_i  => st_slave_port_data_in(12),
    s12_data_o  => st_slave_port_data_out(12),
    s12_addr_o  => st_slave_port_addr(12),
    s12_sel_o   => st_slave_port_sel(12),
    s12_we_o    => st_slave_port_we(12),
    s12_cyc_o   => st_slave_port_cyc(12),
    s12_stb_o   => st_slave_port_stb(12),
    s12_ack_i   => st_slave_port_ack(12),
    s12_err_i   => st_slave_port_err(12),
    s12_rty_i   => st_slave_port_rty(12),
    s12_cti_o   => st_slave_port_cti(12),
    s12_bte_o   => st_slave_port_bte(12),
    -- 
    -- Slave 13 Interface
    s13_data_i  => st_slave_port_data_in(13),
    s13_data_o  => st_slave_port_data_out(13),
    s13_addr_o  => st_slave_port_addr(13),
    s13_sel_o   => st_slave_port_sel(13),
    s13_we_o    => st_slave_port_we(13),
    s13_cyc_o   => st_slave_port_cyc(13),
    s13_stb_o   => st_slave_port_stb(13),
    s13_ack_i   => st_slave_port_ack(13),
    s13_err_i   => st_slave_port_err(13),
    s13_rty_i   => st_slave_port_rty(13),
    s13_cti_o   => st_slave_port_cti(13),
    s13_bte_o   => st_slave_port_bte(13),
    -- 
    -- Slave 14 Interface
    s14_data_i  => st_slave_port_data_in(14),
    s14_data_o  => st_slave_port_data_out(14),
    s14_addr_o  => st_slave_port_addr(14),
    s14_sel_o   => st_slave_port_sel(14),
    s14_we_o    => st_slave_port_we(14),
    s14_cyc_o   => st_slave_port_cyc(14),
    s14_stb_o   => st_slave_port_stb(14),
    s14_ack_i   => st_slave_port_ack(14),
    s14_err_i   => st_slave_port_err(14),
    s14_rty_i   => st_slave_port_rty(14),
    s14_cti_o   => st_slave_port_cti(14),
    s14_bte_o   => st_slave_port_bte(14),
    --
    -- Slave 15 Interface
    s15_data_i  => st_slave_port_data_in(15),
    s15_data_o  => st_slave_port_data_out(15),
    s15_addr_o  => st_slave_port_addr(15),
    s15_sel_o   => st_slave_port_sel(15),
    s15_we_o    => st_slave_port_we(15),
    s15_cyc_o   => st_slave_port_cyc(15),
    s15_stb_o   => st_slave_port_stb(15),
    s15_ack_i   => st_slave_port_ack(15),
    s15_err_i   => st_slave_port_err(15),
    s15_rty_i   => st_slave_port_rty(15),
    s15_cti_o   => st_slave_port_cti(15),
    s15_bte_o   => st_slave_port_bte(15)
);
-------------------------------------------------------------------------------
--
-- Module Inner route:
--
--  1st route WB_CROSS MASTER signals:
--      ==> Deal with PCIE_CORE64_WB Ports:
st_master_port_data_in(0)   <= sv_wbm_data_out_pcie_core64_wb;  -- from WBM to WB_CROSS
st_master_port_addr(0)      <= sv_wbm_addr_pcie_core64_wb;      -- ...
st_master_port_sel(0)       <= sv_wbm_sel_pcie_core64_wb;       -- ...
st_master_port_we(0)        <= s_wbm_we_pcie_core64_wb;         -- ...
st_master_port_cyc(0)       <= s_wbm_cyc_pcie_core64_wb;        -- ...
st_master_port_stb(0)       <= s_wbm_stb_pcie_core64_wb;        -- ...
st_master_port_cti(0)       <= sv_wbm_cti_pcie_core64_wb;       -- ...
st_master_port_bte(0)       <= sv_wbm_bte_pcie_core64_wb;       -- ...

sv_wbm_data_in_pcie_core64_wb   <= st_master_port_data_out(0);  -- from WB_CROSS to WBM
s_wbm_ack_pcie_core64_wb        <= st_master_port_ack(0);       -- ...
s_wbm_err_pcie_core64_wb        <= st_master_port_err(0);       -- ...
s_wbm_rty_pcie_core64_wb        <= st_master_port_rty(0);       -- ...
--      ==> Deal with Unused Ports:
gen_conn_to_unused_mports   : for i in (0+1) to p_WB_CROSS_MASTER_Q-1 generate
    st_master_port_data_in(i)   <= (others => '0');
    st_master_port_addr(i)      <= (others => '0');
    st_master_port_sel(i)       <= (others => '0');
    st_master_port_we(i)        <= '0';
    st_master_port_cyc(i)       <= '0';
    st_master_port_stb(i)       <= '0';
    st_master_port_cti(i)       <= (others => '0');
    st_master_port_bte(i)       <= (others => '0');
    --st_master_port_data_out(i)    <= ;
    --st_master_port_ack(i)         <= ;
    --st_master_port_err(i)         <= ;
    --st_master_port_rty(i)         <= ;
end generate gen_conn_to_unused_mports;
--
-- 2nd route WB_CROSS SLAVE signals:
--      Deal with TEST_CHECK.WB_CFG_SLAVE
sv_wbs_cfg_data_in_test_check   <= st_slave_port_data_out(0);   -- from WB_CROSS to WBS
sv_wbs_cfg_addr_test_check      <= st_slave_port_addr(0);       -- ...
sv_wbs_cfg_sel_test_check       <= st_slave_port_sel(0);        -- ...
s_wbs_cfg_we_test_check         <= st_slave_port_we(0);         -- ...
s_wbs_cfg_cyc_test_check        <= st_slave_port_cyc(0);        -- ...
s_wbs_cfg_stb_test_check        <= st_slave_port_stb(0);        -- ...
sv_wbs_cfg_cti_test_check       <= st_slave_port_cti(0);        -- ...
sv_wbs_cfg_bte_test_check       <= st_slave_port_bte(0);        -- ...

st_slave_port_data_in(0)    <= sv_wbs_cfg_data_out_test_check;  -- from WBS to WB_CROSS
st_slave_port_ack(0)        <= s_wbs_cfg_ack_test_check;        -- ...
st_slave_port_err(0)        <= s_wbs_cfg_err_test_check;        -- ...
st_slave_port_rty(0)        <= s_wbs_cfg_rty_test_check;        -- ...
--      Deal with TEST_CHECK.WB_BURST_SLAVE
sv_wbs_burst_data_in_test_check <= st_slave_port_data_out(1);   -- from WB_CROSS to WBS
sv_wbs_burst_addr_test_check    <= st_slave_port_addr(1);       -- ...
sv_wbs_burst_sel_test_check     <= st_slave_port_sel(1);        -- ...
s_wbs_burst_we_test_check       <= st_slave_port_we(1);         -- ...
s_wbs_burst_cyc_test_check      <= st_slave_port_cyc(1);        -- ...
s_wbs_burst_stb_test_check      <= st_slave_port_stb(1);        -- ...
sv_wbs_burst_cti_test_check     <= st_slave_port_cti(1);
sv_wbs_burst_bte_test_check     <= st_slave_port_bte(1);

st_slave_port_data_in(1)    <= (others => '0');                 -- from WBS to WB_CROSS
st_slave_port_ack(1)        <= s_wbs_burst_ack_test_check;      -- ...
st_slave_port_err(1)        <= s_wbs_burst_err_test_check;      -- ...
st_slave_port_rty(1)        <= s_wbs_burst_rty_test_check;      -- ...
--      Deal with TEST_GEN.WB_CFG_SLAVE
sv_wbs_cfg_data_in_test_gen <= st_slave_port_data_out(2);       -- from WB_CROSS to WBS
sv_wbs_cfg_addr_test_gen    <= st_slave_port_addr(2);           -- ...
sv_wbs_cfg_sel_test_gen     <= st_slave_port_sel(2);            -- ...
s_wbs_cfg_we_test_gen       <= st_slave_port_we(2);             -- ...
s_wbs_cfg_cyc_test_gen      <= st_slave_port_cyc(2);            -- ...
s_wbs_cfg_stb_test_gen      <= st_slave_port_stb(2);            -- ...
sv_wbs_cfg_cti_test_gen     <= st_slave_port_cti(2);            -- ...
sv_wbs_cfg_bte_test_gen     <= st_slave_port_bte(2);            -- ...

st_slave_port_data_in(2)    <= sv_wbs_cfg_data_out_test_gen;    -- from WBS to WB_CROSS
st_slave_port_ack(2)        <= s_wbs_cfg_ack_test_gen;          -- ...
st_slave_port_err(2)        <= s_wbs_cfg_err_test_gen;          -- ...
st_slave_port_rty(2)        <= s_wbs_cfg_rty_test_gen;          -- ...
--      Deal with TEST_GEN.WB_BURST_SLAVE
--st_slave_port_data_out(3)
sv_wbs_burst_addr_test_gen  <= st_slave_port_addr(3);
sv_wbs_burst_sel_test_gen   <= st_slave_port_sel(3);
s_wbs_burst_we_test_gen     <= st_slave_port_we(3);
s_wbs_burst_cyc_test_gen    <= st_slave_port_cyc(3);
s_wbs_burst_stb_test_gen    <= st_slave_port_stb(3);
sv_wbs_burst_cti_test_gen   <= st_slave_port_cti(3);
sv_wbs_burst_bte_test_gen   <= st_slave_port_bte(3);

st_slave_port_data_in(3)    <= sv_wbs_burst_data_out_test_gen;
st_slave_port_ack(3)        <= s_wbs_burst_ack_test_gen;
st_slave_port_err(3)        <= s_wbs_burst_err_test_gen;
st_slave_port_rty(3)        <= s_wbs_burst_rty_test_gen;
--      Deal with Unused SALVE Ports
gen_conn_to_unused_sports   : for i in (3+1) to p_WB_CROSS_SLAVE_Q-1 generate
    --st_slave_port_data_out(i)     <= ;
    --st_slave_port_addr(i)         <= ;
    --st_slave_port_sel(i)          <= ;
    --st_slave_port_we(i)           <= ;
    --st_slave_port_cyc(i)          <= ;
    --st_slave_port_stb(i)          <= ;
    --st_slave_port_cti(i)          <= ;
    --st_slave_port_bte(i)          <= ;
    st_slave_port_data_in(i)    <= p_TEST_DATA_64BIT;
    st_slave_port_ack(i)        <= '1'; -- ALWAYS READY (always answer to MASTER with "p_TEST_DATA_64BIT" value)
    st_slave_port_err(i)        <= '0';
    st_slave_port_rty(i)        <= '0';
    
end generate gen_conn_to_unused_sports;
--
-- Construct PCIE Line-width value:
sv_pcie_line_num    <= sv_pcie_lstatus(6 downto 4) when s_pcie_link_up_n='0'
                        else "000";

-------------------------------------------------------------------------------
--
-- Module Outputs deal:
--
led(1)  <= s_pcie_link_up_n after 1ns when rising_edge(s_wb_clk);           -- LED#0 - PCIE_LINK_UP
--
led(3 downto 2) <=  sv_pcie_line_num( 1 downto 0 ) after 1ns when rising_edge(s_wb_clk);  -- LED#1 - show PCIE line-width: x1->1, x2->2, etc...

-------------------------------------------------------------------------------
end rtl;
