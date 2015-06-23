-------------------------------------------------------------------------------
-- File        : tb_sdram2hibi.vhd
-- Description : Testbench for SDRAM (block transfer) ctrl
-- Author      : Erno Salminen
-- Date        : 29.10.2004
-- Modified    :
-- 
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.txt_util.all;

entity tb_sdram2hibi is
end tb_sdram2hibi;

architecture behavioral of tb_sdram2hibi is

  component fifo
    generic (
      data_width_g : integer := 0;
      depth_g      : integer := 0
      );

    port (
      clk       : in  std_logic;
      rst_n     : in  std_logic;
      data_In   : in  std_logic_vector (data_width_g - 1 downto 0);
      we_in     : in  std_logic;
      one_p_out : out std_logic;
      full_out  : out std_logic;
      data_out  : out std_logic_vector (data_width_g - 1 downto 0);
      re_in     : in  std_logic;
      empty_out : out std_logic;
      one_d_out : out std_logic
      );
  end component;

  component sdram2hibi
    generic (
      hibi_data_width_g    : integer := 0;
      mem_data_width_g     : integer := 0;
      mem_addr_width_g     : integer := 0;
      comm_width_g         : integer := 0;
      input_fifo_depth_g   : integer := 0;
      num_of_read_ports_g  : integer := 0;
      num_of_write_ports_g : integer := 0;
      offset_width_g       : integer := 16;
      rq_fifo_depth_g      : integer := 3
      );
    port (
      clk   : in std_logic;
      rst_n : in std_logic;

      hibi_data_in  : in  std_logic_vector (hibi_data_width_g - 1 downto 0);
      hibi_addr_in  : in  std_logic_vector (hibi_data_width_g - 1 downto 0);
      hibi_comm_in  : in  std_logic_vector (comm_width_g - 1 downto 0);
      hibi_empty_in : in  std_logic;
      hibi_re_out   : out std_logic;

      hibi_data_out : out std_logic_vector (hibi_data_width_g - 1 downto 0);
      hibi_addr_out : out std_logic_vector (hibi_data_width_g - 1 downto 0);
      hibi_comm_out : out std_logic_vector (comm_width_g - 1 downto 0);
      hibi_full_in  : in  std_logic;
      hibi_we_out   : out std_logic;

      hibi_msg_data_in  : in  std_logic_vector (hibi_data_width_g - 1 downto 0);
      hibi_msg_addr_in  : in  std_logic_vector (hibi_data_width_g - 1 downto 0);
      hibi_msg_comm_in  : in  std_logic_vector (comm_width_g - 1 downto 0);
      hibi_msg_empty_in : in  std_logic;
      hibi_msg_re_out   : out std_logic;

      hibi_msg_data_out : out std_logic_vector (hibi_data_width_g - 1 downto 0);
      hibi_msg_addr_out : out std_logic_vector (hibi_data_width_g - 1 downto 0);
      hibi_msg_comm_out : out std_logic_vector (comm_width_g - 1 downto 0);
      hibi_msg_full_in  : in  std_logic;
      hibi_msg_we_out   : out std_logic;

      sdram_ctrl_write_on_in     : in  std_logic;
      sdram_ctrl_comm_out        : out std_logic_vector(1 downto 0);
      sdram_ctrl_addr_out        : out std_logic_vector(21 downto 0);
      sdram_ctrl_data_amount_out : out std_logic_vector(mem_addr_width_g - 1
                                                        downto 0);
      sdram_ctrl_input_empty_out : out std_logic;
      sdram_ctrl_input_one_d_out : out std_logic;
      sdram_ctrl_output_full_out : out std_logic;
      sdram_ctrl_busy_in         : in  std_logic;
      sdram_ctrl_re_in           : in  std_logic;
      sdram_ctrl_we_in           : in  std_logic;
      sdram_ctrl_data_out        : out std_logic_vector(31 downto 0);
      sdram_ctrl_data_in         : in  std_logic_vector(31 downto 0);
      sdram_ctrl_byte_select_out : out std_logic_vector(3 downto 0)
      );
  end component;  --sdram2hibi;

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

  constant hibi_data_width : integer := 32;
  constant mem_data_width  : integer := 32;
  constant mem_addr_width  : integer := 22;
  constant comm_width      : integer := 3;
  constant depth           : integer := 10;
  constant PERIOD          : time    := 10 ns;
  constant clk_freq_c      : integer := 100;

  constant num_of_r_ports_g : integer := 4;
  constant num_of_w_ports_g : integer := 4;

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
  signal Test_Phase : integer range 0 to 100;
  signal clk        : std_logic;
  signal rst_n      : std_logic;

  type   check_state_type is (wait_comm, wait_busy);
  signal check_state : check_state_type;

  -- Signals tb -> rxfifo
  signal c_a_d_tb_rxfifo : std_logic_vector (hibi_data_width+hibi_data_width+comm_width-1 downto 0);
  signal data_tb_rxfifo  : std_logic_vector (hibi_data_width-1 downto 0);
  signal addr_tb_rxfifo  : std_logic_vector (hibi_data_width-1 downto 0);
  signal comm_tb_rxfifo  : std_logic_vector (comm_width-1 downto 0);
  signal we_tb_rxfifo    : std_logic;

  -- Signals rxfifo -> tb
  signal full_rxfifo_tb  : std_logic;
  signal one_p_rxfifo_tb : std_logic;

  -- Signals tb -> msg_rxfifo
  signal msg_c_a_d_tb_rxfifo : std_logic_vector (hibi_data_width+hibi_data_width+comm_width-1 downto 0);
  signal msg_data_tb_rxfifo  : std_logic_vector (hibi_data_width-1 downto 0);
  signal msg_addr_tb_rxfifo  : std_logic_vector (hibi_data_width-1 downto 0);
  signal msg_comm_tb_rxfifo  : std_logic_vector (comm_width-1 downto 0);
  signal msg_we_tb_rxfifo    : std_logic;

  -- Signals msg_rxfifo -> tb
  signal msg_full_rxfifo_tb  : std_logic;
  signal msg_one_p_rxfifo_tb : std_logic;

  -- Signals tb -> txfifo
  signal re_tb_txfifo : std_logic;

  -- Signals txfifo -> tb
  signal c_a_d_txfifo_tb : std_logic_vector(hibi_data_width+hibi_data_width+comm_width - 1 downto 0);
  signal data_txfifo_tb  : std_logic_vector(hibi_data_width - 1 downto 0);
  signal addr_txfifo_tb  : std_logic_vector(hibi_data_width -1 downto 0);
  signal comm_txfifo_tb  : std_logic_vector(comm_width - 1 downto 0);
  signal empty_txfifo_tb : std_logic;
  signal one_d_txfifo_tb : std_logic;

  -- Signals tb -> msg_txfifo
  signal msg_re_tb_txfifo : std_logic;

  -- Signals msg_txfifo -> tb
  signal msg_c_a_d_txfifo_tb : std_logic_vector(hibi_data_width+hibi_data_width+comm_width - 1 downto 0);
  signal msg_data_txfifo_tb  : std_logic_vector(hibi_data_width - 1 downto 0);
  signal msg_addr_txfifo_tb  : std_logic_vector(hibi_data_width - 1 downto 0);
  signal msg_comm_txfifo_tb  : std_logic_vector(comm_width - 1 downto 0);
  signal msg_empty_txfifo_tb : std_logic;
  signal msg_one_d_txfifo_tb : std_logic;

  -- Signals rxfifo -> dut
  signal c_a_d_rxfifo_dut : std_logic_vector (hibi_data_width+hibi_data_width+comm_width-1 downto 0);
  signal addr_rxfifo_dut  : std_logic_vector(hibi_data_width - 1 downto 0);
  signal data_rxfifo_dut  : std_logic_vector(hibi_data_width - 1 downto 0);
  signal comm_rxfifo_dut  : std_logic_vector(comm_width - 1 downto 0);
  signal empty_rxfifo_dut : std_logic;

  -- Signals dut -> rxfifo
  signal re_dut_rxfifo : std_logic;

  -- Signals txfifo -> dut
  signal full_txfifo_dut  : std_logic;
  signal one_p_txfifo_dut : std_logic;

  -- Signals dut -> txfifo
  signal c_a_d_dut_txfifo : std_logic_vector (hibi_data_width+hibi_data_width+comm_width-1 downto 0);
  signal addr_dut_txfifo  : std_logic_vector(hibi_data_width - 1 downto 0);
  signal data_dut_txfifo  : std_logic_vector(hibi_data_width - 1 downto 0);
  signal comm_dut_txfifo  : std_logic_vector(comm_width - 1 downto 0);
  signal we_dut_txfifo    : std_logic;

  -- Signals msg_rxfifo -> dut
  signal msg_c_a_d_rxfifo_dut : std_logic_vector (hibi_data_width+hibi_data_width+comm_width-1 downto 0);
  signal msg_addr_rxfifo_dut  : std_logic_vector(hibi_data_width - 1 downto 0);
  signal msg_data_rxfifo_dut  : std_logic_vector(hibi_data_width - 1 downto 0);
  signal msg_comm_rxfifo_dut  : std_logic_vector(comm_width - 1 downto 0);
  signal msg_empty_rxfifo_dut : std_logic;
  signal msg_one_d_rxfifo_dut : std_logic;

  -- Signals dut -> msg_rxfifo
  signal msg_re_dut_rxfifo : std_logic;

  -- Signals msg_txfifo -> dut
  signal msg_full_txfifo_dut  : std_logic;
  signal msg_one_p_txfifo_dut : std_logic;

  -- Signals dut -> msg_txfifo
  signal msg_c_a_d_dut_txfifo : std_logic_vector(hibi_data_width + hibi_data_width + comm_width - 1 downto 0);
  signal msg_addr_dut_txfifo  : std_logic_vector(hibi_data_width - 1 downto 0);
  signal msg_data_dut_txfifo  : std_logic_vector(hibi_data_width - 1 downto 0);
  signal msg_comm_dut_txfifo  : std_logic_vector(comm_width - 1 downto 0);
  signal msg_we_dut_txfifo    : std_logic;

  -- signals sdram_controller -> dut
  signal write_on_tb_dut : std_logic;
  signal busy_tb_dut     : std_logic;
  signal re_tb_dut       : std_logic;
  signal we_tb_dut       : std_logic;
  signal data_tb_dut     : std_logic_vector(31 downto 0);

  -- sdram_ctrl
  signal sdram_data_inout : std_logic_vector(31 downto 0);
  signal sdram_cke_out    : std_logic;
  signal sdram_cs_n_out   : std_logic;
  signal sdram_we_n_out   : std_logic;
  signal sdram_ras_n_out  : std_logic;
  signal sdram_cas_n_out  : std_logic;
  signal sdram_dqm_out    : std_logic_vector(3 downto 0);
  signal sdram_ba_out     : std_logic_vector(1 downto 0);
  signal sdram_addr_out   : std_logic_vector(11 downto 0);

  -- signals dut -> sdram_controller
  signal comm_dut_tb   : std_logic_vector(1 downto 0);
  signal addr_dut_tb   : std_logic_vector(21 downto 0);
  signal amount_dut_tb : std_logic_vector(21 downto 0);

  signal byte_sel_dut_tb : std_logic_vector(3 downto 0);
  signal empty_dut_tb    : std_logic;
  signal one_d_dut_tb    : std_logic;
  signal full_dut_tb     : std_logic;
  signal data_dut_tb     : std_logic_vector(31 downto 0);

  type   write_integer_array is array (0 to num_of_w_ports_g - 1) of integer;
  signal wr_dst_addr : write_integer_array;
  signal wr_amount   : write_integer_array;
  signal wr_reserved : std_logic_vector(num_of_w_ports_g - 1 downto 0);
  signal wr_valid    : std_logic_vector(num_of_w_ports_g - 1 downto 0);
  signal wr_count    : write_integer_array;
  signal wr_offset   : write_integer_array;
  signal wr_ret_addr : write_integer_array;

  type   read_integer_array is array (0 to num_of_r_ports_g - 1) of integer;
  signal rd_src_addr : read_integer_array;
  signal rd_amount   : read_integer_array;
  signal rd_reserved : std_logic_vector(num_of_r_ports_g - 1 downto 0);
  signal rd_valid    : std_logic_vector(num_of_r_ports_g - 1 downto 0);
  signal rd_count    : read_integer_array;
  signal rd_ret_addr : read_integer_array;
  signal rd_offset   : read_integer_array;

  signal msg_empty_txfifo : std_logic;
  signal msg_full_rxfifo  : std_logic;
  signal full_rxfifo      : std_logic;

  signal data_counter      : read_integer_array;
  signal single_counter_r  : integer;
  signal valid_write_ports : std_logic_vector(num_of_w_ports_g - 1 downto 0);

  signal empty_txfifo : std_logic;

