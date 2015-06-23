

-- <ALTERA_NOTE> CODE INSERTED BETWEEN HERE

signal cpu_0_reset : std_logic;
signal cpu_1_reset : std_logic;
signal cpu_2_reset : std_logic;

signal cpu_0_reset_taken : std_logic;
signal cpu_1_reset_taken : std_logic;
signal cpu_2_reset_taken : std_logic;

signal comm_from_n : std_logic_vector(5*3-1 downto 0);
signal data_from_n : std_logic_vector(32*3-1 downto 0);
signal av_from_n : std_logic_vector(3-1 downto 0);
signal we_from_n : std_logic_vector(3-1 downto 0);
signal re_from_n : std_logic_vector(3-1 downto 0);
signal comm_to_n : std_logic_vector(5*3-1 downto 0);
signal data_to_n : std_logic_vector(32*3-1 downto 0);
signal av_to_n : std_logic_vector(3-1 downto 0);
signal full_to_n : std_logic_vector(3-1 downto 0);
signal one_p_to_n : std_logic_vector(3-1 downto 0);
signal empty_to_n : std_logic_vector(3-1 downto 0);
signal one_d_to_n : std_logic_vector(3-1 downto 0);

-- AND HERE WILL BE PRESERVED </ALTERA_NOTE>


begin

  --
  -- CHECK DUTS NAME !
  --

  --Set us up the Dut
  DUT : n2h2_s
    port map(
      cpu_resettaken_from_the_cpu_0 => cpu_resettaken_from_the_cpu_0,
      cpu_resettaken_from_the_cpu_1 => cpu_resettaken_from_the_cpu_1,
      cpu_resettaken_from_the_cpu_2 => cpu_resettaken_from_the_cpu_2,
      hibi_av_out_from_the_n2h2_chan_0 => hibi_av_out_from_the_n2h2_chan_0,
      hibi_av_out_from_the_n2h2_chan_1 => hibi_av_out_from_the_n2h2_chan_1,
      hibi_av_out_from_the_n2h2_chan_2 => hibi_av_out_from_the_n2h2_chan_2,
      hibi_comm_out_from_the_n2h2_chan_0 => hibi_comm_out_from_the_n2h2_chan_0,
      hibi_comm_out_from_the_n2h2_chan_1 => hibi_comm_out_from_the_n2h2_chan_1,
      hibi_comm_out_from_the_n2h2_chan_2 => hibi_comm_out_from_the_n2h2_chan_2,
      hibi_data_out_from_the_n2h2_chan_0 => hibi_data_out_from_the_n2h2_chan_0,
      hibi_data_out_from_the_n2h2_chan_1 => hibi_data_out_from_the_n2h2_chan_1,
      hibi_data_out_from_the_n2h2_chan_2 => hibi_data_out_from_the_n2h2_chan_2,
      hibi_re_out_from_the_n2h2_chan_0 => hibi_re_out_from_the_n2h2_chan_0,
      hibi_re_out_from_the_n2h2_chan_1 => hibi_re_out_from_the_n2h2_chan_1,
      hibi_re_out_from_the_n2h2_chan_2 => hibi_re_out_from_the_n2h2_chan_2,
      hibi_we_out_from_the_n2h2_chan_0 => hibi_we_out_from_the_n2h2_chan_0,
      hibi_we_out_from_the_n2h2_chan_1 => hibi_we_out_from_the_n2h2_chan_1,
      hibi_we_out_from_the_n2h2_chan_2 => hibi_we_out_from_the_n2h2_chan_2,
      clk_0 => clk_0,
      cpu_resetrequest_to_the_cpu_0 => cpu_resetrequest_to_the_cpu_0,
      cpu_resetrequest_to_the_cpu_1 => cpu_resetrequest_to_the_cpu_1,
      cpu_resetrequest_to_the_cpu_2 => cpu_resetrequest_to_the_cpu_2,
      hibi_av_in_to_the_n2h2_chan_0 => hibi_av_in_to_the_n2h2_chan_0,
      hibi_av_in_to_the_n2h2_chan_1 => hibi_av_in_to_the_n2h2_chan_1,
      hibi_av_in_to_the_n2h2_chan_2 => hibi_av_in_to_the_n2h2_chan_2,
      hibi_comm_in_to_the_n2h2_chan_0 => hibi_comm_in_to_the_n2h2_chan_0,
      hibi_comm_in_to_the_n2h2_chan_1 => hibi_comm_in_to_the_n2h2_chan_1,
      hibi_comm_in_to_the_n2h2_chan_2 => hibi_comm_in_to_the_n2h2_chan_2,
      hibi_data_in_to_the_n2h2_chan_0 => hibi_data_in_to_the_n2h2_chan_0,
      hibi_data_in_to_the_n2h2_chan_1 => hibi_data_in_to_the_n2h2_chan_1,
      hibi_data_in_to_the_n2h2_chan_2 => hibi_data_in_to_the_n2h2_chan_2,
      hibi_empty_in_to_the_n2h2_chan_0 => hibi_empty_in_to_the_n2h2_chan_0,
      hibi_empty_in_to_the_n2h2_chan_1 => hibi_empty_in_to_the_n2h2_chan_1,
      hibi_empty_in_to_the_n2h2_chan_2 => hibi_empty_in_to_the_n2h2_chan_2,
      hibi_full_in_to_the_n2h2_chan_0 => hibi_full_in_to_the_n2h2_chan_0,
      hibi_full_in_to_the_n2h2_chan_1 => hibi_full_in_to_the_n2h2_chan_1,
      hibi_full_in_to_the_n2h2_chan_2 => hibi_full_in_to_the_n2h2_chan_2,
      reset_n => reset_n
    );


  process
  begin
    clk_0 <= '0';
    loop
       wait for 10 ns;
       clk_0 <= not clk_0;
    end loop;
  end process;
  PROCESS
    BEGIN
       reset_n <= '0';
       wait for 200 ns;
       reset_n <= '1'; 
    WAIT;
  END PROCESS;


