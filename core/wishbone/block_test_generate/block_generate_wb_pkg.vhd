----------------------------------------------------------------------------------
-- Company:         ;)
-- Engineer:        Kuzmi4
-- 
-- Create Date:     17:40:25 05/21/2010 
-- Design Name:     
-- Module Name:     add_test_gen_pkg
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

package block_generate_wb_pkg is

COMPONENT ctrl_fifo1024x64_st_v1
  PORT (
    clk : IN STD_LOGIC;
    rst : IN STD_LOGIC;
    din : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
    wr_en : IN STD_LOGIC;
    rd_en : IN STD_LOGIC;
    dout : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
    full : OUT STD_LOGIC;
    empty : OUT STD_LOGIC;
    prog_full : OUT STD_LOGIC
  );
END COMPONENT ctrl_fifo1024x64_st_v1;

component block_generate_wb_burst_slave
port
(
    --
    -- SYS_CON
    i_clk : IN STD_LOGIC;
    i_rst : IN STD_LOGIC;
    --
    -- WB BURST SLAVE IF (READ-ONLY IF)
    iv_wbs_burst_addr   : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
    iv_wbs_burst_sel    : IN STD_LOGIC_VECTOR( 7 DOWNTO 0);
    i_wbs_burst_we      : IN STD_LOGIC;
    i_wbs_burst_cyc     : IN STD_LOGIC;
    i_wbs_burst_stb     : IN STD_LOGIC;
    iv_wbs_burst_cti    : IN STD_LOGIC_VECTOR( 2 DOWNTO 0);
    iv_wbs_burst_bte    : IN STD_LOGIC_VECTOR( 1 DOWNTO 0);
    
    ov_wbs_burst_data   : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
    o_wbs_burst_ack     : OUT STD_LOGIC;
    o_wbs_burst_err     : OUT STD_LOGIC;
    o_wbs_burst_rty     : OUT STD_LOGIC;
    --
    -- TEST_GEN_FIFO IF
    iv_test_gen_fifo_data       : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
    o_test_gen_fifo_rd          : OUT STD_LOGIC;
    i_test_gen_fifo_full        : IN STD_LOGIC;
    i_test_gen_fifo_empty       : IN STD_LOGIC;
    i_test_gen_fifo_prog_full   : IN STD_LOGIC
);
end component block_generate_wb_burst_slave;

end package block_generate_wb_pkg;