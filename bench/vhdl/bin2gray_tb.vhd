-------------------------------------------------------------------------------
-- Title      : Testbench for design "bin2grey"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : bin2gray_tb.vhd
-- Author     : 
-- Company    : 
-- Created    : 2007-10-22
-- Last update: 2007-10-22
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2007 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2007-10-22  1.0      d.koethe        Created
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
-------------------------------------------------------------------------------

entity bin2gray_tb is

end bin2gray_tb;

-------------------------------------------------------------------------------

architecture behavior of bin2gray_tb is

  component gray2bin
    generic (
      width : integer);
    port (
      in_gray : in  std_logic_vector(width-1 downto 0);
      out_bin : out std_logic_vector(width-1 downto 0));
  end component;

  component bin2gray
    generic (
      width : integer);
    port (
      in_bin   : in  std_logic_vector(width-1 downto 0);
      out_gray : out std_logic_vector(width-1 downto 0));
  end component;

  component gray_adder
    generic (
      width : integer);
    port (
      in_gray  : in  std_logic_vector(width-1 downto 0);
      out_gray : out std_logic_vector(width-1 downto 0));
  end component;

  -- component generics
  constant width : integer := 4;

  -- component ports
  signal in_bin           : std_logic_vector(width-1 downto 0);
  signal out_gray         : std_logic_vector(width-1 downto 0);
  signal out_bin          : std_logic_vector(width-1 downto 0);
  signal out_gray_add_one : std_logic_vector(width-1 downto 0);
  
begin  -- behavior

  -- component instantiation
  bin2gray_1 : bin2gray
    generic map (
      width => width)
    port map (
      in_bin   => in_bin,
      out_gray => out_gray);


  gray2bin_1 : gray2bin
    generic map (
      width => width)
    port map (
      in_gray => out_gray,
      out_bin => out_bin);


  gray_adder_1 : gray_adder
    generic map (
      width => width)
    port map (
      in_gray  => out_gray,
      out_gray => out_gray_add_one);


  -- waveform generation
  WaveGen_Proc : process
  begin
    for i in 0 to 2**width-1 loop
      in_bin <= conv_std_logic_vector(i, width);
      wait for 10 ns;
      
    end loop;  -- i
    assert false report "Simulation Sucessful" severity failure;
    
  end process WaveGen_Proc;

  

end behavior;

-------------------------------------------------------------------------------

configuration bin2gray_tb_behavior_cfg of bin2gray_tb is
  for behavior
  end for;
end bin2gray_tb_behavior_cfg;

-------------------------------------------------------------------------------
