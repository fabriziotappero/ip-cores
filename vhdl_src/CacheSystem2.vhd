library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL; 
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity CacheSystem2 is
  generic (
	DATA_WIDTH : integer := 8;
	WINDOW_SIZE : integer := 3;
	ROW_BITS : integer := 9;
	COL_BITS : integer := 10;
	NO_OF_ROWS : integer := 480;
	NO_OF_COLS : integer := 640
	);
  port(
	clk : in std_logic;
	fsync_in : in std_logic;
	Xdata_in : in std_logic_vector(DATA_WIDTH -1 downto 0);
	Ydata_in : in std_logic_vector(DATA_WIDTH -1 downto 0);
	--fsync_out : out std_logic;
	pdata_out1x : out std_logic_vector(DATA_WIDTH -1 downto 0);
	pdata_out2x : out std_logic_vector(DATA_WIDTH -1 downto 0);
	pdata_out3x : out std_logic_vector(DATA_WIDTH -1 downto 0);
	pdata_out4x : out std_logic_vector(DATA_WIDTH -1 downto 0);
	pdata_out5x : out std_logic_vector(DATA_WIDTH -1 downto 0);
	pdata_out6x : out std_logic_vector(DATA_WIDTH -1 downto 0);
	pdata_out7x : out std_logic_vector(DATA_WIDTH -1 downto 0);
	pdata_out8x : out std_logic_vector(DATA_WIDTH -1 downto 0);
	pdata_out9x : out std_logic_vector(DATA_WIDTH -1 downto 0);
	--
	pdata_out1y : out std_logic_vector(DATA_WIDTH -1 downto 0);
	pdata_out2y : out std_logic_vector(DATA_WIDTH -1 downto 0);
	pdata_out3y : out std_logic_vector(DATA_WIDTH -1 downto 0);
	pdata_out4y : out std_logic_vector(DATA_WIDTH -1 downto 0);
	pdata_out5y : out std_logic_vector(DATA_WIDTH -1 downto 0);
	pdata_out6y : out std_logic_vector(DATA_WIDTH -1 downto 0);
	pdata_out7y : out std_logic_vector(DATA_WIDTH -1 downto 0);
	pdata_out8y : out std_logic_vector(DATA_WIDTH -1 downto 0);
	pdata_out9y : out std_logic_vector(DATA_WIDTH -1 downto 0)
	);
  end CacheSystem2;
  
 
architecture CacheSystem2 of CacheSystem2 is

--COMPONENT Counter is
--  generic (
--    n : POSITIVE
--	);
--  port ( 
--    clk : in STD_LOGIC;
--	en : in STD_LOGIC;
--	reset : in STD_LOGIC; -- Active Low
--	output : out STD_LOGIC_VECTOR(n-1 downto 0)
--	);
--end COMPONENT;

COMPONENT nineFiFOLineBuffer is
  generic (
	DATA_WIDTH : integer := DATA_WIDTH;
	NO_OF_COLS : integer := 640 
	);
  port(
	clk : in std_logic;
	fsync : in std_logic;
	pdata_in : in std_logic_vector(DATA_WIDTH -1 downto 0);
	pdata_out1 : out std_logic_vector(DATA_WIDTH -1 downto 0);
	pdata_out2 : buffer std_logic_vector(DATA_WIDTH -1 downto 0);
	pdata_out3 : buffer std_logic_vector(DATA_WIDTH -1 downto 0);
	pdata_out4 : buffer std_logic_vector(DATA_WIDTH -1 downto 0);
	pdata_out5 : buffer std_logic_vector(DATA_WIDTH -1 downto 0);
	pdata_out6 : buffer std_logic_vector(DATA_WIDTH -1 downto 0);
	pdata_out7 : buffer std_logic_vector(DATA_WIDTH -1 downto 0);
	pdata_out8 : buffer std_logic_vector(DATA_WIDTH -1 downto 0);
	pdata_out9 : buffer std_logic_vector(DATA_WIDTH -1 downto 0)
	);
end COMPONENT;

--COMPONENT SyncSignalsDelayer
--  generic (
--	ROW_BITS : integer := 9;
--	COL_BITS : integer := 10;
--	NO_OF_ROWS : integer := 480;
--	NO_OF_COLS : integer := 640
--	);
--  port(
--	clk : IN std_logic;
--	fsync_in : IN std_logic;
--	fsync_out : OUT std_logic
--	);
--end COMPONENT;

