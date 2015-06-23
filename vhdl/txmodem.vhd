library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
--library UNISIM;
--use UNISIM.VComponents.all;

entity txmodem is
  port ( clk           : in  std_logic;
         rst           : in  std_logic;
         serial        : in  std_logic;
         Iout          : out std_logic_vector(13 downto 0);
         Output_enable : out std_logic;
         addrout_out   : in  std_logic_vector(5 downto 0)
         );
end txmodem;

architecture txmodem of txmodem is

  component input
    port (
      clk       : in  std_logic;
      rst       : in  std_logic;
      serial    : in  std_logic;
      mem_block : in  std_logic;
      mem_ready : out std_logic;
      wen       : out std_logic;
      address   : out std_logic_vector (5 downto 0);
      i         : out std_logic_vector(11 downto 0);
      q         : out std_logic_vector(11 downto 0)
      );
  end component;

  component ofdm
    generic (
      Tx_nRx : natural;
      WIDTH  : natural;
      POINT  : natural;
      STAGE  : natural);
    port (
      clk           : in  std_logic;
      rst           : in  std_logic;
      mem_ready     : in  std_logic;
      Iin           : in  std_logic_vector(WIDTH-1 downto 0);
      Qin           : in  std_logic_vector(WIDTH-1 downto 0);
      Iout          : out std_logic_vector(WIDTH+1 downto 0);
      Qout          : out std_logic_vector(WIDTH+1 downto 0);
      mem_block     : out std_logic;
      Output_enable : out std_logic;
      bank0_busy    : out std_logic;
      bank1_busy    : out std_logic;
      wen_in        : in  std_logic;
      addrin_in     : in  std_logic_vector(2*stage-Tx_nRX downto 0);
      addrout_out   : in  std_logic_vector(2*stage-1 downto 0));
  end component;

  signal mem_block : std_logic;
  signal mem_ready : std_logic;
  signal wen       : std_logic;
  signal address   : std_logic_vector (5 downto 0);
  signal i         : std_logic_vector(11 downto 0);
  signal q         : std_logic_vector(11 downto 0);
  
begin
  input_1 : input
    port map (
      clk       => clk,
      rst       => rst,
      serial    => serial,
      mem_block => mem_block,
      mem_ready => mem_ready,
      wen       => wen,
      address   => address,
      i         => i,
      q         => q
      );


  ofdm_1 : ofdm
    generic map (
      Tx_nRx => 1,
      WIDTH  => 12,
      POINT  => 64,
      STAGE  => 3)
    port map (
      clk           => clk,
      rst           => rst,
      mem_ready     => mem_ready,
      Iin           => I,
      Qin           => Q,
      Iout          => Iout,
      Qout          => open,
      mem_block     => mem_block,
      Output_enable => Output_enable,
      bank0_busy    => open,
      bank1_busy    => open,
      wen_in        => wen,
      addrin_in     => address,
      addrout_out   => addrout_out);

end txmodem;
