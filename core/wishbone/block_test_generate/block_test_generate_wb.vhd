----------------------------------------------------------------------------------
-- Company:         ;)
-- Engineer:        Kuzmi4
-- 
-- Create Date:     17:40:25 05/21/2010 
-- Design Name:     
-- Module Name:     block_test_generate_wb - rtl 
-- Project Name:    DS_DMA
-- Target Devices:  (XC6LX45T - FIFO)
-- Tool versions:   Xilinx
-- Description:     
--                  
--                  Top-level module for TEST_GEN_WB functionality
--                  (NB!!! --> module contain syb-modules with restrictions)
--
-- Revision: 
-- Revision 0.01 - File Created 
-- Revision 0.02 - update BLOCK_ID/BLOCK_VER logic - now it's inner ID of component
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package block_test_generate_wb_pkg is

component block_test_generate_wb is
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
    -- WB BURST SLAVE IF (READ-ONLY IF)
    iv_wbs_burst_addr   :   in  std_logic_vector( 11 downto 0 );
    iv_wbs_burst_sel    :   in  std_logic_vector(  7 downto 0 );
    i_wbs_burst_we      :   in  std_logic;
    i_wbs_burst_cyc     :   in  std_logic;
    i_wbs_burst_stb     :   in  std_logic;
    iv_wbs_burst_cti    :   in  std_logic_vector(  2 downto 0 );
    iv_wbs_burst_bte    :   in  std_logic_vector(  1 downto 0 );
    
    ov_wbs_burst_data   :   out std_logic_vector( 63 downto 0 );
    o_wbs_burst_ack     :   out std_logic;
    o_wbs_burst_err     :   out std_logic;
    o_wbs_burst_rty     :   out std_logic;
    --
    -- WB IRQ lines
    o_wbs_irq_0         :   out std_logic;
    o_wbs_irq_dmar      :   out std_logic
);
end component block_test_generate_wb;

end package block_test_generate_wb_pkg;
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library work;
use work.cl_test_generate_pkg.all;
use work.block_generate_wb_config_slave_pkg.all;
use work.block_generate_wb_pkg.all;

entity block_test_generate_wb is
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
    -- WB BURST SLAVE IF (READ-ONLY IF)
    iv_wbs_burst_addr   :   in  std_logic_vector( 11 downto 0 );
    iv_wbs_burst_sel    :   in  std_logic_vector(  7 downto 0 );
    i_wbs_burst_we      :   in  std_logic;
    i_wbs_burst_cyc     :   in  std_logic;
    i_wbs_burst_stb     :   in  std_logic;
    iv_wbs_burst_cti    :   in  std_logic_vector(  2 downto 0 );
    iv_wbs_burst_bte    :   in  std_logic_vector(  1 downto 0 );
    
    ov_wbs_burst_data   :   out std_logic_vector( 63 downto 0 );
    o_wbs_burst_ack     :   out std_logic;
    o_wbs_burst_err     :   out std_logic;
    o_wbs_burst_rty     :   out std_logic;
    --
    -- WB IRQ lines
    o_wbs_irq_0         :   out std_logic;
    o_wbs_irq_dmar      :   out std_logic
);
end block_test_generate_wb;

