library ieee;
use ieee.std_logic_1164.all;

use work.cryptopan.all;


entity sbsr_tb is
  
end sbsr_tb;


architecture tb of sbsr_tb is
  
  component subbytesshiftrows
    port (
      bytes_in  : in  s_vector;
      bytes_out : out s_vector;
      clk       : in  std_logic;
      reset     : in  std_logic);
  end component;

  component mixcolumns
    port (
      bytes_in  : in  s_vector;
      bytes_out : out s_vector;
      clk       : in  std_logic;
      reset     : in  std_logic);
  end component;
  
  signal clk : std_logic;
  signal reset : std_logic;

  signal bytes_in : s_vector;
  signal bytes_out : s_vector;
  signal mix_bytes_out : s_vector;
  
begin  -- tb

  CLKGEN: process
  begin  -- process CLKGEN
    clk <= '1';
    wait for 5 ns;
    clk <= '0';
    wait for 5 ns;
  end process CLKGEN;


  SUBBYTESSHIFTROWS0: subbytesshiftrows
    port map (
        bytes_in  => bytes_in,
        bytes_out => bytes_out,
        clk       => clk,
        reset     => reset);
  
  MIX0: mixcolumns
    port map (
        bytes_in  => bytes_out,
        bytes_out => mix_bytes_out,
        clk       => clk,
        reset     => reset);

  
  TB: process
  begin  -- process TB
    reset <= '1';
    wait for 55 ns;

    reset <= '0';

    wait for 20 ns;
    bytes_in(0) <= X"19";
    bytes_in(1) <= X"A0";
    bytes_in(2) <= X"9A";
    bytes_in(3) <= X"E9";
    bytes_in(4) <= X"3D";
    bytes_in(5) <= X"F4";
    bytes_in(6) <= X"C6";
    bytes_in(7) <= X"F8";
    bytes_in(8) <= X"E3";
    bytes_in(9) <= X"E2";
    bytes_in(10) <= X"8D";
    bytes_in(11) <= X"48";
    bytes_in(12) <= X"BE";
    bytes_in(13) <= X"2B";
    bytes_in(14) <= X"2A";
    bytes_in(15) <= X"08";
    wait for 10 ns;
    bytes_in(0) <= X"A4";
    bytes_in(1) <= X"68";
    bytes_in(2) <= X"6B";
    bytes_in(3) <= X"02";
    bytes_in(4) <= X"9C";
    bytes_in(5) <= X"9F";
    bytes_in(6) <= X"5B";
    bytes_in(7) <= X"6A";
    bytes_in(8) <= X"7F";
    bytes_in(9) <= X"35";
    bytes_in(10) <= X"EA";
    bytes_in(11) <= X"50";
    bytes_in(12) <= X"F2";
    bytes_in(13) <= X"2B";
    bytes_in(14) <= X"43";
    bytes_in(15) <= X"49";
    wait for 10 ns;

    wait;
    
  end process TB;
end tb;
