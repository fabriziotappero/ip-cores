---------------------------------------------------------------------
--	Filename:	gh_fifo_async16_rcsr_wf.vhd
--
--
--	Description:
--		a simple Asynchronous FIFO - uses FASM style Memory
--		16 word depth with UART level read flags
--		has "Style #2" gray code address compare
--              
--	Copyright (c) 2007 by Howard LeFevre 
--		an OpenCores.org Project
--		free to use, but see documentation for conditions 								 
--
--	Revision	History:
--	Revision	Date      	Author   	Comment
--	--------	----------	---------	-----------
--	1.0     	01/20/07  	h lefevre	Initial revision
--	
--------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
USE ieee.std_logic_arith.all;

entity gh_fifo_async16_rcsr_wf is
	GENERIC (data_width: INTEGER :=8 ); -- size of data bus
	port (					
		clk_WR  : in STD_LOGIC; -- write clock
		clk_RD  : in STD_LOGIC; -- read clock
		rst     : in STD_LOGIC; -- resets counters
		rc_srst : in STD_LOGIC:='0'; -- resets counters (sync with clk_RD!!!)
		WR      : in STD_LOGIC; -- write control 
		RD      : in STD_LOGIC; -- read control
		D       : in STD_LOGIC_VECTOR (data_width-1 downto 0);
		Q       : out STD_LOGIC_VECTOR (data_width-1 downto 0);
		empty   : out STD_LOGIC; -- sync with clk_RD!!!
		q_full  : out STD_LOGIC; -- sync with clk_RD!!!
		h_full  : out STD_LOGIC; -- sync with clk_RD!!!
		a_full  : out STD_LOGIC; -- sync with clk_RD!!!
		full    : out STD_LOGIC);
end entity;

architecture a of gh_fifo_async16_rcsr_wf is

component gh_binary2gray IS
	GENERIC (size: INTEGER := 8);
	PORT(	
		B   : IN STD_LOGIC_VECTOR(size-1 DOWNTO 0);
		G   : out STD_LOGIC_VECTOR(size-1 DOWNTO 0)
		);
end component;

component gh_gray2binary IS
	GENERIC (size: INTEGER := 8);
	PORT(	
		G   : IN STD_LOGIC_VECTOR(size-1 DOWNTO 0);	-- gray code in
		B   : out STD_LOGIC_VECTOR(size-1 DOWNTO 0) -- binary value out
		);
end component;

	type ram_mem_type is array (15 downto 0) 
	        of STD_LOGIC_VECTOR (data_width-1 downto 0);
	signal ram_mem : ram_mem_type; 
	signal iempty        : STD_LOGIC;
	signal diempty       : STD_LOGIC;
	signal ifull         : STD_LOGIC;
	signal add_WR_CE     : std_logic;
	signal add_WR        : std_logic_vector(4 downto 0); -- add_width -1 bits are used to address MEM
	signal add_WR_GC     : std_logic_vector(4 downto 0); -- add_width bits are used to compare
	signal iadd_WR_GC    : std_logic_vector(4 downto 0);
	signal n_add_WR      : std_logic_vector(4 downto 0); --   for empty, full flags
	signal add_WR_RS     : std_logic_vector(4 downto 0); -- synced to read clk
	signal add_RD_CE     : std_logic;
	signal add_RD        : std_logic_vector(4 downto 0);
	signal add_RD_GC     : std_logic_vector(4 downto 0);
	signal iadd_RD_GC    : std_logic_vector(4 downto 0);
	signal add_RD_GCwc   : std_logic_vector(4 downto 0);
	signal iadd_RD_GCwc  : std_logic_vector(4 downto 0);
	signal iiadd_RD_GCwc : std_logic_vector(4 downto 0);
	signal n_add_RD      : std_logic_vector(4 downto 0);
	signal add_RD_WS     : std_logic_vector(4 downto 0); -- synced to write clk
	signal srst_w        : STD_LOGIC;
	signal isrst_w       : STD_LOGIC;
	signal srst_r        : STD_LOGIC;
	signal isrst_r       : STD_LOGIC;
	signal c_add_RD      : std_logic_vector(4 downto 0);
	signal c_add_WR      : std_logic_vector(4 downto 0);
	signal c_add         : std_logic_vector(4 downto 0);

begin

--------------------------------------------
------- memory -----------------------------
--------------------------------------------


process (clk_WR)
begin			  
	if (rising_edge(clk_WR)) then
		if ((WR = '1') and (ifull = '0')) then
			ram_mem(CONV_INTEGER(add_WR(3 downto 0))) <= D;
		end if;
	end if;		
end process;

	Q <= ram_mem(CONV_INTEGER(add_RD(3 downto 0)));

-----------------------------------------
----- Write address counter -------------
-----------------------------------------

	add_WR_CE <= '0' when (ifull = '1') else
	             '0' when (WR = '0') else
	             '1';

	n_add_WR <= add_WR + "01";

