-------------------------------------------------------------------------------
-- Title      : ram.vhd
-- Project    : 
-------------------------------------------------------------------------------
-- File       : ram.vhd
-- Author     : 
-- Company    : 
-- Created    : 2003-12-05
-- Last update: 2003-12-05
-- Platform   : 
-------------------------------------------------------------------------------
-- Description: Bloco de ram para armazenar a parte real e a imaginaria.
-------------------------------------------------------------------------------
-- Copyright (c) 2003 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2003-12-05  1.0      tmsiqueira      Created
-------------------------------------------------------------------------------

  library IEEE;
  use IEEE.std_logic_1164.all;
										  
  entity ram is
    
    generic (
        width      : natural;
        depth      : natural;
        Addr_width : natural);

      port (
          clkin   : in  std_logic;      -- clock para a porta de entrada
          wen     : in  std_logic;      -- write enable
          addrin  : in  std_logic_vector(Addr_width-1 downto 0);  -- endereco de entrada
          dinR    : in  std_logic_vector(width-1 downto 0);   -- imag data in
          dinI    : in  std_logic_vector(width-1 downto 0);   -- real data in
          clkout  : in  std_logic;      -- clock para a porta de saida
          addrout : in  std_logic_vector(Addr_width-1 downto 0);  -- endereco de leitura
          doutR   : out std_logic_vector(width-1 downto 0);   -- real data out
          doutI   : out std_logic_vector(width-1 downto 0));  -- imag data out

  end ram;

  architecture ram of ram is

    component blockdram
      generic (
        depth  : natural;
        Dwidth : natural;
        Awidth : natural);
      port (
        clkin   : in  std_logic;
        wen     : in  std_logic;
        addrin  : in  std_logic_vector(Awidth-1 downto 0);
        din     : in  std_logic_vector(Dwidth-1 downto 0);
        clkout  : in  std_logic;
        addrout : in  std_logic_vector(Awidth-1 downto 0);
        dout    : out std_logic_vector(Dwidth-1 downto 0));
    end component;
    
  begin  -- ram

    Real_ram : blockdram
      generic map (
        depth  => depth,
        Dwidth => width,
        Awidth => Addr_width)
      port map (
        clkin   => clkin,
        wen     => wen,
        addrin  => addrin,
        din     => dinR,
        clkout  => clkout,
        addrout => addrout,
        dout    => doutR);

    Imag_ram : blockdram
      generic map (
        depth  => depth,
        Dwidth => width,
        Awidth => Addr_width)
      port map (
        clkin   => clkin,
        wen     => wen,
        addrin  => addrin,
        din     => dinI,
        clkout  => clkout,
        addrout => addrout,
        dout    => doutI);

  end ram;
