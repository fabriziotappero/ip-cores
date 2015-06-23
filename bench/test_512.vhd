-------------------------------------------------------------------------------- 
-- Company:  
-- Engineer: 
-- 
-- Create Date:   17:40:28 12/13/2009 
-- Design Name:    
-- Module Name:   
-- Project Name:  ciosspartan 
-- Target Device:   
-- Tool versions:   
-- Description:    
--  
-- VHDL Test Bench Created by ISE for module: rsa_top 
--  
-- Dependencies: 
--  
-- Revision: 
-- Revision 0.01 - File Created 
-- Additional Comments: 
-- 
-- Notes:  
-- This testbench has been automatically generated using types std_logic and 
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends 
-- that these types always be used for the top-level I/O of a design in order 
-- to guarantee that the testbench will bind correctly to the post-implementation  
-- simulation model. 
-------------------------------------------------------------------------------- 
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity test_rsa_512 is
end test_rsa_512;

architecture behavior of test_rsa_512 is

  -- Component Declaration for the Unit Under Test (UUT) 

  component rsa_top
    port(
      clk       : in  std_logic;
      reset     : in  std_logic;
      valid_in  : in  std_logic;
      start_in  : in  std_logic;
      x         : in  std_logic_vector(15 downto 0);
      y         : in  std_logic_vector(15 downto 0);
      m         : in  std_logic_vector(15 downto 0);
      r_c       : in  std_logic_vector(15 downto 0);
      s         : out std_logic_vector(15 downto 0);
      valid_out : out std_logic;
      bit_size  : in  std_logic_vector(15 downto 0)
      );
  end component;


  --Inputs 
  signal clk       : std_logic                     := '0';
  signal reset     : std_logic                     := '0';
  signal valid_in  : std_logic                     := '0';
  signal start_in  : std_logic;
  signal x         : std_logic_vector(15 downto 0) := (others => '0');
  signal y         : std_logic_vector(15 downto 0) := (others => '0');
  signal m         : std_logic_vector(15 downto 0) := (others => '0');
  signal r_c       : std_logic_vector(15 downto 0) := (others => '0');
  signal n_c       : std_logic_vector(15 downto 0) := (others => '0');
  signal bit_size  : std_logic_vector(15 downto 0) := x"0200";
  --Outputs 
  signal s         : std_logic_vector(15 downto 0);
  signal valid_out : std_logic;

  -- Clock period definitions 
  constant clk_period : time := 1ns;

begin

  -- Instantiate the Unit Under Test (UUT) 
  uut : rsa_top port map (
    clk       => clk,
    reset     => reset,
    valid_in  => valid_in,
    start_in  => start_in,
    x         => x,
    y         => y,
    m         => m,
    r_c       => r_c,
    s         => s,
    valid_out => valid_out,
    bit_size  => bit_size
    );

  -- Clock process definitions 
  clk_process : process
  begin
    clk <= '0';
    wait for clk_period/2;
    clk <= '1';
    wait for clk_period/2;
  end process;


  -- Stimulus process 
  stim_proc : process
  begin
    start_in <= '0';
    valid_in <= '0';
    -- hold reset state for 100ms. 
    reset    <= '1';
    wait for 10ns;
    reset    <= '0';
    wait for clk_period*10;

    -- insert stimulus here  

