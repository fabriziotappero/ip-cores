-------------------------------------------------------------------------------
-- Title      : sdram_controller, modified for DE2 by A.Alhonen.
-- Project    : 
-------------------------------------------------------------------------------
-- File       : sdram_controller.vhd
-- Author     : 
-- Company    : 
-- Created    : 2005-06-08
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: Altera DE2 uses A2V64S40TCP SDRAM.
-------------------------------------------------------------------------------
-- Copyright (c) 2005 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2005-06-08  1.0      penttin5        Created
--
-- 2005-07-12  1.1      penttin5        Split command_in port to command_in,
--                                        address_in, data_amount_in and
--                                        byte_select_in.
--                                      Changed behavior
--                                        If output fifo is full in read
--                                        operation or input fifo is empty in
--                                        write operation, stop operation and
--                                        go to idle to have a new command.
--                               AA 2012: Why?! I decided not to fix it here
--                                        because apparently there is some
--                                        reason to this.
--                                      Data_amount_in width is now generic
-- 19.04.2007           penttin5        Added generic sim_ena_g to make
--                                        simulation easier. When sim_ena_g is
--                                        1, the long init wait is skipped
-- 12.08.2009           alhonena        Started modifying for DE2: 16-bit data,
--                                      different timing.
-- 16.07.2011           alhonena        Continued modifying for DE2
-------------------------------------------------------------------------------
--
-- NOTE!!! The following assignments must be used in Quartus to
--         ensure correct operation:
--
--         In Assignment Editor: Logic options
--
-- from    to                     Assignment name              Value Enabled
--         sdram_data_out_r     : fast output register         On    Yes
--         write_on_r           : fast output enable register  On    Yes
--         data_out             : fast input register          On    Yes
--
-- Use node finder to find these nodes.
--
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity sdram_controller is
  generic (
    clk_freq_mhz_g      : integer := 143;  -- clock frequency in MHz
    mem_addr_width_g    : integer := 22;
    amountw_g           : integer := 22;
    block_read_length_g : integer := 640;
    sim_ena_g           : integer := 0  -- skips the init wait phase
    );

  port (
    clk   : in std_logic;
    rst_n : in std_logic;

    command_in             : in    std_logic_vector(1 downto 0);
    address_in             : in    std_logic_vector(mem_addr_width_g-1 downto 0);
    data_amount_in         : in    std_logic_vector(amountw_g - 1
                                                    downto 0);
    byte_select_in         : in    std_logic_vector(1 downto 0);  -- ACTIVE LOW!
    input_empty_in         : in    std_logic;
    input_one_d_in         : in    std_logic;
    output_full_in         : in    std_logic;
    data_in                : in    std_logic_vector(15 downto 0);
    write_on_out           : out   std_logic;
    busy_out               : out   std_logic;
    output_we_out          : out   std_logic;  -- this is combinational
    input_re_out           : out   std_logic;
    data_out               : out   std_logic_vector(15 downto 0);
    sdram_data_inout       : inout std_logic_vector(15 downto 0);
    sdram_cke_out          : out   std_logic;
    sdram_cs_n_out         : out   std_logic;
    sdram_we_n_out         : out   std_logic;
    sdram_ras_n_out        : out   std_logic;
    sdram_cas_n_out        : out   std_logic;
    sdram_dqm_out          : out   std_logic_vector(1 downto 0);
    sdram_ba_out           : out   std_logic_vector(1 downto 0);
    sdram_address_out      : out   std_logic_vector(11 downto 0)
    );

  attribute useioff : boolean;
  attribute useioff of data_out : signal is true;
  attribute useioff of sdram_data_inout : signal is true;

end;

