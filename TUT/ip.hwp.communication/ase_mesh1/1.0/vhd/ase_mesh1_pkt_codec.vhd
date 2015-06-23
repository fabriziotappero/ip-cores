-------------------------------------------------------------------------------
-- Title      : Ase mesh1 top with packet codecs
-- Project    : 
-------------------------------------------------------------------------------
-- File       : ase_mesh1_pkt_codec.vhd
-- Author     : Lasse Lehtonen
-- Company    : 
-- Created    : 2011-09-25
-- Last update: 2012-06-14
-- Platform   : 
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: Combines the mesh network with packetizers.
-------------------------------------------------------------------------------
-- Copyright (c) 2011 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2011-01-18  1.0      ase     Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;



entity ase_mesh1_pkt_codec is
  
  generic (
    data_width_g      : positive;       -- in bits
    cmd_width_g       : positive;       -- in bits
    agents_g          : positive;       -- num of terminals
    cols_g            : positive;       -- #terminals in x dimension
    rows_g            : positive;       -- #terminals in y dimension
    agent_ports_g     : positive;
    addr_flit_en_g    : natural;
    address_mode_g    : natural;
    clock_mode_g      : natural;
    rip_addr_g        : natural;
    ni_fifo_depth_g   : natural;
    link_fifo_depth_g : natural);

  port (
    clk_ip    : in  std_logic;
    clk_net   : in  std_logic;
    rst_n     : in  std_logic;
    cmd_in    : in  std_logic_vector(agents_g * cmd_width_g - 1 downto 0);
    data_in   : in  std_logic_vector(agents_g * data_width_g - 1 downto 0);
    stall_out : out std_logic_vector(agents_g - 1 downto 0);

    cmd_out  : out std_logic_vector(agents_g * cmd_width_g - 1 downto 0);
    data_out : out std_logic_vector(agents_g * data_width_g - 1 downto 0);
    stall_in : in  std_logic_vector(agents_g - 1 downto 0)
    );

end entity ase_mesh1_pkt_codec;



architecture structural of ase_mesh1_pkt_codec is

  constant noc_type_g : natural := 1;

  -----------------------------------------------------------------------------
  -- MESH
  -----------------------------------------------------------------------------

  signal cmd_to_n     : std_logic_vector(agents_g * cmd_width_g - 1 downto 0);
  signal data_to_n    : std_logic_vector(agents_g * data_width_g - 1 downto 0);
  signal stall_to_n   : std_logic_vector(agents_g - 1 downto 0);
  signal cmd_from_n   : std_logic_vector(agents_g * cmd_width_g - 1 downto 0);
  signal data_from_n  : std_logic_vector(agents_g * data_width_g - 1 downto 0);
  signal stall_from_n : std_logic_vector(agents_g - 1 downto 0);

begin  -- architecture structural


  -----------------------------------------------------------------------------
  -- Instantiate the mesh top-level
  -----------------------------------------------------------------------------
  noc_top_1 : entity work.ase_mesh1
    generic map (
      n_rows_g     => rows_g,
      n_cols_g     => cols_g,
      cmd_width_g  => cmd_width_g,
      bus_width_g  => data_width_g,
      fifo_depth_g => link_fifo_depth_g
      )
    port map (
      clk   => clk_net,
      rst_n => rst_n,

      cmd_in    => cmd_to_n,
      data_in   => data_to_n,
      stall_out => stall_from_n,

      cmd_out  => cmd_from_n,
      data_out => data_from_n,
      stall_in => stall_to_n
      );



  -----------------------------------------------------------------------------
  -- GENERATE PKT_CODEC_MK2s
  -----------------------------------------------------------------------------
  codecs_g : for i in 0 to agents_g-1 generate

    packet_codec_1 : entity work.pkt_codec_mk2
      generic map (
        my_id_g      => i,
        data_width_g => data_width_g,
        cmd_width_g  => cmd_width_g,
        agents_g     => agents_g,
        cols_g       => cols_g,
        rows_g       => rows_g,

        agent_ports_g  => agent_ports_g,
        addr_flit_en_g => addr_flit_en_g,
        address_mode_g => address_mode_g,
        clock_mode_g   => clock_mode_g,
        rip_addr_g     => rip_addr_g,
        noc_type_g     => noc_type_g,
        fifo_depth_g   => ni_fifo_depth_g
        )
      port map (
        clk_ip      => clk_ip,
        clk_net     => clk_net,
        rst_n       => rst_n,
        -- IP side in/out
        ip_cmd_out  => cmd_out((i+1)*cmd_width_g-1 downto i*cmd_width_g),
        ip_data_out => data_out((i+1)*data_width_g-1 downto i*data_width_g),
        ip_stall_in => stall_in(i),

        ip_cmd_in    => cmd_in((i+1)*cmd_width_g-1 downto i*cmd_width_g),
        ip_data_in   => data_in((i+1)*data_width_g-1 downto i*data_width_g),
        ip_stall_out => stall_out(i),

        ip_len_in => (others => '0'),

        -- NoC side out/in
        net_cmd_out  => cmd_to_n((i+1)*cmd_width_g-1 downto i*cmd_width_g),
        net_data_out => data_to_n((i+1)*data_width_g-1 downto i*data_width_g),
        net_stall_in => stall_from_n(i),

        net_cmd_in    => cmd_from_n((i+1)*cmd_width_g-1 downto i*cmd_width_g),
        net_data_in   => data_from_n((i+1)*data_width_g-1 downto i*data_width_g),
        net_stall_out => stall_to_n(i)
        );

  end generate codecs_g;


end architecture structural;

