-------------------------------------------------------------------------------
-- Title      : Testbench for design "shift_register"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : shift_register_tb.vhd
-- Author     : 
-- Company    : 
-- Created    : 2007-08-24
-- Last update: 2007-11-12
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2007 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2007-08-24  1.0      d.koethe        Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

library work;
use work.opb_spi_slave_pack.all;

-------------------------------------------------------------------------------

entity shift_register_tb is

end shift_register_tb;

-------------------------------------------------------------------------------

architecture behavior of shift_register_tb is

  component shift_register
    generic (
      C_SR_WIDTH  : integer;
      C_MSB_FIRST : boolean;
      C_CPOL      : integer range 0 to 1;
      C_PHA       : integer range 0 to 1);
    port (
      rst         : in  std_logic;
      opb_ctl_reg : in  std_logic_vector(C_OPB_CTL_REG_WIDTH-1 downto 0);
      sclk        : in  std_logic;
      ss_n        : in  std_logic;
      mosi        : in  std_logic;
      miso_o      : out std_logic;
      miso_i      : in  std_logic;
      miso_t      : out std_logic;
      sr_tx_clk   : out std_logic;
      sr_tx_en    : out std_logic;
      sr_tx_data  : in  std_logic_vector(C_SR_WIDTH-1 downto 0);
      sr_rx_clk   : out std_logic;
      sr_rx_en    : out std_logic;
      sr_rx_data  : out std_logic_vector(C_SR_WIDTH-1 downto 0));
  end component;
  

  component tx_fifo_emu
    generic (
      C_SR_WIDTH     : integer;
      C_TX_CMP_VALUE : integer);
    port (
      rst     : in  std_logic;
      tx_clk  : in  std_logic;
      tx_en   : in  std_logic;
      tx_data : out std_logic_vector(C_SR_WIDTH-1 downto 0));
  end component;

  component rx_fifo_emu
    generic (
      C_SR_WIDTH     : integer;
      C_RX_CMP_VALUE : integer);
    port (
      rst     : in std_logic;
      rx_clk  : in std_logic;
      rx_en   : in std_logic;
      rx_data : in std_logic_vector(C_SR_WIDTH-1 downto 0));
  end component;


  constant C_NUM_TESTS : integer := 3;

  -- component generics
  constant C_SR_WIDTH  : integer       := 8;
  type C_MSB_FIRST_t is array (0 to C_NUM_TESTS) of boolean;
  constant C_MSB_FIRST : C_MSB_FIRST_t := (true, false, true, false);
  type C_CPOL_t is array (0 to C_NUM_TESTS) of integer range 0 to 1;
  constant C_CPOL      : C_CPOL_t      := (0, 0, 1, 1);
  type C_PHA_t is array (0 to C_NUM_TESTS) of integer range 0 to 1;
  constant C_PHA       : C_PHA_t       := (0, 0, 0, 0);

  constant clk_period : time := 40 ns;

  type sig_std_logic_t is array (0 to C_NUM_TESTS) of std_logic;
  type sig_std_logic_vector_t is array (0 to C_NUM_TESTS) of std_logic_vector(C_SR_WIDTH-1 downto 0);

  type C_SCLK_INIT_t is array (0 to C_NUM_TESTS) of std_logic;
  constant C_SCLK_INIT : C_SCLK_INIT_t := ('0', '0', '1', '1');

  signal TEST_NUM : integer := 0;

  -- component ports
  signal rst     : sig_std_logic_t;
  signal sclk    : sig_std_logic_t;
  signal cs_n    : sig_std_logic_t;
  signal mosi    : sig_std_logic_t;
  signal miso_o  : sig_std_logic_t;
  signal miso_i  : sig_std_logic_t;
  signal miso_t  : sig_std_logic_t;
  signal tx_clk  : sig_std_logic_t;
  signal tx_en   : sig_std_logic_t;
  signal tx_data : sig_std_logic_vector_t;
  signal rx_clk  : sig_std_logic_t;
  signal rx_en   : sig_std_logic_t;
  signal rx_data : sig_std_logic_vector_t;

  -- component ports
  signal s_rst     : std_logic;
  signal s_sclk    : std_logic;
  signal s_cs_n    : std_logic;
  signal s_mosi    : std_logic;
  signal s_miso_o  : std_logic;
  signal s_miso_i  : std_logic;
  signal s_miso_t  : std_logic;
  signal s_tx_clk  : std_logic;
  signal s_tx_en   : std_logic;
  signal s_tx_data : std_logic_vector(C_SR_WIDTH-1 downto 0);
  signal s_rx_clk  : std_logic;
  signal s_rx_en   : std_logic;
  signal s_rx_data : std_logic_vector(C_SR_WIDTH-1 downto 0);

  -- testbench
  constant C_TX_CMP_VALUE : integer := 130;
  constant C_RX_CMP_VALUE : integer := 129;

  signal rx_master : std_logic_vector(7 downto 0);

  signal opb_ctl_reg: std_logic_vector(C_OPB_CTL_REG_WIDTH-1 downto 0);
  
