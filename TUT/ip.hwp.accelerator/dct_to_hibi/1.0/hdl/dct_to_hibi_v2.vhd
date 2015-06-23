-------------------------------------------------------------------------------
-- Title      : DCT to Hibi. Connects dctQidct block to HIBI Wrapper
-- Project    : 
-------------------------------------------------------------------------------
-- File       : dct_to_hibi_v2.vhd
-- Author     : rasmusa
-- Created    : 01.07.2006
-- Last update: 2006-08-22
--
-- Input:
-- 1. Two address to send the results to (one for quant, one for idct)
-- 2. Control word for the current macroblock
--    Control word structure: bit 6: chroma(1)/luma(0), 5: intra(1)/inter(0),
--                             4..0: quantizer parameter (QP)
-- 3. Then the DCT data ( 8x8x6 x 16-bit values = 384 x 16 bit )
--
-- Chroma/luma: 4 luma, 2 chroma
--
-- Outputs:
-- Outputs are 16-bit words which are packed up to hibi. If hibi width is
-- 32b, then 2 16-bit words are combined into one hibi word.
-- 01. quant results: 1. 8*8 x 16bit values to quant result address
-- 02. idct  results: 1. 8*8 x 16bit values to idct  result address  
-- 03. quant results: 2. 8*8 x 16bit values to quant result address
-- 04. idct  results: 2. 8*8 x 16bit values to idct  result address
-- 05. quant results: 3. 8*8 x 16bit values to quant result address
-- 06. idct  results: 3. 8*8 x 16bit values to idct  result address
-- 07. quant results: 4. 8*8 x 16bit values to quant result address
-- 08. idct  results: 4. 8*8 x 16bit values to idct  result address
-- 09. quant results: 5. 8*8 x 16bit values to quant result address
-- 10. idct  results: 5. 8*8 x 16bit values to idct  result address
-- 11. quant results: 6. 8*8 x 16bit values to quant result address
-- 12. quant results: 1 word with bits 5..0 determing if 8x8 quant blocks(1-6)
--                    has all values zeros (except dc-component in intra)
-- 13. idct  results: 6. 8*8 x 16bit values to idct  result address
-------------------------------------------------------------------------------
-- Total amount of 16-bit values is: 384 per result address + 1 hibi word to
-- quantization result address.
--
-- With default parameter:
-- Total of 193 words of data to quant address (if data_width_g = 32)
-- Total of 192 words of data to idct address (if data_width_g = 32)
-------------------------------------------------------------------------------
-- Copyright (c) 2005 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 01.07.2005  1.0      AK      Created
-- 11.08.2005  1.1      AK      all-zero quant result given
-- 16.05.2005  1.11     AK      chroma/luma bit
-- 17.07.2007  1.12i    AR      Major rewrite, IF changed to R4, ...
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

-- For or_reduce
use ieee.std_logic_misc.all;

entity dct_to_hibi is
  generic (
    data_width_g   : integer := 32;
    comm_width_g   : integer := 5;
    dct_width_g    : integer;           -- Incoming data width(9b)
    quant_width_g  : integer;           -- Quantizated data width(8b)
    idct_width_g   : integer;           -- Data width after IDCT(9b)
    use_self_rel_g : integer;           -- Does it release itself from RTM?
    own_address_g  : integer;           -- Used for self-release
    rtm_address_g  : integer;           -- Used for self-release
    debug_w_g      : integer := 1
    );

  port (
    clk   : in std_logic;
    rst_n : in std_logic;

    -- HIBI signals
    hibi_av_out   : out std_logic;
    hibi_data_out : out std_logic_vector (data_width_g-1 downto 0);
    hibi_comm_out : out std_logic_vector (comm_width_g-1 downto 0);
    hibi_we_out   : out std_logic;
    hibi_full_in  : in  std_logic;

    hibi_re_out   : out std_logic;
    hibi_av_in    : in  std_logic;
    hibi_data_in  : in  std_logic_vector (data_width_g-1 downto 0);
    hibi_comm_in  : in  std_logic_vector (comm_width_g-1 downto 0);
    hibi_empty_in : in  std_logic;

    -- DCT signals
    wr_dct_out          : out std_logic;
    quant_ready4col_out : out std_logic;
    idct_ready4col_out  : out std_logic;
    data_dct_out        : out std_logic_vector(dct_width_g-1 downto 0);
    intra_out           : out std_logic;
    loadQP_out          : out std_logic;
    QP_out              : out std_logic_vector (4 downto 0);
    chroma_out          : out std_logic;

    data_idct_in     : in  std_logic_vector(idct_width_g-1 downto 0);
    data_quant_in    : in  std_logic_vector(quant_width_g-1 downto 0);
    dct_ready4col_in : in  std_logic;
    wr_idct_in       : in  std_logic;
    wr_quant_in      : in  std_logic;
    debug_out        : out std_logic_vector(debug_w_g-1 downto 0)

    );

