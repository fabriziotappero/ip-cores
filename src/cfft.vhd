---------------------------------------------------------------------------------------------------
--
-- Title       : cfft
-- Design      : cfft
-- Author      : ZHAO Ming
-- email	: sradio@opencores.org
--
---------------------------------------------------------------------------------------------------
--
-- File        : cfft.vhd
-- Generated   : Thu Oct  3 03:03:58 2002
--
---------------------------------------------------------------------------------------------------
--
-- Description : radix 4 1024 point FFT input 12 bit Output 14 bit with 
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
-- Date            :	Oct 17 2002
-- Modifier        :   	ZHAO Ming 
-- Desccription    :    Data width configurable	
--
---------------------------------------------------------------------------------------------------
--
-- Revisions       :	0
-- Revision Number : 	2
-- Version         :	1.2.0
-- Date            :	Oct 18 2002
-- Modifier        :   	ZHAO Ming 
-- Desccription    :    Point configurable
--                      FFT Gain		IFFT GAIN
--				 256	0.0698			17.9
--				1024    0.0287			29.4
--				4096	0.0118			48.2742
--	             
--
---------------------------------------------------------------------------------------------------
--
-- Revisions       :	0
-- Revision Number : 	3
-- Version         :	1.3.0
-- Date            :	Nov 19 2002
-- Modifier        :   	ZHAO Ming 
-- Desccription    :    add output data position indication 
--	             
--
---------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;

entity cfft is
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
end cfft;


architecture cfft of cfft is

component address
	generic (
		WIDTH : Natural;
		POINT : Natural;
		STAGE : Natural
	);
	 port(
		 clk : in STD_LOGIC;
		 rst : in STD_LOGIC;
		 start : in STD_LOGIC;
		 Iin : in std_logic_vector( WIDTH-1 downto 0 );
		 Qin : in std_logic_vector( WIDTH-1 downto 0 );
		 fftI : in std_logic_vector( WIDTH-1 downto 0 );
		 fftQ : in std_logic_vector( WIDTH-1 downto 0 );
		 wdataI : out std_logic_vector( WIDTH-1 downto 0 );
		 wdataQ : out std_logic_vector( WIDTH-1 downto 0 );
		 raddr : out STD_LOGIC_VECTOR(2*STAGE-1 downto 0);
		 waddr : out STD_LOGIC_VECTOR(2*STAGE-1 downto 0);
		 wen : out std_logic;
		 factorstart : out STD_LOGIC;
		 cfft4start : out STD_LOGIC;
		 outdataen : out std_logic;
		 inputbusy : out std_logic;
	     OutPosition : out STD_LOGIC_VECTOR( 2*STAGE-1 downto 0 )
		 );
end component;

component blockdram
generic( 
	depth:	integer;
	Dwidth: integer;
	Awidth:	integer
);
port(
	addra: IN std_logic_VECTOR(Awidth-1 downto 0);
	clka: IN std_logic;
	addrb: IN std_logic_VECTOR(Awidth-1 downto 0);
	clkb: IN std_logic;
	dia: IN std_logic_VECTOR(Dwidth-1 downto 0);
	wea: IN std_logic;
	dob: OUT std_logic_VECTOR(Dwidth-1 downto 0));
end component;

component cfft4
	generic (
		WIDTH : Natural
	);
	 port(
		 clk : in STD_LOGIC;
		 rst : in STD_LOGIC;
		 start : in STD_LOGIC;
		 invert : in std_logic;
		 I : in STD_LOGIC_VECTOR(WIDTH-1 downto 0);
		 Q : in STD_LOGIC_VECTOR(WIDTH-1 downto 0);
		 Iout : out STD_LOGIC_VECTOR(WIDTH+1 downto 0);
		 Qout : out STD_LOGIC_VECTOR(WIDTH+1 downto 0)
	     );
end component;

component div4limit
	generic (
		WIDTH : Natural
	);
	port(
		clk : in std_logic;
		 D : in STD_LOGIC_VECTOR(WIDTH+3 downto 0);
		 Q : out STD_LOGIC_VECTOR(WIDTH-1 downto 0)
	     );
end component;