begin  -- behavior

  opb_ctl_reg <= "0111";                -- enable all
  
  s_rst     <= rst(TEST_NUM);
  s_sclk    <= sclk(TEST_NUM);
  s_cs_n    <= cs_n(TEST_NUM);
  s_mosi    <= mosi(TEST_NUM);
  s_miso_o  <= miso_o(TEST_NUM);
  s_miso_i  <= miso_i(TEST_NUM);
  s_miso_t  <= miso_t(TEST_NUM);
  s_tx_clk  <= tx_clk(TEST_NUM);
  s_tx_en   <= tx_en(TEST_NUM);
  s_tx_data <= tx_data(TEST_NUM);
  s_rx_clk  <= rx_clk(TEST_NUM);
  s_rx_en   <= rx_en(TEST_NUM);
  s_rx_data <= rx_data(TEST_NUM);


  -- component instantiation

  i : for i in 0 to 3 generate
    DUT : shift_register
      generic map (
        C_SR_WIDTH  => C_SR_WIDTH,
        C_MSB_FIRST => C_MSB_FIRST(i),
        C_CPOL      => C_CPOL(i),
        C_PHA       => C_PHA(i))
      port map (
        rst     => rst(i),
        opb_ctl_reg => opb_ctl_reg,
        sclk    => sclk(i),
        ss_n    => cs_n(i),
        mosi    => mosi(i),
        miso_o  => miso_o(i),
        miso_i  => miso_i(i),
        miso_t  => miso_t(i),
        sr_tx_clk  => tx_clk(i),
        sr_tx_en   => tx_en(i),
        sr_tx_data => tx_data(i),
        sr_rx_clk  => rx_clk(i),
        sr_rx_en   => rx_en(i),
        sr_rx_data => rx_data(i));  



    tx_fifo_emu_1 : tx_fifo_emu
      generic map (
        C_SR_WIDTH     => C_SR_WIDTH,
        C_TX_CMP_VALUE => C_TX_CMP_VALUE)
      port map (
        rst     => rst(i),
        tx_clk  => tx_clk(i),
        tx_en   => tx_en(i),
        tx_data => tx_data(i));


    rx_fifo_emu_1 : rx_fifo_emu
      generic map (
        C_SR_WIDTH     => C_SR_WIDTH,
        C_RX_CMP_VALUE => C_RX_CMP_VALUE)
      port map (
        rst     => rst(i),
        rx_clk  => rx_clk(i),
        rx_en   => rx_en(i),
        rx_data => rx_data(i));
  end generate i;


  -- waveform generation
  WaveGen_Proc : process
    variable rx_value : std_logic_vector(7 downto 0);
    variable tx_value : std_logic_vector(7 downto 0);
  begin
    for i in 0 to C_NUM_TESTS loop
      sclk(i)   <= C_SCLK_INIT(i);
      cs_n(i)   <= '1';
      mosi(i)   <= 'Z';
      miso_i(i) <= 'Z';
      -- rst_active
      rst(i)    <= '1';
    end loop;  -- i
-------------------------------------------------------------------------------
    -- Actual Tests
    TEST_NUM      <= 0;
    rx_value      := conv_std_logic_vector(C_RX_CMP_VALUE, 8);
    tx_value      := conv_std_logic_vector(C_TX_CMP_VALUE, 8);
    wait for 100 ns;
    rst(TEST_NUM) <= '0';

    -- CPHA=0 CPOL=0 C_MSB_FIRST=TRUE
    cs_n(TEST_NUM) <= '0';
    for i in 7 downto 0 loop
      mosi(TEST_NUM) <= rx_value(i);
      wait for clk_period/2;
      sclk(TEST_NUM) <= '1';
      rx_master(i)   <= miso_o(TEST_NUM);
      wait for clk_period/2;
      sclk(TEST_NUM) <= '0';
    end loop;  -- i
    mosi(TEST_NUM) <= 'Z';
    wait for clk_period/2;
    cs_n(TEST_NUM) <= '1';
    wait for 100 ns;
    assert (rx_master = tx_value) report "Master Receive Failure" severity warning;


    -- write 2 byte
    cs_n(TEST_NUM) <= '0';
    for n in 1 to 2 loop
      rx_value := rx_value +1;
      tx_value := tx_value +1;
      for i in 7 downto 0 loop
        mosi(TEST_NUM) <= rx_value(i);
        wait for clk_period/2;
        sclk(TEST_NUM) <= '1';
        rx_master(i)   <= miso_o(TEST_NUM);
        wait for clk_period/2;
        sclk(TEST_NUM) <= '0';
      end loop;  -- i
      assert (rx_master = tx_value) report "Master Receive Failure" severity warning;
    end loop;  -- n
    mosi(TEST_NUM) <= 'Z';
    wait for clk_period/2;
    cs_n(TEST_NUM) <= '1';
