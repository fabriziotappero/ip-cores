----------------------------------------------------------------------------------
-- Company:         ;)
-- Engineer:        Kuzmi4
-- 
-- Create Date:     17:40:25 05/21/2010 
-- Design Name:     
-- Module Name:     block_check_wb_config_slave - rtl 
-- Project Name:    DS_DMA
-- Target Devices:  any
-- Tool versions:   
-- Description:     
--                  
--                  For now we have such restrictions for WB component:
--                      1) no WB_RTY support
--                      2) WB_ERR arize only at event detection and fall after it goes.
--                      3) Operate with Single 64bit WB Transfers. NO WB BURSTs.
--                      4) (TBD)...
--                  
--                   WB_SLAVE MM (ONLY 256B range):
--                  1) CONSTANTs:
--                  ADDR=x00 - BLOCK_ID
--                  ADDR=x08 - BLOCK_VER
--                  ADDR=x10 - RSVD (CONSTANTs)
--                  ADDR=x18 - RSVD (CONSTANTs)
--                  ADDR=x20 - RSVD (CONSTANTs)
--                  ADDR=x28 - RSVD (CONSTANTs)
--                  ADDR=x30 - RSVD (CONSTANTs)
--                  ADDR=x38 - RSVD (CONSTANTs)
--                  2) COMMAND REGs:
--                  ADDR=x40 - TEST_CHECK_CTRL
--                  ADDR=x48 - TEST_CHECK_SIZE
--                  ADDR=x50 - TEST_CHECK_ERR_ADDR
--                  ADDR=x58 - TEST_CHECK_WBS_BURST_CTRL
--                  ADDR=x60 - RSVD (COMMAND REGs)
--                  ADDR=x68 - RSVD (COMMAND REGs)
--                  ADDR=x70 - RSVD (COMMAND REGs)
--                  ADDR=x78 - RSVD (COMMAND REGs)
--                  3) STS REGs, etc:
--                  ADDR=x80 - TEST_CHECK_BL_RD
--                  ADDR=x88 - TEST_CHECK_BL_OK
--                  ADDR=x90 - TEST_CHECK_BL_ERR
--                  ADDR=x98 - TEST_CHECK_ERR
--                  ADDR=xA0 - TEST_CHECK_ERR_DATA
--                  ADDR=xA8 - RSVD (STS REGs, etc)
--                  ....
--                  ADDR=xFF - RSVD (STS REGs, etc)
--                  
--                  
--
-- Revision: 
-- Revision 0.01 - File Created,
--                  2do: for now ADD MemoryMap looks good, but maybe its quite diff from REAL SITUATION --> CHECK/FIX MM later!!!
-- Revision 0.02 - upd WB_ERR func.
-- Revision 0.03 - fix MM (8cell allign).
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package block_check_wb_config_slave_pkg is

component block_check_wb_config_slave is
generic 
(
    BLOCK_ID   : in std_logic_vector( 15 downto 0 ):=x"0000"; -- идентификатор модул€
    BLOCK_VER  : in std_logic_vector( 15 downto 0 ):=x"0000"  -- верси€ модул€
);
port 
( 
    --
    -- SYS_CON
    i_clk : in  STD_LOGIC;
    i_rst : in  STD_LOGIC;
    --
    -- WB CFG SLAVE
    iv_wbs_cfg_addr     :   in  std_logic_vector(  7 downto 0 );
    iv_wbs_cfg_data     :   in  std_logic_vector( 63 downto 0 );
    iv_wbs_cfg_sel      :   in  std_logic_vector(  7 downto 0 );    -- wor now, we NC this wires
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
    -- CONTROL Outputs
    ov_test_check_ctrl      :   out std_logic_vector( 15 downto 0 );
    ov_test_check_size      :   out std_logic_vector( 15 downto 0 );
    ov_test_check_err_adr   :   out std_logic_vector( 15 downto 0 );
    
    ov_wb_burst_control     :   out std_logic_vector( 15 downto 0 );
    --
    -- STATUS Input
    iv_test_check_bl_rd     :   in  std_logic_vector( 31 downto 0 );
    iv_test_check_bl_ok     :   in  std_logic_vector( 31 downto 0 );
    iv_test_check_bl_err    :   in  std_logic_vector( 31 downto 0 );
    iv_test_check_error     :   in  std_logic_vector( 31 downto 0 );
    iv_test_check_err_data  :   in  std_logic_vector( 15 downto 0 )
);
end component block_check_wb_config_slave;

end package block_check_wb_config_slave_pkg;
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library work;
use work.ctrl_ram16_v1_pkg.all;
use work.host_pkg.all;

