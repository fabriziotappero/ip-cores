--------------------------------------------------------------------------------
-- This sourcecode is released under BSD license.
-- Please see http://www.opensource.org/licenses/bsd-license.php for details!
--------------------------------------------------------------------------------
--
-- Copyright (c) 2011, Stefan Fischer <Ste.Fis@OpenCores.org>
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
-- filename: avnet_sp3a_eval_uart_vhd.vhd
-- description: synthesizable PicoBlaze (TM) uart example using wishbone / 
--              AVNET (R) Sp3A-Eval-Kit version
-- todo4user: add other modules as needed
-- version: 0.0.0
-- changelog: - 0.0.0, initial release
--            - ...
--------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;


entity avnet_sp3a_eval_uart_vhd is
  port
  (
    FPGA_RESET : in std_logic;
    CLK_16MHZ : in std_logic;
    
    UART_TXD : in std_logic;
    UART_RXD : out std_logic;
    
    LED1 : out std_logic
  );
end avnet_sp3a_eval_uart_vhd;


architecture rtl of avnet_sp3a_eval_uart_vhd is

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

  signal timer : unsigned(23 downto 0) := (others => '0');

  signal dcm_locked : std_logic := '0';
  
begin

  -- 50 mhz clock generation
  DCM_SP_INST : DCM_SP
    generic map 
    ( 
      CLK_FEEDBACK => "NONE",
      CLKDV_DIVIDE => 2.0,
      CLKFX_DIVIDE => 8,
      CLKFX_MULTIPLY => 25,
      CLKIN_DIVIDE_BY_2 => FALSE,
      CLKIN_PERIOD => 62.500,
      CLKOUT_PHASE_SHIFT => "NONE",
      DESKEW_ADJUST => "SYSTEM_SYNCHRONOUS",
      DFS_FREQUENCY_MODE => "LOW",
      DLL_FREQUENCY_MODE => "LOW",
      DUTY_CYCLE_CORRECTION => TRUE,
      FACTORY_JF => x"C080",
      PHASE_SHIFT => 0,
      STARTUP_WAIT => FALSE
    )
    port map 
    (
      CLKFB => '0',
      CLKIN => CLK_16MHZ,
      DSSEN => '0',
      PSCLK => '0',
      PSEN => '0',
      PSINCDEC => '0',
      RST => FPGA_RESET,
      CLKDV => open,
      CLKFX => clk,
      CLKFX180 => open,
      CLK0 => open,
      CLK2X => open,
      CLK2X180 => open,
      CLK90 => open,
      CLK180 => open,
      CLK270 => open,
      LOCKED => dcm_locked,
      PSDONE => open,
      STATUS => open
    );

  -- reset synchronisation
  process(dcm_locked, clk)
  begin
    if dcm_locked = '0' then
      rst <= '1';
    elsif rising_edge(clk) then
      rst <= not dcm_locked;
    end if;
  end process;
   
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
      
      uart_rx_si_i => UART_TXD,
      uart_tx_so_o => UART_RXD
    );
    
  LED1 <= timer(23);
  
  led_blinker : process(clk)
  begin
    if rising_edge(clk) then
      timer <= timer + 1;
      if rst = '1' then
        timer <= (others => '0');
      end if;
    end if;
  end process;
  
end rtl;