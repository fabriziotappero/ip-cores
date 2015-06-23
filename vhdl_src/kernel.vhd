library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_arith.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL; 
--use IEEE.math_real."log2";

entity filterH is
  generic (
	DATA_WIDTH : integer := 8;
	GRAD_WIDTH : integer := 16
	);
  port (
	clk  : in std_logic;
	fsync   : in std_logic;
	pData1  : in STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
	pData2  : in STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
	pData3  : in STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
	pData4  : in STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
	pData5  : in STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
	pData6  : in STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
	pData7  : in STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
	pData8  : in STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
	pData9  : in STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
	--fsync_o : out std_logic;
	Xdata_o : out std_logic_vector(GRAD_WIDTH-1 downto 0); -- X gradient
	Ydata_o : out std_logic_vector(GRAD_WIDTH-1 downto 0) -- Y gradient
	);
  end entity filterH; 
 
architecture Behavioral of filterH is

signal p1x,p2x,p3x,p4x,p5x,p6x,p7x,p8x,p9x : STD_LOGIC_VECTOR(GRAD_WIDTH-1 downto 0);
signal p1xa,p2xa,p3xa,p4xa,p5xa,p6xa,p7xa,p8xa,p9xa : STD_LOGIC_VECTOR(GRAD_WIDTH-1 downto 0);
signal p1xb,p2xb,p3xb,p4xb,p5xb,p6xb,p7xb,p8xb,p9xb : STD_LOGIC_VECTOR(GRAD_WIDTH-1 downto 0);

signal p1y,p2y,p3y,p4y,p5y,p6y,p7y,p8y,p9y : STD_LOGIC_VECTOR(GRAD_WIDTH-1 downto 0);
signal p1ya,p2ya,p3ya,p4ya,p5ya,p6ya,p7ya,p8ya,p9ya : STD_LOGIC_VECTOR(GRAD_WIDTH-1 downto 0);
signal p1yb,p2yb,p3yb,p4yb,p5yb,p6yb,p7yb,p8yb,p9yb : STD_LOGIC_VECTOR(GRAD_WIDTH-1 downto 0);

signal sX1,sX2,sY1,sY2     : STD_LOGIC_VECTOR(GRAD_WIDTH-1 downto 0);
signal SX1c, sX2c, sYc     : STD_LOGIC_VECTOR(GRAD_WIDTH-1 downto 0);
signal sX1a,sX1b,sX2a,sX2b : STD_LOGIC_VECTOR(GRAD_WIDTH-1 downto 0);
signal sY1a,sY1b,sY2a,sY2b : STD_LOGIC_VECTOR(GRAD_WIDTH-1 downto 0);

begin

--1----------------------------------------
  prod1 : process (clk) -- for the frame sync signal
  begin
	if rising_edge(clk) then
	  if fsync ='1' then
	
