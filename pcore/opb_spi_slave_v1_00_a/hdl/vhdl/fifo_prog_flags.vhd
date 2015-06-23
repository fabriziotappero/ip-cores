-------------------------------------------------------------------------------
--* 
--* @short Generate fifo flags
--* 
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


entity fifo_prog_flags is
  generic (
    C_FIFO_SIZE_WIDTH : integer := 4;
    C_SYNC_TO         : string  := "WR");
  port (
    rst               : in  std_logic;
    clk               : in  std_logic;
    cnt_grey          : in  std_logic_vector(C_FIFO_SIZE_WIDTH-1 downto 0);
    cnt               : in  std_logic_vector(C_FIFO_SIZE_WIDTH-1 downto 0);
    prog_full_thresh  : in  std_logic_vector(C_FIFO_SIZE_WIDTH-1 downto 0);
    prog_empty_thresh : in  std_logic_vector(C_FIFO_SIZE_WIDTH-1 downto 0);
    prog_empty        : out std_logic;
    prog_full         : out std_logic);

end fifo_prog_flags;
architecture behavior of fifo_prog_flags is

  -- sync register for clock domain transfer
  signal cnt_grey_reg : std_logic_vector(C_FIFO_SIZE_WIDTH-1 downto 0);

  type rom_t is array (0 to (2**C_FIFO_SIZE_WIDTH)-1) of std_logic_vector(C_FIFO_SIZE_WIDTH-1 downto 0);

  --* convert from gray to binary
  component gray2bin
    generic (
      width : integer);
    port (
      in_gray : in  std_logic_vector(width-1 downto 0);
      out_bin : out std_logic_vector(width-1 downto 0));
  end component;

  signal cnt_bin_reg : std_logic_vector(C_FIFO_SIZE_WIDTH-1 downto 0);
  
begin  -- behavior

  --* Generate fifo flags
  gen_flags_proc: process(rst, clk)
    variable diff : std_logic_vector(C_FIFO_SIZE_WIDTH-1 downto 0);
  begin
    if (rst = '1') then
      cnt_grey_reg <= (others => '0');
      prog_empty   <= '1';
      prog_full    <= '0';
    elsif rising_edge(clk) then
      -- transfer to rd_clk domain
      cnt_grey_reg <= cnt_grey;
      -- fifo prog full/empty
      if (C_SYNC_TO = "RD") then
        -- diff := conv_grey_rom(conv_integer(cnt_grey_reg))- cnt;
        diff := cnt_bin_reg - cnt;
      else
        -- diff := cnt - conv_grey_rom(conv_integer(cnt_grey_reg));
        diff := cnt - cnt_bin_reg;
      end if;

      if (diff > prog_full_thresh) then
        prog_full <= '1';
      else
        prog_full <= '0';
      end if;

      if (diff < prog_empty_thresh) then
        prog_empty <= '1';
      else
        prog_empty <= '0';
      end if;
    end if;
  end process gen_flags_proc;

  --* convert gray to bin 
  gray2bin_1: gray2bin
    generic map (
      width => C_FIFO_SIZE_WIDTH)
    port map (
      in_gray => cnt_grey_reg,
      out_bin => cnt_bin_reg);

end behavior;
