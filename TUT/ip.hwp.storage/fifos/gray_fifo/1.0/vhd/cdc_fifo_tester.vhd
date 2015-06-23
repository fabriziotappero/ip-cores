library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cdc_fifo_tester is

  generic (
    depth_log2_g : integer := 2;
    dataw_g      : integer := 30
    );

  port (
    rd_clk, wr_clk      : in  std_logic;
    rst_n               : in  std_logic;
    pass_out, error_out : out std_logic;
    pass_count_out      : out std_logic_vector(31 downto 0));

end entity cdc_fifo_tester;

architecture rtl of cdc_fifo_tester is

  signal input_ctr_r    : unsigned(dataw_g-1 downto 0);
  signal expected_ctr_r : unsigned(dataw_g-1 downto 0);
  signal check_r        : std_logic;
  signal wr_state       : integer range 0 to 3 := 0;

  constant READ_AHEAD_co : integer := 0;

  signal wr_data_in                : std_logic_vector(dataw_g-1 downto 0);
  signal rd_data_out               : std_logic_vector(dataw_g-1 downto 0);
  signal rd_empty_out, wr_full_out : std_logic;
  signal wr_en, rd_en              : std_logic;

  signal pass_count_r : unsigned(31 downto 0);

  signal wr_empty_r  : std_logic;
  signal rd_full_r   : std_logic;
  signal wr_empty2_r : std_logic;
  signal rd_full2_r  : std_logic;

  signal re_to_fifo : std_logic;
  constant wr_wait_c : integer := 10;
  signal wr_wait_r : integer range 0 to wr_wait_c-1;
  signal we_wait_r : std_logic;
begin  -- architecture rtl

  cdc_fifo_inst : entity work.cdc_fifo
    generic map (
      READ_AHEAD_g  => READ_AHEAD_co,
      SYNC_CLOCKS_g => 0,
      depth_log2_g  => depth_log2_g,
      dataw_g       => dataw_g)
    port map (
      rst_n        => rst_n,
      rd_clk       => rd_clk,
      rd_en_in     => re_to_fifo, --rd_en,
      rd_empty_out => rd_empty_out,
      rd_data_out  => rd_data_out,
      wr_clk       => wr_clk,
      wr_en_in     => wr_en,
      wr_full_out  => wr_full_out,
      wr_data_in   => wr_data_in);

re_to_fifo <= '1';
  wr_data_in     <= std_logic_vector(input_ctr_r);
  pass_count_out <= std_logic_vector(pass_count_r);

  x : process (wr_state, wr_full_out, rd_empty_out)
  begin
    if (wr_state < 2) then
      -- write inputs as fast as possible.
      -- (i.e. write when fifo is not full)
      -- read as fast as possible.
      -- (i.e. read when fifo is not empty)
      wr_en <= not wr_full_out;
      rd_en <= not rd_empty_out;
    elsif (wr_state = 2) then
      -- write inputs "as slow as possible"!
      -- (i.e. write only when fifo is empty)
      -- read whne fifo is not empty.
--      wr_en <= wr_empty2_r;
--        wr_en <= not wr_full_out;
      wr_en <= we_wait_r;
        rd_en <= not rd_empty_out;
    else
      -- write inputs as fast as possible.
      -- (i.e. write when fifo is not full)
      -- read only when fifo is full
      wr_en <= not wr_full_out;
      rd_en <= not rd_empty_out;
      --rd_en <= rd_full2_r;
    end if;
  end process x;

  inproc : process (wr_clk, rst_n) is
  begin  -- process inproc
    if rst_n = '0' then                 -- asynchronous reset (active low)
      input_ctr_r  <= (others => '0');
      wr_state     <= 0;
      pass_out     <= '0';
      pass_count_r <= (others => '0');
      wr_empty_r   <= '0';
      wr_empty2_r  <= '0';
      wr_wait_r <= 0;
      we_wait_r <= '0';
      
    elsif rising_edge(wr_clk) then      -- rising clock edge
      wr_empty_r  <= rd_empty_out;
      wr_empty2_r <= wr_empty_r;

      if (wr_en = '1') then
        input_ctr_r <= input_ctr_r + 1;

        pass_out <= '0';
        -- change state when pass/round done
        if (input_ctr_r = 2**dataw_g - 1) then
          wr_state     <= (wr_state + 1) mod 4;
          pass_out     <= '1';
          pass_count_r <= pass_count_r + 1;
          input_ctr_r <= (others => '0');
        end if;
      end if;

      if wr_state = 2 then
        if wr_wait_r < wr_wait_c-1 then
          wr_wait_r <= wr_wait_r+1;
          we_wait_r <= '0';
        else
          we_wait_r <= '1' and (not wr_full_out);
        end if;
      else
        wr_wait_r <= 0;
      end if;
      
    end if;
  end process inproc;



  outchecker : process (rd_clk, rst_n) is
  begin  -- process outcheker
    if rst_n = '0' then                 -- asynchronous reset (active low)
      expected_ctr_r <= (others => '0');
      check_r        <= '0';
      error_out      <= '0';
      rd_full_r      <= '0';
      rd_full2_r     <= '0';
    elsif rising_edge(rd_clk) then      -- rising clock edge
      check_r    <= rd_en;
      rd_full_r  <= wr_full_out;
      rd_full2_r <= rd_full_r;
      
      if ((check_r = '1' and READ_AHEAD_co = 0) or
          (rd_en = '1' and READ_AHEAD_co /= 0)) then
        if (std_logic_vector(expected_ctr_r) /= rd_data_out) then
          assert (false) report "test failed!" severity failure;
          error_out <= '1';
        end if;
        expected_ctr_r <= expected_ctr_r + 1;
      end if;
      
    end if;
  end process outchecker;

end architecture rtl;