begin  -- behavioral


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

  full_rxfifo      <= full_rxfifo_tb or (one_p_rxfifo_tb and we_tb_rxfifo);
  empty_txfifo     <= empty_txfifo_tb or (one_d_txfifo_tb and re_tb_txfifo);
  msg_full_rxfifo  <= msg_full_rxfifo_tb or (msg_one_p_rxfifo_tb and msg_we_tb_rxfifo);
  msg_empty_txfifo <= msg_empty_txfifo_tb or (msg_one_d_txfifo_tb and msg_re_tb_txfifo);

  -- 1) PROC
  Generate_input : process
    -----------------------------------------------------------------------------
    -- Three procedures for writing to and for reading the fifo
    -----------------------------------------------------------------------------
    procedure WriteToFifo (
      addr_to_fifo : in integer;
      data_to_fifo : in integer;
      comm_to_fifo : in integer;
      wait_time    : in integer) is

    begin  --procedure

      if clk = '0' then
        wait until clk = '1';
        wait for PERIOD / 5;
      end if;

      while full_rxfifo = '1' loop
        wait for PERIOD;
      end loop;
      --assert false report "Fifo full. Cannot write" severity note;

      data_tb_rxfifo <= std_logic_vector(to_unsigned (data_to_fifo, hibi_data_width));
      comm_tb_rxfifo <= std_logic_vector(to_unsigned (comm_to_fifo, comm_width));
      addr_tb_rxfifo <= std_logic_vector(to_unsigned (addr_to_fifo, hibi_data_width));
      we_tb_rxfifo   <= '1';

      wait for PERIOD/5;
      wait for PERIOD;
      --if wait_time > 0 then      
      we_tb_rxfifo   <= '0';
      data_tb_rxfifo <= (others => 'Z');
      comm_tb_rxfifo <= (others => 'Z');
      addr_tb_rxfifo <= (others => 'Z');
      wait for (wait_time)* PERIOD;
      --end if;

    end WriteToFifo;

    procedure WriteToMsgFifo (
      addr_to_fifo : in integer;
      data_to_fifo : in integer;
      comm_to_fifo : in integer;
      wait_time    : in integer) is

    begin  --procedure

      if clk = '0' then
        wait until clk = '1';
        wait for PERIOD / 5;
      end if;

      while msg_full_rxfifo = '1' loop
        wait for PERIOD;
      end loop;

      --assert false report "Fifo full. Cannot write" severity note;
      msg_addr_tb_rxfifo <= std_logic_vector(to_unsigned (addr_to_fifo, hibi_data_width));
      msg_data_tb_rxfifo <= std_logic_vector(to_unsigned (data_to_fifo, hibi_data_width));
      msg_comm_tb_rxfifo <= std_logic_vector(to_unsigned (comm_to_fifo, comm_width));
      msg_we_tb_rxfifo   <= '1';


      wait for PERIOD/5;
      wait for PERIOD;
      --if wait_time > 0 then      
      msg_addr_tb_rxfifo <= (others => 'Z');
      msg_data_tb_rxfifo <= (others => 'Z');
      msg_comm_tb_rxfifo <= (others => 'Z');
      msg_we_tb_rxfifo   <= '0';
      wait for (wait_time)* PERIOD;
      --end if;

    end WriteToMsgFifo;

    procedure request_read_port (
      agent_number : in integer) is

    begin
      if agent_number < num_of_r_ports_g then

        -- request read port
        for r in 0 to num_of_r_ports_g - 1 loop
          if r = agent_number then
            WriteToMsgFifo(0, rd_ret_addr(r), 3, 1);
          end if;
        end loop;  -- r

        while msg_empty_txfifo = '1' loop
          wait for PERIOD;
        end loop;

        assert to_integer(unsigned(msg_data_txfifo_tb)) /= 0 report "No free read ports!"
          severity note;

        for r in 0 to num_of_r_ports_g - 1 loop
          if r = agent_number then
            assert to_integer(unsigned(msg_addr_txfifo_tb)) = rd_ret_addr(r) report "Own HIBI address corrupted when requesting read port" severity failure;
          end if;
        end loop;  -- r

        assert false report "Read agent offset read" severity note;

        for r in 0 to num_of_r_ports_g - 1 loop
          if r = agent_number then
            rd_offset(r) <= to_integer(unsigned(msg_data_txfifo_tb));
          end if;
        end loop;  -- r

        msg_re_tb_txfifo <= '1';
        wait for PERIOD;
        msg_re_tb_txfifo <= '0';

      end if;
    end procedure;

    procedure request_write_port (
      agent_number : in integer) is

    begin

      if agent_number < num_of_w_ports_g then

        -- request write port
        for w in 0 to num_of_w_ports_g - 1 loop
          if agent_number = w then
            WriteToMsgFifo(1, wr_ret_addr(w), 3, 1);
          end if;
        end loop;  -- w

        while msg_empty_txfifo = '1' loop
          wait for PERIOD;
        end loop;

        if to_integer(unsigned(msg_data_txfifo_tb)) = 0 then
          valid_write_ports(agent_number) <= '0';
        else
          valid_write_ports(agent_number) <= '1';
        end if;


        assert msg_comm_txfifo_tb = "011" report "hibi_msg_comm corrupted"
          severity failure;
        
        assert to_integer(unsigned(msg_data_txfifo_tb)) /= 0 report "No free write ports"
          severity note;

        for w in 0 to num_of_w_ports_g - 1 loop
          if agent_number = w then
            assert to_integer(unsigned(msg_addr_txfifo_tb)) = wr_ret_addr(w) report "Own HIBI address corrupted when requesting write port" severity failure;
          end if;
        end loop;  -- w

        assert false report "Write port offset read" severity note;

        for w in 0 to num_of_w_ports_g - 1 loop
          if agent_number = w then
            wr_offset(w) <= to_integer(unsigned(msg_data_txfifo_tb));
          end if;
        end loop;  -- w

        msg_re_tb_txfifo <= '1';
        wait for PERIOD;
        msg_re_tb_txfifo <= '0';
      end if;

    end procedure;

    procedure configure_read_port (
      agent_number : in integer;
      amount       : in integer) is

    begin

      if agent_number < num_of_r_ports_g then
        
        wait for PERIOD;

        for r in 0 to num_of_r_ports_g - 1 loop
          if r = agent_number then
            if rd_offset(r) /= 0 then
              assert false report "Configure read agent" severity note;
              WriteToMsgFifo(rd_offset(r), rd_src_addr(r), 3, 1);
              WriteToMsgFifo(rd_offset(r)+1, amount, 3, 1);
              WriteToMsgFifo(rd_offset(r)+3, rd_ret_addr(r), 3, 1);
              WriteToMsgFifo(rd_offset(r)+2, 1, 3, 1);
              rd_src_addr(r) <= rd_src_addr(r) + amount;
            else
              assert false report "No valid read ports. Didn't configure" severity warning;
            end if;
          end if;
        end loop;  -- r

      end if;
    end procedure;

    procedure configure_write_port (
      agent_number : in integer;
      amount       : in integer) is

    begin

      if agent_number < num_of_w_ports_g then
        
        wait for PERIOD;

        if valid_write_ports(agent_number) = '1' then
          

          for w in 0 to num_of_w_ports_g - 1 loop

            if w = agent_number then
              WriteToMsgFifo(wr_offset(w), wr_dst_addr(w), 3, 1);
              WriteToMsgFifo(wr_offset(w)+1, amount, 3, 1);
              WriteToMsgFifo(wr_offset(w)+2, 1, 3, 1);
              wr_dst_addr(w) <= wr_dst_addr(w) + amount;  --write_amount(w);
            end if;
          end loop;  -- w

        end if;
      end if;
    end procedure;

    procedure write_input_data (
      agent_number : in integer;
      amount       : in integer) is

    begin

      if agent_number < num_of_w_ports_g then
        
        if valid_write_ports(agent_number) = '1' then

          for w in 0 to num_of_w_ports_g - 1 loop
            if agent_number = w then
              for i in 0 to amount - 1 loop
                wr_count(w) <= wr_count(w) + 1;
                WriteToFifo(wr_offset(w)+3, wr_count(w), 2, 1);
              end loop;  -- i
            end if;
          end loop;  -- w

        end if;
      end if;
    end procedure;


  begin  -- process Generate_input

    -- test sequence
    -- 0 wait for reset
    -- 1 write to empty fifo and read so that it is empty again
    -- 2 write to fifo until there is only one place left
    -- Wait for reset

    data_tb_rxfifo <= (others => 'Z');
    addr_tb_rxfifo <= (others => 'Z');
    comm_tb_rxfifo <= (others => 'Z');
    we_tb_rxfifo   <= '0';

    msg_data_tb_rxfifo <= (others => 'Z');
    msg_addr_tb_rxfifo <= (others => 'Z');
    msg_comm_tb_rxfifo <= (others => 'Z');
    msg_we_tb_rxfifo   <= '0';
    msg_re_tb_txfifo   <= '0';

    for i in 0 to num_of_r_ports_g - 1 loop
      rd_src_addr(i) <= i * 4096;       --X"1000";
    end loop;  -- i
    for i in 0 to num_of_w_ports_g - 1 loop
      wr_dst_addr(i) <= i * 4096;       --X"1000";
    end loop;  -- i

    wr_count <= (others => 0);

    for w in 0 to num_of_w_ports_g - 1 loop
      wr_ret_addr(w) <= (w+1)*100;
    end loop;  -- w

    for r in 0 to num_of_r_ports_g - 1 loop
      rd_ret_addr(r) <= (r+1)* 4096;    -- X"1000";
    end loop;  -- r

    wr_offset <= (others => 0);
    rd_offset <= (others => 0);

    single_counter_r <= 100;
    Test_Phase       <= 0;

    valid_write_ports <= (others => '0');

    wait for (6 + 2)*PERIOD;
    wait for PERIOD/2;
    wait for PERIOD/3;

    -- 0) At the beginning
    assert empty_txfifo_tb = '1' report "0      : Empty does not work" severity error;
    assert full_rxfifo_tb = '0' report "0       : Full does not work" severity error;