entity block_check_wb_config_slave is
generic 
(
    BLOCK_ID   : in std_logic_vector( 15 downto 0 ):=x"0000"; -- идентификатор модул€
    BLOCK_VER  : in std_logic_vector( 15 downto 0 ):=x"0000"  -- верси€ модул€
);
port 
( 
    --
    -- SYS_CON
    i_clk : in  STD_LOGIC;
    i_rst : in  STD_LOGIC;
    --
    -- WB CFG SLAVE
    iv_wbs_cfg_addr     :   in  std_logic_vector(  7 downto 0 );
    iv_wbs_cfg_data     :   in  std_logic_vector( 63 downto 0 );
    iv_wbs_cfg_sel      :   in  std_logic_vector(  7 downto 0 );    -- wor now, we NC this wires
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
    -- CONTROL Outputs
    ov_test_check_ctrl      :   out std_logic_vector( 15 downto 0 );
    ov_test_check_size      :   out std_logic_vector( 15 downto 0 );
    ov_test_check_err_adr   :   out std_logic_vector( 15 downto 0 );
    
    ov_wb_burst_control     :   out std_logic_vector( 15 downto 0 );
    --
    -- STATUS Input
    iv_test_check_bl_rd     :   in  std_logic_vector( 31 downto 0 );
    iv_test_check_bl_ok     :   in  std_logic_vector( 31 downto 0 );
    iv_test_check_bl_err    :   in  std_logic_vector( 31 downto 0 );
    iv_test_check_error     :   in  std_logic_vector( 31 downto 0 );
    iv_test_check_err_data  :   in  std_logic_vector( 15 downto 0 )
);
end block_check_wb_config_slave;

architecture rtl of block_check_wb_config_slave is
----------------------------------------------------------------------------------
--
-- Define CONSTANTs
constant    ct_bl_rom   :   bh_rom:=( 
                                        0=> BLOCK_ID,   -- 
                                        1=> BLOCK_VER,  -- 
                                        2=> x"5504",    -- 2=> Device_ID,
                                        3=> x"0210",    -- 3=> Revision,
                                        4=> x"0104",    -- 4=> PLD_VER,  
                                        5=> x"0000",
                                        6=> x"0000",
                                        7=> x"0000" 
                                    );
--
-- Define BL_RAM stuff:
signal  sv_bl_ram_adr       :   std_logic_vector( 4 downto 0):= (others => '0');
signal  sv_bl_ram_data_in   :   std_logic_vector(15 downto 0):= (others => '0');
signal  sv_bl_ram_data_out  :   std_logic_vector(15 downto 0):= (others => '0');
signal  s_bl_ram_data_we    :   std_logic:= '0';
--
-- DEFINE WB_FSM (required for build correct WB_ACK) stuff:
signal  sv_wbs_cfg_ack_counter  :   std_logic:='0';
--
-- Define additional WB signals:
signal  s_wbs_active_wr     :   std_logic;
signal  s_wbs_active_rd     :   std_logic;
signal  s_wbs_active        :   std_logic;
signal  s_wbs_wr_ena        :   std_logic;
----------------------------------------------------------------------------------
begin
----------------------------------------------------------------------------------
--
-- WB ACTIVE/ENA flag (for RD/WR and for any WB activity)
--
s_wbs_active_wr <= '1' when (
                                i_wbs_cfg_cyc='1' and i_wbs_cfg_stb='1' and i_wbs_cfg_we='1' and    -- all strobes OK
                                (iv_wbs_cfg_cti="000") and (iv_wbs_cfg_bte="00")                    -- type of transfer OK
                            ) else '0';

s_wbs_active_rd <= '1' when (
                                i_wbs_cfg_cyc='1' and i_wbs_cfg_stb='1' and i_wbs_cfg_we='0' and 
                                (iv_wbs_cfg_cti="000") and (iv_wbs_cfg_bte="00")
                            ) else '0';

s_wbs_active    <= '1' when (
                                i_wbs_cfg_cyc='1' and i_wbs_cfg_stb='1'                      and 
                                (iv_wbs_cfg_cti="000") and (iv_wbs_cfg_bte="00")
                            ) else '0';
                            
s_wbs_wr_ena    <= '1' when (
                                s_wbs_active_wr='1'             and     -- have ACTIVE WR flag
                                (sv_wbs_cfg_ack_counter='1')            -- present WB_ACK source
                            ) else '0';
