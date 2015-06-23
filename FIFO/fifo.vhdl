-------------------------------------------------------------------------------
-- 
-- Copyright Jamil Khatib 1999
-- 
--
-- This VHDL design file is an open design; you can redistribute it and/or
-- modify it and/or implement it under the terms of the Openip General Public
-- License as it is going to be published by the OpenIP Organization and any
-- coming versions of this license.
-- You can check the draft license at
-- http://www.openip.org/oc/license.html
--
--
-- Creator : Jamil Khatib
-- Date 10/10/99
--
-- version 0.19991226
--
-- This file was tested on the ModelSim 5.2EE
-- The test vecors for model sim is included in vectors.do file
-- This VHDL design file is proved through simulation but not verified on Silicon
-- 
--
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------


LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

USE ieee.std_logic_unsigned.ALL;



-- Dual port Memory core



ENTITY dpmem IS
generic ( ADD_WIDTH: integer := 8 ;
		 WIDTH : integer := 8);
  PORT (
    clk      : IN  std_logic;                                -- write clock
    reset    : IN  std_logic;                                -- System Reset
    W_add    : IN  std_logic_vector(add_width -1 downto 0);  -- Write Address
    R_add    : IN  std_logic_vector(add_width -1 downto 0);  -- Read Address
    Data_In  : IN  std_logic_vector(WIDTH - 1  DOWNTO 0);    -- input data
    Data_Out : OUT std_logic_vector(WIDTH -1   DOWNTO 0);    -- output Data
    WR       : IN  std_logic;                                -- Write Enable
    RE       : IN  std_logic);                               -- Read Enable
END dpmem;

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

ARCHITECTURE dpmem_v3 OF dpmem IS


  TYPE data_array IS ARRAY (integer range <>) OF std_logic_vector(WIDTH -1  DOWNTO 0);
                                        -- Memory Type
  SIGNAL data : data_array(0 to (2** add_width) );  -- Local data



  procedure init_mem(signal memory_cell : inout data_array ) is
  begin

    for i in 0 to (2** add_width) loop
      memory_cell(i) <= (others => '0');
    end loop;

  end init_mem;


BEGIN  -- dpmem_v3

  PROCESS (clk, reset)

  BEGIN  -- PROCESS


    -- activities triggered by asynchronous reset (active low)
    IF reset = '0' THEN
      data_out <= (OTHERS => '1');
      init_mem ( data);

      -- activities triggered by rising edge of clock
    ELSIF clk'event AND clk = '1' THEN
      IF RE = '1' THEN
        data_out <= data(conv_integer(R_add));
      else
        data_out <= (OTHERS => '1');    -- Defualt value
      END IF;

      IF WR = '1' THEN
        data(conv_integeR(W_add)) <= Data_In;
      END IF;
    END IF;



  END PROCESS;


END dpmem_v3;


-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
USE ieee.std_logic_signed.ALL;
USE ieee.std_logic_arith.ALL;


entity FIFO is
    
    generic (WIDTH : integer := 8;  	-- FIFO word width
	     ADD_WIDTH : integer := 8); -- Address Width

    port (Data_in : in std_logic_vector(WIDTH - 1 downto 0);  -- Input data
	  Data_out : out std_logic_vector(WIDTH - 1 downto 0);  -- Out put data
	  clk : in std_logic;  		-- System Clock
	  Reset : in std_logic;  	-- System global Reset
	  RE : in std_logic;  		-- Read Enable
	  WE : in std_logic;  		-- Write Enable
	  Full : buffer std_logic;  	-- Full Flag
	  Half_full : out std_logic;  	-- Half Full Flag
	  Empty : buffer std_logic); 	-- Empty Flag

end FIFO;

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

-- Input data _is_ latched

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--USE ieee.std_logic_signed.ALL;
--USE ieee.std_logic_arith.ALL;

-------------------------------------------------------------------------------
-- purpose: FIFO Architecture
architecture FIFO_v1 of FIFO is

