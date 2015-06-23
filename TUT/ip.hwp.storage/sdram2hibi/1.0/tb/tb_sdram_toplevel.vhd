-------------------------------------------------------------------------------
-- Title      : tb_sdram_toplevel
-- Project    : 
-------------------------------------------------------------------------------
-- File       : tb_sdram_toplevel.vhd
-- Author     : 
-- Company    : 
-- Created    : 2006-10-03
-- Last update: 2006-10-24
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: Toplevel for SDRAM testbench
-------------------------------------------------------------------------------
-- Copyright (c) 2006 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2006-10-03  1.0      penttin5        Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_sdram_toplevel is
end tb_sdram_toplevel;

architecture behavioral of tb_sdram_toplevel is

  constant clk_per_c             : time    := 10 ns;
  constant clk_freq_mhz_c        : integer := 100;
  constant num_of_agents_c       : integer := 9;
  constant check_rd_data_c       : integer := 0;
  constant data_width_c          : integer := 32;
  constant addr_width_c          : integer := 32;
  constant fifo_depth_c          : integer := 5;
  constant tb_arb_type_c         : integer := 2;  -- variable prior

  -- SDRAM
  constant mem_addr_width_c    : integer := 22;
  constant block_read_length_c : integer := 640;

  -- sdram2hibi
  constant comm_width_c         : integer := 3;
  constant num_of_read_ports_c  : integer := 2;
  constant num_of_write_ports_c : integer := 2;
  constant offset_width_c       : integer := 16;
  constant rq_fifo_depth_c      : integer := 9;
  constant op_arb_type_c        : integer := 1;
  constant port_arb_type_c      : integer := 0;
  constant blk_rd_prior_c       : integer := 0;
  constant blk_wr_prior_c       : integer := 1;
  constant single_op_prior_c    : integer := 2;
  constant block_overlap_c      : integer := 1;
  
  type ag_addr_array_type is array (0 to num_of_agents_c - 1) of integer;
  constant ag_addr_array : ag_addr_array_type := (
    16#10000#, 16#20000#, 16#30000#, 16#40000#, 16#50000#, 16#60000#, 16#70000#, 16#80000#, 16#90000#
    );

  component arbiter
    generic (
      arb_width_g : integer;
      arb_type_g  : integer);
    port (
      clk       : in  std_logic;
      rst_n     : in  std_logic;
      req_in    : in  std_logic_vector(arb_width_g - 1 downto 0);
      hold_in   : in  std_logic_vector(arb_width_g - 1 downto 0);
      grant_out : out std_logic_vector(arb_width_g - 1 downto 0));
  end component;

  component fifo
    generic (
      data_width_g : integer := 0;
      depth_g      : integer := 0
      );
    port (
      clk       : in  std_logic;
      rst_n     : in  std_logic;
      data_in   : in  std_logic_vector(data_width_g - 1 downto 0);
      we_in     : in  std_logic;
      one_p_out : out std_logic;
      full_out  : out std_logic;
      data_out  : out std_logic_vector(data_width_g - 1 downto 0);
      re_in     : in  std_logic;
      empty_out : out std_logic;
      one_d_out : out std_logic
      );
  end component;

  component tb_agent
    generic (
      own_addr_g    : integer;
      check_rd_data : integer;
      data_width_g  : integer;
      addr_width_g  : integer);
    port (
      clk          : in  std_logic;
      rst_n        : in  std_logic;
      req_out      : out std_logic;
      hold_out     : out std_logic;
      grant_in     : in  std_logic;
      comm_out     : out std_logic_vector(2 downto 0);
      data_out     : out std_logic_vector(data_width_g - 1 downto 0);
      addr_out     : out std_logic_vector(addr_width_g - 1 downto 0);
      we_out       : out std_logic;
      re_out       : out std_logic;
      full_in      : in  std_logic;
      one_p_in     : in  std_logic;
      data_in      : in  std_logic_vector(data_width_g - 1 downto 0);
      addr_in      : in  std_logic_vector(data_width_g - 1 downto 0);
      empty_in     : in  std_logic;
      one_d_in     : in  std_logic;
      msg_req_out  : out std_logic;
      msg_hold_out : out std_logic;
      msg_grant_in : in  std_logic;
      msg_full_in  : in  std_logic;
      msg_one_p_in : in  std_logic;
      msg_data_in  : in  std_logic_vector(data_width_g - 1 downto 0);
      msg_addr_in  : in  std_logic_vector(data_width_g - 1 downto 0);
      msg_empty_in : in  std_logic;
      msg_one_d_in : in  std_logic;
      msg_data_out : out std_logic_vector(data_width_g - 1 downto 0);
      msg_addr_out : out std_logic_vector(addr_width_g - 1 downto 0);
      msg_we_out   : out std_logic;
      msg_re_out   : out std_logic);
  end component;

  component sdram2hibi
    generic (
      hibi_data_width_g    : integer;
      mem_data_width_g     : integer;
      mem_addr_width_g     : integer;
      comm_width_g         : integer;
      input_fifo_depth_g   : integer;
      num_of_read_ports_g  : integer;
      num_of_write_ports_g : integer;
      offset_width_g       : integer;
      rq_fifo_depth_g      : integer;
      op_arb_type_g        : integer;
      port_arb_type_g      : integer;
      blk_rd_prior_g       : integer;
      blk_wr_prior_g       : integer;
      single_op_prior_g    : integer;
      block_overlap_g      : integer);
    port (
      clk                        : in  std_logic;
      rst_n                      : in  std_logic;
      hibi_addr_in               : in  std_logic_vector(hibi_data_width_g - 1 downto 0);
      hibi_data_in               : in  std_logic_vector(hibi_data_width_g - 1 downto 0);
      hibi_comm_in               : in  std_logic_vector(comm_width_g - 1 downto 0);
      hibi_empty_in              : in  std_logic;
      hibi_re_out                : out std_logic;
      hibi_addr_out              : out std_logic_vector(hibi_data_width_g - 1 downto 0);
      hibi_data_out              : out std_logic_vector(hibi_data_width_g - 1 downto 0);
      hibi_comm_out              : out std_logic_vector(comm_width_g - 1 downto 0);
      hibi_full_in               : in  std_logic;
      hibi_we_out                : out std_logic;
      hibi_msg_addr_in           : in  std_logic_vector(hibi_data_width_g - 1 downto 0);
      hibi_msg_data_in           : in  std_logic_vector(hibi_data_width_g - 1 downto 0);
      hibi_msg_comm_in           : in  std_logic_vector(comm_width_g - 1 downto 0);
      hibi_msg_empty_in          : in  std_logic;
      hibi_msg_re_out            : out std_logic;
      hibi_msg_data_out          : out std_logic_vector(hibi_data_width_g - 1 downto 0);
      hibi_msg_addr_out          : out std_logic_vector(hibi_data_width_g - 1 downto 0);
      hibi_msg_comm_out          : out std_logic_vector(comm_width_g - 1 downto 0);
      hibi_msg_full_in           : in  std_logic;
      hibi_msg_we_out            : out std_logic;
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
      sdram_ctrl_data_out        : out std_logic_vector(31 downto 0);
      sdram_ctrl_data_in         : in  std_logic_vector(31 downto 0);
      sdram_ctrl_byte_select_out : out std_logic_vector(3 downto 0));
  end component;

  component sdram_controller
    generic (
      clk_freq_mhz_g      : integer;
      mem_addr_width_g    : integer;
      block_read_length_g : integer);
    port (
      clk                    : in    std_logic;
      rst_n                  : in    std_logic;
      command_in             : in    std_logic_vector(1 downto 0);
      address_in             : in    std_logic_vector(21 downto 0);
      data_amount_in         : in    std_logic_vector(mem_addr_width_g - 1
                                                      downto 0);
      byte_select_in         : in    std_logic_vector(3 downto 0);
      input_empty_in         : in    std_logic;
      input_one_d_in         : in    std_logic;
      output_full_in         : in    std_logic;
      data_in                : in    std_logic_vector(31 downto 0);
      write_on_out           : out   std_logic;
      busy_out               : out   std_logic;
      output_we_out          : out   std_logic;
      input_re_out           : out   std_logic;
      data_to_sdram2hibi_out : out   std_logic_vector(31 downto 0);
      sdram_data_inout       : inout std_logic_vector(31 downto 0);
      sdram_cke_out          : out   std_logic;
      sdram_cs_n_out         : out   std_logic;
      sdram_we_n_out         : out   std_logic;
      sdram_ras_n_out        : out   std_logic;
      sdram_cas_n_out        : out   std_logic;
      sdram_dqm_out          : out   std_logic_vector(3 downto 0);
      sdram_ba_out           : out   std_logic_vector(1 downto 0);
      sdram_address_out      : out   std_logic_vector(11 downto 0));
  end component;

  component mt48lc4m32b2
    generic (
      addr_bits : integer;
      data_bits : integer;
      col_bits  : integer;
      mem_sizes : integer);
    port (
      Dq    : inout std_logic_vector(data_bits - 1 downto 0);
      Addr  : in    std_logic_vector(addr_bits - 1 downto 0);
      Ba    : in    std_logic_vector(1 downto 0);
      Clk   : in    std_logic;
      Cke   : in    std_logic;
      Cs_n  : in    std_logic;
      Ras_n : in    std_logic;
      Cas_n : in    std_logic;
      We_n  : in    std_logic;
      Dqm   : in    std_logic_vector(3 downto 0)
      );
  end component;


  signal clk   : std_logic;
  signal rst_n : std_logic;

  -- arbiters
  signal req       : std_logic_vector(num_of_agents_c - 1 downto 0);
  signal grant     : std_logic_vector(num_of_agents_c - 1 downto 0);
  signal hold      : std_logic_vector(num_of_agents_c - 1 downto 0);
  signal msg_req   : std_logic_vector(num_of_agents_c - 1 downto 0);
  signal msg_grant : std_logic_vector(num_of_agents_c - 1 downto 0);
  signal msg_hold  : std_logic_vector(num_of_agents_c - 1 downto 0);

  type comm_type_arr is array (num_of_agents_c - 1 downto 0)
    of std_logic_vector(2 downto 0);
  type data_type_arr is array (num_of_agents_c - 1 downto 0)
    of std_logic_vector(data_width_c - 1 downto 0);
  type addr_type_arr is array (num_of_agents_c - 1 downto 0)
    of std_logic_vector(data_width_c - 1 downto 0);

  -- tb_agents -> dut_input fifo
  signal comm_tb_fifo     : comm_type_arr;
  signal data_tb_fifo     : data_type_arr;
  signal addr_tb_fifo     : addr_type_arr;
  signal msg_data_tb_fifo : data_type_arr;
  signal msg_addr_tb_fifo : addr_type_arr;
  signal we_tb_fifo       : std_logic_vector(num_of_agents_c - 1 downto 0);
  signal msg_we_tb_fifo   : std_logic_vector(num_of_agents_c - 1 downto 0);

  -- dut_input fifo -> tb_agents
  signal full_inp_fifo      : std_logic;
  signal one_p_inp_fifo     : std_logic;
  signal msg_full_inp_fifo  : std_logic;
  signal msg_one_p_inp_fifo : std_logic;
  signal we_inp_fifo        : std_logic;
  signal comm_inp_fifo      : std_logic_vector(2 downto 0);
  signal data_inp_fifo      : std_logic_vector(data_width_c - 1 downto 0);
  signal addr_inp_fifo      : std_logic_vector(addr_width_c - 1 downto 0);
  signal msg_we_inp_fifo    : std_logic;
  signal msg_data_inp_fifo  : std_logic_vector(data_width_c - 1 downto 0);
  signal msg_addr_inp_fifo  : std_logic_vector(addr_width_c - 1 downto 0);
  signal full_fifo_tb       : std_logic_vector(num_of_agents_c - 1 downto 0);
  signal one_p_fifo_tb      : std_logic_vector(num_of_agents_c - 1 downto 0);
  signal msg_full_fifo_tb   : std_logic_vector(num_of_agents_c - 1 downto 0);
  signal msg_one_p_fifo_tb  : std_logic_vector(num_of_agents_c - 1 downto 0);

  -- dut_output fifo -> tb_agents
  signal data_outp_fifo      : std_logic_vector(data_width_c - 1 downto 0);
  signal addr_outp_fifo      : std_logic_vector(addr_width_c - 1 downto 0);
  signal re_outp_fifo        : std_logic;
  signal empty_outp_fifo     : std_logic;
  signal one_d_outp_fifo     : std_logic;
  signal msg_data_outp_fifo  : std_logic_vector(data_width_c - 1 downto 0);
  signal msg_addr_outp_fifo  : std_logic_vector(addr_width_c - 1 downto 0);
  signal msg_re_outp_fifo    : std_logic;
  signal msg_empty_outp_fifo : std_logic;
  signal msg_one_d_outp_fifo : std_logic;

  signal data_fifo_tb      : data_type_arr;
  signal addr_fifo_tb      : addr_type_arr;
  signal re_tb_fifo        : std_logic_vector(num_of_agents_c - 1 downto 0);
  signal empty_fifo_tb     : std_logic_vector(num_of_agents_c - 1 downto 0);
  signal one_d_fifo_tb     : std_logic_vector(num_of_agents_c - 1 downto 0);
  signal msg_data_fifo_tb  : data_type_arr;
  signal msg_addr_fifo_tb  : addr_type_arr;
  signal msg_re_tb_fifo    : std_logic_vector(num_of_agents_c - 1 downto 0);
  signal msg_empty_fifo_tb : std_logic_vector(num_of_agents_c - 1 downto 0);
  signal msg_one_d_fifo_tb : std_logic_vector(num_of_agents_c - 1 downto 0);

  -- dut_input fifo -> dut
  signal empty_fifo_dut     : std_logic;
  signal msg_empty_fifo_dut : std_logic;
  signal comm_fifo_dut      : std_logic_vector(2 downto 0);
  signal data_fifo_dut      : std_logic_vector(data_width_c - 1 downto 0);
  signal addr_fifo_dut      : std_logic_vector(addr_width_c - 1 downto 0);
  signal msg_data_fifo_dut  : std_logic_vector(data_width_c - 1 downto 0);
  signal msg_addr_fifo_dut  : std_logic_vector(addr_width_c - 1 downto 0);

  -- output fifo -> dut
  signal full_outp_fifo     : std_logic;
  signal msg_full_outp_fifo : std_logic;

  -- dut -> input fifo
  signal re_dut_fifo     : std_logic;
  signal msg_re_dut_fifo : std_logic;

  -- dut -> output fifo
  signal addr_dut_fifo     : std_logic_vector(addr_width_c - 1 downto 0);
  signal data_dut_fifo     : std_logic_vector(data_width_c - 1 downto 0);
  signal we_dut_fifo       : std_logic;
  signal full_fifo_dut     : std_logic;
  signal msg_addr_dut_fifo : std_logic_vector(addr_width_c - 1 downto 0);
  signal msg_data_dut_fifo : std_logic_vector(data_width_c - 1 downto 0);
  signal msg_we_dut_fifo   : std_logic;
  signal msg_full_fifo_dut : std_logic;

  -- sdram_ctrl -> dut
  signal write_on_sdram_dut : std_logic;
  signal busy_sdram_dut     : std_logic;
  signal re_sdram_dut       : std_logic;
  signal we_sdram_dut       : std_logic;
  signal data_sdram_dut     : std_logic_vector(data_width_c - 1 downto 0);

  -- dut -> sdram_ctrl
  signal comm_dut_sdram     : std_logic_vector(1 downto 0);
  signal addr_dut_sdram     : std_logic_vector(mem_addr_width_c - 1 downto 0);
  signal amount_dut_sdram   : std_logic_vector(mem_addr_width_c - 1 downto 0);
  signal one_d_dut_sdram    : std_logic;
  signal empty_dut_sdram    : std_logic;
  signal full_dut_sdram     : std_logic;
  signal data_dut_sdram     : std_logic_vector(data_width_c - 1 downto 0);
  signal byte_sel_dut_sdram : std_logic_vector(data_width_c/8 - 1 downto 0);

  -- SDRAM controller <-> SDRAM
  signal sdram_dq    : std_logic_vector(31 downto 0);
  signal sdram_addr  : std_logic_vector(11 downto 0);
  signal sdram_ba    : std_logic_vector(1 downto 0);
  signal sdram_clk   : std_logic;
  signal sdram_cke   : std_logic;
  signal sdram_cs_n  : std_logic;
  signal sdram_ras_n : std_logic;
  signal sdram_cas_n : std_logic;
  signal sdram_we_n  : std_logic;
  signal sdram_dqm   : std_logic_vector(3 downto 0);

  signal sdram_dq_d    : std_logic_vector(31 downto 0);
  signal sdram_addr_d  : std_logic_vector(11 downto 0);
  signal sdram_ba_d    : std_logic_vector(1 downto 0);
  signal sdram_clk_d   : std_logic;
  signal sdram_cke_d   : std_logic;
  signal sdram_cs_n_d  : std_logic;
  signal sdram_ras_n_d : std_logic;
  signal sdram_cas_n_d : std_logic;
  signal sdram_we_n_d  : std_logic;
  signal sdram_dqm_d   : std_logic_vector(3 downto 0);

