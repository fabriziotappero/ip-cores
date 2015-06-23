-------------------------------------------------------------------------------
-- Title      : sdram2hibi and sdram_controller top-level
-- Project    : 
-------------------------------------------------------------------------------
-- File       : sdram_top.vhd
-- Author     : 
-- Company    : 
-- Created    : 2005-10-13
-- Last update: 2012-04-11
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description:
-- 
-------------------------------------------------------------------------------
-- Copyright (c) 2005 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2005-10-13  1.0      penttin5        Created
-- 2012-01-22  1.001    alhonen fixed names.  hibiv3.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity sdram_toplevel is
  
  generic (
    own_hibi_base_addr_g : integer := 0;
    hibi_data_width_g    : integer := 32;
    mem_data_width_g     : integer := 16;
    mem_addr_width_g     : integer := 22;
    comm_width_g         : integer := 5;
    input_fifo_depth_g   : integer := 10;
    num_of_read_ports_g  : integer := 4;
    num_of_write_ports_g : integer := 4;
    offset_width_g       : integer := 16;
    rq_fifo_depth_g      : integer := 3;
    op_arb_type_g        : integer := 0;  -- 1=fixed prior
    port_arb_type_g      : integer := 0;
    blk_rd_prior_g       : integer := 0;  -- rd has the highest prior
    blk_wr_prior_g       : integer := 1;
    single_op_prior_g    : integer := 2;
    block_overlap_g      : integer := 0;
    clk_freq_mhz_g       : integer := 50;  -- clock frequency in MHz
    block_read_length_g  : integer := 30
    );

  port (
    clk           : in  std_logic;
    rst_n         : in  std_logic;
    hibi_addr_in  : in  std_logic_vector(hibi_data_width_g - 1 downto 0);
    hibi_data_in  : in  std_logic_vector(hibi_data_width_g - 1 downto 0);
    hibi_comm_in  : in  std_logic_vector(comm_width_g - 1 downto 0);
    hibi_empty_in : in  std_logic;
    hibi_re_out   : out std_logic;

    hibi_addr_out : out std_logic_vector(hibi_data_width_g - 1 downto 0);
    hibi_data_out : out std_logic_vector(hibi_data_width_g - 1 downto 0);
    hibi_comm_out : out std_logic_vector(comm_width_g - 1 downto 0);
    hibi_full_in  : in  std_logic;
    hibi_we_out   : out std_logic;      -- this is asynchronous

    hibi_msg_addr_in  : in  std_logic_vector(hibi_data_width_g - 1 downto 0);
    hibi_msg_data_in  : in  std_logic_vector(hibi_data_width_g - 1 downto 0);
    hibi_msg_comm_in  : in  std_logic_vector(comm_width_g - 1 downto 0);
    hibi_msg_empty_in : in  std_logic;
    hibi_msg_re_out   : out std_logic;

    hibi_msg_data_out : out std_logic_vector(hibi_data_width_g - 1 downto 0);
    hibi_msg_addr_out : out std_logic_vector(hibi_data_width_g - 1 downto 0);
    hibi_msg_comm_out : out std_logic_vector(comm_width_g - 1 downto 0);
    hibi_msg_full_in  : in  std_logic;
    hibi_msg_we_out   : out std_logic;

    sdram_data_inout  : inout std_logic_vector(15 downto 0);
    sdram_cke_out     : out   std_logic;
    sdram_cs_n_out    : out   std_logic;
    sdram_we_n_out    : out   std_logic;
    sdram_ras_n_out   : out   std_logic;
    sdram_cas_n_out   : out   std_logic;
    sdram_dqm_out     : out   std_logic_vector(1 downto 0);
    sdram_ba_out      : out   std_logic_vector(1 downto 0);
    sdram_address_out : out   std_logic_vector(11 downto 0)
    );

end sdram_toplevel;