architecture rtl of block_test_generate_wb is
----------------------------------------------------------------------------------
--
-- Define TEST_GEN CTRL/STS stuff:
signal  sv_test_gen_ctrl    :   std_logic_vector(15 downto 0);
signal  sv_test_gen_size    :   std_logic_vector(15 downto 0);
signal  sv_test_gen_cnt1    :   std_logic_vector(15 downto 0);
signal  sv_test_gen_cnt2    :   std_logic_vector(15 downto 0);
signal  sv_test_gen_bl_wr   :   std_logic_vector(31 downto 0);
--
-- Define TEST_GEN DATA_OUT IF stuff:
signal  sv_di_data          :   std_logic_vector(63 downto 0);
signal  s_di_data_we        :   std_logic;
signal  s_di_flag_paf       :   std_logic;
signal  s_di_fifo_rst       :   std_logic;
signal  s_di_start          :   std_logic;
--
-- Define WB_BURST_SLAVE/TEST_GEN_FIFO communication stuff:
signal  sv_test_gen_fifo_data       :   std_logic_vector(63 downto 0);
signal  s_test_gen_fifo_rd          :   std_logic;
signal  s_test_gen_fifo_full        :   std_logic;
signal  s_test_gen_fifo_empty       :   std_logic;
signal  s_test_gen_fifo_prog_full   :   std_logic;	
signal	iv_test_gen_status			:   std_logic_vector( 31 downto 0 ); 
signal	rstp						:   std_logic;
signal	dmar						:   std_logic;
----------------------------------------------------------------------------------
begin
----------------------------------------------------------------------------------
--
-- Instaniate WB_CFG_SLAVE
--
WB_CFG_SLAVE    :   block_generate_wb_config_slave
generic map
(
    BLOCK_ID   => x"001B", -- идентификатор модуля
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
    ov_test_gen_ctrl    => sv_test_gen_ctrl,
    ov_test_gen_size    => sv_test_gen_size,
    ov_test_gen_cnt1    => sv_test_gen_cnt1,
    ov_test_gen_cnt2    => sv_test_gen_cnt2,
    --
    -- STATUS Input						  
	iv_test_gen_status  => iv_test_gen_status,
    iv_test_gen_bl_wr   => sv_test_gen_bl_wr
);
----------------------------------------------------------------------------------
--
-- Instaniate TEST_GEN 
--
TEST_GEN    :   cl_test_generate
port map
(
    ---- Global ----
    reset       => s_di_fifo_rst,   -- 0 - сброс
    clk         => i_clk,           -- тактовая частота
    
    ---- DIO_IN ----
    di_clk      => i_clk,                   -- тактовая частота записи в FIFO
    di_data     => sv_di_data,              -- данные
    di_data_we  => s_di_data_we,            -- 1 - запись данных
    di_flag_paf => s_di_flag_paf,           -- 1 - есть место для записи
    di_fifo_rst => s_di_fifo_rst,           -- 0 - сброс FIFO
    di_start    => s_di_start,              -- 1 - разрешение работы (MODE0[5])
    
    ---- Управление ----
    test_gen_ctrl   => sv_test_gen_ctrl,    -- Регистр управления
    test_gen_size   => sv_test_gen_size,    -- размер в блоках по 512x64 (4096 байт)
    test_gen_bl_wr  => sv_test_gen_bl_wr,   -- Число записанных блоков [31:0]
    test_gen_cnt1   => sv_test_gen_cnt1,    -- Счётчик разрешения работы
    test_gen_cnt2   => sv_test_gen_cnt2     -- Счётчик запрещения работы
);
----------------------------------------------------------------------------------
--
-- Instaniate TEST_GEN_FIFO
--  ==> Volume==(512+512)x64bit
--
TEST_GEN_FIFO   :   ctrl_fifo1024x64_st_v1
PORT MAP 
(
    --
    -- SYS_CON
    clk => i_clk,
    rst => rstp,
    --
    -- DATA_IN 
    din     => sv_di_data,
    wr_en   => s_di_data_we,
    --
    -- DATA_OUT
    dout    => sv_test_gen_fifo_data,
    rd_en   => s_test_gen_fifo_rd,
    --
    -- FLAGs
    full        => s_test_gen_fifo_full,
    empty       => s_test_gen_fifo_empty,
    prog_full   => s_test_gen_fifo_prog_full    -- Level==512
);
----------------------------------------------------------------------------------
--
-- Instaniate WB_BURST_SLAVE (provide Output-Only Functionality)
--
WB_BURST_SLAVE  :   block_generate_wb_burst_slave
port map
(
    --
    -- SYS_CON
    i_clk => i_clk,
    i_rst => i_rst,
    --
    -- WB BURST SLAVE IF (READ-ONLY IF)
    iv_wbs_burst_addr   => iv_wbs_burst_addr,
    iv_wbs_burst_sel    => iv_wbs_burst_sel,
    i_wbs_burst_we      => i_wbs_burst_we,
    i_wbs_burst_cyc     => i_wbs_burst_cyc,
    i_wbs_burst_stb     => i_wbs_burst_stb,
    iv_wbs_burst_cti    => iv_wbs_burst_cti,
    iv_wbs_burst_bte    => iv_wbs_burst_bte,
    
    ov_wbs_burst_data   => ov_wbs_burst_data,
    o_wbs_burst_ack     => o_wbs_burst_ack,
    o_wbs_burst_err     => o_wbs_burst_err,
    o_wbs_burst_rty     => o_wbs_burst_rty,
    --
    -- TEST_GEN_FIFO IF 
    iv_test_gen_fifo_data       => sv_test_gen_fifo_data,
    o_test_gen_fifo_rd          => s_test_gen_fifo_rd,
    i_test_gen_fifo_full        => s_test_gen_fifo_full,
    i_test_gen_fifo_empty       => s_test_gen_fifo_empty,
    i_test_gen_fifo_prog_full   => s_test_gen_fifo_prog_full
    
);
----------------------------------------------------------------------------------
--
-- MODULE INNER wires routing:
--
-- define TEST_GEN.di_flag_paf like TEST_GEN_FIFO.prog_full 
s_di_flag_paf   <= not s_test_gen_fifo_prog_full;
-- define TEST_GEN.di_start like TEST_GEN.sv_test_gen_ctrl[1] ( 1-> RSVD ) 
s_di_start      <= sv_test_gen_ctrl(5);
-- define TEST_GEN.di_fifo_rst - it is RST_n signal 
s_di_fifo_rst   <= not rstp;

rstp <= i_rst or sv_test_gen_ctrl(0) after 1 ns when rising_edge( i_clk );

iv_test_gen_status(0) <= '1';
iv_test_gen_status(1) <= '0';
iv_test_gen_status(2) <= s_test_gen_fifo_empty;
iv_test_gen_status(3) <= s_test_gen_fifo_prog_full;
iv_test_gen_status(4) <= s_test_gen_fifo_full;
iv_test_gen_status(5) <= '0';
iv_test_gen_status(6) <= '0';
iv_test_gen_status(7) <= '0';
iv_test_gen_status(8) <= sv_test_gen_ctrl(5);
iv_test_gen_status(9) <= dmar;
iv_test_gen_status(10) <= rstp;
iv_test_gen_status(11) <= '0';
iv_test_gen_status(12) <= '0';
iv_test_gen_status(13) <= '0';
iv_test_gen_status(14) <= '0';
iv_test_gen_status(15) <= '0';

iv_test_gen_status( 31 downto 16 ) <= (others=>'0');



----------------------------------------------------------------------------------
--
-- MODULE OUTPUTs routing:
--
-- DMAR WB IRQ deal				   
dmar <= s_test_gen_fifo_prog_full or sv_test_gen_ctrl(14);   -- (DS: 512 слов заполнили - взевели dmar)
o_wbs_irq_dmar  <= dmar;
-- WB IRQ deal
o_wbs_irq_0     <= '0';                         -- No EVENTs for now
----------------------------------------------------------------------------------
end rtl;

