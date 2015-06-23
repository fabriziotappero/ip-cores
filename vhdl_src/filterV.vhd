library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_arith.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL; 
use IEEE.math_real."log2";

entity filterV is
  generic (
	DATA_WIDTH : integer := 8;
	GRAD_WIDTH : integer := 16
	);
  port (
	clk      : in std_logic;
	fsync    : in std_logic;
	--
	pData1x  : in STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
	pData2x  : in STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
	pData3x  : in STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
	pData4x  : in STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
	pData5x  : in STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
	pData6x  : in STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
	pData7x  : in STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
	pData8x  : in STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
	pData9x  : in STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
	--
	pData1y  : in STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
	pData2y  : in STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
	pData3y  : in STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
	pData4y  : in STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
	pData5y  : in STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
	pData6y  : in STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
	pData7y  : in STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
	pData8y  : in STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
	pData9y  : in STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
	--
	Mdata_o : out STD_LOGIC_VECTOR(GRAD_WIDTH-1-16 downto 0); -- X gradient
	Ddata_o : out STD_LOGIC_VECTOR(1 downto 0) -- Y gradient
	);
  end entity filterV;
 
 
architecture Behavioral of filterV is

signal p1x,p2x,p3x,p4x,p5x,p6x,p7x,p8x,p9x : STD_LOGIC_VECTOR(GRAD_WIDTH-1 downto 0);
signal p1xa,p2xa,p3xa,p4xa,p5xa,p6xa,p7xa,p8xa,p9xa : STD_LOGIC_VECTOR(GRAD_WIDTH-1 downto 0);
signal p1xb,p2xb,p3xb,p4xb,p5xb,p6xb,p7xb,p8xb,p9xb : STD_LOGIC_VECTOR(GRAD_WIDTH-1 downto 0);

signal p1y,p2y,p3y,p4y,p5y,p6y,p7y,p8y,p9y : STD_LOGIC_VECTOR(GRAD_WIDTH-1 downto 0);
signal p1ya,p2ya,p3ya,p4ya,p5ya,p6ya,p7ya,p8ya,p9ya : STD_LOGIC_VECTOR(GRAD_WIDTH-1 downto 0);
signal p1yb,p2yb,p3yb,p4yb,p5yb,p6yb,p7yb,p8yb,p9yb : STD_LOGIC_VECTOR(GRAD_WIDTH-1 downto 0);

signal sY1,sY2,sX1,sX2                     : STD_LOGIC_VECTOR(GRAD_WIDTH-1 downto 0);
signal sX1a,sX1b,sX2a,sX2b                 : STD_LOGIC_VECTOR(GRAD_WIDTH-1 downto 0);
signal sY1a,sY1b,sY2a,sY2b                 : STD_LOGIC_VECTOR(GRAD_WIDTH-1 downto 0);
signal sY1c,sY2c,sXc                       : STD_LOGIC_VECTOR(GRAD_WIDTH-1 downto 0);
signal Xgrad,Ygrad,XgradM,YgradM           : STD_LOGIC_VECTOR(GRAD_WIDTH-1-16 downto 0);
signal XgradS,YgradS  	                   : STD_LOGIC;

begin
  
--1----------------------------------------
  prod1 : process (clk) -- for the frame sync signal
  begin
	if rising_edge(clk) then
    if fsync ='1' then
	