architecture structural of sdram_toplevel is

  component sdram2hibi
    generic (
    own_hibi_base_addr_g : integer := 0;
    hibi_data_width_g    : integer := 32;
    mem_data_width_g     : integer := 16;
    mem_addr_width_g     : integer := 22;
    comm_width_g         : integer := 5;
    input_fifo_depth_g   : integer := 5;
    num_of_read_ports_g  : integer := 4;
    num_of_write_ports_g : integer := 4;
    offset_width_g       : integer := 16;
    rq_fifo_depth_g      : integer := 3;
    op_arb_type_g        : integer := 1;  -- fixed prior
    port_arb_type_g      : integer := 0;
    blk_rd_prior_g       : integer := 0;  -- rd has the highest prior
    blk_wr_prior_g       : integer := 1;
    single_op_prior_g    : integer := 2;
    block_overlap_g      : integer := 0      
      );

    port (
      clk   : in std_logic;
      rst_n : in std_logic;

      hibi_addr_in  : in  std_logic_vector(hibi_data_width_g - 1 downto 0);
      hibi_data_in  : in  std_logic_vector(hibi_data_width_g - 1 downto 0);
      hibi_comm_in  : in  std_logic_vector(comm_width_g - 1 downto 0);
      hibi_empty_in : in  std_logic;
      hibi_re_out   : out std_logic;

      hibi_addr_out : out std_logic_vector(hibi_data_width_g - 1 downto 0);
      hibi_data_out : out std_logic_vector(hibi_data_width_g - 1 downto 0);
      hibi_comm_out : out std_logic_vector(comm_width_g - 1 downto 0);
      hibi_full_in  : in  std_logic;
      hibi_we_out   : out std_logic;    -- this is asynchronous

      hibi_msg_addr_in  : in  std_logic_vector(hibi_data_width_g - 1
                                               downto 0);
      hibi_msg_data_in  : in  std_logic_vector(hibi_data_width_g - 1
                                               downto 0);
      hibi_msg_comm_in  : in  std_logic_vector(comm_width_g - 1 downto 0);
      hibi_msg_empty_in : in  std_logic;
      hibi_msg_re_out   : out std_logic;

      hibi_msg_data_out : out std_logic_vector(hibi_data_width_g - 1
                                               downto 0);
      hibi_msg_addr_out : out std_logic_vector(hibi_data_width_g - 1
                                               downto 0);
      hibi_msg_comm_out : out std_logic_vector(comm_width_g - 1 downto 0);
      hibi_msg_full_in  : in  std_logic;
      hibi_msg_we_out   : out std_logic;

      sdram_ctrl_write_on_in     : in  std_logic;
      sdram_ctrl_comm_out        : out std_logic_vector(1 downto 0);
      sdram_ctrl_addr_out        : out std_logic_vector(21 downto 0);
      sdram_ctrl_data_amount_out : out std_logic_vector(mem_addr_width_g - 1
                                                        downto 0);
      sdram_ctrl_input_one_d_out : out std_logic;
      sdram_ctrl_input_empty_out : out std_logic;
      sdram_ctrl_output_full_out : out std_logic;
      sdram_ctrl_busy_in         : in  std_logic;
      sdram_ctrl_re_in           : in  std_logic;
      sdram_ctrl_we_in           : in  std_logic;

      -- this is asynchronous but it is read to register in sdram_controller
      sdram_ctrl_data_out        : out std_logic_vector(mem_data_width_g-1 downto 0);
      sdram_ctrl_data_in         : in  std_logic_vector(mem_data_width_g-1 downto 0);
      -- byte select is not implemented!!!
      sdram_ctrl_byte_select_out : out std_logic_vector(mem_data_width_g/8-1 downto 0)
      );

  end component;

  component wra_16sdram_32hibi
    generic (
      mem_addr_width_g : integer);
    port (
      clk                       : in  std_logic;
      rst_n                     : in  std_logic;
      sdram2hibi_write_on_out   : out std_logic;
      sdram2hibi_comm_in        : in  std_logic_vector(1 downto 0);
      sdram2hibi_addr_in        : in  std_logic_vector(21 downto 0);
      sdram2hibi_data_amount_in : in  std_logic_vector(mem_addr_width_g-1 downto 0);
      sdram2hibi_input_one_d_in : in  std_logic;
      sdram2hibi_input_empty_in : in  std_logic;
      sdram2hibi_output_full_in : in  std_logic;
      sdram2hibi_busy_out       : out std_logic;
      sdram2hibi_re_out         : out std_logic;
      sdram2hibi_we_out         : out std_logic;
      sdram2hibi_data_in        : in  std_logic_vector(31 downto 0);
      sdram2hibi_data_out       : out std_logic_vector(31 downto 0);
      ctrl_command_out          : out std_logic_vector(1 downto 0);
      ctrl_address_out          : out std_logic_vector(21 downto 0);
      ctrl_data_amount_out      : out std_logic_vector(mem_addr_width_g-1 downto 0);
      ctrl_byte_select_out      : out std_logic_vector(1 downto 0);
      ctrl_input_empty_out      : out std_logic;
      ctrl_input_one_d_out      : out std_logic;
      ctrl_output_full_out      : out std_logic;
      ctrl_data_out             : out std_logic_vector(15 downto 0);
      ctrl_write_on_in          : in  std_logic;
      ctrl_busy_in              : in  std_logic;
      ctrl_output_we_in         : in  std_logic;
      ctrl_input_re_in          : in  std_logic;
      ctrl_data_in              : in  std_logic_vector(15 downto 0));
  end component;

  signal   ctrl_command_out          :  std_logic_vector(1 downto 0);
  signal   ctrl_address_out          :  std_logic_vector(21 downto 0);
  signal   ctrl_data_amount_out      :  std_logic_vector(mem_addr_width_g-1 downto 0);
  signal   ctrl_byte_select_out      :  std_logic_vector(1 downto 0);
  signal   ctrl_input_empty_out      :  std_logic;
  signal   ctrl_input_one_d_out      :  std_logic;
  signal   ctrl_output_full_out      :  std_logic;
  signal   ctrl_data_out             :  std_logic_vector(15 downto 0);
  signal   ctrl_write_on_in          :  std_logic;
  signal   ctrl_busy_in              :  std_logic;
  signal   ctrl_output_we_in         :  std_logic;
  signal   ctrl_input_re_in          :  std_logic;
  signal   ctrl_data_in              :  std_logic_vector(15 downto 0);
  
  
  component sdram_controller
    generic (
      clk_freq_mhz_g      : integer := 143;  -- clock frequency in MHz
      mem_addr_width_g    : integer := 22;
      block_read_length_g : integer := 10
      );

    port (
      clk   : in std_logic;
      rst_n : in std_logic;

      command_in             : in    std_logic_vector(1 downto 0);
      address_in             : in    std_logic_vector(21 downto 0);
      data_amount_in         : in    std_logic_vector(mem_addr_width_g - 1
                                                      downto 0);
      byte_select_in         : in    std_logic_vector(1 downto 0);
      input_empty_in         : in    std_logic;
      input_one_d_in         : in    std_logic;
      output_full_in         : in    std_logic;
      data_in                : in    std_logic_vector(15 downto 0);
      write_on_out           : out   std_logic;
      busy_out               : out   std_logic;
      output_we_out          : out   std_logic;  -- this is asynchronous
      input_re_out           : out   std_logic;
      data_out               : out   std_logic_vector(15 downto 0);
      sdram_data_inout       : inout std_logic_vector(15 downto 0);
      sdram_cke_out          : out   std_logic;
      sdram_cs_n_out         : out   std_logic;
      sdram_we_n_out         : out   std_logic;
      sdram_ras_n_out        : out   std_logic;
      sdram_cas_n_out        : out   std_logic;
      sdram_dqm_out          : out   std_logic_vector(1 downto 0);
      sdram_ba_out           : out   std_logic_vector(1 downto 0);
      sdram_address_out      : out   std_logic_vector(11 downto 0)
      );
  end component;

  signal write_on_ctrl_sdram2hibi : std_logic;
  signal comm_sdram2hibi_ctrl : std_logic_vector(1 downto 0);
  signal addr_sdram2hibi_ctrl : std_logic_vector(21 downto 0);
  signal amount_sdram2hibi_ctrl : std_logic_vector(mem_addr_width_g - 1
                                                   downto 0);
  signal one_d_sdram2hibi_ctrl       : std_logic;
  signal empty_sdram2hibi_ctrl       : std_logic;
  signal full_sdram2hibi_ctrl        : std_logic;
  signal busy_ctrl_sdram2hibi        : std_logic;
  signal re_ctrl_sdram2hibi          : std_logic;
  signal we_ctrl_sdram2hibi          : std_logic;
  signal data_sdram2hibi_ctrl        : std_logic_vector(31 downto 0);
  signal data_ctrl_sdram2hibi        : std_logic_vector(31 downto 0);
  signal byte_select_sdram2hibi_ctrl : std_logic_vector(3 downto 0);

