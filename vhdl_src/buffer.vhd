library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL; 
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity CacheSystem is
  generic (
	DATA_WIDTH : integer := 8;
	WINDOW_SIZE : integer := 9;
	ROW_BITS : integer := 9;
	COL_BITS : integer := 10;
	NO_OF_ROWS : integer := 480;
	NO_OF_COLS : integer := 640
	);
  port(
	clk : in std_logic;
	fsync_in : in std_logic;
	pdata_in : in std_logic_vector(DATA_WIDTH -1 downto 0);
	--fsync_out : out std_logic;
	pdata_out1 : out std_logic_vector(DATA_WIDTH -1 downto 0);--primo pixel a sx
	pdata_out2 : out std_logic_vector(DATA_WIDTH -1 downto 0);
	pdata_out3 : out std_logic_vector(DATA_WIDTH -1 downto 0);
	pdata_out4 : out std_logic_vector(DATA_WIDTH -1 downto 0);
	pdata_out5 : out std_logic_vector(DATA_WIDTH -1 downto 0);
	pdata_out6 : out std_logic_vector(DATA_WIDTH -1 downto 0);
	pdata_out7 : out std_logic_vector(DATA_WIDTH -1 downto 0);
	pdata_out8 : out std_logic_vector(DATA_WIDTH -1 downto 0);
	pdata_out9 : out std_logic_vector(DATA_WIDTH -1 downto 0) -- ultimo px a destra 
	);
  end CacheSystem;
  
 
architecture CacheSystem of CacheSystem is

signal cache1 : std_logic_vector((WINDOW_SIZE*DATA_WIDTH) -1 downto 0);

begin
--
-- fsync_out <= fsync_temp;
-- fsync_buffer <= fsync_in OR fsync_temp;
--
-- fsync_delayer : process (clk)
-- begin
--	if rising_edge(clk) then
--	  fsync_store <= fsync_store(LATENCY-2 downto 0) & fsync_in;
--	  fsync_temp <= fsync_store(LATENCY-1);
--	end if;
-- end process fsync_delayer;