-------------------------------------------------------------------GRAD_Y_hardwired multipliers

	  p1ya <=(pData1y(GRAD_WIDTH-1) & pData1y(GRAD_WIDTH-2-7 downto 0) & (7-1 downto 0 => '0')) +  
		     (pData1y(GRAD_WIDTH-1) & pData1y(GRAD_WIDTH-2-4 downto 0) & (4-1 downto 0 => '0')); 
	  p1yb <=(pData1y(GRAD_WIDTH-1) & pData1y(GRAD_WIDTH-2 downto 0));
			 
	  p2ya <=(pData2y(GRAD_WIDTH-1) & pData2y(GRAD_WIDTH-2-8 downto 0) & (8-1 downto 0 => '0')) +  
		     (pData2y(GRAD_WIDTH-1) & pData2y(GRAD_WIDTH-2-7 downto 0) & (7-1 downto 0 => '0')); 
	  p2yb <=(pData2y(GRAD_WIDTH-1) & pData2y(GRAD_WIDTH-2-5 downto 0) & (5-1 downto 0 => '0')) +
			 (pData2y(GRAD_WIDTH-1) & pData2y(GRAD_WIDTH-2-4 downto 0) & (4-1 downto 0 => '0')) +
			 (pData2y(GRAD_WIDTH-1) & pData2y(GRAD_WIDTH-2-2 downto 0) & (2-1 downto 0 => '0')); 
			 
	  p3ya <=(pData3y(GRAD_WIDTH-1) & pData3y(GRAD_WIDTH-2-9 downto 0) & (9-1 downto 0 => '0')) +  
		     (pData3y(GRAD_WIDTH-1) & pData3y(GRAD_WIDTH-2-7 downto 0) & (7-1 downto 0 => '0')); 
	  p3yb <=(pData3y(GRAD_WIDTH-1) & pData3y(GRAD_WIDTH-2-5 downto 0) & (5-1 downto 0 => '0')) +
			 (pData3y(GRAD_WIDTH-1) & pData3y(GRAD_WIDTH-2-3 downto 0) & (3-1 downto 0 => '0')) +
			 (pData3y(GRAD_WIDTH-1) & pData3y(GRAD_WIDTH-2-1 downto 0) & (1-1 downto 0 => '0'));
			 
	  p4ya <=(pData4y(GRAD_WIDTH-1) & pData4y(GRAD_WIDTH-2-8 downto 0) & (8-1 downto 0 => '0')) +  
		     (pData4y(GRAD_WIDTH-1) & pData4y(GRAD_WIDTH-2-6 downto 0) & (6-1 downto 0 => '0')); 
	  p4yb <=(pData4y(GRAD_WIDTH-1) & pData4y(GRAD_WIDTH-2-5 downto 0) & (5-1 downto 0 => '0')) +
			 (pData4y(GRAD_WIDTH-1) & pData4y(GRAD_WIDTH-2-4 downto 0) & (4-1 downto 0 => '0'));
			 
	  p5ya <= (others => '0');
	  p5yb <= (others => '0');
	  --p5ya <= pData5x;--------DEBUG-------------
	  
	  p6ya <=(pData6y(GRAD_WIDTH-1) & pData6y(GRAD_WIDTH-2-8 downto 0) & (8-1 downto 0 => '0')) +  
		     (pData6y(GRAD_WIDTH-1) & pData6y(GRAD_WIDTH-2-6 downto 0) & (6-1 downto 0 => '0')); 
	  p6yb <=(pData6y(GRAD_WIDTH-1) & pData6y(GRAD_WIDTH-2-5 downto 0) & (5-1 downto 0 => '0')) +
			 (pData6y(GRAD_WIDTH-1) & pData6y(GRAD_WIDTH-2-4 downto 0) & (4-1 downto 0 => '0'));
			 
	  p7ya <=(pData7y(GRAD_WIDTH-1) & pData7y(GRAD_WIDTH-2-9 downto 0) & (9-1 downto 0 => '0')) +  
		     (pData7y(GRAD_WIDTH-1) & pData7y(GRAD_WIDTH-2-7 downto 0) & (7-1 downto 0 => '0')); 
	  p7yb <=(pData7y(GRAD_WIDTH-1) & pData7y(GRAD_WIDTH-2-5 downto 0) & (5-1 downto 0 => '0')) +
			 (pData7y(GRAD_WIDTH-1) & pData7y(GRAD_WIDTH-2-3 downto 0) & (3-1 downto 0 => '0')) +
			 (pData7y(GRAD_WIDTH-1) & pData7y(GRAD_WIDTH-2-1 downto 0) & (1-1 downto 0 => '0')); 
			 
	  p8ya <=(pData8y(GRAD_WIDTH-1) & pData8y(GRAD_WIDTH-2-8 downto 0) & (8-1 downto 0 => '0')) +  
		     (pData8y(GRAD_WIDTH-1) & pData8y(GRAD_WIDTH-2-7 downto 0) & (7-1 downto 0 => '0')); 
	  p8yb <=(pData8y(GRAD_WIDTH-1) & pData8y(GRAD_WIDTH-2-5 downto 0) & (5-1 downto 0 => '0')) +
			 (pData8y(GRAD_WIDTH-1) & pData8y(GRAD_WIDTH-2-4 downto 0) & (4-1 downto 0 => '0')) +
			 (pData8y(GRAD_WIDTH-1) & pData8y(GRAD_WIDTH-2-2 downto 0) & (2-1 downto 0 => '0')); 
	  
	  p9ya <=(pData9y(GRAD_WIDTH-1) & pData9y(GRAD_WIDTH-2-7 downto 0) & (7-1 downto 0 => '0')) +  
		     (pData9y(GRAD_WIDTH-1) & pData9y(GRAD_WIDTH-2-4 downto 0) & (4-1 downto 0 => '0')); 
	  p9yb <=(pData9y(GRAD_WIDTH-1) & pData9y(GRAD_WIDTH-2 downto 0));
			 