--n_c and valid signal and the r_c constant are also required
    --n_c      <= x"738f";
    m        <= x"b491";
    --Start_in to begin n_c calculation
    start_in <= '1';
    wait for clk_period;
    start_in <= '0';
    wait for clk_period*6;
    --Start data flow
    x        <= x"f3ad";
    y        <= x"42b1";
    m        <= x"b491";
    r_c      <= x"f579";
    valid_in <= '1';
    wait for clk_period;
    x        <= x"8e40";
    y        <= x"1ad3";
    m        <= x"1417";
    r_c      <= x"6ee9";
    wait for clk_period;
    x        <= x"6af9";
    y        <= x"a827";
    m        <= x"b498";
    r_c      <= x"972d";
    wait for clk_period;
    x        <= x"4e63";
    y        <= x"0d64";
    m        <= x"e1b7";
    r_c      <= x"5052";
    wait for clk_period;
    x        <= x"9600";
    y        <= x"3f76";
    m        <= x"e47c";
    r_c      <= x"1dca";
    wait for clk_period;
    x        <= x"68f4";
    y        <= x"6670";
    m        <= x"b186";
    r_c      <= x"bc81";
    wait for clk_period;
    x        <= x"5a12";
    y        <= x"5a1c";
    m        <= x"93f0";
    r_c      <= x"377e";
    wait for clk_period;
    x        <= x"d62e";
    y        <= x"4844";
    m        <= x"b183";
    r_c      <= x"04ef";
    wait for clk_period;
    x        <= x"8fc1";
    y        <= x"d5f2";
    m        <= x"f8f1";
    r_c      <= x"3a2a";
    wait for clk_period;
    x        <= x"031d";
    y        <= x"b65a";
    m        <= x"eed1";
    r_c      <= x"291b";
    wait for clk_period;
    x        <= x"f496";
    y        <= x"034f";
    m        <= x"0083";
    r_c      <= x"c159";
    wait for clk_period;
    x        <= x"1268";
    y        <= x"9635";
    m        <= x"981c";
    r_c      <= x"9336";
    wait for clk_period;
    x        <= x"2e5a";
    y        <= x"386e";
    m        <= x"6441";
    r_c      <= x"1bd0";
    wait for clk_period;
    x        <= x"c1d6";
    y        <= x"fb73";
    m        <= x"fcd8";
    r_c      <= x"317d";
    wait for clk_period;
    x        <= x"cd8f";
    y        <= x"5623";
    m        <= x"cbf0";
    r_c      <= x"64b4";
    wait for clk_period;
    x        <= x"e4d2";
    y        <= x"9041";
    m        <= x"e3ca";
    r_c      <= x"8793";
    wait for clk_period;
    x        <= x"36c6";
    y        <= x"99da";
    m        <= x"41d9";
    r_c      <= x"85f5";
    wait for clk_period;
    x        <= x"df4a";
    y        <= x"cd68";
    m        <= x"b7a0";
    r_c      <= x"7c8d";
    wait for clk_period;
    x        <= x"8e40";
    y        <= x"9a94";
    m        <= x"146e";
    r_c      <= x"64d9";
    wait for clk_period;
    x        <= x"6af9";
    y        <= x"ccc8";
    m        <= x"4776";
    r_c      <= x"c7f6";
    wait for clk_period;
    x        <= x"4e63";
    y        <= x"ed49";
    m        <= x"ec50";
    r_c      <= x"fba0";
    wait for clk_period;
    x        <= x"9600";
    y        <= x"4d25";
    m        <= x"c07c";
    r_c      <= x"e3e0";
    wait for clk_period;
    x        <= x"68f4";
    y        <= x"3b8e";
    m        <= x"e698";
    r_c      <= x"b567";
    wait for clk_period;
    x        <= x"5a12";
    y        <= x"36d5";
    m        <= x"d85f";
    r_c      <= x"3172";
    wait for clk_period;
    x        <= x"d62e";
    y        <= x"3a75";
    m        <= x"729c";
    r_c      <= x"111a";
    wait for clk_period;
    x        <= x"8fc1";
    y        <= x"77a3";
    m        <= x"19b6";
    r_c      <= x"1971";
    wait for clk_period;
    x        <= x"d2cd";
    y        <= x"367f";
    m        <= x"05d3";
    r_c      <= x"9f9b";
    wait for clk_period;
    x        <= x"c6e4";
    y        <= x"68de";
    m        <= x"cacd";
    r_c      <= x"b574";
    wait for clk_period;
    x        <= x"4a36";
    y        <= x"59a4";
    m        <= x"e16f";
    r_c      <= x"4a50";
    wait for clk_period;
    x        <= x"f6df";
    y        <= x"9f89";
    m        <= x"f67b";
    r_c      <= x"6d56";
    wait for clk_period;
    x        <= x"061c";
    y        <= x"ed71";
    m        <= x"7066";
    r_c      <= x"bdc6";
    wait for clk_period;
    x        <= x"06c8";
    y        <= x"059f";
    m        <= x"08de";
    r_c      <= x"0400";
    wait for clk_period;
    valid_in <= '0';

