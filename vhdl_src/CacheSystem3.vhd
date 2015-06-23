library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL; 
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity CacheSystem3 is
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
	mData_in : in std_logic_vector(DATA_WIDTH -1 downto 0);
	dData_in : in std_logic_vector(1 downto 0);
	--fsync_out : out std_logic;
	pdata_out1 : out std_logic_vector(DATA_WIDTH -1 downto 0);
	pdata_out2 : out std_logic_vector(DATA_WIDTH -1 downto 0);
	pdata_out3 : out std_logic_vector(DATA_WIDTH -1 downto 0);
	pdata_out4 : out std_logic_vector(DATA_WIDTH -1 downto 0);
	pdata_out5 : out std_logic_vector(DATA_WIDTH -1 downto 0);
	pdata_out6 : out std_logic_vector(DATA_WIDTH -1 downto 0);
	pdata_out7 : out std_logic_vector(DATA_WIDTH -1 downto 0);
	pdata_out8 : out std_logic_vector(DATA_WIDTH -1 downto 0);
	pdata_out9 : out std_logic_vector(DATA_WIDTH -1 downto 0);
	dData_out  : out std_logic_vector(1 downto 0)
	);
  end CacheSystem3;
  
 
architecture CacheSystem3 of CacheSystem3 is


COMPONENT DoubleFiFOLineBuffer is
  generic (
	DATA_WIDTH : integer := 8;
	NO_OF_COLS : integer := 640 
	);
  port(
	clk : in std_logic;
	fsync : in std_logic;
	pdata_in : in std_logic_vector(DATA_WIDTH -1 downto 0);
	pdata_out1 : out std_logic_vector(DATA_WIDTH -1 downto 0);
	pdata_out2 : buffer std_logic_vector(DATA_WIDTH -1 downto 0);
	pdata_out3 : buffer std_logic_vector(DATA_WIDTH -1 downto 0)
	);
end COMPONENT;

component FIFOLineBuffer is
  generic (
	DATA_WIDTH : integer := 8;
	NO_OF_COLS : integer := 640
	);
  port(
	clk : in std_logic;
	fsync : in std_logic;
	pdata_in : in std_logic_vector(DATA_WIDTH -1 downto 0);
	pdata_out : buffer std_logic_vector(DATA_WIDTH -1 downto 0));
  end component;

--signal RowsCounter_r, RowsCounter_x : STD_LOGIC_VECTOR(ROW_BITS-1 downto 0);
--signal ColsCounter_r, ColsCounter_x : STD_LOGIC_VECTOR(COL_BITS-1 downto 0);

signal dout1 : std_logic_vector(DATA_WIDTH -1 downto 0);
signal dout2 : std_logic_vector(DATA_WIDTH -1 downto 0);
signal dout3 : std_logic_vector(DATA_WIDTH -1 downto 0);

signal dData_temp : std_logic_vector(1 downto 0);


signal cache1 : std_logic_vector((WINDOW_SIZE*DATA_WIDTH) -1 downto 0);
signal cache2 : std_logic_vector((WINDOW_SIZE*DATA_WIDTH) -1 downto 0);
signal cache3 : std_logic_vector((WINDOW_SIZE*DATA_WIDTH) -1 downto 0);

--constant LATENCY : integer := NO_OF_COLS+2;
--signal fsync_store : std_logic_vector(LATENCY - 1 downto 0); -- clock cycles delay to compensate for latency

begin

  
--  
--  fsync_out <= fsync_temp;
--  --fsync_buffer <= fsync_in OR fsync_temp;
--  
--  fsync_delayer : process (clk)
--  begin
--	if rising_edge(clk) then
--	  fsync_store <= fsync_store(LATENCY-2 downto 0) & fsync_in;
--	  fsync_temp <= fsync_store(LATENCY-1);
--	end if;
--  end process fsync_delayer;
 
  DoubleLineBufferMag: DoubleFiFOLineBuffer
	generic map (
	  DATA_WIDTH => DATA_WIDTH,
	  NO_OF_COLS => NO_OF_COLS
	  )
	port map (
	  clk => clk,
	  fsync => fsync_in,--fsync_buffer,
	  pdata_in => mdata_in,
	  pdata_out1 => dout1,
	  pdata_out2 => dout2,
	  pdata_out3 => dout3
	  );
	  
  dDataBuffer1 : FIFOLineBuffer
	generic map (
	  DATA_WIDTH => 2,
	  NO_OF_COLS => NO_OF_COLS+2+1
	  )
	port map(clk, fsync_in, dData_in, dData_temp);
	

