-------------------------------------------------------------------------------
-- Title      : 4 agent top level for ase_mesh1
-- Project    : 
-------------------------------------------------------------------------------
-- File       : ase_mesh1_top4.vhd
-- Author     : Lasse Lehtonen
-- Company    : 
-- Created    : 2011-11-09
-- Last update: 2011-12-02
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: Creates a fixed size mesh (incl. packetizers).
-------------------------------------------------------------------------------
-- Copyright (c) 2011 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2011-11-09  1.0      lehton87        Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;


entity ase_mesh1_top4 is
  
  port (
    clk        : in  std_logic;
    rst_n      : in  std_logic;
    cmd0_in    : in  std_logic_vector(1 downto 0);
    data0_in   : in  std_logic_vector(31 downto 0);
    stall0_out : out std_logic;
    cmd0_out   : out std_logic_vector(1 downto 0);
    data0_out  : out std_logic_vector(31 downto 0);
    stall0_in  : in  std_logic;

    cmd1_in    : in  std_logic_vector(1 downto 0);
    data1_in   : in  std_logic_vector(31 downto 0);
    stall1_out : out std_logic;
    cmd1_out   : out std_logic_vector(1 downto 0);
    data1_out  : out std_logic_vector(31 downto 0);
    stall1_in  : in  std_logic;

    cmd2_in    : in  std_logic_vector(1 downto 0);
    data2_in   : in  std_logic_vector(31 downto 0);
    stall2_out : out std_logic;
    cmd2_out   : out std_logic_vector(1 downto 0);
    data2_out  : out std_logic_vector(31 downto 0);
    stall2_in  : in  std_logic;

    cmd3_in    : in  std_logic_vector(1 downto 0);
    data3_in   : in  std_logic_vector(31 downto 0);
    stall3_out : out std_logic;
    cmd3_out   : out std_logic_vector(1 downto 0);
    data3_out  : out std_logic_vector(31 downto 0);
    stall3_in  : in  std_logic);

end ase_mesh1_top4;

architecture structural of ase_mesh1_top4 is

  -- Intermediate wide signals that combine indifivudal terminals so that they
  -- can be connected to mesh
  signal cmd_i   : std_logic_vector(4*2-1 downto 0);
  signal data_i  : std_logic_vector(4*32-1 downto 0);
  signal stall_i : std_logic_vector(3 downto 0);
  
  signal cmd_o   : std_logic_vector(4*2-1 downto 0);
  signal data_o  : std_logic_vector(4*32-1 downto 0);
  signal stall_o : std_logic_vector(3 downto 0);
  
begin  -- structural

  -- Connect terminals to internal signals, and vice versa
  cmd_i((0+1)*2-1 downto 0*2)    <= cmd0_in;
  data_i((0+1)*32-1 downto 0*32) <= data0_in;
  stall_i(0)                     <= stall0_in;
  cmd0_out                       <= cmd_o((0+1)*2-1 downto 0*2);
  data0_out                      <= data_o((0+1)*32-1 downto 0*32);
  stall0_out                     <= stall_o(0);

  cmd_i((1+1)*2-1 downto 1*2)    <= cmd1_in;
  data_i((1+1)*32-1 downto 1*32) <= data1_in;
  stall_i(1)                     <= stall1_in;
  cmd1_out                       <= cmd_o((1+1)*2-1 downto 1*2);
  data1_out                      <= data_o((1+1)*32-1 downto 1*32);
  stall1_out                     <= stall_o(1);

  cmd_i((2+1)*2-1 downto 2*2)    <= cmd2_in;
  data_i((2+1)*32-1 downto 2*32) <= data2_in;
  stall_i(2)                     <= stall2_in;
  cmd2_out                       <= cmd_o((2+1)*2-1 downto 2*2);
  data2_out                      <= data_o((2+1)*32-1 downto 2*32);
  stall2_out                     <= stall_o(2);

  cmd_i((3+1)*2-1 downto 3*2)    <= cmd3_in;
  data_i((3+1)*32-1 downto 3*32) <= data3_in;
  stall_i(3)                     <= stall3_in;
  cmd3_out                       <= cmd_o((3+1)*2-1 downto 3*2);
  data3_out                      <= data_o((3+1)*32-1 downto 3*32);
  stall3_out                     <= stall_o(3);

  -- Instantiate mesh with fixed parameters
  ase_mesh1_pkt_codec_1 : entity work.ase_mesh1_pkt_codec
    generic map (
      data_width_g   => 32,
      cmd_width_g    => 2,
      agents_g       => 4,
      cols_g         => 2,
      rows_g         => 2,
      agent_ports_g  => 1,
      addr_flit_en_g => 0,
      address_mode_g => 1,
      clock_mode_g   => 0,
      rip_addr_g     => 0,
      fifo_depth_g   => 0
      )
    port map (
      clk_ip    => clk,
      clk_net   => clk,
      rst_n     => rst_n,

      cmd_in    => cmd_i,
      data_in   => data_i,
      stall_out => stall_o,
      
      cmd_out   => cmd_o,
      data_out  => data_o,
      stall_in  => stall_i
      ); 

end structural;