begin  -- behavioral

  check_sdram_access: postponed process (we_sdram_dut, comm_dut_sdram,
                               addr_dut_sdram, data_dut_sdram,
                               data_dut_fifo)
  begin  -- process check_sdram_access

    if comm_dut_sdram = "10" then
      -- write
      assert addr_dut_sdram(19 downto 16) = data_dut_sdram(19 downto 16)
        report "SDRAM is getting wrong write parameters"
        severity failure;
    elsif we_sdram_dut = '1' then
      assert data_dut_fifo(19 downto 16) = addr_dut_sdram(19 downto 16)
        report "SDRAM is getting wrong read parameters"
        severity failure;      
    end if;

  end process check_sdram_access;

  mux_agents : process (grant, msg_grant,
                        we_tb_fifo, msg_we_tb_fifo,
                        full_inp_fifo, msg_full_inp_fifo,
                        one_p_inp_fifo, msg_one_p_inp_fifo,
                        data_tb_fifo, msg_data_tb_fifo,
                        addr_tb_fifo, msg_addr_tb_fifo,
                        comm_tb_fifo,
                        addr_outp_fifo, msg_addr_outp_fifo,
                        data_outp_fifo, msg_data_outp_fifo,
                        re_tb_fifo, msg_re_tb_fifo,
                        empty_outp_fifo, msg_empty_outp_fifo,
                        we_inp_fifo, msg_we_inp_fifo,
                        re_outp_fifo, msg_re_outp_fifo,
                        one_d_outp_fifo, msg_one_d_outp_fifo)

  begin  -- process mux_agents

    -- mux agents to input fifo
    we_inp_fifo   <= '0';
    data_inp_fifo <= (others => '0');
    addr_inp_fifo <= (others => '0');
    full_fifo_tb  <= (others => '1');
    one_p_fifo_tb <= (others => '0');
    comm_inp_fifo <= (others => '0');
    for ag_num in num_of_agents_c - 1 downto 0 loop
      if grant(ag_num) = '1' then
        comm_inp_fifo         <= comm_tb_fifo(ag_num);
        we_inp_fifo           <= we_tb_fifo(ag_num);
        data_inp_fifo         <= data_tb_fifo(ag_num);
        addr_inp_fifo         <= addr_tb_fifo(ag_num);
        full_fifo_tb(ag_num)  <= full_inp_fifo and not(one_p_inp_fifo and we_inp_fifo);
        one_p_fifo_tb(ag_num) <= one_p_inp_fifo;
      end if;
    end loop;  -- i

    -- mux agents to input msg fifo
    msg_we_inp_fifo   <= '0';
    msg_data_inp_fifo <= (others => '0');
    msg_addr_inp_fifo <= (others => '0');
    msg_full_fifo_tb  <= (others => '1');
    msg_one_p_fifo_tb <= (others => '0');
    for ag_num in num_of_agents_c - 1 downto 0 loop
      if msg_grant(ag_num) = '1' then
        msg_we_inp_fifo           <= msg_we_tb_fifo(ag_num);
        msg_data_inp_fifo         <= msg_data_tb_fifo(ag_num);
        msg_addr_inp_fifo         <= msg_addr_tb_fifo(ag_num);
        msg_full_fifo_tb(ag_num)  <= msg_full_inp_fifo and not(msg_one_p_inp_fifo and msg_we_inp_fifo);
        msg_one_p_fifo_tb(ag_num) <= msg_one_p_inp_fifo;
      end if;
    end loop;  -- i

    -- mux output fifo to agents
    data_fifo_tb  <= (others => (others => '0'));
    addr_fifo_tb  <= (others => (others => '0'));
    re_outp_fifo  <= '0';
    empty_fifo_tb <= (others => '1');
    one_d_fifo_tb <= (others => '0');
    for ag_num in num_of_agents_c - 1 downto 0 loop
      if to_integer(unsigned(addr_outp_fifo)) = ag_addr_array(ag_num) then
        re_outp_fifo          <= re_tb_fifo(ag_num);
        data_fifo_tb(ag_num)  <= data_outp_fifo;
        addr_fifo_tb(ag_num)  <= addr_outp_fifo;
        empty_fifo_tb(ag_num) <= empty_outp_fifo and not(one_d_outp_fifo and re_outp_fifo);
        one_d_fifo_tb(ag_num) <= one_d_outp_fifo;
      end if;
    end loop;  -- i

    -- mux msg output fifo to agents
    msg_data_fifo_tb  <= (others => (others => '0'));
    msg_addr_fifo_tb  <= (others => (others => '0'));
    msg_re_outp_fifo  <= '0';
    msg_empty_fifo_tb <= (others => '1');
    msg_one_d_fifo_tb <= (others => '0');
    for ag_num in num_of_agents_c - 1 downto 0 loop
      if to_integer(unsigned(msg_addr_outp_fifo)) = ag_addr_array(ag_num) then
        msg_re_outp_fifo          <= msg_re_tb_fifo(ag_num);
        msg_data_fifo_tb(ag_num)  <= msg_data_outp_fifo;
        msg_addr_fifo_tb(ag_num)  <= msg_addr_outp_fifo;
        msg_empty_fifo_tb(ag_num) <= msg_empty_outp_fifo and not(msg_one_d_outp_fifo and msg_re_outp_fifo);
        msg_one_d_fifo_tb(ag_num) <= msg_one_d_outp_fifo;
      end if;
    end loop;  -- i
  end process mux_agents;

  gen_clk : process
  begin
    clk <= '1';
    wait for clk_per_c/2;
    clk <= '0';
    wait for clk_per_c/2;
  end process gen_clk;

  gen_rst : process
  begin
    rst_n <= '0';
    wait for 3*clk_per_c;
    wait for clk_per_c/3;
    rst_n <= '1';
    wait;
  end process gen_rst;

  arbiter_lo_1 : arbiter
    generic map (
      arb_width_g => num_of_agents_c,
      arb_type_g  => tb_arb_type_c)
    port map (
      clk       => clk,
      rst_n     => rst_n,
      req_in    => req,
      hold_in   => hold,
      grant_out => grant);

  arbiter_hi_1 : arbiter
    generic map (
      arb_width_g => num_of_agents_c,
      arb_type_g  => tb_arb_type_c)
    port map (
      clk       => clk,
      rst_n     => rst_n,
      req_in    => msg_req,
      hold_in   => msg_hold,
      grant_out => msg_grant);

  gen_tb_agents : for i in num_of_agents_c - 1 downto 0 generate
    tb_agent_i : tb_agent
      generic map (
        own_addr_g    => ag_addr_array(i),
        check_rd_data => check_rd_data_c,
        data_width_g  => data_width_c,
        addr_width_g  => addr_width_c)
      port map (
        clk          => clk,
        rst_n        => rst_n,
        req_out      => req(i),
        hold_out     => hold(i),
        grant_in     => grant(i),
        comm_out     => comm_tb_fifo(i),
        data_out     => data_tb_fifo(i),
        addr_out     => addr_tb_fifo(i),
        we_out       => we_tb_fifo(i),
        re_out       => re_tb_fifo(i),
        full_in      => full_fifo_tb(i),
        one_p_in     => one_p_fifo_tb(i),
        data_in      => data_fifo_tb(i),
        addr_in      => addr_fifo_tb(i),
        empty_in     => empty_fifo_tb(i),
        one_d_in     => one_d_fifo_tb(i),
        msg_req_out  => msg_req(i),
        msg_hold_out => msg_hold(i),
        msg_grant_in => msg_grant(i),
        msg_full_in  => msg_full_fifo_tb(i),
        msg_one_p_in => msg_one_p_fifo_tb(i),
        msg_data_in  => msg_data_fifo_tb(i),
        msg_addr_in  => msg_addr_fifo_tb(i),
        msg_empty_in => msg_empty_fifo_tb(i),
        msg_one_d_in => msg_one_d_fifo_tb(i),
        msg_data_out => msg_data_tb_fifo(i),
        msg_addr_out => msg_addr_tb_fifo(i),
        msg_we_out   => msg_we_tb_fifo(i),
        msg_re_out   => msg_re_tb_fifo(i));
  end generate gen_tb_agents;

  process (clk, rst_n)
  begin  -- process
    if rst_n = '0' then                 -- asynchronous reset (active low)
      data_sdram_dut <= (others => 'Z');
    elsif clk'event and clk = '1' then  -- rising clock edge
      data_sdram_dut <= sdram_dq_d;
    end if;
  end process;

  sdram2hibi_1 : sdram2hibi
    generic map (
      hibi_data_width_g    => data_width_c,
      mem_data_width_g     => data_width_c,
      mem_addr_width_g     => mem_addr_width_c,
      comm_width_g         => comm_width_c,
      input_fifo_depth_g   => fifo_depth_c,
      num_of_read_ports_g  => num_of_read_ports_c,
      num_of_write_ports_g => num_of_write_ports_c,
      offset_width_g       => offset_width_c,
      rq_fifo_depth_g      => rq_fifo_depth_c,
      op_arb_type_g        => op_arb_type_c,
      port_arb_type_g      => port_arb_type_c,
      blk_rd_prior_g       => blk_rd_prior_c,
      blk_wr_prior_g       => blk_wr_prior_c,
      single_op_prior_g    => single_op_prior_c,
      block_overlap_g      => block_overlap_c
      )
    port map (
      clk                        => clk,
      rst_n                      => rst_n,
      hibi_addr_in               => addr_fifo_dut,
      hibi_data_in               => data_fifo_dut,
      hibi_comm_in               => comm_fifo_dut,
      hibi_empty_in              => empty_fifo_dut,
      hibi_re_out                => re_dut_fifo,
      hibi_addr_out              => addr_dut_fifo,
      hibi_data_out              => data_dut_fifo,
--      hibi_comm_out              => comm_dut_fifo,
      hibi_full_in               => full_outp_fifo,
      hibi_we_out                => we_dut_fifo,
      hibi_msg_addr_in           => msg_addr_fifo_dut,
      hibi_msg_data_in           => msg_data_fifo_dut,
      hibi_msg_comm_in           => "000",  --hibi_msg_comm_tb_dut,
      hibi_msg_empty_in          => msg_empty_fifo_dut,
      hibi_msg_re_out            => msg_re_dut_fifo,
      hibi_msg_data_out          => msg_data_dut_fifo,
      hibi_msg_addr_out          => msg_addr_dut_fifo,
--      hibi_msg_comm_out          => hibi_msg_comm_dut_tb,
      hibi_msg_full_in           => msg_full_outp_fifo,
      hibi_msg_we_out            => msg_we_dut_fifo,
      sdram_ctrl_write_on_in     => write_on_sdram_dut,
      sdram_ctrl_comm_out        => comm_dut_sdram,
      sdram_ctrl_addr_out        => addr_dut_sdram,
      sdram_ctrl_data_amount_out => amount_dut_sdram,
      sdram_ctrl_input_one_d_out => one_d_dut_sdram,
      sdram_ctrl_input_empty_out => empty_dut_sdram,
      sdram_ctrl_output_full_out => full_dut_sdram,
      sdram_ctrl_busy_in         => busy_sdram_dut,
      sdram_ctrl_re_in           => re_sdram_dut,
      sdram_ctrl_we_in           => we_sdram_dut,
      sdram_ctrl_data_out        => data_dut_sdram,
      sdram_ctrl_data_in         => data_sdram_dut,
      sdram_ctrl_byte_select_out => byte_sel_dut_sdram);

  sdram_controller_1 : sdram_controller
    generic map (
      clk_freq_mhz_g      => clk_freq_mhz_c,
      mem_addr_width_g    => mem_addr_width_c,
      block_read_length_g => block_read_length_c)
    port map (
      clk                    => clk,
      rst_n                  => rst_n,
      command_in             => comm_dut_sdram,
      address_in             => addr_dut_sdram,
      data_amount_in         => amount_dut_sdram,
      byte_select_in         => byte_sel_dut_sdram,
      input_empty_in         => empty_dut_sdram,
      input_one_d_in         => one_d_dut_sdram,
      output_full_in         => full_dut_sdram,
      data_in                => data_dut_sdram,
      write_on_out           => write_on_sdram_dut,
      busy_out               => busy_sdram_dut,
      output_we_out          => we_sdram_dut,
      input_re_out           => re_sdram_dut,
      data_to_sdram2hibi_out => data_sdram_dut,
      sdram_data_inout       => sdram_dq,
      sdram_cke_out          => sdram_cke,
      sdram_cs_n_out         => sdram_cs_n,
      sdram_we_n_out         => sdram_we_n,
      sdram_ras_n_out        => sdram_ras_n,
      sdram_cas_n_out        => sdram_cas_n,
      sdram_dqm_out          => sdram_dqm,
      sdram_ba_out           => sdram_ba,
      sdram_address_out      => sdram_addr
      );

  fifo_inp_data : fifo
    generic map (
      data_width_g => data_width_c,
      depth_g      => fifo_depth_c)
    port map (
      clk       => clk,
      rst_n     => rst_n,
      data_in   => data_inp_fifo,
      we_in     => we_inp_fifo,
      one_p_out => one_p_inp_fifo,
      full_out  => full_inp_fifo,
      data_out  => data_fifo_dut,
      re_in     => re_dut_fifo,
      empty_out => empty_fifo_dut);
