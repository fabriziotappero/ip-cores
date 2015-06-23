-------------------------------------------------------------------------------
-- Title      : PS/2 interface Testbench
-- Project    :
-------------------------------------------------------------------------------
-- File       : ps2.vhd
-- Author     : Daniel Quintero <danielqg@infonegocio.com>
-- Company    : Itoo Software
-- Created    : 2003-04-14
-- Last update: 2003-10-30
-- Platform   : VHDL'87
-------------------------------------------------------------------------------
-- Description: PS/2 generic UART for mice/keyboard, Wishbone Testbench
-------------------------------------------------------------------------------
--  This code is distributed under the terms and conditions of the
--  GNU General Public License
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2003-04-14  1.0      daniel  Created
-------------------------------------------------------------------------------

library ieee, work;
use ieee.std_logic_1164.all;
use work.wb_test.all;

entity wb_ps2_tb is
  -- Generic declarations of the tested unit
  generic(
    addr_width : positive := 1;
    bus_width  : positive := 8);
end wb_ps2_tb;


architecture sim of wb_ps2_tb is
  -- Component declaration of the tested unit
  component ps2_wb
    port (
      wb_clk_i : in    std_logic;
      wb_rst_i : in    std_logic;
      wb_dat_i : in    std_logic_vector(7 downto 0);
      wb_dat_o : out   std_logic_vector(7 downto 0);
      wb_adr_i : in    std_logic_vector(0 downto 0);
      wb_stb_i : in    std_logic;
      wb_we_i  : in    std_logic;
      wb_ack_o : out   std_logic;
      irq_o    : out   std_logic;
      ps2_clk  : inout std_logic;
      ps2_dat  : inout std_logic);
  end component;


  component ps2mouse
    port (
      PS2_clk  : inout std_logic;
      PS2_data : inout std_logic);
  end component;



  signal adr_i : std_logic_vector (addr_width-1 downto 0) := (others => '0');
  -- Stimulus signals - signals mapped to the input and inout ports of tested entity
  signal clk_i : std_logic                                := '0';
  signal rst_i : std_logic                                := '0';
  signal cyc_i : std_logic;
  signal stb_i : std_logic;
  signal we_i  : std_logic;
  signal dat_i : std_logic_vector((bus_width-1) downto 0);

  -- Observed signals - signals mapped to the output ports of tested entity
  signal ack_o   : std_logic;
  signal dat_o   : std_logic_vector((bus_width-1) downto 0);
  signal irq_o   : std_logic;
  signal ps2_clk : std_logic;
  signal ps2_dat : std_logic;

  signal done : boolean := false;

  -- Add your code here ...

begin
  -- Unit Under Test port map
  ps2_wb_1 : ps2_wb
    port map (
      wb_clk_i => clk_i,
      wb_rst_i => rst_i,
      wb_dat_i => dat_i,
      wb_dat_o => dat_o,
      wb_adr_i => adr_i,
      wb_stb_i => stb_i,
      wb_we_i  => we_i,
      wb_ack_o => ack_o,
      irq_o    => irq_o,
      ps2_clk  => ps2_clk,
      ps2_dat  => ps2_dat);

  ps2mouse_1 : ps2mouse
    port map (
      PS2_clk  => ps2_clk,
      PS2_data => ps2_dat);

  clk : process is
  begin
    while not done loop
      clk_i <= not clk_i;
      wait for 25 ns;                   -- 20Mhz clock
    end loop;
    wait;
  end process;

  reset : process is
  begin
    rst_i <= '1';
    wait for 150 ns;
    rst_i <= '0';
    wait;
  end process;

  master : process is
    variable status : std_logic_vector(7 downto 0);
  begin
    we_i  <= '0';
    cyc_i <= '0';
    stb_i <= '0';
    adr_i <= (others => '0');
    dat_i <= (others => '0');
    wait until clk_i'event and clk_i = '1';
    wait until clk_i'event and clk_i = '1';
    wait until clk_i'event and clk_i = '1';
    wait until clk_i'event and clk_i = '1';
    wait until clk_i'event and clk_i = '1';
    wait until clk_i'event and clk_i = '1';
    wait until clk_i'event and clk_i = '1';

    -- Check control register, interrupt status bits
    wr_chk_val (clk_i, adr_i, dat_o, dat_i, we_i, cyc_i, stb_i, ack_o, "1","11000000");
    wr_chk_val (clk_i, adr_i, dat_o, dat_i, we_i, cyc_i, stb_i, ack_o, "1","10000000");
    wr_chk_val (clk_i, adr_i, dat_o, dat_i, we_i, cyc_i, stb_i, ack_o, "1","01000000");
    wr_chk_val (clk_i, adr_i, dat_o, dat_i, we_i, cyc_i, stb_i, ack_o, "1","00000000");

    -- Check for transmit
    wr_val (clk_i, adr_i, dat_o, dat_i, we_i, cyc_i, stb_i, ack_o, "1","11000000");
    wr_val (clk_i, adr_i, dat_o, dat_i, we_i, cyc_i, stb_i, ack_o, "0","01010101");

    -- wait for end of transmit
    status := (others => '1');
    while status(0) = '1' loop
      rd_val (clk_i, adr_i, dat_o, dat_i, we_i, cyc_i, stb_i, ack_o, "1",status);
    end loop;

    -- wait for receive data
    while status(1) = '0' loop
      rd_val (clk_i, adr_i, dat_o, dat_i, we_i, cyc_i, stb_i, ack_o, "1",status);
    end loop;

    -- Get data
    rd_val (clk_i, adr_i, dat_o, dat_i, we_i, cyc_i, stb_i, ack_o, "1",status);

    -- Clear flag
    wr_val (clk_i, adr_i, dat_o, dat_i, we_i, cyc_i, stb_i, ack_o, "1","11000000");


    done <= true;
  end process;
end sim;

