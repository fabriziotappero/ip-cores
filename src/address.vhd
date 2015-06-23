---------------------------------------------------------------------------------------------------
--
-- Title       : address
-- Design      : cfft
-- Author      : ZHAO Ming
-- email	   : sradio@opencores.org
--
---------------------------------------------------------------------------------------------------
--
-- File        : address.vhd
-- Generated   : Thu Oct  3 01:44:47 2002
--
---------------------------------------------------------------------------------------------------
--
-- Description : Generate RAM read write address and start finish control signal
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
-- Desccription    :    Data width configurable	
--
---------------------------------------------------------------------------------------------------
--
-- Revisions       :	1
-- Revision Number : 	2
-- Version         :	1.2.1
-- Date            :	Oct 19 2002
-- Modifier        :   	ZHAO Ming 
-- Desccription    :    modified fuction counter2address for syn	
--						add rmask1,rmask2,wmask1,wmask2 signal
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
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_signed.all;

entity address is
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
		 raddr : out STD_LOGIC_VECTOR(STAGE*2-1 downto 0);
		 waddr : out STD_LOGIC_VECTOR(STAGE*2-1 downto 0);
		 wen : out std_logic;
		 factorstart : out STD_LOGIC;
		 cfft4start : out STD_LOGIC;
		 outdataen : out std_logic;
		 inputbusy : out std_logic;
		 OutPosition : out STD_LOGIC_VECTOR( 2*STAGE-1 downto 0 )
	     );
end address;


architecture address of address is


