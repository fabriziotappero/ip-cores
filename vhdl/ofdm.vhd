library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity ofdm is
  generic (
    Tx_nRx : natural := 1;
    WIDTH : natural := 12;
    POINT : natural := 64;
    STAGE : natural := 3               -- STAGE=log4(POINT)
    );
  port (
    clk       : in std_logic;
    rst       : in std_logic;
    mem_ready : in std_logic;
    Iin  : in  std_logic_vector(WIDTH-1 downto 0);
    Qin  : in  std_logic_vector(WIDTH-1 downto 0);
    Iout : out std_logic_vector(WIDTH+1 downto 0);
    Qout : out std_logic_vector(WIDTH+1 downto 0);
    mem_block    : out std_logic;
    Output_enable : out std_logic;    
    bank0_busy : out std_logic;
    bank1_busy : out std_logic;
    wen_in    : in std_logic;
    addrin_in : in std_logic_vector(2*stage-Tx_nRX downto 0);
    addrout_out : in std_logic_vector(2*stage-1 downto 0));

end ofdm;

architecture ofdm of ofdm is

  component cfft_control
    generic (
      Tx_nRx : natural;
      stage : natural);
    port (
      clk          : in  std_logic;
      rst          : in  std_logic;
      mem_ready    : in  std_logic;
      sel_mux      : out std_logic;
      factorstart  : out std_logic;
      cfft4start   : out std_logic;
      inv          : out std_logic;
      Output_enable : out std_logic;      
      bank0_busy : out std_logic;
      bank1_busy : out std_logic;
      mem_block    : out std_logic;
      addrout_in   : out std_logic_vector(stage*2-Tx_nRX downto 0);
      wen_proc     : out std_logic;
      addrin_proc  : out std_logic_vector(stage*2-1 downto 0);
      addrout_proc : out std_logic_vector(stage*2-1 downto 0);
      wen_out      : out std_logic;
      addrin_out   : out std_logic_vector(stage*2-1 downto 0));
  end component;

  component cfft
    generic (
      Tx_nRx : natural;
      WIDTH : natural;
      POINT : natural;
      STAGE : natural);
    port (
      rst          : in  std_logic;
      Iin          : in  std_logic_vector(WIDTH-1 downto 0);
      Qin          : in  std_logic_vector(WIDTH-1 downto 0);
      Iout         : out std_logic_vector(WIDTH+1 downto 0);
      Qout         : out std_logic_vector(WIDTH+1 downto 0);
      factorstart  : in  std_logic;
      cfft4start   : in  std_logic;
      ClkIn        : in  std_logic;
      sel_mux      : in  std_logic;
      inv          : in  std_logic;
      wen_in       : in  std_logic;
      addrin_in    : in  std_logic_vector(2*stage-Tx_nRx downto 0);
      addrout_in   : in  std_logic_vector(2*stage-Tx_nRx downto 0);
      wen_proc     : in  std_logic;
      addrin_proc  : in  std_logic_vector(2*stage-1 downto 0);
      addrout_proc : in  std_logic_vector(2*stage-1 downto 0);
      wen_out      : in  std_logic;
      addrin_out   : in  std_logic_vector(2*stage-1 downto 0);
      addrout_out  : in  std_logic_vector(2*stage-1 downto 0));
  end component;

  signal sel_mux      : std_logic;
  signal factorstart  : std_logic;
  signal cfft4start   : std_logic;
  signal inv          : std_logic;
  signal addrout_in   : std_logic_vector(stage*2-Tx_nRx downto 0);
  signal wen_proc     : std_logic;
  signal addrin_proc  : std_logic_vector(stage*2-1 downto 0);
  signal addrout_proc : std_logic_vector(stage*2-1 downto 0);
  signal wen_out      : std_logic;
  signal addrin_out   : std_logic_vector(stage*2-1 downto 0);
  
begin

  cfft_control_1 : cfft_control
    generic map (
      Tx_nRx => Tx_nRx,
      stage => stage)
    port map (
      clk          => clk,
      rst          => rst,
      mem_ready    => mem_ready,
      sel_mux      => sel_mux,
      factorstart  => factorstart,
      cfft4start   => cfft4start,
      inv          => inv,
      Output_enable => Output_enable,     
		bank0_busy    => bank0_busy,
		bank1_busy    => bank1_busy,
      mem_block    => mem_block,
      addrout_in   => addrout_in,
      wen_proc     => wen_proc,
      addrin_proc  => addrin_proc,
      addrout_proc => addrout_proc,
      wen_out      => wen_out,
      addrin_out   => addrin_out);

  cfft_1 : cfft
    generic map (
      Tx_nRx => Tx_nRx,
      WIDTH => WIDTH,
      POINT => POINT,
      STAGE => STAGE)
    port map (
      rst          => rst,
      Iin          => Iin,
      Qin          => Qin,
      Iout         => Iout,
      Qout         => Qout,
      factorstart  => factorstart,
      cfft4start   => cfft4start,
      ClkIn        => Clk,
      sel_mux      => sel_mux,
      inv          => inv,
      wen_in       => wen_in,
      addrin_in    => addrin_in,
      addrout_in   => addrout_in,
      wen_proc     => wen_proc,
      addrin_proc  => addrin_proc,
      addrout_proc => addrout_proc,
      wen_out      => wen_out,
      addrin_out   => addrin_out,
      addrout_out  => addrout_out);
end ofdm;
