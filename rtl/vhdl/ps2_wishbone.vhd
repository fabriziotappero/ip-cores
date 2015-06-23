-------------------------------------------------------------------------------
-- Title      : PS/2 Wishbone Interface
-- Project    :
-------------------------------------------------------------------------------
-- File       : ps2_wishbone.vhd
-- Author     : Daniel Quinter <danielqg@infonegocio.com>
-- Company    : Itoo Software
-- Created    : 2003-05-08
-- Last update: 2003-10-30
-- Platform   : VHDL'87
-------------------------------------------------------------------------------
-- Description: PS/2 mice/keyboard wishbone interface
-------------------------------------------------------------------------------
--  This code is distributed under the terms and conditions of the
--  GNU General Public License
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2003-05-08  1.0      daniel  Created
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;


entity ps2_wb is
        port (                          -- Wishbone interface
                wb_clk_i : in  std_logic;
                wb_rst_i : in  std_logic;
                wb_dat_i : in  std_logic_vector(7 downto 0);
                wb_dat_o : out std_logic_vector(7 downto 0);
                wb_adr_i : in  std_logic_vector(0 downto 0);
                wb_stb_i : in  std_logic;
                wb_we_i  : in  std_logic;
                wb_ack_o : out std_logic;

                -- IRQ output
                irq_o : out std_logic;

                -- PS2 signals
                ps2_clk : inout std_logic;
                ps2_dat : inout std_logic);
end ps2_wb;


architecture rtl of ps2_wb is
        component ps2
                port (
                        clk_i        : in    std_logic;
                        rst_i        : in    std_logic;
                        data_o       : out   std_logic_vector(7 downto 0);
                        data_i       : in    std_logic_vector(7 downto 0);
                        ibf_clr_i    : in    std_logic;
                        obf_set_i    : in    std_logic;
                        ibf_o        : out   std_logic;
                        obf_o        : out   std_logic;
                        frame_err_o  : out   std_logic;
                        parity_err_o : out   std_logic;
                        busy_o       : out   std_logic;
                        err_clr_i    : in    std_logic;
                        wdt_o        : out   std_logic;
                        ps2_clk_io   : inout std_logic;
                        ps2_data_io  : inout std_logic);
        end component;

        signal nrst       : std_logic;
        signal ps2_data_o : std_logic_vector(7 downto 0);
        signal ps2_data_i : std_logic_vector(7 downto 0);
        signal ibf_clr    : std_logic;
        signal obf_set    : std_logic;
        signal ibf        : std_logic;
        signal obf        : std_logic;
        signal frame_err  : std_logic;
        signal parity_err : std_logic;
        signal busy       : std_logic;
        signal err_clr    : std_logic;
        signal wdt        : std_logic;

        signal status_reg  : std_logic_vector(7 downto 0);
        signal control_reg : std_logic_vector(7 downto 0);

        signal irq_rx_enb : std_logic;
        signal irq_tx_enb : std_logic;

begin

        ps2_uart : ps2
                port map (
                        clk_i        => wb_clk_i,
                        rst_i        => nrst,
                        data_o       => ps2_data_o,
                        data_i       => ps2_data_i,
                        ibf_clr_i    => ibf_clr,
                        obf_set_i    => obf_set,
                        ibf_o        => ibf,
                        obf_o        => obf,
                        frame_err_o  => frame_err,
                        parity_err_o => parity_err,
                        busy_o       => busy,
                        err_clr_i    => err_clr,
                        wdt_o        => wdt,
                        ps2_clk_io   => ps2_clk,
                        ps2_data_io  => ps2_dat);

        nrst <= not wb_rst_i;

        -- clear error flags when clear it's
        err_clr <= '1' when wb_stb_i = '1' and wb_we_i = '1' and wb_adr_i = "1" and wb_dat_i(3) = '0'
                   else '0';

        -- clear In Buffer Full (IBF) flag when clear it
        ibf_clr <= '1' when wb_stb_i = '1' and wb_we_i = '1' and wb_adr_i = "1" and wb_dat_i(0) = '0'
                   else '0';

        -- set Out Buffer Full when write to data register
        obf_set <= '1' when wb_stb_i = '1' and wb_we_i = '1' and wb_adr_i = "0"
                   else '0';

        -- Status register
        status_reg(7)          <= irq_tx_enb;
        status_reg(6)          <= irq_rx_enb;
        status_reg(5 downto 4) <= "00";
        status_reg(3)          <= parity_err or frame_err;
        status_reg(2)          <= obf;
        status_reg(1)          <= ibf;
        status_reg(0)          <= busy;

        -- Control register
        irq_rx_enb <= control_reg(6);
        irq_tx_enb <= control_reg(7);

        -- purpose: Control register latch
        control_reg_proc : process (wb_clk_i)
        begin
                if (wb_clk_i'event and wb_clk_i = '1') then
                        if wb_rst_i = '1' then  -- Synchronous reset
                                control_reg(7 downto 6) <= (others => '0');
                        elsif (wb_stb_i and wb_we_i) = '1' and wb_adr_i = "1" then  -- control_write
                                control_reg(7 downto 6) <= wb_dat_i(7 downto 6);
                        end if;
                end if;

        end process control_reg_proc;

        -- output data/status
        wb_dat_o   <= ps2_data_o when wb_adr_i = "0" else status_reg;
        ps2_data_i <= wb_dat_i;

        -- Irq generation
        irq_o <= (ibf and irq_rx_enb) or ((not obf) and irq_tx_enb);

        -- no wait states for all acceses
        wb_ack_o <= wb_stb_i;

end rtl;