--	function counter2addr(counter : std_logic_vector; state:std_logic_vector) return std_logic_vector is
--	variable result	:std_logic_vector(counter'range);
--	variable istate : Natural;
--	begin					  
--		istate:=CONV_INTEGER(unsigned(state));
--		if istate=0	then
--			result := counter( 1 downto 0 )&counter( counter'high downto 2 );
--		elsif istate=(counter'high-1)/2 then
--			result := counter;
--		elsif istate<(counter'high-1)/2 then
--			result := counter( counter'high downto counter'high-istate*2+1 )&counter( 1 downto 0 )&counter( counter'high-istate*2 downto 2 );
--		else
--			result := counter;
--		end if;
--		return result;
--	end counter2addr;

	function counter2addr(
		counter : std_logic_vector; 
		mask1:std_logic_vector;
		mask2:std_logic_vector
	) return std_logic_vector is
	variable result	:std_logic_vector(counter'range);
	begin					  
		for n in mask1'range loop
			if mask1(n)='1' then
				result( 2*n+1 downto 2*n ):=counter( 1 downto 0 );
			elsif mask2(n)='1' and n/=STAGE-1 then
				result( 2*n+1 downto 2*n ):=counter( 2*n+3 downto 2*n+2 );
			else
				result( 2*n+1 downto 2*n ):=counter( 2*n+1 downto 2*n );
			end if;
		end loop;
		return result;
	end counter2addr;

	function outcounter2addr(
		counter : std_logic_vector 
	) return std_logic_vector is
	variable result	:std_logic_vector(counter'range);
	begin					  
		for n in 0 to STAGE-1 loop
			result( 2*n+1 downto 2*n ):=counter( counter'high-2*n downto counter'high-2*n-1 );
		end loop;
		return result;
	end outcounter2addr;

signal rstate,wstate,state:std_logic_vector( 3 downto 0 );
signal rmask1,rmask2,wmask1,wmask2:std_logic_vector( STAGE-1 downto 0 );
signal counter,wcounter,rcounter:std_logic_vector( STAGE*2-1 downto 0 );
signal outcounter:std_logic_vector( STAGE*2 downto 0 );

constant FFTDELAY:integer:=12+2*STAGE;
constant FACTORDELAY:integer:=6;
constant OUTDELAY:integer:=7;



begin
outdataen<=outcounter(STAGE*2);
OutPosition<=outcounter2addr( outcounter( STAGE*2-1 downto 0 ));
count:process( clk, rst )
begin
	if rst='1' then
		counter<=( others=>'0' );
		state<=CONV_STD_LOGIC_VECTOR( STAGE+1,4);
	elsif clk'event and clk='1' then
		if start='1' then
			counter<=( others=>'0' );
			state<=(others=>'0');
		elsif unsigned(state)/=STAGE+1 then
			counter<=unsigned(counter)+1;
			if signed(counter)=-1 then
				state<=unsigned(state)+1;
			end if;
		end if;
	end if;
end process count;

readaddr:process( clk,rst )
begin
	if rst='1' then
		raddr<=( others=>'0' );
		rcounter<=( others=>'0' );
		rstate<=( others=>'0' );										
		rmask1<=( others=>'0' );										
		rmask2<=( others=>'0' );										
	elsif clk'event and clk='1' then
		if unsigned(state)=0 and signed(counter)=-1 then
			rmask1(STAGE-1)<='1';
			rmask1(STAGE-2 downto 0)<=(others=>'0');
			rmask2(STAGE-1)<='0';
			rmask2(STAGE-2 downto 0)<=(others=>'1');
		elsif signed(counter)=-1 then
			rmask1<='0'&rmask1( STAGE-1 downto 1 );
			rmask2<='0'&rmask2( STAGE-1 downto 1 );
		end if;	
		if unsigned(state)/=STAGE+1 and signed(counter)=-1 then
			rcounter<=( others=>'0' );
			rstate<=state;
		else
			rcounter<=unsigned(rcounter)+1;
		end if;
		raddr<=counter2addr( rcounter, rmask1, rmask2 );
--		modified for point configurable
--		case rstate is
--			when "000" =>
--			raddr<=rcounter( 1 downto 0 )&rcounter( 9 downto 2);
--			when "001" =>
--			raddr<=rcounter( 9 downto 8 )&rcounter( 1 downto 0 )&rcounter( 7 downto 2);
--			when "010" =>
--			raddr<=rcounter( 9 downto 6 )&rcounter( 1 downto 0 )&rcounter( 5 downto 2);
--			when "011" =>
--			raddr<=rcounter( 9 downto 4 )&rcounter( 1 downto 0 )&rcounter( 3 downto 2);
--			when "100" =>
--			raddr<=rcounter( 9 downto 2 )&rcounter( 1 downto 0 );
--			when others =>
--			raddr<=( others=> '0' );
--		end case;
	end if;
end process readaddr;

writeaddr:process( clk,rst )
begin
	if rst='1' then
		waddr<=( others=>'0' );
		wcounter<=( others=>'0' );
		wstate<=( others=>'0' );					 
		wmask1<=( others=>'0' );
		wmask2<=( others=>'0' );
	elsif clk'event and clk='1' then
		if unsigned(state)=0 then
			waddr<=counter;
		else					
			if UNSIGNED(rstate)=0 and unsigned(rcounter)=FFTDELAY-1 then
				wmask1(STAGE-1)<='1';
				wmask1(STAGE-2 downto 0)<=(others=>'0');
				wmask2(STAGE-1)<='0';
				wmask2(STAGE-2 downto 0)<=(others=>'1');
			elsif unsigned(rcounter)=FFTDELAY-1 then
				wmask1<='0'&wmask1( STAGE-1 downto 1 );
				wmask2<='0'&wmask2( STAGE-1 downto 1 );
			end if;
			if UNSIGNED(rstate)<STAGE and unsigned(rcounter)=FFTDELAY-1 then
				wcounter<=( others=>'0' );
				wstate<=rstate;
			else
				wcounter<=unsigned(wcounter)+1;
			end if;				   
			waddr<=counter2addr( wcounter, wmask1, wmask2 );
--			modified for point configurable
--			case wstate is
--				when "000" =>
--				waddr<=wcounter( 1 downto 0 )&wcounter( 9 downto 2);
--				when "001" =>
--				waddr<=wcounter( 9 downto 8 )&wcounter( 1 downto 0 )&wcounter( 7 downto 2);
--				when "010" =>
--				waddr<=wcounter( 9 downto 6 )&wcounter( 1 downto 0 )&wcounter( 5 downto 2);
--				when "011" =>
--				waddr<=wcounter( 9 downto 4 )&wcounter( 1 downto 0 )&wcounter( 3 downto 2);
--				when others =>
--				waddr<=( others=> '0' );
--			end case;
		end if;
	end if;
end process writeaddr;

writeen : process( clk, rst )
begin
	if rst='1' then
		wen<='0';
	elsif clk'event and clk='1' then
		if unsigned(state)=0 then
			wen<='1';
		elsif unsigned(state)=1 and unsigned(counter)=0 then
			wen<='0';
		elsif unsigned(rstate)=0 and unsigned(rcounter)=FFTDELAY then
			wen<='1';
		elsif unsigned(rstate)=STAGE-1 and unsigned(rcounter)=FFTDELAY then
			wen<='0';
		end if;
	end if;
end process writeen;

otherstart : process( clk, rst )
begin
	if rst='1' then
		factorstart<='0';
		cfft4start<='0';
		outcounter<=(others=>'0');
		inputbusy<='0';
	elsif clk'event and clk='1' then
		if start='1' then
			inputbusy<='1';
		elsif unsigned(state)=STAGE and unsigned(counter)=FFTDELAY  then
			inputbusy<='0';
		end if;
		if unsigned(state)=1 and unsigned(counter)=0 then
			cfft4start<='1';
		else
			cfft4start<='0';
		end if;
		if unsigned(rstate)=0 and unsigned(rcounter)=FACTORDELAY then
			factorstart<='1';
		else
			factorstart<='0';
		end if;
		if unsigned(state)=STAGE and unsigned(rcounter)=OUTDELAY then
			outcounter<=CONV_STD_LOGIC_VECTOR(POINT,2*STAGE+1);
		elsif outcounter(STAGE*2)='1' then
			outcounter<=unsigned(outcounter)+1;
		end if;
   end if;
end process otherstart;

datasel : process( clk,rst )
begin
	if rst='1' then
		wdataI<=( others=>'0' );
		wdataQ<=( others=>'0' );
	elsif clk'event and clk='1' then
		if unsigned(state)=0 then
			wdataI<=Iin;
			wdataQ<=Qin;
		else
			wdataI<=fftI;
			wdataQ<=fftQ;
		end if;
	end if;
end process datasel;

end address;