--      one_d_out => one_d_out);

  fifo_msg_inp_data : fifo
    generic map (
      data_width_g => data_width_c,
      depth_g      => fifo_depth_c)
    port map (
      clk       => clk,
      rst_n     => rst_n,
      data_in   => msg_data_inp_fifo,
      we_in     => msg_we_inp_fifo,
      one_p_out => msg_one_p_inp_fifo,
      full_out  => msg_full_inp_fifo,
      data_out  => msg_data_fifo_dut,
      re_in     => msg_re_dut_fifo,
      empty_out => msg_empty_fifo_dut);
--      one_d_out => msg_one_d_out);

  fifo_inp_addr : fifo
    generic map (
      data_width_g => data_width_c,
      depth_g      => fifo_depth_c)
    port map (
      clk      => clk,
      rst_n    => rst_n,
      data_in  => addr_inp_fifo,
      we_in    => we_inp_fifo,
--      one_p_out => one_p_fifo_tb,
--      full_out  => full_inp_fifo,
      data_out => addr_fifo_dut,
      re_in    => re_dut_fifo);
--      empty_out => empty_fifo_dut);
--      one_d_out => one_d_out);

  fifo_inp_comm : fifo
    generic map (
      data_width_g => 3,
      depth_g      => fifo_depth_c)
    port map (
      clk      => clk,
      rst_n    => rst_n,
      data_in  => comm_inp_fifo,
      we_in    => we_inp_fifo,
--      one_p_out => one_p_fifo_tb,
--      full_out  => full_inp_fifo,
      data_out => comm_fifo_dut,
      re_in    => re_dut_fifo);
