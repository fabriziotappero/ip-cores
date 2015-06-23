-------------------------------------------------------------------------------
--* 
--* @short Configurable FIFO
--* 
--* @generic C_FIFO_WIDTH       RAM-With (1..xx)
--* @generic C_FIFO_SIZE_WIDTH  RAM Size = 2**C_FIFO_SIZE_WIDTH
--* @generic C_SYNC_TO          Sync FIFO Flags to read or write clock
--*
--*    @author: Daniel Köthe
--*   @version: 1.0
--* @date:      2007-11-11
--/
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;


entity fifo is
  generic (
    C_FIFO_WIDTH      : integer := 8;
    C_FIFO_SIZE_WIDTH : integer := 4;
    C_SYNC_TO         : string  := "RD");
  port (
    rst               : in  std_logic;
    -- write port
    wr_clk            : in  std_logic;
    wr_en             : in  std_logic;
    din               : in  std_logic_vector(C_FIFO_WIDTH-1 downto 0);
    -- read port
    rd_clk            : in  std_logic;
    rd_en             : in  std_logic;
    dout              : out std_logic_vector(C_FIFO_WIDTH-1 downto 0);
    -- flags    
    empty             : out std_logic;
    full              : out std_logic;
    overflow          : out std_logic;
    underflow         : out std_logic;
    prog_empty_thresh : in  std_logic_vector(C_FIFO_SIZE_WIDTH-1 downto 0);
    prog_full_thresh  : in  std_logic_vector(C_FIFO_SIZE_WIDTH-1 downto 0);
    prog_empty        : out std_logic;
    prog_full         : out std_logic);

end fifo;

architecture behavior of fifo is
  --* ram with sync write and async read
  component ram
    generic (
      C_FIFO_WIDTH      : integer := 8;
      C_FIFO_SIZE_WIDTH : integer := 4);
    port (
      clk  : in  std_logic;
      we   : in  std_logic;
      a    : in  std_logic_vector(C_FIFO_SIZE_WIDTH-1 downto 0);
      dpra : in  std_logic_vector(C_FIFO_SIZE_WIDTH-1 downto 0);
      di   : in  std_logic_vector(C_FIFO_WIDTH-1 downto 0);
      dpo  : out std_logic_vector(C_FIFO_WIDTH-1 downto 0));
  end component;

  --* component generates fifo flag
  component fifo_prog_flags
    generic (
      C_FIFO_SIZE_WIDTH : integer;
      C_SYNC_TO         : string);
    port (
      rst               : in  std_logic;
      clk               : in  std_logic;
      cnt_grey          : in  std_logic_vector(C_FIFO_SIZE_WIDTH-1 downto 0);
      cnt               : in  std_logic_vector(C_FIFO_SIZE_WIDTH-1 downto 0);
      prog_full_thresh  : in  std_logic_vector(C_FIFO_SIZE_WIDTH-1 downto 0);
      prog_empty_thresh : in  std_logic_vector(C_FIFO_SIZE_WIDTH-1 downto 0);
      prog_empty        : out std_logic;
      prog_full         : out std_logic);
  end component;

  --* logic coded gray counter
  component gray_adder
    generic (
      width : integer);
    port (
      in_gray  : in  std_logic_vector(width-1 downto 0);
      out_gray : out std_logic_vector(width-1 downto 0));
  end component;

  signal wr_cnt_gray_add_one      : std_logic_vector(C_FIFO_SIZE_WIDTH-1 downto 0);
  signal wr_cnt_next_grey_add_one : std_logic_vector(C_FIFO_SIZE_WIDTH-1 downto 0);
  signal rd_cnt_grey_add_one      : std_logic_vector(C_FIFO_SIZE_WIDTH-1 downto 0);

  attribute fsm_extract                : string;
  -- wr_clock domain
  -- main wr grey code counter
  signal wr_cnt_grey                   : std_logic_vector(C_FIFO_SIZE_WIDTH-1 downto 0);
  attribute fsm_extract of wr_cnt_grey : signal is "no";

  -- main grey code counter for full
  signal wr_cnt_next_grey                   : std_logic_vector(C_FIFO_SIZE_WIDTH-1 downto 0);
  attribute fsm_extract of wr_cnt_next_grey : signal is "no";

  -- rd_clk domain
  -- main rd grey code counter
  signal rd_cnt_grey                   : std_logic_vector(C_FIFO_SIZE_WIDTH-1 downto 0);
  attribute fsm_extract of rd_cnt_grey : signal is "no";

  -- binary counter for prog full/empty
  signal rd_cnt : std_logic_vector(C_FIFO_SIZE_WIDTH-1 downto 0);
  signal wr_cnt : std_logic_vector(C_FIFO_SIZE_WIDTH-1 downto 0);

  signal empty_int : std_logic;
  signal full_int  : std_logic;

begin  -- behavior

  empty <= empty_int;
  full  <= full_int;

