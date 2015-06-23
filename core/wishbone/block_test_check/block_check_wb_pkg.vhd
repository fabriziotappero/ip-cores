----------------------------------------------------------------------------------
-- Company:         ;)
-- Engineer:        Kuzmi4
-- 
-- Create Date:     17:40:25 05/21/2010 
-- Design Name:     
-- Module Name:     add_test_check_pkg
-- Project Name:    
-- Target Devices:  
-- Tool versions:   
-- Description:     
--                  
--                  
--
-- Revision: 
-- Revision 0.01 - File Created
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package block_check_wb_pkg is

component block_check_wb_burst_slave
port
(
    --
    -- SYS_CON
    i_clk : IN STD_LOGIC;
    i_rst : IN STD_LOGIC;
    --
    -- WB BURST SLAVE IF (WRITE-ONLY IF)
    iv_wbs_burst_addr   : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
    iv_wbs_burst_data   : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
    iv_wbs_burst_sel    : IN STD_LOGIC_VECTOR( 7 DOWNTO 0);
    i_wbs_burst_we      : IN STD_LOGIC;
    i_wbs_burst_cyc     : IN STD_LOGIC;
    i_wbs_burst_stb     : IN STD_LOGIC;
    iv_wbs_burst_cti    : IN STD_LOGIC_VECTOR( 2 DOWNTO 0);
    iv_wbs_burst_bte    : IN STD_LOGIC_VECTOR( 1 DOWNTO 0);
    
    o_wbs_burst_ack     : OUT STD_LOGIC;
    o_wbs_burst_err     : OUT STD_LOGIC;
    o_wbs_burst_rty     : OUT STD_LOGIC;
    --
    -- TEST_CHECK IF (Output data with ENA)
    ov_test_check_data      : OUT   STD_LOGIC_VECTOR(63 DOWNTO 0);
    o_test_check_data_ena   : OUT   STD_LOGIC;
    --
    -- TEST_CHECK Controls (WBS_CFG)
    iv_control          : IN STD_LOGIC_VECTOR(15 DOWNTO 0)
    
);
end component block_check_wb_burst_slave;

end package block_check_wb_pkg;