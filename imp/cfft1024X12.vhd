---------------------------------------------------------------------------------------------------
--
-- Title       : cfft1024X12
-- Design      : cfft
-- Author      : ZHAO Ming
-- email	: sradio@opencores.org
--
---------------------------------------------------------------------------------------------------
--
-- File        : cfft1024X12.vhd
--
---------------------------------------------------------------------------------------------------
--
-- Description :This is a sample implementation of cfft 
--		
--		radix 4 1024 point FFT input 12 bit Output 14 bit with 
--               limit and overfall processing internal
--
--              The gain is 0.0287 for FFT and 29.4 for IFFT
--
--				The output is 4-based reversed ordered, it means
--				a0a1a2a3a4a5a6a7a8a9 => a8a9a6a7a4a5aa2a3a0a1
-- 				
--
---------------------------------------------------------------------------------------------------


---------------------------------------------------------------------------------------------------
--
-- port :
--			clk : main clk 		-- I have test 90M with Xilinx virtex600E
--          rst : globe reset 	-- '1' for reset
--			start : start fft	-- one clock '1' before data input
--			invert : '0' for fft and '1' for ifft, it is sampled when start is '1' 
--			Iin,Qin : data input-- following start immediately, input data
--                              -- power should not be too big
--          inputbusy : if it change to '0' then next fft is enable
--			outdataen : when it is '1', the valid data is output
--          Iout,Qout : fft data output when outdataen is '1'									   
--
---------------------------------------------------------------------------------------------------
--
-- Revisions       :	0
-- Revision Number : 	1
-- Version         :	1.1.0
-- Date            :	Oct 31 2002
-- Modifier        :   	ZHAO Ming 
-- Desccription    :    initial release	
--
---------------------------------------------------------------------------------------------------
--
-- Revisions       :	0
-- Revision Number : 	2
-- Version         :	1.2.0
-- Date            :	Nov 19 2002
-- Modifier        :   	ZHAO Ming 
-- Desccription    :    add output data position indication 
--	             
--
---------------------------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity cfft1024X12 is
	 port(
		 clk : in STD_LOGIC;
		 rst : in STD_LOGIC;
		 start : in STD_LOGIC;
		 invert : in std_logic;
		 Iin : in STD_LOGIC_VECTOR(11 downto 0);
		 Qin : in STD_LOGIC_VECTOR(11 downto 0);
		 inputbusy : out STD_LOGIC;
		 outdataen : out STD_LOGIC;
		 Iout : out STD_LOGIC_VECTOR(13 downto 0);
		 Qout : out STD_LOGIC_VECTOR(13 downto 0);
		 OutPosition : out STD_LOGIC_VECTOR( 9 downto 0 )
	     );
end cfft1024X12;


architecture imp of cfft1024X12 is

component cfft
	generic (
		WIDTH : Natural;
		POINT : Natural;
		STAGE : Natural   -- STAGE=log4(POINT)
	);
	 port(
		 clk : in STD_LOGIC;
		 rst : in STD_LOGIC;
		 start : in STD_LOGIC;
		 invert : in std_logic;
		 Iin : in STD_LOGIC_VECTOR(WIDTH-1 downto 0);
		 Qin : in STD_LOGIC_VECTOR(WIDTH-1 downto 0);
		 inputbusy : out STD_LOGIC;
		 outdataen : out STD_LOGIC;
		 Iout : out STD_LOGIC_VECTOR(WIDTH+1 downto 0);
		 Qout : out STD_LOGIC_VECTOR(WIDTH+1 downto 0);
		 OutPosition : out STD_LOGIC_VECTOR( 2*STAGE-1 downto 0 )
	     );
end component;

begin

aCfft:cfft
generic map (
	WIDTH=>12,
	POINT=>1024,
	STAGE=>5
)
port map (
	clk=>clk,
	rst=>rst,
	start=>start,
	invert=>invert,
	Iin=>Iin,
	Qin=>Qin,
	inputbusy=>inputbusy,
	outdataen=>outdataen,
	Iout=>Iout,
	Qout=>Qout,
	OutPosition=>OutPosition

);


end imp;