component mulfactor
	generic (
		WIDTH : Natural;
		STAGE : Natural
	);
	 port(
		 clk : in STD_LOGIC;
		 rst : in STD_LOGIC;
		 angle : in signed(2*STAGE-1 downto 0);
		 I : in signed(WIDTH+1 downto 0);
		 Q : in signed(WIDTH+1 downto 0);
		 Iout : out signed(WIDTH+3 downto 0);
		 Qout : out signed(WIDTH+3 downto 0)
	     );
end component;

component rofactor							   
	generic (
		POINT : Natural;
		STAGE : Natural
	);
	 port(
		 clk : in STD_LOGIC;
		 rst : in STD_LOGIC;
		 start : in STD_LOGIC;
		 invert : in std_logic;
		 angle : out STD_LOGIC_VECTOR(2*STAGE-1 downto 0)
	     );
end component;
signal wea,cfft4start,factorstart:std_logic:='0';
signal wdataI,wdataQ,fftI,fftQ,Iramout,Qramout:std_logic_vector(WIDTH-1 downto 0):=(others=>'0');
signal waddr,raddr:std_logic_vector( 2*STAGE-1 downto 0):=(others=>'0'); 
signal Icfft4out,Qcfft4out:std_logic_vector( WIDTH+1 downto 0):=(others=>'0'); 
signal angle:std_logic_vector( 2*STAGE-1 downto 0 ):=( others=>'0');
signal Imulout,Qmulout:signed( WIDTH+3 downto 0):=(others=>'0'); 	 
signal inv_reg:std_logic:='0';

begin

Aaddress:address
generic map (
	WIDTH=>WIDTH,
	POINT=>POINT,
	STAGE=>STAGE
)
port map (
	clk=>clk,
	rst=>rst,
	start=>start,
	Iin=>Iin,
	Qin=>Qin,
	fftI=>fftI,
	fftQ=>fftQ,
	wdataI=>wdataI,
	wdataQ=>wdataQ,
	raddr=>raddr,
	waddr=>waddr,
	wen=>wea,
	factorstart=>factorstart,
	cfft4start=>cfft4start,
	outdataen=>outdataen,
	inputbusy=>inputbusy,
	OutPosition=>OutPosition
	     );

Iram:blockdram
generic map (
	depth=>POINT,
	Dwidth=>WIDTH,
	Awidth=>2*STAGE
)
port map (
	addra=>waddr,
	clka=>clk,
	addrb=>raddr,
	clkb=>clk,
	dia=>wdataI,
	wea=>wea,
	dob=>Iramout
);		  

Qram:blockdram
generic map (
	depth=>POINT,
	Dwidth=>WIDTH,
	Awidth=>2*STAGE
)
port map (
	addra=>waddr,
	clka=>clk,
	addrb=>raddr,
	clkb=>clk,
	dia=>wdataQ,
	wea=>wea,
	dob=>Qramout
);

acfft4:cfft4	 
generic map (
	WIDTH=>WIDTH
)
port map (
	clk=>clk,
	rst=>rst,
	start=>cfft4start,
	invert=>inv_reg,
	I=>Iramout,
	Q=>Qramout,
	Iout=>Icfft4out,
	Qout=>Qcfft4out
	     );

Iout<=Icfft4out;
Qout<=Qcfft4out;
		 
Ilimit:div4limit
generic map (
	WIDTH=>WIDTH
)
port map (
	clk=>clk,
	D=>std_logic_vector(Imulout),
	Q=>fftI
	     );
Qlimit:div4limit
generic map (
	WIDTH=>WIDTH
)
port map (
	clk=>clk,
	D=>std_logic_vector(Qmulout),
	Q=>fftQ
	     );

amulfactor:mulfactor
generic map (
	WIDTH=>WIDTH,
	STAGE=>STAGE
)
port map (
	clk=>clk,
	rst=>rst,
	angle=>signed(angle),
	I=>signed(Icfft4out),
	Q=>signed(Qcfft4out),
	Iout=>Imulout,
	Qout=>Qmulout
	     );

arofactor:rofactor 
generic map (
	POINT=>POINT,
	STAGE=>STAGE
)
port map (
	clk=>clk,
	rst=>rst,
	start=>factorstart,
	invert=>inv_reg,
	angle=>angle
	     );

process( clk, rst )
begin
	if rst='1' then
		inv_reg<='0';
	elsif clk'event and clk='1' then
		if start='1' then
			inv_reg<=invert;
		end if;
	end if;
end process;
	
		

end cfft;
