-------------------------------------------------------------------------------
-- File        : tb_sdram2hibi.vhd
-- Description : Testbench for SDRAM (block transfer) ctrl
-- Author      : Erno Salminen
-- Date        : 29.10.2004
-- Modified    : 
--
-- Every agent can have only one port at a time, so at least 2 agents are needed
-- to test concurrent read and write!!!
--
-- Supports blocking and non-blocking requests
-- Supports old and new sdram2hibi config methods
-- 
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.txt_util.all;

entity tb_sdram2hibi is
  generic (
    dut_ver_g        : integer := 7;    -- Sdram2hibi version
    rq_fifo_depth_g  : integer := 3;  -- Request fifo depth(0=non-blocking others=blocking)
    num_of_r_ports_g : integer := 4;    -- Number of read ports
    num_of_w_ports_g : integer := 4);   -- Number of write ports
end tb_sdram2hibi;

architecture behavioral of tb_sdram2hibi is

  -- NUM OF TB AGENTS
  constant n_agents_c : integer := 16;
  type read_integer_array is array (n_agents_c + 1 downto 0) of integer;

  signal old_config_method : integer;

  -- TESTBENCH AGENT ADDRESSES
  signal agent_addrs_r : read_integer_array;

  constant re_delay_c        : integer := 5;
  constant msg_rx_depth_c    : integer := 20;
  constant rx_depth_c        : integer := 20;
  constant msg_tx_depth_c    : integer := 3;
  constant tx_depth_c        : integer := 2;
  constant rq_timeout_c      : integer := 1000;  -- Timeout for request response
  constant hibi_data_width   : integer := 32;
  constant mem_data_width    : integer := 32;
  constant mem_addr_width    : integer := 22;
  constant comm_width        : integer := 3;
  constant depth             : integer := 10;
  constant period_c          : time    := 10 ns;
  constant clk_freq_c        : integer := 100;
  constant sdram_hibi_addr_c : integer := 16#09000000#;

  -----------------------------------------------------------------------------
  -- 
  --  _____                        ________      ________________
  -- |     |                      |        |    |                |    
  -- |     |   <- msg tx fifo <-  |        |    |                | <-
  -- |     |   <-     tx_fifo <-  |        | <- | sdram 50MHz    |       tb
  -- |  tb |                      | ctrl   |    | cas 3          |
  -- |     |   ->     rx_fifo ->  | (dut)  |    |                | ->
  -- |     |   -> msg rx fifo ->  |        | -> |                |
  -- | ____|                      |________|    |________________|
  --                                  A
  --                                  |__ tb?
  --
  -----------------------------------------------------------------------------


  -- Testbench signals
  signal clk   : std_logic;
  signal rst_n : std_logic;

  type check_state_type is (wait_comm, wait_busy);
  signal check_state : check_state_type;

  type state_type is (idle, read_state, write_state);
  signal state_r : state_type;

  type tb_state_type is (rst, rq_wr, conf_wr, rq_rd, conf_rd, send_wr_data,
                         wait_pending, conf_pending);
  signal tb_state : tb_state_type;

  type port_offset_array is array(n_agents_c + 1 downto 0) of integer;
  signal port_offsets_r  : port_offset_array;
  signal rd_wr_rq        : std_logic_vector(n_agents_c + 1 downto 0);
  type write_integer_array is array (n_agents_c + 1 downto 0) of integer;
  signal wr_dst_addr     : write_integer_array;
  signal wr_data_r        : write_integer_array;
  signal wr_data_check_r : write_integer_array;
  signal wr_offset       : write_integer_array;

  signal rd_src_addr : read_integer_array;

  constant single_write_c : integer := n_agents_c;
  constant single_read_c : integer  := n_agents_c + 1;
  
  signal tb_sdram_write   : std_logic;
  signal re_cnt_r         : integer;
  signal test_num         : integer;
  signal iteration        : integer;
  signal i_dbg            : integer;
  -- Signals for port request checking
  signal rq_timeout_cnt_r : integer;
  signal rq_port          : std_logic;
  signal got_resp         : std_logic;
  signal got_resp_vec     : std_logic_vector(n_agents_c - 1 downto 0);
  signal wait_resp_vec    : std_logic_vector(n_agents_c - 1 downto 0);
  signal rq_vec           : std_logic_vector(n_agents_c - 1 downto 0);
  signal pending_rqs      : integer;

  signal single_op_addr  : integer;
  signal single_op_wr_addr  : integer;
  signal new_rd_conf     : std_logic;
  signal new_rd_idx      : integer;
  signal new_rd_addr     : integer;
  signal new_rd_amount   : integer;
  signal new_wr_conf     : std_logic;
  signal new_wr_idx      : integer;
  signal new_wr_addr     : integer;
  signal new_wr_amount   : integer;
  signal wr_addrs_r      : port_offset_array;
  signal rd_addrs_r      : port_offset_array;
  signal rd_amounts_r    : port_offset_array;
  signal wr_amounts_r    : port_offset_array;
  signal curr_rd_ag_r    : integer;
  signal curr_wr_ag_r    : integer;
  signal clr_offset_r    : std_logic;
  signal clr_idx_r       : integer;
  signal n_free_rd_ports : integer;
  signal n_free_wr_ports : integer;
  signal sending_data    : std_logic_vector(n_agents_c - 1 downto 0);
  signal data_sent       : std_logic_vector(n_agents_c - 1 downto 0);

  -- Signals tb <-> rxfifo
  signal c_a_d_tb_rxfifo : std_logic_vector (hibi_data_width+hibi_data_width+comm_width-1 downto 0);
  signal data_tb_rxfifo  : std_logic_vector (hibi_data_width-1 downto 0);
  signal addr_tb_rxfifo  : std_logic_vector (hibi_data_width-1 downto 0);
  signal comm_tb_rxfifo  : std_logic_vector (comm_width-1 downto 0);
  signal we_tb_rxfifo    : std_logic;
  signal full_rxfifo_tb  : std_logic;
  signal one_p_rxfifo_tb : std_logic;

  -- Signals tb <-> msg_rxfifo
  signal msg_c_a_d_tb_rxfifo : std_logic_vector (hibi_data_width+hibi_data_width+comm_width-1 downto 0);
  signal msg_data_tb_rxfifo  : std_logic_vector (hibi_data_width-1 downto 0);
  signal msg_addr_tb_rxfifo  : std_logic_vector (hibi_data_width-1 downto 0);
  signal msg_comm_tb_rxfifo  : std_logic_vector (comm_width-1 downto 0);
  signal msg_we_tb_rxfifo    : std_logic;
  signal msg_full_rxfifo_tb  : std_logic;
  signal msg_one_p_rxfifo_tb : std_logic;

  -- Signals tb <-> txfifo
  signal re_tb_txfifo    : std_logic;
  signal c_a_d_txfifo_tb : std_logic_vector(hibi_data_width+hibi_data_width+comm_width - 1 downto 0);
  signal data_txfifo_tb  : std_logic_vector(hibi_data_width - 1 downto 0);
  signal addr_txfifo_tb  : std_logic_vector(hibi_data_width -1 downto 0);
  signal comm_txfifo_tb  : std_logic_vector(comm_width - 1 downto 0);
  signal empty_txfifo_tb : std_logic;
  signal one_d_txfifo_tb : std_logic;

  -- Signals tb <-> msg_txfifo
  signal msg_re_tb_txfifo    : std_logic;
  signal msg_c_a_d_txfifo_tb : std_logic_vector(hibi_data_width+hibi_data_width+comm_width - 1 downto 0);
  signal msg_data_txfifo_tb  : std_logic_vector(hibi_data_width - 1 downto 0);
  signal msg_addr_txfifo_tb  : std_logic_vector(hibi_data_width - 1 downto 0);
  signal msg_comm_txfifo_tb  : std_logic_vector(comm_width - 1 downto 0);
  signal msg_empty_txfifo_tb : std_logic;
  signal msg_one_d_txfifo_tb : std_logic;

  -- Signals rxfifo <-> dut
  signal c_a_d_rxfifo_dut : std_logic_vector (hibi_data_width+hibi_data_width+comm_width-1 downto 0);
  signal addr_rxfifo_dut  : std_logic_vector(hibi_data_width - 1 downto 0);
  signal data_rxfifo_dut  : std_logic_vector(hibi_data_width - 1 downto 0);
  signal comm_rxfifo_dut  : std_logic_vector(comm_width - 1 downto 0);
  signal empty_rxfifo_dut : std_logic;
  signal re_dut_rxfifo    : std_logic;

  -- Signals txfifo <-> dut
  signal full_txfifo_dut  : std_logic;
  signal one_p_txfifo_dut : std_logic;
  signal c_a_d_dut_txfifo : std_logic_vector (hibi_data_width+hibi_data_width+comm_width-1 downto 0);
  signal addr_dut_txfifo  : std_logic_vector(hibi_data_width - 1 downto 0);
  signal data_dut_txfifo  : std_logic_vector(hibi_data_width - 1 downto 0);
  signal comm_dut_txfifo  : std_logic_vector(comm_width - 1 downto 0);
  signal we_dut_txfifo    : std_logic;

  -- Signals msg_rxfifo <-> dut
  signal msg_c_a_d_rxfifo_dut : std_logic_vector (hibi_data_width+hibi_data_width+comm_width-1 downto 0);
  signal msg_addr_rxfifo_dut  : std_logic_vector(hibi_data_width - 1 downto 0);
  signal msg_data_rxfifo_dut  : std_logic_vector(hibi_data_width - 1 downto 0);
  signal msg_comm_rxfifo_dut  : std_logic_vector(comm_width - 1 downto 0);
  signal msg_empty_rxfifo_dut : std_logic;
  signal msg_one_d_rxfifo_dut : std_logic;
  signal msg_re_dut_rxfifo    : std_logic;

  -- Signals msg_txfifo <-> dut
  signal msg_full_txfifo_dut  : std_logic;
  signal msg_one_p_txfifo_dut : std_logic;
  signal msg_c_a_d_dut_txfifo : std_logic_vector(hibi_data_width + hibi_data_width + comm_width - 1 downto 0);
  signal msg_addr_dut_txfifo  : std_logic_vector(hibi_data_width - 1 downto 0);
  signal msg_data_dut_txfifo  : std_logic_vector(hibi_data_width - 1 downto 0);
  signal msg_comm_dut_txfifo  : std_logic_vector(comm_width - 1 downto 0);
  signal msg_we_dut_txfifo    : std_logic;

  -- Signals dut <-> sdram_controller
  signal write_on_tb_dut : std_logic;
  signal busy_tb_dut     : std_logic;
  signal re_tb_dut       : std_logic;
  signal we_tb_dut       : std_logic;
  signal data_tb_dut     : std_logic_vector(31 downto 0);
  signal comm_dut_tb     : std_logic_vector(1 downto 0);
  signal addr_dut_tb     : std_logic_vector(21 downto 0);
  signal amount_dut_tb   : std_logic_vector(21 downto 0);

  signal byte_sel_dut_tb : std_logic_vector(3 downto 0);
  signal empty_dut_tb    : std_logic;
  signal one_d_dut_tb    : std_logic;
  signal full_dut_tb     : std_logic;
  signal data_dut_tb     : std_logic_vector(31 downto 0);

  -- sdram_ctrl <-> tb
  signal sdram_data_inout : std_logic_vector(31 downto 0);
  signal sdram_cke_out    : std_logic;
  signal sdram_cs_n_out   : std_logic;
  signal sdram_we_n_out   : std_logic;
  signal sdram_ras_n_out  : std_logic;
  signal sdram_cas_n_out  : std_logic;
  signal sdram_dqm_out    : std_logic_vector(3 downto 0);
  signal sdram_ba_out     : std_logic_vector(1 downto 0);
  signal sdram_addr_out   : std_logic_vector(11 downto 0);
  signal was_busy_r       : std_logic;

  signal hibi_addr_mask : std_logic_vector(mem_addr_width - 1 downto 0) := (others => '1');