-------------------------------------------------------------------GRAD_X_hardwired multipliers

	  p1xa <=(pData1x(GRAD_WIDTH-1) & pData1x(GRAD_WIDTH-2-4 downto 0) & (4-1 downto 0 => '0'));
	  p1xb <=(others=>'0');
			 
	  p2xa <=(pData2x(GRAD_WIDTH-1) & pData2x(GRAD_WIDTH-2-6 downto 0) & (6-1 downto 0 => '0')) +  
	         (pData2x(GRAD_WIDTH-1) & pData2x(GRAD_WIDTH-2-4 downto 0) & (4-1 downto 0 => '0')); 
	  p2xb <=(pData2x(GRAD_WIDTH-1) & pData2x(GRAD_WIDTH-2-2 downto 0) & (2-1 downto 0 => '0'));
			 
	  p3xa <=(pData3x(GRAD_WIDTH-1) & pData3x(GRAD_WIDTH-2-8 downto 0) & (8-1 downto 0 => '0')) +  
	         (pData3x(GRAD_WIDTH-1) & pData3x(GRAD_WIDTH-2-5 downto 0) & (5-1 downto 0 => '0')); 
	  p3xb <=(pData3x(GRAD_WIDTH-1) & pData3x(GRAD_WIDTH-2-3 downto 0) & (3-1 downto 0 => '0'));
			 
	  p4xa <=(pData4x(GRAD_WIDTH-1) & pData4x(GRAD_WIDTH-2-9 downto 0) & (9-1 downto 0 => '0')) +  
	         (pData4x(GRAD_WIDTH-1) & pData4x(GRAD_WIDTH-2-6 downto 0) & (6-1 downto 0 => '0'));
	  p4xb <=(pData4x(GRAD_WIDTH-1) & pData4x(GRAD_WIDTH-2-5 downto 0) & (5-1 downto 0 => '0')) +
			 (pData4x(GRAD_WIDTH-1) & pData4x(GRAD_WIDTH-2-4 downto 0) & (4-1 downto 0 => '0')) +
			 (pData4x(GRAD_WIDTH-1) & pData4x(GRAD_WIDTH-2-1 downto 0) & (1-1 downto 0 => '0'));
			 
	  p5xa <=(pData5x(GRAD_WIDTH-1) & pData5x(GRAD_WIDTH-2-9 downto 0) & (9-1 downto 0 => '0')) +  
	         (pData5x(GRAD_WIDTH-1) & pData5x(GRAD_WIDTH-2-8 downto 0) & (8-1 downto 0 => '0'));
	  p5xb <=(pData5x(GRAD_WIDTH-1) & pData5x(GRAD_WIDTH-2-5 downto 0) & (5-1 downto 0 => '0')) +
			 (pData5x(GRAD_WIDTH-1) & pData5x(GRAD_WIDTH-2-2 downto 0) & (2-1 downto 0 => '0'));

	  p6xa <=(pData6x(GRAD_WIDTH-1) & pData6x(GRAD_WIDTH-2-9 downto 0) & (9-1 downto 0 => '0')) +  
	         (pData6x(GRAD_WIDTH-1) & pData6x(GRAD_WIDTH-2-6 downto 0) & (6-1 downto 0 => '0')); 
	  p6xb <=(pData6x(GRAD_WIDTH-1) & pData6x(GRAD_WIDTH-2-5 downto 0) & (5-1 downto 0 => '0')) +
			 (pData6x(GRAD_WIDTH-1) & pData6x(GRAD_WIDTH-2-4 downto 0) & (4-1 downto 0 => '0')) +
			 (pData6x(GRAD_WIDTH-1) & pData6x(GRAD_WIDTH-2-1 downto 0) & (1-1 downto 0 => '0'));

	  p7xa <=(pData7x(GRAD_WIDTH-1) & pData7x(GRAD_WIDTH-2-8 downto 0) & (8-1 downto 0 => '0')) +  
		     (pData7x(GRAD_WIDTH-1) & pData7x(GRAD_WIDTH-2-5 downto 0) & (5-1 downto 0 => '0')); 
	  p7xb <=(pData7x(GRAD_WIDTH-1) & pData7x(GRAD_WIDTH-2-3 downto 0) & (3-1 downto 0 => '0'));		 

	  p8xa <=(pData8x(GRAD_WIDTH-1) & pData8x(GRAD_WIDTH-2-6 downto 0) & (6-1 downto 0 => '0')) +  
		     (pData8x(GRAD_WIDTH-1) & pData8x(GRAD_WIDTH-2-4 downto 0) & (4-1 downto 0 => '0')); 
	  p8xb <=(pData8x(GRAD_WIDTH-1) & pData8x(GRAD_WIDTH-2-2 downto 0) & (2-1 downto 0 => '0'));

	  p9xa <= (pData9x(GRAD_WIDTH-1) & pData9x(GRAD_WIDTH-2-4 downto 0) & (4-1 downto 0 => '0'));
	  p9xb <=(others=>'0');
			 
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
	  --sY1a <= p5y; ----DEBUG-----------
	  sY1a <= p1y+p2y;
	  SY1b <= p3y+p4y;
	  sY2a <= p6y+p7y;
	  sY2b <= p8y+p9y;
	  sX1a <= p1x+p2x;
	  sX1b <= p3x+p4x;
	  sX2a <= p5x+p6x;
      sX2b <= p7x+p8x+p9x;		  
	end if;
	end if;
  end process sum1; 
 
