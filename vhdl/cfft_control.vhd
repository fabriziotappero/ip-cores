library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_SIGNED.all;

entity cfft_control is
  generic (
    Tx_nRx : natural := 0;              -- tx = 1, rx = 0
    stage  : natural := 3);
  port (
    clk       : in std_logic;
    rst       : in std_logic;
    mem_ready : in std_logic;

    sel_mux       : out std_logic;
    factorstart   : out std_logic;
    cfft4start    : out std_logic;
    inv           : out std_logic;
    Output_enable : out std_logic;
    bank0_busy    : out std_logic;
    bank1_busy    : out std_logic;

    mem_block : out std_logic;

    addrout_in   : out std_logic_vector(stage*2-Tx_nRx downto 0);
    wen_proc     : out std_logic;
    addrin_proc  : out std_logic_vector(stage*2-1 downto 0);
    addrout_proc : out std_logic_vector(stage*2-1 downto 0);
    wen_out      : out std_logic;
    addrin_out   : out std_logic_vector(stage*2-1 downto 0));
end cfft_control;

architecture cfft_control of cfft_control is

  component counter
    generic (
      stage : natural);
    port (
      clk       : in  std_logic;
      rst       : in  std_logic;
      mem_ready : in  std_logic;
      mem_bk    : out std_logic;
      count     : out std_logic_vector(2*stage+2 downto 0));
  end component;

  component ram_control
    generic (
      Tx_nRX : natural;
      stage  : natural);
    port (
      clk          : in  std_logic;
      rst          : in  std_logic;
      Gen_state    : in  std_logic_vector(2*stage+2 downto 0);
      mem_bk       : in  std_logic;
      addrout_in   : out std_logic_vector(stage*2-Tx_nRX downto 0);
      wen_proc     : out std_logic;
      addrin_proc  : out std_logic_vector(stage*2-1 downto 0);
      addrout_proc : out std_logic_vector(stage*2-1 downto 0);
      wen_out      : out std_logic;
      addrin_out   : out std_logic_vector(stage*2-1 downto 0));
  end component;

  component mux_control
    generic (
      stage : natural);
    port (
      clk       : in  std_logic;
      rst       : in  std_logic;
      Gen_state : in  std_logic_vector(8 downto 0);
      sel_mux   : out std_logic);
  end component;

  component starts
    generic (
      stage : natural);
    port (
      clk         : in  std_logic;
      rst         : in  std_logic;
      Gen_state   : in  std_logic_vector(2*stage+2 downto 0);
      factorstart : out std_logic;
      cfft4start  : out std_logic);
  end component;

  component inv_control
    generic (
      stage : natural);
    port (
      clk       : in  std_logic;
      rst       : in  std_logic;
      Gen_state : in  std_logic_vector(2*stage+2 downto 0);
      inv       : out std_logic);
  end component;

  component io_control
    generic (
      stage : natural);
    port (
      clk           : in  std_logic;
      rst           : in  std_logic;
      mem_bk        : in  std_logic;
      Gen_state     : in  std_logic_vector(2*stage+2 downto 0);
      bank0_busy    : out std_logic;
      bank1_busy    : out std_logic;
      Output_enable : out std_logic);
  end component;

  signal count  : std_logic_vector(2*stage+2 downto 0);
  signal mem_bk : std_logic;
begin

  mem_block <= mem_bk;

  counter_1 : counter
    generic map (
      stage => stage)
    port map (
      clk       => clk,
      rst       => rst,
      mem_ready => mem_ready,
      mem_bk    => mem_bk,
      count     => count);

  ram_control_1 : ram_control
    generic map (
      Tx_nRX => Tx_nRX,
      stage  => stage)
    port map (
      clk          => clk,
      rst          => rst,
      Gen_state    => count,
      mem_bk       => mem_bk,
      addrout_in   => addrout_in,
      wen_proc     => wen_proc,
      addrin_proc  => addrin_proc,
      addrout_proc => addrout_proc,
      wen_out      => wen_out,
      addrin_out   => addrin_out);

  mux_control_1 : mux_control
    generic map (
      stage => stage)
    port map (
      clk       => clk,
      rst       => rst,
      Gen_state => count,
      sel_mux   => sel_mux);

  starts_1 : starts
    generic map (
      stage => stage)
    port map (
      clk         => clk,
      rst         => rst,
      Gen_state   => count,
      factorstart => factorstart,
      cfft4start  => cfft4start);

  TX_inv : if Tx_nRx = 1 generate
    inv_control_1 : inv_control
      generic map (
        stage => stage)
      port map (
        clk       => clk,
        rst       => rst,
        Gen_state => count,
        inv       => inv);
  end generate;

  io_control_1 : io_control
    generic map (
      stage => stage)
    port map (
      clk           => clk,
      rst           => rst,
      mem_bk        => mem_bk,
      Gen_state     => count,
      bank0_busy    => bank0_busy,
      bank1_busy    => bank1_busy,
      Output_enable => Output_enable);

end cfft_control;
