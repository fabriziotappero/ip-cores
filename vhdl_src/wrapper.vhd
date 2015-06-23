library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity edge_sobel_wrapper is 
  generic (
    data_width : integer := 8
  );
  Port ( clk  : in  STD_LOGIC;
    rstn      : in  STD_LOGIC;
	 fsync_in  : in  STD_LOGIC;
	 pdata_in  : in  STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0);
	 fsync_out : out  STD_LOGIC;
	 pdata_out : out  STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0)
  );
end entity edge_sobel_wrapper;

architecture Structural of edge_sobel_wrapper is

constant GRAD_WIDTH : integer := 32;
constant GDIR_WIDTH : integer := 2;
constant NO_OF_COLS : integer := 640;
constant NO_OF_ROWS : integer := 480;
constant ROW_BITS   : integer := 9;
constant COL_BITS   : integer := 10;

signal RowsCounter_r, RowsCounter_x : STD_LOGIC_VECTOR(ROW_BITS-1 downto 0);
signal ColsCounter_r, ColsCounter_x : STD_LOGIC_VECTOR(COL_BITS-1 downto 0);

signal pdata_1_1   :  std_logic_vector(DATA_WIDTH-1 downto 0);
signal pdata_2_1   :  std_logic_vector(DATA_WIDTH-1 downto 0);
signal pdata_3_1   :  std_logic_vector(DATA_WIDTH-1 downto 0);
signal pdata_4_1   :  std_logic_vector(DATA_WIDTH-1 downto 0);
signal pdata_5_1   :  std_logic_vector(DATA_WIDTH-1 downto 0);
signal pdata_6_1   :  std_logic_vector(DATA_WIDTH-1 downto 0);
signal pdata_7_1   :  std_logic_vector(DATA_WIDTH-1 downto 0);
signal pdata_8_1   :  std_logic_vector(DATA_WIDTH-1 downto 0);
signal pdata_9_1   :  std_logic_vector(DATA_WIDTH-1 downto 0);
signal fsync_o_1   :  std_logic;
--
signal Xdata_o_2   :  std_logic_vector(GRAD_WIDTH-1 downto 0);
signal Ydata_o_2   :  std_logic_vector(GRAD_WIDTH-1 downto 0);
signal fsync_o_2   :  std_logic;
--
signal pdata_1_3x  :  std_logic_vector(GRAD_WIDTH-1 downto 0);
signal pdata_2_3x  :  std_logic_vector(GRAD_WIDTH-1 downto 0);
signal pdata_3_3x  :  std_logic_vector(GRAD_WIDTH-1 downto 0);
signal pdata_4_3x  :  std_logic_vector(GRAD_WIDTH-1 downto 0);
signal pdata_5_3x  :  std_logic_vector(GRAD_WIDTH-1 downto 0);
signal pdata_6_3x  :  std_logic_vector(GRAD_WIDTH-1 downto 0);
signal pdata_7_3x  :  std_logic_vector(GRAD_WIDTH-1 downto 0);
signal pdata_8_3x  :  std_logic_vector(GRAD_WIDTH-1 downto 0);
signal pdata_9_3x  :  std_logic_vector(GRAD_WIDTH-1 downto 0);
--
signal pdata_1_3y  :  std_logic_vector(GRAD_WIDTH-1 downto 0);
signal pdata_2_3y  :  std_logic_vector(GRAD_WIDTH-1 downto 0);
signal pdata_3_3y  :  std_logic_vector(GRAD_WIDTH-1 downto 0);
signal pdata_4_3y  :  std_logic_vector(GRAD_WIDTH-1 downto 0);
signal pdata_5_3y  :  std_logic_vector(GRAD_WIDTH-1 downto 0);
signal pdata_6_3y  :  std_logic_vector(GRAD_WIDTH-1 downto 0);
signal pdata_7_3y  :  std_logic_vector(GRAD_WIDTH-1 downto 0);
signal pdata_8_3y  :  std_logic_vector(GRAD_WIDTH-1 downto 0);
signal pdata_9_3y  :  std_logic_vector(GRAD_WIDTH-1 downto 0);
signal fsync_o_3   :  std_logic;
--
signal Mdata_o_4   :  std_logic_vector(GRAD_WIDTH-1-16 downto 0);
signal Ddata_o_4   :  std_logic_vector(1 downto 0);
signal fsync_o_4   :  std_logic;
--
signal pdata_1_5   :  std_logic_vector(GRAD_WIDTH-1-16 downto 0);
signal pdata_2_5   :  std_logic_vector(GRAD_WIDTH-1-16 downto 0);
signal pdata_3_5   :  std_logic_vector(GRAD_WIDTH-1-16 downto 0);
signal pdata_4_5   :  std_logic_vector(GRAD_WIDTH-1-16 downto 0);
signal pdata_5_5   :  std_logic_vector(GRAD_WIDTH-1-16 downto 0);
signal pdata_6_5   :  std_logic_vector(GRAD_WIDTH-1-16 downto 0);
signal pdata_7_5   :  std_logic_vector(GRAD_WIDTH-1-16 downto 0);
signal pdata_8_5   :  std_logic_vector(GRAD_WIDTH-1-16 downto 0);
signal pdata_9_5   :  std_logic_vector(GRAD_WIDTH-1-16 downto 0);
signal dData_o_5   :  std_logic_vector(1 downto 0);
signal fsync_o_5   :  std_logic;
--
signal fsync_o_6   :  std_logic;
signal pdata_o_6   :  std_logic_vector(DATA_WIDTH-1 downto 0);
--
signal counter_x   :  std_logic_vector(18 downto 0);
signal counter_r   :  std_logic_vector(18 downto 0);
signal counter1_x  :  std_logic_vector(15 downto 0);
signal counter1_r  :  std_logic_vector(15 downto 0);
signal fsync_temp  :  std_logic;
signal fsync_out_a :  std_logic;
signal tail_x      :  std_logic;
signal tail_r      :  std_logic;
--
constant LATENCY : integer := 5+5+5+3+(5*NO_OF_COLS)+7+2;
signal fsync_store : std_logic_vector(LATENCY - 1 downto 0); -- clock cycles delay to compensate for latency