-------------------------------------------------------------------GRAD_X_hardwired multipliers

	  p1xa <=((GRAD_WIDTH-1 downto (8+7) => '0') & pData1 & (7-1 downto 0 => '0')) +  
		     ((GRAD_WIDTH-1 downto (8+4) => '0') & pData1 & (4-1 downto 0 => '0'));			 
	  p1xb <=((GRAD_WIDTH-1 downto (8+0) => '0') & pData1);	
	  
	  p2xa <=((GRAD_WIDTH-1 downto (8+8) => '0') & pData2 & (8-1 downto 0 => '0')) +  
		     ((GRAD_WIDTH-1 downto (8+7) => '0') & pData2 & (7-1 downto 0 => '0'));
	  p2xb <=((GRAD_WIDTH-1 downto (8+5) => '0') & pData2 & (5-1 downto 0 => '0')) +
			 ((GRAD_WIDTH-1 downto (8+4) => '0') & pData2 & (4-1 downto 0 => '0')) +
			 ((GRAD_WIDTH-1 downto (8+2) => '0') & pData2 & (2-1 downto 0 => '0')); 
			 
	  p3xa <=((GRAD_WIDTH-1 downto (8+9) => '0') & pData3 & (9-1 downto 0 => '0')) +  
		     ((GRAD_WIDTH-1 downto (8+7) => '0') & pData3 & (7-1 downto 0 => '0')); 
	  p3xb <=((GRAD_WIDTH-1 downto (8+5) => '0') & pData3 & (5-1 downto 0 => '0')) +
			 ((GRAD_WIDTH-1 downto (8+3) => '0') & pData3 & (3-1 downto 0 => '0')) +
			 ((GRAD_WIDTH-1 downto (8+1) => '0') & pData3 & (1-1 downto 0 => '0'));
			 
	  p4xa <=((GRAD_WIDTH-1 downto (8+8) => '0') & pData4 & (8-1 downto 0 => '0')) +  
		     ((GRAD_WIDTH-1 downto (8+6) => '0') & pData4 & (6-1 downto 0 => '0'));
	  p4xb <=((GRAD_WIDTH-1 downto (8+5) => '0') & pData4 & (5-1 downto 0 => '0')) +
			 ((GRAD_WIDTH-1 downto (8+4) => '0') & pData4 & (4-1 downto 0 => '0'));
			 
	  
	  p5xb <= (others => '0');
	  p5xa <= (others => '0');
	  --p5xa <= x"000000" & pData5;--------DEBUG-------------
	  
	  p6xa <=((GRAD_WIDTH-1 downto (8+8) => '0') & pData6 & (8-1 downto 0 => '0')) +  
		     ((GRAD_WIDTH-1 downto (8+6) => '0') & pData6 & (6-1 downto 0 => '0'));
	  p6xb <=((GRAD_WIDTH-1 downto (8+5) => '0') & pData6 & (5-1 downto 0 => '0')) +
			 ((GRAD_WIDTH-1 downto (8+4) => '0') & pData6 & (4-1 downto 0 => '0'));
			 
	  p7xa <=((GRAD_WIDTH-1 downto (8+9) => '0') & pData7 & (9-1 downto 0 => '0')) +  
		     ((GRAD_WIDTH-1 downto (8+7) => '0') & pData7 & (7-1 downto 0 => '0')); 
	  p7xb <=((GRAD_WIDTH-1 downto (8+5) => '0') & pData7 & (5-1 downto 0 => '0')) +
			 ((GRAD_WIDTH-1 downto (8+3) => '0') & pData7 & (3-1 downto 0 => '0')) +
			 ((GRAD_WIDTH-1 downto (8+1) => '0') & pData7 & (1-1 downto 0 => '0')); 
			 
	  p8xa <=((GRAD_WIDTH-1 downto (8+8) => '0') & pData8 & (8-1 downto 0 => '0')) +  
		     ((GRAD_WIDTH-1 downto (8+7) => '0') & pData8 & (7-1 downto 0 => '0')); 
	  p8xb <=((GRAD_WIDTH-1 downto (8+5) => '0') & pData8 & (5-1 downto 0 => '0')) +
			 ((GRAD_WIDTH-1 downto (8+4) => '0') & pData8 & (4-1 downto 0 => '0')) +
			 ((GRAD_WIDTH-1 downto (8+2) => '0') & pData8 & (2-1 downto 0 => '0')); 
	  
	  p9xa <=((GRAD_WIDTH-1 downto (8+7) => '0') & pData9 & (7-1 downto 0 => '0')) +  
		     ((GRAD_WIDTH-1 downto (8+4) => '0') & pData9 & (4-1 downto 0 => '0')); 
	  p9xb <=((GRAD_WIDTH-1 downto (8+0) => '0') & pData9);
			 
