library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.gray_code.all;

entity cdc_fifo_ctrl is
  
  generic (
    READ_AHEAD_g  : integer := 0;
    SYNC_CLOCKS_g : integer := 0;
    depth_log2_g  : integer := 0);

  port (
    rst_n : in std_logic;

    rd_clk       : in  std_logic;
    rd_en_in     : in  std_logic;
    rd_empty_out : out std_logic;
    rd_one_d_out : out std_logic;
    rd_addr_out  : out std_logic_vector (depth_log2_g-1 downto 0);

    wr_clk       : in  std_logic;
    wr_en_in     : in  std_logic;
    wr_full_out  : out std_logic;
    wr_one_p_out : out std_logic;
    wr_addr_out  : out std_logic_vector (depth_log2_g-1 downto 0)
    );

end entity cdc_fifo_ctrl;

architecture rtl of cdc_fifo_ctrl is


--  signal wr_counter_synchronized_r : unsigned (depth_log2_g-1 downto 0);


  -- (rd_clk) registers
  signal rd_counter_r            : unsigned (depth_log2_g-1 downto 0);
  signal rd_counter_gray_r       : std_logic_vector(depth_log2_g-1 downto 0);
  signal wr_counter_gray_sync1_r : std_logic_vector (depth_log2_g-1 downto 0);
  signal wr_counter_gray_sync2_r : std_logic_vector (depth_log2_g-1 downto 0);
  signal wr_counter_gray_sync3_r : std_logic_vector (depth_log2_g-1 downto 0);
  signal rd_empty : std_logic;
  
  -- (wr_clk) registers
  signal wr_counter_r            : unsigned (depth_log2_g-1 downto 0);
  signal wr_counter_gray_r       : std_logic_vector(depth_log2_g-1 downto 0);
  signal rd_counter_gray_sync1_r : std_logic_vector (depth_log2_g-1 downto 0);
  signal rd_counter_gray_sync2_r : std_logic_vector (depth_log2_g-1 downto 0);
  signal rd_counter_gray_sync3_r : std_logic_vector (depth_log2_g-1 downto 0);

  signal rd_counter_next : unsigned (depth_log2_g-1 downto 0);
  signal wr_counter_next : unsigned (depth_log2_g-1 downto 0);

  signal wr_counter_gray_syncd : std_logic_vector(depth_log2_g-1 downto 0);
  signal rd_counter_gray_syncd : std_logic_vector(depth_log2_g-1 downto 0);
begin  -- architecture rtl

  -- concurrent assignments
  wr_addr_out <= std_logic_vector(wr_counter_r);

  --AK TESTE CAHNGED
  -- data is available at the same clock cylce as the rd_en_in = '1'
  readahead : if READ_AHEAD_g /= 0 generate
    rd_addr_out <= std_logic_vector(rd_counter_next) when (rd_en_in = '1' and rd_empty = '0') else
                   std_logic_vector(rd_counter_r);
  end generate readahead;

  -- data is available at the next clock cycle
  no_readahead : if READ_AHEAD_g = 0 generate
    rd_addr_out <= std_logic_vector(rd_counter_r);
  end generate no_readahead;


  -- purpose: counter logic for write address (binary counter + gray counter)
  -- type   : sequential
  -- inputs : wr_clk, rst_n
  -- outputs: 
  wr_counter_next <= wr_counter_r + 1;
  write_counter : process (rst_n, wr_clk) is
  begin  -- process write_counter
    if (rst_n = '0') then               -- asynchronous reset (active low)
      wr_counter_r      <= (others => '0');
      wr_counter_gray_r <= (others => '0');
      wr_counter_gray_sync1_r <= (others => '0');      
    elsif rising_edge(wr_clk) then      -- rising clock edge
      -- check also if becoming full
      if (wr_en_in = '1') then
        wr_counter_r      <= wr_counter_next;        
        wr_counter_gray_r <= gray_encode(wr_counter_next);
      end if;
      wr_counter_gray_sync1_r <= wr_counter_gray_r;
    end if;
  end process write_counter;

  -- purpose: counter logic for read address (binary counter & gray counter)
  -- type   : sequential
  -- inputs : rd_clk, rst_n
  -- outputs: 
  rd_counter_next <= rd_counter_r + 1;
  read_counter : process (rd_clk, rst_n) is
  begin  -- process read_counter
    if (rst_n = '0') then               -- asynchronous reset (active low)
      rd_counter_r      <= (others => '0');
      rd_counter_gray_r <= (others => '0');
    elsif rising_edge(rd_clk) then      -- rising clock edge
      -- check also if becoming empty
      if (rd_en_in = '1') then  --  and (not rd_counter_gray_r = wr_counter_gray_syncd)
        rd_counter_r      <= rd_counter_next;
        rd_counter_gray_r <= gray_encode(rd_counter_next);
      end if;
    end if;
  end process read_counter;


  syncd_clocks : if SYNC_CLOCKS_g /= 0 generate
    -- use only 1 synchronization register
    wr_counter_gray_syncd <= wr_counter_gray_sync1_r;
    rd_counter_gray_syncd <= rd_counter_gray_sync1_r;
  end generate syncd_clocks;

  no_syncd_clocks : if SYNC_CLOCKS_g = 0 generate
    -- use 2 synchronization registers
