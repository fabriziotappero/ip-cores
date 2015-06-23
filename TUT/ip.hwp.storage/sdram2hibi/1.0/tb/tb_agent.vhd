-------------------------------------------------------------------------------
-- Title      : tb_agent
-- Project    : 
-------------------------------------------------------------------------------
-- File       : tb_agent.vhd
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

entity tb_agent is
  
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
    comm_out     : out std_logic_vector(2 downto 0);
    data_out     : out std_logic_vector(data_width_g - 1 downto 0);
    addr_out     : out std_logic_vector(addr_width_g - 1 downto 0);
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
end tb_agent;

architecture behavioral of tb_agent is

  type state_vec_type is (idle,
                          req_write_port, req_read_port,
                          wait_write_port, wait_read_port,
                          conf_write_port, conf_read_port,
                          send_write_data);
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
      msg_re_out   <= '1';
      rd_count_r   <= (others => '0');
      chk_amount_r <= std_logic_vector(to_unsigned(1, data_width_g));
      chk_count_r  <= std_logic_vector(to_unsigned(1, data_width_g));

      chk_state_r <= run_test;

    elsif clk'event and clk = '1' then  -- rising clock edge

      re_out     <= '1';
      msg_re_out <= '1';

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

            if chk_count_r = chk_amount_r then
              assert false report "ag: 0x" & str(own_addr_g, 16) &
                " read OK (length=" & str(to_integer(unsigned(chk_amount_r)), 16) & ")"
                severity note;
              chk_amount_r <= std_logic_vector(unsigned(chk_amount_r) + 1);
              chk_count_r  <= std_logic_vector(to_unsigned(1, data_width_g));

              if unsigned(chk_amount_r) >= 255 then
                
                assert unsigned(chk_amount_r) < 255 report "++++++++ ag: 0x" & str(own_addr_g, 16) &
                  " TEST SUCCESFUL ++++++++++++++++++++"
                  severity failure;
                chk_state_r <= test_finished;
              end if;
            else
              chk_amount_r <= chk_amount_r;
              chk_count_r  <= std_logic_vector(unsigned(chk_count_r) + 1);
            end if;

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

  data_out <= wr_data_r;

  update_wr_data : process (clk, rst_n)
  begin  -- process update_wr_count
    if rst_n = '0' then
      wr_data_r <= std_logic_vector(to_unsigned(own_addr_g, data_width_g));  --(others => '0');
    elsif clk = '1' and clk'event then
      if we_r = '1' and full_in = '0' then
        wr_data_r <= std_logic_vector(unsigned(wr_data_r) + 1);
      end if;
    end if;
  end process update_wr_data;

  process (clk, rst_n)
  begin  -- process

    if rst_n = '0' then                 -- asynchronous reset (active low)

      req_out      <= '0';
      hold_out     <= '0';
      msg_req_out  <= '0';
      msg_hold_out <= '0';
      comm_out     <= "010";
      addr_out     <= (others => '0');
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

    elsif clk'event and clk = '1' then  -- rising clock edge

      if chk_state_r = test_finished then
        msg_req_out  <= '0';
        msg_hold_out <= '0';
        req_out      <= '0';
        hold_out     <= '0';
      else
        case state_r is

          when idle =>
            req_out       <= '0';
            hold_out      <= '0';
            msg_req_out   <= '0';
            msg_hold_out  <= '0';
            wr_conf_state <= conf_dst_addr;
            rd_conf_state <= conf_src_addr;
            state_r       <= req_write_port;

          when req_write_port =>
            msg_req_out  <= '1';
            msg_hold_out <= '1';
            msg_addr_out <= std_logic_vector(to_unsigned(1, addr_width_g));
            msg_data_out <= std_logic_vector(to_unsigned(own_addr_g, data_width_g));
            if msg_grant_in = '1' and msg_full_in = '0' then
              msg_we_r <= '1';
              state_r  <= wait_write_port;
            else
              msg_we_r <= '0';
              state_r  <= req_write_port;
            end if;
            
          when wait_write_port =>

            if msg_we_r = '1' and msg_full_in = '1' then
              state_r <= wait_write_port;
            else
              msg_we_r     <= '0';
              msg_req_out  <= '0';
              msg_hold_out <= '0';
              msg_addr_out <= (others => '0');
              msg_data_out <= (others => '0');

              if msg_empty_in = '0'
                and msg_data_in = std_logic_vector(to_unsigned(0, data_width_g)) then
                state_r <= req_write_port;

              elsif msg_empty_in = '0'
                and msg_data_in /= std_logic_vector(to_unsigned(0, data_width_g)) then
                wr_port_addr <= msg_data_in;
                state_r      <= conf_write_port;
              else
                wr_port_addr <= (others => '0');
                state_r      <= wait_write_port;
              end if;
              
            end if;

          when conf_write_port =>

            msg_req_out  <= '1';
            msg_hold_out <= '1';

            if msg_grant_in = '1' and msg_full_in = '0' then

              if msg_we_r = '1' and msg_full_in = '1' then
                wr_conf_state <= wr_conf_state;
                state_r       <= state_r;

              else

                msg_we_r <= '1';

                case wr_conf_state is
                  
                  when conf_dst_addr =>
                    msg_addr_out <= wr_port_addr;
                    msg_data_out <= dst_addr_r;
                    dst_addr_r <= std_logic_vector(unsigned(dst_addr_r) +
                                                   unsigned(wr_amount_r));
                    wr_conf_state <= conf_amount;

                  when conf_amount =>
                    msg_addr_out  <= std_logic_vector(unsigned(wr_port_addr) + 1);
                    msg_data_out  <= wr_amount_r;
                    wr_conf_state <= conf_height_offset;
                    
                  when conf_height_offset =>
                    msg_req_out  <= '1';
                    msg_hold_out <= '1';
                    msg_we_r     <= '1';
                    msg_addr_out <= std_logic_vector(unsigned(wr_port_addr) + 2);
                    msg_data_out <= std_logic_vector(to_unsigned(1, data_width_g/2)) &
                                    std_logic_vector(to_unsigned(1, data_width_g/2));
                    wr_conf_state <= conf_dst_addr;
                    state_r       <= send_write_data;

                  when others =>
                    assert false report "tb_agent: 0x" & str(own_addr_g, 16) &
                      " illegal rd_conf_state" severity failure;
                end case;

              end if;

            end if;

          when send_write_data =>

            if msg_we_r = '1' and msg_full_in = '1' then
              state_r <= send_write_data;
            else
              msg_we_r     <= '0';
              msg_req_out  <= '0';
              msg_hold_out <= '0';

              req_out  <= '1';
              hold_out <= '1';

              addr_out <= std_logic_vector(unsigned(wr_port_addr) + 3);
              we_r     <= '1';

              if grant_in = '1' and full_in = '0' then
                if wr_count_r = std_logic_vector(unsigned(wr_amount_r)) then
                  req_out    <= '0';
                  hold_out   <= '0';
                  we_r       <= '0';
                  wr_count_r <= std_logic_vector(to_unsigned(1, data_width_g));  --(others => '0');

                  if to_integer(unsigned(wr_amount_r)) = 255 then
                    wr_amount_r <= std_logic_vector(to_unsigned(1, data_width_g));
                  else
                    wr_amount_r <= std_logic_vector(unsigned(wr_amount_r) + 1);
                  end if;
                  state_r <= req_read_port;
                else
                  wr_count_r <= std_logic_vector(unsigned(wr_count_r) + 1);
                  state_r    <= send_write_data;
                end if;
              end if;
              
            end if;

          when req_read_port =>
            req_out      <= '0';
            hold_out     <= '0';
            we_r         <= '0';
            msg_req_out  <= '1';
            msg_hold_out <= '1';
            msg_addr_out <= (others => '0');
            msg_data_out <= std_logic_vector(to_unsigned(own_addr_g, data_width_g));
            if msg_grant_in = '1' and msg_full_in = '0' then
              msg_we_r <= '1';
              state_r  <= wait_read_port;
            else
              msg_we_r <= '0';
              state_r  <= req_read_port;
            end if;
            

          when wait_read_port =>
            msg_we_r     <= '0';
            msg_req_out  <= '0';
            msg_hold_out <= '0';
            msg_addr_out <= (others => '0');
            msg_data_out <= (others => '0');

            if msg_empty_in = '0'
              and msg_data_in = std_logic_vector(to_unsigned(0, data_width_g)) then
              state_r <= req_read_port;
            elsif msg_empty_in = '0'
              and msg_data_in /= std_logic_vector(to_unsigned(0, data_width_g)) then
              rd_port_addr <= msg_data_in;
              state_r      <= conf_read_port;
            else
              rd_port_addr <= (others => '0');
              state_r      <= wait_read_port;
            end if;

          when conf_read_port =>

            if msg_we_r = '1' then

              -- this is here to allow other agents get grants and use
              -- msg fifo during configuring
              msg_req_out  <= '0';
              msg_hold_out <= '0';
              msg_we_r     <= '0';
            else

              msg_req_out  <= '1';
              msg_hold_out <= '1';

              if msg_grant_in = '1' and msg_full_in = '0' then

                msg_we_r <= '1';

                case rd_conf_state is
                  
                  when conf_src_addr =>
                    msg_addr_out <= rd_port_addr;
                    msg_data_out <= src_addr_r;
                    src_addr_r <= std_logic_vector(unsigned(src_addr_r) +
                                                   unsigned(rd_amount_r));
                    rd_conf_state <= conf_amount;

                  when conf_amount =>
                    msg_addr_out <= std_logic_vector(unsigned(rd_port_addr) + 1);
                    msg_data_out <= rd_amount_r;
                    if to_integer(unsigned(rd_amount_r)) = 255 then
                      rd_amount_r <= std_logic_vector(to_unsigned(1, data_width_g));
                    else
                      rd_amount_r <= std_logic_vector(unsigned(rd_amount_r) + 1);
                    end if;
                    rd_conf_state <= conf_ret_addr;
                    
                  when conf_ret_addr =>
                    msg_addr_out  <= std_logic_vector(unsigned(rd_port_addr) + 3);
                    msg_data_out  <= std_logic_vector(to_unsigned(own_addr_g, data_width_g));
                    rd_conf_state <= conf_height_offset;
                    
                  when conf_height_offset =>
                    msg_addr_out <= std_logic_vector(unsigned(rd_port_addr) + 2);
                    msg_data_out <= std_logic_vector(to_unsigned(1, data_width_g/2)) &
                                    std_logic_vector(to_unsigned(1, data_width_g/2));
                    rd_conf_state <= conf_src_addr;
                    state_r       <= req_write_port;

                  when others =>
                    assert false report "tb_agent: 0x" & str(own_addr_g, 16) &
                      " illegal rd_conf_state" severity failure;
                end case;
              else
                msg_we_r <= '0';
              end if;
            end if;

          when others =>
            assert false report "tb_agent: 0x" & str(own_addr_g, 16) &
              " illegal state" severity failure;
        end case;
        
      end if;
    end if;
  end process;

end behavioral;