begin  -- behavioral

  sel_old_config_method : if dut_ver_g < 7 generate
    old_config_method <= 1;
  end generate sel_old_config_method;
  sel_new_config_method : if dut_ver_g >= 7 generate
    old_config_method <= 0;
  end generate sel_new_config_method;

  -- Generate addresses fo testbench agents.
  -- First agent's address is 1000
  -- Second's 2000 and so on...
  gen_tb_agent_addrs : for i in 0 to n_agents_c + 1 generate
    agent_addrs_r(i) <= 16#01000000# * (i+1) + 16#1000# * (i+1);
  end generate;  -- gen_tb_agent_addrs

  -- Concurrent assignments
  -- tb -> rx_fifo
  c_a_d_tb_rxfifo     <= comm_tb_rxfifo & addr_tb_rxfifo & data_tb_rxfifo;
  msg_c_a_d_tb_rxfifo <= msg_comm_tb_rxfifo & msg_addr_tb_rxfifo & msg_data_tb_rxfifo;

  -- rx_fifo -> dut
  comm_rxfifo_dut <= c_a_d_rxfifo_dut (hibi_data_width + hibi_data_width + comm_width-1 downto hibi_data_width + hibi_data_width)
                     when empty_rxfifo_dut = '0' else (others => 'Z');
  addr_rxfifo_dut <= c_a_d_rxfifo_dut (hibi_data_width + hibi_data_width -1 downto hibi_data_width)
                     when empty_rxfifo_dut = '0' else (others => 'Z');
  data_rxfifo_dut <= c_a_d_rxfifo_dut (hibi_data_width -1 downto 0)
                     when empty_rxfifo_dut = '0' else (others => 'Z');

  msg_comm_rxfifo_dut <= msg_c_a_d_rxfifo_dut (hibi_data_width + hibi_data_width + comm_width-1 downto hibi_data_width + hibi_data_width)
                         when msg_empty_rxfifo_dut = '0' else (others => 'Z');
  msg_addr_rxfifo_dut <= msg_c_a_d_rxfifo_dut (hibi_data_width + hibi_data_width -1 downto hibi_data_width)
                         when msg_empty_rxfifo_dut = '0' else (others => 'Z');
  msg_data_rxfifo_dut <= msg_c_a_d_rxfifo_dut (hibi_data_width -1 downto 0)
                         when msg_empty_rxfifo_dut = '0' else (others => 'Z');

  -- dut -> tx_fifo
  c_a_d_dut_txfifo     <= comm_dut_txfifo & addr_dut_txfifo & data_dut_txfifo;
  msg_c_a_d_dut_txfifo <= msg_comm_dut_txfifo & msg_addr_dut_txfifo & msg_data_dut_txfifo;

  -- tx_fifo -> tb
  comm_txfifo_tb <= c_a_d_txfifo_tb (hibi_data_width + hibi_data_width + comm_width-1 downto hibi_data_width + hibi_data_width)
                    when empty_txfifo_tb = '0' else (others => 'Z');
  addr_txfifo_tb <= c_a_d_txfifo_tb (hibi_data_width + hibi_data_width -1 downto hibi_data_width)
                    when empty_txfifo_tb = '0' else (others => 'Z');
  data_txfifo_tb <= c_a_d_txfifo_tb (hibi_data_width -1 downto 0)
                    when empty_txfifo_tb = '0' else (others => 'Z');

  msg_comm_txfifo_tb <= msg_c_a_d_txfifo_tb (hibi_data_width + hibi_data_width + comm_width-1 downto hibi_data_width + hibi_data_width)
                        when msg_empty_txfifo_tb = '0' else (others => 'Z');
  msg_addr_txfifo_tb <= msg_c_a_d_txfifo_tb (hibi_data_width + hibi_data_width -1 downto hibi_data_width)
                        when msg_empty_txfifo_tb = '0' else (others => 'Z');
  msg_data_txfifo_tb <= msg_c_a_d_txfifo_tb (hibi_data_width -1 downto 0)
                        when msg_empty_txfifo_tb = '0' else (others => 'Z');

  -- 1) PROC
  Generate_input : postponed process

    ---------------------------------------------------------------------------
    -- Write to rx_fifo
    ---------------------------------------------------------------------------
    procedure WriteToFifo (
      addr_to_fifo : in integer;
      data_to_fifo : in integer;
      comm_to_fifo : in integer) is

    begin  --procedure

      while full_rxfifo_tb = '1' loop
        wait for period_c;
      end loop;

      data_tb_rxfifo <= std_logic_vector(to_unsigned (data_to_fifo, hibi_data_width));
      comm_tb_rxfifo <= std_logic_vector(to_unsigned (comm_to_fifo, comm_width));
      addr_tb_rxfifo <= std_logic_vector(to_unsigned (addr_to_fifo, hibi_data_width));
      we_tb_rxfifo   <= '1';

      wait for period_c;

      we_tb_rxfifo   <= '0';
      data_tb_rxfifo <= (others => 'Z');
      comm_tb_rxfifo <= (others => 'Z');
      addr_tb_rxfifo <= (others => 'Z');

    end WriteToFifo;

    ---------------------------------------------------------------------------
    -- Write to msg_rx_fifo
    ---------------------------------------------------------------------------
    procedure WriteToMsgFifo (
      addr_to_fifo : in integer;
      data_to_fifo : in integer;
      comm_to_fifo : in integer) is

    begin  --procedure

      while msg_full_rxfifo_tb = '1' loop
        wait for period_c;
      end loop;

      msg_addr_tb_rxfifo <= std_logic_vector(to_unsigned (addr_to_fifo, hibi_data_width));
      msg_data_tb_rxfifo <= std_logic_vector(to_unsigned (data_to_fifo, hibi_data_width));
      msg_comm_tb_rxfifo <= std_logic_vector(to_unsigned (comm_to_fifo, comm_width));
      msg_we_tb_rxfifo   <= '1';

      wait for period_c;

      msg_addr_tb_rxfifo <= (others => 'Z');
      msg_data_tb_rxfifo <= (others => 'Z');
      msg_comm_tb_rxfifo <= (others => 'Z');
      msg_we_tb_rxfifo   <= '0';

    end WriteToMsgFifo;

    ---------------------------------------------------------------------------
    -- Request read port from DUT
    --
    -- If agent has a port offset /= 0, we assume that the previous operation
    -- hasn't completed and we wait until it is finished and port_offset reset
    ---------------------------------------------------------------------------
    procedure rq_read_port (
      agent_number : in integer) is

    begin