---------------------------------------------------------------------------
    -- Actual Tests
    TEST_NUM       <= 1;
    rx_value       := conv_std_logic_vector(C_RX_CMP_VALUE, 8);
    tx_value       := conv_std_logic_vector(C_TX_CMP_VALUE, 8);
    wait for 100 ns;
    rst(TEST_NUM)  <= '0';

    -- CPHA=0 CPOL=0 C_MSB_FIRST=FALSE
    cs_n(TEST_NUM) <= '0';
    for i in 0 to 7 loop
      mosi(TEST_NUM) <= rx_value(i);
      wait for clk_period/2;
      sclk(TEST_NUM) <= '1';
      rx_master(i)   <= miso_o(TEST_NUM);
      wait for clk_period/2;
      sclk(TEST_NUM) <= '0';
    end loop;  -- i
    mosi(TEST_NUM) <= 'Z';
    wait for clk_period/2;
    cs_n(TEST_NUM) <= '1';
    wait for 100 ns;
    assert (rx_master = tx_value) report "Master Receive Failure" severity warning;


    -- write 2 byte
    cs_n(TEST_NUM) <= '0';
    for n in 1 to 2 loop
      rx_value := rx_value +1;
      tx_value := tx_value +1;
      for i in 0 to 7 loop
        mosi(TEST_NUM) <= rx_value(i);
        wait for clk_period/2;
        sclk(TEST_NUM) <= '1';
        rx_master(i)   <= miso_o(TEST_NUM);
        wait for clk_period/2;
        sclk(TEST_NUM) <= '0';
      end loop;  -- i
      assert (rx_master = tx_value) report "Master Receive Failure" severity warning;
    end loop;  -- n
    mosi(TEST_NUM) <= 'Z';
    wait for clk_period/2;
    cs_n(TEST_NUM) <= '1';

-------------------------------------------------------------------------------
    TEST_NUM      <= 2;
    rx_value      := conv_std_logic_vector(C_RX_CMP_VALUE, 8);
    tx_value      := conv_std_logic_vector(C_TX_CMP_VALUE, 8);
    wait for 100 ns;
    rst(TEST_NUM) <= '0';

    -- CPHA=0 CPOL=1 C_MSB_FIRST=TRUE
    cs_n(TEST_NUM) <= '0';
    for i in 7 downto 0 loop
      mosi(TEST_NUM) <= rx_value(i);
      wait for clk_period/2;
      sclk(TEST_NUM) <= '0';
      wait for clk_period/2;
      sclk(TEST_NUM) <= '1';
    end loop;  -- i
    mosi(TEST_NUM) <= 'Z';
    wait for clk_period/2;
    cs_n(TEST_NUM) <= '1';
    wait for 100 ns;

    -- write 2 byte
    cs_n(TEST_NUM) <= '0';
    for n in 1 to 2 loop
      rx_value := rx_value +1;
      for i in 7 downto 0 loop
        mosi(TEST_NUM) <= rx_value(i);
        wait for clk_period/2;
        sclk(TEST_NUM) <= '0';
        wait for clk_period/2;
        sclk(TEST_NUM) <= '1';
      end loop;  -- i
    end loop;  -- n
    mosi(TEST_NUM) <= 'Z';
    wait for clk_period/2;
    cs_n(TEST_NUM) <= '1';

-------------------------------------------------------------------------------
    TEST_NUM      <= 3;
    rx_value      := conv_std_logic_vector(C_RX_CMP_VALUE, 8);
    tx_value      := conv_std_logic_vector(C_TX_CMP_VALUE, 8);
    wait for 100 ns;
    rst(TEST_NUM) <= '0';

    -- CPHA=0 CPOL=1 C_MSB_FIRST=FALSE
    cs_n(TEST_NUM) <= '0';
    for i in 0 to 7 loop
      mosi(TEST_NUM) <= rx_value(i);
      wait for clk_period/2;
      sclk(TEST_NUM) <= '0';
      wait for clk_period/2;
      sclk(TEST_NUM) <= '1';
    end loop;  -- i
    mosi(TEST_NUM) <= 'Z';
    wait for clk_period/2;
    cs_n(TEST_NUM) <= '1';
    wait for 100 ns;

    -- write 2 byte
    cs_n(TEST_NUM) <= '0';
    for n in 1 to 2 loop
      rx_value := rx_value +1;
      for i in 0 to 7 loop
        mosi(TEST_NUM) <= rx_value(i);
        wait for clk_period/2;
        sclk(TEST_NUM) <= '0';
        wait for clk_period/2;
        sclk(TEST_NUM) <= '1';
      end loop;  -- i
    end loop;  -- n
    mosi(TEST_NUM) <= 'Z';
    wait for clk_period/2;
    cs_n(TEST_NUM) <= '1';

-------------------------------------------------------------------------------    


    wait for 1 us;

    assert false report "Simulation sucessful" severity failure;
    
    

  end process WaveGen_Proc;

  

end behavior;

-------------------------------------------------------------------------------

configuration shift_register_tb_behavior_cfg of shift_register_tb is
  for behavior
  end for;
end shift_register_tb_behavior_cfg;

-------------------------------------------------------------------------------
