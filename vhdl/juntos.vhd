library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
--library UNISIM;
--use UNISIM.VComponents.all;

entity juntos is
  port(
    clk : in  std_logic;
    rst : in  std_logic;
    rx  : in  std_logic;
    tx  : out std_logic);

    end juntos;

    architecture Behavioral of juntos is

      component parallel
        port (
          clk    : in  std_logic;
          rst    : in  std_logic;
          input  : in  std_logic;
          output : out std_logic_vector(1 downto 0));
      end component;

      component qam
        port (
          clk   : in  std_logic;
          rst   : in  std_logic;
          input : in  std_logic_vector(1 downto 0);
          Iout  : out std_logic_vector(11 downto 0);
          Qout  : out std_logic_vector(11 downto 0));
      end component;

      component qamdecoder
        port (
          clk    : in  std_logic;
          rst    : in  std_logic;
          Iin    : in  std_logic_vector(11 downto 0);
          Qin    : in  std_logic_vector(11 downto 0);
          output : out std_logic_vector(1 downto 0));
      end component;

      component serial
        port (
          clk    : in  std_logic;
          rst    : in  std_logic;
          input  : in  std_logic_vector(1 downto 0);
          output : out std_logic);
      end component;

      signal input : std_logic_vector(1 downto 0);
      signal output : std_logic_vector(1 downto 0);  
      signal Iin    :   std_logic_vector(11 downto 0);
      signal Qin    :   std_logic_vector(11 downto 0);  

    begin
      par_input : parallel
        port map(
          clk    => clk,
          rst    => rst,
          input  => rx,
          output => input);

      qam_1 : qam
        port map (
          clk   => clk,
          rst   => rst,
          input => input,
          Iout  => Iin,
          Qout  => Qin);


      qamdecoder_1: qamdecoder
        port map (
          clk    => clk,
          rst    => rst,
          Iin    => Iin,
          Qin    => Qin,
          output => output);

      serial_1: serial
        port map (
          clk    => clk,
          rst    => rst,
          input  => output,
          output => tx);
      
    end Behavioral;