--      assert n_free_rd_ports /= 0 report "Waiting for free read ports" severity note;
--      while n_free_rd_ports = 0 loop
--        wait for period_c;
--      end loop;

      assert port_offsets_r(agent_number) = 0
        report "TB: agent " & str(agent_number)
        & " waiting for previous operation before reserving new read port"
        severity note;

      while port_offsets_r(agent_number) /= 0 loop
        wait for period_c;
      end loop;

      while msg_full_rxfifo_tb = '1' loop
        wait for period_c;
      end loop;

      if clr_idx_r /= agent_number or clr_offset_r = '0' then
        
        rq_port                <= '1';
        rd_wr_rq(agent_number) <= '0';
        rq_vec(agent_number)   <= '1';
        msg_addr_tb_rxfifo     <= std_logic_vector(to_unsigned (0, hibi_data_width));
        msg_data_tb_rxfifo     <= std_logic_vector(to_unsigned (agent_addrs_r(agent_number), hibi_data_width));
        msg_comm_tb_rxfifo     <= std_logic_vector(to_unsigned (3, comm_width));
        msg_we_tb_rxfifo       <= '1';

        wait for period_c;
--      assert false
--        report "Agent " & str(agent_number) & " requested read port"
--        severity note;
        rq_port              <= '0';
        rq_vec(agent_number) <= '0';

        msg_addr_tb_rxfifo <= (others => 'Z');
        msg_data_tb_rxfifo <= (others => 'Z');
        msg_comm_tb_rxfifo <= (others => 'Z');
        msg_we_tb_rxfifo   <= '0';
      end if;

    end procedure;  -- rq_read_port

    ---------------------------------------------------------------------------
    -- Request write port from DUT
    --
    -- If agent has a port offset /= 0, we assume that the previous operation
    -- hasn't completed and we wait until it is finished and port_offset reset
    ---------------------------------------------------------------------------
    procedure rq_write_port (
      agent_number : in integer) is
    begin

--      assert n_free_wr_ports /= 0 report "Waiting for free write ports" severity note;
--      while n_free_wr_ports = 0 loop
--        wait for period_c;
--      end loop;

      assert port_offsets_r(agent_number) = 0
        report "TB: agent " & str(agent_number)
        & " waiting for previous operation before reserving new write port"
        severity note;

      while port_offsets_r(agent_number) /= 0 loop
        wait for period_c;
      end loop;

      while msg_full_rxfifo_tb = '1' loop
        wait for period_c;
      end loop;

      rq_port                <= '1';
      rq_vec(agent_number)   <= '1';
      rd_wr_rq(agent_number) <= '1';
      --assert false report "Fifo full. Cannot write" severity note;
      msg_addr_tb_rxfifo     <= std_logic_vector(to_unsigned (1, hibi_data_width));
      msg_data_tb_rxfifo     <= std_logic_vector(to_unsigned (agent_addrs_r(agent_number), hibi_data_width));
      msg_comm_tb_rxfifo     <= std_logic_vector(to_unsigned (3, comm_width));
      msg_we_tb_rxfifo       <= '1';

      wait for period_c;
--      assert false
--        report "Agent " & str(agent_number) & " requested write port"
--        severity note;
      rq_port              <= '0';
      rq_vec(agent_number) <= '0';

      msg_addr_tb_rxfifo <= (others => 'Z');
      msg_data_tb_rxfifo <= (others => 'Z');
      msg_comm_tb_rxfifo <= (others => 'Z');
      msg_we_tb_rxfifo   <= '0';

    end procedure;  -- rq_write_port

    ---------------------------------------------------------------------------
    -- Configure read port
    --
    -- If previous read operation hasn't finished, asserts failure
    -- If we haven't got response for port request, we wait for it.
    -- If we get zero response(i.e. ports not available), we skip configuring
    ---------------------------------------------------------------------------
    procedure configure_read_port (
      agent_number : in integer;
      amount       : in integer) is
    begin

      assert rd_amounts_r(agent_number) = 0
        report "TB ERROR: Tried to configure valid read port"
        severity failure;

      assert got_resp_vec(agent_number) = '1'
        report "Waiting for port offset before configuring read port"
        severity note;
      while got_resp_vec(agent_number) = '0' loop
        wait for period_c;
      end loop;

      assert port_offsets_r(agent_number) /= 0
        report "Agent " & str(agent_number) & " No reserved read port, can not configure"
        severity note;

      if port_offsets_r(agent_number) /= 0 then

