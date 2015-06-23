-----------------------------------------------------------------------------
--	Filename:	gh_baud_rate_gen.vhd
--
--	Description:
--		a 16 bit baud rate generator
--
--	Copyright (c) 2005 by George Huber 
--		an OpenCores.org Project
--		free to use, but see documentation for conditions 
--
--	Revision 	History:
--	Revision 	Date       	Author    	Comment
--	-------- 	---------- 	---------	-----------
--	1.0      	01/28/06  	H LeFevre	Initial revision
--	2.0      	02/04/06  	H LeFevre	reload counter with register load
--	2.1      	04/10/06  	H LeFevre	Fix error in rCLK
--
-----------------------------------------------------------------------------
library ieee ;
use ieee.std_logic_1164.all ;
use ieee.std_logic_arith.all ;
use ieee.std_logic_unsigned.all ;

entity gh_baud_rate_gen is
	port(
		clk     : in std_logic;	
		BR_clk  : in std_logic;
		rst     : in std_logic;
		WR      : in std_logic;
		BE      : in std_logic_vector (1 downto 0); -- byte enable
		D       : in std_logic_vector (15 downto 0);
		RD      : out std_logic_vector (15 downto 0);
		rCE     : out std_logic;
		rCLK    : out std_logic
		);
end entity;

architecture a of gh_baud_rate_gen is

COMPONENT gh_register_ce is
	GENERIC (size: INTEGER := 8);
	PORT(	
		clk : IN		STD_LOGIC;
		rst : IN		STD_LOGIC; 
		CE  : IN		STD_LOGIC; -- clock enable
		D   : IN		STD_LOGIC_VECTOR(size-1 DOWNTO 0);
		Q   : OUT		STD_LOGIC_VECTOR(size-1 DOWNTO 0)
		);
END COMPONENT;

COMPONENT gh_counter_down_ce_ld is
	GENERIC (size: INTEGER :=8);
	PORT(
		CLK   : IN	STD_LOGIC;
		rst   : IN	STD_LOGIC;
		LOAD  : IN	STD_LOGIC;
		CE    : IN	STD_LOGIC;
		D     : IN  STD_LOGIC_VECTOR(size-1 DOWNTO 0);
		Q     : OUT STD_LOGIC_VECTOR(size-1 DOWNTO 0)
	);
END COMPONENT;

	signal UB_LD   : std_logic;
	signal LB_LD   : std_logic;
	signal rate    : std_logic_vector(15 downto 0);
	signal C_LD    : std_logic;
	signal C_CE    : std_logic;
	signal irLD    : std_logic;	-- added 02/04/06
	signal rLD     : std_logic; -- added 02/04/06
	signal count   : std_logic_vector(15 downto 0);
	
begin
 
	rCE <= '1' when (count = x"01") else
	       '0';
		
process(BR_clk,rst)
begin
	if (rst = '1') then
		rCLK <= '0';
		rLD <= '0';
	elsif (rising_edge(BR_CLK)) then 
		rLD <= irLD;
		if (count > ('0' & (rate(15 downto 1)))) then -- fixed 04/10/06
			rCLK <= '1';
		else
			rCLK <= '0';
		end if;
	end if;
end process;

	RD <= rate;
	
----------------------------------------------
----------------------------------------------	

	UB_LD <= '0' when (WR = '0') else
	         '0' when (BE(1) = '0') else	
	         '1';
				 
u1 : gh_register_ce 
	generic map (8)
	port map(
		clk => clk,
		rst => rst,
		ce => UB_LD,
		D => d(15 downto 8),
		Q => rate(15 downto 8)
		);

	LB_LD <= '0' when (WR = '0') else
	         '0' when (BE(0) = '0') else	
	         '1';
				 
u2 : gh_register_ce 
	generic map (8)
	port map(
		clk => clk,
		rst => rst,
		ce => LB_LD,
		D => d(7 downto 0),
		Q => rate(7 downto 0)
		);

------------------------------------------------------------
------------ baud rate counter -----------------------------
------------------------------------------------------------

process(clk,rst)
begin
	if (rst = '1') then
		irLD <= '0';
	elsif (rising_edge(CLK)) then 
		if ((UB_LD or LB_LD) = '1') then
			irLD <= '1';
		elsif (rLD = '1') then
			irLD <= '0';
		end if;
	end if;
end process;

	C_LD <= '1' when (count = x"01") else
	        '1' when (rLD = '1') else
	        '0';
	
	C_CE <= '1' when (rate > x"01") else
	        '0';

U3 : gh_counter_down_ce_ld
	Generic Map (size => 16)
	PORT MAP (
		clk => BR_clk,
		rst => rst,
		LOAD => C_LD,
		CE => C_CE,
		D => rate,
		Q => count);
		
end a;

