-------------------------------------------------------------------------------
-- Title      : tb_agent_so
-- Project    : 
-------------------------------------------------------------------------------
-- File       : tb_agent_so.vhd
-- Author     : 
-- Company    : 
-- Created    : 2006-10-03
-- Last update: 2006-10-24
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: Agent that sends request to sdram2hibi
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
use work.txt_util.all;

entity tb_agent_so is
  
  generic (
    own_addr_g    : integer;
    check_rd_data : integer := 0;
    data_width_g  : integer;
    addr_width_g  : integer
    );
  port (
    clk          : in  std_logic;
    rst_n        : in  std_logic;
    req_out      : out std_logic;
    hold_out     : out std_logic;
    grant_in     : in  std_logic;
    data_out     : out std_logic_vector(data_width_g - 1 downto 0);
    addr_out     : out std_logic_vector(addr_width_g - 1 downto 0);
    comm_out     : out std_logic_vector(2 downto 0);
    re_out       : out std_logic;
    we_out       : out std_logic;
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
    msg_re_out   : out std_logic;
    msg_we_out   : out std_logic
    );
end tb_agent_so;

architecture behavioral of tb_agent_so is

  type state_vec_type is (idle,
                          single_read, single_write);
  signal state_r : state_vec_type;

  type conf_state_type is (conf_dst_addr, conf_src_addr,
                           conf_amount, conf_height_offset,
                           conf_ret_addr);
  signal wr_conf_state : conf_state_type;
  signal rd_conf_state : conf_state_type;
  signal rd_port_addr  : std_logic_vector(data_width_g - 1 downto 0);
  signal wr_port_addr  : std_logic_vector(data_width_g - 1 downto 0);

  type chk_state_vec is (run_test, test_finished);
  signal chk_state_r : chk_state_vec;
  signal msg_we_r    : std_logic;
  signal we_r        : std_logic;

  signal dst_addr_r  : std_logic_vector(addr_width_g - 1 downto 0);
  signal src_addr_r  : std_logic_vector(addr_width_g - 1 downto 0);
  signal wr_amount_r : std_logic_vector(data_width_g - 1 downto 0);
  signal rd_amount_r : std_logic_vector(data_width_g - 1 downto 0);
  signal wr_count_r  : std_logic_vector(data_width_g - 1 downto 0);
  signal rd_count_r  : std_logic_vector(data_width_g - 1 downto 0);

  signal wr_data_r : std_logic_vector(data_width_g - 1 downto 0);

  signal chk_count_r  : std_logic_vector(data_width_g - 1 downto 0);
  signal chk_amount_r : std_logic_vector(data_width_g - 1 downto 0);