--        assert false report "Configure read agent" severity note;
        -- src addr
        WriteToMsgFifo(port_offsets_r(agent_number), agent_addrs_r(agent_number), 3);
        -- amount/width
        WriteToMsgFifo(port_offsets_r(agent_number)+old_config_method*1, amount, 3);

        -- height&offset
        WriteToMsgFifo(port_offsets_r(agent_number)+old_config_method*2, 0, 3);

        -- Signal to check_sdram_addrs process that we have configured a read port
        new_rd_conf   <= '1';
        new_rd_idx    <= agent_number;
        new_rd_addr   <= agent_addrs_r(agent_number);
        new_rd_amount <= amount;
        wait for period_c;
        new_rd_conf   <= '0';
        new_rd_idx    <= 0;
        new_rd_addr   <= 0;
        new_rd_amount <= 0;

        -- return address
        WriteToMsgFifo(port_offsets_r(agent_number)+old_config_method*3, 1, 3);
        rd_src_addr(agent_number) <= rd_src_addr(agent_number) + amount;
      end if;

    end procedure;

    ---------------------------------------------------------------------------
    -- Configure write port
    --
    -- If previous write operation hasn't finished, asserts failure
    -- If we haven't got response for port request, we wait for it.
    -- If we get zero response(i.e. ports not available) we skip configuring
    ---------------------------------------------------------------------------
    procedure configure_write_port (
      agent_number : in integer;
      amount       : in integer) is
    begin

      assert wr_amounts_r(agent_number) = 0
        report "TB ERROR: Tried to configure valid write port"
        severity failure;

      assert got_resp_vec(agent_number) = '1'
        report "Waiting for port offset before configuring write port"
        severity note;
      while got_resp_vec(agent_number) = '0' loop
        wait for period_c;
      end loop;

      assert port_offsets_r(agent_number) /= 0
        report "Agent " & str(agent_number) & " No reserved write port, can not configure"
        severity note;

      if port_offsets_r(agent_number) /= 0 then
        -- dst_addr
        WriteToMsgFifo(port_offsets_r(agent_number), agent_addrs_r(agent_number), 3);
        -- amount/width
        WriteToMsgFifo(port_offsets_r(agent_number)+old_config_method*1, amount, 3);

        -- height&offset
        WriteToMsgFifo(port_offsets_r(agent_number)+old_config_method*2, 0, 3);

        -- Signal to check_sdram_addrs process that we have configured a read port
        new_wr_conf   <= '1';
        new_wr_idx    <= agent_number;
        new_wr_addr   <= agent_addrs_r(agent_number);
        new_wr_amount <= amount;
        wait for period_c;
--        assert false
--          report "Agent " & str(agent_number) & " configure write port"
--          severity note;
        new_wr_conf   <= '0';
        new_wr_idx    <= 0;
        new_wr_addr   <= 0;
        new_wr_amount <= 0;

        wr_dst_addr(agent_number) <= wr_dst_addr(agent_number) + amount;  --write_amount(w);

      end if;
    end procedure;

    procedure single_op (
      constant r_w    : in std_logic;
      constant amount : in integer) is
    begin  -- single_op

      if r_w = '1' then
        new_wr_conf    <= '1';
        new_wr_idx     <= single_write_c;
        new_wr_addr    <= agent_addrs_r(single_write_c);
        new_wr_amount  <= amount;
        single_op_addr <= agent_addrs_r(single_write_c);
      else
        new_rd_conf    <= '1';
        new_rd_idx     <= single_read_c;
        new_rd_addr    <= agent_addrs_r(single_read_c);
        new_rd_amount  <= amount;
        single_op_addr <= agent_addrs_r(single_read_c);
      end if;

      wait for period_c;

      new_rd_conf   <= '0';
      new_rd_idx    <= 0;
      new_rd_addr   <= 0;
      new_rd_amount <= 0;
      new_wr_conf   <= '0';
      new_wr_idx    <= 0;
      new_wr_addr   <= 0;
      new_wr_amount <= 0;

      if r_w = '1' then
        -- write
        for i in 0 to amount - 1 loop

      while full_rxfifo_tb = '1' loop
        wait for period_c;
      end loop;

      data_tb_rxfifo <= std_logic_vector(to_unsigned(
        wr_data_r(single_write_c), hibi_data_width));
      comm_tb_rxfifo <= std_logic_vector(to_unsigned(2, comm_width));
      addr_tb_rxfifo <= std_logic_vector(to_unsigned(
        single_op_addr, hibi_data_width));
      we_tb_rxfifo   <= '1';

      wr_data_r(single_write_c) <= wr_data_r(single_write_c) + 1;
      single_op_addr <= single_op_addr + 1;
      wait for period_c;

      we_tb_rxfifo   <= '0';
      data_tb_rxfifo <= (others => 'Z');
      comm_tb_rxfifo <= (others => 'Z');
      addr_tb_rxfifo <= (others => 'Z');
--          WriteToFifo(single_op_addr, wr_data_r(single_write_c), 2);
        end loop;  -- i
      else
        -- read
        for i in 0 to amount - 1 loop
          while full_rxfifo_tb = '1' loop
            wait for period_c;
          end loop;

      data_tb_rxfifo <= std_logic_vector(to_unsigned(
        agent_addrs_r(single_read_c), hibi_data_width));
      comm_tb_rxfifo <= std_logic_vector(to_unsigned(0, comm_width));
      addr_tb_rxfifo <= std_logic_vector(to_unsigned(
        single_op_addr, hibi_data_width));
      we_tb_rxfifo   <= '1';

      single_op_addr <= single_op_addr + 1;
      wait for period_c;

      we_tb_rxfifo   <= '0';
      data_tb_rxfifo <= (others => 'Z');
      comm_tb_rxfifo <= (others => 'Z');
      addr_tb_rxfifo <= (others => 'Z');
--          WriteToFifo(single_op_addr, agent_addrs_r(single_read_c), 0);
        end loop;  -- i        
      end if;
    end single_op;
    ---------------------------------------------------------------------------
    -- Writes write data to rx fifo
    ---------------------------------------------------------------------------
    procedure write_input_data (
      agent_number : in integer;
      amount       : in integer) is
    begin

      for i in 0 to amount - 1 loop
        sending_data(agent_number) <= '1';

        while full_rxfifo_tb = '1' loop
          wait for period_c;
        end loop;

        data_tb_rxfifo <= std_logic_vector(to_unsigned(
          wr_data_r(agent_number), hibi_data_width));

        comm_tb_rxfifo <= std_logic_vector(to_unsigned(2, comm_width));
        addr_tb_rxfifo <= std_logic_vector(to_unsigned(
          port_offsets_r(agent_number)+3*old_config_method, hibi_data_width));

        we_tb_rxfifo   <= '1';

        wr_data_r(agent_number)    <= wr_data_r(agent_number) + 1;
        wait for period_c;

--        WriteToFifo(port_offsets_r(agent_number)+3*old_config_method, wr_data_r(agent_number), 2);
      end loop;  -- i
      we_tb_rxfifo   <= '0';
      data_tb_rxfifo <= (others => 'Z');
      comm_tb_rxfifo <= (others => 'Z');
      addr_tb_rxfifo <= (others => 'Z');
      sending_data(agent_number) <= '0';

    end procedure;