begin  -- structural

    -- The sdram2hibi needs to know its own base hibi address.
  assert own_hibi_base_addr_g /= 0 report "Please set own_hibi_base_addr_g" severity failure;
  
  sdram2hibi_1 : sdram2hibi
    generic map (
      own_hibi_base_addr_g => own_hibi_base_addr_g,
      hibi_data_width_g    => hibi_data_width_g,
      mem_data_width_g     => 32,
      mem_addr_width_g     => mem_addr_width_g,
      comm_width_g         => comm_width_g,
      input_fifo_depth_g   => input_fifo_depth_g,
      num_of_read_ports_g  => num_of_read_ports_g,
      num_of_write_ports_g => num_of_write_ports_g,
      offset_width_g       => offset_width_g,
      rq_fifo_depth_g      => rq_fifo_depth_g,
      op_arb_type_g        => op_arb_type_g,
      port_arb_type_g      => port_arb_type_g,
      blk_rd_prior_g       => blk_rd_prior_g,
      blk_wr_prior_g       => blk_wr_prior_g,
      single_op_prior_g    => single_op_prior_g,
      block_overlap_g      => block_overlap_g
      )
    port map (
      clk           => clk,
      rst_n         => rst_n,
      hibi_addr_in  => hibi_addr_in,
      hibi_data_in  => hibi_data_in,
      hibi_comm_in  => hibi_comm_in,
      hibi_empty_in => hibi_empty_in,
      hibi_re_out   => hibi_re_out,

      hibi_addr_out => hibi_addr_out,
      hibi_data_out => hibi_data_out,
      hibi_comm_out => hibi_comm_out,
      hibi_full_in  => hibi_full_in,
      hibi_we_out   => hibi_we_out,

      hibi_msg_addr_in  => hibi_msg_addr_in,
      hibi_msg_data_in  => hibi_msg_data_in,
      hibi_msg_comm_in  => hibi_msg_comm_in,
      hibi_msg_empty_in => hibi_msg_empty_in,
      hibi_msg_re_out   => hibi_msg_re_out,

      hibi_msg_data_out => hibi_msg_data_out,
      hibi_msg_addr_out => hibi_msg_addr_out,
      hibi_msg_comm_out => hibi_msg_comm_out,
      hibi_msg_full_in  => hibi_msg_full_in,
      hibi_msg_we_out   => hibi_msg_we_out,

      sdram_ctrl_write_on_in     => write_on_ctrl_sdram2hibi,
      sdram_ctrl_comm_out        => comm_sdram2hibi_ctrl,
      sdram_ctrl_addr_out        => addr_sdram2hibi_ctrl,
      sdram_ctrl_data_amount_out => amount_sdram2hibi_ctrl,
      sdram_ctrl_input_one_d_out => one_d_sdram2hibi_ctrl,
      sdram_ctrl_input_empty_out => empty_sdram2hibi_ctrl,
      sdram_ctrl_output_full_out => full_sdram2hibi_ctrl,
      sdram_ctrl_busy_in         => busy_ctrl_sdram2hibi,
      sdram_ctrl_re_in           => re_ctrl_sdram2hibi,
      sdram_ctrl_we_in           => we_ctrl_sdram2hibi,
      sdram_ctrl_data_out        => data_sdram2hibi_ctrl,
      sdram_ctrl_data_in         => data_ctrl_sdram2hibi,

      --not implemented!!!
      sdram_ctrl_byte_select_out => byte_select_sdram2hibi_ctrl
      );

  wra_16sdram_32hibi_1: wra_16sdram_32hibi
    generic map (
      mem_addr_width_g => mem_addr_width_g)
    port map (
      clk                       => clk,
      rst_n                     => rst_n,
      sdram2hibi_write_on_out   => write_on_ctrl_sdram2hibi,
      sdram2hibi_comm_in        => comm_sdram2hibi_ctrl,
      sdram2hibi_addr_in        => addr_sdram2hibi_ctrl,
      sdram2hibi_data_amount_in => amount_sdram2hibi_ctrl,
      sdram2hibi_input_one_d_in => one_d_sdram2hibi_ctrl,
      sdram2hibi_input_empty_in => empty_sdram2hibi_ctrl,
      sdram2hibi_output_full_in => full_sdram2hibi_ctrl,
      sdram2hibi_busy_out       => busy_ctrl_sdram2hibi,
      sdram2hibi_re_out         => re_ctrl_sdram2hibi,
      sdram2hibi_we_out         => we_ctrl_sdram2hibi,
      sdram2hibi_data_in        => data_sdram2hibi_ctrl,
      sdram2hibi_data_out       => data_ctrl_sdram2hibi,
      ctrl_command_out          => ctrl_command_out,
      ctrl_address_out          => ctrl_address_out,
      ctrl_data_amount_out      => ctrl_data_amount_out,
      ctrl_byte_select_out      => ctrl_byte_select_out,
      ctrl_input_empty_out      => ctrl_input_empty_out,
      ctrl_input_one_d_out      => ctrl_input_one_d_out,
      ctrl_output_full_out      => ctrl_output_full_out,
      ctrl_data_out             => ctrl_data_out,
      ctrl_write_on_in          => ctrl_write_on_in,
      ctrl_busy_in              => ctrl_busy_in,
      ctrl_output_we_in         => ctrl_output_we_in,
      ctrl_input_re_in          => ctrl_input_re_in,
      ctrl_data_in              => ctrl_data_in);

  
  sdram_controller_1 : sdram_controller
    generic map (
      clk_freq_mhz_g      => clk_freq_mhz_g,
      mem_addr_width_g    => mem_addr_width_g,
      block_read_length_g => block_read_length_g
      )
    port map (
      clk                    => clk,
      rst_n                  => rst_n,
      command_in             => ctrl_command_out,
      address_in             => ctrl_address_out,
      data_amount_in         => ctrl_data_amount_out,
      byte_select_in         => ctrl_byte_select_out,
      input_empty_in         => ctrl_input_empty_out,
      input_one_d_in         => ctrl_input_one_d_out,
      output_full_in         => ctrl_output_full_out,
      data_in                => ctrl_data_out,
      write_on_out           => ctrl_write_on_in,
      busy_out               => ctrl_busy_in,
      output_we_out          => ctrl_output_we_in,
      input_re_out           => ctrl_input_re_in,
      data_out               => ctrl_data_in,
      sdram_data_inout       => sdram_data_inout,
      sdram_cke_out          => sdram_cke_out,
      sdram_cs_n_out         => sdram_cs_n_out,
      sdram_we_n_out         => sdram_we_n_out,
      sdram_ras_n_out        => sdram_ras_n_out,
      sdram_cas_n_out        => sdram_cas_n_out,
      sdram_dqm_out          => sdram_dqm_out,
      sdram_ba_out           => sdram_ba_out,
      sdram_address_out      => sdram_address_out
      );

end structural;