--signal RowsCounter_r, RowsCounter_x : STD_LOGIC_VECTOR(ROW_BITS-1 downto 0);
--signal ColsCounter_r, ColsCounter_x : STD_LOGIC_VECTOR(COL_BITS-1 downto 0);
--
signal dout1x : std_logic_vector(DATA_WIDTH -1 downto 0);
signal dout2x : std_logic_vector(DATA_WIDTH -1 downto 0);
signal dout3x : std_logic_vector(DATA_WIDTH -1 downto 0);
signal dout4x : std_logic_vector(DATA_WIDTH -1 downto 0);
signal dout5x : std_logic_vector(DATA_WIDTH -1 downto 0);
signal dout6x : std_logic_vector(DATA_WIDTH -1 downto 0);
signal dout7x : std_logic_vector(DATA_WIDTH -1 downto 0);
signal dout8x : std_logic_vector(DATA_WIDTH -1 downto 0);
signal dout9x : std_logic_vector(DATA_WIDTH -1 downto 0);
--
signal dout1y : std_logic_vector(DATA_WIDTH -1 downto 0);
signal dout2y : std_logic_vector(DATA_WIDTH -1 downto 0);
signal dout3y : std_logic_vector(DATA_WIDTH -1 downto 0);
signal dout4y : std_logic_vector(DATA_WIDTH -1 downto 0);
signal dout5y : std_logic_vector(DATA_WIDTH -1 downto 0);
signal dout6y : std_logic_vector(DATA_WIDTH -1 downto 0);
signal dout7y : std_logic_vector(DATA_WIDTH -1 downto 0);
signal dout8y : std_logic_vector(DATA_WIDTH -1 downto 0);
signal dout9y : std_logic_vector(DATA_WIDTH -1 downto 0);
--
--signal fsync_temp : std_logic;
--
--constant LATENCY : integer := NO_OF_COLS*4;
--signal fsync_store : std_logic_vector(LATENCY - 1 downto 0); -- clock cycles delay to compensate for latency


begin

  --fsync_out <= fsync_temp;
  
--  fsync_delayer : FIFOLineBuffer
--	generic map (
--	  DATA_WIDTH => 1,
--	  NO_OF_COLS => NO_OF_COLS*4
--	  )
--	port map(
--	  clk => clk,
--	  fsync => fsync_buffer,
--	  pdata_in(0) => fsync_in,
--      pdata_out(0) => fsync_temp
--	  );

--  fsync_delayer : process (clk)
--  begin
--	if rising_edge(clk) then
--	  fsync_store <= fsync_store(LATENCY-2 downto 0) & fsync_in;
--	  fsync_temp <= fsync_store(LATENCY-1);
--	end if;
--  end process fsync_delayer;
--  
--  fsync_buffer <= fsync_in OR fsync_temp;

  nineLineBufferX: nineFiFOLineBuffer
	generic map (
	  DATA_WIDTH => DATA_WIDTH,
	  NO_OF_COLS => NO_OF_COLS
	  )
	port map (
	  clk => clk,
	  fsync => fsync_in,
	  pdata_in => xdata_in,
	  pdata_out1 => dout1x,
	  pdata_out2 => dout2x,
	  pdata_out3 => dout3x,
	  pdata_out4 => dout4x,
	  pdata_out5 => dout5x,
	  pdata_out6 => dout6x,
	  pdata_out7 => dout7x,
	  pdata_out8 => dout8x,
	  pdata_out9 => dout9x	  
	  );
	  
  nineLineBufferY: nineFiFOLineBuffer
	generic map (
	  DATA_WIDTH => DATA_WIDTH,
	  NO_OF_COLS => NO_OF_COLS
	  )
	port map (
	  clk => clk,
	  fsync => fsync_in,
	  pdata_in => ydata_in,
	  pdata_out1 => dout1y,
	  pdata_out2 => dout2y,
	  pdata_out3 => dout3y,
	  pdata_out4 => dout4y,
	  pdata_out5 => dout5y,
	  pdata_out6 => dout6y,
	  pdata_out7 => dout7y,
	  pdata_out8 => dout8y,
	  pdata_out9 => dout9y	  
	  );
	  
