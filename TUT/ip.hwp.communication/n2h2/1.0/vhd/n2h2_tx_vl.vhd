-------------------------------------------------------------------------------
-- Title      : N2H2 TX with variable latency support
-- Project    : 
-------------------------------------------------------------------------------
-- File       : n2h2_tx.vhd
-- Author     : kulmala3
-- Created    : 30.03.2005
-- Last update: 2011-02-02
-- Description: Bufferless transmitter for N2H2. new version to be used
-- with memories of all latencies.
--
-- REQUIRES:
-- step_counter2.vhd 
-------------------------------------------------------------------------------
-- Copyright (c) 2005 
-- New version of TX. uses step_counter2.vhd, supports streaming.
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 30.03.2005  1.0      AK      Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity n2h2_tx is

  generic (
    -- legal values because of SOPC Builder £@££@ crap.
    data_width_g   : integer := 32;
    addr_width_g   : integer := 32;
    amount_width_g : integer := 16);

  port (
    clk                     : in  std_logic;
    rst_n                   : in  std_logic;
    -- Avalon master read interface
    avalon_addr_out         : out std_logic_vector(addr_width_g-1 downto 0);
    avalon_re_out           : out std_logic;
    avalon_readdata_in      : in  std_logic_vector(data_width_g-1 downto 0);
    avalon_waitrequest_in   : in  std_logic;
    avalon_readdatavalid_in : in  std_logic;

    -- hibi write interface
    hibi_data_out           : out std_logic_vector(data_width_g-1 downto 0);
    hibi_av_out             : out std_logic;
    hibi_full_in            : in  std_logic;
    hibi_comm_out           : out std_logic_vector(4 downto 0);
    hibi_we_out             : out std_logic;

    -- DMA conf interface
    tx_start_in             : in  std_logic;
    tx_status_done_out      : out std_logic;
    tx_comm_in              : in  std_logic_vector(4 downto 0);
    tx_hibi_addr_in         : in  std_logic_vector(addr_width_g-1 downto 0);
    tx_ram_addr_in          : in  std_logic_vector(addr_width_g-1 downto 0);
    tx_amount_in            : in  std_logic_vector(amount_width_g-1 downto 0)
    );

end n2h2_tx;

architecture rtl of n2h2_tx is

  type control_states is (idle, transmit_addr, transmit, hfull);
  signal   control_r     : control_states;
  constant addr_offset_c : integer := data_width_g/8;

  component step_counter2
    generic (
      step_size_g :     integer;
      width_g     :     integer
      );
    port (
      clk         : in  std_logic;
      rst_n       : in  std_logic;
      en_in       : in  std_logic;
      value_in    : in  std_logic_vector(width_g-1 downto 0);
      load_in     : in  std_logic;
      value_out   : out std_logic_vector(width_g-1 downto 0));
  end component;

  signal addr_cnt_en_r      : std_logic;
  signal addr_cnt_value_r   : std_logic_vector(addr_width_g-1 downto 0);
  signal addr_cnt_load_r    : std_logic;
  signal addr_r             : std_logic_vector(addr_width_g-1 downto 0);
  signal amount_cnt_en_r    : std_logic;
  signal amount_cnt_value_r : std_logic_vector(addr_width_g-1 downto 0);
  signal amount_cnt_load_r  : std_logic;
  signal amount_r           : std_logic_vector(addr_width_g-1 downto 0);

  signal addr_amount_eq : std_logic;

  signal addr_to_stop_r : std_logic_vector(addr_width_g-1 downto 0);
  signal avalon_re_r    : std_logic;
  signal start_re_r     : std_logic;

  signal hibi_write_addr_r : std_logic;
  signal data_src_sel      : std_logic;
  signal hibi_we_r         : std_logic;
  signal hibi_stop_we_r    : std_logic;


begin  -- rtl

  -----------------------------------------------------------------------------
  -- 1) waitrequest affects the data reading
  -- 2) readdatavalid data write to hibi
  -- 3) avalon side read must control the amount of data
  -- 4) whenever readdatavalid is asserted, data is written to HIBI
  -- 5) HIBI full is problematic. A counter must be added to see from which
  --    address we have succesfully read the data so far. We cannot
  --    save the data to register, because we are unaware of the latency.
  --    So when full comes, the read process from avalon must be started
  --    again.
  -- 6) write and read signals should be asynchronously controlled by
  --    signals from hibi and avalon in order to react as fast as possible.
  -- 7) after full the write should be ceased. readdatavalid from older data
  --    should be taken care of. Write continues only after read enable has
  --    been asserted again?
  -- 8) read from avalon must proceed as fast as possible. for example,
  --    start already when writing address to hibi. (at least one clock
  --    cycle latency expected, should be safe). Or after full.
  -- 9) data to hibi comes from either register input (address) or
  --    straight from the memory. mux is needed.
  -----------------------------------------------------------------------------

  hibi_comm_out   <= tx_comm_in;
  -- minus here and and addition in first store? could reduce the
  -- cricital path...
  avalon_addr_out <= addr_r;

  addr_counter2_1 : step_counter2
    generic map (
      step_size_g => addr_offset_c,
      width_g     => addr_width_g)
    port map (
      clk         => clk,
      rst_n       => rst_n,
      en_in       => addr_cnt_en_r,
      value_in    => addr_cnt_value_r,
      load_in     => addr_cnt_load_r,
      value_out   => addr_r
      );

  addr_cnt_load_r      <= (tx_start_in or hibi_full_in);
  addr_cnt : process (tx_ram_addr_in, amount_r, tx_start_in)
  begin  -- process addr_cnt
    if tx_start_in = '1' then
      -- addr from input
      addr_cnt_value_r <= tx_ram_addr_in;
    else
      -- addr from counter
      addr_cnt_value_r <= amount_r;
    end if;
  end process addr_cnt;



  amount_counter2_1 : step_counter2
    generic map (
      step_size_g => addr_offset_c,
      width_g     => addr_width_g)
    port map (
      clk         => clk,
      rst_n       => rst_n,
      en_in       => amount_cnt_en_r,
      value_in    => amount_cnt_value_r,
      load_in     => amount_cnt_load_r,
      value_out   => amount_r
      );
