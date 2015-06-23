-------------------------------------------------------------------------------
-- Title      : sdram2hibiv8
-- Project    : 
-------------------------------------------------------------------------------
-- File       : sdram2hibiv8.vhd
-- Author     : 
-- Company    : 
-- Created    : 2005-07-05
-- Last update: 2012-04-11
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description:
--              doesn't change read port until read is finshed.
--              Read/write overlap blocking.
--
--              rq_fifo_depth > 0 - blocking requests
--                            = 0 - non-blocking requests
--
--              Arbitter types as in Dally&Towles: Principles and Practices
--              of Interconnection Networks p.352-355
--              x_arb_type 0 - round robin
--                         1 - fixed priority
--                         2 - variable priority
--
--              x_prior_g  0 - highest
--
--              block_overlap_g 0 - checks only if the first row overlaps
--                              1 - checks whole block for overlap
--
-------------------------------------------------------------------------------
-- Copyright (c) 2005 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author          Description
-- 2005-07-05  1.0      penttin5        Created
--             1.1      penttin5        Non-blocking when rq_fifo_depth_g = 0
--                                      Blocking when rq_fifo_depth_g > 0
--             1.2      penttin5        Rewrote major parts of VHDL
-- 28.06.2007           penttin5        in-order reads
-- 2012-01-27  1.3      alhonena        hibiv3
-- 2012-03-24  1.4      alhonena        This was completely broken. It freezed
--                                      in a very peculiar way if the hibi base
--                                      address was any smaller than 22 bits.
--                                      A completely undocumented feature.
--                                      Instead of just documenting this
--                                      unwanted feature, I fixed it.
--                                      However, please test thoroughly,
--                                      especially if you use single ops.
--                                      Now, the single op address is calculated
--                                      by subtracting the hibi base addr from
--                                      hibi addr. For this reason, I have added
--                                      own_hibi_base_addr_g which must be correct.
--                                      Of course, if you want to use single ops
--                                      AND access as much memory space as
--                                      possible, you still need 22-bit hibi
--                                      address space.
--                                      TODO: Fix the "single op" specification
--                                      and implementation: now the first few
--                                      bytes of memory cannot be accessed by
--                                      using "single op"s.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.hibiv3_pkg.all;

entity sdram2hibi is

  generic (
    own_hibi_base_addr_g : integer := 0;
    hibi_data_width_g    : integer := 32;
    mem_data_width_g     : integer := 32;
    mem_addr_width_g     : integer := 22;
    comm_width_g         : integer := 3;
    input_fifo_depth_g   : integer := 5;
    num_of_read_ports_g  : integer := 4;
    num_of_write_ports_g : integer := 4;
    offset_width_g       : integer := 16;
    rq_fifo_depth_g      : integer := 0;
    op_arb_type_g        : integer := 1;  -- fixed prior
    port_arb_type_g      : integer := 0;
    blk_rd_prior_g       : integer := 0;  -- rd has the highest prior
    blk_wr_prior_g       : integer := 1;
    single_op_prior_g    : integer := 2;
    amountw_g            : integer := 22;
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
    sdram_ctrl_data_out        : out std_logic_vector(31 downto 0);
    sdram_ctrl_data_in         : in  std_logic_vector(31 downto 0);
    -- byte select is not implemented!!!
    sdram_ctrl_byte_select_out : out std_logic_vector(3 downto 0)
    );

end sdram2hibi;

