library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
--library UNISIM;
--use UNISIM.VComponents.all;

entity rxmodem is
    Port ( clk : in std_logic;
            rst : in std_logic;
            mem_ready     : in  std_logic;
            Iin           : in  std_logic_vector(11 downto 0);
            mem_block     : out std_logic;
            wen           : in  std_logic;
            addrin_in     : in  std_logic_vector(6 downto 0);
            txserial : out std_logic
        );
end rxmodem;

architecture rxmodem of rxmodem is

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
      --Qin           : in  std_logic_vector(WIDTH-1 downto 0);
      Iout          : out std_logic_vector(WIDTH+1 downto 0);
      Qout          : out std_logic_vector(WIDTH+1 downto 0);
      mem_block     : out std_logic;
      Output_enable : out std_logic;
      --bank0_busy    : out std_logic;
      --bank1_busy    : out std_logic;
      wen_in        : in  std_logic;
      addrin_in     : in  std_logic_vector(2*stage-Tx_nRX downto 0);
      addrout_out   : in  std_logic_vector(2*stage-1 downto 0));
  end component;

component output
    Port ( clk : in std_logic;
           rst : in std_logic;
           Iout          : in std_logic_vector(13 downto 0);
           Qout          : in std_logic_vector(13 downto 0);
           Output_enable : in std_logic;
           addrout_out   : out  std_logic_vector(5 downto 0);
           txserial : out std_logic
           );
end component;

signal Iout        : std_logic_vector(13 downto 0);
signal Qout        : std_logic_vector(13 downto 0);
signal Output_enable : std_logic;
signal addrout_out : std_logic_vector(5 downto 0);

begin
  ofdm_1: ofdm
    generic map (
      Tx_nRx => 0,
      WIDTH  => 12,
      POINT  => 64,
      STAGE  => 3)
    port map (
         clk           => clk,
         rst           => rst,
         mem_ready     => mem_ready,
         Iin           => Iin,
         --Qin           => (others => '0'),
         Iout          => Iout,  --tratado
         Qout          => Qout,  --tratado
         mem_block     => mem_block,
         Output_enable => Output_enable,  --tratado
         wen_in        => wen,
         addrin_in     => addrin_in,
         addrout_out   => addrout_out);  --tratado

 output_1: output
    Port map (
           clk           => clk          ,
           rst           => rst          ,
           Iout          => Iout         ,
           Qout          => Qout         ,
           Output_enable => Output_enable,
           addrout_out   => addrout_out  ,
           txserial      => txserial     
           );


end rxmodem;
