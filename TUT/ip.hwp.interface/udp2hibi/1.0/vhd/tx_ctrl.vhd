-------------------------------------------------------------------------------
-- Title      : Tx control block
-- Project    : UDP2HIBI
-------------------------------------------------------------------------------
-- File       : tx_ctrl.vhd
-- Author     : Jussi Nieminen  <niemin95@galapagosinkeiju.cs.tut.fi>
-- Last update: 2012-03-23
-- Platform   : 
-------------------------------------------------------------------------------
-- Description: Sub-block of udp2hibi.
--              Takes care of chatting with udp/ip block.
--              This gets data from HIBI receiver and gives it to UDP/IP.
--              Includes multclk-fifo and a state machine.
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2009/12/11  1.0      niemin95        Created
-- 2012-03-23  1.0      ege             Beautifying and commenting.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.udp2hibi_pkg.all;


entity tx_ctrl is

  generic (
    frequency_g           : integer := 50_000_000;
    multiclk_fifo_depth_g : integer := 10
    );

  port (
    clk                 : in  std_logic;
    clk_udp             : in  std_logic;
    rst_n               : in  std_logic;

    -- for multiclk fifo
    tx_data_in          : in  std_logic_vector (udp_block_data_w_c-1 downto 0);
    tx_we_in            : in  std_logic;
    tx_full_out         : out std_logic;

    -- from multiclk fifo to udp/ip
    tx_data_out         : out std_logic_vector (udp_block_data_w_c-1 downto 0);
    tx_data_valid_out   : out std_logic;
    tx_re_in            : in  std_logic;

    -- other signals to udp/ip
    new_tx_out          : out std_logic;
    tx_len_out          : out std_logic_vector (tx_len_w_c-1 downto 0);
    dest_ip_out         : out std_logic_vector (ip_addr_w_c-1 downto 0);
    dest_port_out       : out std_logic_vector (udp_port_w_c-1 downto 0);
    source_port_out     : out std_logic_vector (udp_port_w_c-1 downto 0);

    -- signals to and from hibi_receiver
    new_tx_in           : in  std_logic;
    tx_len_in           : in  std_logic_vector (tx_len_w_c-1 downto 0);
    new_tx_ack_out      : out std_logic;
    timeout_in          : in  std_logic_vector (timeout_w_c-1 downto 0);
    timeout_to_hr_out   : out std_logic;

    -- signals to and from ctrl regs
    tx_ip_in            : in  std_logic_vector (ip_addr_w_c-1 downto 0);
    tx_dest_port_in     : in  std_logic_vector (udp_port_w_c-1 downto 0);
    tx_source_port_in   : in  std_logic_vector (udp_port_w_c-1 downto 0);
    timeout_release_out : out std_logic
    );

end tx_ctrl;


architecture rtl of tx_ctrl is

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


  signal  new_tx_r        : std_logic;
  signal  tx_cnt_r        : integer range 0 to 2**(tx_len_w_c-1);
  subtype timeout_int is integer range 0 to 2**timeout_w_c-1;
  signal  timeout_cnt_r   : timeout_int;
  signal  timeout_value_r : timeout_int;

  signal tx_data_to_fifo      : std_logic_vector(udp_block_data_w_c-1 downto 0);
  signal tx_we_to_fifo        : std_logic;
  signal tx_full_from_fifo    : std_logic;
  signal full_to_h_receiver_r : std_logic;
  signal gain_tx_control_r    : std_logic;
  signal tx_we_local_r        : std_logic;
  signal empty_from_fifo      : std_logic;
  signal udp_ip_re_old_r      : std_logic;
  signal new_tx_ack_r         : std_logic;

  -- states:
  -- idle: as one might guess..
  -- tx: count writes to fifo, and reset timeout_cnt every time data is written
  -- dump: timeout, dump fake data to fifo until tx_len of data is written
  type   state_type is (idle, tx, dump);
  signal state_r : state_type;