begin  -- behavioral

  msg_we_out <= msg_we_r;
  we_out     <= we_r;

  check_results : process (clk, rst_n)
  begin  -- process check_results

    if rst_n = '0' then                 -- asynchronous reset (active low)
      re_out       <= '1';
      msg_re_out   <= '0';
      rd_count_r   <= (others => '0');
      chk_amount_r <= std_logic_vector(to_unsigned(1, data_width_g));
      chk_count_r  <= std_logic_vector(to_unsigned(1, data_width_g));

      chk_state_r <= run_test;

    elsif clk'event and clk = '1' then  -- rising clock edge

      re_out <= '1';

      case chk_state_r is
        when run_test =>

          if empty_in = '0' then

            -- check incoming addr
            assert to_integer(unsigned(addr_in)) = own_addr_g
              report "ERROR: tb_ag(lo) 0x" &
              str(own_addr_g, 16) &
              " got addr: 0x" & str(to_integer(unsigned(addr_in)), 16) severity failure;

            -- check incoming data
            assert std_logic_vector(to_unsigned(own_addr_g, data_width_g) + unsigned(rd_count_r)) = data_in
              report "ERROR: data corrupted exp: 0x" &
              str(to_integer(unsigned(rd_count_r)) + own_addr_g, 16) & " got: 0x" &
              str(to_integer(unsigned(data_in)), 16) severity failure;
            assert std_logic_vector(to_unsigned(own_addr_g, data_width_g) + unsigned(rd_count_r)) /= data_in
              report "data ok got: 0x" &
              str(to_integer(unsigned(data_in)), 16) severity note;

            rd_count_r <= std_logic_vector(unsigned(rd_count_r) + 1);

            if unsigned(rd_count_r) >= 255 then
              
              assert unsigned(rd_count_r) < 255 report "++++++++ ag: 0x" & str(own_addr_g, 16) &
                " TEST SUCCESFUL ++++++++++++++++++++"
                severity failure;
              chk_state_r <= test_finished;
            end if;

          else
            chk_state_r <= chk_state_r;
          end if;

          -- check incoming msg addr
          if msg_empty_in = '0' then
            assert to_integer(unsigned(msg_addr_in)) = own_addr_g
              report "ERROR: tb_ag(msg) 0x" &
              str(own_addr_g, 16) &
              " got addr: 0x" & str(to_integer(unsigned(msg_addr_in)), 16) severity failure;
          end if;
        when test_finished =>
          null;
        when others =>
          assert false report "Illegal test state" severity failure;
      end case;
    end if;
  end process check_results;

  process (clk, rst_n)
  begin  -- process

    if rst_n = '0' then                 -- asynchronous reset (active low)

      req_out      <= '0';
      hold_out     <= '0';
      msg_req_out  <= '0';
      msg_hold_out <= '0';
      comm_out     <= (others => '0');
      addr_out     <= (others => '0');
      data_out     <= (others => '0');
      msg_data_out <= (others => '0');
      msg_addr_out <= (others => '0');
      we_r         <= '0';
      msg_we_r     <= '0';
      rd_port_addr <= (others => '0');
      wr_port_addr <= (others => '0');
      src_addr_r   <= std_logic_vector(to_unsigned(own_addr_g, addr_width_g));
      dst_addr_r   <= std_logic_vector(to_unsigned(own_addr_g, addr_width_g));
      rd_amount_r  <= std_logic_vector(to_unsigned(1, data_width_g));
      wr_amount_r  <= std_logic_vector(to_unsigned(1, data_width_g));
      wr_count_r   <= std_logic_vector(to_unsigned(1, data_width_g));  --(others => '0');
      state_r      <= idle;

      wr_data_r <= std_logic_vector(to_unsigned(own_addr_g, data_width_g));

    elsif clk'event and clk = '1' then  -- rising clock edge

      if chk_state_r = test_finished then
        msg_req_out  <= '0';
        msg_hold_out <= '0';
        req_out      <= '0';
        hold_out     <= '0';
      else

        if chk_state_r = run_test then
          
          case state_r is

            when idle =>
              if full_in = '1' and we_r = '1' then
                state_r <= idle;
              else
                we_r         <= '0';
                req_out      <= '0';
                hold_out     <= '0';
                msg_req_out  <= '0';
                msg_hold_out <= '0';
                state_r      <= single_write;
              end if;

            when single_write =>

              if full_in = '1' and we_r = '1' then
                state_r <= single_write;
              else
                req_out  <= '1';
                hold_out <= '1';
                comm_out <= "010";      -- write
                addr_out <= dst_addr_r;
                data_out <= wr_data_r;

                if grant_in = '1' and full_in = '0' then
                  we_r       <= '1';
                  req_out    <= '0';
                  dst_addr_r <= std_logic_vector(unsigned(dst_addr_r) + 1);
                  wr_data_r  <= std_logic_vector(unsigned(wr_data_r) + 1);
                  state_r    <= single_read;
                else
                  we_r    <= '0';
                  state_r <= single_write;
                end if;
              end if;
            when single_read =>
              if full_in = '1' and we_r = '1' then
                state_r <= single_read;
              else
                req_out  <= '1';
                hold_out <= '1';
                comm_out <= "001";      -- read
                addr_out <= src_addr_r;
                data_out <= std_logic_vector(to_unsigned(own_addr_g, data_width_g));

                if grant_in = '1' and full_in = '0' then
                  we_r       <= '1';
                  req_out    <= '0';
                  src_addr_r <= std_logic_vector(unsigned(src_addr_r) + 1);
                  state_r    <= idle;
                else
                  we_r    <= '0';
                  state_r <= single_read;
                end if;
              end if;
            when others =>
              assert false report "tb_agent_so: 0x" & str(own_addr_g, 16) &
                " illegal state" severity failure;
          end case;

        else
          req_out  <= '0';
          hold_out <= '0';
          we_r     <= '0';
        end if;
      end if;
    end if;
  end process;

end behavioral;