-------------------------------------------------------------------------------
-- TESTBENCH
-------------------------------------------------------------------------------
    variable j : integer;
  begin  -- process Generate_input

    -- test sequence
    -- 0 wait for reset
    -- 1 write to empty fifo and read so that it is empty again
    -- 2 write to fifo until there is only one place left
    -- Wait for reset

    -- reset
    data_tb_rxfifo     <= (others => 'Z');
    addr_tb_rxfifo     <= (others => 'Z');
    comm_tb_rxfifo     <= (others => 'Z');
    we_tb_rxfifo       <= '0';
    msg_data_tb_rxfifo <= (others => 'Z');
    msg_addr_tb_rxfifo <= (others => 'Z');
    msg_comm_tb_rxfifo <= (others => 'Z');
    msg_we_tb_rxfifo   <= '0';
    wr_offset          <= (others => 0);
    rq_port            <= '0';
    new_rd_conf        <= '0';
    new_rd_idx         <= 0;
    new_rd_addr        <= 0;
    new_rd_amount      <= 0;
    new_wr_conf        <= '0';
    new_wr_idx         <= 0;
    new_wr_addr        <= 0;
    new_wr_amount      <= 0;
    rd_wr_rq           <= (others => '0');
    rq_vec             <= (others => '0');
    tb_state           <= rst;
    test_num           <= 0;
    iteration          <= 0;
    sending_data       <= (others => '0');
    for i in 0 to n_agents_c loop
      rd_src_addr(i) <= i * 4096;       --X"1000";
    end loop;  -- i

    for i in 0 to n_agents_c loop
      wr_dst_addr(i) <= i * 4096;       --X"1000";
      wr_data_r(i)   <= i * 100;
    end loop;  -- i


    wait for period_c/2;
    wait for period_c/5;

    if rst_n = '0' then
      wait until rst_n = '1';
    end if;

    wait for period_c/2;
    wait for period_c/5;

    wait for period_c;
    while true loop

      tb_state <= rq_wr;

      -- TEST 1, request n_agents_c write ports and
      --         configure num_of_write_ports write ports
      --         send write data
      test_num  <= 1;
      iteration <= 0;


      for iter in 0 to 1000 loop
        tb_state <= rq_wr;
        for i in 0 to n_agents_c/2 - 1 loop
          -- request write port if agent is not waiting for response and
          -- has no valid port
          if wait_resp_vec(i) = '0'
            and port_offsets_r(i) = 0 then
            i_dbg <= i;
            rq_write_port(i);
          end if;
        end loop;  -- i

        -- single op reads, if previous single op reads have been completed
        if rd_amounts_r(single_read_c) = 0 then
          single_op('0', 5);
        end if;

        -- single op writes, if previous single op writes have been completed
        if wr_amounts_r(single_write_c) = 0 then
          single_op('1', 5);          
        end if;
        for i in n_agents_c/2 to n_agents_c - 1 loop
          -- request read port if agent is not waiting for response and
          -- has no valid port
          if wait_resp_vec(i) = '0'
            and port_offsets_r(i) = 0 then
            i_dbg <= i;
            rq_read_port(i);
          end if;
        end loop;  -- i

        -- single op writes, if previous single op writes have been completed
        if wr_amounts_r(single_write_c) = 0 then
          single_op('1', 5);          
        end if;
        -- single op reads, if previous single op reads have been completed
        if rd_amounts_r(single_read_c) = 0 then
          single_op('0', 5);
        end if;
        tb_state  <= conf_wr;
        iteration <= iteration + 1;
        for i in 0 to n_agents_c/2 - 1 loop
          -- configure write port if agent has got port offset and
          -- hasn't been configured yet
          if port_offsets_r(i) /= 0
            and wr_amounts_r(i) = 0
            and not(clr_idx_r = i and clr_offset_r = '1') then
            i_dbg <= i;
            configure_write_port(i, 1+i*2);
          end if;
        end loop;  -- i

        -- single op reads, if previous single op reads have been completed
        if rd_amounts_r(single_read_c) = 0 then
          single_op('0', 5);
        end if;
        -- single op writes, if previous single op writes have been completed
        if wr_amounts_r(single_write_c) = 0 then
          single_op('1', 5);          
        end if;
        for i in n_agents_c/2 to n_agents_c - 1 loop
          -- configure read port if agent has got port offset and
          -- hasn't been configured yet
          if port_offsets_r(i) /= 0
            and rd_amounts_r(i) = 0
            and not(clr_idx_r = i and clr_offset_r = '1') then
            i_dbg <= i;
            configure_read_port(i, 1+i*2);
          end if;
        end loop;  -- i

        tb_state <= send_wr_data;
        for i in 0 to n_agents_c/2 - 1 loop
          -- send write data if agent has configured write port
          -- and write data hasn't been sent
          if wr_amounts_r(i) /= 0 and data_sent(i) = '0' then
            i_dbg <= i;
            write_input_data(i, 1+i*2);
          end if;
        end loop;  -- i
        wait for period_c;
      end loop;  -- iter

      -- finish test 1 by completing unfinished operations
      for i in n_agents_c/2 - 1 downto 0 loop
        
        wait for period_c;
        tb_state <= conf_wr;
        for i in 0 to n_agents_c/2 - 1 loop
          -- configure write port if agent has got port offset and
          -- hasn't been configured yet
          if port_offsets_r(i) /= 0 and wr_amounts_r(i) = 0
            and not(clr_idx_r = i and clr_offset_r = '1') then
            i_dbg <= i;
            configure_write_port(i, 1+i*2);
          end if;
        end loop;  -- i
        tb_state <= send_wr_data;

        for i in 0 to n_agents_c/2 - 1 loop
          -- send write data if agent has configured write port
          -- and doesn't have write data
          if wr_amounts_r(i) /= 0 and data_sent(i) = '0' then
            i_dbg <= i;
            write_input_data(i, 1+i*2);
          end if;
        end loop;  -- i
        wait for period_c*20;
      end loop;  -- i

      wait for period_c*50;

-------------------------------------------------------------------------------
-- Test 2:
-- Port operations of length 1
-------------------------------------------------------------------------------
      test_num  <= 2;
      iteration <= 0;

      for iter in 0 to 1000 loop

        for i in 0 to n_agents_c/2 - 1 loop

          -- single op reads, if previous single op reads have been completed
          if rd_amounts_r(single_read_c) = 0 then
            single_op('0', 1);
          end if;
          -- single op writes, if previous single op writes have been completed
          if wr_amounts_r(single_write_c) = 0 then
            single_op('1', 1);          
          end if;

          tb_state <= rq_rd;
          -- request read port if agent is not waiting for response and
          -- has no valid port
          if wait_resp_vec(i+n_agents_c/2) = '0'
            and port_offsets_r(i+n_agents_c/2) = 0 then
            i_dbg <= i;
            rq_read_port(i+n_agents_c/2);
          end if;

          tb_state <= rq_wr;
          -- request write port if agent is not waiting for response and
          -- has no valid port
          if wait_resp_vec(i) = '0'
            and port_offsets_r(i) = 0 then
            i_dbg <= i;
            rq_write_port(i);
          end if;

          -- single op reads, if previous single op reads have been completed
          if rd_amounts_r(single_read_c) = 0 then
            single_op('0', 1);
          end if;
          -- single op writes, if previous single op writes have been completed
          if wr_amounts_r(single_write_c) = 0 then
            single_op('1', 1);          
          end if;

          -- configure read port if agent has got port offset and
          -- hasn't been configured yet
          tb_state  <= conf_rd;
          if port_offsets_r(i+n_agents_c/2) /= 0 and rd_amounts_r(i+n_agents_c/2) = 0
            and not(clr_idx_r = i+n_agents_c/2 and clr_offset_r = '1') then
            i_dbg <= i;
            configure_read_port(i+n_agents_c/2, 1);
          end if;

          wait for period_c;

          tb_state  <= conf_wr;
          if port_offsets_r(i) /= 0
            and wr_amounts_r(i) = 0
            and not(clr_idx_r = i and clr_offset_r = '1') then
            configure_write_port(i, 1);
          end if;

          -- single op reads, if previous single op reads have been completed
          if rd_amounts_r(single_read_c) = 0 then
            single_op('0', 1);
          end if;
          -- single op writes, if previous single op writes have been completed
          if wr_amounts_r(single_write_c) = 0 then
            single_op('1', 1);          
          end if;
          -- send write data
          tb_state <= send_wr_data;
          if wr_amounts_r(i) /= 0 and data_sent(i) = '0' then
            i_dbg <= i;
            write_input_data(i, 1);
          end if;
        end loop;  -- i
        iteration <= iteration + 1;
      end loop;  -- iter
      

      -- finish test 2 by completing unfinished operations
      for i in n_agents_c/2 - 1 downto 0 loop
        
        wait for period_c;
        tb_state <= conf_rd;
        for i in 0 to n_agents_c/2 - 1 loop
          -- configure read port if agent has got port offset but
          -- hasn't been configured yet
          if port_offsets_r(i+n_agents_c/2) /= 0 and rd_amounts_r(i+n_agents_c/2) = 0
            and not(clr_idx_r = i+n_agents_c/2 and clr_offset_r = '1') then
            i_dbg <= i;
            configure_read_port(i+n_agents_c/2, 1);
          end if;
          if port_offsets_r(i) /= 0 and wr_amounts_r(i) = 0
            and not(clr_idx_r = i and clr_offset_r = '1') then
            i_dbg <= i;
            configure_write_port(i, 1);
          end if;
          if wr_amounts_r(i) /= 0 and data_sent(i) = '0' then
            i_dbg <= i;
            write_input_data(i, 1);
          end if;
        end loop;  -- i

        wait for period_c*50;
      end loop;  -- i

      -- wait for previous test
      for i in 0 to n_agents_c - 1 loop
        while port_offsets_r(i) /= 0 loop
          wait for period_c;
        end loop;
      end loop;  -- i

      wait for 20*period_c;

      for i in n_agents_c - 1 downto 0 loop
        assert port_offsets_r(i) = 0
          report "Transfers not finished" severity failure;
        assert wait_resp_vec(i) = '0'
          report "Waiting for port offset" severity failure;
      end loop;  -- i
      assert false report "++++++++++++++" severity note;
      assert false report "Test completed" severity note;
      assert false report "++++++++++++++" severity failure;
    end loop;

    wait;
  end process Generate_input;