--valid_in <='0';
    wait for clk_period*200000;

    --Now with the public key x"10001"; 

    bit_size <= x"0011";
    valid_in <= '1';
    x        <= x"f3ad";
    y        <= x"0001";
    m        <= x"b491";
    r_c      <= x"f579";
    wait for clk_period;
    x        <= x"8e40";
    y        <= x"0001";
    m        <= x"1417";
    r_c      <= x"6ee9";
    wait for clk_period;
    x        <= x"6af9";
    y        <= x"0000";
    m        <= x"b498";
    r_c      <= x"972d";
    wait for clk_period;
    x        <= x"4e63";
    m        <= x"e1b7";
    r_c      <= x"5052";
    wait for clk_period;
    x        <= x"9600";
    m        <= x"e47c";
    r_c      <= x"1dca";
    wait for clk_period;
    x        <= x"68f4";
    m        <= x"b186";
    r_c      <= x"bc81";
    wait for clk_period;
    x        <= x"5a12";
    m        <= x"93f0";
    r_c      <= x"377e";
    wait for clk_period;
    x        <= x"d62e";
    m        <= x"b183";
    r_c      <= x"04ef";
    wait for clk_period;
    x        <= x"8fc1";
    m        <= x"f8f1";
    r_c      <= x"3a2a";
    wait for clk_period;
    x        <= x"031d";
    m        <= x"eed1";
    r_c      <= x"291b";
    wait for clk_period;
    x        <= x"f496";
    m        <= x"0083";
    r_c      <= x"c159";
    wait for clk_period;
    x        <= x"1268";

    m   <= x"981c";
    r_c <= x"9336";
    wait for clk_period;
    x   <= x"2e5a";

    m   <= x"6441";
    r_c <= x"1bd0";
    wait for clk_period;
    x   <= x"c1d6";

    m   <= x"fcd8";
    r_c <= x"317d";
    wait for clk_period;
    x   <= x"cd8f";

    m   <= x"cbf0";
    r_c <= x"64b4";
    wait for clk_period;
    x   <= x"e4d2";

    m   <= x"e3ca";
    r_c <= x"8793";
    wait for clk_period;
    x   <= x"36c6";

    m   <= x"41d9";
    r_c <= x"85f5";
    wait for clk_period;
    x   <= x"df4a";

    m   <= x"b7a0";
    r_c <= x"7c8d";
    wait for clk_period;
    x   <= x"8e40";

    m   <= x"146e";
    r_c <= x"64d9";
    wait for clk_period;
    x   <= x"6af9";

    m   <= x"4776";
    r_c <= x"c7f6";
    wait for clk_period;
    x   <= x"4e63";

    m   <= x"ec50";
    r_c <= x"fba0";
    wait for clk_period;
    x   <= x"9600";

    m   <= x"c07c";
    r_c <= x"e3e0";
    wait for clk_period;
    x   <= x"68f4";

    m   <= x"e698";
    r_c <= x"b567";
    wait for clk_period;
    x   <= x"5a12";

    m   <= x"d85f";
    r_c <= x"3172";
    wait for clk_period;
    x   <= x"d62e";

    m   <= x"729c";
    r_c <= x"111a";
    wait for clk_period;
    x   <= x"8fc1";

    m   <= x"19b6";
    r_c <= x"1971";
    wait for clk_period;
    x   <= x"d2cd";

    m   <= x"05d3";
    r_c <= x"9f9b";
    wait for clk_period;
    x   <= x"c6e4";

    m   <= x"cacd";
    r_c <= x"b574";
    wait for clk_period;
    x   <= x"4a36";

    m   <= x"e16f";
    r_c <= x"4a50";
    wait for clk_period;
    x   <= x"f6df";

    m   <= x"f67b";
    r_c <= x"6d56";
    wait for clk_period;
    x   <= x"061c";

    m   <= x"7066";
    r_c <= x"bdc6";
    wait for clk_period;
    x   <= x"06c8";

    m        <= x"08de";
    r_c      <= x"0400";
    wait for clk_period;
    valid_in <= '0';

    wait;
  end process;

end;