--* write counter generation
  fifo_write_proc: process(rst, wr_clk)
  begin
    if (rst = '1') then
      wr_cnt_grey                                    <= (others => '0');
      wr_cnt                                         <= (others => '0');
      wr_cnt_next_grey(C_FIFO_SIZE_WIDTH-1 downto 1) <= (others => '0');
      wr_cnt_next_grey(0)                            <= '1';
    elsif rising_edge(wr_clk) then
      if (wr_en = '1') then
        wr_cnt <= wr_cnt+1;

        -- wr_cnt_grey      <= add_grey_rom(conv_integer(wr_cnt_grey));
        wr_cnt_grey <= wr_cnt_gray_add_one;

        -- wr_cnt_next_grey <= add_grey_rom(conv_integer(wr_cnt_next_grey));
        wr_cnt_next_grey <= wr_cnt_next_grey_add_one;
        
      end if;
    end if;
  end process fifo_write_proc;

  --* add one to wr_cnt_gray
  gray_adder_1 : gray_adder
    generic map (
      width => C_FIFO_SIZE_WIDTH)
    port map (
      in_gray  => wr_cnt_grey,
      out_gray => wr_cnt_gray_add_one);

  --* add one to wr_cnt_next_grey
  gray_adder_2 : gray_adder
    generic map (
      width => C_FIFO_SIZE_WIDTH)
    port map (
      in_gray  => wr_cnt_next_grey,
      out_gray => wr_cnt_next_grey_add_one);    


--* read counter generation
  fifo_read_proc: process(rst, rd_clk)
  begin
    if (rst = '1') then
      rd_cnt_grey <= (others => '0');
      rd_cnt      <= (others => '0');
    elsif rising_edge(rd_clk) then
      -- rd grey code counter
      if (rd_en = '1') then
        -- rd_cnt_grey <= add_grey_rom(conv_integer(rd_cnt_grey));
        rd_cnt_grey <= rd_cnt_grey_add_one;
        rd_cnt      <= rd_cnt+1;
      end if;
    end if;
  end process fifo_read_proc;

  --* add one to rd_cnt_grey 
  gray_adder_3 : gray_adder
    generic map (
      width => C_FIFO_SIZE_WIDTH)
    port map (
      in_gray  => rd_cnt_grey,
      out_gray => rd_cnt_grey_add_one);    


  --* FIFO Memory
  ram_1 : ram
    generic map (
      C_FIFO_WIDTH      => C_FIFO_WIDTH,
      C_FIFO_SIZE_WIDTH => C_FIFO_SIZE_WIDTH)
    port map (
      clk  => wr_clk,
      we   => wr_en,
      a    => wr_cnt_grey,
      di   => din,
      dpra => rd_cnt_grey,
      dpo  => dout);


  --* generate overflow
  gen_of_proc: process(rst, wr_clk)
  begin
    if (rst = '1') then
      overflow <= '0';
    elsif rising_edge(wr_clk) then
      if (full_int = '1' and wr_en = '1') then
        overflow <= '1';
      end if;
    end if;
  end process gen_of_proc;

  --* generate underflow
  gen_uf_proc: process(rst, rd_clk)
  begin
    if (rst = '1') then
      underflow <= '0';
    elsif rising_edge(rd_clk) then
      if (empty_int = '1' and rd_en = '1') then
        underflow <= '1';
      end if;
    end if;
  end process gen_uf_proc;

  -- generate empty
  empty_int <= '1' when (wr_cnt_grey = rd_cnt_grey) else
               '0';

  -- generate full
  full_int <= '1' when (wr_cnt_next_grey = rd_cnt_grey) else
              '0';

  --* select clock side for flags
  u1 : if (C_SYNC_TO = "WR") generate
  --* sync flags to write clock
    fifo_prog_flags_1 : fifo_prog_flags
      generic map (
        C_FIFO_SIZE_WIDTH => C_FIFO_SIZE_WIDTH,
        C_SYNC_TO         => C_SYNC_TO)
      port map (
        rst               => rst,
        clk               => wr_clk,
        cnt_grey          => rd_cnt_grey,
        cnt               => wr_cnt,
        prog_full_thresh  => prog_full_thresh,
        prog_empty_thresh => prog_empty_thresh,
        prog_empty        => prog_empty,
        prog_full         => prog_full);
  end generate u1;

  u2 : if (C_SYNC_TO = "RD") generate
  --* sync flags to read clock
    fifo_prog_flags_1 : fifo_prog_flags
      generic map (
        C_FIFO_SIZE_WIDTH => C_FIFO_SIZE_WIDTH,
        C_SYNC_TO         => C_SYNC_TO)
      port map (
        rst               => rst,
        clk               => rd_clk,
        cnt_grey          => wr_cnt_grey,
        cnt               => rd_cnt,
        prog_full_thresh  => prog_full_thresh,
        prog_empty_thresh => prog_empty_thresh,
        prog_empty        => prog_empty,
        prog_full         => prog_full);    
  end generate u2;
end behavior;