-------------------------------------------------------------------------------
-- Check that we get responses for port requests
-------------------------------------------------------------------------------
  count_rqs_and_resps : process(clk, rst_n)
  begin  -- count_rqs_and_resps
    if rst_n = '0' then
      pending_rqs      <= 0;
      rq_timeout_cnt_r <= 0;
    elsif clk'event and clk = '1' then

      -- Keep count of port requests and responses
      if rq_port = '1' and got_resp = '0' then
        pending_rqs <= pending_rqs + 1;
      elsif rq_port = '0' and got_resp = '1' then
        pending_rqs <= pending_rqs - 1;
      else
        pending_rqs <= pending_rqs;
      end if;

      -- How long have we waited for response?
      if pending_rqs > 0 and got_resp = '0' then
        rq_timeout_cnt_r <= rq_timeout_cnt_r + 1;
      else
        rq_timeout_cnt_r <= 0;
      end if;

      -- Check that we don't get more responses than requested
      assert pending_rqs >= 0
        report "Got more ports than requested"
        severity failure;

      -- Check that we get responses for requests
--      assert rq_timeout_cnt_r < rq_timeout_c
--        report "Didn't get response for port request"
--        severity failure;

    end if;
  end process;

-------------------------------------------------------------------------------
-- Read port request responses and store port offsets
-------------------------------------------------------------------------------
  rd_rq_resps : process (clk, rst_n)
    variable check_resp_addr_v : std_logic := '0';
    variable n_free_r_ports_v  : integer;
    variable n_free_w_ports_v  : integer;
  begin  -- process rd_rq_resps
    if rst_n = '0' then                 -- asynchronous reset (active low)
      msg_re_tb_txfifo <= '0';
      got_resp         <= '0';
      port_offsets_r   <= (others => 0);
      n_free_rd_ports  <= num_of_r_ports_g;
      n_free_wr_ports  <= num_of_w_ports_g;
      got_resp_vec     <= (others => '0');
      wait_resp_vec    <= (others => '0');
      re_cnt_r         <= 0;

    elsif clk'event and clk = '1' then  -- rising clock edge

      -- Delay reading to test DUT when msg_tx_fifo is full
      if msg_empty_txfifo_tb = '0' then
        if re_cnt_r = re_delay_c then
          msg_re_tb_txfifo <= '1';
          re_cnt_r         <= 0;
        else
          msg_re_tb_txfifo <= '0';
          re_cnt_r         <= re_cnt_r + 1;
        end if;
      end if;

      n_free_r_ports_v := n_free_rd_ports;
      n_free_w_ports_v := n_free_wr_ports;

      check_resp_addr_v := '0';

      -- Clear got_resp, when new request is issued
      got_resp_vec <= got_resp_vec and not(rq_vec);


      for i in n_agents_c - 1 downto 0 loop
        if rq_vec(i) = '1' then
          -- Set wait_resp_vec, when agent requests port
          wait_resp_vec(i) <= '1';
        else
          -- Clear wait_resp when we get a response
          wait_resp_vec(i) <= wait_resp_vec(i) and not(got_resp_vec(i));
        end if;
      end loop;  -- i

      -- Check that we don't get more read ports than
      -- the actual number of read ports
      assert n_free_rd_ports >= 0
        report "Got more read ports than num_of_r_ports"
        severity failure;
      assert n_free_rd_ports <= num_of_r_ports_g
                                report "More free read ports than num_of_r_ports"
                                severity failure;

      -- Check that we don't get more write ports than
      -- the actual number of write ports
      assert n_free_wr_ports >= 0
        report "Got more write ports than num_of_w_ports"
        severity failure;
      assert n_free_wr_ports <= num_of_w_ports_g
                                report "More free write ports than num_of_w_ports"
                                severity failure;

      -- If operation finishes we must clear the port offset and
      -- increase the number of free ports
      if clr_offset_r = '1'
        and clr_idx_r /= single_read_c and clr_idx_r /= single_write_c then
        assert false report "Agent " & str(clr_idx_r) & " operation finished" severity note;
        port_offsets_r(clr_idx_r) <= 0;
        if rd_wr_rq(clr_idx_r) = '0' then
          n_free_r_ports_v := n_free_r_ports_v + 1;
        else
          n_free_w_ports_v := n_free_w_ports_v + 1;
        end if;
      end if;

      -- Read DUT responses from msg_tx_fifo
      if msg_empty_txfifo_tb = '0' and msg_re_tb_txfifo = '1' then

        -- Fifo not empty so we got a response
        got_resp <= '1';

        -- zero is a valid response(no ports available)
        if to_integer(unsigned(msg_addr_txfifo_tb)) = 0 then
          check_resp_addr_v := '1';
        end if;

        -- Check which testbench agent got response
        for i in 0 to n_agents_c - 1 loop
          if to_integer(unsigned(msg_addr_txfifo_tb)) = agent_addrs_r(i) then
            check_resp_addr_v := '1';   -- response to valid address
            got_resp_vec(i)   <= '1';
            port_offsets_r(i) <= to_integer(unsigned(msg_data_txfifo_tb));
            assert false
              report "Agent " & str(i) & " got port offset "
              & str(to_integer(unsigned(msg_data_txfifo_tb)))
              severity note;

            -- Was this a response to read or write port request?
            if rd_wr_rq(i) = '0' and to_integer(unsigned(msg_data_txfifo_tb)) /= 0 then

              -- Response to read port request,
              -- reduce the number of free read ports
              n_free_r_ports_v := n_free_r_ports_v - 1;
            elsif rd_wr_rq(i) = '1' and to_integer(unsigned(msg_data_txfifo_tb)) /= 0 then

              -- Response to write port request,
              -- reduce the number of free write ports
              n_free_w_ports_v := n_free_w_ports_v - 1;
            end if;
          end if;

        end loop;  -- i

        -- Check that the response address is one of the agent addresses
        assert check_resp_addr_v = '1'
          report "Got port rq response to illegal address"
          severity failure;

      else

        -- Fifo was empty so no responses this time
        got_resp <= '0';

      end if;

      n_free_rd_ports <= n_free_r_ports_v;
      n_free_wr_ports <= n_free_w_ports_v;

    end if;
  end process rd_rq_resps;