-------------------------------------------------------------------------------
begin  -- rtl
-------------------------------------------------------------------------------

  tx_multiclk_fifo : multiclk_fifo
    generic map (
      re_freq_g    => udp_block_freq_c,
      we_freq_g    => frequency_g,
      depth_g      => multiclk_fifo_depth_g,
      data_width_g => udp_block_data_w_c
      )
    port map (
      clk_re    => clk_udp,
      clk_we    => clk,
      rst_n     => rst_n,

      data_in   => tx_data_to_fifo,
      we_in     => tx_we_to_fifo,
      full_out  => tx_full_from_fifo,
      one_p_out => open,
      
      re_in     => tx_re_in,
      data_out  => tx_data_out,
      empty_out => empty_from_fifo,
      one_d_out => open
      );

  tx_data_valid_out <= not empty_from_fifo;

  -- Inputs from ctrl-regs go directly to hibi
  dest_ip_out     <= tx_ip_in;
  dest_port_out   <= tx_dest_port_in;
  source_port_out <= tx_source_port_in;
  new_tx_out      <= new_tx_r;

  tx_full_out <= tx_full_from_fifo or full_to_h_receiver_r;


  -----------------------------------------------------------------------------
  -- in case of a timeout, this block has to take care of finishing the tx
  -- (with fake data ofcourse)
  -----------------------------------------------------------------------------
  tx_fifo_mux : process (gain_tx_control_r, tx_we_local_r, tx_we_in, tx_data_in)
  begin  -- process tx_fifo_mux
    if gain_tx_control_r = '1' then
      -- timeout has occured, write zeroes to fifo
      tx_data_to_fifo <= (others => '0');
      tx_we_to_fifo   <= tx_we_local_r;
    else
      -- situation normal, nothing fouled up...
      tx_data_to_fifo <= tx_data_in;
      tx_we_to_fifo   <= tx_we_in;
    end if;
  end process tx_fifo_mux;

  new_tx_ack_out <= new_tx_ack_r;

  -----------------------------------------------------------------------------
  --
  -----------------------------------------------------------------------------
  main : process (clk, rst_n)
    variable sub_from_len_v : integer range 0 to 1;
  begin  -- process main
    if rst_n = '0' then                 -- asynchronous reset (active low)

      tx_cnt_r        <= 0;
      timeout_cnt_r   <= 0;
      timeout_value_r <= 0;
      state_r         <= idle;

      full_to_h_receiver_r <= '0';
      gain_tx_control_r    <= '0';
      tx_we_local_r        <= '0';
      udp_ip_re_old_r      <= '0';

      timeout_release_out <= '0';
      timeout_to_hr_out   <= '0';
      new_tx_r            <= '0';
      tx_len_out          <= (others => '0');
      new_tx_ack_r        <= '0';
      
    elsif clk'event and clk = '1' then  -- rising clock edge

      udp_ip_re_old_r <= tx_re_in;

      -- default values
      new_tx_ack_r        <= '0';
      timeout_release_out <= '0';
      timeout_to_hr_out   <= '0';
      tx_we_local_r       <= '0';

      -- We don't know in which state we are when udp/ip starts to read, so
      -- clear new_tx here
      if new_tx_r = '1' and tx_re_in = '1' and udp_ip_re_old_r = '0' then
        -- Rising edge of re, clear new_tx
        new_tx_r <= '0';
      end if;

      case state_r is
        
        -----------------------------------------------------------------------
        when idle =>

          if new_tx_in = '1' and new_tx_ack_r = '0' then
            new_tx_ack_r <= '1';

            -- store length (in halfwords) and timeout
            sub_from_len_v := 0;
            if tx_we_in = '1' and tx_full_from_fifo = '0' then
              -- if new_tx comes parallel with the first write operation, we
              -- must subtrackt one from the tx_cnt
              sub_from_len_v := 1;
            end if;
            tx_cnt_r <= to_integer(unsigned(tx_len_in(tx_len_w_c-1 downto 1)))
                        + to_integer(unsigned(tx_len_in(0 downto 0)))
                        - sub_from_len_v;
            timeout_value_r <= to_integer(unsigned(timeout_in));
            timeout_cnt_r   <= 0;

            if to_integer(unsigned(tx_len_in)) > 2 or sub_from_len_v = 0 then
              -- no need to get into tx state if tx_len is 1 and the data is already
              -- written (in fact going to tx state would result in malfunction)
              state_r <= tx;
            end if;

            new_tx_r   <= '1';
            tx_len_out <= tx_len_in;
          end if;


          -----------------------------------------------------------------------
        when tx =>

          if tx_we_in = '1' and tx_full_from_fifo = '0' then

            -- reset timeout counter
            timeout_cnt_r <= 0;

            if tx_cnt_r = 1 then
              -- last data written
              state_r  <= idle;
              tx_cnt_r <= 0;
            else
              tx_cnt_r <= tx_cnt_r - 1;
            end if;

          elsif timeout_cnt_r = timeout_value_r then

            -- timeout! Fill fifo with fake data, and inform ctrl regs
            state_r              <= dump;
            timeout_release_out  <= '1';
            timeout_to_hr_out    <= '1';
            -- take control over the data line
            gain_tx_control_r    <= '1';
            full_to_h_receiver_r <= '1';
            timeout_cnt_r        <= 0;

          else
            -- increase timeout counter
            timeout_cnt_r <= timeout_cnt_r + 1;
          end if;


          -----------------------------------------------------------------------
        when dump =>

          if tx_full_from_fifo = '0' then

            -- write them zeroes
            tx_we_local_r <= '1';

            if tx_we_local_r = '1' then
              
              if tx_cnt_r = 1 then
                -- last data
                state_r  <= idle;
                tx_cnt_r <= 0;

                -- give fifo back to hibi_receiver
                gain_tx_control_r    <= '0';
                full_to_h_receiver_r <= '0';
                
              else
                tx_cnt_r <= tx_cnt_r - 1;
              end if;
            end if;
          end if;
          
        when others => null;
      end case;
      
    end if;
  end process main;
  

end rtl;