-- amount counted only when data is written
  amount_cnt_en_r <= hibi_we_r and (not data_src_sel);
  -- hibi_we depends on readdatavalid and full + control signal for
  -- address writing
  -- start address writing right when the signal comes in.
  -- no old readdatavalids should be written if full is short.
  hibi_we_out     <= hibi_we_r;
  hibi_we_r       <= ((data_src_sel) or (avalon_readdatavalid_in and (not hibi_stop_we_r)))
                     and (not hibi_full_in);

  data_src_sel <= tx_start_in or hibi_write_addr_r;
  hibi_av_out  <= data_src_sel;

  addr_data : process (tx_hibi_addr_in, avalon_readdata_in, data_src_sel)
  begin  -- process addr_data
    if data_src_sel = '1' then
      hibi_data_out <= (others => '0');
      hibi_data_out(addr_width_g-1 downto 0) <= tx_hibi_addr_in;
    else
      hibi_data_out <= avalon_readdata_in;
    end if;
  end process addr_data;

  -- if we're reading and not forced to wait,
  -- increase the address. we want to cease reading if hibi goes full
  -- (reload address)
  addr_cnt_en_r <= (avalon_re_r and (not avalon_waitrequest_in)) and
                   (not hibi_full_in);
  avalon_re_out <= avalon_re_r;
  -- read enable depends on the amount transferred, if a 
  -- transmission is ongoing. shoot as soon as possible,
  -- whenever new transmission is assigned.
-- CHECK OUT THIS ONE! could be used to fasten n2h2 up!
    avalon_re_r   <= start_re_r;-- or (tx_start_in and (not hibi_full_in));

  comparison : process (addr_r, addr_to_stop_r)
  begin  -- process comparison
    -- addr_offset added here, because addr_to_stop process caused two
    -- back-to-back adders, now they should be in parallel
    if addr_r = addr_to_stop_r then
      addr_amount_eq <= '1';
    else
      addr_amount_eq <= '0';
    end if;
  end process comparison;

  addr_to_stop : process (tx_amount_in, tx_ram_addr_in)
  begin  -- process addr_to_stop
    addr_to_stop_r <= tx_ram_addr_in + conv_std_logic_vector(
      conv_integer(tx_amount_in)*addr_offset_c, addr_width_g);
-- conv_integer(tx_amount_in+1)*addr_offset_c, data_width_g);
  end process addr_to_stop;

  amount_cnt_value_r <= tx_ram_addr_in;
  amount_cnt_load_r  <= tx_start_in;

  main : process (clk, rst_n)
  begin  -- process main
    if rst_n = '0' then                 -- asynchronous reset (active low)
      control_r          <= idle;
      start_re_r         <= '0';
      hibi_write_addr_r  <= '0';
      tx_status_done_out <= '1';
      hibi_stop_we_r     <= '0';

    elsif clk'event and clk = '1' then  -- rising clock edge
      case control_r is
        when idle =>
          hibi_write_addr_r  <= '0';
          start_re_r         <= '0';
          tx_status_done_out <= '1';
          hibi_stop_we_r     <= '1';

          if tx_start_in = '1' then
            -- avalon read address
            -- address which contents written to hibi
            tx_status_done_out <= '0';
            hibi_stop_we_r     <= '0';

            if hibi_full_in = '0' then
              -- address will be transferred in this clock cycle
              control_r         <= transmit;
              start_re_r        <= '1';
            else
              hibi_write_addr_r <= '1';
              control_r         <= transmit_addr;
            end if;
          end if;

        when transmit_addr =>
          -- if we're here, hibi was full
          if hibi_full_in = '0' then
            -- we wrote the addr
            start_re_r        <= '1';
            control_r         <= transmit;
            hibi_write_addr_r <= '0';
          else
            start_re_r        <= '0';
            control_r         <= transmit_addr;
            hibi_write_addr_r <= '1';
          end if;

        when transmit =>
          if hibi_full_in = '1' then
            start_re_r     <= '0';
            control_r      <= hfull;
            hibi_stop_we_r <= '1';
          else
            start_re_r     <= '1';
            hibi_stop_we_r <= '0';
            control_r      <= transmit;
          end if;

--          if addr_amount_eq = '1' and hibi_full_in = '0' then
          if addr_amount_eq = '1' and hibi_we_r = '1' then          
            control_r      <= idle;
            -- stopped transferring
            tx_status_done_out <= '1';            
            hibi_stop_we_r <= '1';
          end if;

        when hfull =>
          if hibi_full_in = '0' and avalon_readdatavalid_in = '0' then
            -- datavalid has to go down before proceed.
            -- so we make sure that no invalid data is written
            -- when there's a short full.
            start_re_r     <= '1';
            hibi_stop_we_r <= '0';
            control_r      <= transmit;
          else
            start_re_r     <= '0';
            hibi_stop_we_r <= '1';
            control_r      <= hfull;
          end if;

        when others => null;
      end case;
    end if;
  end process main;

end rtl;
