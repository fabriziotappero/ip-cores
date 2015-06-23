-----------------------------------------------------------------
-- file         : io_block.vhd
-- Description  : Includes in and out fifos and controller
--             
-- Designer     : Vesa Lahtinen 6.11.2003
--
-- Last modified 30.8.2006 added hold signal from io_ctrl
--
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Copyright (c) 2011 Tampere University of Technology
-------------------------------------------------------------------------------
--  This file is part of Transaction Generator.
--
--  Transaction Generator is free software: you can redistribute it and/or
--  modify it under the terms of the Lesser GNU General Public License as
--  published by the Free Software Foundation, either version 3 of the License,
--  or (at your option) any later version.
--
--  Transaction Generator is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  Lesser GNU General Public License for more details.
--
--  You should have received a copy of the Lesser GNU General Public License
--  along with Transaction Generator.  If not, see
--  <http://www.gnu.org/licenses/>.
-------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity io_block is
  generic (
    data_width_g    :    integer;
    fifo_depth_g    :    integer;
    addr_width_g    :    integer;
    pkt_switch_en_g :    integer := 0;  --14.10.06 es
    stfwd_en_g      :    integer := 0;  --14.10.06 es
    max_send_g      :    integer := 9;  -- 0=no limit
    net_freq_g      :    integer := 1;
    sim_dbg_en_g    :    integer := 0;
    ip_freq_g       :    integer := 1
    );
  port (
    clk_net         : in std_logic;
    clk_ip          : in std_logic;
    rst_n           : in std_logic;

    -- Signals from agent
    ip_av_in        : in  std_logic; 
    ip_data_in      : in  std_logic_vector (data_width_g-1 downto 0);
    ip_we_in        : in  std_logic;
    ip_tx_full_out  : out std_logic;
    ip_tx_empty_out : out std_logic;

    -- Signals to bus and arbiter
    -- Flit-out contains either addr or data
    net_av_out   : out std_logic;
    net_flit_out : out std_logic_vector (data_width_g-1 downto 0);
    net_we_out   : out std_logic;

    net_req_addr_out : out std_logic_vector (addr_width_g - 1 downto 0);
    net_req_out      : out std_logic;
    net_hold_out     : out std_logic;
    net_grant_in     : in  std_logic;
    net_full_in      : in  std_logic;

    -- Signals from bus and arbiter
    net_av_in     : in  std_logic;
    net_data_in   : in  std_logic_vector (data_width_g-1 downto 0);
    net_we_in     : in  std_logic;
    net_full_out  : out std_logic;
    net_empty_out : out std_logic;

    -- Signals to agent
    ip_av_out       : out std_logic; 
    ip_data_out     : out std_logic_vector (data_width_g-1 downto 0);
    ip_re_in        : in  std_logic;
    ip_rx_full_out  : out std_logic;
    ip_rx_empty_out : out std_logic
    );
end io_block;

architecture structural of io_block is

  component multiclk_fifo
    generic (
      re_freq_g    : integer;
      we_freq_g    : integer;
      depth_g      : integer;
      data_width_g : integer);
    port (
      clk_re    : in  std_logic;
      clk_we    : in  std_logic;
      rst_n     : in  std_logic;
      data_in   : in  std_logic_vector (data_width_g-1 downto 0);
      we_in     : in  std_logic;
      full_out  : out std_logic;
      one_p_out : out std_logic;
      re_in     : in  std_logic;
      data_out  : out std_logic_vector (data_width_g-1 downto 0);
      empty_out : out std_logic;
      one_d_out : out std_logic);
  end component;

  constant rst_val_arr_c : std_logic_vector(1 downto 0) := "Z0";

  constant vittu_saatana : std_logic_vector ( data_width_g-1 downto 0) := (others => '0');
  
  -- Internal signals
  signal tx_flit : std_logic_vector (data_width_g-1 downto 0);
  signal tx_we   : std_logic;

  signal re_to_txf      : std_logic;
  signal empty_from_txf : std_logic;
  signal full_from_txf  : std_logic;


  signal empty_from_rxf         : std_logic;
  signal full_from_rxf          : std_logic;
  signal one_place_left_rx_fifo : std_logic;

  -- From io_ctrl
  signal   we_r           : std_logic;
  --signal   we_ioctrl_xbar : std_logic;
  signal   addr_r         : std_logic_vector(addr_width_g-1 downto 0);


  signal a_d_net_rxf : std_logic_vector ( data_width_g+1 -1 downto 0);
  signal a_d_rxf_ip  : std_logic_vector ( data_width_g+1 -1 downto 0);




  signal a_d_ip_txf   : std_logic_vector (data_width_g+1 -1 downto 0);
  signal a_d_txf_net  : std_logic_vector (data_width_g+1 -1 downto 0);
  signal av_from_txf  : std_logic;
  signal av_ctrl_xbar : std_logic;


  type state_type is (wait_grant, tx_addr, tx_data);
  signal curr_state_r : state_type;
  --signal curr_state_r : integer range 0 to 10;

  constant max_value_for_counter_c : integer :=1024-1;
  signal send_counter_r : integer range 0 to max_value_for_counter_c;