begin

  CacheSystem : entity work.CacheSystem
	generic map (
	  DATA_WIDTH => DATA_WIDTH,
	  WINDOW_SIZE => 9,
	  ROW_BITS => 9,
	  COL_BITS => 10,
	  NO_OF_ROWS => NO_OF_ROWS,
     NO_OF_COLS => NO_OF_COLS
	  )
	port map(
	  clk => clk,
	  fsync_in => fsync_out_a,
	  pdata_in => pdata_in,
	  --fsync_out => fsync_o_1,
	  pdata_out1 => pdata_1_1,
	  pdata_out2 => pdata_2_1,
	  pdata_out3 => pdata_3_1,
	  pdata_out4 => pdata_4_1,
	  pdata_out5 => pdata_5_1,
	  pdata_out6 => pdata_6_1,
	  pdata_out7 => pdata_7_1,
	  pdata_out8 => pdata_8_1,
	  pdata_out9 => pdata_9_1
	  );
	  
  filterH: entity work.filterH
	generic map ( 
	  DATA_WIDTH => DATA_WIDTH,
	  GRAD_WIDTH => GRAD_WIDTH
	  )
	port map(
	  clk => clk,
	  fsync => fsync_out_a,
	  pData1  => pData_1_1,
	  pData2  => pData_2_1,
	  pData3  => pData_3_1,
	  pData4  => pData_4_1,
	  pData5  => pData_5_1,
	  pData6  => pData_6_1,
	  pData7  => pData_7_1,
	  pData8  => pData_8_1,
	  pData9  => pData_9_1,
	  --fsync_o => fsync_o_2,
	  Xdata_o => Xdata_o_2, -- x gradient partial filtering product
	  Ydata_o => Ydata_o_2	-- y gradient partial filtering product
	  );
	  
  -- rowbuffer	  	  
  CacheSystem2 : entity work.CacheSystem2
	generic map (
	  DATA_WIDTH => GRAD_WIDTH,
	  WINDOW_SIZE =>9,
	  ROW_BITS => ROW_BITS,
	  COL_BITS => COL_BITS,
	  NO_OF_ROWS => NO_OF_ROWS,
     NO_OF_COLS => NO_OF_COLS
	  )
	port map(
	  clk => clk,
	  fsync_in => fsync_out_a,
	  Xdata_in => Xdata_o_2,
	  Ydata_in => Ydata_o_2,
	  --fsync_out => fsync_o_3,
	  --
	  pdata_out1x => pdata_1_3x,
	  pdata_out2x => pdata_2_3x,
	  pdata_out3x => pdata_3_3x,
	  pdata_out4x => pdata_4_3x,
	  pdata_out5x => pdata_5_3x,
	  pdata_out6x => pdata_6_3x,
	  pdata_out7x => pdata_7_3x,
	  pdata_out8x => pdata_8_3x,
	  pdata_out9x => pdata_9_3x,
	  --	  
	  pdata_out1y => pdata_1_3y,
	  pdata_out2y => pdata_2_3y,
	  pdata_out3y => pdata_3_3y,
	  pdata_out4y => pdata_4_3y,
	  pdata_out5y => pdata_5_3y,
	  pdata_out6y => pdata_6_3y,
	  pdata_out7y => pdata_7_3y,
	  pdata_out8y => pdata_8_3y,
	  pdata_out9y => pdata_9_3y
	  );	  
	  

  filterV: entity work.filterV
	generic map ( 
	  DATA_WIDTH => GRAD_WIDTH,
	  GRAD_WIDTH => GRAD_WIDTH
	  )
	port map(
	  clk => clk,
	  fsync => fsync_out_a,
	  pData1x  => pData_1_3x,
	  pData2x  => pData_2_3x,
	  pData3x  => pData_3_3x,
	  pData4x  => pData_4_3x,
	  pData5x  => pData_5_3x,
	  pData6x  => pData_6_3x,
	  pData7x  => pData_7_3x,
	  pData8x  => pData_8_3x,
	  pData9x  => pData_9_3x,
	  --
	  pData1y  => pData_1_3y,
	  pData2y  => pData_2_3y,
	  pData3y  => pData_3_3y,
	  pData4y  => pData_4_3y,
	  pData5y  => pData_5_3y,
	  pData6y  => pData_6_3y,
	  pData7y  => pData_7_3y,
	  pData8y  => pData_8_3y,
	  pData9y  => pData_9_3y,
	  --fsync_o => fsync_o_4,
	  Mdata_o  => Mdata_o_4, 
	  Ddata_o  => Ddata_o_4	
	  );	  
	  
  CacheSystem3 : entity work.CacheSystem3
	generic map (
	  DATA_WIDTH => GRAD_WIDTH-16,
	  WINDOW_SIZE => 3,
	  ROW_BITS => ROW_BITS,
	  COL_BITS => COL_BITS,
	  NO_OF_ROWS => NO_OF_ROWS,
     NO_OF_COLS => NO_OF_COLS
	  )
	port map(
	  clk => clk,
	  fsync_in => fsync_out_a,
	  mdata_in => mdata_o_4,
	  dData_in => Ddata_o_4,
	  --fsync_out => fsync_o_5,
	  pdata_out1 => pdata_1_5,
	  pdata_out2 => pdata_2_5,
	  pdata_out3 => pdata_3_5,
	  pdata_out4 => pdata_4_5,
	  pdata_out5 => pdata_5_5,
	  pdata_out6 => pdata_6_5,
	  pdata_out7 => pdata_7_5,
	  pdata_out8 => pdata_8_5,
	  pdata_out9 => pdata_9_5,
	  dData_out => dData_o_5
	  );

  krnl2: entity work.nmax_supp
	generic map ( 
	  DATA_WIDTH => DATA_WIDTH,
	  GRAD_WIDTH => GRAD_WIDTH-16
	  )
	port map(
	  clk => clk,
	  fsync => fsync_out_a,
	  mData1 => pData_1_5,
	  mData2 => pData_2_5,
	  mData3 => pData_3_5,
	  mData4 => pData_4_5,
	  mData5 => pData_5_5,
	  mData6 => pData_6_5,
	  mData7 => pData_7_5,
	  mData8 => pData_8_5,
	  mData9 => pData_9_5,
	  dData  => dData_o_5,
	  --fsync_o => fsync_o_6,
	  pdata_o => pdata_o_6
	  );	  
	  
  --fsync_out <= fsync_o_4;	  
  --pdata_out <= mdata_o_4(7 downto 0);
  pdata_out <= pdata_o_6;-- when RowsCounter_r > std_logic_vector(to_unsigned(3, RowsCounter_r'length)) AND
--							  ColsCounter_r > std_logic_vector(to_unsigned(3, ColsCounter_r'length)) AND
--							  RowsCounter_r < std_logic_vector(to_unsigned(NO_OF_ROWS-4, RowsCounter_r'length)) AND
--							  ColsCounter_r < std_logic_vector(to_unsigned(NO_OF_COLS-4, ColsCounter_r'length)) ELSE
--							  (others => '0');

--  fsync_out <= fsync_temp;
  fsync_out_a <= fsync_temp OR fsync_in;
  fsync_out     <= fsync_temp;
  

---- fsync_temp is the delayed version (LATENCY) of fsync_out
--  fsync_delayer : process (clk)
--  begin
--	if rising_edge(clk) then
--	  fsync_store <= fsync_store(LATENCY-2 downto 0) & fsync_in;
--	  fsync_temp <= fsync_store(LATENCY-1);
--	end if;
--  end process fsync_delayer;
 
--	if (fsync_in) = '1' AND counter_r /= std_logic_vector(to_unsigned(5+5+5+3+(5*NO_OF_COLS)+7+2, counter_r'length)) then
 
  f_sync_delayer1: process (counter_r, counter1_r, fsync_in, tail_r) -- nmaxsupp
  begin
    counter_x  <= counter_r;
    counter1_x <= counter1_r;
	 tail_x     <= tail_r;
	
	 if fsync_in = '1' then
      if counter_r /= std_logic_vector(to_unsigned(NO_OF_ROWS*NO_OF_COLS-1, counter_r'length)) then
        counter_x <= counter_r + 1;
	   else 
	     counter_x <= (others => '0');
		  tail_x <= '1';
	   end if;
	end if;
	
	if tail_r = '0' then 
	  if counter_r < std_logic_vector(to_unsigned(5+5+5+4+(5*NO_OF_COLS)+7+2, counter_r'length)) then
	    fsync_temp <= '0';
	  else
	    fsync_temp <= fsync_in;
	  end if;
	else
	  fsync_temp <= '1';
	end if;
	
	if tail_r ='1' then 
	  if counter1_r < std_logic_vector(to_unsigned(5+5+5+3+(5*NO_OF_COLS)+7+2, counter_r'length)) then
	    counter1_x <= counter1_r + 1;
	  else
	    counter1_x <= (others => '0');
	    tail_x <= '0';
	  end if;
	end if;
  end process f_sync_delayer1;
  
  update_reg : process (clk)
  begin 
    if rising_edge(clk) then
	  if rstn = '0' then
	    RowsCounter_r <= (others => '0');
       ColsCounter_r <= (others => '0');
	    counter_r     <= (others => '0');
       counter1_r    <= (others => '0');
	    tail_r        <= '0';
	  else
	    RowsCounter_r <= RowsCounter_x;
       ColsCounter_r <= ColsCounter_x;
	    counter_r     <= counter_x;
       counter1_r    <= counter1_x;
	    tail_r        <= tail_x;
	  end if;
	end if;
  end process update_reg;
  
  counter : process (fsync_o_6,  ColsCounter_r, RowsCounter_r, fsync_in)
  begin
    RowsCounter_x <= RowsCounter_r;
    ColsCounter_x <= ColsCounter_r;
	--if rising_edge(clk) then
	if(fsync_in = '1') then
	  if RowsCounter_r = std_logic_vector(to_unsigned(NO_OF_ROWS-1, ROW_BITS)) AND 
	    ColsCounter_r = std_logic_vector(to_unsigned(NO_OF_COLS-1, COL_BITS)) then
	    ColsCounter_x <= (others => '0');
		 RowsCounter_x <= (others => '0');
	  elsif RowsCounter_r /= std_logic_vector(to_unsigned(NO_OF_ROWS-1, ROW_BITS)) AND
	    ColsCounter_r = std_logic_vector(to_unsigned(NO_OF_COLS-1, COL_BITS)) then
	    ColsCounter_x <= ColsCounter_r + 1;
		 RowsCounter_x <= RowsCounter_r;
	  else 
		 ColsCounter_x <= ColsCounter_r + 1;
		 RowsCounter_x <= RowsCounter_r;
	  end if;
	end if;
    --end if;
  end process counter;
	  
end Structural;