-------------------------------------------------------------------GRAD_Y_hardwired multipliers

	  p1ya <=((GRAD_WIDTH-1 downto (8+4) => '0') & pData1 & (4-1 downto 0 => '0'));
	  p1yb <=(others=>'0');
			 
	  p2ya <=((GRAD_WIDTH-1 downto (8+6) => '0') & pData2 & (6-1 downto 0 => '0')) +  
		     ((GRAD_WIDTH-1 downto (8+4) => '0') & pData2 & (4-1 downto 0 => '0'));
	  p2yb <=((GRAD_WIDTH-1 downto (8+2) => '0') & pData2 & (2-1 downto 0 => '0'));
			 
	  p3ya <=((GRAD_WIDTH-1 downto (8+8) => '0') & pData3 & (8-1 downto 0 => '0')) +  
		     ((GRAD_WIDTH-1 downto (8+5) => '0') & pData3 & (5-1 downto 0 => '0')); 
	  p3yb <=((GRAD_WIDTH-1 downto (8+3) => '0') & pData3 & (3-1 downto 0 => '0'));
			 
	  p4ya <=((GRAD_WIDTH-1 downto (8+9) => '0') & pData4 & (9-1 downto 0 => '0')) +  
		     ((GRAD_WIDTH-1 downto (8+6) => '0') & pData4 & (6-1 downto 0 => '0'));
	  p4yb <=((GRAD_WIDTH-1 downto (8+5) => '0') & pData4 & (5-1 downto 0 => '0')) +
			 ((GRAD_WIDTH-1 downto (8+4) => '0') & pData4 & (4-1 downto 0 => '0')) +
			 ((GRAD_WIDTH-1 downto (8+1) => '0') & pData4 & (1-1 downto 0 => '0'));
			 
	  p5ya <=((GRAD_WIDTH-1 downto (8+9) => '0') & pData5 & (9-1 downto 0 => '0')) +  
		     ((GRAD_WIDTH-1 downto (8+8) => '0') & pData5 & (8-1 downto 0 => '0')); 
	  p5yb <=((GRAD_WIDTH-1 downto (8+5) => '0') & pData5 & (5-1 downto 0 => '0')) +
			 ((GRAD_WIDTH-1 downto (8+2) => '0') & pData5 & (2-1 downto 0 => '0'));

	  p6ya <=((GRAD_WIDTH-1 downto (8+9) => '0') & pData6 & (9-1 downto 0 => '0')) +  
		     ((GRAD_WIDTH-1 downto (8+6) => '0') & pData6 & (6-1 downto 0 => '0')); 
	  p6yb <=((GRAD_WIDTH-1 downto (8+5) => '0') & pData6 & (5-1 downto 0 => '0')) +
			 ((GRAD_WIDTH-1 downto (8+4) => '0') & pData6 & (4-1 downto 0 => '0')) +
			 ((GRAD_WIDTH-1 downto (8+1) => '0') & pData6 & (1-1 downto 0 => '0'));

	  p7ya <=((GRAD_WIDTH-1 downto (8+8) => '0') & pData7 & (8-1 downto 0 => '0')) +  
		     ((GRAD_WIDTH-1 downto (8+5) => '0') & pData7 & (5-1 downto 0 => '0'));
	  p7yb <=((GRAD_WIDTH-1 downto (8+3) => '0') & pData7 & (3-1 downto 0 => '0'));		 

	  p8ya <=((GRAD_WIDTH-1 downto (8+6) => '0') & pData8 & (6-1 downto 0 => '0')) +  
		     ((GRAD_WIDTH-1 downto (8+4) => '0') & pData8 & (4-1 downto 0 => '0')); 
	  p8yb <=((GRAD_WIDTH-1 downto (8+2) => '0') & pData8 & (2-1 downto 0 => '0'));

	  p9ya <=((GRAD_WIDTH-1 downto (8+4) => '0') & pData9 & (4-1 downto 0 => '0'));
	  p9yb <=(others=>'0');
	end if;		 
	end if;
  end process prod1;
  
--2----------------------------------------    
  prod2 : process (clk) -- for the frame sync signal
  begin
	if rising_edge(clk) then
	if fsync ='1' then
	  p1x <= p1xa + p1xb;
	  p2x <= p2xa + p2xb;
	  p3x <= p3xa + p3xb;
	  p4x <= p4xa + p4xb;
	  p5x <= p5xa + p5xb;
	  p6x <= p6xa + p6xb;
	  p7x <= p7xa + p7xb;
	  p8x <= p8xa + p8xb;
	  p9x <= p9xa + p9xb;
	  --
	  p1y <= p1ya + p1yb;
	  p2y <= p2ya + p2yb;
	  p3y <= p3ya + p3yb;
	  p4y <= p4ya + p4yb;
	  p5y <= p5ya + p5yb;
	  p6y <= p6ya + p6yb;
	  p7y <= p7ya + p7yb;
	  p8y <= p8ya + p8yb;
	  p9y <= p9ya + p9yb;
	end if;
	end if;
  end process prod2;

--3---------------------------------------- 
  sum1 : process (clk)
  begin
	if rising_edge(clk) then
	if fsync ='1' then
	  --sX1a <= p5x; ----DEBUG-----------
	  sX1a <= p1x+p2x;
	  sX1b <= p3x+p4x;
	  sX2a <= p6x+p7x;
	  sX2b <= p8x+p9x;
	  sY1a <= p1y+p2y;
	  sY1b <= p3y+p4y;
	  sY2a <= p5y+p6y;
	  sY2b <= p7y+p8y+p9y;	
	end if;	
	end if;
  end process sum1; 

--4---------------------------------------- 
  sum2 : process (clk)
  begin
	if rising_edge(clk) then
	if fsync ='1' then
	  --sX1 <= sX1a; ----DEBUG-----------
	  sX1 <= sX1a+sX1b;
	  sX2 <= sX2a+sX2b;
	  sY1 <= sY1a+sY1b;
	  sY2 <= sY2a+sY2b;
	end if;	
	end if;
  end process sum2; 

--5---------------------------------------- 
  sum3 : process (clk) 
  begin
	if rising_edge(clk) then
	if fsync ='1' then
	    sX2c <= (not sX2) + 1;
	    sX1c <= sX1;
	    sYc  <= sY1+sY2;
	end if;	
	end if;
  end process sum3;

--6---------------------------------------- 
  outp : process (clk) 
  begin
	if rising_edge(clk) then
	if fsync ='1' then
		--Xdata_o <= sX1c; -------DEBUG-------
	   Xdata_o <= sX1c+sX2c;
		Ydata_o <= (not sYc) + 1;
	end if;	
	end if;
  end process outp;

end Behavioral;