U1 : gh_binary2gray
	generic map (size => 5)
	port map(
		B => n_add_WR,
		G => iadd_WR_GC
		);
	
process (clk_WR,rst)
begin 
	if (rst = '1') then
		add_WR <= (others => '0');
		add_RD_WS(4 downto 3) <= "11"; 
		add_RD_WS(2 downto 0) <= (others => '0');
		add_WR_GC <= (others => '0');
	elsif (rising_edge(clk_WR)) then
		add_RD_WS <= add_RD_GCwc;
		if (srst_w = '1') then
			add_WR <= (others => '0');
			add_WR_GC <= (others => '0');
		elsif (add_WR_CE = '1') then
			add_WR <= n_add_WR;
			add_WR_GC <= iadd_WR_GC;
		else
			add_WR <= add_WR;
			add_WR_GC <= add_WR_GC;
		end if;
	end if;
end process;
				 
	full <= ifull;

	ifull <= '0' when (iempty = '1') else -- just in case add_RD_WS is reset to all zero's
	         '0' when (add_RD_WS /= add_WR_GC) else ---- instend of "11 zero's" 
	         '1';

		
-----------------------------------------
----- Read address counter --------------
-----------------------------------------


	add_RD_CE <= '0' when (iempty = '1') else
	             '0' when (RD = '0') else
	             '1';
				 
	n_add_RD <= add_RD + "01";

U2 : gh_binary2gray
	generic map (size => 5)
	port map(
		B => n_add_RD,
		G => iadd_RD_GC -- to be used for empty flag
		);

	iiadd_RD_GCwc <= (not n_add_RD(4)) & n_add_RD(3 downto 0);
		
U3 : gh_binary2gray
	generic map (size => 5)
	port map(
		B => iiadd_RD_GCwc,
		G => iadd_RD_GCwc -- to be used for full flag
		);
		
process (clk_RD,rst)
begin 
	if (rst = '1') then
		add_RD <= (others => '0');	
		add_WR_RS <= (others => '0');
		add_RD_GC <= (others => '0');
		add_RD_GCwc(4 downto 3) <= "11";
		add_RD_GCwc(2 downto 0) <= (others => '0');
		diempty <= '1';
	elsif (rising_edge(clk_RD)) then
		add_WR_RS <= add_WR_GC;
		diempty <= iempty;
		if (srst_r = '1') then
			add_RD <= (others => '0');
			add_RD_GC <= (others => '0');
			add_RD_GCwc(4 downto 3) <= "11";
			add_RD_GCwc(2 downto 0) <= (others => '0');
		elsif (add_RD_CE = '1') then
			add_RD <= n_add_RD;
			add_RD_GC <= iadd_RD_GC;
			add_RD_GCwc <= iadd_RD_GCwc;
		else
			add_RD <= add_RD; 
			add_RD_GC <= add_RD_GC;
			add_RD_GCwc <= add_RD_GCwc;
		end if;
	end if;
end process;

	empty <= diempty;
 
	iempty <= '1' when (add_WR_RS = add_RD_GC) else
	          '0';
 
U4 : gh_gray2binary
	generic map (size => 5)
	port map(
		G => add_RD_GC,
		B => c_add_RD 
		);

U5 : gh_gray2binary
	generic map (size => 5)
	port map(
		G => add_WR_RS,
		B => c_add_WR 
		); 
		
	c_add <= (c_add_WR - c_add_RD);
	
	q_full <= '0' when (iempty = '1') else
	          '0' when (c_add(4 downto 2) = "000") else
	          '1';
	
	h_full <= '0' when (iempty = '1') else
	          '0' when (c_add(4 downto 3) = "00") else
	          '1'; 
	
	a_full <= '0' when (iempty = '1') else
	          '0' when (c_add(4 downto 1) < "0111") else
	          '1'; 
			  
----------------------------------
--- sync rest stuff --------------
--- rc_srst is sync with clk_RD --
--- srst_w is sync with clk_WR ---
----------------------------------

process (clk_WR,rst)
begin 
	if (rst = '1') then
		srst_w <= '0';	
		isrst_r <= '0';	
	elsif (rising_edge(clk_WR)) then
		srst_w <= isrst_w;
		if (srst_w = '1') then
			isrst_r <= '1';
		elsif (srst_w = '0') then
			isrst_r <= '0';
		end if;
	end if;
end process;

process (clk_RD,rst)
begin 
	if (rst = '1') then
		srst_r <= '0';	
		isrst_w <= '0';
	elsif (rising_edge(clk_RD)) then
		srst_r <= rc_srst;
		if (rc_srst = '1') then
			isrst_w <= '1';
		elsif (isrst_r = '1') then
			isrst_w <= '0';
		end if;
	end if;
end process;

end architecture;