--      empty_out => empty_fifo_dut);
--      one_d_out => one_d_out);

  fifo_msg_inp_addr : fifo
    generic map (
      data_width_g => data_width_c,
      depth_g      => fifo_depth_c)
    port map (
      clk      => clk,
      rst_n    => rst_n,
      data_in  => msg_addr_inp_fifo,
      we_in    => msg_we_inp_fifo,
--      one_p_out => msg_one_p_out,
--      full_out  => msg_full_inp_fifo,
      data_out => msg_addr_fifo_dut,
      re_in    => msg_re_dut_fifo);
--      empty_out => msg_empty_fifo_dut,
--      one_d_out => msg_one_d_out);

  fifo_outp_data : fifo
    generic map (
      data_width_g => data_width_c,
      depth_g      => fifo_depth_c)
    port map (
      clk       => clk,
      rst_n     => rst_n,
      data_in   => data_dut_fifo,
      we_in     => we_dut_fifo,
--      one_p_out => one_p_outp_fifo,
      full_out  => full_outp_fifo,
      data_out  => data_outp_fifo,
      re_in     => re_outp_fifo,
      empty_out => empty_outp_fifo,
      one_d_out => one_d_outp_fifo);

  fifo_msg_outp_data : fifo
    generic map (
      data_width_g => data_width_c,
      depth_g      => fifo_depth_c)
    port map (
      clk       => clk,
      rst_n     => rst_n,
      data_in   => msg_data_dut_fifo,
      we_in     => msg_we_dut_fifo,
--      one_p_out => msg_one_p_outp_fifo,
      full_out  => msg_full_outp_fifo,
      data_out  => msg_data_outp_fifo,
      re_in     => msg_re_outp_fifo,
      empty_out => msg_empty_outp_fifo,
      one_d_out => msg_one_d_outp_fifo);

  fifo_outp_addr : fifo
    generic map (
      data_width_g => data_width_c,
      depth_g      => fifo_depth_c)
    port map (
      clk      => clk,
      rst_n    => rst_n,
      data_in  => addr_dut_fifo,
      we_in    => we_dut_fifo,
--      one_p_out => one_p_dut_fifo,
--      full_out  => full_fifo,
      data_out => addr_outp_fifo,
      re_in    => re_outp_fifo);