architecture rtl of sdram2hibi is

  function maximum (L : integer; R : integer) return integer is
  begin
    if L > R then
      return L;
    else
      return R;
    end if;
  end;

  function log2_ceil(N : natural) return positive is
  begin
    if N < 2 then
      return 1;
    else
      return 1 + log2_ceil(N/2);
    end if;
  end;

  component sdram_wr_port
    generic (
      fifo_depth_g    : integer;
      amountw_g       : integer;
      hibi_dataw_g    : integer;
      block_overlap_g : integer;
      offsetw_g       : integer;
      mem_dataw_g     : integer;
      mem_addrw_g     : integer); 
    port (
      clk            : in  std_logic;
      rst_n          : in  std_logic;
      conf_we_in     : in  std_logic;
      conf_data_in   : in  std_logic_vector(hibi_dataw_g - 1 downto 0);
      write_in       : in  std_logic;
      reserve_in     : in  std_logic;
      valid_out      : out std_logic;
      reserved_out   : out std_logic;
      end_addr_out   : out std_logic_vector(mem_addrw_g - 1 downto 0);
      dst_addr_out   : out std_logic_vector(mem_addrw_g - 1 downto 0);
      amount_out     : out std_logic_vector(amountw_g - 1 downto 0);
      fifo_we_in     : in  std_logic;
      fifo_re_in     : in  std_logic;
      fifo_data_in   : in  std_logic_vector(hibi_dataw_g - 1 downto 0);
      fifo_full_out  : out std_logic;
      fifo_empty_out : out std_logic;
      fifo_one_p_out : out std_logic;
      fifo_one_d_out : out std_logic;
      fifo_data_out  : out std_logic_vector(hibi_dataw_g - 1 downto 0);
      error_out      : out std_logic); 
  end component;

  component sdram_rd_port
    generic (
      amountw_g       : integer;
      hibi_dataw_g    : integer;
      block_overlap_g : integer;
      offsetw_g       : integer;
      mem_dataw_g     : integer;
      mem_addrw_g     : integer);
    port (
      clk          : in  std_logic;
      rst_n        : in  std_logic;
      conf_we_in   : in  std_logic;
      conf_data_in : in  std_logic_vector(hibi_dataw_g - 1 downto 0);
      read_in      : in  std_logic;
      reserve_in   : in  std_logic;
      valid_out    : out std_logic;
      reserved_out : out std_logic;
      end_addr_out : out std_logic_vector(mem_addrw_g - 1 downto 0);
      src_addr_out : out std_logic_vector(mem_addrw_g - 1 downto 0);
      amount_out   : out std_logic_vector(amountw_g - 1 downto 0);
      ret_addr_out : out std_logic_vector(hibi_dataw_g - 1 downto 0);
      finish_out   : out std_logic;
      error_out    : out std_logic);
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

  component sdram_arbiter

    generic (
      arb_width_g : integer;
      arb_type_g  : integer := 0
      );
    port(
      clk       : in  std_logic;
      rst_n     : in  std_logic;
      req_in    : in  std_logic_vector(arb_width_g - 1 downto 0);
      hold_in   : in  std_logic_vector(arb_width_g - 1 downto 0);
      grant_out : out std_logic_vector(arb_width_g - 1 downto 0)
      );
  end component;

  -- How many bits do we need to compare on hibi_msg_addr_in
  -- to detect port request or config?
  -- (addrs 0 and 1 for port requests
  --  addrs 2...2+num_of_read_ports_g-1 for read port configs,
  --  addrs 2+num_of_read_ports_g...2+num_of_read_ports_g+num_of_write_ports_g-1
  --        for write port configs
  -- So num of bits is log2(2 + num_of_read_ports_g + num_of_write_ports_g)
  constant msg_addr_compw_c : integer
    := log2_ceil(2 + num_of_read_ports_g + num_of_write_ports_g);

  signal sdram_write : std_logic_vector(num_of_write_ports_g - 1 downto 0);
  signal sdram_read  : std_logic_vector(num_of_read_ports_g - 1 downto 0);

  -- state machine for process from_ports_to_controller
  type state_vector_type is (idle, wait_for_block_read_start,
                             wait_for_block_write_start,
                             wait_for_single_op_start);
  signal state_r : state_vector_type;

  signal conf_rd_r : std_logic_vector(num_of_read_ports_g - 1 downto 0);
  signal conf_wr_r : std_logic_vector(num_of_write_ports_g - 1 downto 0);

  -- Rq and conf detection signals
  signal rd_port_rq   : std_logic;
  signal wr_port_rq   : std_logic;
  signal rd_port_conf : std_logic;
  signal wr_port_conf : std_logic;

  -- Types definitions for write port signals
  type w_mem_addr_arr is array (num_of_write_ports_g - 1 downto 0)
    of std_logic_vector(mem_addr_width_g - 1 downto 0);

  type w_data_arr is array (num_of_write_ports_g downto 0)
    of std_logic_vector(hibi_data_width_g - 1 downto 0);

  type w_amount_arr is array (num_of_write_ports_g - 1 downto 0)
    of std_logic_vector(amountw_g - 1 downto 0);

  type w_end_addr_arr is array (num_of_write_ports_g - 1 downto 0)
    of std_logic_vector(mem_addr_width_g - 1 downto 0);

  -- Write port signals
  signal w_reserve    : std_logic_vector(num_of_write_ports_g - 1 downto 0);
  signal w_reserved_r : std_logic_vector(num_of_write_ports_g - 1 downto 0);
  signal w_valid_r    : std_logic_vector(num_of_write_ports_g - 1 downto 0);
  signal w_dst_addr_r : w_mem_addr_arr;
  signal w_amount_r   : w_amount_arr;
  signal w_we_r       : std_logic_vector(num_of_write_ports_g - 1 downto 0);
  signal w_re_r       : std_logic_vector(num_of_write_ports_g - 1 downto 0);
  signal w_empty      : std_logic_vector(num_of_write_ports_g downto 0);
  signal w_full       : std_logic_vector(num_of_write_ports_g - 1 downto 0);
  signal w_one_p_left : std_logic_vector(num_of_write_ports_g - 1 downto 0);
  signal w_one_d_left : std_logic_vector(num_of_write_ports_g downto 0);
  signal w_data_out   : w_data_arr;
  signal w_end_addr_r : w_end_addr_arr;

  -- Read port signal type definitions
  type r_mem_addr_arr is array (num_of_read_ports_g - 1 downto 0)
    of std_logic_vector(mem_addr_width_g - 1 downto 0);
  type r_amount_arr is array (num_of_read_ports_g - 1 downto 0)
    of std_logic_vector(amountw_g - 1 downto 0);
  type r_data_arr is array (num_of_read_ports_g - 1 downto 0)
    of std_logic_vector(hibi_data_width_g - 1 downto 0);
  type r_overlap_vec_arr is array (num_of_read_ports_g - 1 downto 0)
    of std_logic_vector(num_of_write_ports_g - 1 downto 0);

  -- Read port signals
  signal r_reserved_r    : std_logic_vector(num_of_read_ports_g - 1 downto 0);
  signal r_end_addr_r    : r_mem_addr_arr;
  signal r_valid_r       : std_logic_vector(num_of_read_ports_g - 1 downto 0);
  signal r_src_addr_r    : r_mem_addr_arr;
  signal r_amount_r      : r_amount_arr;
  signal r_ret_addr_r    : r_data_arr;
  signal r_overlap_vec_r : r_overlap_vec_arr;
  signal r_overlap       : std_logic_vector(num_of_read_ports_g - 1 downto 0);
  signal r_reserve       : std_logic_vector(num_of_read_ports_g - 1 downto 0);
  signal r_finish_r      : std_logic_vector(num_of_read_ports_g - 1 downto 0);

  -- 21.05.07 HP
  signal data_to_fifos_r : std_logic_vector(hibi_data_width_g - 1 downto 0);
  signal prev_r_valid_r  : std_logic_vector(num_of_read_ports_g - 1 downto 0);
  signal conf_data_r     : std_logic_vector(hibi_data_width_g - 1 downto 0);

  -- Arbiter signals
  signal next_op             : std_logic_vector(2 downto 0);
  signal next_op_req         : std_logic_vector(2 downto 0);
  signal next_op_hold        : std_logic_vector(2 downto 0);
  signal r_port_req          : std_logic_vector(num_of_read_ports_g - 1 downto 0);
  signal r_port_hold         : std_logic_vector(num_of_read_ports_g - 1 downto 0);
  signal w_port_req          : std_logic_vector(num_of_write_ports_g - 1 downto 0);
  signal w_port_hold         : std_logic_vector(num_of_write_ports_g - 1 downto 0);
  signal next_rd_port        : std_logic_vector(num_of_read_ports_g - 1 downto 0);
  signal next_wr_port        : std_logic_vector(num_of_write_ports_g - 1 downto 0);
  signal rd_hold_mask        : std_logic;
  signal wr_hold_mask        : std_logic;
  signal single_op_hold_mask : std_logic;

  -- 17.10.06 HP

  signal free_r_port   : std_logic;
  signal free_w_port   : std_logic;
  signal free_r_num_r    : integer range num_of_read_ports_g - 1 downto 0;
  signal free_w_num    : integer range num_of_write_ports_g - 1 downto 0;
  signal free_r_offset : integer
    range 2 + num_of_read_ports_g - 1 downto 0;
  signal free_w_offset : integer
    range 2 + num_of_read_ports_g + num_of_write_ports_g - 1 downto 0;

  -- signals for single operations port
  signal single_op_in : std_logic_vector(2 + 2*(hibi_data_width_g) - 1
                                         downto 0);
  signal single_op_comm_in_r : std_logic_vector(1 downto 0);
  signal single_op_addr_in_r : std_logic_vector(hibi_data_width_g - 1
                                                downto 0);
  signal single_op_ret_addr_out : std_logic_vector(hibi_data_width_g - 1 downto 0);
  signal single_op_we_r         : std_logic;
  signal single_op_re_r         : std_logic;
  signal single_op_empty        : std_logic;
  signal single_op_full         : std_logic;
  signal single_op_out : std_logic_vector(2 + 2*(hibi_data_width_g) - 1
                                          downto 0);
  signal single_op_data_out_r : std_logic_vector(31 downto 0);
  signal single_op_one_p_left : std_logic;
  signal single_op_one_d_left : std_logic;
  signal single_op_comm_out   : std_logic_vector(1 downto 0);
  signal single_op_addr_out : std_logic_vector(mem_addr_width_g - 1
                                               downto 0);
  signal single_op_data_out : std_logic_vector(31 downto 0);
  signal single_op_on_r     : std_logic;

  signal curr_wr_port_r : integer range num_of_write_ports_g downto 0;
  signal curr_rd_port_r : integer range num_of_read_ports_g - 1 downto 0;

  signal hibi_msg_we_r   : std_logic;
  signal hibi_msg_data_r : std_logic_vector(hibi_data_width_g - 1 downto 0);
  signal hibi_msg_addr_r : std_logic_vector(hibi_data_width_g - 1 downto 0);

  -- Read request fifo signals
  signal rd_rq_in_r  : std_logic_vector(hibi_data_width_g - 1 downto 0);
  signal rd_rq_we_r  : std_logic;
  signal rd_rq_full  : std_logic;
  signal rd_rq       : std_logic_vector(hibi_data_width_g - 1 downto 0);
  signal rd_rq_re    : std_logic;
  signal rd_rq_empty : std_logic;

  -- Write request fifo signals
  signal wr_rq_in_r  : std_logic_vector(hibi_data_width_g - 1 downto 0);
  signal wr_rq_we_r  : std_logic;
  signal wr_rq_full  : std_logic;
  signal wr_rq       : std_logic_vector(hibi_data_width_g - 1 downto 0);
  signal wr_rq_re    : std_logic;
  signal wr_rq_empty : std_logic;

  -- Zero response fifo signals
  signal zero_in_r  : std_logic_vector(hibi_data_width_g - 1 downto 0);
  signal zero_out_r : std_logic_vector(hibi_data_width_g - 1 downto 0);
  signal zero_we_r  : std_logic;
  signal zero_full  : std_logic;
  signal zero_re    : std_logic;
  signal zero_empty : std_logic;
  
begin  -- rtl


  -- The sdram2hibi needs to know its own base hibi address.
  assert own_hibi_base_addr_g /= 0 report "Please set own_hibi_base_addr_g" severity failure;
  
-------------------------------------------------------------------------------
-- Drive outputs
-------------------------------------------------------------------------------
  sdram_ctrl_byte_select_out <= (others => '0');  -- byteenable not implemented
  sdram_ctrl_output_full_out <= hibi_full_in;

  hibi_msg_we_out   <= hibi_msg_we_r;
  hibi_msg_data_out <= hibi_msg_data_r;
  hibi_msg_addr_out <= hibi_msg_addr_r;
  hibi_msg_comm_out <= MSG_WR_c;
  hibi_comm_out     <= DATA_WR_c;
  hibi_data_out     <= sdram_ctrl_data_in;
  hibi_we_out       <= sdram_ctrl_we_in;

  -- combine comm, data, and addr to one signal
  single_op_in <= single_op_comm_in_r & single_op_addr_in_r &
                  data_to_fifos_r;

  -- divide single operation fifo output to comm, addr and data
  single_op_comm_out <= single_op_out
                        (single_op_out'length - 1
                         downto single_op_out'length - 2);
  single_op_ret_addr_out <= single_op_out
                            (single_op_out'length - 2 - 1 downto
                             hibi_data_width_g);
  single_op_addr_out <= single_op_out(hibi_data_width_g + mem_addr_width_g - 1
                                      downto hibi_data_width_g);
  single_op_data_out <= single_op_out(hibi_data_width_g - 1 downto 0);


-------------------------------------------------------------------------------
-- or_reduce read ports overlap vector
-------------------------------------------------------------------------------
  gen_r_overlap : process (r_overlap_vec_r)
  begin  -- process gen_r_overlap
    for rd_port in num_of_read_ports_g - 1 downto 0 loop
      if to_integer(unsigned(r_overlap_vec_r(rd_port))) /= 0 then
        r_overlap(rd_port) <= '1';
      else
        r_overlap(rd_port) <= '0';
      end if;
    end loop;  -- rd_port
  end process gen_r_overlap;

-------------------------------------------------------------------------------
-- generate request signals for read port arbitrator
-------------------------------------------------------------------------------
--  gen_r_port_req : for rd_port in num_of_read_ports_g - 1 downto 0 generate
--    r_port_req(rd_port) <= r_valid_r(rd_port) and not(r_overlap(rd_port));
--  end generate gen_r_port_req;

-------------------------------------------------------------------------------
-- generate hold signals for read port arbitrator
-------------------------------------------------------------------------------
--  gen_r_port_hold : for rd_port in num_of_read_ports_g - 1 downto 0 generate
--    r_port_hold(rd_port) <= r_port_req(rd_port) and not(rd_hold_mask);
--  end generate gen_r_port_hold;

-------------------------------------------------------------------------------
-- generate request signals for write port arbitrator
-------------------------------------------------------------------------------
  gen_w_port_req : for wr_port in num_of_write_ports_g - 1 downto 0 generate
    w_port_req(wr_port) <= w_valid_r(wr_port) and not(w_empty(wr_port));
  end generate gen_w_port_req;

-------------------------------------------------------------------------------
-- generate hold signals for write port arbitrator
-------------------------------------------------------------------------------
  gen_w_port_hold : for wr_port in num_of_write_ports_g - 1 downto 0 generate
    w_port_hold(wr_port) <= w_port_req(wr_port) and not(wr_hold_mask);
  end generate gen_w_port_hold;

-------------------------------------------------------------------------------
-- generate request signals for next operation arbtrator
-------------------------------------------------------------------------------
  gen_op_req : process (curr_rd_port_r, r_valid_r, r_overlap, w_port_req, single_op_empty)
--  gen_op_req : process (r_port_req, w_port_req, single_op_empty)
  begin  -- process gen_op_req
--    if to_integer(unsigned(r_port_req)) /= 0 then
    if r_valid_r(curr_rd_port_r) = '1' and r_overlap(curr_rd_port_r) = '0' then
      next_op_req(blk_rd_prior_g) <= '1';
    else
      next_op_req(blk_rd_prior_g) <= '0';
    end if;

    if to_integer(unsigned(w_port_req)) /= 0 then
      next_op_req(blk_wr_prior_g) <= '1';
    else
      next_op_req(blk_wr_prior_g) <= '0';
    end if;

    next_op_req(single_op_prior_g) <= not(single_op_empty);
  end process gen_op_req;

-------------------------------------------------------------------------------
-- generate hold signals for next operation arbitrator
-- that chooses the next operation(i.e. block read, block write, single op)
-------------------------------------------------------------------------------
  next_op_hold(blk_rd_prior_g) <= next_op_req(blk_rd_prior_g)
                                     and not(rd_hold_mask);
  next_op_hold(blk_wr_prior_g) <= next_op_req(blk_wr_prior_g)
                                     and not(wr_hold_mask);
  next_op_hold(single_op_prior_g) <= next_op_req(single_op_prior_g)
                                     and not(single_op_hold_mask);

-------------------------------------------------------------------------------
-- Multiplex correct signals to SDRAM controller
-- (empty, one_data_left, data)
-------------------------------------------------------------------------------
  -- when single op, write port outputs must have some value
  w_data_out(num_of_write_ports_g)   <= (others => '0');
  w_empty(num_of_write_ports_g)      <= '0';
  w_one_d_left(num_of_write_ports_g) <= '0';

  -- multiplex correct empty to SDRAM controller
  with single_op_on_r select
    sdram_ctrl_input_empty_out <=
    w_empty(curr_wr_port_r) when '0',
    '0' when others;

  -- multiplex the correct one_d_left to SDRAM controller
  with single_op_on_r select
    sdram_ctrl_input_one_d_out <=
    w_one_d_left(curr_wr_port_r) when '0',
    '0' when others;

  -- multiplex the correct data to SDRAM controller
  with single_op_on_r select
    sdram_ctrl_data_out <=
    single_op_data_out_r       when '1',
    w_data_out(curr_wr_port_r) when others;

-------------------------------------------------------------------------------
-- Generate hold signals for read port arbitter
-------------------------------------------------------------------------------
  gen_rd_hold_mask : process (r_finish_r)
    variable hold_v : std_logic;
  begin  -- process gen_rd_hold_mask
    hold_v := '0';
    for i in num_of_read_ports_g - 1 downto 0 loop
      hold_v := hold_v or r_finish_r(i);
    end loop;  -- i
    rd_hold_mask <= hold_v;
  end process gen_rd_hold_mask;

-------------------------------------------------------------------------------
-- Detect read and write port requests and configs from HIBI msg fifo
-------------------------------------------------------------------------------
  detect_rqs_and_confs: process (hibi_msg_addr_in, hibi_msg_empty_in)
    variable msg_addr_v : std_logic_vector(msg_addr_compw_c - 1 downto 0);
  begin  -- process detect_rqs_and_confs

    msg_addr_v := hibi_msg_addr_in(msg_addr_compw_c - 1 downto 0);

    if to_integer(unsigned(msg_addr_v)) = 0 and hibi_msg_empty_in = '0' then
      rd_port_rq   <= '1';
      wr_port_rq   <= '0';
      rd_port_conf <= '0';
      wr_port_conf <= '0';
    elsif to_integer(unsigned(msg_addr_v)) = 1 and hibi_msg_empty_in = '0' then
      rd_port_rq   <= '0';
      wr_port_rq   <= '1';
      rd_port_conf <= '0';
      wr_port_conf <= '0';
    elsif to_integer(unsigned(msg_addr_v)) > 1
      and to_integer(unsigned(msg_addr_v)) < 2 + num_of_read_ports_g
      and hibi_msg_empty_in = '0' then
      rd_port_rq   <= '0';
      wr_port_rq   <= '0';
      rd_port_conf <= '1';
      wr_port_conf <= '0';
    elsif to_integer(unsigned(msg_addr_v)) > 1 + num_of_read_ports_g
      and to_integer(unsigned(msg_addr_v)) <
      2 + num_of_read_ports_g + num_of_write_ports_g
      and hibi_msg_empty_in = '0' then
      rd_port_rq   <= '0';
      wr_port_rq   <= '0';
      rd_port_conf <= '0';
      wr_port_conf <= '1';
    else
      rd_port_rq   <= '0';
      wr_port_rq   <= '0';
      rd_port_conf <= '0';
      wr_port_conf <= '0';
    end if;
  end process detect_rqs_and_confs;

-------------------------------------------------------------------------------
-- BLOCKING
-- Read HIBI msg fifo
-- Only situations for not reading the fifo are:
--   1) read port request and both rd_rq and zero response fifos are full
--   2) write port request and both wr_rq and zero response fifos are full
-------------------------------------------------------------------------------
  gen_blocking_read_msgs: if rq_fifo_depth_g > 0 generate
    read_msgs : process (rd_port_rq, wr_port_rq,
                         rd_rq_full, wr_rq_full,
                         zero_full)
    begin  -- process read_msgs

      if rd_port_rq = '1'
        and rd_rq_full = '1' and zero_full = '1' then

        -- read port request that we can't put anywhere
        -- (i.e. rd_rq_fifo full and zero_fifo full
        hibi_msg_re_out <= '0';

      elsif wr_port_rq = '1'
        and wr_rq_full = '1' and zero_full = '1' then

        -- write port request that we can't put anywhere
        -- (i.e. wr_rq_fifo full and zero_fifo full
        hibi_msg_re_out <= '0';

      else

        -- either port request that we can serve or
        -- port configuration
        hibi_msg_re_out <= '1';
      end if;

    end process read_msgs;
  end generate gen_blocking_read_msgs;
-------------------------------------------------------------------------------
-- NON-BLOCKING
-- Read HIBI msg fifo
-- Only situations for not reading the fifo is when there's a port request
-- and HIBI msg fifo full
-- otherwise we send either port offset or zero offset or we configure port
-------------------------------------------------------------------------------
  gen_non_blocking_read_msgs: if rq_fifo_depth_g = 0 generate
    read_msgs : process (rd_port_rq, wr_port_rq, hibi_msg_full_in)

    begin  -- process read_msgs

      if (rd_port_rq = '1' or wr_port_rq = '1') and hibi_msg_full_in = '1' then

        -- hibi msg fifo full
        hibi_msg_re_out <= '0';

      else

        -- hibi msg fifo not full
        hibi_msg_re_out <= '1';
      end if;

    end process read_msgs;
  end generate gen_non_blocking_read_msgs;

-------------------------------------------------------------------------------
-- BLOCKING
-- Write port requests from HIBI msg fifo to
-- request fifos or zero response fifo
-------------------------------------------------------------------------------
  gen_blocking_write_rq_fifos: if rq_fifo_depth_g > 0 generate
    write_rq_fifos : process (clk, rst_n)
    begin  -- process write_rq_fifos
      if rst_n = '0' then                 -- asynchronous reset (active low)
        rd_rq_we_r   <= '0';
        wr_rq_we_r   <= '0';
        zero_we_r    <= '0';
        zero_in_r    <= (others => '0');
        rd_rq_in_r   <= (others => '0');
        wr_rq_in_r   <= (others => '0');
      elsif clk'event and clk = '1' then  -- rising clock edge

        if rd_rq_we_r = '1' and rd_rq_full = '1' then

          -- wait for previous read request fifo write
          rd_rq_we_r <= '1';
          rd_rq_in_r <= rd_rq_in_r;

        elsif rd_port_rq = '1' and rd_rq_full = '0' then

          -- read port request, write request to read request fifo
          rd_rq_we_r <= '1';
          rd_rq_in_r <= hibi_msg_data_in;

        else
          -- no read port requests or read port request fifo full
          rd_rq_we_r <= '0';
          rd_rq_in_r <= (others => '0');
        end if;

        if wr_rq_we_r = '1' and wr_rq_full = '1' then

          -- wait for previous write port request fifo write
          wr_rq_we_r <= '1';
          wr_rq_in_r <= wr_rq_in_r;

        elsif wr_port_rq = '1' and wr_rq_full = '0' then

          -- write port request, write to write request fifo
          wr_rq_we_r <= '1';
          wr_rq_in_r <= hibi_msg_data_in;
        else

          -- no write port requests or write request fifo full
          wr_rq_we_r <= '0';
          wr_rq_in_r <= (others => '0');
        end if;

        if zero_we_r = '1' and zero_full = '1' then

          -- wait for previous zero response write
          zero_we_r <= '1';
          zero_in_r <= zero_in_r;

        elsif ((rd_port_rq = '1' and rd_rq_full = '1')
               or (wr_port_rq = '1' and wr_rq_full = '1'))
          and zero_full = '0' then

          -- read or write port request and
          -- corresponding request fifo full
          -- write to zero response fifo
          zero_we_r <= '1';
          zero_in_r <= hibi_msg_data_in;

        else

          -- requests go to request fifo or
          -- zero response fifo full
          zero_we_r <= '0';
          zero_in_r <= (others => '0');
        end if;
      
      end if;
    end process write_rq_fifos;
  end generate gen_blocking_write_rq_fifos;

-------------------------------------------------------------------------------
-- BLOCKING
-- Read port requests from request fifos
-- type   : combinational
--
-- !!! NOTE !!!
-- Write response and read response must be in the same order as in
-- send_resps process(i.e. if write request sending is the 1st elsif then
-- wr rq fifo read should also be the 1st elsif in read_rq_fifos process
-------------------------------------------------------------------------------
  gen_blocking_read_rq_fifos: if rq_fifo_depth_g > 0 generate
    read_rq_fifos : process (rd_rq_empty, wr_rq_empty, zero_empty,
                             free_r_port, free_w_port,
                             hibi_msg_full_in)
      variable free_r_port_v : std_logic;
      variable free_w_port_v : std_logic;
    begin  -- process read_rq_fifos

      if wr_rq_empty = '0' and free_w_port = '1' and hibi_msg_full_in = '0' then

        -- Write port request from fifo
        -- Free write port available and HIBI msg fifo not full
        rd_rq_re <= '0';
        wr_rq_re <= '1';
        zero_re  <= '0';

      elsif rd_rq_empty = '0' and free_r_port = '1' and hibi_msg_full_in = '0' then

        -- Read port request from fifo
        -- Free read port available and HIBI msg fifo not full
        rd_rq_re <= '1';
        wr_rq_re <= '0';
        zero_re  <= '0';
        
      elsif zero_empty = '0' and hibi_msg_full_in = '0' then

        -- Read or write port request
        -- No ports available and and HIBI msg fifo not full
        rd_rq_re <= '0';
        wr_rq_re <= '0';
        zero_re  <= '1';

      else
        rd_rq_re <= '0';
        wr_rq_re <= '0';
        zero_re  <= '0';
      end if;
    end process read_rq_fifos;
  end generate gen_blocking_read_rq_fifos;

-------------------------------------------------------------------------------
-- BLOCKING
-- Send responses to port requests
-- Options are:
--  1) Free read port offset to request from rd_rq_fifo
--  2) Free write port offset to request from wr_rq_fifo
--  3) Zero response to request from zero fifo
--
-- !!! NOTE !!!
-- Write response and read response must be in the same order as in
-- read_rq_fifos process(i.e. if write request sending is the 1st elsif then
-- wr rq fifo read should also be the 1st elsif in read_rq_fifos process
-------------------------------------------------------------------------------
  gen_blocking_send_resps: if rq_fifo_depth_g > 0 generate
    send_resps : process (clk, rst_n)
    begin  -- process send_resps
      if rst_n = '0' then                 -- asynchronous reset (active low)
        hibi_msg_we_r   <= '0';
        hibi_msg_addr_r <= (others => '0');
        hibi_msg_data_r <= (others => '0');
      elsif clk'event and clk = '1' then  -- rising clock edge

        if hibi_msg_we_r = '1' and hibi_msg_full_in = '1' then

          -- wait for previous write
          hibi_msg_we_r   <= '1';
          hibi_msg_addr_r <= hibi_msg_addr_r;
          hibi_msg_data_r <= hibi_msg_data_r;

        elsif wr_rq_empty = '0' and free_w_port = '1' and hibi_msg_full_in = '0' then

          -- free write port and write request in fifo and
          -- HIBI msg fifo not full, send write port offset
          hibi_msg_we_r   <= '1';
          hibi_msg_addr_r <= wr_rq;
          hibi_msg_data_r <= std_logic_vector(
            to_unsigned(free_w_offset, hibi_msg_data_r'length));

        elsif rd_rq_empty = '0' and free_r_port = '1' and hibi_msg_full_in = '0' then
          -- free read port and read request in fifo and
          -- HIBI msg fifo not full, send read port offset
          hibi_msg_we_r   <= '1';
          hibi_msg_addr_r <= rd_rq;
          hibi_msg_data_r <=std_logic_vector(
            to_unsigned(free_r_offset, hibi_msg_data_r'length));

        elsif zero_empty = '0' and hibi_msg_full_in = '0' then
          -- no free ports and HIBI msg fifo not full,
          -- send zero response
          hibi_msg_we_r   <= '1';
          hibi_msg_addr_r <= zero_out_r;
          hibi_msg_data_r <= (others => '0');

        else
          hibi_msg_we_r   <= '0';
          hibi_msg_addr_r <= (others => '0');
          hibi_msg_data_r <= (others => '0');
        end if;
      end if;
    end process send_resps;
  end generate gen_blocking_send_resps;
-------------------------------------------------------------------------------
-- NON-BLOCKING
-- Send responses to port requests
-- Options are:
--  1) Free read port offset to request from HIBI msg fifo
--  2) Free write port offset to request from HIBI msg fifo
--  3) Zero response to request from HIBI msg fifo
-------------------------------------------------------------------------------
  gen_non_blocking_send_resps: if rq_fifo_depth_g = 0 generate
    send_resps : process (clk, rst_n)
    begin  -- process send_resps
      if rst_n = '0' then                 -- asynchronous reset (active low)
        hibi_msg_we_r   <= '0';
        hibi_msg_addr_r <= (others => '0');
        hibi_msg_data_r <= (others => '0');
      elsif clk'event and clk = '1' then  -- rising clock edge

        if hibi_msg_we_r = '1' and hibi_msg_full_in = '1' then
          -- wait for previous write
          hibi_msg_we_r   <= '1';
          hibi_msg_addr_r <= hibi_msg_addr_r;
          hibi_msg_data_r <= hibi_msg_data_r;

        elsif wr_port_rq = '1' and free_w_port = '1'
          and hibi_msg_full_in = '0' then
          -- write port request and free write port available
          -- send free write port offset
          hibi_msg_we_r   <= '1';
          hibi_msg_addr_r <= hibi_msg_data_in;
          hibi_msg_data_r <= std_logic_vector(
            to_unsigned(free_w_offset, hibi_msg_data_r'length));
          
        elsif rd_port_rq = '1' and free_r_port = '1'
          and hibi_msg_full_in = '0' then
          -- read port request and free read port available
          -- send free read port offset
          hibi_msg_we_r   <= '1';
          hibi_msg_addr_r <= hibi_msg_data_in;
          hibi_msg_data_r <= std_logic_vector(
            to_unsigned(free_r_offset, hibi_msg_data_r'length));

        elsif wr_port_rq = '1' and free_w_port = '0'
          and hibi_msg_full_in = '0' then
          -- write port request and
          -- no free write ports, send zero offset
          hibi_msg_we_r   <= '1';
          hibi_msg_addr_r <= hibi_msg_data_in;
          hibi_msg_data_r <= (others => '0');

        elsif rd_port_rq = '1' and free_r_port = '0'
          and hibi_msg_full_in = '0' then
          -- read port request and
          -- no free read ports, send zero offset
          hibi_msg_we_r   <= '1';
          hibi_msg_addr_r <= hibi_msg_data_in;
          hibi_msg_data_r <= (others => '0');

        else
          hibi_msg_we_r   <= '0';
          hibi_msg_addr_r <= (others => '0');
          hibi_msg_data_r <= (others => '0');
        end if;
      end if;
    end process send_resps;
  end generate gen_non_blocking_send_resps;

-------------------------------------------------------------------------------
-- BLOCKING
-- Reserve ports when we send port offset
-------------------------------------------------------------------------------
  gen_blocking_reserve_ports: if rq_fifo_depth_g > 0 generate
    reserve_ports : process (rd_rq_re, wr_rq_re,
                             free_r_num_r, free_w_num)
    begin
      -- defaults
      r_reserve <= (others => '0');
      w_reserve <= (others => '0');

      if rd_rq_re = '1' then
        -- we send and reserve read port offset
        -- when we read from rd_rq fifo
        r_reserve(free_r_num_r) <= '1';
      elsif wr_rq_re = '1' then
        -- we send and reserve write port offset
        -- when we read from wr_rq fifo
        w_reserve(free_w_num) <= '1';
      end if;
    end process reserve_ports;
  end generate gen_blocking_reserve_ports;
-------------------------------------------------------------------------------
-- NON-BLOCKING
-- Reserve ports when we send port offset
-------------------------------------------------------------------------------
  gen_non_blocking_reserve_ports: if rq_fifo_depth_g = 0 generate
    reserve_ports : process (rd_port_rq, wr_port_rq,
                             free_r_port, free_w_port,
                             free_r_num_r, free_w_num,
                             hibi_msg_full_in)
    begin
      -- defaults
      r_reserve <= (others => '0');
      w_reserve <= (others => '0');

      if rd_port_rq = '1' and free_r_port = '1'
        and hibi_msg_full_in = '0' then
        -- we send and reserve read port offset
        -- when we read from rd_rq fifo
        r_reserve(free_r_num_r) <= '1';
      elsif wr_port_rq = '1' and free_w_port = '1'
        and hibi_msg_full_in = '0' then
        -- we send and reserve write port offset
        -- when we read from wr_rq fifo
        w_reserve(free_w_num) <= '1';
      end if;
    end process reserve_ports;
  end generate gen_non_blocking_reserve_ports;

-------------------------------------------------------------------------------
-- Update free read port pointer
-------------------------------------------------------------------------------
  update_free_r_num: process (clk, rst_n)
  begin  -- process update_free_r_num
    if rst_n = '0' then                 -- asynchronous reset (active low)
      free_r_num_r <= 0;
    elsif clk'event and clk = '1' then  -- rising clock edge
      if to_integer(unsigned(r_reserve)) /= 0 then

        if free_r_num_r = num_of_read_ports_g - 1 then
          free_r_num_r <= 0;
        else
          free_r_num_r <= free_r_num_r + 1;
        end if;
      end if;
    else
      free_r_num_r <= free_r_num_r;
    end if;
  end process update_free_r_num;
  free_r_offset <= 2 + free_r_num_r;
  free_r_port   <= not(r_reserved_r(free_r_num_r));

-------------------------------------------------------------------------------
-- Read configurations from HIBI msg fifo and send them to ports
-------------------------------------------------------------------------------
  send_configs_to_ports : process (clk, rst_n)
    variable msg_addr_v : std_logic_vector(msg_addr_compw_c - 1 downto 0);
  begin  -- process send_configs_to_ports
    if rst_n = '0' then                 -- asynchronous reset (active low)
      conf_wr_r   <= (others => '0');
      conf_rd_r   <= (others => '0');
      conf_data_r <= (others => '0');
      msg_addr_v  := (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge

      -- read conf_data_r
      conf_data_r <= hibi_msg_data_in;

      -- we don't need to compare all bits
      -- only addresses 0..2+num_of_read_ports_g+num_of_write_ports_g
      -- are of interest
      msg_addr_v := hibi_msg_addr_in(msg_addr_compw_c - 1 downto 0);

      if wr_port_conf = '1' then
        
        -- Write port configuration from HIBI msg fifo
        conf_rd_r <= (others => '0');   -- not a read config
        for i in num_of_write_ports_g - 1 downto 0 loop
          -- which port is configured?
          if to_integer(unsigned(msg_addr_v))
            - 2 - num_of_read_ports_g = i then
            conf_wr_r(i) <= '1';
          else
            conf_wr_r(i) <= '0';
          end if;
        end loop;  -- i

      elsif rd_port_conf = '1' then
        
        -- Read port configuration from HIBI msg fifo
        conf_wr_r <= (others => '0');   -- not a write config
        for i in num_of_read_ports_g - 1 downto 0 loop
          -- which port is configured?
          if to_integer(unsigned(msg_addr_v)) - 2 = i then
            conf_rd_r(i) <= '1';
          else
            conf_rd_r(i) <= '0';
          end if;
        end loop;  -- i
      else
        -- no configs
        conf_rd_r <= (others => '0');
        conf_wr_r <= (others => '0');
      end if;
    end if;
  end process send_configs_to_ports;

-------------------------------------------------------------------------------
-- Detect read and write port overlaps and
-- block overlapping reads
-------------------------------------------------------------------------------
  detect_overlaps : process (clk, rst_n)
  begin  -- process detect_overlaps
    if rst_n = '0' then                 -- asynchronous reset (active low)
      r_overlap_vec_r <= (others => (others => '0'));
      prev_r_valid_r  <= (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge

      -- detect rising edge of valid read port signals
      prev_r_valid_r <= r_valid_r;

      for r in num_of_read_ports_g - 1 downto 0 loop
        -- read port is being reserved,
        -- default overlap for all write ports until
        -- we have calculated the actual overlap
        if r_reserve(r) = '1' then
          r_overlap_vec_r(r) <= (others => '1');
        end if;
      end loop;  -- r

      for r in num_of_read_ports_g - 1 downto 0 loop

        if prev_r_valid_r(r) = '0' and r_valid_r(r) = '1' then

          -- read port configured, calculate actual overlaps
          for w in num_of_write_ports_g - 1 downto 0 loop

            if w_valid_r(w) = '1' then

              -- overlap can happen only with valid write ports
              --   - no overlap if read start addr > write end addr or
              --                   read end addr < write start addr
              if unsigned(r_src_addr_r(r)) > unsigned(w_end_addr_r(w)) or
                unsigned(r_end_addr_r(r)) < unsigned(w_dst_addr_r(w)) then
                r_overlap_vec_r(r)(w) <= '0';
              else
                r_overlap_vec_r(r)(w) <= '1';
              end if;
            else
              r_overlap_vec_r(r)(w) <= '0';
            end if;
          end loop;  -- w
        end if;
      end loop;  -- r

      -- if write port finishes, clear overlap
      for w in num_of_write_ports_g - 1 downto 0 loop
        if w_valid_r(w) = '0' then
          for r in num_of_read_ports_g - 1 downto 0 loop
            r_overlap_vec_r(r)(w) <= '0';
          end loop;  -- r
        end if;
      end loop;  -- w
      
    end if;
  end process detect_overlaps;

-------------------------------------------------------------------------------
-- Find free read and write ports
-------------------------------------------------------------------------------
  -- Find free read ports
--  find_free_r_port : process (r_reserved_r)
--  begin  -- process find_free_r_port
--
--    free_r_port   <= '0';
--    free_r_num    <= 0;
--    free_r_offset <= 0;
--    for i in num_of_read_ports_g - 1 downto 0 loop
--      if r_reserved_r(i) = '0' then
--        -- if port is not reserved, it is free
--        free_r_port   <= '1';
--        free_r_num    <= i;
--        free_r_offset <= 2 + i;
--      end if;
--    end loop;  -- i
--
--  end process find_free_r_port;

  -- Find free write ports
  find_free_w_port : process (w_reserved_r)
  begin  -- process find_free_w_port

    free_w_port   <= '0';
    free_w_num    <= 0;
    free_w_offset <= 0;

    for i in num_of_write_ports_g - 1 downto 0 loop
      if w_reserved_r(i) = '0' then
        -- if port is not reserved, it is free
        free_w_port   <= '1';
        free_w_num    <= i;
        free_w_offset <= 2 + num_of_read_ports_g + i;
      end if;
    end loop;  -- i

  end process find_free_w_port;

-----------------------------------------------------------------------------
-- Read HIBI and put data into ports
-----------------------------------------------------------------------------

  -- Read HIBI fifo
  -- Read always except when previous write is pending
  read_hibi : process (w_full, w_we_r, single_op_full, single_op_we_r)
  begin  -- process read_hibi

    if single_op_full = '1' and single_op_we_r = '1' then
      -- wait for single op write
      hibi_re_out <= '0';
    elsif to_integer(unsigned(w_full and w_we_r)) /= 0 then
      -- wait for write port write
      hibi_re_out <= '0';
    else
      hibi_re_out <= '1';
    end if;
  end process read_hibi;

  -- Write HIBI data to single op fifo or write port input fifos
  sort_data_to_ports : process (clk, rst_n)
    variable port_write_v : std_logic;
  begin  -- process sort_data_to_ports
    if rst_n = '0' then                 -- asynchronous reset (active low)
      single_op_comm_in_r <= (others => '0');
      single_op_we_r      <= '0';
      w_we_r              <= (others => '0');
      data_to_fifos_r     <= (others => '0');
      single_op_addr_in_r <= (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge

      if single_op_we_r = '1' and single_op_full = '1' then

        -- wait for previous single op write
        single_op_we_r      <= single_op_we_r;
        w_we_r              <= (others => '0');
        data_to_fifos_r     <= data_to_fifos_r;
        single_op_addr_in_r <= single_op_addr_in_r;
        single_op_comm_in_r <= single_op_comm_in_r;

      elsif to_integer(unsigned(w_full and w_we_r)) /= 0 then

        -- wait for previous write port fifo write
        single_op_we_r      <= '0';
        w_we_r              <= w_we_r;
        data_to_fifos_r     <= data_to_fifos_r;
        single_op_addr_in_r <= single_op_addr_in_r;
        single_op_comm_in_r <= single_op_comm_in_r;

      elsif hibi_empty_in = '0' then

        -- data from HIBI fifo

   -- Original broken code before fixing on 2012 by A.Alhonen
   -- Please test the new one thoroughly and remove the commented code
   -- if the new is really ok.
--        single_op_addr_in_r <= hibi_addr_in;
        single_op_addr_in_r <= std_logic_vector(unsigned(hibi_addr_in) -
                               to_unsigned(own_hibi_base_addr_g, hibi_data_width_g));

        data_to_fifos_r     <= hibi_data_in;

        if hibi_comm_in = DATA_WR_c then

          -- write comm from HIBI
          single_op_comm_in_r <= "10";  -- write
          port_write_v        := '0';
          for i in num_of_write_ports_g - 1 downto 0 loop
            -- is this a port write?

   -- Original broken code before fixing on 2012 by A.Alhonen
   -- Please test the new one thoroughly and remove the commented code
   -- if the new is really ok.
--            if to_integer(unsigned(
--              hibi_addr_in(mem_addr_width_g - 1
--                           downto 0))) - 2 - num_of_read_ports_g = i then

            if to_integer(unsigned(hibi_addr_in)) - own_hibi_base_addr_g
              - 2 - num_of_read_ports_g = i then
              -- yes it is, write to write port fifo
              port_write_v := '1';
              w_we_r(i)    <= '1';
            else
              w_we_r(i) <= '0';
            end if;
          end loop;  -- i

          if port_write_v = '0' then
            -- single op write, write to single op fifo
            single_op_we_r      <= '1';
            single_op_comm_in_r <= "10";  -- write
          else
            single_op_we_r      <= '0';
            single_op_comm_in_r <= single_op_comm_in_r;
          end if;

        else
          -- read comm from HIBI
          -- single read
          w_we_r              <= (others => '0'); -- not write
          single_op_comm_in_r <= "01";            -- read
          single_op_we_r      <= '1';
        end if;

      else

        -- HIBI empty, do nothing
        single_op_we_r      <= '0';
        w_we_r              <= (others => '0');
        single_op_comm_in_r <= single_op_comm_in_r;
        data_to_fifos_r     <= hibi_data_in;

      end if;
    end if;
  end process sort_data_to_ports;


-------------------------------------------------------------------------------
-- Update curr read port ptr
-------------------------------------------------------------------------------
  update_curr_rd_port: process (clk, rst_n)
  begin  -- process update_curr_rd_port
    if rst_n = '0' then                 -- asynchronous reset (active low)
      curr_rd_port_r <= 0;
    elsif clk'event and clk = '1' then  -- rising clock edge
      if to_integer(unsigned(r_finish_r)) /= 0 then
        if curr_rd_port_r = num_of_read_ports_g - 1 then
          curr_rd_port_r <= 0;
        else
          curr_rd_port_r <= curr_rd_port_r + 1;
        end if;
      else
        curr_rd_port_r <= curr_rd_port_r;
      end if;
    end if;
  end process update_curr_rd_port;
-------------------------------------------------------------------------------
-- Assigns commands from read/write ports or from single
-- operation port to sdram_controller.
-- This only tries one operation per cycle. So if next operation
-- is read and there's no valid read operations in the read
-- ports, one cycle is wasted. This could be optimized.
-------------------------------------------------------------------------------
  from_ports_to_controller : process (clk, rst_n)
  begin  -- process from_ports_to_controller

    if rst_n = '0' then                 -- asynchronous reset (active low)

      sdram_ctrl_comm_out        <= "00";
      sdram_ctrl_addr_out        <= (others => '0');
      sdram_ctrl_data_amount_out <= (others => '0');
--      curr_rd_port_r             <= 0;
--      curr_wr_port_r             <= 0;
      hibi_addr_out              <= (others => '0');
      single_op_re_r             <= '0';
      single_op_on_r             <= '0';
      single_op_data_out_r       <= (others => '0');
      state_r                    <= idle;
      wr_hold_mask               <= '0';
      single_op_hold_mask        <= '0';

    elsif clk'event and clk = '1' then  -- rising clock edge

      case state_r is

        when idle =>

          wr_hold_mask        <= '0';
          single_op_hold_mask <= '0';

          single_op_re_r <= '0';

          if sdram_ctrl_busy_in = '0' then

            -- SDRAM controller is ready for new operation
            if next_op(blk_rd_prior_g) = '1' then

              -- Start block read
              single_op_on_r <= '0';

              -- set curr_wr_port_r to 'illegal' value
              curr_wr_port_r <= num_of_write_ports_g;

--              for i in num_of_read_ports_g - 1 downto 0 loop
--                -- which read port's turn?
--                if next_rd_port(i) = '1' then
--                  curr_rd_port_r             <= i;
--                  sdram_ctrl_addr_out        <= r_src_addr_r(i);
--                  sdram_ctrl_data_amount_out <= r_amount_r(i);
--                  hibi_addr_out              <= r_ret_addr_r(i);
--                end if;
--              end loop;  -- rd_port
              sdram_ctrl_addr_out        <= r_src_addr_r(curr_rd_port_r);
              sdram_ctrl_data_amount_out <= r_amount_r(curr_rd_port_r);
              hibi_addr_out              <= r_ret_addr_r(curr_rd_port_r);

              -- 17.10.06 HP
              sdram_ctrl_comm_out <= "01";  -- read comm to sdram_controller
              state_r             <= wait_for_block_read_start;

            elsif next_op(blk_wr_prior_g) = '1' then

              -- Start block write
              single_op_on_r <= '0';

              -- set curr_rd_port_r to 'illegal' value
--              curr_rd_port_r <= num_of_read_ports_g;

              for i in num_of_write_ports_g - 1 downto 0 loop
                -- which write ports turn?
                if next_wr_port(i) = '1' then
                  curr_wr_port_r             <= i;
                  sdram_ctrl_addr_out        <= w_dst_addr_r(i);
                  sdram_ctrl_data_amount_out <= w_amount_r(i);
                end if;
              end loop;  -- wr_port

              sdram_ctrl_comm_out <= "10";  -- write comm to sdram_controller
              state_r             <= wait_for_block_write_start;

            elsif next_op(single_op_prior_g) = '1' then

              -- start single operation
              single_op_on_r <= '1';

              -- set curr_rd_port_r and curr_wr_port_r to 'illegal' values
--              curr_rd_port_r <= num_of_read_ports_g;
              curr_wr_port_r <= num_of_write_ports_g;

              single_op_data_out_r <= single_op_data_out;
              sdram_ctrl_addr_out  <= single_op_addr_out;
              sdram_ctrl_data_amount_out <= std_logic_vector(
                to_unsigned(1, sdram_ctrl_data_amount_out'length));
              hibi_addr_out <= single_op_data_out;

              if single_op_comm_out = "10" or hibi_full_in = '0' then

                -- write operation or hibi not full,
                -- start operation
                sdram_ctrl_comm_out <= single_op_comm_out;

              else
                -- read operation and hibi full,
                -- don't start yet
                sdram_ctrl_comm_out <= "00";
              end if;

              state_r <= wait_for_single_op_start;

            else

              -- no valid ports or output fifo full
              -- do nothing

              single_op_on_r      <= '0';
              sdram_ctrl_comm_out <= "00";  -- nop

              state_r <= idle;

            end if;

          else

            -- sdram controller busy, do nothing
--            curr_rd_port_r      <= curr_rd_port_r;
            curr_wr_port_r      <= curr_wr_port_r;
            single_op_on_r      <= single_op_on_r;
            sdram_ctrl_comm_out <= "00";  -- nop
            state_r             <= idle;
          end if;

        when wait_for_block_read_start =>

          -- keep read parameters on lines until controller gets to work
          -- (sdram_ctrl_busy_in goes up)
          single_op_on_r             <= '0';
          sdram_ctrl_addr_out        <= r_src_addr_r(curr_rd_port_r);
          sdram_ctrl_data_amount_out <= r_amount_r(curr_rd_port_r);
          hibi_addr_out              <= r_ret_addr_r(curr_rd_port_r);

          if sdram_ctrl_busy_in = '0' then
            sdram_ctrl_comm_out <= "01";
            state_r             <= wait_for_block_read_start;
          else
            -- operation started, go to idle
            sdram_ctrl_comm_out <= "00";
            state_r             <= idle;
          end if;

        when wait_for_block_write_start =>

          -- keep write parameters on lines until controller gets to work
          -- (sdram_ctrl_busy_in goes up)
          single_op_on_r             <= '0';
          sdram_ctrl_addr_out        <= w_dst_addr_r(curr_wr_port_r);
          sdram_ctrl_data_amount_out <= w_amount_r(curr_wr_port_r);

          if sdram_ctrl_busy_in = '0' then
            sdram_ctrl_comm_out <= "10";
            state_r             <= wait_for_block_write_start;
          else
            -- operation started, go to idle
            sdram_ctrl_comm_out <= "00";
            wr_hold_mask        <= '1';
            state_r             <= idle;
          end if;

        when wait_for_single_op_start =>

          single_op_on_r      <= '1';
          hibi_addr_out       <= single_op_data_out;
          sdram_ctrl_addr_out <= single_op_addr_out;
          sdram_ctrl_data_amount_out <= std_logic_vector(
            to_unsigned(1, sdram_ctrl_data_amount_out'length));

          if sdram_ctrl_busy_in = '0' then

            single_op_re_r <= '0';

            -- if hibi_data_out full and single_op_comm is read then we
            -- must wait until hibi is not full
            if single_op_comm_out = "10" or hibi_full_in = '0' then
              sdram_ctrl_comm_out <= single_op_comm_out;
            else
              sdram_ctrl_comm_out <= "00";
            end if;

            state_r <= wait_for_single_op_start;

          else
            -- operation started, go to idle
            sdram_ctrl_comm_out <= "00";
            single_op_re_r      <= '1';
            single_op_hold_mask <= '1';
            state_r             <= idle;
          end if;

        when others =>
          null;

      end case;

    end if;

  end process from_ports_to_controller;

  -- purpose: demux sdram controller signals to
  --          read ports
  rd_demux : process (curr_rd_port_r, sdram_ctrl_we_in, single_op_on_r)
  begin  -- process rd_demux

    for r in num_of_read_ports_g - 1 downto 0 loop
      if curr_rd_port_r = r and single_op_on_r = '0' then
        sdram_read(r) <= sdram_ctrl_we_in;
      else
        sdram_read(r) <= '0';
      end if;
    end loop;  -- r

  end process rd_demux;

  -- purpose: demux sdram controller signals to
  --          write ports
  wr_demuxes : process (curr_wr_port_r, sdram_ctrl_re_in,
                        sdram_ctrl_write_on_in)
  begin  -- process wr_demuxes

    for w in num_of_write_ports_g - 1 downto 0 loop
      if curr_wr_port_r = w then
        w_re_r(w)      <= sdram_ctrl_re_in;
        sdram_write(w) <= sdram_ctrl_write_on_in;
      else
        w_re_r(w)      <= '0';
        sdram_write(w) <= '0';
      end if;
    end loop;  -- w

  end process wr_demuxes;

  arbiter_op : sdram_arbiter
    generic map (
      arb_width_g => 3,
      arb_type_g  => op_arb_type_g)
    port map (
      clk       => clk,
      rst_n     => rst_n,
      req_in    => next_op_req,
      hold_in   => next_op_hold,
      grant_out => next_op);

  arbiter_rd : sdram_arbiter
    generic map (
      arb_width_g => num_of_read_ports_g,
      arb_type_g  => port_arb_type_g)
    port map (
      clk       => clk,
      rst_n     => rst_n,
      req_in    => r_port_req,
      hold_in   => r_port_hold,
      grant_out => next_rd_port);

  arbiter_wr : sdram_arbiter
    generic map (
      arb_width_g => num_of_write_ports_g,
      arb_type_g  => port_arb_type_g)
    port map (
      clk       => clk,
      rst_n     => rst_n,
      req_in    => w_port_req,
      hold_in   => w_port_hold,
      grant_out => next_wr_port);

  gen_write_ports : for i in num_of_write_ports_g - 1 downto 0 generate
    wr_port_1 : sdram_wr_port
      generic map (
        fifo_depth_g    => input_fifo_depth_g,
        amountw_g       => amountw_g,
        hibi_dataw_g    => hibi_data_width_g,
        block_overlap_g => block_overlap_g,
        offsetw_g       => offset_width_g,
        mem_dataw_g     => mem_data_width_g,
        mem_addrw_g     => mem_addr_width_g)
      port map (
        clk            => clk,
        rst_n          => rst_n,
        conf_we_in     => conf_wr_r(i),
        conf_data_in   => conf_data_r,
        write_in       => sdram_write(i),
        reserve_in     => w_reserve(i),
        valid_out      => w_valid_r(i),
        reserved_out   => w_reserved_r(i),
        end_addr_out   => w_end_addr_r(i),
        dst_addr_out   => w_dst_addr_r(i),
        amount_out     => w_amount_r(i),
        fifo_we_in     => w_we_r(i),
        fifo_re_in     => w_re_r(i),
        fifo_data_in   => data_to_fifos_r,
        fifo_full_out  => w_full(i),
        fifo_empty_out => w_empty(i),
        fifo_one_p_out => w_one_p_left(i),
        fifo_one_d_out => w_one_d_left(i),
        fifo_data_out  => w_data_out(i),
        error_out      => open);  
  end generate gen_write_ports;

  gen_read_ports : for i in num_of_read_ports_g - 1 downto 0 generate
    rd_port_1 : sdram_rd_port
      generic map (
        amountw_g       => amountw_g,
        hibi_dataw_g    => hibi_data_width_g,
        block_overlap_g => block_overlap_g,
        offsetw_g       => offset_width_g,
        mem_dataw_g     => mem_data_width_g,
        mem_addrw_g     => mem_addr_width_g)
      port map (
        clk          => clk,
        rst_n        => rst_n,
        conf_we_in   => conf_rd_r(i),
        conf_data_in => conf_data_r,
        read_in      => sdram_read(i),
        reserve_in   => r_reserve(i),
        valid_out    => r_valid_r(i),
        reserved_out => r_reserved_r(i),
        end_addr_out => r_end_addr_r(i),
        src_addr_out => r_src_addr_r(i),
        amount_out   => r_amount_r(i),
        ret_addr_out => r_ret_addr_r(i),
        finish_out   => r_finish_r(i),
        error_out    => open);
  end generate gen_read_ports;

  -- fifo for blocking read requests(blocking)
  gen_rq_fifos : if rq_fifo_depth_g /= 0 generate
    
    rd_rq_fifo : fifo
      generic map (
        data_width_g => hibi_data_width_g,
        depth_g      => rq_fifo_depth_g
        )
      port map (
        clk       => clk,
        rst_n     => rst_n,
        data_in   => rd_rq_in_r,        --hibi_msg_data_in,
        we_in     => rd_rq_we_r,
        one_p_out => open,
        full_out  => rd_rq_full,
        data_out  => rd_rq,
        re_in     => rd_rq_re,
        empty_out => rd_rq_empty,
        one_d_out => open
        );

    -- fifo for blocking write requests
    wr_rq_fifo : fifo
      generic map (
        data_width_g => hibi_data_width_g,
        depth_g      => rq_fifo_depth_g
        )
      port map (
        clk       => clk,
        rst_n     => rst_n,
        data_in   => wr_rq_in_r,        --hibi_msg_data_in,
        we_in     => wr_rq_we_r,
        one_p_out => open,
        full_out  => wr_rq_full,
        data_out  => wr_rq,
        re_in     => wr_rq_re,
        empty_out => wr_rq_empty,
        one_d_out => open
        );
    zero_fifo : fifo
      generic map (
        data_width_g => hibi_data_width_g,
        depth_g      => 1
        )
      port map (
        clk       => clk,
        rst_n     => rst_n,
        data_in   => zero_in_r,         --hibi_msg_data_in,
        we_in     => zero_we_r,
        one_p_out => open,
        full_out  => zero_full,
        data_out  => zero_out_r,
        re_in     => zero_re,
        empty_out => zero_empty,
        one_d_out => open
        );

  end generate gen_rq_fifos;

  -- fifo for storing operations of length 1 and don't have their own port
  single_operations_fifo : fifo
    generic map (
      data_width_g => 2 + hibi_data_width_g + hibi_data_width_g,
      depth_g      => input_fifo_depth_g
      )
    port map (
      clk       => clk,
      rst_n     => rst_n,
      data_in   => single_op_in,
      we_in     => single_op_we_r,
      one_p_out => single_op_one_p_left,
      full_out  => single_op_full,
      data_out  => single_op_out,
      re_in     => single_op_re_r,
      empty_out => single_op_empty,
      one_d_out => single_op_one_d_left
      );

end rtl;