--4---------------------------------------- 
  sum2 : process (clk) 
  begin
	if rising_edge(clk) then
    if fsync ='1' then
	  --sY1 <= sY1a; ----DEBUG-----------
	  sY1 <= sY1a+sY1b;
	  sY2 <= sY2a+sY2b;
	  sX1 <= sX1a+sX1b;
	  sX2 <= sX2a+sX2b;
	end if;	
	end if;
  end process sum2; 

--5---------------------------------------- 
  sum3 : process (clk) -- for the frame sync signal
  begin
	if rising_edge(clk) then
    if fsync ='1' then
	    sY2c <= (not sY2) + 1;
	    sY1c <= Sy1;
	    sXc  <= sX1+sX2;
	end if;	
	end if;
  end process sum3;

--6---------------------------------------- 
  outp : process (clk) 
  begin
	if rising_edge(clk) then
    if fsync ='1' then
		--Ygrad <= sY1c(15 downto 0); -------DEBUG-------
	    Ygrad <= sY1c(GRAD_WIDTH-1 downto 16)+sY2c(GRAD_WIDTH-1 downto 16);
		Xgrad <= (not sXc(GRAD_WIDTH-1 downto 16)) + 1;
	end if;	
	end if;
  end process outp;
  
--7---------------------------------------- 
  mag : process (clk)
  begin
	if rising_edge(clk) then
    if fsync ='1' then
	  if Ygrad(GRAD_WIDTH-1-16)='1' then
		YgradM <= (not Ygrad) + 1;
	  else
	    YgradM <= Ygrad;
	  end if;	  
	  if Xgrad(GRAD_WIDTH-1-16)='1' then
		XgradM <= (not Xgrad) + 1;
	  else
	    XgradM <= Xgrad;
	  end if;	
	  XgradS <= Xgrad(GRAD_WIDTH-1-16);
	  YgradS <= Ygrad(GRAD_WIDTH-1-16);
	end if;	
	end if;
  end process ;
  
--8---------------------------------------- 
  outMag : process (clk)
  begin
	if rising_edge(clk) then
    if fsync ='1' then
	  Mdata_o <= XgradM + YgradM;
	  --Mdata_o <= YgradM; ----------------DEBUG-------------
	end if;	
	end if;
  end process ;
  
-------------------------------------------------------------------------------------------------------
-- If we want to get get rid of the atan2() we can just use tan(Gy/Gx): 
-- basically the tangent of the angle T defined by Gx and Gy is Gy/Gx: tan(T) = Gy/Gx.
-- So we just have to compare Gy/Gx against the tangent of the reference angle,
-- which are the following constants:
-- tan( p/8) = v2 - 1 ~ 1/2
-- tan(3p/8) = v2 + 1 ~ 2
-- And to avoid the division of Gy/Gx, we can simply compare Gy against Gx multiplied by these constants
-------------------------------------------------------------------------------------------------------
 
--8 
------------------------------------------------------------
  edge_sobel_getdir2: process (clk)
  begin
	if rising_edge(clk) then 
    if fsync ='1' then
      if    YgradM(GRAD_WIDTH-1-16 downto 0) < ('0' & XgradM(GRAD_WIDTH-1-16 downto 1)) then Ddata_o <= "01"; --DIRECTION_HORIZONTAL
      elsif ('0' & YgradM(GRAD_WIDTH-1-16 downto 1)) > XgradM(GRAD_WIDTH-1-16 downto 0) then Ddata_o <= "00"; -- DIRECTION_VERTICAL
      else 
	    if XgradS = YgradS then Ddata_o <= "10"; -- DIRECTION_45R
		else Ddata_o <= "11"; -- DIRECTION_45F
        end if;
	  end if;
	  --Ddata_o <= Ygrada(1 downto 0); ---------DEBUG-------------
	end if;
	end if;
  end process edge_sobel_getdir2;	  



end Behavioral;