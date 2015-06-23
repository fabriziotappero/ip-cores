-------------------------------------------------------------------------------
-- Title      : HIBI receiver
-- Project    : UDP2HIBI
-------------------------------------------------------------------------------
-- File       : hibi_receiver.vhd
-- Author     : Jussi Nieminen
-- Last update: 2012-03-22
-- Platform   : 
-------------------------------------------------------------------------------
-- Description: Decides what to do with packets coming from HIBI.
--              Gives parameters to ctrl-registers and data to tx-ctrl.
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2009/12/02  1.0      niemin95        Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.udp2hibi_pkg.all;


entity hibi_receiver is

  generic (
    hibi_comm_width_g : integer := 3;
    hibi_addr_width_g : integer := 32;
    hibi_data_width_g : integer := 32
    );

  port (
    clk              : in  std_logic;
    rst_n            : in  std_logic;
    -- to HIBI
    hibi_comm_in     : in  std_logic_vector( hibi_comm_width_g-1 downto 0 );
    hibi_data_in     : in  std_logic_vector( hibi_data_width_g-1 downto 0 );
    hibi_av_in       : in  std_logic;
    hibi_re_out      : out std_logic;
    hibi_empty_in    : in  std_logic;
    -- to tx multiclk fifo (width 16) (the fifo is really inside tx_ctrl)
    tx_data_out      : out std_logic_vector( udp_block_data_w_c-1 downto 0 );
    tx_we_out        : out std_logic;
    tx_full_in       : in  std_logic;
    -- to tx_ctrl
    new_tx_out       : out std_logic;
    tx_length_out    : out std_logic_vector( tx_len_w_c-1 downto 0 );
    new_tx_ack_in    : in  std_logic;
    timeout_out      : out std_logic_vector( timeout_w_c-1 downto 0 );
    timeout_in       : in  std_logic;
    -- to ctrl_regs
    release_lock_out  : out std_logic;
    new_tx_conf_out   : out std_logic;
    new_rx_conf_out   : out std_logic;
    ip_out            : out std_logic_vector( ip_addr_w_c-1 downto 0 );
    dest_port_out     : out std_logic_vector( udp_port_w_c-1 downto 0 );
    source_port_out   : out std_logic_vector( udp_port_w_c-1 downto 0 );
    lock_addr_out     : out std_logic_vector( hibi_addr_width_g-1 downto 0 );
    response_addr_out : out std_logic_vector( hibi_addr_width_g-1 downto 0 );
    lock_in           : in  std_logic;
    lock_addr_in      : in  std_logic_vector( hibi_addr_width_g-1 downto 0 )
    );

end hibi_receiver;


architecture rtl of hibi_receiver is

  -- store the address data is coming to
  signal current_hibi_addr_r : std_logic_vector( hibi_addr_width_g-1 downto 0 );

  signal hibi_re   : std_logic;
  signal hibi_re_r : std_logic;
  signal tx_we_r   : std_logic;
  signal new_tx_r  : std_logic;
  
  -- state machine to ease up tx configuring
  type conf_state_type is (idle, ip, ports, hibi_addr);
  signal conf_state_r : conf_state_type;

  type conf_type is (tx, rx);
  signal conf_type_r : conf_type;

  -- we must count the amount of data we get
  signal data_cnt_r : integer range 0 to 2**tx_len_w_c-1;
  signal tx_ongoing_r : std_logic;
  signal tx_data_select_r : std_logic;
  signal store_upper_half_r : std_logic;
  
  signal timeout_dump_r : std_logic;
  signal dump_data_r    : std_logic;
  
