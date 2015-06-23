-------------------------------------------------------------------------------
-- Title      : PS/2 Syntetizable interface Test
-- Project    :
-------------------------------------------------------------------------------
-- File       : ps2.vhd
-- Author     : Daniel Quintero <danielqg@infonegocio.com>
-- Company    : Itoo Software
-- Created    : 2003-04-14
-- Last update: 2003-10-30
-- Platform   : VHDL'87
-------------------------------------------------------------------------------
-- Description: Test interface for PS2 mouse
-------------------------------------------------------------------------------
--  This code is distributed under the terms and conditions of the
--  GNU General Public License
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2003-04-14  1.0      daniel  Created
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;

entity mouse_test is
        port (
                clk_i : in std_logic;
                rst_i : in std_logic;

                ps2_data_io : inout std_logic;
                ps2_clk_io  : inout std_logic;
                activity_o  : out   std_logic;
                beep_o      : out   std_logic;
                data_o      : out   std_logic_vector(23 downto 0);
                perr_o      : out   std_logic;
                ferr_o      : out   std_logic);
end mouse_test;



architecture rtl of mouse_test is
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
                        err_clr_i    : in    std_logic;
                        wdt_o        : out   std_logic;
                        ps2_clk_io   : inout std_logic;
                        ps2_data_io  : inout std_logic);
        end component;

        constant BEEP_TIMEOUT : integer := 24000;  -- clks to debounce the ps2_clk signal
        constant BEEP_BITS    : integer := 15;

        signal rst              : std_logic := '0';
        signal ps2_wdt          : std_logic;
        --signal rst_cnt_cao      : std_logic;
        --signal rst_cnt          : std_logic_vector(24 downto 0);
        signal beep_cnt_cao     : std_logic;
        signal beep_cnt         : std_logic_vector(BEEP_BITS-1 downto 0);
        signal beep_freq        : std_logic;
        signal data_cnt         : std_logic_vector(1 downto 0);
        signal data_out         : std_logic_vector(7 downto 0);
        signal data_in          : std_logic_vector(7 downto 0);
        signal mouse_data       : std_logic_vector(23 downto 0);
        signal ibf_clr, obf_set : std_logic;
        signal ibf, obf         : std_logic;
        signal parity_err       : std_logic;
        signal frame_err        : std_logic;
        signal err_clr          : std_logic;
        type   states is (reset, setup0, setup1, wait_packet,
                          wait_data, recv_data, process_data);
        signal state            : states;
begin
        syscon : process (clk_i)
        begin

                if clk_i'event and clk_i = '1' then
                        rst <= rst_i; -- and (not rst_cnt_cao);
                end if;
        end process;

--        rst_wdt : process (clk_i, rst_i)
--        begin
--                if rst_i = '0' then
--                        rst_cnt <= (others => '0');
--                elsif clk_i'event and clk_i = '1' then
--                       if rst_cnt_cao = '1' then
--                                rst_cnt <= (others => '0');
--                       else
--                                rst_cnt <= rst_cnt + 1;
--                       end if;
--                end if;
--        end process;
--        rst_cnt_cao <= rst_cnt(24);
--        rst_cnt_cao <= '0';

        beepcnt : process (clk_i, rst_i)
        begin
                if rst_i = '0' then
                        beep_cnt <= (others => '0');
                        beep_freq <= '0';
                elsif clk_i'event and clk_i = '1' then
                       if beep_cnt_cao = '1' then
                                beep_cnt <= (others => '0');
                                beep_freq <= not beep_freq;
                       else
                                beep_cnt <= beep_cnt + 1;
                       end if;
                end if;
        end process;
        beep_cnt_cao <= '1' when beep_cnt =
                        CONV_STD_LOGIC_VECTOR(BEEP_TIMEOUT-1, BEEP_BITS)
                        else '0';

        ps2_uart: ps2
                port map (
                        clk_i        => clk_i,
                        rst_i        => rst,
                        data_o       => data_in,
                        data_i       => data_out,
                        ibf_clr_i    => ibf_clr,
                        obf_set_i    => obf_set,
                        ibf_o        => ibf,
                        obf_o        => obf,
                        frame_err_o  => frame_err,
                        parity_err_o => parity_err,
                        err_clr_i    => err_clr,
                        wdt_o        => ps2_wdt,
                        ps2_clk_io   => ps2_clk_io,
                        ps2_data_io  => ps2_data_io);

        stm : process (clk_i, rst)
        begin  -- process stm
                if rst = '0' then       -- asynchronous reset (active low)
                        state      <= reset;
                        data_cnt   <= "00";
                        mouse_data <= (others => '0');
			    data_out   <= (others => '0');
                elsif clk_i'event and clk_i = '1' then  -- rising clock edge
                        case state is
                                when reset => state <= setup0;

                                when setup0 => data_out <= "11110100";  -- F4h - Enable data reporting
                                               state <= setup1;

                                when setup1 => if obf = '0' then
                                                      state <= wait_packet;
                                               end if;

                                when wait_packet => data_cnt <= "00";
                                                    state <= wait_data;

                                when wait_data => if data_cnt = "11" then
                                                          state <= process_data;
                                                  elsif ibf = '1' then
                                                          state <= recv_data;
                                                  elsif ps2_wdt = '1' and
                                                          data_cnt /= "00" then
                                                          state <= wait_packet;
                                                  end if;

                                when recv_data => if data_cnt = "00" then
                                                          mouse_data(7 downto 0) <= data_in;
                                                  elsif data_cnt = "01" then
                                                          mouse_data(15 downto 8) <= data_in;
                                                  elsif data_cnt = "10" then
                                                          mouse_data(23 downto 16) <= data_in;
                                                  end if;
                                                  data_cnt <= data_cnt + 1;
                                                  state <= wait_data;

                                when process_data => state <= wait_packet;

                                when others => null;
                        end case;
                end if;
        end process stm;
        obf_set <= '1' when state = setup0 else '0';
        ibf_clr <= '1' when state = recv_data else '0';
        err_clr <= ps2_wdt;

        data_o <= mouse_data;
        activity_o <= mouse_data(0) or mouse_data(1) or mouse_data(2) or not rst;
        beep_o <= beep_freq and (mouse_data(0) or mouse_data(1) or mouse_data(2));
        perr_o <= parity_err;
        ferr_o <= frame_err;
end rtl;