--    while busy_tb_dut = '1' loop
    wait for PERIOD;
--    end loop;
    while true loop

      -- request write port
      request_write_port(0);
      -- request write port
      request_write_port(1);
      -- request write port
      request_write_port(2);

      -- configure write port
      configure_write_port(0, 100);
      configure_write_port(1, 5);
      configure_write_port(2, 1);

      wait for 20*period;

      -- write data to rxfifo
      write_input_data(0, 10);
      -- write data to rxfifo
      write_input_data(1, 5);
      -- write data to rxfifo
      write_input_data(2, 1);

      wait for 40*PERIOD;

      -- request read port
      request_read_port(0);

      -- configure read port
--    read_amount(0) <= 2;
      configure_read_port(0, 10);

      wait for 20*period;

      assert false report "Start filling single op with write" severity note;
      -- fill single_op_fifo
      for i in 0 to 50 loop
        WriteToFifo(single_counter_r + i, single_counter_r + i, 2, 0);
      end loop;  -- i
      assert false report "Single op filled with write, start filling with read"
        severity note;
      write_input_data(0, 45);

      -- single read
      for i in 0 to 50 loop
        single_counter_r <= single_counter_r + 1;
        WriteToFifo(single_counter_r, 123, 4, 0);
      end loop;  -- i
      write_input_data(0, 45);

      assert false report "Single op filled with read" severity note;

      -- request read port
      request_read_port(1);

      -- request read port
      request_read_port(2);

      -- configure read port