architecture rtl of sdram_controller is

  -- purpose: counts the needed delays in clock cycles from clock frequency
  --          and nanoseconds
  function calculate_cycles (clk_freq_mhz : integer;
                             time_ns      : integer;
                             round        : string)
    return integer is
    variable result_cycles : integer;
  begin  -- calculate_cycles
    assert round = "down" or round = "up"
      report
      "Error in calling function calculate_cycles: unknown rounding parameter!"
      severity failure;
    result_cycles := (clk_freq_mhz * time_ns);
    if result_cycles rem 1000 /= 0 then
      if round = "up" then
        result_cycles := result_cycles + 1000;
      end if;
    end if;
    return result_cycles/1000;
  end calculate_cycles;

  -- purpose: sets correct cas latency according to clock frequency and
  --          checks that clock frequency isn't higher than 143MHz
  function set_cas_latency (
    clk_freq_mhz_g : integer)
    return integer is
    variable cas_result : integer;
  begin  -- set_cas_latency
    if clk_freq_mhz_g <= 50 then
      cas_result := 2;
    elsif clk_freq_mhz_g <= 100 then
      cas_result := 2;
    elsif clk_freq_mhz_g <= 143 then
      cas_result := 3;
    else
      assert false report "Clock frequency too high (>143MHz) for SDRAM"
        severity warning;
    end if;
    return cas_result;
  end set_cas_latency;

  -- ACTIVE to ACTIVE in the same bank
  -- tRC = 63ns
  constant t_rc_c      : integer := calculate_cycles(clk_freq_mhz_g, 63, "up");
  -- ACTIVE to READ/WRITE
  -- tRCD = 21ns
  constant t_rcd_c     : integer := calculate_cycles(clk_freq_mhz_g, 21, "up");
  -- ACTIVE to PRECHARGE
  -- tRAS(min) = 42ns
  constant t_ras_min_c : integer := calculate_cycles(clk_freq_mhz_g, 42, "up");
  -- ACTIVE to PRECHARGE
  -- tRAS(max) = 100 000ns
  constant t_ras_max_c :
    integer := calculate_cycles(clk_freq_mhz_g, 100000, "up") - 2;
  -- Auto refresh period
  -- tRFC = 70ns = tRC
  constant t_rfc_c : integer := calculate_cycles(clk_freq_mhz_g, 70, "up");
  -- Precharge period
  -- tRP = 21ns
  constant t_rp_c :
    integer := calculate_cycles(clk_freq_mhz_g, 21, "up");
  -- ACTIVE to ACTIVE, different banks
  -- tRRD = 14ns
  constant t_rrd_c : integer := calculate_cycles(clk_freq_mhz_g, 14, "up");
  -- Write recovery time -- Tätä ei jostain syystä löydy datalehdestä, jätin ennalleen.
  -- tWR = 14ns wo/autoprecharge = 1clk + 7ns w/autoprecharge
  constant t_wr_c  : integer := calculate_cycles(clk_freq_mhz_g, 14, "up");
  -- CAS latency +1(registered output causes 1 extra cycle latency)
  constant t_cas_c : integer := set_cas_latency(clk_freq_mhz_g) + 1;
  -- LOAD MODE REGISTER command period
  -- tMRD = 2 cycles
  constant t_mrd_c : integer := 2;

  -- Evenly distributed refresh commands
  -- 1 autorefresh cycle per 15,625us = 15625ns
  -- 1 cycle removed to compensate clock uncertainty

  constant refresh_period_c : integer :=
    calculate_cycles(clk_freq_mhz_g, 15625, "down") - 1; --30;

  constant refresh_latency_write_c : integer :=
    t_wr_c + t_rp_c + t_rfc_c + 3;
--    t_ras_min_c + t_rp_c;
  constant refresh_latency_read_c : integer :=
    t_cas_c + t_rp_c + t_rfc_c + 2;
--    t_cas_c + t_ras_min_c + t_rp_c + 2;
  constant refresh_latency_idle_c : integer :=
    t_rcd_c + t_rp_c + t_rfc_c + 8;

  -- after reset 200us = 200000ns of NOPs
  constant init_wait_cycles_c : integer :=
    calculate_cycles(clk_freq_mhz_g, 200000, "up");

  -- commands
  constant command_nop_c   : std_logic_vector(1 downto 0) := "00";
  constant command_read_c  : std_logic_vector(1 downto 0) := "01";
  constant command_write_c : std_logic_vector(1 downto 0) := "10";

  -- SDRAM commands
  constant sdram_nop_c          : std_logic_vector(3 downto 0) := "0111";
  constant sdram_active_c       : std_logic_vector(3 downto 0) := "0011";
  constant sdram_read_c         : std_logic_vector(3 downto 0) := "0101";
  constant sdram_write_c        : std_logic_vector(3 downto 0) := "0100";
  constant sdram_precharge_c    : std_logic_vector(3 downto 0) := "0010";
  constant sdram_auto_refresh_c : std_logic_vector(3 downto 0) := "0001";
  constant sdram_load_mode_c    : std_logic_vector(3 downto 0) := "0000";

  -- SDRAM default mode = burst length 1
  constant default_mode_c : std_logic_vector(11 downto 0) :=
    "00000" & conv_std_logic_vector(t_cas_c - 1, 3) & "0000";
  -- Write Burst Lengthiksi vaihdettu "single bit".
  -- Vaihdettu takas nollaks (= burst). Se on toi keskimmäinen noista viidestä.

  -- SDRAM command register
  signal sdram_command_r : std_logic_vector(3 downto 0);

  -- SDRAM address register
  signal sdram_address_r : std_logic_vector(mem_addr_width_g - 1 downto 0);

  -- registers for operations longer than one word
  signal data_counter_r : std_logic_vector(data_amount_in'length - 1
                                           downto 0);
  signal succesful_reads_r : std_logic_vector(data_amount_in'length - 1
                                              downto 0);

  signal data_amount_r : std_logic_vector(data_amount_in'length - 1
                                          downto 0);

  signal read_on_r   : std_logic;
  signal output_we_r : std_logic;

  -- state machine signals
  type state_vector is (init_wait,
                        init_precharge,
                        init_auto_refresh1,
                        init_auto_refresh2,
                        init_load_mode_register,
                        idle,
                        idle_auto_refresh,

                        start_read,
                        continue_read,
                        read_refresh_precharge,
                        read_refresh,
                        read_refresh_wait,
                        read_finished,
                        read_finished_precharge,

                        start_write,
                        wait_write_active_to_active,
                        continue_write,
                        write_refresh_precharge,
                        write_refresh,
                        write_refresh_wait,
                        write_change_row_precharge,
                        write_finished,
                        write_finished_precharge
                        );

  signal current_state_r : state_vector;

  -- signals for timing
  signal t_cas_r         : integer range 0 to t_cas_c - 1;
  signal t_end_cas_r     : integer range 0 to t_cas_c - 1;
  signal t_rfc_r         : integer range 0 to t_rfc_c - 1;
  signal t_rp_r          : integer range 0 to t_rp_c - 1;
  signal t_from_active_r : integer range 0 to t_ras_max_c - 2;

  signal t_wr_r               : integer range 0 to t_wr_c - 1;
  signal t_mrd_r              : integer range 0 to t_mrd_c - 1;
  signal t_from_refresh_r     : integer range 0 to init_wait_cycles_c - 1;
  signal refresh_period_clr_r : std_logic;
  signal row_active_r         : std_logic;
  signal input_re_out_r       : std_logic;

  signal sdram_data_out_r : std_logic_vector(15 downto 0);
  signal input_one_d_in_r   : std_logic;
  signal input_empty_in_r   : std_logic;

  signal write_on_r : std_logic;

  signal data_to_sdram2hibi_r : std_logic_vector(15 downto 0);

