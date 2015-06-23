-----------------------------------------------------------------------------
--	Filename:	gh_Pulse_Generator.vhd
--
--	Description:
--		A Pulse Generator
--
--	Copyright (c) 2005, 2006 by George Huber 
--		an OpenCores.org Project
--		free to use, but see documentation for conditions 
--
--	Revision 	History:
--	Revision 	Date       	Author    	Comment
--	-------- 	---------- 	---------	-----------
--	1.0      	09/24/05  	S A Dodd 	Initial revision
--	1.1      	02/18/06  	G Huber  	add gh_ to name
--	1.2     	03/09/06  	S A Dodd 	fix typo's, add Period reload 
--	        	          	         	   if Period_count > Period
--
-----------------------------------------------------------------------------

library IEEE;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
USE ieee.std_logic_arith.all;
							 
entity gh_Pulse_Generator is
	GENERIC(size_Period: INTEGER := 16); 
	port(
		clk         : in std_logic; 
		rst         : in std_logic;
		Period      : in std_logic_vector (size_Period-1 downto 0);
		Pulse_Width : in std_logic_vector (size_Period-1 downto 0);
		ENABLE      : in std_logic;
		Pulse       : out std_logic 
		);
end entity;

architecture a of gh_Pulse_Generator is

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

	signal trigger        : std_logic;
	signal LD_Period      : std_logic;
	signal Period_Count   : std_logic_vector(size_Period-1 downto 0);
	signal Width_Count    : std_logic_vector(size_Period-1 downto 0);
	signal Period_cmp     : std_logic_vector(size_Period-1 downto 0);
	signal Width_cmp      : std_logic_vector(size_Period-1 downto 0);
	
	signal LD_width      : std_logic;
	signal E_width       : std_logic;
	
begin

-- constant compare values  -----------------------------------
	Period_cmp(size_Period-1 downto 1) <= (others =>'0');
	Period_cmp(0) <= '1';
	Width_cmp <= (others => '0');
---------------------------------------------------------------
	
	
U1 : gh_counter_down_ce_ld 
	Generic Map(size_Period) 
	PORT MAP(
		clk => clk,
		rst => rst,
		LOAD => LD_Period,
		CE => ENABLE,  
		D => Period,
		Q => Period_Count
		);

	LD_Period <= trigger or (not ENABLE);
	
	trigger <= '1' when (Period_Count > Period) else
	           '1' when (Period_Count = Period_cmp) else
	           '0';
		
-----------------------------------------------------------
			   
U2 : gh_counter_down_ce_ld 
	Generic Map(size_Period) 
	PORT MAP(
		clk => clk,
		rst => rst,
		LOAD => LD_width,
		CE => E_width,  
		D => Pulse_Width,
		Q => Width_Count
		);

	LD_width <= trigger; 
	
	E_width <= '0' when (Width_Count = Width_cmp) else
	           '1';
	
	Pulse <= E_width;

end a;