--    read_amount(1) <= 10;
      configure_read_port(1, 10);

      -- configure read port
--    read_amount(2) <= 3;
      configure_read_port(2, 3);

      wait for 20*period;

      assert false report "++++++++++++++" severity note;
      assert false report "Test completed" severity note;
      assert false report "++++++++++++++" severity note;
    end loop;

    wait;
  end process Generate_input;

  check_output : process (clk, rst_n)

    variable addr_int     : integer := 0;
    variable addr_tmp     : std_logic_vector(21 downto 0);
    variable addr_tmp_int : integer := 0;
    variable port_num     : integer := 0;
  begin  -- process check_output

    if rst_n = '0' then                 -- asynchronous reset (active low)
      addr_int     := 0;
      addr_tmp     := (others => '0');
      addr_tmp_int := 0;
      port_num     := 0;
      check_state  <= wait_comm;
    elsif clk'event and clk = '1' then  -- rising clock edge

      case check_state is

        when wait_comm =>

          if busy_tb_dut = '0' then
            
            case comm_dut_tb is

              when "00" =>
                -- NOP
                check_state <= wait_comm;

              when "01" =>
                -- READ
                addr_int               := to_integer(unsigned(addr_dut_tb));
                addr_tmp(21 downto 12) := addr_dut_tb(21 downto 12);
                addr_tmp(11 downto 0)  := (others => '0');
                addr_int               := to_integer(unsigned(addr_tmp));
                port_num               := 0;
                addr_tmp_int           := addr_int;
                while addr_tmp_int > 0 loop
                  port_num     := port_num + 1;
                  addr_tmp_int := addr_tmp_int - 4096;  --X"1000";
                end loop;
                report "----- Read command to ctrl -----";
                report "Addr: 0x" & str(addr_int, 16);
                report "Port: " & str(port_num);
                report "Amount: " & str(to_integer(unsigned(amount_dut_tb))) severity note;
                check_state <= wait_busy;

              when "10" =>
                -- WRITE
                addr_int               := to_integer(unsigned(addr_dut_tb));
                addr_tmp(21 downto 12) := addr_dut_tb(21 downto 12);
                addr_tmp(11 downto 0)  := (others => '0');
                addr_int               := to_integer(unsigned(addr_tmp));
                port_num               := 0;
                addr_tmp_int           := addr_int;
                while addr_tmp_int > 0 loop
                  port_num     := port_num + 1;
                  addr_tmp_int := addr_tmp_int - 4096;  --X"1000";
                end loop;
                report "----- Write command to ctrl -----";
                report "Addr: 0x" & str(addr_int, 16);
                report "Port: " & str(port_num);
                report "Amount: " & str(to_integer(unsigned(amount_dut_tb))) severity note;
                check_state <= wait_busy;

              when others =>
                assert false report "Illegal command to ctrl" severity failure;
                check_state <= wait_comm;
            end case;
          end if;

        when wait_busy =>
          if busy_tb_dut = '0' then
            check_state <= wait_busy;
          else
            check_state <= wait_comm;
          end if;
        when others =>
          assert false report "Illegal check state" severity failure;
      end case;
      
    end if;
  end process check_output;


  -- 4) PROC (ASYNC)
  CLOCK1 : process                      -- generate clock signal for design
  begin
    clk <= '1';
    wait for PERIOD/2;
    clk <= '0';
    wait for PERIOD/2;
  end process CLOCK1;

  -- 5) PROC (ASYNC)
  RESET : process
  begin
    rst_n <= '0';                       -- Reset the testsystem
    wait for 6*PERIOD;                  -- Wait 
    rst_n <= '1';                       -- de-assert reset
    wait;
  end process RESET;

  DUT : sdram2hibi

    generic map(
      hibi_data_width_g    => hibi_data_width,
      mem_data_width_g     => mem_data_width,
      mem_addr_width_g     => mem_addr_width,
      comm_width_g         => comm_width,
      input_fifo_depth_g   => 5,
      num_of_read_ports_g  => num_of_r_ports_g,
      num_of_write_ports_g => num_of_w_ports_g
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


  rx_fifo : fifo
    generic map (
      data_width_g => hibi_data_width+hibi_data_width+comm_width,
      depth_g      => 5
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

  msg_rx_fifo : fifo
    generic map (
      data_width_g => hibi_data_width+hibi_data_width+comm_width,
      depth_g      => 5
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


  tx_fifo : fifo
    generic map (
      data_width_g => hibi_data_width+hibi_data_width+comm_width,
      depth_g      => 5
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

  msg_tx_fifo : fifo
    generic map (
      data_width_g => hibi_data_width+hibi_data_width+comm_width,
      depth_g      => 5
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

  sdram_controller_1 : sdram_controller
    generic map (
      clk_freq_mhz_g      => clk_freq_c,
      mem_addr_width_g    => 22,
      block_read_length_g => 640)
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