-- <ALTERA_NOTE> CODE INSERTED BETWEEN HERE

  cpu_0_reset_taken <= cpu_resettaken_from_the_cpu_0;
  cpu_1_reset_taken <= cpu_resettaken_from_the_cpu_1;
  cpu_2_reset_taken <= cpu_resettaken_from_the_cpu_2;

  cpu_resetrequest_to_the_cpu_0 <= cpu_0_reset;
  cpu_resetrequest_to_the_cpu_1 <= cpu_1_reset;
  cpu_resetrequest_to_the_cpu_2 <= cpu_2_reset;

  av_from_n(0) <= hibi_av_out_from_the_n2h2_chan_0;
  av_from_n(1) <= hibi_av_out_from_the_n2h2_chan_1;
  av_from_n(2) <= hibi_av_out_from_the_n2h2_chan_2;

  comm_from_n(5*1-1 downto 5*0) <= hibi_comm_out_from_the_n2h2_chan_0;
  comm_from_n(5*2-1 downto 5*1) <= hibi_comm_out_from_the_n2h2_chan_1;
  comm_from_n(5*3-1 downto 5*2) <= hibi_comm_out_from_the_n2h2_chan_2;

  data_from_n(32*1-1 downto 32*0) <= hibi_data_out_from_the_n2h2_chan_0;
  data_from_n(32*2-1 downto 32*1) <= hibi_data_out_from_the_n2h2_chan_1;
  data_from_n(32*3-1 downto 32*2) <= hibi_data_out_from_the_n2h2_chan_2;

  re_from_n(0) <= hibi_re_out_from_the_n2h2_chan_0;
  re_from_n(1) <= hibi_re_out_from_the_n2h2_chan_1;
  re_from_n(2) <= hibi_re_out_from_the_n2h2_chan_2;

  we_from_n(0) <= hibi_we_out_from_the_n2h2_chan_0;
  we_from_n(1) <= hibi_we_out_from_the_n2h2_chan_1;
  we_from_n(2) <= hibi_we_out_from_the_n2h2_chan_2;
  
  hibi_av_in_to_the_n2h2_chan_0 <= av_to_n(0);
  hibi_av_in_to_the_n2h2_chan_1 <= av_to_n(1);
  hibi_av_in_to_the_n2h2_chan_2 <= av_to_n(2);

  hibi_comm_in_to_the_n2h2_chan_0 <= comm_to_n(5*1-1 downto 5*0);
  hibi_comm_in_to_the_n2h2_chan_1 <= comm_to_n(5*2-1 downto 5*1);
  hibi_comm_in_to_the_n2h2_chan_2 <= comm_to_n(5*3-1 downto 5*2);

  hibi_data_in_to_the_n2h2_chan_0 <= data_to_n(32*1-1 downto 32*0);
  hibi_data_in_to_the_n2h2_chan_1 <= data_to_n(32*2-1 downto 32*1);
  hibi_data_in_to_the_n2h2_chan_2 <= data_to_n(32*3-1 downto 32*2);

  hibi_empty_in_to_the_n2h2_chan_0 <= empty_to_n(0);
  hibi_empty_in_to_the_n2h2_chan_1 <= empty_to_n(1);
  hibi_empty_in_to_the_n2h2_chan_2 <= empty_to_n(2);

  hibi_full_in_to_the_n2h2_chan_0 <= full_to_n(0);
  hibi_full_in_to_the_n2h2_chan_1 <= full_to_n(1);
  hibi_full_in_to_the_n2h2_chan_2 <= full_to_n(2);

  
  
  hibiv3_r4_1: entity work.hibiv3_r4
    generic map (
      id_width_g          => 6,
      addr_width_g        => 32,
      data_width_g        => 32,
      comm_width_g        => 5,
      counter_width_g     => 8,
      rel_agent_freq_g    => 1,
      rel_bus_freq_g      => 1,
      arb_type_g          => 3,
      fifo_sel_g          => 0,
      rx_fifo_depth_g     => 4,
      rx_msg_fifo_depth_g => 4,
      tx_fifo_depth_g     => 4,
      tx_msg_fifo_depth_g => 4,
      max_send_g          => 20,
      n_cfg_pages_g       => 1,
      n_time_slots_g      => 0,
      keep_slot_g         => 0,
      n_extra_params_g    => 1,
      cfg_re_g            => 1,
      cfg_we_g            => 1,
      debug_width_g       => 1,
      n_agents_g          => 3,
      n_segments_g        => 1,
      separate_addr_g     => 0)
    port map (
      clk_ip          => clk_0,
      clk_noc         => clk_0,
      rst_n           => reset_n,
      agent_comm_in   => comm_from_n,
      agent_data_in   => data_from_n,
      agent_av_in     => av_from_n,
      agent_we_in     => we_from_n,
      agent_re_in     => re_from_n,
      agent_comm_out  => comm_to_n,
      agent_data_out  => data_to_n,
      agent_av_out    => av_to_n,
      agent_full_out  => full_to_n,
      agent_one_p_out => one_p_to_n,
      agent_empty_out => empty_to_n,
      agent_one_d_out => one_d_to_n);


  cpu_reset_p: process
  begin  -- process cpu_reset_p

    cpu_0_reset <= '1';
    cpu_1_reset <= '1';
    cpu_2_reset <= '1';

    wait for 100 us;

    cpu_0_reset <= '0';
    cpu_1_reset <= '0';
    cpu_2_reset <= '0';      

    wait;
    
  end process cpu_reset_p;
  
  
-- AND HERE WILL BE PRESERVED </ALTERA_NOTE>


end europa;



--synthesis translate_on