begin  -- rtl

  write_on_out <= write_on_r;

  data_out <= data_to_sdram2hibi_r;

  output_we_out <= output_we_r and not(output_full_in);

  input_re_out <= input_re_out_r;

  sdram_data_inout <= sdram_data_out_r when write_on_r = '1'
                      else (others => 'Z');
  -- assign commands to sdram control lines
  sdram_cs_n_out  <= sdram_command_r(3);
  sdram_ras_n_out <= sdram_command_r(2);
  sdram_cas_n_out <= sdram_command_r(1);
  sdram_we_n_out  <= sdram_command_r(0);

  -- sdram clock is always enabled
  sdram_cke_out <= '1';

  register_inouts : process (clk, rst_n)
  begin  -- process register_inouts

    if rst_n = '0' then                 -- asynchronous reset (active low)
      sdram_data_out_r   <= (others => '0');
      input_empty_in_r     <= '0';
      input_one_d_in_r     <= '0';
      data_to_sdram2hibi_r <= (others => '0');

    elsif clk'event and clk = '1' then  -- rising clock edge
      sdram_data_out_r   <= data_in;
      input_empty_in_r     <= input_empty_in;
      input_one_d_in_r     <= input_one_d_in;
      data_to_sdram2hibi_r <= sdram_data_inout;
    end if;
  end process register_inouts;

  -- purpose: State machine
  state_machine_proc : process (clk, rst_n)
  begin  -- process state_machine_proc
    if rst_n = '0' then                 -- asynchronous reset (active low)
      row_active_r         <= '0';
      sdram_dqm_out        <= (others => '0');
      t_wr_r               <= 0;
      data_counter_r       <= (others => '0');
      data_amount_r        <= (others => '0');
      sdram_ba_out         <= (others => '0');
      sdram_address_out    <= (others => '0');
      t_rp_r               <= 0;
      t_rfc_r              <= 0;
      t_mrd_r              <= 0;
      t_end_cas_r          <= 0;
      refresh_period_clr_r <= '0';
      input_re_out_r       <= '0';
      sdram_command_r      <= sdram_nop_c;
      sdram_address_r      <= (others => '0');
      current_state_r      <= init_wait;
      busy_out             <= '1';
      read_on_r            <= '0';
      write_on_r           <= '0';
    elsif clk'event and clk = '1' then  -- rising clock edge

      case current_state_r is

-------------------------------------------------------------------------------
-- start initialization sequence
-------------------------------------------------------------------------------
        -- after reset NOP commands for 100us
        when init_wait =>
          refresh_period_clr_r <= '0';
          if t_from_refresh_r = init_wait_cycles_c - 1
            or sim_ena_g = 1 then
            t_rp_r                <= 0;
            sdram_address_out(10) <= '1';
            sdram_command_r       <= sdram_precharge_c;
            current_state_r       <= init_precharge;
          else
            sdram_command_r <= sdram_nop_c;
            current_state_r <= init_wait;
          end if;

          -- after 100us of NOPs precharge all banks
        when init_precharge =>
          if t_rp_r = t_rp_c - 1 or t_rp_c <= 1 then
            sdram_command_r <= sdram_auto_refresh_c;
            current_state_r <= init_auto_refresh1;
          else
            t_rp_r          <= t_rp_r + 1;
            sdram_command_r <= sdram_nop_c;
            current_state_r <= init_precharge;
          end if;

          -- after precharge two auto refreshes
        when init_auto_refresh1 =>
          if t_rfc_r = t_rfc_c - 1 or t_rfc_c <= 1 then
            refresh_period_clr_r <= '1';
            t_rfc_r              <= 0;
            sdram_command_r      <= sdram_auto_refresh_c;
            current_state_r      <= init_auto_refresh2;
          else
            refresh_period_clr_r <= '0';
            t_rfc_r              <= t_rfc_r + 1;
            sdram_command_r      <= sdram_nop_c;
            current_state_r      <= init_auto_refresh1;
          end if;

        when init_auto_refresh2 =>
          refresh_period_clr_r                <= '0';
          if t_rfc_r = t_rfc_c - 1 or t_rfc_c <= 1 then
            t_rfc_r           <= 0;
            sdram_address_out <= default_mode_c;
            sdram_command_r   <= sdram_load_mode_c;
            current_state_r   <= init_load_mode_register;
          else
            t_rfc_r         <= t_rfc_r + 1;
            sdram_command_r <= sdram_nop_c;
            current_state_r <= init_auto_refresh2;
          end if;

          -- load default mode
        when init_load_mode_register =>
          sdram_command_r                     <= sdram_nop_c;
          if t_mrd_r = t_mrd_c - 1 or t_mrd_c <= 1 then
            t_mrd_r         <= 0;
            busy_out        <= '0';
            current_state_r <= idle;
          else
            t_mrd_r         <= t_mrd_r + 1;
            current_state_r <= init_load_mode_register;
          end if;