-- update_reg : process (clk)
-- begin 
--   if rising_edge(clk) then
--	    RowsCounter_r <= RowsCounter_x;
--     ColsCounter_r <= ColsCounter_x;
--	  end if;
-- end process update_reg;
--  
-- counter : process (clk, fsync_temp)
-- begin
--   --RowsCounter_x <= RowsCounter_r;
--   --ColsCounter_x <= ColsCounter_r;
--	  if(fsync_temp = '0') then
--	    RowsCounter_x <= (others => '0');
--	    ColsCounter_x <= (others => '0');
--	  elsif(clk'event and clk = '1') then
--	    if ColsCounter_r /= std_logic_vector(to_unsigned(NO_OF_COLS-1, COL_BITS)) then
--	      ColsCounter_x <= ColsCounter_r + 1;
--	    else
--	      RowsCounter_x <= RowsCounter_r + 1;
--		   ColsCounter_x <= (others => '0');
--	    end if;
--   end if;
-- end process counter;
  
  ShiftingProcess : process (clk, fsync_in)  
  begin

	if rising_edge(clk) then
	if fsync_in = '1' then
	  cache1(((WINDOW_SIZE-1)*DATA_WIDTH-1) downto 0) <= cache1(((WINDOW_SIZE-0)*DATA_WIDTH-1) downto (DATA_WIDTH));
	  cache1(((WINDOW_SIZE-0)*DATA_WIDTH-1) downto ((WINDOW_SIZE-1)*DATA_WIDTH)) <= pdata_in;
	end if; -- clk
	end if;
  end process ShiftingProcess;
  
  EmittingProcess : process (clk)  
  begin
    if rising_edge(clk) then
  
    if fsync_in = '1' then
--	  
--	  -- 1 top left
--	  if ColsCounter_r = "0000000000" OR ColsCounter_r = std_logic_vector(to_unsigned(NO_OF_COLS-1, COL_BITS)) then 
--	    pdata_out9 <= cache1(((WINDOW_SIZE-0)*DATA_WIDTH - 1) downto ((WINDOW_SIZE-1)*DATA_WIDTH));
--		 pdata_out8 <= cache1(((WINDOW_SIZE-1)*DATA_WIDTH - 1) downto ((WINDOW_SIZE-2)*DATA_WIDTH));
--		 pdata_out7 <= cache1(((WINDOW_SIZE-2)*DATA_WIDTH - 1) downto ((WINDOW_SIZE-3)*DATA_WIDTH));
--     pdata_out6 <= cache1(((WINDOW_SIZE-3)*DATA_WIDTH - 1) downto ((WINDOW_SIZE-4)*DATA_WIDTH));
--		 pdata_out5 <= cache1(((WINDOW_SIZE-4)*DATA_WIDTH - 1) downto ((WINDOW_SIZE-5)*DATA_WIDTH));
--		 pdata_out4 <= cache1(((WINDOW_SIZE-4)*DATA_WIDTH - 1) downto ((WINDOW_SIZE-5)*DATA_WIDTH));
--		 pdata_out3 <= cache1(((WINDOW_SIZE-4)*DATA_WIDTH - 1) downto ((WINDOW_SIZE-5)*DATA_WIDTH));
--		 pdata_out2 <= cache1(((WINDOW_SIZE-4)*DATA_WIDTH - 1) downto ((WINDOW_SIZE-5)*DATA_WIDTH));
--		 pdata_out1 <= cache1(((WINDOW_SIZE-4)*DATA_WIDTH - 1) downto ((WINDOW_SIZE-5)*DATA_WIDTH));
--		
--	  elsif ColsCounter_r = "0000000001" OR ColsCounter_r = std_logic_vector(to_unsigned(NO_OF_COLS-2, COL_BITS)) then 
--	    pdata_out9 <= cache1(((WINDOW_SIZE-0)*DATA_WIDTH - 1) downto ((WINDOW_SIZE-1)*DATA_WIDTH));
--		 pdata_out8 <= cache1(((WINDOW_SIZE-1)*DATA_WIDTH - 1) downto ((WINDOW_SIZE-2)*DATA_WIDTH));
--		 pdata_out7 <= cache1(((WINDOW_SIZE-2)*DATA_WIDTH - 1) downto ((WINDOW_SIZE-3)*DATA_WIDTH));
--     pdata_out6 <= cache1(((WINDOW_SIZE-3)*DATA_WIDTH - 1) downto ((WINDOW_SIZE-4)*DATA_WIDTH));
--		 pdata_out5 <= cache1(((WINDOW_SIZE-4)*DATA_WIDTH - 1) downto ((WINDOW_SIZE-5)*DATA_WIDTH));
--		 pdata_out4 <= cache1(((WINDOW_SIZE-5)*DATA_WIDTH - 1) downto ((WINDOW_SIZE-6)*DATA_WIDTH));
--		 pdata_out3 <= cache1(((WINDOW_SIZE-4)*DATA_WIDTH - 1) downto ((WINDOW_SIZE-5)*DATA_WIDTH));
--		 pdata_out2 <= cache1(((WINDOW_SIZE-4)*DATA_WIDTH - 1) downto ((WINDOW_SIZE-5)*DATA_WIDTH));
--		 pdata_out1 <= cache1(((WINDOW_SIZE-4)*DATA_WIDTH - 1) downto ((WINDOW_SIZE-5)*DATA_WIDTH));
--		
--	  elsif ColsCounter_r = "0000000010" OR ColsCounter_r = std_logic_vector(to_unsigned(NO_OF_COLS-3, COL_BITS)) then  
--	    pdata_out9 <= cache1(((WINDOW_SIZE-0)*DATA_WIDTH - 1) downto ((WINDOW_SIZE-1)*DATA_WIDTH));
--		 pdata_out8 <= cache1(((WINDOW_SIZE-1)*DATA_WIDTH - 1) downto ((WINDOW_SIZE-2)*DATA_WIDTH));
--		 pdata_out7 <= cache1(((WINDOW_SIZE-2)*DATA_WIDTH - 1) downto ((WINDOW_SIZE-3)*DATA_WIDTH));
--     pdata_out6 <= cache1(((WINDOW_SIZE-3)*DATA_WIDTH - 1) downto ((WINDOW_SIZE-4)*DATA_WIDTH));
--		 pdata_out5 <= cache1(((WINDOW_SIZE-4)*DATA_WIDTH - 1) downto ((WINDOW_SIZE-5)*DATA_WIDTH));
--		 pdata_out4 <= cache1(((WINDOW_SIZE-5)*DATA_WIDTH - 1) downto ((WINDOW_SIZE-6)*DATA_WIDTH));
--		 pdata_out3 <= cache1(((WINDOW_SIZE-6)*DATA_WIDTH - 1) downto ((WINDOW_SIZE-7)*DATA_WIDTH));
--		 pdata_out2 <= cache1(((WINDOW_SIZE-4)*DATA_WIDTH - 1) downto ((WINDOW_SIZE-5)*DATA_WIDTH));
--		 pdata_out1 <= cache1(((WINDOW_SIZE-4)*DATA_WIDTH - 1) downto ((WINDOW_SIZE-5)*DATA_WIDTH));
--		
--	  elsif ColsCounter_r = "0000000011" OR ColsCounter_r = std_logic_vector(to_unsigned(NO_OF_COLS-4, COL_BITS)) then 
--	    pdata_out9 <= cache1(((WINDOW_SIZE-0)*DATA_WIDTH - 1) downto ((WINDOW_SIZE-1)*DATA_WIDTH));
--		 pdata_out8 <= cache1(((WINDOW_SIZE-1)*DATA_WIDTH - 1) downto ((WINDOW_SIZE-2)*DATA_WIDTH));
--		 pdata_out7 <= cache1(((WINDOW_SIZE-2)*DATA_WIDTH - 1) downto ((WINDOW_SIZE-3)*DATA_WIDTH));
--     pdata_out6 <= cache1(((WINDOW_SIZE-3)*DATA_WIDTH - 1) downto ((WINDOW_SIZE-4)*DATA_WIDTH));
--		 pdata_out5 <= cache1(((WINDOW_SIZE-4)*DATA_WIDTH - 1) downto ((WINDOW_SIZE-5)*DATA_WIDTH));
--		 pdata_out4 <= cache1(((WINDOW_SIZE-5)*DATA_WIDTH - 1) downto ((WINDOW_SIZE-6)*DATA_WIDTH));
--		 pdata_out3 <= cache1(((WINDOW_SIZE-6)*DATA_WIDTH - 1) downto ((WINDOW_SIZE-7)*DATA_WIDTH));
--		 pdata_out2 <= cache1(((WINDOW_SIZE-7)*DATA_WIDTH - 1) downto ((WINDOW_SIZE-8)*DATA_WIDTH));
--		 pdata_out1 <= cache1(((WINDOW_SIZE-4)*DATA_WIDTH - 1) downto ((WINDOW_SIZE-5)*DATA_WIDTH));
--
--	  else
	    pdata_out9 <= cache1(((WINDOW_SIZE-0)*DATA_WIDTH - 1) downto ((WINDOW_SIZE-1)*DATA_WIDTH));
		 pdata_out8 <= cache1(((WINDOW_SIZE-1)*DATA_WIDTH - 1) downto ((WINDOW_SIZE-2)*DATA_WIDTH));
		 pdata_out7 <= cache1(((WINDOW_SIZE-2)*DATA_WIDTH - 1) downto ((WINDOW_SIZE-3)*DATA_WIDTH));
       pdata_out6 <= cache1(((WINDOW_SIZE-3)*DATA_WIDTH - 1) downto ((WINDOW_SIZE-4)*DATA_WIDTH));
		 pdata_out5 <= cache1(((WINDOW_SIZE-4)*DATA_WIDTH - 1) downto ((WINDOW_SIZE-5)*DATA_WIDTH));
		 pdata_out4 <= cache1(((WINDOW_SIZE-5)*DATA_WIDTH - 1) downto ((WINDOW_SIZE-6)*DATA_WIDTH));
		 pdata_out3 <= cache1(((WINDOW_SIZE-6)*DATA_WIDTH - 1) downto ((WINDOW_SIZE-7)*DATA_WIDTH));
		 pdata_out2 <= cache1(((WINDOW_SIZE-7)*DATA_WIDTH - 1) downto ((WINDOW_SIZE-8)*DATA_WIDTH));
		 pdata_out1 <= cache1(((WINDOW_SIZE-8)*DATA_WIDTH - 1) downto ((WINDOW_SIZE-9)*DATA_WIDTH));
	  end if;
--		
--	  end if; -- RowsCounter_r and ColsCounter_r
--	else
--	  pdata_out1 <= (others =>'0');
--	  pdata_out2 <= (others =>'0');
--	  pdata_out3 <= (others =>'0');
--	  pdata_out4 <= (others =>'0');
--	  pdata_out5 <= (others =>'0');
--	  pdata_out6 <= (others =>'0');
--	  pdata_out7 <= (others =>'0');
--	  pdata_out8 <= (others =>'0');
--	  pdata_out9 <= (others =>'0');
--	end if; --rsync_temp
	end if; -- clk
  end process EmittingProcess;
end CacheSystem;		
		