--  update_reg : process (clk)
--  begin 
--    if rising_edge(clk) then
--	  RowsCounter_r <= RowsCounter_x;
--      ColsCounter_r <= ColsCounter_x;
--	end if;
--  end process update_reg;
--  
--  counter : process (clk, fsync_temp)
--  begin
--    --RowsCounter_x <= RowsCounter_r;
--    --ColsCounter_x <= ColsCounter_r;
--	if(clk'event and clk = '1') then
--	  if(fsync_temp = '0') then
--	    RowsCounter_x <= (others => '0');
--	    ColsCounter_x <= (others => '0');
--	  elsif ColsCounter_r /= std_logic_vector(to_unsigned(NO_OF_COLS-1, COL_BITS)) then
--	    ColsCounter_x <= ColsCounter_r + 1;
--	  else
--	    RowsCounter_x <= RowsCounter_r + 1;
--		ColsCounter_x <= (others => '0');
--	  end if;
--    end if;
--  end process counter;
 
  
  EmittingProcess : process (clk)  
  begin

    if rising_edge(clk) then  
	if fsync_in = '1' then  


--	  if RowsCounter_r = "0000000000" OR RowsCounter_r = std_logic_vector(to_unsigned(NO_OF_ROWS-1, ROW_BITS)) then 
--	    pdata_out1x <= dout5x;
--		pdata_out2x <= dout5x;
--		pdata_out3x <= dout5x;
--        pdata_out4x <= dout5x;
--		pdata_out5x <= dout5x;
--		pdata_out6x <= dout4x;
--		pdata_out7x <= dout3x;
--		pdata_out8x <= dout2x;
--		pdata_out9x <= dout1x;	  
--	    --
--	    pdata_out1y <= dout5y;
--		pdata_out2y <= dout5y;
--		pdata_out3y <= dout5y;
--        pdata_out4y <= dout5y;
--		pdata_out5y <= dout5y;
--		pdata_out6y <= dout4y;
--		pdata_out7y <= dout3y;
--		pdata_out8y <= dout2y;
--		pdata_out9y <= dout1y;	
--		
--	  elsif RowsCounter_r = "0000000001" OR RowsCounter_r = std_logic_vector(to_unsigned(NO_OF_ROWS-2, ROW_BITS)) then 
--	    pdata_out1x <= dout6x;
--		pdata_out2x <= dout6x;
--		pdata_out3x <= dout6x;
--        pdata_out4x <= dout6x;
--		pdata_out5x <= dout5x;
--		pdata_out6x <= dout4x;
--		pdata_out7x <= dout3x;
--		pdata_out8x <= dout2x;
--		pdata_out9x <= dout1x;	  
--	    --
--	    pdata_out1y <= dout6y;
--		pdata_out2y <= dout6y;
--		pdata_out3y <= dout6y;
--        pdata_out4y <= dout6y;
--		pdata_out5y <= dout5y;
--		pdata_out6y <= dout4y;
--		pdata_out7y <= dout3y;
--		pdata_out8y <= dout2y;
--		pdata_out9y <= dout1y;	
--		
--	  elsif RowsCounter_r = "0000000010" OR RowsCounter_r = std_logic_vector(to_unsigned(NO_OF_ROWS-3, ROW_BITS)) then 
--	    pdata_out1x <= dout7x;
--		pdata_out2x <= dout7x;
--		pdata_out3x <= dout7x;
--        pdata_out4x <= dout6x;
--		pdata_out5x <= dout5x;
--		pdata_out6x <= dout4x;
--		pdata_out7x <= dout3x;
--		pdata_out8x <= dout2x;
--		pdata_out9x <= dout1x;	  
--	    --
--	    pdata_out1y <= dout7y;
--		pdata_out2y <= dout7y;
--		pdata_out3y <= dout7y;
--        pdata_out4y <= dout6y;
--		pdata_out5y <= dout5y;
--		pdata_out6y <= dout4y;
--		pdata_out7y <= dout3y;
--		pdata_out8y <= dout2y;
--		pdata_out9y <= dout1y;	
--		
--	  elsif RowsCounter_r = "0000000011" OR RowsCounter_r = std_logic_vector(to_unsigned(NO_OF_ROWS-4, ROW_BITS)) then 
--	    pdata_out1x <= dout8x;
--		pdata_out2x <= dout8x;
--		pdata_out3x <= dout7x;
--        pdata_out4x <= dout6x;
--		pdata_out5x <= dout5x;
--		pdata_out6x <= dout4x;
--		pdata_out7x <= dout3x;
--		pdata_out8x <= dout2x;
--		pdata_out9x <= dout1x;	  
--	    --
--	    pdata_out1y <= dout8y;
--		pdata_out2y <= dout8y;
--		pdata_out3y <= dout7y;
--        pdata_out4y <= dout6y;
--		pdata_out5y <= dout5y;
--		pdata_out6y <= dout4y;
--		pdata_out7y <= dout3y;
--		pdata_out8y <= dout2y;
--		pdata_out9y <= dout1y;
--	  
--	  else
	   pdata_out1x <= dout9x;
		pdata_out2x <= dout8x;
		pdata_out3x <= dout7x;
      pdata_out4x <= dout6x;
		pdata_out5x <= dout5x;
		pdata_out6x <= dout4x;
		pdata_out7x <= dout3x;
		pdata_out8x <= dout2x;
		pdata_out9x <= dout1x;	  
	    --
	   pdata_out1y <= dout9y;
		pdata_out2y <= dout8y;
		pdata_out3y <= dout7y;
      pdata_out4y <= dout6y;
		pdata_out5y <= dout5y;
		pdata_out6y <= dout4y;
		pdata_out7y <= dout3y;
		pdata_out8y <= dout2y;
		pdata_out9y <= dout1y;
		
	end if;

	--else
	
--	  pdata_out1x <= (others =>'0');
--	  pdata_out2x <= (others =>'0');
--	  pdata_out3x <= (others =>'0');
--	  pdata_out4x <= (others =>'0');
--	  pdata_out5x <= (others =>'0');
--	  pdata_out6x <= (others =>'0');
--	  pdata_out7x <= (others =>'0');
--	  pdata_out8x <= (others =>'0');
--	  pdata_out9x <= (others =>'0');
--	  --
--	  pdata_out1y <= (others =>'0');
--	  pdata_out2y <= (others =>'0');
--	  pdata_out3y <= (others =>'0');
--	  pdata_out4y <= (others =>'0');
--	  pdata_out5y <= (others =>'0');
--	  pdata_out6y <= (others =>'0');
--	  pdata_out7y <= (others =>'0');
--	  pdata_out8y <= (others =>'0');
--	  pdata_out9y <= (others =>'0');
	end if; --clk   
	--end if; --rsync_temp
  end process EmittingProcess;
end CacheSystem2;		
		