-------------------------------------------------------------------------------
-- end initialization and start normal operation
-------------------------------------------------------------------------------

        when idle =>

          data_counter_r <= (others => '0');
          -- precharge is always done before returning to idle state
          -- so we don't have to worry about t_ras_min_c or t_rp_c
          -- (2*t_ras_min),t_rc_c and t_rp_c subracted from refresh_period to prevent
          -- situations where refresh is done right next to active command.
          -- (which is waste of time)
          -- This way when we start executing reads or writes we can do
          -- at least one operation before refreshing.
          if t_from_refresh_r
            >= refresh_period_c - refresh_latency_idle_c then
--             >= refresh_period_c - t_ras_min_c - t_rp_c - 20  -- - 2
--            - (2 * t_ras_min_c) - t_rc_c - t_rp_c - 1 then
            sdram_command_r      <= sdram_auto_refresh_c;
            refresh_period_clr_r <= '1';
            current_state_r      <= idle_auto_refresh;
            busy_out             <= '0';
          else

            -- If there is a valid command in the command_in port
            -- we start to process it immediately and tell it to
            -- others by setting busy_out to '1'
            case command_in is

              -- if time from active to active is met, activate
              -- row and proceed to reading. Otherwise go to
              -- wait_read_active_to_active state. And wait
              -- for t_rc_c or t_rrd
              when command_read_c =>

                sdram_dqm_out <= (others => '0');
                if data_amount_in >
                  conv_std_logic_vector(block_read_length_g,
                                        data_amount_r'length) then
                  data_amount_r <=
                    conv_std_logic_vector(block_read_length_g,
                                          data_amount_r'length);
                else
                  data_amount_r <= data_amount_in;
                end if;
                sdram_address_r   <= address_in;
                sdram_ba_out      <= address_in(21 downto 20);
                sdram_address_out <= address_in(19 downto 8);

                -- read operation to bank that was activated in previous operation
                if address_in(21 downto 20)
                   = sdram_address_r(21 downto 20) then

                  if (t_from_active_r >= t_rc_c - 1 or t_rc_c <= 1)
                    and sdram_command_r /= sdram_active_c
                    and output_full_in = '0' then

                    busy_out        <= '1';
                    read_on_r <= '1';
                    sdram_command_r <= sdram_active_c;
                    current_state_r <= start_read;
                  else
                    busy_out        <= '0';
                    sdram_command_r <= sdram_nop_c;
                    current_state_r <= idle;
                  end if;

                  -- read operation to different bank than previously
                else

                  if (t_from_active_r >= t_rrd_c - 1 or t_rrd_c <= 1)
                    and sdram_command_r /= sdram_active_c
                    and output_full_in = '0' then
                    busy_out        <= '1';
                    read_on_r <= '1';
                    sdram_command_r <= sdram_active_c;
                    current_state_r <= start_read;
                  else
                    busy_out        <= '0';
                    sdram_command_r <= sdram_nop_c;
                    current_state_r <= idle;
                  end if;
                  
                end if;

              when command_write_c =>

                sdram_dqm_out     <= byte_select_in;
                data_amount_r     <= data_amount_in;
                sdram_address_r   <= address_in;
                sdram_ba_out      <= address_in(21 downto 20);
                sdram_address_out <= address_in(19 downto 8);

                -- write operation to bank that was activated in
                -- the previous operation
                if address_in(21 downto 20)
                   = sdram_address_r(21 downto 20) then

                  if (t_from_active_r >= t_rc_c - 1 or t_rc_c <= 1)
                    and sdram_command_r /= sdram_active_c
                    and input_empty_in = '0' then

                    busy_out        <= '1';
                    sdram_command_r <= sdram_active_c;
                    current_state_r <= start_write;
                  else
                    busy_out        <= '0';
                    sdram_command_r <= sdram_nop_c;
                    current_state_r <= idle;
                  end if;

                  -- write operation to different bank than previously
                else

                  if (t_from_active_r >= t_rrd_c - 1 or t_rrd_c <= 1)
                    and sdram_command_r /= sdram_active_c
                    and input_empty_in = '0' then
                    busy_out        <= '1';
                    sdram_command_r <= sdram_active_c;
                    current_state_r <= start_write;
                  else
                    busy_out        <= '0';
                    sdram_command_r <= sdram_nop_c;
                    current_state_r <= idle;
                  end if;
                  
                end if;

                -- NOP or unknown command, don't do anything
              when others =>
                busy_out        <= '0';
                sdram_command_r <= sdram_nop_c;
                current_state_r <= idle;
            end case;
          end if;


        -- wait until time minimum time from active to active is met
        -- and precharge command period is met
        -- go to start write
        when wait_write_active_to_active =>
          sdram_ba_out      <= sdram_address_r(21 downto 20);
          sdram_address_out <= sdram_address_r(19 downto 8);

          if t_rp_r >= t_rp_c - 1 or t_rp_c <= 1 then
            t_rp_r <= t_rp_r;
          else
            t_rp_r <= t_rp_r + 1;
          end if;

          -- operation to bank that was activated in previous operation
          if address_in(21 downto 20)
             = sdram_address_r(21 downto 20) then

            if (t_from_active_r >= t_rc_c - 2 or t_rc_c <= 2)
              and sdram_command_r /= sdram_active_c
              and t_rp_r >= t_rp_c - 1 then

              sdram_command_r <= sdram_active_c;
              current_state_r <= start_write;
            else
              sdram_command_r <= sdram_nop_c;
              current_state_r <= wait_write_active_to_active;
            end if;

            -- operation to different bank than previously
          else

            if (t_from_active_r >= t_rrd_c - 2 or t_rrd_c <= 2)
              and sdram_command_r /= sdram_active_c
              and t_rp_r >= t_rp_c - 1 then

              sdram_command_r <= sdram_active_c;
              current_state_r <= start_write;
            else
              sdram_command_r <= sdram_nop_c;
              current_state_r <= wait_write_active_to_active;
            end if;
            
          end if;

          -- Wait for data to be written.
          -- Since we don't know when input data is available
          -- we must check refreshing and t_ras_max(maximum
          -- time that row can be open).
          -- When input data arrives, read data(input_re_out = '1')
          -- and go to continue write state.
        when start_write =>

          sdram_command_r <= sdram_nop_c;

          -- Worst case in refreshing is that we go to
          -- write_change_row_precharge state then
          -- the next possibility to make refresh is after:
          --   t_ras_min_c in write_change_row_precharge +
          --   t_rc_c in wait_write_active_to_active +
          --   t_ras_min_c in write_refresh_precharge +
          --   t_rp_c in write_refresh
          --     = 2*t_ras_min_c + t_rc_c + t_rp
          if t_from_refresh_r
             >= refresh_period_c - refresh_latency_write_c - 1
            or (t_from_active_r >= t_ras_max_c - t_wr_c - 3
                and sdram_command_r /= sdram_active_c) then

            input_re_out_r  <= '0';
            current_state_r <= write_refresh_precharge;

          else
            -- is t_rcd_c (minimum time from active to read/write) met?
            if t_rcd_c <= 2
                          or (t_from_active_r >= t_rcd_c - 3
                              and sdram_command_r /= sdram_active_c) then

              sdram_ba_out      <= sdram_address_r(21 downto 20);
              sdram_address_out <= "0000" & sdram_address_r(7 downto 0);

              -- We must change row if address is first column in row and
              -- this is not the first write of this operation.
              if input_empty_in = '0' and not(input_one_d_in = '1' and
                                              input_re_out_r = '1') then

                if sdram_address_r(7 downto 0) = 0 and data_counter_r /= 0
                  and row_active_r = '0' then
                  input_re_out_r  <= '0';
                  row_active_r    <= '1';
                  current_state_r <= write_change_row_precharge;
                else
                  input_re_out_r  <= '1';
                  current_state_r <= continue_write;
                end if;
              else
                input_re_out_r  <= '0';
                current_state_r <= write_finished;
              end if;
            else
              input_re_out_r  <= '0';
              current_state_r <= start_write;
            end if;
          end if;

          -- Write until operation is completed. Change row,
          -- precharge and refresh if necessary
        when continue_write =>

          sdram_ba_out      <= sdram_address_r(21 downto 20);
          sdram_address_out <= "0000" & sdram_address_r(7 downto 0);

          -- write finished or terminated
          if data_counter_r = data_amount_r
            or (sdram_address_r
                 = conv_std_logic_vector(0, sdram_address_r'length)
                and data_counter_r /= 0) then
            row_active_r <= '0';

            input_re_out_r  <= '0';
            data_counter_r  <= (others => '0');
            sdram_command_r <= sdram_nop_c;
            current_state_r <= write_finished;
            write_on_r      <= '0';

            -- refresh. refresh_latency_write takes care of possible
            -- delays before refresh can be done (precharge command period
            -- and changing row.
          elsif t_from_refresh_r >= refresh_period_c - refresh_latency_write_c
            or (t_from_active_r >= t_ras_max_c - t_wr_c - 2
                and sdram_command_r /= sdram_active_c) then
            input_re_out_r  <= '0';
            sdram_command_r <= sdram_nop_c;
            current_state_r <= write_refresh_precharge;
            write_on_r      <= '0';


            -- change row
          elsif sdram_address_r(7 downto 0) = 0 and data_counter_r /= 0
            and row_active_r = '0' then
            input_re_out_r  <= '0';
            row_active_r    <= '1';
            sdram_command_r <= sdram_nop_c;
            current_state_r <= write_change_row_precharge;
            write_on_r      <= '0';

            -- normal write
          else
            row_active_r <= '0';

            if (input_empty_in_r = '0' and not(input_one_d_in_r = '1'
                                               and input_re_out_r = '1'))
              or data_counter_r = 0 then

              data_counter_r  <= data_counter_r + 1;
              sdram_address_r <= sdram_address_r + 1;

              -- don't load new data if write finishes or row changes
              -- or refresh or t_ras_max_c is met.
              -- In t_from_refresh_r >= refresh_period - x the x
              -- must be one larger than in the previous if(refresh)
              -- otherwise the data_counter_r goes wrong

              if sdram_address_r(7 downto 0) = "11111111"
                or t_from_refresh_r
                 >= refresh_period_c - refresh_latency_write_c - 1
                or (t_from_active_r >= t_ras_max_c - t_wr_c - 2 - 1
                    and sdram_command_r /= sdram_active_c)
                or data_counter_r = data_amount_r - 1
                or (input_empty_in = '1' or (input_one_d_in = '1'
                                             and input_re_out_r = '1')) then
                input_re_out_r  <= '0';
                current_state_r <= write_finished;

              else
                input_re_out_r  <= '1';
                current_state_r <= continue_write;
              end if;
              write_on_r      <= '1';
              sdram_command_r <= sdram_write_c;
              t_wr_r          <= 0;

              -- no input data available, terminate write
            else
              write_on_r      <= '0';
              data_counter_r  <= data_counter_r;
              sdram_address_r <= sdram_address_r;
              input_re_out_r  <= '0';
              sdram_command_r <= sdram_nop_c;
              current_state_r <= write_finished;
            end if;
          end if;

          -- Refresh during write operation.
          -- First we must wait for t_wr(write recovery time) and
          -- t_ras_min(minimum time from active to precharge)
          -- Then we must precharge all banks before refresh.
        when write_refresh_precharge =>
          if t_wr_c <= 2 or (t_wr_r >= t_wr_c - 2) then
            if (t_from_active_r >= t_ras_min_c - 2
                and sdram_command_r /= sdram_active_c) then
              t_rp_r                <= 0;
              sdram_address_out(10) <= '1';
              sdram_command_r       <= sdram_precharge_c;
              current_state_r       <= write_refresh;
            else
              t_wr_r          <= t_wr_r;
              sdram_command_r <= sdram_nop_c;
              current_state_r <= write_refresh_precharge;
            end if;

          else
            t_wr_r          <= t_wr_r + 1;
            sdram_command_r <= sdram_nop_c;
            current_state_r <= write_refresh_precharge;
          end if;

          -- Wait for t_rp(precharge command period)
          -- after that refresh
        when write_refresh =>
          if t_rp_r = t_rp_c - 1 or t_rp_c <= 1 then
            refresh_period_clr_r <= '1';
            t_rp_r               <= 0;
            sdram_command_r      <= sdram_auto_refresh_c;
            current_state_r      <= write_refresh_wait;
          else
            sdram_command_r <= sdram_nop_c;
            t_rp_r          <= t_rp_r + 1;
            current_state_r <= write_refresh;
          end if;

          -- wait for refresh command period and
          -- proceed write operation
        when write_refresh_wait =>
          refresh_period_clr_r                <= '0';
          if t_rfc_r = t_rfc_c - 1 or t_rfc_c <= 1 then
            t_rfc_r         <= 0;
            sdram_command_r <= sdram_nop_c;
            if data_counter_r = data_amount_r then
              row_active_r    <= '0';
              busy_out        <= '0';
              current_state_r <= idle;
            else
              busy_out        <= '1';
              current_state_r <= wait_write_active_to_active;
            end if;
          else
            t_rfc_r         <= t_rfc_r + 1;
            sdram_command_r <= sdram_nop_c;
            current_state_r <= write_refresh_wait;
          end if;

          -- Change row in write operation.
          -- Wait for write recovery time and precharge
          -- all banks. Then go to wait_write_active_to_active
          -- state that handles activating the new row/bank
          -- and proceeds writing.
        when write_change_row_precharge =>
          if t_wr_c <= 2 or (t_wr_r = t_wr_c - 2) then
            if (t_from_active_r >= t_ras_min_c - 2 or t_ras_min_c <= 2)
              and sdram_command_r /= sdram_active_c then
              t_rp_r                <= 0;
              sdram_address_out(10) <= '1';
              sdram_command_r       <= sdram_precharge_c;

              if data_counter_r = data_amount_r then
                busy_out        <= '1';
                row_active_r    <= '0';
                current_state_r <= write_finished_precharge;
              else
                current_state_r <= wait_write_active_to_active;
              end if;
            else
              t_wr_r          <= t_wr_r;
              sdram_command_r <= sdram_nop_c;
              current_state_r <= write_change_row_precharge;
            end if;
          else
            t_wr_r          <= t_wr_r + 1;
            sdram_command_r <= sdram_nop_c;
            current_state_r <= write_change_row_precharge;
          end if;

          -- write finished, so wait for wait_recovery time
          -- and minimum time from active to precharge and
          -- precharge all banks
        when write_finished =>
          write_on_r   <= '0';
          row_active_r <= '0';

          if write_on_r = '0' then
            
            if (t_wr_c <= 2 or (t_wr_r >= t_wr_c - 2)) then
              if (t_from_active_r >= t_ras_min_c - 2 or t_ras_min_c <= 2)
                and sdram_command_r /= sdram_active_c then
                sdram_address_out(10) <= '1';
                t_rp_r                <= 0;
                busy_out              <= '1';
                sdram_command_r       <= sdram_precharge_c;
                current_state_r       <= write_finished_precharge;
              else
                t_wr_r          <= t_wr_r;
                sdram_command_r <= sdram_nop_c;
                current_state_r <= write_finished;
              end if;
            else
              t_wr_r          <= t_wr_r + 1;
              sdram_command_r <= sdram_nop_c;
              current_state_r <= write_finished;
            end if;
          else
            sdram_command_r <= sdram_nop_c;
            current_state_r <= write_finished;
          end if;

          -- wait for precharge command period and
          -- go to idle state.
        when write_finished_precharge =>
          sdram_command_r <= sdram_nop_c;
          if t_rp_c       <= 2 or (t_rp_r = t_rp_c - 1 - 1) then
            t_rp_r          <= t_rp_c - 1;
            busy_out        <= '0';
            current_state_r <= idle;
          else
            t_rp_r          <= t_rp_r + 1;
            current_state_r <= write_finished_precharge;
          end if;

          -- refresh during idle state
        when idle_auto_refresh =>
          refresh_period_clr_r                <= '0';
          sdram_command_r                     <= sdram_nop_c;
          if t_rfc_r = t_rfc_c - 1 or t_rfc_c <= 1 then
            t_rfc_r         <= 0;
            busy_out        <= '0';
            current_state_r <= idle;
          else
            t_rfc_r         <= t_rfc_r + 1;
            current_state_r <= idle_auto_refresh;
          end if;

          -- Start read state
          -- Check t_rcd(minimum time between active and read/write command).
          -- If timings are met the go to continue read state where
          -- the actual read happens.
        when start_read =>
          sdram_command_r <= sdram_nop_c;

          if t_rcd_c <= 2
                        or (t_from_active_r >= t_rcd_c - 3
                            and sdram_command_r /= sdram_active_c) then
            current_state_r <= continue_read;
          else
            current_state_r <= start_read;
          end if;

          -- continue read state:
          -- Check refreshing and t_ras_max.
          -- If output fifo is full or
          -- row changes, terminate read
        when continue_read =>

          -- refresh
          if t_from_refresh_r >= refresh_period_c - refresh_latency_read_c
            or (t_from_active_r >= t_ras_max_c - 2
                and sdram_command_r /= sdram_active_c) then

            if output_full_in = '1' then
              data_counter_r <= succesful_reads_r;
            else
              data_counter_r  <= data_counter_r;
              sdram_address_r <= sdram_address_r;
            end if;

            sdram_command_r <= sdram_nop_c;
            current_state_r <= read_refresh_precharge;

          else

            if output_full_in = '0' then

              -- read finished
              if data_counter_r = data_amount_r then
                sdram_address_r <= sdram_address_r;
                data_counter_r  <= data_counter_r;
                sdram_command_r <= sdram_nop_c;
                current_state_r <= read_finished;

                -- address overflow, read the last address until operation
                -- is finished
              elsif sdram_address_r
                 = conv_std_logic_vector(0, sdram_address_r'length)
                and data_counter_r /= 0 then

                sdram_address_r   <= (others => '1');
                sdram_ba_out      <= sdram_address_r(21 downto 20);
                sdram_address_out <= "0000" & sdram_address_r(7 downto 0);

                data_counter_r    <= data_counter_r + 1;
                sdram_command_r   <= sdram_read_c;
                current_state_r   <= continue_read;

                -- row changes so terminate read
              elsif sdram_address_r(7 downto 0) = "00000000"
                and data_counter_r /= 0 then

                sdram_command_r <= sdram_nop_c;
                current_state_r <= read_finished;

                -- normal read
              else
                data_counter_r    <= data_counter_r + 1;
                sdram_address_r   <= sdram_address_r + 1;
                sdram_ba_out      <= sdram_address_r(21 downto 20);
                sdram_address_out <= "0000" & sdram_address_r(7 downto 0);
                sdram_command_r   <= sdram_read_c;
                current_state_r   <= continue_read;
              end if;

              -- output full, terminate read
            else
              sdram_command_r <= sdram_nop_c;
              data_counter_r  <= succesful_reads_r;

              current_state_r <= read_finished;

            end if;
          end if;

          -- wait for timings to be met and precharge
        when read_refresh_precharge =>

          if t_end_cas_r = t_cas_c - 1 or output_full_in = '1' then

            data_counter_r <= succesful_reads_r;

            if (t_from_active_r >= t_ras_min_c - 2 or t_ras_min_c <= 2)
              and sdram_command_r /= sdram_active_c then
              t_end_cas_r           <= 0;
              t_rp_r                <= 0;
              data_counter_r        <= (others => '0');
              read_on_r             <= '0';
              sdram_address_out(10) <= '1';
              sdram_command_r       <= sdram_precharge_c;
              current_state_r       <= read_refresh;

            else
              sdram_command_r <= sdram_nop_c;
              t_end_cas_r     <= t_end_cas_r;
              current_state_r <= read_refresh_precharge;
            end if;

          else
            t_end_cas_r     <= t_end_cas_r + 1;
            sdram_command_r <= sdram_nop_c;
            current_state_r <= read_refresh_precharge;
          end if;

          -- wait for precharge command period and refresh
        when read_refresh =>
          if t_rp_r = t_rp_c - 1 or t_rp_c <= 1 then
            refresh_period_clr_r <= '1';
            sdram_command_r      <= sdram_auto_refresh_c;
            current_state_r      <= read_refresh_wait;
          else
            sdram_command_r <= sdram_nop_c;
            t_rp_r          <= t_rp_r + 1;
            current_state_r <= read_refresh;
          end if;

          -- wait for refresh command period and proceed reading.
        when read_refresh_wait =>
          refresh_period_clr_r                <= '0';
          if t_rfc_r = t_rfc_c - 1 or t_rfc_c <= 1 then
            t_rfc_r         <= 0;
            sdram_command_r <= sdram_nop_c;
            busy_out        <= '0';
            read_on_r       <= '0';
            current_state_r <= idle;
          else
            t_rfc_r         <= t_rfc_r + 1;
            sdram_command_r <= sdram_nop_c;
            current_state_r <= read_refresh_wait;
          end if;

          -- All read commands are send to sdram.
          -- Wait for cas latency and check that all read data fits
          -- to output fifo. If fifo gets full then terminate read.
          -- Precharge all banks.
        when read_finished =>

          if t_end_cas_r = t_cas_c - 1 or output_full_in = '1' then

            data_counter_r <= succesful_reads_r;

            if (t_from_active_r >= t_ras_min_c - 2 or t_ras_min_c <= 2)
              and sdram_command_r /= sdram_active_c then
              data_counter_r        <= (others => '0');
              t_end_cas_r           <= 0;
              t_rp_r                <= 0;
              sdram_address_out(10) <= '1';
              busy_out              <= '1';
              read_on_r             <= '0';
              sdram_command_r       <= sdram_precharge_c;
              current_state_r       <= read_finished_precharge;
            else
              sdram_command_r <= sdram_nop_c;
              t_end_cas_r     <= t_end_cas_r;
              current_state_r <= read_finished;
            end if;
          else
            sdram_command_r <= sdram_nop_c;
            t_end_cas_r     <= t_end_cas_r + 1;
            current_state_r <= read_finished;
          end if;

          -- Read operation is finished, all read data is
          -- put to output fifo and precharge is done.
          -- Now wait for precharge command period and
          -- go to idle state.
        when read_finished_precharge =>
          sdram_command_r <= sdram_nop_c;
          if t_rp_c       <= 2 or (t_rp_r = t_rp_c - 1 - 1) then
            t_rp_r          <= t_rp_c - 1;
            busy_out        <= '0';
            read_on_r       <= '0';
            current_state_r <= idle;
          else
            t_rp_r          <= t_rp_r + 1;
            current_state_r <= read_finished_precharge;
          end if;

        when others =>
          sdram_command_r <= sdram_nop_c;
          current_state_r <= idle;
      end case;
    end if;

  end process state_machine_proc;

  -- This process writes read data from sdram data bus to
  -- output fifo.
  write_read_data_to_output : process (clk, rst_n)

  begin  -- process write_read_data_to_output
    if rst_n = '0' then                 -- asynchronous reset (active low)
      t_cas_r           <= 0;
      succesful_reads_r <= (others => '0');
      output_we_r       <= '0';

    elsif clk'event and clk = '1' then  -- rising clock edge

      -- first check that current operation is read
      if read_on_r = '1' then

        -- if output fifo gets full. Clear cas latency counter
        -- and don't write read data to output
        if output_full_in = '1' then

          t_cas_r <= 0;
          output_we_r <= '0';

        else

          -- if read succeeds(output is not full) then proceed
          -- writing data to output buffer until the operation
          -- is complete
          if data_counter_r > succesful_reads_r then

            -- if cas latency is met(data from sdram is on the data bus),
            -- then write data to output fifo and update succesful read
            -- count and succesful read and store their previous values.
            -- address.
            if t_cas_r = t_cas_c - 1 then
              t_cas_r           <= t_cas_r;
              succesful_reads_r <= succesful_reads_r + 1;
              output_we_r       <= '1';

              -- wait for data from sdram(cas latency)
            else
              t_cas_r           <= t_cas_r + 1;
              succesful_reads_r <= succesful_reads_r;
              output_we_r       <= '0';
            end if;

            -- read is finished, clear cas and don't write to output fifo
          else
            t_cas_r     <= 0;
            output_we_r <= '0';
          end if;
        end if;

        -- if current operation is not read then reset this process
      else
        t_cas_r           <= 0;
        succesful_reads_r <= (others => '0');
        output_we_r       <= '0';
      end if;
    end if;

  end process write_read_data_to_output;

  -- purpose: keeps count of time from active command
  --          handles t_rc, t_rcd, t_rrd, t_ras_min, t_ras_max
  t_from_active_counter : process (clk, rst_n)

  begin  -- process t_from_active_counter

    if rst_n = '0' then                 -- asynchronous reset (active low)
      t_from_active_r <= 0;
    elsif clk'event and clk = '1' then  -- rising clock edge

      if sdram_command_r = sdram_active_c then
        t_from_active_r <= 0;
      else
        if t_from_active_r = t_ras_max_c - 2 then
          t_from_active_r <= t_from_active_r;
        else
          t_from_active_r <= t_from_active_r + 1;
        end if;
      end if;

    end if;

  end process t_from_active_counter;

  -- purpose: keeps count of refresh periods
  refresh_period_counter : process (clk, rst_n)

  begin  -- process refresh_period_counter

    if rst_n = '0' then                 -- asynchronous reset (active low)
      t_from_refresh_r <= 0;

    elsif clk'event and clk = '1' then  -- rising clock edge

      if refresh_period_clr_r = '1' then
        t_from_refresh_r <= 0;
      else

        if t_from_refresh_r = init_wait_cycles_c - 1 then
          t_from_refresh_r <= t_from_refresh_r;
        else
          t_from_refresh_r <= t_from_refresh_r + 1;
        end if;
      end if;
      
    end if;

  end process refresh_period_counter;

end rtl;