----------------------------------------------------------------------------------
--
-- WB Write process
--
WB_WRITE    :   process (i_clk, i_rst)
    begin
        if (i_rst='1') then             -- RST
            ov_test_check_ctrl      <= (others => '0');
            ov_test_check_size      <= (others => '0');
            ov_test_check_err_adr   <= (others => '0');
            ov_wb_burst_control     <= (others => '0');
        elsif (rising_edge(i_clk)) then -- WRK
            if (s_wbs_wr_ena='1') then
                case(iv_wbs_cfg_addr(7 downto 0)) is
                    -- 
                    when x"40"  => ov_test_check_ctrl       <= iv_wbs_cfg_data( 15 downto 0);
                    when x"48"  => ov_test_check_size       <= iv_wbs_cfg_data( 15 downto 0);
                    when x"50"  => ov_test_check_err_adr    <= iv_wbs_cfg_data( 15 downto 0);
                    -- 
                    when x"58"  => ov_wb_burst_control      <= iv_wbs_cfg_data( 15 downto 0);
                    when others => null;
                end case;
            end if;
        end if;
end process WB_WRITE;
----------------------------------------------------------------------------------
--
-- WB Read process
--
WB_READ     :   process (i_clk, i_rst)
    begin
        if (i_rst='1') then             -- RST
            ov_wbs_cfg_data <= (others => '0');
        elsif (rising_edge(i_clk)) then -- WRK
            if (s_wbs_active_rd='1') then
                case(iv_wbs_cfg_addr(7 downto 0)) is
                    -- STS MM region
                    when x"80"  => ov_wbs_cfg_data(31 downto 0) <= iv_test_check_bl_rd;
                    when x"88"  => ov_wbs_cfg_data(31 downto 0) <= iv_test_check_bl_ok;
                    when x"90"  => ov_wbs_cfg_data(31 downto 0) <= iv_test_check_bl_err;
                    when x"98"  => ov_wbs_cfg_data(31 downto 0) <= iv_test_check_error;
                    when x"A0"  => ov_wbs_cfg_data(15 downto 0) <= iv_test_check_err_data;
                    -- OTHER case -> BL_RAM MM region
                    when others =>  ov_wbs_cfg_data(15 downto 0) <= sv_bl_ram_data_out;
                end case;
            end if;
        end if;
end process WB_READ;
----------------------------------------------------------------------------------
--
-- WB ACK process
--
WB_ACK_CNT  :   process (i_clk, i_rst)
    begin
        if (i_rst='1') then             -- RST
            sv_wbs_cfg_ack_counter <= '0';
        elsif (rising_edge(i_clk)) then -- WRK:
            if (s_wbs_active='1') then  -- WB Transfer in progress
                --sv_wbs_cfg_ack_counter <= sv_wbs_cfg_ack_counter + '1';
                if (sv_wbs_cfg_ack_counter='0') then
                    sv_wbs_cfg_ack_counter <= '1';
                else
                    sv_wbs_cfg_ack_counter <= '0';
                end if;
            else                        -- no WB Transfer
                sv_wbs_cfg_ack_counter <= '0';
            end if;
        end if;
end process WB_ACK_CNT;
-- Define WB_ACK
o_wbs_cfg_ack <= '1' when   (
                                sv_wbs_cfg_ack_counter='1' and 
                                i_wbs_cfg_cyc='1' and i_wbs_cfg_stb='1' -- add controls for avoid problems in anarranged transfers
                            ) else '0';
----------------------------------------------------------------------------------
--
-- Instaniate BL_RAM (contain CONSTANTs and RD values for COMMAND registers)
--
BL_RAM  :   ctrl_ram16_v1 
generic map
(
    rom	        => ct_bl_rom            -- значени€ констант
)
port map
(
    clk         => i_clk,               -- “актова€ частота
    
    adr         => sv_bl_ram_adr,       -- адрес 
    data_in     => sv_bl_ram_data_in,   -- вход данных
    data_out    => sv_bl_ram_data_out,  -- выход данных
    
    data_we     => s_bl_ram_data_we     -- 1 - запись данных
);
-- Define BL_RAM ADDR
sv_bl_ram_adr       <= iv_wbs_cfg_addr( 7 downto 3);    -- 8B granularity Transfers (cut [2:0] addr bits)
-- DEFINE BL_RAM DATA_IN
sv_bl_ram_data_in   <= iv_wbs_cfg_data(15 downto 0);    -- Cut only LS 16bit
-- DEFINE BL_RAM DATA_WRITE
s_bl_ram_data_we    <= s_wbs_wr_ena;                    -- WB_WE signal is OK
----------------------------------------------------------------------------------
--
-- MODULE OUTPUTs routing:
--
-- WB_ERR deal
o_wbs_cfg_err   <= '1' when (
                                i_wbs_cfg_cyc='1' and i_wbs_cfg_stb='1' and             -- all strobes OK
                                ( (iv_wbs_cfg_cti/="000") or (iv_wbs_cfg_bte/="00") )   -- BUT type of transfer is NOT OK
                            ) else '0';
-- WB_RTY deal
o_wbs_cfg_rty   <= '0'; -- nothing to report for now
----------------------------------------------------------------------------------
end rtl;