--      empty_out => empty_fifo_tb);
--      one_d_out => one_d_out);

  fifo_msg_outp_addr : fifo
    generic map (
      data_width_g => data_width_c,
      depth_g      => fifo_depth_c)
    port map (
      clk      => clk,
      rst_n    => rst_n,
      data_in  => msg_addr_dut_fifo,
      we_in    => msg_we_dut_fifo,
--      one_p_out => one_p_dut_fifo,
--      full_out  => full_fifo,
      data_out => msg_addr_outp_fifo,
      re_in    => msg_re_outp_fifo);
--      empty_out => empty_fifo_tb);
--      one_d_out => one_d_out);


  sdram_dq_d    <= sdram_dq    after 2 ns;
  sdram_addr_d  <= sdram_addr  after 2 ns;
  sdram_ba_d    <= sdram_ba    after 2 ns;
  sdram_cke_d   <= sdram_cke   after 2 ns;
  sdram_cs_n_d  <= sdram_cs_n  after 2 ns;
  sdram_cas_n_d <= sdram_cas_n after 2 ns;
  sdram_ras_n_d <= sdram_ras_n after 2 ns;
  sdram_we_n_d  <= sdram_we_n  after 2 ns;
  sdram_dqm_d   <= sdram_dqm   after 2 ns;

  mt48lc4m32b2_1 : mt48lc4m32b2
    generic map (
      addr_bits => 12,
      data_bits => 32,
      col_bits  => 8,
      mem_sizes => 1048575)
    port map (
      Dq    => sdram_dq_d,
      Addr  => sdram_addr_d,
      Ba    => sdram_ba_d,
      Clk   => clk,
      Cke   => sdram_cke_d,
      Cs_n  => sdram_cs_n_d,
      Ras_n => sdram_ras_n_d,
      Cas_n => sdram_cas_n_d,
      We_n  => sdram_we_n_d,
      Dqm   => sdram_dqm_d);
end behavioral;
