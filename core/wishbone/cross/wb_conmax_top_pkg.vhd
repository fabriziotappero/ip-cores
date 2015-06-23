----------------------------------------------------------------------------------
-- Company:         ;)
-- Engineer:        Kuzmi4
-- 
-- Create Date:     17:40:25 05/21/2010 
-- Design Name:     
-- Module Name:     wb_conmax_top Verilog component package
-- Project Name:    DS_DMA
-- Target Devices:  any
-- Tool versions:   
-- Description:     
--                  
--                  
--                  
--
-- Revision: 
-- Revision 0.01 - File Created
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package wb_conmax_top_pkg is
-- Define WB_CROSS:
component wb_conmax_top is
generic
(
    dw  :   integer;
    aw  :   integer
    
);
port 
( 
    --
    -- SYS_CON
    clk_i : in  STD_LOGIC;
    rst_i : in  STD_LOGIC;
    --
    -- Master 0 Interface
    m0_data_i   :   in  STD_LOGIC_VECTOR(dw-1 downto 0);
    m0_data_o   :   out STD_LOGIC_VECTOR(dw-1 downto 0);
    m0_addr_i   :   in  STD_LOGIC_VECTOR(aw-1 downto 0);
    m0_sel_i    :   in  STD_LOGIC_VECTOR(dw/8-1 downto 0);
    m0_we_i     :   in  STD_LOGIC;
    m0_cyc_i    :   in  STD_LOGIC;
    m0_stb_i    :   in  STD_LOGIC;
    m0_ack_o    :   out STD_LOGIC;
    m0_err_o    :   out STD_LOGIC;
    m0_rty_o    :   out STD_LOGIC;
    m0_cti_i    :   in  STD_LOGIC_VECTOR(2 downto 0);
    m0_bte_i    :   in  STD_LOGIC_VECTOR(1 downto 0);
    --
    -- Master 1 Interface
    m1_data_i   :   in  STD_LOGIC_VECTOR(dw-1 downto 0);
    m1_data_o   :   out STD_LOGIC_VECTOR(dw-1 downto 0);
    m1_addr_i   :   in  STD_LOGIC_VECTOR(aw-1 downto 0);
    m1_sel_i    :   in  STD_LOGIC_VECTOR(dw/8-1 downto 0);
    m1_we_i     :   in  STD_LOGIC;
    m1_cyc_i    :   in  STD_LOGIC;
    m1_stb_i    :   in  STD_LOGIC;
    m1_ack_o    :   out STD_LOGIC;
    m1_err_o    :   out STD_LOGIC;
    m1_rty_o    :   out STD_LOGIC;
    m1_cti_i    :   in  STD_LOGIC_VECTOR(2 downto 0);
    m1_bte_i    :   in  STD_LOGIC_VECTOR(1 downto 0);
    --
    -- Master 2 Interface
    m2_data_i   :   in  STD_LOGIC_VECTOR(dw-1 downto 0);
    m2_data_o   :   out STD_LOGIC_VECTOR(dw-1 downto 0);
    m2_addr_i   :   in  STD_LOGIC_VECTOR(aw-1 downto 0);
    m2_sel_i    :   in  STD_LOGIC_VECTOR(dw/8-1 downto 0);
    m2_we_i     :   in  STD_LOGIC;
    m2_cyc_i    :   in  STD_LOGIC;
    m2_stb_i    :   in  STD_LOGIC;
    m2_ack_o    :   out STD_LOGIC;
    m2_err_o    :   out STD_LOGIC;
    m2_rty_o    :   out STD_LOGIC;
    m2_cti_i    :   in  STD_LOGIC_VECTOR(2 downto 0);
    m2_bte_i    :   in  STD_LOGIC_VECTOR(1 downto 0);
    --
    -- Master 3 Interface
    m3_data_i   :   in  STD_LOGIC_VECTOR(dw-1 downto 0);
    m3_data_o   :   out STD_LOGIC_VECTOR(dw-1 downto 0);
    m3_addr_i   :   in  STD_LOGIC_VECTOR(aw-1 downto 0);
    m3_sel_i    :   in  STD_LOGIC_VECTOR(dw/8-1 downto 0);
    m3_we_i     :   in  STD_LOGIC;
    m3_cyc_i    :   in  STD_LOGIC;
    m3_stb_i    :   in  STD_LOGIC;
    m3_ack_o    :   out STD_LOGIC;
    m3_err_o    :   out STD_LOGIC;
    m3_rty_o    :   out STD_LOGIC;
    m3_cti_i    :   in  STD_LOGIC_VECTOR(2 downto 0);
    m3_bte_i    :   in  STD_LOGIC_VECTOR(1 downto 0);
    --
    -- Master 4 Interface
    m4_data_i   :   in  STD_LOGIC_VECTOR(dw-1 downto 0);
    m4_data_o   :   out STD_LOGIC_VECTOR(dw-1 downto 0);
    m4_addr_i   :   in  STD_LOGIC_VECTOR(aw-1 downto 0);
    m4_sel_i    :   in  STD_LOGIC_VECTOR(dw/8-1 downto 0);
    m4_we_i     :   in  STD_LOGIC;
    m4_cyc_i    :   in  STD_LOGIC;
    m4_stb_i    :   in  STD_LOGIC;
    m4_ack_o    :   out STD_LOGIC;
    m4_err_o    :   out STD_LOGIC;
    m4_rty_o    :   out STD_LOGIC;
    m4_cti_i    :   in  STD_LOGIC_VECTOR(2 downto 0);
    m4_bte_i    :   in  STD_LOGIC_VECTOR(1 downto 0);
    --
    -- Master 5 Interface
    m5_data_i   :   in  STD_LOGIC_VECTOR(dw-1 downto 0);
    m5_data_o   :   out STD_LOGIC_VECTOR(dw-1 downto 0);
    m5_addr_i   :   in  STD_LOGIC_VECTOR(aw-1 downto 0);
    m5_sel_i    :   in  STD_LOGIC_VECTOR(dw/8-1 downto 0);
    m5_we_i     :   in  STD_LOGIC;
    m5_cyc_i    :   in  STD_LOGIC;
    m5_stb_i    :   in  STD_LOGIC;
    m5_ack_o    :   out STD_LOGIC;
    m5_err_o    :   out STD_LOGIC;
    m5_rty_o    :   out STD_LOGIC;
    m5_cti_i    :   in  STD_LOGIC_VECTOR(2 downto 0);
    m5_bte_i    :   in  STD_LOGIC_VECTOR(1 downto 0);
    --
    -- Master 6 Interface
    m6_data_i   :   in  STD_LOGIC_VECTOR(dw-1 downto 0);
    m6_data_o   :   out STD_LOGIC_VECTOR(dw-1 downto 0);
    m6_addr_i   :   in  STD_LOGIC_VECTOR(aw-1 downto 0);
    m6_sel_i    :   in  STD_LOGIC_VECTOR(dw/8-1 downto 0);
    m6_we_i     :   in  STD_LOGIC;
    m6_cyc_i    :   in  STD_LOGIC;
    m6_stb_i    :   in  STD_LOGIC;
    m6_ack_o    :   out STD_LOGIC;
    m6_err_o    :   out STD_LOGIC;
    m6_rty_o    :   out STD_LOGIC;
    m6_cti_i    :   in  STD_LOGIC_VECTOR(2 downto 0);
    m6_bte_i    :   in  STD_LOGIC_VECTOR(1 downto 0);
    --
    -- Master 7 Interface
    m7_data_i   :   in  STD_LOGIC_VECTOR(dw-1 downto 0);
    m7_data_o   :   out STD_LOGIC_VECTOR(dw-1 downto 0);
    m7_addr_i   :   in  STD_LOGIC_VECTOR(aw-1 downto 0);
    m7_sel_i    :   in  STD_LOGIC_VECTOR(dw/8-1 downto 0);
    m7_we_i     :   in  STD_LOGIC;
    m7_cyc_i    :   in  STD_LOGIC;
    m7_stb_i    :   in  STD_LOGIC;
    m7_ack_o    :   out STD_LOGIC;
    m7_err_o    :   out STD_LOGIC;
    m7_rty_o    :   out STD_LOGIC;
    m7_cti_i    :   in  STD_LOGIC_VECTOR(2 downto 0);
    m7_bte_i    :   in  STD_LOGIC_VECTOR(1 downto 0);
    --
    --
    -- Slave 0 Interface
    s0_data_i   :   in  STD_LOGIC_VECTOR(dw-1 downto 0);
    s0_data_o   :   out STD_LOGIC_VECTOR(dw-1 downto 0);
    s0_addr_o   :   out STD_LOGIC_VECTOR(aw-1 downto 0);
    s0_sel_o    :   out STD_LOGIC_VECTOR(dw/8-1 downto 0);
    s0_we_o     :   out STD_LOGIC;
    s0_cyc_o    :   out STD_LOGIC;
    s0_stb_o    :   out STD_LOGIC;
    s0_ack_i    :   in  STD_LOGIC;
    s0_err_i    :   in  STD_LOGIC;
    s0_rty_i    :   in  STD_LOGIC;
    s0_cti_o    :   out STD_LOGIC_VECTOR(2 downto 0);
    s0_bte_o    :   out STD_LOGIC_VECTOR(1 downto 0);
    --
    -- Slave 1 Interface
    s1_data_i   :   in  STD_LOGIC_VECTOR(dw-1 downto 0);
    s1_data_o   :   out STD_LOGIC_VECTOR(dw-1 downto 0);
    s1_addr_o   :   out STD_LOGIC_VECTOR(aw-1 downto 0);
    s1_sel_o    :   out STD_LOGIC_VECTOR(dw/8-1 downto 0);
    s1_we_o     :   out STD_LOGIC;
    s1_cyc_o    :   out STD_LOGIC;
    s1_stb_o    :   out STD_LOGIC;
    s1_ack_i    :   in  STD_LOGIC;
    s1_err_i    :   in  STD_LOGIC;
    s1_rty_i    :   in  STD_LOGIC;
    s1_cti_o    :   out STD_LOGIC_VECTOR(2 downto 0);
    s1_bte_o    :   out STD_LOGIC_VECTOR(1 downto 0);
    --
    -- Slave 2 Interface
    s2_data_i   :   in  STD_LOGIC_VECTOR(dw-1 downto 0);
    s2_data_o   :   out STD_LOGIC_VECTOR(dw-1 downto 0);
    s2_addr_o   :   out STD_LOGIC_VECTOR(aw-1 downto 0);
    s2_sel_o    :   out STD_LOGIC_VECTOR(dw/8-1 downto 0);
    s2_we_o     :   out STD_LOGIC;
    s2_cyc_o    :   out STD_LOGIC;
    s2_stb_o    :   out STD_LOGIC;
    s2_ack_i    :   in  STD_LOGIC;
    s2_err_i    :   in  STD_LOGIC;
    s2_rty_i    :   in  STD_LOGIC;
    s2_cti_o    :   out STD_LOGIC_VECTOR(2 downto 0);
    s2_bte_o    :   out STD_LOGIC_VECTOR(1 downto 0);
    --
    -- Slave 3 Interface
    s3_data_i   :   in  STD_LOGIC_VECTOR(dw-1 downto 0);
    s3_data_o   :   out STD_LOGIC_VECTOR(dw-1 downto 0);
    s3_addr_o   :   out STD_LOGIC_VECTOR(aw-1 downto 0);
    s3_sel_o    :   out STD_LOGIC_VECTOR(dw/8-1 downto 0);
    s3_we_o     :   out STD_LOGIC;
    s3_cyc_o    :   out STD_LOGIC;
    s3_stb_o    :   out STD_LOGIC;
    s3_ack_i    :   in  STD_LOGIC;
    s3_err_i    :   in  STD_LOGIC;
    s3_rty_i    :   in  STD_LOGIC;
    s3_cti_o    :   out STD_LOGIC_VECTOR(2 downto 0);
    s3_bte_o    :   out STD_LOGIC_VECTOR(1 downto 0);
    -- 
    -- Slave 4 Interface
    s4_data_i   :   in  STD_LOGIC_VECTOR(dw-1 downto 0);
    s4_data_o   :   out STD_LOGIC_VECTOR(dw-1 downto 0);
    s4_addr_o   :   out STD_LOGIC_VECTOR(aw-1 downto 0);
    s4_sel_o    :   out STD_LOGIC_VECTOR(dw/8-1 downto 0);
    s4_we_o     :   out STD_LOGIC;
    s4_cyc_o    :   out STD_LOGIC;
    s4_stb_o    :   out STD_LOGIC;
    s4_ack_i    :   in  STD_LOGIC;
    s4_err_i    :   in  STD_LOGIC;
    s4_rty_i    :   in  STD_LOGIC;
    s4_cti_o    :   out STD_LOGIC_VECTOR(2 downto 0);
    s4_bte_o    :   out STD_LOGIC_VECTOR(1 downto 0);
    -- 
    -- Slave 5 Interface
    s5_data_i   :   in  STD_LOGIC_VECTOR(dw-1 downto 0);
    s5_data_o   :   out STD_LOGIC_VECTOR(dw-1 downto 0);
    s5_addr_o   :   out STD_LOGIC_VECTOR(aw-1 downto 0);
    s5_sel_o    :   out STD_LOGIC_VECTOR(dw/8-1 downto 0);
    s5_we_o     :   out STD_LOGIC;
    s5_cyc_o    :   out STD_LOGIC;
    s5_stb_o    :   out STD_LOGIC;
    s5_ack_i    :   in  STD_LOGIC;
    s5_err_i    :   in  STD_LOGIC;
    s5_rty_i    :   in  STD_LOGIC;
    s5_cti_o    :   out STD_LOGIC_VECTOR(2 downto 0);
    s5_bte_o    :   out STD_LOGIC_VECTOR(1 downto 0);
    --
    -- Slave 6 Interface
    s6_data_i   :   in  STD_LOGIC_VECTOR(dw-1 downto 0);
    s6_data_o   :   out STD_LOGIC_VECTOR(dw-1 downto 0);
    s6_addr_o   :   out STD_LOGIC_VECTOR(aw-1 downto 0);
    s6_sel_o    :   out STD_LOGIC_VECTOR(dw/8-1 downto 0);
    s6_we_o     :   out STD_LOGIC;
    s6_cyc_o    :   out STD_LOGIC;
    s6_stb_o    :   out STD_LOGIC;
    s6_ack_i    :   in  STD_LOGIC;
    s6_err_i    :   in  STD_LOGIC;
    s6_rty_i    :   in  STD_LOGIC;
    s6_cti_o    :   out STD_LOGIC_VECTOR(2 downto 0);
    s6_bte_o    :   out STD_LOGIC_VECTOR(1 downto 0);
    --
    -- Slave 7 Interface
    s7_data_i   :   in  STD_LOGIC_VECTOR(dw-1 downto 0);
    s7_data_o   :   out STD_LOGIC_VECTOR(dw-1 downto 0);
    s7_addr_o   :   out STD_LOGIC_VECTOR(aw-1 downto 0);
    s7_sel_o    :   out STD_LOGIC_VECTOR(dw/8-1 downto 0);
    s7_we_o     :   out STD_LOGIC;
    s7_cyc_o    :   out STD_LOGIC;
    s7_stb_o    :   out STD_LOGIC;
    s7_ack_i    :   in  STD_LOGIC;
    s7_err_i    :   in  STD_LOGIC;
    s7_rty_i    :   in  STD_LOGIC;
    s7_cti_o    :   out STD_LOGIC_VECTOR(2 downto 0);
    s7_bte_o    :   out STD_LOGIC_VECTOR(1 downto 0);
    --
    -- Slave 8 Interface
    s8_data_i   :   in  STD_LOGIC_VECTOR(dw-1 downto 0);
    s8_data_o   :   out STD_LOGIC_VECTOR(dw-1 downto 0);
    s8_addr_o   :   out STD_LOGIC_VECTOR(aw-1 downto 0);
    s8_sel_o    :   out STD_LOGIC_VECTOR(dw/8-1 downto 0);
    s8_we_o     :   out STD_LOGIC;
    s8_cyc_o    :   out STD_LOGIC;
    s8_stb_o    :   out STD_LOGIC;
    s8_ack_i    :   in  STD_LOGIC;
    s8_err_i    :   in  STD_LOGIC;
    s8_rty_i    :   in  STD_LOGIC;
    s8_cti_o    :   out STD_LOGIC_VECTOR(2 downto 0);
    s8_bte_o    :   out STD_LOGIC_VECTOR(1 downto 0);
    -- 
    -- Slave 9 Interface
    s9_data_i   :   in  STD_LOGIC_VECTOR(dw-1 downto 0);
    s9_data_o   :   out STD_LOGIC_VECTOR(dw-1 downto 0);
    s9_addr_o   :   out STD_LOGIC_VECTOR(aw-1 downto 0);
    s9_sel_o    :   out STD_LOGIC_VECTOR(dw/8-1 downto 0);
    s9_we_o     :   out STD_LOGIC;
    s9_cyc_o    :   out STD_LOGIC;
    s9_stb_o    :   out STD_LOGIC;
    s9_ack_i    :   in  STD_LOGIC;
    s9_err_i    :   in  STD_LOGIC;
    s9_rty_i    :   in  STD_LOGIC;
    s9_cti_o    :   out STD_LOGIC_VECTOR(2 downto 0);
    s9_bte_o    :   out STD_LOGIC_VECTOR(1 downto 0);
    -- 
    -- Slave 10 Interface
    s10_data_i  :   in  STD_LOGIC_VECTOR(dw-1 downto 0);
    s10_data_o  :   out STD_LOGIC_VECTOR(dw-1 downto 0);
    s10_addr_o  :   out STD_LOGIC_VECTOR(aw-1 downto 0);
    s10_sel_o   :   out STD_LOGIC_VECTOR(dw/8-1 downto 0);
    s10_we_o    :   out STD_LOGIC;
    s10_cyc_o   :   out STD_LOGIC;
    s10_stb_o   :   out STD_LOGIC;
    s10_ack_i   :   in  STD_LOGIC;
    s10_err_i   :   in  STD_LOGIC;
    s10_rty_i   :   in  STD_LOGIC;
    s10_cti_o   :   out STD_LOGIC_VECTOR(2 downto 0);
    s10_bte_o   :   out STD_LOGIC_VECTOR(1 downto 0);
    -- 
    -- Slave 11 Interface
    s11_data_i  :   in  STD_LOGIC_VECTOR(dw-1 downto 0);
    s11_data_o  :   out STD_LOGIC_VECTOR(dw-1 downto 0);
    s11_addr_o  :   out STD_LOGIC_VECTOR(aw-1 downto 0);
    s11_sel_o   :   out STD_LOGIC_VECTOR(dw/8-1 downto 0);
    s11_we_o    :   out STD_LOGIC;
    s11_cyc_o   :   out STD_LOGIC;
    s11_stb_o   :   out STD_LOGIC;
    s11_ack_i   :   in  STD_LOGIC;
    s11_err_i   :   in  STD_LOGIC;
    s11_rty_i   :   in  STD_LOGIC;
    s11_cti_o   :   out STD_LOGIC_VECTOR(2 downto 0);
    s11_bte_o   :   out STD_LOGIC_VECTOR(1 downto 0);
    -- 
    -- Slave 12 Interface
    s12_data_i  :   in  STD_LOGIC_VECTOR(dw-1 downto 0);
    s12_data_o  :   out STD_LOGIC_VECTOR(dw-1 downto 0);
    s12_addr_o  :   out STD_LOGIC_VECTOR(aw-1 downto 0);
    s12_sel_o   :   out STD_LOGIC_VECTOR(dw/8-1 downto 0);
    s12_we_o    :   out STD_LOGIC;
    s12_cyc_o   :   out STD_LOGIC;
    s12_stb_o   :   out STD_LOGIC;
    s12_ack_i   :   in  STD_LOGIC;
    s12_err_i   :   in  STD_LOGIC;
    s12_rty_i   :   in  STD_LOGIC;
    s12_cti_o   :   out STD_LOGIC_VECTOR(2 downto 0);
    s12_bte_o   :   out STD_LOGIC_VECTOR(1 downto 0);
    -- 
    -- Slave 13 Interface
    s13_data_i  :   in  STD_LOGIC_VECTOR(dw-1 downto 0);
    s13_data_o  :   out STD_LOGIC_VECTOR(dw-1 downto 0);
    s13_addr_o  :   out STD_LOGIC_VECTOR(aw-1 downto 0);
    s13_sel_o   :   out STD_LOGIC_VECTOR(dw/8-1 downto 0);
    s13_we_o    :   out STD_LOGIC;
    s13_cyc_o   :   out STD_LOGIC;
    s13_stb_o   :   out STD_LOGIC;
    s13_ack_i   :   in  STD_LOGIC;
    s13_err_i   :   in  STD_LOGIC;
    s13_rty_i   :   in  STD_LOGIC;
    s13_cti_o   :   out STD_LOGIC_VECTOR(2 downto 0);
    s13_bte_o   :   out STD_LOGIC_VECTOR(1 downto 0);
    -- 
    -- Slave 14 Interface
    s14_data_i  :   in  STD_LOGIC_VECTOR(dw-1 downto 0);
    s14_data_o  :   out STD_LOGIC_VECTOR(dw-1 downto 0);
    s14_addr_o  :   out STD_LOGIC_VECTOR(aw-1 downto 0);
    s14_sel_o   :   out STD_LOGIC_VECTOR(dw/8-1 downto 0);
    s14_we_o    :   out STD_LOGIC;
    s14_cyc_o   :   out STD_LOGIC;
    s14_stb_o   :   out STD_LOGIC;
    s14_ack_i   :   in  STD_LOGIC;
    s14_err_i   :   in  STD_LOGIC;
    s14_rty_i   :   in  STD_LOGIC;
    s14_cti_o   :   out STD_LOGIC_VECTOR(2 downto 0);
    s14_bte_o   :   out STD_LOGIC_VECTOR(1 downto 0);
    --
    -- Slave 15 Interface
    s15_data_i  :   in  STD_LOGIC_VECTOR(dw-1 downto 0);
    s15_data_o  :   out STD_LOGIC_VECTOR(dw-1 downto 0);
    s15_addr_o  :   out STD_LOGIC_VECTOR(aw-1 downto 0);
    s15_sel_o   :   out STD_LOGIC_VECTOR(dw/8-1 downto 0);
    s15_we_o    :   out STD_LOGIC;
    s15_cyc_o   :   out STD_LOGIC;
    s15_stb_o   :   out STD_LOGIC;
    s15_ack_i   :   in  STD_LOGIC;
    s15_err_i   :   in  STD_LOGIC;
    s15_rty_i   :   in  STD_LOGIC;
    s15_cti_o   :   out STD_LOGIC_VECTOR(2 downto 0);
    s15_bte_o   :   out STD_LOGIC_VECTOR(1 downto 0)
);
end component wb_conmax_top;
-- Define WB_CROSS constants:
constant    p_WB_CROSS_MASTER_Q :   integer:=8;
constant    p_WB_CROSS_SLAVE_Q  :   integer:=16;