-- constant values
	constant MAX_ADDR:std_logic_vector(ADD_WIDTH -1 downto 0) := (others => '1');
	constant MIN_ADDR:std_logic_vector(ADD_WIDTH -1 downto 0) := (others => '0');
        constant HALF_ADDR:std_logic_vector(ADD_WIDTH -1 downto 0) := '0' & (MAX_ADDR'range => '1');
	
 
	signal Data_in_del : std_logic_vector(WIDTH - 1 downto 0);  -- delayed Data in


    signal R_ADD   : std_logic_vector(ADD_WIDTH - 1 downto 0);  -- Read Address
    signal W_ADD   : std_logic_vector(ADD_WIDTH - 1 downto 0);  -- Write Address
	signal D_ADD   : std_logic_vector(ADD_WIDTH - 1 downto 0);  -- Diff Address

    signal REN_INT : std_logic;  		-- Internal Read Enable
    signal WEN_INT : std_logic;  		-- Internal Write Enable

	component dpmem
	    generic (ADD_WIDTH : integer := 8;
	   			 WIDTH : integer := 8 );

    	port (clk : in std_logic;
	    reset : in std_logic;
	  	w_add : in std_logic_vector(ADD_WIDTH -1  downto 0 );
	    r_add : in std_logic_vector(ADD_WIDTH -1 downto 0 );
	    data_in : in std_logic_vector(WIDTH - 1 downto 0);
	    data_out : out std_logic_vector(WIDTH - 1 downto 0 );
	    WR  : in std_logic;
	    RE  : in std_logic);
	end component;

	
    
begin  -- FIFO_v1
-------------------------------------------------------------------------------
        
memcore: dpmem 
generic map (WIDTH => 8,
				ADD_WIDTH =>8)
	port map (clk => clk,
			 reset => reset,
			 w_add => w_add,
			 r_add => r_add,
			 Data_in => data_in_del,
			 data_out => data_out,
			 wr => wen_int,
			 re => ren_int);

-------------------------------------------------------------------------------

Sync_data: process(clk,reset)
	begin -- process Sync_data
		if reset ='0' then
			data_in_del <= (others =>'0');

		elsif clk'event and clk = '1'  then
			data_in_del <= data_in;
		else 
			data_in_del <= data_in_del;
		end if;


	end process Sync_data;

-------------------------------------------------------------------------------

wen_int <= '1' when (WE = '1' and ( FULL = '0')) else '0';

ren_int <= '1' when RE = '1' and ( EMPTY = '0') else '0';

--w_r_gen: process(we,re,FULL,EMPTY)
 
--begin
	
--	if WE = '1' and (FULL = '0') then
--			wen_int <= '1';
--        else
--	   	 	wen_int <= '0';

--    end if;

--	if RE = '1' and ( EMPTY = '0') then
--   		ren_int <= '1';
--     else
--   		ren_int <= '0';
--    end if;

--end process w_r_gen;

-------------------------------------------------------------------------------


Add_gen: process(clk,reset)    
	variable q1 : std_logic_vector(ADD_WIDTH - 1 downto 0);  -- Counter state
	variable q2 : std_logic_vector(ADD_WIDTH - 1 downto 0);  -- Counter state
	variable q3 : std_logic_vector(ADD_WIDTH - 1 downto 0);  -- Counter state

   begin  -- process ADD_gen

       -- activities triggered by asynchronous reset (active low)
       if reset = '0' then
	   		q1 := (others =>'0');
	   		q2 := (others =>'0');
	   		q3 := (others =>'0');
--			wen_int <= '0';
--			ren_int <= '0';
       -- activities triggered by rising edge of clock
       elsif clk'event and clk = '1'  then
		
		if WE = '1' and ( FULL = '0') then
	   		q1 := q1 + 1;
			q3 := q3 +1;
		   --	wen_int <= '1';
        else
	   		q1 := q1;
			q3 := q3;
			--wen_int <= '0';

	    end if;

		if RE = '1' and ( EMPTY = '0') then
	   		q2 := q2 + 1;
			q3 := q3 -1;
			--ren_int <= '1';
        else
	   		q2 := q2;
			q3 := q3;
			--ren_int <= '0';
	    end if;
			
       end if;
		
	    R_ADD  <= q2;
		W_ADD  <= q1;
		D_ADD  <= q3;

   end process ADD_gen;

-------------------------------------------------------------------------------

	FULL      <=  '1'when (D_ADD(ADD_WIDTH - 1 downto 0) = MAX_ADDR) else '0';
	EMPTY     <=  '1'when (D_ADD(ADD_WIDTH - 1 downto 0) =  MIN_ADDR) else '0';
	HALF_FULL <=  '1'when (D_ADD(ADD_WIDTH - 1 downto 0) >  HALF_ADDR) else '0';


-------------------------------------------------------------------------------

    
    
end FIFO_v1;

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Ren_int & Wen_int are synchronized with the clock

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--USE ieee.std_logic_signed.ALL;
--USE ieee.std_logic_arith.ALL;

-------------------------------------------------------------------------------
-- purpose: FIFO Architecture
architecture FIFO_v2 of FIFO is

-- constant values
	constant MAX_ADDR:std_logic_vector(ADD_WIDTH -1 downto 0) := (others => '1');
	constant MIN_ADDR:std_logic_vector(ADD_WIDTH -1 downto 0) := (others => '0');
constant HALF_ADDR:std_logic_vector(ADD_WIDTH -1 downto 0) := '0' & (MAX_ADDR'range => '1');
	
 
    signal R_ADD   : std_logic_vector(ADD_WIDTH - 1 downto 0);  -- Read Address
    signal W_ADD   : std_logic_vector(ADD_WIDTH - 1 downto 0);  -- Write Address
	signal D_ADD   : std_logic_vector(ADD_WIDTH - 1 downto 0);  -- Diff Address

    signal REN_INT : std_logic;  		-- Internal Read Enable
    signal WEN_INT : std_logic;  		-- Internal Write Enable

	component dpmem
	    generic (ADD_WIDTH : integer := 8;
	   			 WIDTH : integer := 8 );

    	port (clk : in std_logic;
	    reset : in std_logic;
	  	w_add : in std_logic_vector(ADD_WIDTH -1 downto 0 );
	    r_add : in std_logic_vector(ADD_WIDTH -1 downto 0 );
	    data_in : in std_logic_vector(WIDTH - 1 downto 0);
	    data_out : out std_logic_vector(WIDTH - 1 downto 0 );
	    WR  : in std_logic;
	    RE  : in std_logic);
	end component;

	
    
begin  -- FIFO_v2

-------------------------------------------------------------------------------
        
memcore: dpmem 
	generic map (WIDTH => 8,
				ADD_WIDTH =>8)

	port map (clk => clk,
			 reset => reset,
			 w_add => w_add,
			 r_add => r_add,
			 Data_in => data_in,
			 data_out => data_out,
			 wr => wen_int,
			 re => ren_int);

-------------------------------------------------------------------------------

cont_gen: process(clk,reset)    
   begin  -- process cont_gen

       -- activities triggered by asynchronous reset (active low)
       if reset = '0' then
	   		wen_int <= '0';
			ren_int <= '0';
       -- activities triggered by rising edge of clock
       elsif clk'event and clk = '1'  then
		
		if WE = '1' and (not FULL = '1') then
	   		wen_int <= '1';
        else
	   		wen_int <= '0';

	    end if;

		if RE = '1' and (not EMPTY = '1') then
	   		ren_int <= '1';
        else
	   		ren_int <= '0';
	    end if;
			
       end if;
		
   end process cont_gen;


-------------------------------------------------------------------------------

Add_gen: process(clk,reset)    
	variable q1 : std_logic_vector(ADD_WIDTH - 1 downto 0);  -- Counter state
	variable q2 : std_logic_vector(ADD_WIDTH - 1 downto 0);  -- Counter state
	variable q3 : std_logic_vector(ADD_WIDTH - 1 downto 0);  -- Counter state

   begin  -- process ADD_gen

       -- activities triggered by asynchronous reset (active low)
       if reset = '0' then
	   		q1 := (others =>'0');
	   		q2 := (others =>'0');
	   		q3 := (others =>'0');
        -- activities triggered by rising edge of clock
       elsif clk'event and clk = '1'  then
		
		if WE = '1' and ( FULL = '0') then
	   		q1 := q1 + 1;
			q3 := q3 +1;
         else
	   		q1 := q1;
			q3 := q3;

	    end if;

		if RE = '1' and ( EMPTY = '0') then
	   		q2 := q2 + 1;
			q3 := q3 -1;
        else
	   		q2 := q2;
			q3 := q3;
	    end if;
			
       end if;
		
	    R_ADD  <= q2;
		W_ADD  <= q1;
		D_ADD  <= q3;

   end process ADD_gen;

-------------------------------------------------------------------------------

   	FULL      <=  '1'when (D_ADD(ADD_WIDTH - 1 downto 0) =  MAX_ADDR) else '0';
	EMPTY     <=  '1'when (D_ADD(ADD_WIDTH - 1 downto 0) =  MIN_ADDR) else '0';
	HALF_FULL <=  '1'when (D_ADD(ADD_WIDTH - 1 downto 0) >  HALF_ADDR) else '0';

-------------------------------------------------------------------------------
    
end FIFO_v2;

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

-- Input data is _NOT_ latched

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--USE ieee.std_logic_signed.ALL;
--USE ieee.std_logic_arith.ALL;

-------------------------------------------------------------------------------
-- purpose: FIFO Architecture
architecture FIFO_v3 of FIFO is

-- constant values
	constant MAX_ADDR:std_logic_vector(ADD_WIDTH -1 downto 0) := (others => '1');
	constant MIN_ADDR:std_logic_vector(ADD_WIDTH -1 downto 0) := (others => '0');
        constant HALF_ADDR:std_logic_vector(ADD_WIDTH -1 downto 0) := '0' & (MAX_ADDR'range => '1');

	

    signal R_ADD   : std_logic_vector(ADD_WIDTH - 1 downto 0);  -- Read Address
    signal W_ADD   : std_logic_vector(ADD_WIDTH - 1 downto 0);  -- Write Address
	signal D_ADD   : std_logic_vector(ADD_WIDTH - 1 downto 0);  -- Diff Address

    signal REN_INT : std_logic;  		-- Internal Read Enable
    signal WEN_INT : std_logic;  		-- Internal Write Enable

	component dpmem
	    generic (ADD_WIDTH : integer := 8;
	   			 WIDTH : integer := 8 );

    	port (clk : in std_logic;
	    reset : in std_logic;
	  	w_add : in std_logic_vector(ADD_WIDTH -1 downto 0 );
	    r_add : in std_logic_vector(ADD_WIDTH -1 downto 0 );
	    data_in : in std_logic_vector(WIDTH - 1 downto 0);
	    data_out : out std_logic_vector(WIDTH - 1 downto 0 );
	    WR  : in std_logic;
	    RE  : in std_logic);
	end component;

	
    
begin  -- FIFO_v3

-------------------------------------------------------------------------------        

memcore: dpmem 
generic map (WIDTH => 8,
				ADD_WIDTH =>8)
	port map (clk => clk,
			 reset => reset,
			 w_add => w_add,
			 r_add => r_add,
			 Data_in => data_in,
			 data_out => data_out,
			 wr => wen_int,
			 re => ren_int);

-------------------------------------------------------------------------------

wen_int <= '1' when (WE = '1' and ( FULL = '0')) else '0';

ren_int <= '1' when RE = '1' and ( EMPTY = '0') else '0';


-------------------------------------------------------------------------------

Add_gen: process(clk,reset)    
	variable q1 : std_logic_vector(ADD_WIDTH - 1 downto 0);  -- Counter state
	variable q2 : std_logic_vector(ADD_WIDTH - 1 downto 0);  -- Counter state
	variable q3 : std_logic_vector(ADD_WIDTH - 1 downto 0);  -- Counter state

   begin  -- process ADD_gen

       -- activities triggered by asynchronous reset (active low)
       if reset = '0' then
	   		q1 := (others =>'0');
	   		q2 := (others =>'0');
	   		q3 := (others =>'0');
       -- activities triggered by rising edge of clock
       elsif clk'event and clk = '1'  then
		
		if WE = '1' and ( FULL = '0') then
	   		q1 := q1 + 1;
			q3 := q3 +1;
        else
	   		q1 := q1;
			q3 := q3;

	    end if;

		if RE = '1' and ( EMPTY = '0') then
	   		q2 := q2 + 1;
			q3 := q3 -1;
        else
	   		q2 := q2;
			q3 := q3;
	    end if;
			
       end if;
		
	    R_ADD  <= q2;
		W_ADD  <= q1;
		D_ADD  <= q3;

   end process ADD_gen;

-------------------------------------------------------------------------------

	FULL      <=  '1'when (D_ADD(ADD_WIDTH - 1 downto 0) = MAX_ADDR) else '0';
	EMPTY     <=  '1'when (D_ADD(ADD_WIDTH - 1 downto 0) =  MIN_ADDR) else '0';
	HALF_FULL <=  '1'when (D_ADD(ADD_WIDTH - 1 downto 0) >  HALF_ADDR) else '0';


-------------------------------------------------------------------------------

        
end FIFO_v3;


-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

-- This arch was synthesized by webfitter 
-- It is the same as fifo_v1 but
-- 1. address variables was changed to signals
-- 2. else statement was removed from process sync_data
-- 3. address-width was changed to 3 instead of 8
-- Input data _is_ latched

library ieee;
-- numeric package genertes compile error by webfitter compiler
use ieee.std_logic_1164.all;
USE ieee.std_logic_signed.ALL;
USE ieee.std_logic_arith.ALL;

-------------------------------------------------------------------------------
-- purpose: FIFO Architecture
architecture FIFO_v4 of FIFO is

-- constant values
	constant MAX_ADDR:std_logic_vector(ADD_WIDTH -1 downto 0) := (others => '1');
	constant MIN_ADDR:std_logic_vector(ADD_WIDTH -1 downto 0) := (others => '0');
        constant HALF_ADDR:std_logic_vector(ADD_WIDTH -1 downto 0) := '0' & (MAX_ADDR'range => '1');
 
        constant HALF_ADDR:std_logic_vector(ADD_WIDTH -1 downto 0) := '0' & (MAX_ADDR'range => '1');
      
 
	signal Data_in_del : std_logic_vector(WIDTH - 1 downto 0);  -- delayed Data in


    signal R_ADD   : std_logic_vector(ADD_WIDTH - 1 downto 0);  -- Read Address
    signal W_ADD   : std_logic_vector(ADD_WIDTH - 1 downto 0);  -- Write Address
	signal D_ADD   : std_logic_vector(ADD_WIDTH - 1 downto 0);  -- Diff Address

    signal REN_INT : std_logic;  		-- Internal Read Enable
    signal WEN_INT : std_logic;  		-- Internal Write Enable

	component dpmem
	    generic (ADD_WIDTH : integer := 8;
	   			 WIDTH : integer := 8 );

    	port (clk : in std_logic;
	    reset : in std_logic;
	  	w_add : in std_logic_vector(ADD_WIDTH -1  downto 0 );
	    r_add : in std_logic_vector(ADD_WIDTH -1  downto 0 );
	    data_in : in std_logic_vector(WIDTH - 1 downto 0);
	    data_out : out std_logic_vector(WIDTH - 1 downto 0 );
	    WR  : in std_logic;
	    RE  : in std_logic);
	end component;

	
    
begin  -- FIFO_v4
-------------------------------------------------------------------------------
        
memcore: dpmem 
generic map (WIDTH => 8,
				ADD_WIDTH =>8)
	port map (clk => clk,
			 reset => reset,
			 w_add => w_add,
			 r_add => r_add,
			 Data_in => data_in_del,
			 data_out => data_out,
			 wr => wen_int,
			 re => ren_int);

-------------------------------------------------------------------------------

Sync_data: process(clk,reset)
	begin -- process Sync_data
		if reset ='0' then
			data_in_del <= (others =>'0');

		elsif clk'event and clk = '1'  then
			data_in_del <= data_in;

-- else statemnet was removed due to error (hdl 
-- 
		end if;


	end process Sync_data;

-------------------------------------------------------------------------------

wen_int <= '1' when (WE = '1' and ( FULL = '0')) else '0';

ren_int <= '1' when RE = '1' and ( EMPTY = '0') else '0';

-------------------------------------------------------------------------------


Add_gen: process(clk,reset)    
-- The variables was replaced by add signals

   begin  -- process ADD_gen

       -- activities triggered by asynchronous reset (active low)
       if reset = '0' then
	   		W_ADD <= (others =>'0');
	   		R_ADD <= (others =>'0');
	   		D_ADD <= (others =>'0');
       -- activities triggered by rising edge of clock
       elsif clk'event and clk = '1'  then
		
		if WE = '1' and ( FULL = '0') then
	   		W_ADD <= W_ADD + 1;
			D_ADD <= D_ADD +1;
--        else
--	   		W_ADD <= W_ADD;
--			D_ADD <= D_ADD;

	    end if;

		if RE = '1' and ( EMPTY = '0') then
	   		R_ADD <= R_ADD + 1;
			D_ADD <= D_ADD -1;
--        else
--	   		R_ADD <= R_ADD;
--			D_ADD <= D_ADD;
	    end if;
			
       end if;
		

   end process ADD_gen;

-------------------------------------------------------------------------------

	FULL      <=  '1'when (D_ADD(ADD_WIDTH - 1 downto 0) = MAX_ADDR) else '0';
	EMPTY     <=  '1'when (D_ADD(ADD_WIDTH - 1 downto 0) =  MIN_ADDR) else '0';
	HALF_FULL <=  '1'when (D_ADD(ADD_WIDTH - 1 downto 0) >  HALF_ADDR) else '0';


-------------------------------------------------------------------------------

    
    
end FIFO_v4;

-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

-- synthesized using webfitter
-- Input data is _NOT_ latched
-- The same as fifo_v3 but without the use of the variables in add_gen process
-- else case in add_gen "RE and WE" was removed

library ieee;
use ieee.std_logic_1164.all;
--use ieee.numeric_std.all;
USE ieee.std_logic_signed.ALL;
USE ieee.std_logic_arith.ALL;

-------------------------------------------------------------------------------
-- purpose: FIFO Architecture
architecture FIFO_v5 of FIFO is

-- constant values
	constant MAX_ADDR:std_logic_vector(ADD_WIDTH -1 downto 0) := (others => '1');
	constant MIN_ADDR:std_logic_vector(ADD_WIDTH -1 downto 0) := (others => '0');
        constant HALF_ADDR:std_logic_vector(ADD_WIDTH -1 downto 0) := '0' & (MAX_ADDR'range => '1');
        

    signal R_ADD   : std_logic_vector(ADD_WIDTH - 1 downto 0);  -- Read Address
    signal W_ADD   : std_logic_vector(ADD_WIDTH - 1 downto 0);  -- Write Address
	signal D_ADD   : std_logic_vector(ADD_WIDTH - 1 downto 0);  -- Diff Address

    signal REN_INT : std_logic;  		-- Internal Read Enable
    signal WEN_INT : std_logic;  		-- Internal Write Enable

	component dpmem
	    generic (ADD_WIDTH : integer := 8;
	   			 WIDTH : integer := 8 );

    	port (clk : in std_logic;
	    reset : in std_logic;
	  	w_add : in std_logic_vector(ADD_WIDTH -1 downto 0 );
	    r_add : in std_logic_vector(ADD_WIDTH -1 downto 0 );
	    data_in : in std_logic_vector(WIDTH - 1 downto 0);
	    data_out : out std_logic_vector(WIDTH - 1 downto 0 );
	    WR  : in std_logic;
	    RE  : in std_logic);
	end component;

	
    
begin  -- FIFO_v5

-------------------------------------------------------------------------------        

memcore: dpmem 
generic map (WIDTH => 8,
				ADD_WIDTH =>8)
	port map (clk => clk,
			 reset => reset,
			 w_add => w_add,
			 r_add => r_add,
			 Data_in => data_in,
			 data_out => data_out,
			 wr => wen_int,
			 re => ren_int);

-------------------------------------------------------------------------------

wen_int <= '1' when (WE = '1' and ( FULL = '0')) else '0';

ren_int <= '1' when RE = '1' and ( EMPTY = '0') else '0';


-------------------------------------------------------------------------------

Add_gen: process(clk,reset)    

   begin  -- process ADD_gen

       -- activities triggered by asynchronous reset (active low)
       if reset = '0' then
	   		W_ADD <= (others =>'0');
	   		R_ADD <= (others =>'0');
	   		D_ADD <= (others =>'0');
       -- activities triggered by rising edge of clock
       elsif clk'event and clk = '1'  then
		
		if WE = '1' and ( FULL = '0') then
	   		W_ADD <= W_ADD + 1;
			D_ADD <= D_ADD +1;
--        else
--	   		W_ADD <= W_ADD;
--			D_ADD <= D_ADD;

	    end if;

		if RE = '1' and ( EMPTY = '0') then
	   		R_ADD <= R_ADD + 1;
			D_ADD <= D_ADD -1;
--        else
--	   		R_ADD <= R_ADD;
--			D_ADD <= D_ADD;
	    end if;
			
       end if;
		
--	    R_ADD  <= q2;
--		W_ADD  <= q1;
--		D_ADD  <= q3;

   end process ADD_gen;

-------------------------------------------------------------------------------

	FULL      <=  '1'when (D_ADD(ADD_WIDTH - 1 downto 0) = MAX_ADDR) else '0';
	EMPTY     <=  '1'when (D_ADD(ADD_WIDTH - 1 downto 0) =  MIN_ADDR) else '0';
	HALF_FULL <=  '1'when (D_ADD(ADD_WIDTH - 1 downto 0) >  HALF_ADDR) else '0';


-------------------------------------------------------------------------------

        
end FIFO_v5;

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

-- Exactly teh same as FIFO_v5 but ieee.numeric_std.all is used

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--USE ieee.std_logic_signed.ALL;
--USE ieee.std_logic_arith.ALL;

-------------------------------------------------------------------------------
-- purpose: FIFO Architecture
architecture FIFO_v6 of FIFO is

-- constant values
	constant MAX_ADDR:std_logic_vector(ADD_WIDTH -1 downto 0) := (others => '1');
	constant MIN_ADDR:std_logic_vector(ADD_WIDTH -1 downto 0) := (others => '0');
        constant HALF_ADDR:std_logic_vector(ADD_WIDTH -1 downto 0) := '0' & (MAX_ADDR'range => '1');

    signal R_ADD   : std_logic_vector(ADD_WIDTH - 1 downto 0);  -- Read Address
    signal W_ADD   : std_logic_vector(ADD_WIDTH - 1 downto 0);  -- Write Address
	signal D_ADD   : std_logic_vector(ADD_WIDTH - 1 downto 0);  -- Diff Address

    signal REN_INT : std_logic;  		-- Internal Read Enable
    signal WEN_INT : std_logic;  		-- Internal Write Enable

	component dpmem
	    generic (ADD_WIDTH : integer := 8;
	   			 WIDTH : integer := 8 );

    	port (clk : in std_logic;
	    reset : in std_logic;
	  	w_add : in std_logic_vector(ADD_WIDTH -1 downto 0 );
	    r_add : in std_logic_vector(ADD_WIDTH -1 downto 0 );
	    data_in : in std_logic_vector(WIDTH - 1 downto 0);
	    data_out : out std_logic_vector(WIDTH - 1 downto 0 );
	    WR  : in std_logic;
	    RE  : in std_logic);
	end component;

	
    
begin  -- FIFO_v6

-------------------------------------------------------------------------------        

memcore: dpmem 
generic map (WIDTH => 8,
				ADD_WIDTH =>8)
	port map (clk => clk,
			 reset => reset,
			 w_add => w_add,
			 r_add => r_add,
			 Data_in => data_in,
			 data_out => data_out,
			 wr => wen_int,
			 re => ren_int);

-------------------------------------------------------------------------------

wen_int <= '1' when (WE = '1' and ( FULL = '0')) else '0';

ren_int <= '1' when RE = '1' and ( EMPTY = '0') else '0';


-------------------------------------------------------------------------------

Add_gen: process(clk,reset)    

   begin  -- process ADD_gen

       -- activities triggered by asynchronous reset (active low)
       if reset = '0' then
	   		W_ADD <= (others =>'0');
	   		R_ADD <= (others =>'0');
	   		D_ADD <= (others =>'0');
       -- activities triggered by rising edge of clock
       elsif clk'event and clk = '1'  then
		
		if WE = '1' and ( FULL = '0') then
	   		W_ADD <= W_ADD + 1;
			D_ADD <= D_ADD +1;
--        else
--	   		W_ADD <= W_ADD;
--			D_ADD <= D_ADD;

	    end if;

		if RE = '1' and ( EMPTY = '0') then
	   		R_ADD <= R_ADD + 1;
			D_ADD <= D_ADD -1;
--        else
--	   		R_ADD <= R_ADD;
--			D_ADD <= D_ADD;
	    end if;
			
       end if;
		
--	    R_ADD  <= q2;
--		W_ADD  <= q1;
--		D_ADD  <= q3;

   end process ADD_gen;

-------------------------------------------------------------------------------

	FULL      <=  '1'when (D_ADD(ADD_WIDTH - 1 downto 0) = MAX_ADDR) else '0';
	EMPTY     <=  '1'when (D_ADD(ADD_WIDTH - 1 downto 0) =  MIN_ADDR) else '0';
	HALF_FULL <=  '1'when (D_ADD(ADD_WIDTH - 1 downto 0) >  HALF_ADDR) else '0';


-------------------------------------------------------------------------------

        
end FIFO_v6;

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

-- 1- Synchronous FIFO
-- 2- Read & write are synchronized to the same clock
-- 3- Input data should be stable one clock after Wr
-- 4- 


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
-------------------------------------------------------------------------------
-- purpose: FIFO Architecture
architecture FIFO_v7 of FIFO is

-- constant values
	constant MAX_ADDR:std_logic_vector(ADD_WIDTH -1 downto 0) := (others => '1');
	constant MIN_ADDR:std_logic_vector(ADD_WIDTH -1 downto 0) := (others => '0');
        constant HALF_ADDR:std_logic_vector(ADD_WIDTH -1 downto 0) := '0' & (MAX_ADDR'range => '1');
	

-- Internal signals
    signal R_ADD   : std_logic_vector(ADD_WIDTH - 1 downto 0);  -- Read Address
    signal W_ADD   : std_logic_vector(ADD_WIDTH - 1 downto 0);  -- Write Address

    signal REN_INT : std_logic;  		-- Internal Read Enable
    signal WEN_INT : std_logic;  		-- Internal Write Enable

--	signal int_full : std_logic;
--	signal int_empty : std_logic;

	signal datainREG : std_logic_vector(WIDTH - 1 downto 0);	-- Data in regiester
	signal dataoutREG : std_logic_vector(WIDTH - 1 downto 0);	-- Data out regiester


	component dpmem
	    generic (ADD_WIDTH : integer := 4;
	   			 WIDTH : integer := 8 );

    	port (clk : in std_logic;
	    reset : in std_logic;
	  	w_add : in std_logic_vector(ADD_WIDTH -1 downto 0 );
	    r_add : in std_logic_vector(ADD_WIDTH -1 downto 0 );
	    data_in : in std_logic_vector(WIDTH - 1 downto 0);
	    data_out : out std_logic_vector(WIDTH - 1 downto 0 );
	    WR  : in std_logic;
	    RE  : in std_logic);
	end component;

	
    
begin  -- FIFO_v7

-------------------------------------------------------------------------------        

memcore: dpmem 
generic map (WIDTH => 8,
				ADD_WIDTH =>4)
	port map (clk => clk,
			 reset => reset,
			 w_add => w_add,
			 r_add => r_add,
			 Data_in => datainREG,
			 data_out => dataoutREG,
			 wr => wen_int,
			 re => re);

-------------------------------------------------------------------------------

Add_gen: process(clk,reset)    

	variable full_var : std_logic;
	variable empty_var : std_logic;
	variable half_full_var : std_logic;

	variable W_ADD_old :  std_logic_vector(ADD_WIDTH -1 downto 0);


	variable D_ADD : std_logic_vector(add_width -1 downto 0);


   begin  -- process ADD_gen

       -- activities triggered by asynchronous reset (active low)
       if reset = '0' then
	   		W_ADD <= (others =>'0');
	   		R_ADD <= (others =>'0');
	   		D_ADD := (others => '0');

			W_ADD_old := (others => '0');

			full_var := '0';
			empty_var := '1';
			half_full_var := '0';

			FULL <= full_var;
			EMPTY <= empty_var;
			HALF_FULL <= half_full_var;	

			ren_int <= '0';
			wen_int <= '0';

			datainreg <= (others => '1');
			data_out <= (others => '1');
			
       -- activities triggered by rising edge of clock
       elsif clk'event and clk = '1'  then
		
		if ren_int = '1' and wen_int = '1' and empty_var = '1' then
			  data_out <= data_in;

		else 
		
			datainREG <= data_in;
			
		    if ren_int = '1' then

	 	    	data_out <= dataoutREG;
			else
				data_out <= (others => '1');
	 		end if;

					

			W_ADD <= W_ADD_old;

			if WE = '1' then
				if  FULL_var = '0' then
			   		W_ADD_old := W_ADD_old + 1;
					D_ADD := D_ADD +1;
					wen_int <= '1';

				else
					wen_int <= '0';

				end if;

			else
				wen_int <= '0';

		    end if;


			if RE = '1' then 
				if  EMPTY_var = '0' then
			   		R_ADD <= R_ADD + 1;
					D_ADD := D_ADD -1;
					ren_int <= '1';
				else
					ren_int <= '0';

				end if;

			else
				ren_int <= '0';
		    end if;

		
			full_var := '0';
			empty_var := '0';
			half_full_var := '0';


			if D_ADD = MAX_ADDR then
				full_var := '1';
				
			end if;

			if D_ADD = MIN_ADDR then
				empty_var := '1';
				
			end if;

			if D_ADD(ADD_WIDTH -1) = '1' then
				half_full_var := '1';
				
			end if;

			FULL <= full_var;
			EMPTY <= empty_var;
			HALF_FULL <= half_full_var;	

		   
		end if;
	  end if;
		
   end process ADD_gen;

-------------------------------------------------------------------------------

        
end FIFO_v7;
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------


configuration fifo_conf of fifo is
	for fifo_v1
		for memcore:dpmem
  			use entity work.dpmem(dpmem_v3);
		end for;
	end for;

end fifo_conf;


