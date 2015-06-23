library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL; 
USE IEEE.NUMERIC_STD.ALL;


entity nmax_supp is
  generic (
	DATA_WIDTH : integer := 8;
	GRAD_WIDTH : integer := 16
	);
  port (
	clk  : in std_logic;
	fsync   : in std_logic;
	mData1  : in STD_LOGIC_VECTOR(GRAD_WIDTH-1 downto 0);
	mData2  : in STD_LOGIC_VECTOR(GRAD_WIDTH-1 downto 0);
	mData3  : in STD_LOGIC_VECTOR(GRAD_WIDTH-1 downto 0);
	mData4  : in STD_LOGIC_VECTOR(GRAD_WIDTH-1 downto 0);
	mData5  : in STD_LOGIC_VECTOR(GRAD_WIDTH-1 downto 0);
	mData6  : in STD_LOGIC_VECTOR(GRAD_WIDTH-1 downto 0);
	mData7  : in STD_LOGIC_VECTOR(GRAD_WIDTH-1 downto 0);
	mData8  : in STD_LOGIC_VECTOR(GRAD_WIDTH-1 downto 0);
	mData9  : in STD_LOGIC_VECTOR(GRAD_WIDTH-1 downto 0);
    dData   : in STD_LOGIC_VECTOR(1 downto 0);
	--fsync_o : out std_logic;
	pdata_o : out std_logic_vector(DATA_WIDTH-1 downto 0)
	);
  end entity nmax_supp;
  

-- WARNING UNSIGNED STD_LOGIC_VECTOR in this KERNEL
  
architecture Behavioral of nmax_supp is

constant UP_THRES : integer := 50;

signal cdata1,cdata2,cdata3 : STD_LOGIC_VECTOR(GRAD_WIDTH-1 downto 0);
--signal fsync_ia : STD_LOGIC;

--constant LATENCY   : integer := 1;
--signal fsync_store : std_logic; -- clock cycles delay to compensate for latency

begin

--  latency_comp: process (clk) -- for the frame sync signal
--  begin
--	if rising_edge(clk) then
--	  fsync_store <= fsync_i;
--	  fsync_o <= fsync_store;
--	end if;
--  end process latency_comp;
  
  --1
  --------------------------------------------------------
--  nonmax_supp: process (clk) -- nmaxsupp
--  begin
--	if rising_edge(clk) then
--	  --fsync_o <= fsync_i;
--	  --pdata_o <= mdata7(GRAD_WIDTH-1 downto GRAD_WIDTH-8); ------------DEBUG-------------
--	  if dData = "00" then -- VERTICAL gradient
--
--	    -- The gradient is from top to bottom. This means the edge is from left to right.
--	    -- So you check gradient magnitudes against the pixels right above and below.
--		if mData5 >= mData2 AND mData5 > mData8 then
--          --pdata_o <= x"3F";
--		  pdata_o <= mData5(GRAD_WIDTH-1 downto GRAD_WIDTH-8);
--		else 
--		  pdata_o <= (others => '0');
--		end if;
--	 elsif dData = "01" then -- HORIZONTAL gradient
--	    -- The gradient is horizontal. So the edge is vertical. 
--		-- So you check the pixels to the left and right.
--		if mData5 >= mData4 AND mData5 > mData6 then
--		  pdata_o <= mData5(GRAD_WIDTH-1 downto GRAD_WIDTH-8);
--		 --pdata_o <= x"7E";--mData5;
--		else 
--		  pdata_o <= (others => '0');
--		end if;
--	 elsif dData = "11" then -- 45R gradient
--
--        -- from the bottom left corner to the up right corner.
--        -- This means the edge lies from the bottom right corner to up left
--		if mData5 > mData3 AND mData5 >= mData7 then
--		  pdata_o <= mData5(GRAD_WIDTH-1 downto GRAD_WIDTH-8);
--		  --pdata_o <= x"BD";--mData5;
--		else 
--		  pdata_o <= (others => '0');
--		end if;
--	 elsif dData = "10" then-- 45F gradient
--
--        -- from the top left corner to the down right corner.
--        -- This means the edge lies from the top right corner to down left
--		if mData5 >= mData1 AND mData5 > mData9  then
--		  pdata_o <= mData5(GRAD_WIDTH-1 downto GRAD_WIDTH-8); 
--		  --pdata_o <= x"FF";--mData5;
--		else 
--		  pdata_o <= (others => '0');
--		end if;
--	  end if;		  
--	end if;
--  end process nonmax_supp;  
  
  --1
  --------------------------------------------------------
  nonmax_supp1: process (clk) -- nmaxsupp
  begin
	if rising_edge(clk) then
    if fsync ='1' then
	  --fsync_ia <= fsync_i;
	  cData2 <= mData5;
--	  pdata_o <= mdata5; ------------DEBUG-------------
	  if dData = "00" then -- VERTICAL gradient
		cData1 <= mData2;
		cData3 <= mData8;
	  elsif dData = "01" then -- HORIZONTAL
		cData1 <= mData4;
		cData3 <= mData6;	   
	  elsif dData = "11" then -- 45R gradient
		cData1 <= mData7;
		cData3 <= mData3;
	  else -- 45F gradient
		cData1 <= mData1;
		cData3 <= mData9;
	  end if;
	end if;
	end if;
  end process nonmax_supp1;
    
  --2
  --------------------------------------------------------
  nonmax_supp2: process (clk) -- nmaxsupp
  begin
	if rising_edge(clk) then
    if fsync ='1' then
--	  pdata_o <= cData2(GRAD_WIDTH-1 downto 8); ---------DEBUG
	  if cData2 >= cData1 AND cData2 > cData3 then
		if cData2(GRAD_WIDTH-1 downto 8) > x"000A" then -- THRESHOLD
		  pdata_o <= (others => '1');
		else
        pdata_o <= cData2(GRAD_WIDTH-1-2 downto 8-2); -- or set weak edges to 0 if preferred (others => '0');
		end if;
	  else 
		pdata_o <= (others => '0');
	  end if;
	end if;
	end if;
  end process nonmax_supp2;
	   



end Behavioral;