constant    p_WB_CROSS_ADDR_W   :   integer:=32;
constant    p_WB_CROSS_DATA_W   :   integer:=64;

constant    p_TEST_DATA_32BIT   :   std_logic_vector( 31 downto 0):= x"12345678";
constant    p_TEST_DATA_64BIT   :   std_logic_vector( 63 downto 0):= x"0123456789ABCDEF";
-- Define WB_CROSS types (helps in cross route):
--  1) MASTER
type wb_master_port_addr    is array( p_WB_CROSS_MASTER_Q-1 downto 0 )  of std_logic_vector( p_WB_CROSS_ADDR_W-1 downto 0 );
type wb_master_port_data    is array( p_WB_CROSS_MASTER_Q-1 downto 0 )  of std_logic_vector( p_WB_CROSS_DATA_W-1 downto 0 );
type wb_master_port_sel     is array( p_WB_CROSS_MASTER_Q-1 downto 0 )  of std_logic_vector( (p_WB_CROSS_DATA_W/8)-1 downto 0 );
type wb_master_port_we      is array( p_WB_CROSS_MASTER_Q-1 downto 0 )  of std_logic;
type wb_master_port_cyc     is array( p_WB_CROSS_MASTER_Q-1 downto 0 )  of std_logic;
type wb_master_port_stb     is array( p_WB_CROSS_MASTER_Q-1 downto 0 )  of std_logic;
type wb_master_port_ack     is array( p_WB_CROSS_MASTER_Q-1 downto 0 )  of std_logic;
type wb_master_port_err     is array( p_WB_CROSS_MASTER_Q-1 downto 0 )  of std_logic;
type wb_master_port_rty     is array( p_WB_CROSS_MASTER_Q-1 downto 0 )  of std_logic;
type wb_master_port_cti     is array( p_WB_CROSS_MASTER_Q-1 downto 0 )  of std_logic_vector( 2 downto 0);
type wb_master_port_bte     is array( p_WB_CROSS_MASTER_Q-1 downto 0 )  of std_logic_vector( 1 downto 0);
--  2) SLAVE
type wb_slave_port_addr     is array( p_WB_CROSS_SLAVE_Q-1 downto 0 )   of std_logic_vector( p_WB_CROSS_ADDR_W-1 downto 0 );
type wb_slave_port_data     is array( p_WB_CROSS_SLAVE_Q-1 downto 0 )   of std_logic_vector( p_WB_CROSS_DATA_W-1 downto 0 );
type wb_slave_port_sel      is array( p_WB_CROSS_SLAVE_Q-1 downto 0 )   of std_logic_vector( (p_WB_CROSS_DATA_W/8)-1 downto 0 );
type wb_slave_port_we       is array( p_WB_CROSS_SLAVE_Q-1 downto 0 )   of std_logic;
type wb_slave_port_cyc      is array( p_WB_CROSS_SLAVE_Q-1 downto 0 )   of std_logic;
type wb_slave_port_stb      is array( p_WB_CROSS_SLAVE_Q-1 downto 0 )   of std_logic;
type wb_slave_port_ack      is array( p_WB_CROSS_SLAVE_Q-1 downto 0 )   of std_logic;
type wb_slave_port_err      is array( p_WB_CROSS_SLAVE_Q-1 downto 0 )   of std_logic;
type wb_slave_port_rty      is array( p_WB_CROSS_SLAVE_Q-1 downto 0 )   of std_logic;
type wb_slave_port_cti      is array( p_WB_CROSS_SLAVE_Q-1 downto 0 )   of std_logic_vector( 2 downto 0);
type wb_slave_port_bte      is array( p_WB_CROSS_SLAVE_Q-1 downto 0 )   of std_logic_vector( 1 downto 0);
end package wb_conmax_top_pkg;