-------------------------------------------------------------------------------
begin  -- rtl
-------------------------------------------------------------------------------

  -----------------------------------------------------------------------------
  -- connect multiclk fifo's data_in to either upper of lower half of the word
  -- in hibi's data according to store_upper_half_r
  tx_data_mux: process (hibi_data_in, store_upper_half_r)
  begin  -- process tx_data_mux
    if store_upper_half_r = '1' then
      -- upper half
      tx_data_out <= hibi_data_in(31 downto 16);
    else
      -- lower half
      tx_data_out <= hibi_data_in(15 downto 0);
    end if;
  end process tx_data_mux;
  -----------------------------------------------------------------------------
  

  -- the we signal must not be high, if there's nothing or an address coming
  tx_we_out <= tx_we_r and (not hibi_empty_in) and (not hibi_av_in);
  -- the re signal must remain down, if multiclk fifo is full
  hibi_re <= hibi_re_r and ((not tx_full_in) or timeout_dump_r);
  hibi_re_out <= hibi_re;
  new_tx_out <= new_tx_r;
  

  -----------------------------------------------------------------------------
  main : process (clk, rst_n)
    variable hibi_re_v : std_logic;
  begin  -- process main
    if rst_n = '0' then                 -- asynchronous reset (active low)

      conf_state_r <= idle;
      conf_type_r <= tx;
      
      hibi_re_r        <= '0';
      current_hibi_addr_r <= (others => '0');
      tx_we_r             <= '0';
      new_tx_r            <= '0';
      data_cnt_r          <= 0;
      tx_ongoing_r        <= '0';
      dump_data_r         <= '0';
      timeout_dump_r      <= '0';
      store_upper_half_r    <= '0';

      tx_we_r          <= '0';
      new_tx_r         <= '0';
      tx_length_out    <= (others => '0');
      new_tx_conf_out  <= '0';
      new_rx_conf_out  <= '0';
      ip_out           <= (others => '0');
      dest_port_out    <= (others => '0');
      source_port_out  <= (others => '0');
      lock_addr_out    <= (others => '0');
      response_addr_out <= (others => '0');
      timeout_out      <= (others => '0');
      release_lock_out <= '0';
      

    elsif clk'event and clk = '1' then  -- rising clock edge

      -- default values
      hibi_re_r <= '0';
      tx_we_r      <= '0';
      
      new_tx_conf_out  <= '0';
      new_rx_conf_out  <= '0';
      release_lock_out <= '0';


      if new_tx_r = '1' and new_tx_ack_in = '1' then
        new_tx_r <= '0';
      end if;

      if timeout_in = '1' and
        tx_ongoing_r = '1' and
        current_hibi_addr_r = lock_addr_in
      then
        -- dump data that is waiting and clear tx_ongoing_r
        timeout_dump_r  <= '1';
        tx_ongoing_r <= '0';
      end if;
      

      -------------------------------------------------------------------------
      -- if there is data incoming, and we already have written half the
      -- current word to the multiclk fifo, now we write the other half
      if store_upper_half_r = '1' then
        -- this means, that we are writing the upper half of current data word

        tx_we_r <= '1';
        
        if tx_full_in = '0' then
          store_upper_half_r <= '0';
          -- if we have one halfword left, we can read out the final data next
          -- cycle already
          if data_cnt_r = 1 then
            hibi_re_r <= '1';
          else
            hibi_re_r <= '0';
          end if;
          
        else
          -- keep hibi_re_r up (full signal will keep the final re to hibi
          -- down), so that the data is read out right after full comes down
          hibi_re_r <= '1';
        end if;
      -------------------------------------------------------------------------


      -------------------------------------------------------------------------
      elsif hibi_empty_in = '0' then

        -- read, unless we are reading first half of data (that is decided later)
        hibi_re_v := '1';

        -- if address valid, store it
        if hibi_av_in = '1' then

          if hibi_re_r = '1' then
            current_hibi_addr_r <= hibi_data_in;
            dump_data_r <= '0';
            -- don't read next data yet, if data coming
            if lock_in = '1' and hibi_data_in = lock_addr_in and tx_ongoing_r = '1' then
              hibi_re_v := '0';
            end if;
          end if;
        
        else

          ---------------------------------------------------------------------
          if timeout_dump_r = '1' and lock_in = '0' and
            current_hibi_addr_r = lock_addr_in and hibi_re = '1'
          then
            -- Timeout has happened, no new tx_confs, and there's still data coming.
            -- (This might be due to some ethernet problems.)
            -- Dump data.
            if data_cnt_r <= 2 then
              data_cnt_r <= 0;
              timeout_dump_r <= '0';
            else
              data_cnt_r <= data_cnt_r - 2;
            end if;
            
            
          -- not dumping
          elsif dump_data_r = '0'
          then

            -------------------------------------------------------------------
            -- if we are receiving data to locked address
            if lock_in = '1' and current_hibi_addr_r = lock_addr_in and tx_ongoing_r = '1' then


              if tx_we_r = '1' and tx_full_in = '0' then
                -- we are currently writing the lower half, so move on to write
                -- the upper if necessary
                
                if data_cnt_r = 2 then
                
                  -- last two 16-bit words
                  store_upper_half_r <= '1';
                  tx_ongoing_r <= '0';
                  tx_we_r <= '1';
                  data_cnt_r <= 0;

                elsif data_cnt_r = 1 then
                  -- one halfword left, read it out right away, don't store other
                  -- half
                  tx_ongoing_r <= '0';
                  data_cnt_r <= 0;
                
                else
                  -- more data left, just write as usual
                  store_upper_half_r <= '1';

                  -- don't read yet, because we still need to write the upper
                  -- half too
                  data_cnt_r <= data_cnt_r - 2;
                  tx_we_r <= '1';
                end if;

              else

                -- if we is not up, or full is up, lift/keep we up and wait for a cycle
                hibi_re_v := '0';
                tx_we_r <= '1';        
              end if;
              

              
            -------------------------------------------------------------------
            -- if we are in the middle of receiving a conf word
            elsif conf_state_r /= idle and hibi_re = '1' then

              case conf_state_r is
                when ip =>
                  ip_out <= hibi_data_in;
                  conf_state_r <= ports;
                when ports =>
                  dest_port_out <= hibi_data_in( 31 downto 16 );
                  source_port_out <= hibi_data_in( 15 downto 0 );
                  conf_state_r <= hibi_addr;
                when hibi_addr =>
                  response_addr_out <= hibi_data_in;
                  lock_addr_out <= current_hibi_addr_r;
                  
                  if conf_type_r = tx then
                    new_tx_conf_out <= '1';
                  else
                    new_rx_conf_out <= '1';
                  end if;
                  
                  conf_state_r <= idle;
                when others => null;
              end case;

              
            -------------------------------------------------------------------
            -- when receiving conf words we can wait until re is up before
            -- doing anything. With data we cant, because tx fifo's write
            -- enable must be up in time.
            elsif hibi_data_in( id_hi_idx_c downto id_lo_idx_c ) = tx_conf_header_id_c
              and hibi_re = '1'
            then
              -- tx conf packet received
              conf_type_r <= tx;
              conf_state_r <= ip;
              timeout_out <= hibi_data_in( timeout_w_c-1 downto 0 );

            -------------------------------------------------------------------
            elsif hibi_data_in( id_hi_idx_c downto id_lo_idx_c ) = rx_conf_header_id_c
              and hibi_re = '1'
            then
              -- rx conf packet received
              conf_type_r <= rx;
              conf_state_r <= ip;


            -------------------------------------------------------------------  
            -- if there is a valid tx start word to the correct address
            elsif lock_in = '1' and lock_addr_in = current_hibi_addr_r and
              hibi_data_in( id_hi_idx_c downto id_lo_idx_c ) = tx_data_header_id_c
              and hibi_re = '1'
            then
                
              -- get the length in 16-bit words (first divide with 2, then add
              -- last bit of the original value)
              data_cnt_r <= to_integer( unsigned( hibi_data_in( id_lo_idx_c-1 downto id_lo_idx_c-tx_len_w_c + 1 ) ))
                            + to_integer( unsigned( hibi_data_in( id_lo_idx_c-tx_len_w_c downto id_lo_idx_c-tx_len_w_c ) ));
                
              -- length in bytes to the tx_ctrl
              tx_length_out <= hibi_data_in( id_lo_idx_c-1 downto id_lo_idx_c-tx_len_w_c );
              -- notify the tx_ctrl
              new_tx_r <= '1';
              tx_ongoing_r <= '1';

              -- already lift the we to tx fifo, so that the data gets written in
              -- time
              tx_we_r <= '1';

              -- don't read yet, cause it takes two cycles to store word in halfwords
              hibi_re_v := '0';

              
            -------------------------------------------------------------------
            -- if there is a release word
            elsif lock_in = '1' and lock_addr_in = current_hibi_addr_r and
              hibi_data_in( id_hi_idx_c downto id_lo_idx_c ) = tx_release_header_id_c
              and hibi_re = '1'
            then
              release_lock_out <= '1';


            -------------------------------------------------------------------
            elsif hibi_re = '1' then
              -- what the heck, invalid header, dump the data (that is, do nothing)
              report "Invalid header" severity warning;
              -- all data gets dumped untill next av = '1'
              dump_data_r <= '1';
            end if;
            
          ---------------------------------------------------------------------
            
          end if;
        end if;

        hibi_re_r <= hibi_re_v;
        
      end if; -- empty from fifo = '0'
    end if;
  end process main;

end rtl;