begin

  assert max_send_g < max_value_for_counter_c report "Send_counter is too small for given max_send limit" severity ERROR;
  
  -- From io_ctrl


  out_flit : process (tx_flit, net_grant_in, tx_we)
  begin  -- process out_flit

    if tx_we = '1' then
      if net_grant_in = '1' then
        net_flit_out <= tx_flit;
        net_we_out   <= '1';
      else
        net_flit_out <= (others => rst_val_arr_c(sim_dbg_en_g));
        net_we_out   <= '0';
      end if;

    else
      -- tx-fifo is empty
      net_we_out   <= '0';

      --net_flit_out <= (others => '0');      
      if net_grant_in = '1' then net_flit_out <= (others => rst_val_arr_c(sim_dbg_en_g));
      else net_flit_out                       <= (others => rst_val_arr_c(sim_dbg_en_g));
      end if;
    end if;

  end process out_flit;
  

  av_from_txf     <= a_d_txf_net (data_width_g);
  a_d_ip_txf      <= ip_av_in & ip_data_in;
  ip_tx_empty_out <= empty_from_txf;
  ip_tx_full_out  <= full_from_txf;
  net_av_out      <= av_ctrl_xbar;

  ip_av_out       <= a_d_rxf_ip (data_width_g);
  ip_data_out     <= a_d_rxf_ip (data_width_g-1 downto 0);
  ip_rx_empty_out <= empty_from_rxf;
  ip_rx_full_out  <= full_from_rxf;

  a_d_net_rxf   <= net_av_in & net_data_in;
  net_full_out  <= full_from_rxf;       -- 13.09.2006 ES removed 0ne_p!!
  net_empty_Out <= empty_from_rxf;


  tx_fifo : multiclk_fifo
    generic map (
      re_freq_g    => net_freq_g,
      we_freq_g    => ip_freq_g,
      data_width_g => data_width_g +1,
      depth_g      => fifo_depth_g
      -- depth=1 does not work 15.09.2006
      )
    port map (
      clk_re    => clk_net,
      clk_we    => clk_ip,
      rst_n     => rst_n,
      
      data_in   => a_d_ip_txf, --ip_data_in,
      we_in     => ip_we_in,
      full_out  => full_from_txf,
      
      data_Out  => a_d_txf_net,
      empty_out => empty_from_txf,
      re_in     => re_to_txf
      );



  rx_fifo : multiclk_fifo
    generic map (
      re_freq_g    => ip_freq_g,
      we_freq_g    => net_freq_g,
      data_width_g => data_width_g +1,
      depth_g      => fifo_depth_g
      -- All depths (dep=1 or greater) should work 15.09.2006
      )
    port map (
      clk_re       => clk_ip,
      clk_we       => clk_net,
      rst_n        => rst_n,

      data_in      => a_d_net_rxf,      --net_data_in(data_width_g-1 downto 0),
      we_in        => net_we_in,
      full_out     => full_from_rxf,
      one_p_out    => one_place_left_rx_fifo,
      
      data_out     => a_d_rxf_ip,       --ip_data_out
      empty_out    => empty_from_rxf,
      re_in        => ip_re_in
      );


  main_fsm : process (clk_net, rst_n)
  begin  -- process main_fsm
    if rst_n = '0' then                 -- asynchronous reset (active low)
      we_r           <= '0';
      curr_state_r   <= wait_grant;     --0;
      send_counter_r <= 0;

      addr_r <= (others => rst_val_arr_c(sim_dbg_en_g));

    elsif clk_net'event and clk_net = '1' then  -- rising clock edge

      case curr_state_r is
        when wait_grant =>              --0 => 
          -- Nothing to do
          we_r           <= '0';
          send_counter_r <= 0;

          -- Req is asserted in another process,
          -- wait for grant here
          if net_grant_in = '1' then
            curr_state_r <= tx_addr; --3;
            we_r         <= '1';

          end if;

        -- -- States 1+2 removed


        when tx_addr =>                 --3 =>   
          -- Transfer address
          curr_state_r   <= tx_data;    --4;
          send_counter_r <= 1;

        when tx_data =>  --4 =>   
          -- Transfer data
          we_r <= '1';

          -- No_pkts: Send as long as data available
          --    or when send_limit reached
          -- Pkt: send pkt_amount (=max_send)
          -- Both:stop at new addr
            
            if (empty_from_txf = '0' and av_from_txf = '1')
              or (send_counter_r = max_send_g)  --14.10.06 es
              or (empty_from_txf = '1' and pkt_switch_en_g = 0)
            then
              curr_state_r   <= wait_grant;  --0;
              send_counter_r <= 0;
            else
              curr_state_r   <= tx_data;     --3;

              if tx_we = '1' then
                send_counter_r <= send_counter_r +1;  
              end if;
            end if;

        when others =>
          null;
      end case;


      -- this code replaces req_addr_storage
      if (av_from_txf = '1' and empty_from_txf = '0')
       then
          addr_r <= a_d_txf_net (data_width_g-1 downto 0); --tx_flit(addr_width_g - 1 downto 0);
      else
         addr_r  <= addr_r;
      end if;

      
    end if;
  end process main_fsm;

  -- net_req_addr_out <= addr_r;
  --net_req_addr_out <= addr_r when av_from_txf = '0' else a_d_txf_net (data_width_g-1 downto 0);
  net_req_addr_out <=  a_d_txf_net (data_width_g-1 downto 0)when (av_from_txf = '1' and empty_from_txf='0') else addr_r;

  
  set_outputs: process (curr_state_r, av_from_txf,
                        --we_ioctrl_xbar,
                        tx_we, empty_from_txf,
                        we_r,
                        full_from_txf,
                        send_counter_r, 
                        a_d_txf_net, addr_r,
                        net_grant_in, net_full_in)
  begin  -- process set_outputs

    tx_we <= we_r and not(empty_from_txf) and not(net_full_in);
    -- These might be overriden in state4

    tx_flit (data_width_g-1 downto 0) <= a_d_txf_net (data_width_g-1 downto 0);
    re_to_txf                         <= tx_we and net_grant_in;


    -- orig.
    --we_ioctrl_xbar <= we_r and not(empty_from_txf) and not(net_full_in);
    --tx_we          <= we_ioctrl_xbar;
    --re_to_txf      <= we_ioctrl_xbar and net_grant_in;

      case curr_state_r is
        when wait_grant =>  --0 =>
          -- Nothing to do except
          -- asserting the request if data in fifo
          av_ctrl_xbar <= '0';
          --net_hold_out <= not empty_from_txf; --'0';
          --net_req_out  <= not empty_from_txf;

          if pkt_switch_en_g = 1 then
            if stfwd_en_g = 1 then
              -- Store-and-forward
              net_req_out  <= full_from_txf;
              net_hold_out <= full_from_txf;  --'0';  
            else
              -- Cut-through
              net_req_out  <= not empty_from_txf;
              net_hold_out <= not empty_from_txf; --'0';
            end if;

          else
            -- Packets not used           
            net_req_out  <= not empty_from_txf;            
            net_hold_out <= not empty_from_txf; --'0';
          end if;


          
        when tx_addr => -- 3 =>
          -- Transfer address
          av_ctrl_xbar <= '1';
          net_req_out  <= '0';
          net_hold_out <= '1';

          if (empty_from_txf = '0' and av_from_txf = '0')
          then
            -- Take addr from register not from fifo
            -- Overrrides for default assigments
            tx_we                                        <= '1';

            --tx_flit (data_width_g-1 downto addr_width_g) <= (others => '0');
            tx_flit (data_width_g-1 downto  addr_width_g) <= vittu_saatana (data_width_g-1 downto addr_width_g);

            tx_flit (addr_width_g-1 downto 0)            <= addr_r;
            re_to_txf                                    <= '0';
          end if;

        when tx_data =>  --4 =>
          -- Transfer data
          av_ctrl_xbar <= '0';
          net_req_out  <= '0';

          -- New addr or no more data to send => stop and start again with req
          if (empty_from_txf = '0' and av_from_txf = '1')
            or (send_counter_r = max_send_g)  --14.10.06 es
            or (empty_from_txf = '1' and pkt_switch_en_g = 0)
          then
            net_hold_out <= '0';

            -- Overrides for default assigments
            tx_we                             <= '0';
            --tx_flit (data_width_g-1 downto 0) <= (others => '0');  --'Z');
            tx_flit (data_width_g-1 downto 0) <= vittu_saatana (data_width_g-1 downto 0);

            re_to_txf                         <= '0';

          else
            net_hold_out <= '1';              
          end if;
          
        when others =>
          null;

      end case;    
  end process set_outputs;
  
  
  
end structural;