--  update_reg : process (clk)
--  begin 
--    if(clk'event and clk = '1') then
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
  
  
	
  --fsync_out <= fsync_temp;
  
  ShiftingProcess : process (clk, fsync_in)  
  begin

	if rising_edge(clk) then
	    if fsync_in = '1' then
	  -- the pixel in the middle part is copied into the low part
	  cache1(DATA_WIDTH-1 downto 0) <= cache1(((WINDOW_SIZE-1)*DATA_WIDTH-1) downto ((WINDOW_SIZE-2)*DATA_WIDTH));
	  cache2(DATA_WIDTH-1 downto 0) <= cache2(((WINDOW_SIZE-1)*DATA_WIDTH-1) downto ((WINDOW_SIZE-2)*DATA_WIDTH));
	  cache3(DATA_WIDTH-1 downto 0) <= cache3(((WINDOW_SIZE-1)*DATA_WIDTH-1) downto ((WINDOW_SIZE-2)*DATA_WIDTH));
	  -- the pixel in the high part is copied into the middle part
	  cache1(((WINDOW_SIZE-1)*DATA_WIDTH-1) downto ((WINDOW_SIZE-2)*DATA_WIDTH) ) <= cache1((WINDOW_SIZE*DATA_WIDTH)-1 downto ((WINDOW_SIZE-1)*DATA_WIDTH));
	  cache2(((WINDOW_SIZE-1)*DATA_WIDTH-1) downto ((WINDOW_SIZE-2)*DATA_WIDTH) ) <= cache2((WINDOW_SIZE*DATA_WIDTH)-1 downto ((WINDOW_SIZE-1)*DATA_WIDTH));
	  cache3(((WINDOW_SIZE-1)*DATA_WIDTH-1) downto ((WINDOW_SIZE-2)*DATA_WIDTH) ) <= cache3((WINDOW_SIZE*DATA_WIDTH)-1 downto ((WINDOW_SIZE-1)*DATA_WIDTH));
	  -- the output of the ram is put in the high part of the variable
	  cache1((WINDOW_SIZE*DATA_WIDTH)-1 downto ((WINDOW_SIZE-1)*DATA_WIDTH)) <= dout1;
	  cache2((WINDOW_SIZE*DATA_WIDTH)-1 downto ((WINDOW_SIZE-1)*DATA_WIDTH)) <= dout2;
	  cache3((WINDOW_SIZE*DATA_WIDTH)-1 downto ((WINDOW_SIZE-1)*DATA_WIDTH)) <= dout3;
	end if; -- clk
	end if;
  end process ShiftingProcess;
  
  EmittingProcess : process (clk)  
  begin
     
	 
	if rising_edge(clk) then  
    if fsync_in = '1' then
      dData_out <= dData_temp;	
	  -- 1 top left
--	  if RowsCounter_r = "000000000" and ColsCounter_r = "0000000000" then 
--		pdata_out1 <= (others => '0');
--		pdata_out2 <= (others => '0');
--		pdata_out3 <= (others => '0');
--		pdata_out4 <= (others => '0');
--		pdata_out5 <= cache2(((WINDOW_SIZE-1)*DATA_WIDTH-1) downto ((WINDOW_SIZE-2)*DATA_WIDTH));
--		pdata_out6 <= cache2(((WINDOW_SIZE)*DATA_WIDTH-1) downto ((WINDOW_SIZE-1)*DATA_WIDTH));
--		pdata_out7 <= (others => '0');
--		pdata_out8 <= cache1(((WINDOW_SIZE-1)*DATA_WIDTH-1) downto ((WINDOW_SIZE-2)*DATA_WIDTH));
--		pdata_out9 <= cache1(((WINDOW_SIZE)*DATA_WIDTH-1) downto ((WINDOW_SIZE-1)*DATA_WIDTH));
--	
--	  -- counter2>0 and counter2<639 (2) top
--	  elsif RowsCounter_r = "000000000" and ColsCounter_r > "0000000000" and ColsCounter_r < "1001111111" then
--		pdata_out1 <= (others => '0');
--		pdata_out2 <= (others => '0');
--		pdata_out3 <= (others => '0');
--		pdata_out4 <= cache2((DATA_WIDTH-1) downto 0);
--		pdata_out5 <= cache2(((WINDOW_SIZE-1)*DATA_WIDTH-1) downto ((WINDOW_SIZE-2)*DATA_WIDTH));
--		pdata_out6 <= cache2(((WINDOW_SIZE)*DATA_WIDTH-1) downto ((WINDOW_SIZE-1)*DATA_WIDTH));
--		pdata_out7 <= cache1((DATA_WIDTH-1) downto 0);
--		pdata_out8 <= cache1(((WINDOW_SIZE-1)*DATA_WIDTH-1) downto ((WINDOW_SIZE-2)*DATA_WIDTH));
--		pdata_out9 <= cache1(((WINDOW_SIZE)*DATA_WIDTH-1) downto ((WINDOW_SIZE-1)*DATA_WIDTH));
--		-- counter2=639
--		
--	  --3 top right	
--	  elsif RowsCounter_r = "000000000" and ColsCounter_r = "1001111111" then 
--		pdata_out1 <= (others => '0');
--		pdata_out2 <= (others => '0');
--		pdata_out3 <= (others => '0');
--		pdata_out4 <= cache2((DATA_WIDTH-1) downto 0 );
--		pdata_out5 <= cache2(((WINDOW_SIZE-1)*DATA_WIDTH-1) downto DATA_WIDTH);
--		pdata_out6 <= (others => '0');
--		pdata_out7 <= cache1((DATA_WIDTH-1) downto 0 );
--		pdata_out8 <= cache1(((WINDOW_SIZE-1)*DATA_WIDTH-1) downto DATA_WIDTH);
--		pdata_out9 <= (others => '0');
--		
--	  -- row>0 and row<479 (4)left
--	  elsif RowsCounter_r > "000000000" and RowsCounter_r < "111011111" and ColsCounter_r = "0000000000" then
--		pdata_out1 <= (others => '0');
--		pdata_out2 <= cache3(((WINDOW_SIZE-1)*DATA_WIDTH - 1) downto DATA_WIDTH ); 
--		pdata_out3 <= cache3(((WINDOW_SIZE)*DATA_WIDTH - 1) downto ((WINDOW_SIZE-1)*DATA_WIDTH) );
--		pdata_out4 <= (others => '0');
--		pdata_out5 <= cache2(((WINDOW_SIZE-1)*DATA_WIDTH - 1) downto DATA_WIDTH );
--		pdata_out6 <= cache2(((WINDOW_SIZE)*DATA_WIDTH - 1) downto ((WINDOW_SIZE-1)*DATA_WIDTH) );
--		pdata_out7 <= (others => '0');
--		pdata_out8 <= cache1(((WINDOW_SIZE-1)*DATA_WIDTH - 1) downto DATA_WIDTH );
--		pdata_out9 <= cache1(((WINDOW_SIZE)*DATA_WIDTH - 1) downto ((WINDOW_SIZE-1)*DATA_WIDTH) );
--		
--	  -- row>0 and row<479 and counter2>0 and counter2=639 (6) right
--	  elsif RowsCounter_r > "000000000" and RowsCounter_r < "111011111" and ColsCounter_r = "1001111111" then
--		pdata_out1 <= cache3((DATA_WIDTH - 1) downto 0 );
--		pdata_out2 <= cache3(((WINDOW_SIZE-1)*DATA_WIDTH - 1) downto DATA_WIDTH );
--		pdata_out3 <= (others => '0');
--		pdata_out4 <= cache2((DATA_WIDTH - 1) downto 0 );
--		pdata_out5 <= cache2(((WINDOW_SIZE-1)*DATA_WIDTH - 1) downto DATA_WIDTH );
--		pdata_out6 <= (others => '0');
--		pdata_out7 <= cache1((DATA_WIDTH - 1) downto 0 );
--		pdata_out8 <= cache1(((WINDOW_SIZE-1)*DATA_WIDTH - 1) downto DATA_WIDTH );
--		pdata_out9 <= (others => '0');
--		
--	  -- row=479 and counter2=0 (7) bottom left
--	  elsif RowsCounter_r="111011111" and ColsCounter_r="0000000000" then
--		pdata_out1 <= (others => '0');
--		pdata_out2 <= cache3(((WINDOW_SIZE-1)*DATA_WIDTH - 1) downto DATA_WIDTH );
--		pdata_out3 <= cache3(((WINDOW_SIZE)*DATA_WIDTH - 1) downto ((WINDOW_SIZE-1)*DATA_WIDTH) );
--		pdata_out4 <= (others => '0');
--		pdata_out5 <= cache2(((WINDOW_SIZE-1)*DATA_WIDTH - 1) downto DATA_WIDTH ); 
--		pdata_out6 <= cache2(((WINDOW_SIZE)*DATA_WIDTH - 1) downto ((WINDOW_SIZE-1)*DATA_WIDTH) );
--		pdata_out7 <= (others => '0');
--		pdata_out8 <= (others => '0');
--		pdata_out9 <= cache2(((WINDOW_SIZE)*DATA_WIDTH - 1) downto ((WINDOW_SIZE-1)*DATA_WIDTH) ); -- 6
--		
--	  -- row=479 and counter2>0 and counter2<639 (8) bottom
--	  elsif RowsCounter_r = "111011111" and ColsCounter_r > "0000000000" and ColsCounter_r < "1001111111" then
--		pdata_out1 <= cache3((DATA_WIDTH - 1) downto 0 );
--		pdata_out2 <= cache3(((WINDOW_SIZE-1)*DATA_WIDTH - 1) downto DATA_WIDTH );
--		pdata_out3 <= cache3(((WINDOW_SIZE)*DATA_WIDTH - 1) downto ((WINDOW_SIZE-1)*DATA_WIDTH) );
--		pdata_out4 <= cache2((DATA_WIDTH - 1) downto 0 );
--		pdata_out5 <= cache2(((WINDOW_SIZE-1)*DATA_WIDTH - 1) downto DATA_WIDTH );
--		pdata_out6 <= cache2(((WINDOW_SIZE)*DATA_WIDTH - 1) downto ((WINDOW_SIZE-1)*DATA_WIDTH) );
--		pdata_out7 <= (others => '0');
--		pdata_out8 <= (others => '0');
--		pdata_out9 <= (others => '0');
--		
--	  -- row=479 and counter2=639 (9) bottom right
--	  elsif RowsCounter_r = "111011111" and ColsCounter_r = "1001111111" then 
--		pdata_out1 <= cache3((DATA_WIDTH - 1) downto 0 );
--		pdata_out2 <= cache3(((WINDOW_SIZE-1)*DATA_WIDTH - 1) downto DATA_WIDTH );
--		pdata_out3 <= (others => '0');
--		pdata_out4 <= cache2((DATA_WIDTH - 1) downto 0 );
--		pdata_out5 <= cache2(((WINDOW_SIZE-1)*DATA_WIDTH - 1) downto DATA_WIDTH );
--		pdata_out6 <= (others => '0');
--		pdata_out7 <= cache2((DATA_WIDTH - 1) downto 0 ); -- 4 
--		pdata_out8 <= (others => '0');
--		pdata_out9 <= (others => '0');
		
	  -- 5	
--	  else
	    pdata_out1 <= cache3((DATA_WIDTH - 1) downto 0 );
		pdata_out2 <= cache3(((WINDOW_SIZE-1)*DATA_WIDTH - 1) downto (WINDOW_SIZE-2)*DATA_WIDTH );
		pdata_out3 <= cache3(((WINDOW_SIZE)*DATA_WIDTH - 1) downto ((WINDOW_SIZE-1)*DATA_WIDTH) );
        pdata_out4 <= cache2((DATA_WIDTH-1) downto 0);
		pdata_out5 <= cache2(((WINDOW_SIZE-1)*DATA_WIDTH-1) downto ((WINDOW_SIZE-2)*DATA_WIDTH));
		pdata_out6 <= cache2(((WINDOW_SIZE)*DATA_WIDTH-1) downto ((WINDOW_SIZE-1)*DATA_WIDTH));
		pdata_out7 <= cache1((DATA_WIDTH-1) downto 0);
		pdata_out8 <= cache1(((WINDOW_SIZE-1)*DATA_WIDTH-1) downto ((WINDOW_SIZE-2)*DATA_WIDTH));
		pdata_out9 <= cache1(((WINDOW_SIZE)*DATA_WIDTH-1) downto ((WINDOW_SIZE-1)*DATA_WIDTH));	  

		
--	  end if; -- RowsCounter_r and ColsCounter_r
	--else
--	  dData_out  <= (others =>'0');
--	  pdata_out1 <= (others =>'0');
--	  pdata_out2 <= (others =>'0');
--	  pdata_out3 <= (others =>'0');
--	  pdata_out4 <= (others =>'0');
--	  pdata_out5 <= (others =>'0');
--	  pdata_out6 <= (others =>'0');
--	  pdata_out7 <= (others =>'0');
--	  pdata_out8 <= (others =>'0');
--	  pdata_out9 <= (others =>'0');
	end if; --rsync_temp
	end if; --clk   
  end process EmittingProcess;
end CacheSystem3;		
		