--    wr_counter_gray_syncd <= wr_counter_gray_sync2_r;
    rd_counter_gray_syncd <= rd_counter_gray_sync2_r;
    wr_counter_gray_syncd <= wr_counter_gray_sync3_r;
--    rd_counter_gray_syncd <= rd_counter_gray_sync3_r;
    
  end generate no_syncd_clocks;


  rd_empty_out <= rd_empty;

  -- purpose: determines whether the fifo is empty or not
  -- combinational inputs : rd_counter_r, wr_counter_sync2_r outputs:
  -- empty
  empty_logic : process (rd_counter_gray_r, wr_counter_gray_syncd,
                         rd_counter_r) is
  begin  -- process empty_logic
    if (rd_counter_gray_r = wr_counter_gray_syncd) then
      rd_empty <= '1';
    else
      rd_empty <= '0';
    end if;

    if (gray_encode(rd_counter_r+1) = wr_counter_gray_syncd) then
      rd_one_d_out <= '1';
    else
      rd_one_d_out <= '0';
    end if;    
  end process empty_logic;



  full_logic : process (rd_counter_gray_syncd, wr_counter_next) is
  begin  -- process full_logic
    if (rd_counter_gray_syncd = gray_encode(wr_counter_next)) then
      wr_full_out <= '1';
    else
      wr_full_out <= '0';
    end if;

    if rd_counter_gray_syncd = gray_encode(wr_counter_next+1) then
      wr_one_p_out <= '1';
    else
      wr_one_p_out <= '0';
    end if;
    
  end process full_logic;

-- purpose: Synchronizes write counter value to read -side clock domain.
-- type   : sequential (avoids meta-stability)
-- inputs : rd_clk, rst_n
-- outputs: 
  rd_synchronizer : process (rd_clk, rst_n) is
  begin  -- process rd_synchronizer
    if rst_n = '0' then                 -- asynchronous reset (active low)
--      wr_counter_gray_sync1_r <= (others => '0');
      wr_counter_gray_sync2_r <= (others => '0');
      wr_counter_gray_sync3_r <= (others => '0');
    elsif rising_edge(rd_clk) then      -- rising clock edge
--        wr_counter_gray_sync1_r <= wr_counter_gray_r;      
      wr_counter_gray_sync2_r <= wr_counter_gray_sync1_r;
      wr_counter_gray_sync3_r <= wr_counter_gray_sync2_r;
    end if;
  end process rd_synchronizer;

-- purpose: Synchronizes read counter value to write -side clock domain.
-- type   : sequential (avoids meta-stability)
-- inputs : wr_clk, rst_n
-- outputs: 
  wr_synchronizer : process (rst_n, wr_clk) is
  begin  -- process rd_synchronizer
    if rst_n = '0' then                 -- asynchronous reset (active low)
      rd_counter_gray_sync1_r <= (others => '0');
      rd_counter_gray_sync2_r <= (others => '0');
      rd_counter_gray_sync3_r <= (others => '0');      
    elsif rising_edge(wr_clk) then      -- rising clock edge
      rd_counter_gray_sync1_r <= rd_counter_gray_r;
      rd_counter_gray_sync2_r <= rd_counter_gray_sync1_r;
      rd_counter_gray_sync3_r <= rd_counter_gray_sync2_r;
    end if;
  end process wr_synchronizer;

end architecture rtl;