end dct_to_hibi;

architecture rtl of dct_to_hibi is

  -- How many 8x8 blocks are sent after a request
  -- (4 x luma + 2 x chroma = a 16x16 macroblock )
  constant n_blocks_per_req_c : integer := 6;

  -- Incoming value width
  constant dct_word_width_in_bus_c : integer := 16;

  -- Result value width
  constant output_word_width_c : integer := 16;

  constant rx_elements_c : integer := 8*8*n_blocks_per_req_c;

  -- How many 16-bit values in a hibi word
  constant tx_fifo_value_sel_max_c : integer := data_width_g/output_word_width_c;

  -- Because dctQidct pushes out 8 values at a time, fifo must be:
  constant tx_fifo_depth_c : integer := 8/tx_fifo_value_sel_max_c;

  -- /tx_fifo_value_sel_max_c because multiple values in a word
  constant n_values_in_block_c : integer := 8*8/tx_fifo_value_sel_max_c;

  -- Input data (received from the dct's point of view )
  signal rx_counter_r : integer range 0 to rx_elements_c-1;

  -- tx from the dct's point of view ( actually results )
  -- Signals for quant result fifo
  signal tx_q_fifo_full        : std_logic;
  signal tx_q_fifo_empty       : std_logic;
  signal tx_q_fifo_re          : std_logic;
  signal tx_q_fifo_we          : std_logic;
  signal tx_q_fifo_data_from   : std_logic_vector(data_width_g-1 downto 0);
  signal tx_q_fifo_data_to_r   : std_logic_vector(data_width_g-1 downto 0);
  signal tx_q_fifo_value_sel_r : integer range 0 to tx_fifo_value_sel_max_c-1;

  -- Signals for idct result fifo
  signal tx_i_fifo_full        : std_logic;
  signal tx_i_fifo_empty       : std_logic;
  signal tx_i_fifo_re          : std_logic;
  signal tx_i_fifo_we          : std_logic;
  signal tx_i_fifo_data_from   : std_logic_vector(data_width_g-1 downto 0);
  signal tx_i_fifo_data_to_r   : std_logic_vector(data_width_g-1 downto 0);
  signal tx_i_fifo_value_sel_r : integer range 0 to tx_fifo_value_sel_max_c-1;

  -- Signals for tx fifo (muxed to either to q or i fifo)
  signal tx_fifo_full      : std_logic;
  signal tx_fifo_empty     : std_logic;
  signal tx_fifo_re        : std_logic;
  signal tx_fifo_re_r      : std_logic;
  signal tx_fifo_data_from : std_logic_vector(data_width_g-1 downto 0);
  signal tx_data_counter_r : integer range 0 to n_values_in_block_c-1;

  -- n_blocks_per_req_c result blocks of a kind (quant and idct). Sum is 2*n_blocks_per_req_c
  constant result_block_count_c   : integer := n_blocks_per_req_c*2;
  signal   result_block_counter_r : integer range 0 to result_block_count_c-1;

  component fifo
    generic (
      data_width_g : integer;
      depth_g      : integer);
    port (
      clk       : in  std_logic;
      rst_n     : in  std_logic;
      data_in   : in  std_logic_vector (data_width_g-1 downto 0);
      we_in     : in  std_logic;
      one_p_out : out std_logic;
      full_out  : out std_logic;
      data_out  : out std_logic_vector (data_width_g-1 downto 0);
      re_in     : in  std_logic;
      empty_out : out std_logic;
      one_d_out : out std_logic);
  end component;


  -- Originally Ari's counter which tells if current block is luma or chroma.
  component cl_cnt
    generic (
      n_luma_g   : integer;
      n_chroma_g : integer);
    port (
      clk    : in  std_logic;
      rst_n  : in  std_logic;
      ena_in : in  std_logic;
      cl_out : out std_logic);
  end component;


  type main_state_type is (idle, wait_quant_addr, wait_idct_addr, wait_control, wait_data, write_data);
  type result_send_type is (idle, send_av, send_data, send_last, send_rel_av, send_rel);

  -- States (results is quant is kind of state too )
  signal main_state        : main_state_type;
  signal result_send_state : result_send_type;
  signal result_is_quant_r : std_logic;

  -- Signals related to control word
  signal control_word_r : std_logic_vector(data_width_g-1 downto 0);
  alias intra_r         : std_logic is control_word_r(5);
  alias quant_param_r   : std_logic_vector(4 downto 0) is control_word_r(4 downto 0);
  signal loadQP_r       : std_logic;

  -- Some internal hibi signals
  signal hibi_re_i   : std_logic;
  signal hibi_re_r   : std_logic;
  signal hibi_we_i   : std_logic;
  signal hibi_we_r   : std_logic;
  signal hibi_av_r   : std_logic;
  signal hibi_data_r : std_logic_vector(data_width_g-1 downto 0);

  -- Signals to handle sending self release to rtm
  signal send_release_r : std_logic;
  signal release_sent_r : std_logic;

  -- Signals releated to fifos which store the result addresses
  signal addr_fifos_re_r    : std_logic;
  signal addr_fifo_q_we     : std_logic;
  signal addr_fifo_i_we     : std_logic;
  signal addr_ret_for_quant : std_logic_vector(data_width_g-1 downto 0);
  signal addr_ret_for_idct  : std_logic_vector(data_width_g-1 downto 0);
  signal addr_ret           : std_logic_vector(data_width_g-1 downto 0);


  -- For determing if a 8x8 block has only zeros ( skip 1st value of intra block )
  signal first_of_a_block_r : std_logic;
  signal quant_or_r         : std_logic_vector(n_blocks_per_req_c-1 downto 0);
  signal intra_old_r        : std_logic;
  signal send_or_value_r    : std_logic;

  -- For signalling dctQidct if we are ready to receive results or not
  signal ready_for_q_col_r : std_logic;
  signal ready_for_i_col_r : std_logic;
  
begin  -- rtl

  -----------------------------------------------------------------------------
  
  intra_out  <= intra_r;
  QP_out     <= quant_param_r;
  loadQP_out <= loadQP_r;

  -----------------------------------------------------------------------------

  cl_cnt_1 : cl_cnt
    generic map (
      n_luma_g   => 4,
      n_chroma_g => 2)
    port map (
      clk    => clk,
      rst_n  => rst_n,
      ena_in => loadQP_r,
      cl_out => chroma_out
      );

  -----------------------------------------------------------------------------

  fifo_tx_i : fifo
    generic map (
      data_width_g => data_width_g,
      depth_g      => tx_fifo_depth_c
      )
    port map (
      clk       => clk,
      rst_n     => rst_n,
      data_in   => tx_i_fifo_data_to_r,
      we_in     => tx_i_fifo_we,
      full_out  => tx_i_fifo_full,
      data_out  => tx_i_fifo_data_from,
      re_in     => tx_i_fifo_re,
      empty_out => tx_i_fifo_empty
      );

  -----------------------------------------------------------------------------

  fifo_tx_q : fifo
    generic map (
      data_width_g => data_width_g,
      depth_g      => tx_fifo_depth_c
      )
    port map (
      clk       => clk,
      rst_n     => rst_n,
      data_in   => tx_q_fifo_data_to_r,
      we_in     => tx_q_fifo_we,
      full_out  => tx_q_fifo_full,
      data_out  => tx_q_fifo_data_from,
      re_in     => tx_q_fifo_re,
      empty_out => tx_q_fifo_empty
      );

  addr_fifo_q : fifo
    generic map (
      data_width_g => data_width_g,
      depth_g      => 2  -- two addresses in mem (new and current)
      )
    port map (
      clk      => clk,
      rst_n    => rst_n,
      data_in  => hibi_data_in,
      we_in    => addr_fifo_q_we,
--      full_out  => tx_q_fifo_full,
      data_out => addr_ret_for_quant,
      re_in    => addr_fifos_re_r
--      empty_out => tx_q_fifo_empty
      );

  addr_fifo_i : fifo
    generic map (
      data_width_g => data_width_g,
      depth_g      => 2  -- two addresses in mem (new and current)
      )
    port map (
      clk      => clk,
      rst_n    => rst_n,
      data_in  => hibi_data_in,
      we_in    => addr_fifo_i_we,
--      full_out  => tx_q_fifo_full,
      data_out => addr_ret_for_idct,
      re_in    => addr_fifos_re_r
--      empty_out => tx_q_fifo_empty
      );

  -----------------------------------------------------------------------------

  quant_ready4col_out <= ready_for_q_col_r;  --2.8.
  idct_ready4col_out  <= ready_for_i_col_r;  --2.8.

  addr_fifo_q_we <= '1' when hibi_empty_in = '0' and hibi_av_in = '0' and main_state = wait_quant_addr
                    else '0';
  addr_fifo_i_we <= '1' when hibi_empty_in = '0' and hibi_av_in = '0' and main_state = wait_idct_addr
                    else '0';

  -----------------------------------------------------------------------------

-- This process handles the incoming requests and stores the data to fifo  
-- for the dct
  main : process (clk, rst_n)
    variable value_sel_v : integer range 0 to data_width_g/dct_word_width_in_bus_c-1;
  begin  -- process main
    if rst_n = '0' then                 -- asynchronous reset (active low)
      control_word_r <= (others => '0');
      wr_dct_out     <= '0';
      hibi_re_r      <= '0';
      data_dct_out   <= (others => '0');
      loadQP_r       <= '0';
      main_state     <= idle;
      send_release_r <= '0';
      rx_counter_r   <= 0;
      
    elsif clk'event and clk = '1' then  -- rising clock edge

      loadQP_r <= '0';

      if release_sent_r = '1' then
        send_release_r <= '0';
      end if;

      case main_state is

        when idle =>
          wr_dct_out <= '0';
          hibi_re_r  <= '1';
          if hibi_empty_in = '0' and hibi_av_in = '1' then
            main_state <= wait_quant_addr;
          end if;

        when wait_quant_addr =>
          
          if hibi_empty_in = '0' and hibi_av_in = '0' then
            main_state <= wait_idct_addr;
          end if;

        when wait_idct_addr =>
          if hibi_empty_in = '0' and hibi_av_in = '0' then
            main_state <= wait_control;
          end if;

        when wait_control =>
          if hibi_empty_in = '0' and hibi_av_in = '0' then
            control_word_r <= hibi_data_in;
            hibi_re_r      <= '0';
            main_state     <= wait_data;
          end if;

        when wait_data =>
          wr_dct_out <= '0';
          hibi_re_r  <= '0';
          if dct_ready4col_in = '1' then
            main_state <= write_data;
          end if;

        when write_data =>
          wr_dct_out <= '0';
          hibi_re_r  <= '0';

          value_sel_v := rx_counter_r mod (data_width_g/dct_word_width_in_bus_c);

          if hibi_empty_in = '0' and hibi_av_in = '1' and hibi_re_r = '0' then
            hibi_re_r <= '1';
          end if;

          if hibi_empty_in = '0' and hibi_av_in = '0' and (value_sel_v /= data_width_g/dct_word_width_in_bus_c-1 or hibi_re_i = '1') then
            
            wr_dct_out <= '1';

            for i in 0 to data_width_g/dct_word_width_in_bus_c-1 loop
              if i = value_sel_v then
                data_dct_out <= hibi_data_in(i*dct_word_width_in_bus_c+dct_width_g-1 downto i*dct_word_width_in_bus_c);
              end if;
            end loop;

            if data_width_g/dct_word_width_in_bus_c = 1 then
              hibi_re_r <= '1';
            else

              if value_sel_v = data_width_g/dct_word_width_in_bus_c-1-1 then
                hibi_re_r <= '1';
              end if;
              
            end if;

            if rx_counter_r mod 8 = 7 then
              main_state <= wait_data;
            end if;

            if rx_counter_r mod 64 = 63 then
              loadQP_r <= '1';
            end if;

            if rx_counter_r = rx_elements_c-1 then
              rx_counter_r   <= 0;
              send_release_r <= '1';
              main_state     <= idle;
            else
              rx_counter_r <= rx_counter_r + 1;
            end if;

            --        else
--            hibi_re_r <= '1';
          end if;
          
      end case;
      
    end if;
  end process main;

  -----------------------------------------------------------------------------

  hibi_re_i   <= hibi_re_r and (not hibi_empty_in);
  hibi_re_out <= hibi_re_i;

  -----------------------------------------------------------------------------


  -------------------------------------------------------------------------------
  -- Process which handles the result idct data writing to corresponding tx fifo
  -------------------------------------------------------------------------------  
  output_to_fifo_i : process (clk, rst_n)
  begin  -- process dct_to_fifo
    if rst_n = '0' then                 -- asynchronous reset (active low)

      tx_i_fifo_value_sel_r <= 0;
      tx_i_fifo_data_to_r   <= (others => '0');
      tx_i_fifo_we          <= '0';

    elsif clk'event and clk = '1' then  -- rising clock edge

      tx_i_fifo_we <= '0';
      if wr_idct_in = '1' then
        
        tx_i_fifo_we <= '0';
        assert tx_i_fifo_full = '0' report "TX I FIFO FULL!" severity failure;

        for i in 0 to tx_fifo_value_sel_max_c-1 loop
          if i = tx_i_fifo_value_sel_r then
            tx_i_fifo_data_to_r((i+1)*output_word_width_c-1 downto i*output_word_width_c) <= std_logic_vector(resize(signed(data_idct_in), output_word_width_c));
          end if;
        end loop;


        if tx_i_fifo_value_sel_r = tx_fifo_value_sel_max_c-1 then
          tx_i_fifo_value_sel_r <= 0;
          tx_i_fifo_we          <= '1';
        else
          tx_i_fifo_value_sel_r <= tx_i_fifo_value_sel_r + 1;
        end if;
        
      end if;

    end if;
  end process output_to_fifo_i;

  -------------------------------------------------------------------------------
  -- Process which handles the result quant data writing to corresponding tx fifo
  -------------------------------------------------------------------------------
  output_to_fifo_q : process (clk, rst_n)
    variable intra_v : std_logic;
  begin  -- process dct_to_fifo
    if rst_n = '0' then                 -- asynchronous reset (active low)

      tx_q_fifo_value_sel_r <= 0;
      tx_q_fifo_data_to_r   <= (others => '0');
      tx_q_fifo_we          <= '0';

    elsif clk'event and clk = '1' then  -- rising clock edge

      tx_q_fifo_we <= '0';
      if wr_quant_in = '1' then
        
        tx_q_fifo_we <= '0';
        assert tx_q_fifo_full = '0' report "TX Q FIFO FULL!" severity failure;


        -- The following if statement is also in the zero check process
        if result_block_counter_r = 0 then
          intra_v := intra_r;
          -- Commented out intra_old <= intra_r assignment because
          -- it is in the zero check process
        else
          intra_v := intra_old_r;
        end if;


        for i in 0 to tx_fifo_value_sel_max_c-1 loop
          if i = tx_q_fifo_value_sel_r then
            -- Lets treat the first coeff of an intra block as a unsigned
            -- (1-254 according to the quant specs found in IQuant.vhd)
            if (first_of_a_block_r = '1' and intra_v = '1') then
              tx_q_fifo_data_to_r((i+1)*output_word_width_c-1 downto i*output_word_width_c) <= std_logic_vector(resize(unsigned(data_quant_in), output_word_width_c));
            else
              tx_q_fifo_data_to_r((i+1)*output_word_width_c-1 downto i*output_word_width_c) <= std_logic_vector(resize(signed(data_quant_in), output_word_width_c));
            end if;
          end if;
        end loop;

        if tx_q_fifo_value_sel_r = tx_fifo_value_sel_max_c-1 then
          tx_q_fifo_value_sel_r <= 0;
          tx_q_fifo_we          <= '1';
        else
          tx_q_fifo_value_sel_r <= tx_q_fifo_value_sel_r + 1;
        end if;
        
      end if;

    end if;
  end process output_to_fifo_q;


  -----------------------------------------------------------------------------
  -- Depending on the result_is_quant_r signal, tx_fifo signals are connected
  -- to either of the two transmit fifos (quant or idct)
  -----------------------------------------------------------------------------

  q_i_fifo_mux_demux : process (tx_i_fifo_full, tx_q_fifo_full, tx_q_fifo_empty, tx_i_fifo_empty, tx_fifo_re, tx_q_fifo_data_from, tx_i_fifo_data_from, result_is_quant_r, addr_ret_for_idct, addr_ret_for_quant)
  begin  -- process q_i_fifo_mux
    tx_q_fifo_re <= '0';
    tx_i_fifo_re <= '0';

    if result_is_quant_r = '1' then
      tx_q_fifo_re <= tx_fifo_re;

      tx_fifo_full      <= tx_q_fifo_full;
      tx_fifo_empty     <= tx_q_fifo_empty;
      tx_fifo_data_from <= tx_q_fifo_data_from;

      addr_ret <= addr_ret_for_quant;
    else
      tx_i_fifo_re <= tx_fifo_re;

      tx_fifo_data_from <= tx_i_fifo_data_from;
      tx_fifo_full      <= tx_i_fifo_full;
      tx_fifo_empty     <= tx_i_fifo_empty;

      addr_ret <= addr_ret_for_idct;
    end if;

  end process q_i_fifo_mux_demux;

  -----------------------------------------------------------------------------

  hibi_we_i   <= hibi_we_r and (not hibi_full_in) and ((not tx_fifo_empty) or release_sent_r or send_or_value_r);
  hibi_we_out <= hibi_we_i;

  hibi_av_out <= hibi_av_r;

  tx_fifo_re <= tx_fifo_re_r and (not hibi_full_in) and (not tx_fifo_empty);

  -- Choose hibi_data_out depending on the state and hibi_av_out (_r)
  tx_fifo_read : process (result_send_state, hibi_data_r, tx_fifo_data_from, hibi_av_r)
  begin  -- process tx_fifo_i_read
    if (result_send_state = send_data) and hibi_av_r = '0' then
      hibi_data_out <= tx_fifo_data_from;
    else
      hibi_data_out <= hibi_data_r;
    end if;
  end process tx_fifo_read;

  -----------------------------------------------------------------------------
  -- ZERO CHECK PROCESS
  -- Determine if incoming quant data has only zeros or not
  -----------------------------------------------------------------------------
  zero_check : process (clk, rst_n)
    variable intra_v : std_logic;
  begin  -- process zero_check
    if rst_n = '0' then                 -- asynchronous reset (active low)
      quant_or_r         <= (others => '0');
      first_of_a_block_r <= '1';
      intra_old_r        <= '0';
    elsif clk'event and clk = '1' then  -- rising clock edge

      intra_v := '0';

      if wr_quant_in = '1' then


        -- These same if-statements are also in quant result write process
        if result_block_counter_r = 0 then
          intra_v     := intra_r;
          intra_old_r <= intra_r;
        else
          intra_v := intra_old_r;
        end if;

        if not (first_of_a_block_r = '1' and intra_v = '1') then
          quant_or_r(0) <= quant_or_r(0) or or_reduce(data_quant_in);
        end if;

        if first_of_a_block_r = '1' then
          first_of_a_block_r <= '0';
        end if;

      end if;

      if result_send_state = send_last and result_is_quant_r = '1' then
        first_of_a_block_r <= '1';
        quant_or_r         <= quant_or_r(n_blocks_per_req_c-2 downto 0) & '0';
      end if;
      
      
    end if;
  end process zero_check;

  -----------------------------------------------------------------------------
  -- SEND RESULTS OVER HIBI 
  -----------------------------------------------------------------------------
  hibi_send_proc : process (clk, rst_n)
  begin  -- process hibi_send_proc
    if rst_n = '0' then                 -- asynchronous reset (active low)
      hibi_data_r            <= (others => '0');
      hibi_comm_out          <= std_logic_vector(to_unsigned(0, comm_width_g));
      hibi_we_r              <= '0';
      hibi_av_r              <= '0';
      tx_fifo_re_r           <= '0';
      tx_data_counter_r      <= 0;
      release_sent_r         <= '0';
      result_is_quant_r      <= '1';
      addr_fifos_re_r        <= '0';
      send_or_value_r        <= '0';
      result_send_state      <= idle;
      result_block_counter_r <= 0;
      ready_for_q_col_r      <= '1';
      ready_for_i_col_r      <= '1';
      
    elsif clk'event and clk = '1' then  -- rising clock edge

      addr_fifos_re_r <= '0';

      -- If incoming data from dctQidct, let's set the ready signals low
      if wr_quant_in = '1' then
        ready_for_q_col_r <= '0';
      end if;
      if wr_idct_in = '1' then
        ready_for_i_col_r <= '0';
      end if;


      case result_send_state is

        -- Do nothing unless there is something in transmit fifo or release is
        -- requested
        when idle =>
          if tx_fifo_empty = '0' then
            result_send_state <= send_av;
          end if;

          if send_release_r = '1' and use_self_rel_g /= 0 then
            result_send_state <= send_rel_av;
          end if;

          -- Send self release address valid (+2 for release to rtm)
        when send_rel_av =>
          release_sent_r    <= '1';
          hibi_av_r         <= '1';
          hibi_we_r         <= '1';
          hibi_comm_out     <= std_logic_vector(to_unsigned(3, comm_width_g));
          hibi_data_r       <= std_logic_vector(to_unsigned(rtm_address_g+2, data_width_g));
          result_send_state <= send_rel;

          -- Send self release data (own address)
        when send_rel =>
          if hibi_we_i = '1' then
            hibi_av_r   <= '0';
            hibi_data_r <= std_logic_vector(to_unsigned(own_address_g, data_width_g));
            if hibi_av_r = '0' then
              hibi_data_r       <= (others => '0');
              hibi_we_r         <= '0';
              hibi_comm_out     <= (others => '0');
              release_sent_r    <= '0';
              result_send_state <= idle;
            end if;
          end if;

          -- Send address valid in the beginning of every 8x8 block
        when send_av =>
          hibi_av_r     <= '1';
          hibi_we_r     <= '1';
          hibi_comm_out <= std_logic_vector(to_unsigned(2, comm_width_g));
          hibi_data_r   <= addr_ret;

          result_send_state <= send_data;
          
        when send_data =>

          -- If last sending was ok.
          if hibi_we_i = '1' then
            tx_fifo_re_r <= '1';
            hibi_av_r    <= '0';

            -- If address is sent
            if hibi_av_r = '0' then

              -- If 8x8 block sending is ready
              if tx_data_counter_r = n_values_in_block_c-1 then  -- 0..31
                tx_data_counter_r <= 0;

                -- If we are finished sending the last 8x8 block (idct in fact)
                if result_block_counter_r = result_block_count_c-1 then  --0..11
                  result_block_counter_r <= 0;
                  addr_fifos_re_r        <= '1';
                else
                  result_block_counter_r <= result_block_counter_r + 1;
                end if;

                hibi_av_r       <= '0';
                hibi_comm_out   <= (others => '0');
                hibi_we_r       <= '0';
                hibi_data_r     <= (others => '0');
                tx_fifo_re_r    <= '0';
                send_or_value_r <= '0';

                -- If we are finished sending the last QUANT block,
                -- let's send the OR-value which determines if QUANT blocks
                -- has zeros.
                if result_block_counter_r = result_block_count_c-2 then
                  hibi_we_r                                  <= '1';
                  send_or_value_r                            <= '1';
                  hibi_data_r(n_blocks_per_req_c-1 downto 0) <= quant_or_r;
                  hibi_comm_out                              <= std_logic_vector(to_unsigned(2, comm_width_g));
                end if;

                result_send_state <= send_last;

              else
                tx_data_counter_r <= tx_data_counter_r + 1;
              end if;

              -- After every 8 values, we set the ready signal back on
              if tx_data_counter_r mod (8/tx_fifo_value_sel_max_c) = (8/tx_fifo_value_sel_max_c)-1 then
                if result_is_quant_r = '1' then
                  ready_for_q_col_r <= '1';
                else
                  ready_for_i_col_r <= '1';
                end if;
              end if;
              
            end if;
            
          end if;

          -- In this state, the or word is being sent, if send_or_value_r is high.
        when send_last =>
          if send_or_value_r = '0' or hibi_we_i = '1' then
            send_or_value_r   <= '0';
            hibi_we_r         <= '0';
            hibi_data_r       <= (others => '0');
            hibi_comm_out     <= (others => '0');
            result_is_quant_r <= not result_is_quant_r;
            result_send_state <= idle;
          end if;
          
      end case;

    end if;
  end process hibi_send_proc;

end rtl;