-------------------------------------------------------------------------------
-- Monitors SDRAM operations and checks the amounts and addresses of SDRAM
-- reads and writes. Signals to other processes if port operations finish
-------------------------------------------------------------------------------
  check_sdram_addrs : process (clk, rst_n)
    variable check_addr_v : std_logic;
    variable data_sent_v  : std_logic_vector(n_agents_c - 1 downto 0);
    variable agent_addr_v : std_logic_vector(mem_addr_width - 1 downto 0);
  begin  -- process check_sdram_addrs
    if rst_n = '0' then                 -- asynchronous reset (active low)
      rd_addrs_r      <= (others => 0);
      wr_addrs_r      <= (others => 0);
      rd_amounts_r    <= (others => 0);
      wr_amounts_r    <= (others => 0);
      curr_rd_ag_r    <= 0;
      curr_wr_ag_r    <= 0;
      state_r         <= idle;
      clr_offset_r    <= '0';
      clr_idx_r       <= 0;
      was_busy_r      <= '0';
      for i in 0 to n_agents_c loop
        wr_data_check_r(i) <= i * 100;
      end loop;  -- i
      data_sent       <= (others => '0');
      agent_addr_v    := (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge

      data_sent_v := data_sent or sending_data;

      clr_offset_r <= '0';
      clr_idx_r    <= 0;

      check_addr_v := '0';

      was_busy_r <= busy_tb_dut;

      if new_rd_conf = '1' then

        -- configure read port procedure has configured a read port,
        -- store read address and amount
        rd_addrs_r(new_rd_idx)   <= new_rd_addr;
        rd_amounts_r(new_rd_idx) <= new_rd_amount;

      elsif new_wr_conf = '1' then

        -- configure write port procedure has configured a write port
        -- store write address and amount
        wr_addrs_r(new_wr_idx)   <= new_wr_addr;
        wr_amounts_r(new_wr_idx) <= new_wr_amount;
      end if;

      case state_r is

        when idle =>

          if busy_tb_dut = '1' and was_busy_r = '0' then

            case comm_dut_tb is

              when "00" =>

                -- nop
                state_r <= idle;

              when "01" =>

                -- read command to SDRAM
                -- check which port is used
                for i in 0 to n_agents_c - 1 loop

                  -- mask out the HIBI part of agent addr
                  agent_addr_v := std_logic_vector(
                    to_unsigned(rd_addrs_r(i), mem_addr_width));
                  if addr_dut_tb = agent_addr_v then
--                  if to_integer(unsigned(addr_dut_tb)) = rd_addrs_r(i) then
                    check_addr_v := '1';
                    curr_rd_ag_r <= i;
                    -- amount must be > 0
                    assert rd_amounts_r(i) /= 0
                      report "Agent " & str(i) & " Read with amount 0"
                      severity failure;
                    assert rd_amounts_r(i) = to_integer(unsigned(amount_dut_tb))
                      report "Agent " & str(i) & " Read amount corrupted"
                      severity failure;
                  end if;
                end loop;  -- i

                -- check if this is single op read
                agent_addr_v := std_logic_vector(
                  to_unsigned(rd_addrs_r(single_read_c), mem_addr_width));
                if addr_dut_tb = agent_addr_v then
                  check_addr_v := '1';
                  curr_rd_ag_r <= single_read_c;
                  -- amount must be = 1
                  assert 1 = to_integer(unsigned(amount_dut_tb))
                    report "Single op read with amount /= 1"
                    severity failure;
                end if;
                -- did we find a corresponding read port?

                assert check_addr_v = '1'
                  report "Unexpected read. Addr: " & str(to_integer(unsigned(addr_dut_tb)))
                  severity failure;
                state_r <= read_state;

              when "10" =>

                -- write command to SDRAM
                -- check which port is used
                for i in 0 to n_agents_c - 1 loop
                  agent_addr_v := std_logic_vector(
                    to_unsigned(wr_addrs_r(i), mem_addr_width));
                  if addr_dut_tb = agent_addr_v then
--                  if to_integer(unsigned(addr_dut_tb)) = wr_addrs_r(i) then
                    check_addr_v := '1';
                    curr_wr_ag_r <= i;
                    -- amount must be > 0
                    -- amount must be > 0
                    assert wr_amounts_r(i) /= 0
                      report "Agent " & str(i) & " write with amount 0"
                      severity failure;
                    assert wr_amounts_r(i) = to_integer(unsigned(amount_dut_tb))
                      report "Agent " & str(i) & " write amount corrupted"
                      severity failure;
                  end if;
                end loop;  -- i

                -- check if this is single op write
                agent_addr_v := std_logic_vector(
                  to_unsigned(wr_addrs_r(single_write_c), mem_addr_width));
                if addr_dut_tb = agent_addr_v then
                  check_addr_v := '1';
                  curr_wr_ag_r <= single_write_c;
                  -- amount must be = 1
                  assert 1 = to_integer(unsigned(amount_dut_tb))
                    report "Single op write with amount /= 1"
                    severity failure;
                end if;

                -- did we find a corresponding write port?
                assert check_addr_v = '1'
                  report "Unexpected write. Addr: " & str(to_integer(unsigned(addr_dut_tb)))
                  severity failure;
                state_r <= write_state;

              when others =>
                assert false report "Illegal command to ctrl" severity failure;
                state_r <= idle;
            end case;
          end if;

        when read_state =>

          if we_tb_dut = '1' then

            -- SDRAM controller writes read data to DUT
            -- check that DUT doesn't get data when amount is 0
            if curr_rd_ag_r < n_agents_c then
              
              assert rd_amounts_r(curr_rd_ag_r) /= 0
                report "Agent: " & str(curr_rd_ag_r) & " read while amount 0"
                severity failure;
            elsif curr_rd_ag_r = single_read_c then              
              assert rd_amounts_r(curr_rd_ag_r) /= 0
                report "Unexpected single op read"
                severity failure;
            else
              assert false report "Unexpected read" severity failure;
            end if;

            if rd_amounts_r(curr_rd_ag_r) = 1 and curr_rd_ag_r /= n_agents_c then
              -- Read operation finishes
              -- signal to rd_rq_resps process that operation finishes
              clr_idx_r    <= curr_rd_ag_r;
              clr_offset_r <= '1';
            end if;

            -- Update address and amount
            rd_addrs_r(curr_rd_ag_r)   <= rd_addrs_r(curr_rd_ag_r) + 1;
            rd_amounts_r(curr_rd_ag_r) <= rd_amounts_r(curr_rd_ag_r) - 1;
          end if;

          -- Does SDRAM operation continue?
          if busy_tb_dut = '0' then
            -- SDRAM operation finishes
            state_r <= idle;
          else
            -- SDRAM operation continues
            state_r <= state_r;
          end if;

        when write_state =>

          if write_on_tb_dut = '1' then

            -- SDRAM controller write
            -- Check that we don't do too many writes
            if curr_wr_ag_r < n_agents_c then

              assert wr_amounts_r(curr_wr_ag_r) /= 0
                report "Agent: " & str(curr_wr_ag_r) & " write while amount 0"
                severity failure;
            else
              assert wr_amounts_r(curr_wr_ag_r) /= 0
                report "Unexpected single op write"
                severity failure;
            end if;

            if wr_amounts_r(curr_wr_ag_r) = 1 and curr_wr_ag_r /= n_agents_c then
              -- Write operation finishes
              -- signal to rd_rq_resps process that operation finishes and
              -- clear data_sent of corresponding port
              clr_idx_r                 <= curr_wr_ag_r;
              clr_offset_r              <= '1';
              data_sent_v(curr_wr_ag_r) := '0';
            end if;

            -- Update address, amount check
            wr_addrs_r(curr_wr_ag_r)   <= wr_addrs_r(curr_wr_ag_r) + 1;
            wr_amounts_r(curr_wr_ag_r) <= wr_amounts_r(curr_wr_ag_r) - 1;
          end if;

          if sdram_cs_n_out = '0' and sdram_ras_n_out = '1' and
            sdram_cas_n_out = '0' and sdram_we_n_out = '0' then
            -- SDRAM write
            if curr_wr_ag_r < n_agents_c then

              assert wr_data_check_r(curr_wr_ag_r) = to_integer(unsigned(sdram_data_inout))
                report "Agent " & str(curr_wr_ag_r) & " Write data corrupted"
                severity failure;
            elsif curr_wr_ag_r = single_write_c then
              assert wr_data_check_r(curr_wr_ag_r) = to_integer(unsigned(sdram_data_inout))
                report "Agent " & str(curr_wr_ag_r) & " Single op write data corrupted"
                severity failure;
            else
              assert false report "Unexcpected write" severity failure;
            end if;
            -- update data check
            wr_data_check_r(curr_wr_ag_r) <= wr_data_check_r(curr_wr_ag_r) + 1;
          end if;
            -- Does SDRAM operation continue?
          if busy_tb_dut = '0' then
            -- SDRAM operation finishes
            state_r <= idle;
          else
            -- SDRAM operation continues
            state_r <= state_r;
          end if;
      end case;
      data_sent <= data_sent_v;

    end if;

  end process check_sdram_addrs;

  -- 4) PROC (ASYNC)
  CLOCK1 : process                      -- generate clock signal for design
  begin
    clk <= '1';
    wait for period_c/2;
    clk <= '0';
    wait for period_c/2;
  end process CLOCK1;

  -- 5) PROC (ASYNC)
  RESET : process
  begin
    rst_n <= '0';                       -- Reset the testsystem
    wait for 6*period_c;                -- Wait 
    rst_n <= '1';                       -- de-assert reset
    wait;
  end process RESET;

  DUT : entity work.sdram2hibi

    generic map(
      hibi_data_width_g    => hibi_data_width,
      mem_data_width_g     => mem_data_width,
      mem_addr_width_g     => mem_addr_width,
      comm_width_g         => comm_width,
      input_fifo_depth_g   => 5,
      num_of_read_ports_g  => num_of_r_ports_g,
      num_of_write_ports_g => num_of_w_ports_g,
      rq_fifo_depth_g      => rq_fifo_depth_g
      )
    port map(
      clk   => clk,
      rst_n => rst_n,

      hibi_addr_in  => addr_rxfifo_dut,
      hibi_data_in  => data_rxfifo_dut,
      hibi_comm_in  => comm_rxfifo_dut,
      hibi_empty_in => empty_rxfifo_dut,
      hibi_re_out   => re_dut_rxfifo,

      hibi_addr_out => addr_dut_txfifo,
      hibi_data_out => data_dut_txfifo,
      hibi_comm_out => comm_dut_txfifo,
      hibi_full_in  => full_txfifo_dut,
      hibi_we_out   => we_dut_txfifo,

      hibi_msg_addr_in  => msg_addr_rxfifo_dut,
      hibi_msg_data_in  => msg_data_rxfifo_dut,
      hibi_msg_comm_in  => msg_comm_rxfifo_dut,
      hibi_msg_empty_in => msg_empty_rxfifo_dut,
      hibi_msg_re_out   => msg_re_dut_rxfifo,

      hibi_msg_addr_out => msg_addr_dut_txfifo,
      hibi_msg_data_out => msg_data_dut_txfifo,
      hibi_msg_comm_out => msg_comm_dut_txfifo,
      hibi_msg_full_in  => msg_full_txfifo_dut,
      hibi_msg_we_out   => msg_we_dut_txfifo,

      sdram_ctrl_write_on_in     => write_on_tb_dut,
      sdram_ctrl_comm_out        => comm_dut_tb,
      sdram_ctrl_addr_out        => addr_dut_tb,
      sdram_ctrl_data_amount_out => amount_dut_tb,
      sdram_ctrl_input_empty_out => empty_dut_tb,
      sdram_ctrl_input_one_d_out => one_d_dut_tb,
      sdram_ctrl_output_full_out => full_dut_tb,
      sdram_ctrl_busy_in         => busy_tb_dut,
      sdram_ctrl_re_in           => re_tb_dut,
      sdram_ctrl_we_in           => we_tb_dut,
      sdram_ctrl_data_out        => data_dut_tb,
      sdram_ctrl_data_in         => data_tb_dut,
      sdram_ctrl_byte_select_out => byte_sel_dut_tb
      );


  rx_fifo : entity work.fifo
    generic map (
      data_width_g => hibi_data_width+hibi_data_width+comm_width,
      depth_g      => rx_depth_c
      )
    port map (
      clk       => clk,
      rst_n     => rst_n,
      data_in   => c_a_d_tb_rxfifo,
      we_in     => we_tb_rxfifo,
      full_out  => full_rxfifo_tb,
      one_p_out => one_p_rxfifo_tb,

      data_out  => c_a_d_rxfifo_dut,
      re_in     => re_dut_rxfifo,
      empty_out => empty_rxfifo_dut

      );

  msg_rx_fifo : entity work.fifo
    generic map (
      data_width_g => hibi_data_width+hibi_data_width+comm_width,
      depth_g      => msg_rx_depth_c
      )
    port map (
      clk       => clk,
      rst_n     => rst_n,
      data_in   => msg_c_a_d_tb_rxfifo,
      we_in     => msg_we_tb_rxfifo,
      full_out  => msg_full_rxfifo_tb,
      one_p_out => msg_one_p_rxfifo_tb,

      data_out  => msg_c_a_d_rxfifo_dut,
      re_in     => msg_re_dut_rxfifo,
      empty_out => msg_empty_rxfifo_dut,
      one_d_out => msg_one_d_rxfifo_dut

      );


  tx_fifo : entity work.fifo
    generic map (
      data_width_g => hibi_data_width+hibi_data_width+comm_width,
      depth_g      => tx_depth_c
      )
    port map (
      clk     => clk,
      rst_n   => rst_n,
      data_in => c_a_d_dut_txfifo,
      we_in   => we_dut_txfifo,

      full_out  => full_txfifo_dut,
      one_p_out => one_p_txfifo_dut,

      data_out  => c_a_d_txfifo_tb,
      re_in     => re_tb_txfifo,
      empty_out => empty_txfifo_tb,
      one_d_out => one_d_txfifo_tb
      );

  msg_tx_fifo : entity work.fifo
    generic map (
      data_width_g => hibi_data_width+hibi_data_width+comm_width,
      depth_g      => msg_tx_depth_c
      )
    port map (
      clk     => clk,
      rst_n   => rst_n,
      data_in => msg_c_a_d_dut_txfifo,
      we_in   => msg_we_dut_txfifo,

      full_out  => msg_full_txfifo_dut,
      one_p_out => msg_one_p_txfifo_dut,

      data_out  => msg_c_a_d_txfifo_tb,
      re_in     => msg_re_tb_txfifo,
      empty_out => msg_empty_txfifo_tb,
      one_d_out => msg_one_d_txfifo_tb

      );

  tb_sdram_write <= not(sdram_cs_n_out) and sdram_ras_n_out and
                    not(sdram_cas_n_out) and not(sdram_we_n_out);
  
  sdram_controller_1 : entity work.sdram_controller
    generic map (
      clk_freq_mhz_g      => clk_freq_c,
      mem_addr_width_g    => mem_addr_width,
      block_read_length_g => 640,
      sim_ena_g           => 1)
    port map (
      clk                    => clk,
      rst_n                  => rst_n,
      command_in             => comm_dut_tb,
      address_in             => addr_dut_tb,
      data_amount_in         => amount_dut_tb,
      byte_select_in         => byte_sel_dut_tb,
      input_empty_in         => empty_dut_tb,
      input_one_d_in         => one_d_dut_tb,
      output_full_in         => full_dut_tb,
      data_in                => data_dut_tb,
      write_on_out           => write_on_tb_dut,
      busy_out               => busy_tb_dut,
      output_we_out          => we_tb_dut,
      input_re_out           => re_tb_dut,
      data_to_sdram2hibi_out => data_tb_dut,
      sdram_data_inout       => sdram_data_inout,
      sdram_cke_out          => sdram_cke_out,
      sdram_cs_n_out         => sdram_cs_n_out,
      sdram_we_n_out         => sdram_we_n_out,
      sdram_ras_n_out        => sdram_ras_n_out,
      sdram_cas_n_out        => sdram_cas_n_out,
      sdram_dqm_out          => sdram_dqm_out,
      sdram_ba_out           => sdram_ba_out,
      sdram_address_out      => sdram_addr_out);

end behavioral;
