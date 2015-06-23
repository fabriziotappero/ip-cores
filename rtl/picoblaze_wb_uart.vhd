--------------------------------------------------------------------------------
-- This sourcecode is released under BSD license.
-- Please see http://www.opensource.org/licenses/bsd-license.php for details!
--------------------------------------------------------------------------------
--
-- Copyright (c) 2010, Stefan Fischer <Ste.Fis@OpenCores.org>
-- All rights reserved.
--
-- Redistribution and use in source and binary forms, with or without 
-- modification, are permitted provided that the following conditions are met:
--
--  * Redistributions of source code must retain the above copyright notice, 
--    this list of conditions and the following disclaimer.
--  * Redistributions in binary form must reproduce the above copyright notice,
--    this list of conditions and the following disclaimer in the documentation
--    and/or other materials provided with the distribution.
--
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
-- AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
-- IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
-- ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE 
-- LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
-- CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
-- SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
-- INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
-- CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
-- ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
-- POSSIBILITY OF SUCH DAMAGE.
--
--------------------------------------------------------------------------------
-- filename: picoblaze_wb_uart.vhd
-- description: synthesizable PicoBlaze (TM) uart example using wishbone
-- todo4user: add other modules as needed
-- version: 0.0.0
-- changelog: - 0.0.0, initial release
--            - ...
--------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;


entity picoblaze_wb_uart is
  port
  (
    p_rst_n_i : in std_logic;
    p_clk_i : in std_logic;
    
    p_uart_rx_si_i : in std_logic;
    p_uart_tx_so_o : out std_logic
  );
end picoblaze_wb_uart;


architecture rtl of picoblaze_wb_uart is

  component kcpsm3 is
    port 
    (
      address : out std_logic_vector(9 downto 0);
      instruction : in std_logic_vector(17 downto 0);
      port_id : out std_logic_vector(7 downto 0);
      write_strobe : out std_logic;
      out_port : out std_logic_vector(7 downto 0);
      read_strobe : out std_logic;
      in_port : in std_logic_vector(7 downto 0);
      interrupt : in std_logic;
      interrupt_ack : out std_logic;
      reset : in std_logic;
      clk : in std_logic
    );
  end component;

  component pbwbuart is
    port 
    (      
      address : in std_logic_vector(9 downto 0);
      instruction : out std_logic_vector(17 downto 0);
      clk : in std_logic
    );
  end component;

  component wbm_picoblaze is
    port
    (
      rst : in std_logic;
      clk : in std_logic;
      
      wbm_cyc_o : out std_logic;
      wbm_stb_o : out std_logic;
      wbm_we_o : out std_logic;
      wbm_adr_o : out std_logic_vector(7 downto 0);
      wbm_dat_m2s_o : out std_logic_vector(7 downto 0);
      wbm_dat_s2m_i : in std_logic_vector(7 downto 0);
      wbm_ack_i : in std_logic;
      
      pb_port_id_i : in std_logic_vector(7 downto 0);
      pb_write_strobe_i : in std_logic;
      pb_out_port_i : in std_logic_vector(7 downto 0);
      pb_read_strobe_i : in std_logic;
      pb_in_port_o : out std_logic_vector(7 downto 0)
    );
  end component;

  component wbs_uart is
    port
    (
      rst : in std_logic;
      clk : in std_logic;
      
      wbs_cyc_i : in std_logic;
      wbs_stb_i : in std_logic;
      wbs_we_i : in std_logic;
      wbs_adr_i : in std_logic_vector(7 downto 0);
      wbs_dat_m2s_i : in std_logic_vector(7 downto 0);
      wbs_dat_s2m_o : out std_logic_vector(7 downto 0);
      wbs_ack_o : out std_logic;
      
      uart_rx_si_i : in std_logic;
      uart_tx_so_o : out std_logic
    );
  end component;

  signal rst : std_logic := '1';
  signal clk : std_logic := '1';
  
  signal wb_cyc : std_logic := '0';
  signal wb_stb : std_logic := '0';
  signal wb_we : std_logic := '0';
  signal wb_adr : std_logic_vector(7 downto 0) := (others => '0');
  signal wb_dat_m2s : std_logic_vector(7 downto 0) := (others => '0');
  signal wb_dat_s2m : std_logic_vector(7 downto 0) := (others => '0');
  signal wb_ack : std_logic := '0';
  
  signal pb_write_strobe : std_logic := '0';
  signal pb_read_strobe : std_logic := '0';
  signal pb_port_id : std_logic_vector(7 downto 0) := (others => '0');
  signal pb_in_port : std_logic_vector(7 downto 0) := (others => '0');
  signal pb_out_port : std_logic_vector(7 downto 0) := (others => '0');
  
  signal instruction : std_logic_vector(17 downto 0) := (others => '0');
  signal address : std_logic_vector(9 downto 0) := (others => '0');
  
  signal interrupt : std_logic := '0';
  signal interrupt_ack : std_logic := '0';
  
begin

  -- reset synchronisation
  process(clk)
  begin
    if rising_edge(clk) then
      rst <= not p_rst_n_i;
    end if;
  end process;
  clk <= p_clk_i;
  
  -- module instances
  -------------------
  
  inst_kcpsm3 : kcpsm3
    port map
    (
      address => address,
      instruction => instruction,
      port_id => pb_port_id,
      write_strobe => pb_write_strobe,
      out_port => pb_out_port,
      read_strobe => pb_read_strobe,
      in_port => pb_in_port,
      interrupt => interrupt,
      interrupt_ack => interrupt_ack,
      reset => rst,
      clk => clk
    );

  inst_pbwbuart : pbwbuart
    port map
    (      
      address => address,
      instruction => instruction,
      clk => clk
    );

  inst_wbm_picoblaze : wbm_picoblaze
    port map
    (
      rst => rst,
      clk => clk,
      
      wbm_cyc_o => wb_cyc,
      wbm_stb_o => wb_stb,
      wbm_we_o => wb_we,
      wbm_adr_o => wb_adr,
      wbm_dat_m2s_o => wb_dat_m2s,
      wbm_dat_s2m_i => wb_dat_s2m,
      wbm_ack_i => wb_ack,
      
      pb_port_id_i => pb_port_id,
      pb_write_strobe_i => pb_write_strobe,
      pb_out_port_i => pb_out_port,
      pb_read_strobe_i => pb_read_strobe,
      pb_in_port_o => pb_in_port
    );

  inst_wbs_uart : wbs_uart
    port map
    (
      rst => rst,
      clk => clk,
      
      wbs_cyc_i => wb_cyc,
      wbs_stb_i => wb_stb,
      wbs_we_i => wb_we,
      wbs_adr_i => wb_adr,
      wbs_dat_m2s_i => wb_dat_m2s,
      wbs_dat_s2m_o => wb_dat_s2m,
      wbs_ack_o => wb_ack,
      
      uart_rx_si_i => p_uart_rx_si_i,
      uart_tx_so_o => p_uart_tx_so_o
    );
  
end rtl;
