---------------------------------------------------------------------
----                                                             ----
----  DCT IP core                                                ----
----                                                             ----
----  Authors: Anatoliy Sergienko, Volodya Lepeha                ----
----  Company: Unicore Systems http://unicore.co.ua              ----
----                                                             ----
----  Downloaded from: http://www.opencores.org                  ----
----                                                             ----
---------------------------------------------------------------------
----                                                             ----
---- Copyright (C) 2006-2010 Unicore Systems LTD                 ----
---- www.unicore.co.ua                                           ----
---- o.uzenkov@unicore.co.ua                                     ----
----                                                             ----
---- This source file may be used and distributed without        ----
---- restriction provided that this copyright statement is not   ----
---- removed from the file and that any derivative work contains ----
---- the original copyright notice and the associated disclaimer.----
----                                                             ----
---- THIS SOFTWARE IS PROVIDED "AS IS"                           ----
---- AND ANY EXPRESSED OR IMPLIED WARRANTIES,                    ----
---- INCLUDING, BUT NOT LIMITED TO, THE IMPLIED                  ----
---- WARRANTIES OF MERCHANTABILITY, NONINFRINGEMENT              ----
---- AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.        ----
---- IN NO EVENT SHALL THE UNICORE SYSTEMS OR ITS                ----
---- CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,            ----
---- INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL            ----
---- DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT         ----
---- OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,               ----
---- DATA, OR PROFITS; OR BUSINESS INTERRUPTION)                 ----
---- HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,              ----
---- WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT              ----
---- (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING                 ----
---- IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,                 ----
---- EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.          ----
----                                                             ----
---------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;  
use IEEE.std_logic_arith.all;

entity DCT_BEH is		  	
	generic(  SIGNED_DATA: integer);	
	port (
		DATAIN: in STD_LOGIC_VECTOR (7 downto 0);
		CLK: in STD_LOGIC;
		RST: in STD_LOGIC;   
		EN: in STD_LOGIC;   
		START: in STD_LOGIC;   
		READY : out STD_LOGIC:='0';
		DATAOUT: out STD_LOGIC_VECTOR ( 11 downto 0)  --:=x"0000"
		);
end DCT_BEH;


architecture DCT_BEH of DCT_BEH is 				 
	type TLUT2 is array(0 to 255 ) of real; 			
	type TLUT3 is array(0 to 63 ) of real;		   	
	type TLUT1 is array(0 to 255 ) of std_logic_vector(7 downto 0);	  
	constant LATENCY:integer:=3; -- 40; --51;
	constant c   : real := 0.7071;
	constant c0  : real := 0.9808;
	constant c1  : real := 0.8315;
	constant c2  : real := 0.5556;
	constant c3  : real := 0.1951;   
	constant c4  : real := 0.9239;
	constant c5  : real := 0.3827;
	Constant c6  : real := 0.7071;  
	constant c0i  : real := -0.9808;
	constant c1i  : real := -0.8315;
	constant c2i  : real := -0.5556;
	constant c3i  : real := -0.1951;   
	constant c4i  : real := -0.9239;
	constant c5i  : real := -0.3827;
	Constant c6i  : real := -0.7071;   		
	
	Constant ROM3:Tlut3:=( (  
	c,c,c,c,c,c,c,c, 
	c0,c1,c2,c3,c3i,c2i,c1i,c0i,
	c4,c5,c5i,c4i,c4i,c5i,c5,c4,
	c1,c3i,c0i,c2i,c2,c0,c3,c1i,
	c6,c6i,c6i,c6,c6,c6i,c6i,c6,
	c2,c0i,c3,c1,c1i,c3i,c0,c2i,
	c5,c4i,c4,c5i,c5i,c4,c4i,c5,
	c3,c2i,c1,c0i,c0,c1i,c2,c3i
	));		
	
	
	Constant ROM4:Tlut3:=( ( 
	c,c0,c4,c1,c6,c2,c5,c3,
	c,c1,c5,c3i,c6i,c0i,c4i,c2i,
	c,c2,c5i,c0i,c6i,c3,c4,c1,
	c,c3,c4i,c2i,c6,c1,c5i,c0i,
	c,c3i,c4i,c2,c6,c1i,c5i,c0,
	c,c2i,c5i,c0,c6i,c3i,c4,c1i,
	c,c1i,c5,c3,c6i,c0,c4i,c2,
	c,c0i,c4,c1i,c6,c2i,c5,c3i
	));		
	
	signal RESET: std_logic;  
	signal COEF : STD_LOGIC_VECTOR (6 downto 0);  
	signal  X,X11,DATAINi:  STD_LOGIC_VECTOR (7 downto 0); 
	signal	Y1,y2:  STD_LOGIC_VECTOR (15 downto 0); 
	signal  Y,DATAOUTi:  STD_LOGIC_VECTOR (11 downto 0);
	signal K1,K2,X1,k8,couna: INTEGER;	
	signal k3,k4,k7: real;
	signal ram00,ramres,ramt : tlut3;
	signal prov,prov1:  std_logic_vector (7 downto 0); 
	signal inarray,inarray0,tmpar1,tmpar2,tmpar3: tlut3;
	signal 		index: integer range 0 to 63;  	
	signal CLK64,eoutput,indataready,indataready2,	startdel,startd1,startd2,	startfix,readyi:boolean;		  
	signal delay,cycle: integer:=0;
begin
	
	
	G1:	if 	 SIGNED_DATA=1   generate
		DATAINi<=DATAIN;
	end generate;
	G0:	 	if 	 SIGNED_DATA=0   generate
		DATAINi<=unsigned (DATAIN) - 128;	
	end generate;
	
	
	
	DATA_INPUT: process(CLK,RST,START)
		variable index: integer  range 0 to 64;
	begin				
		if RST='1' or START='1' then
			index:=0;	  indataready<=false;
			for i in 0 to 63 loop
				inarray0(i)<=0.0;
			end loop;
		elsif CLK='1' and CLK'event then			 
			if en='1' then
				inarray0(index)<=REAL(CONV_INTEGER(SIGNED(DATAINi)));
				index:=(index+1) mod 64;		 
				if index=63		  then 
					indataready<=true;
				else  
					indataready<=false; 
				end if;  	
			end if;
		end if;
		
	end process;
	
	DATAREADY:process(CLK)
	begin				
		if CLK'event and CLK='1'  then 		
			if en='1' then
				indataready2<=indataready;
				if indataready2 then 
					inarray<=inarray0; 	
				end if;			   
			end if;
		end if;
		
	end process;		 
	
	
	DCT:	process   			  --Discrete Cosine Transform calculation
		variable cc0,cc1,cc2,cc3,cc4,cc5,cc6: real;		 
		variable ac0,ac1,ac2,ac3,ac4,ac5,ac6,ac7: real;	 
		variable s,i,j,k: integer;
	begin	  
		for s in 0 to 7 loop
			for j in 0 to 7 loop
				ac0:= 0.0;
				for i in 0 to 7 loop 
					cc0 := rom3(s*8 + i);
					cc1 := (inarray(j + i*8)); -- - 128.0);
					ac0 := ac0 +  cc0 * cc1;
				end loop;
				ram00(s*8 +j) <= ac0; 	 
				ramt(j*8 +s)<=ac0/2.0; 
				wait for 1 ps;
			end loop;	 
		end loop; 	 	  
		
		
		wait for 5 ps;
		for s in 0 to 7 loop
			for j in 0 to 7 loop
				ac0:= 0.0;
				for i in 0 to 7 loop 	
					cc0 := ram00(s*8 + i);
					cc1 := rom3(j*8 + i);
					ac0 := ac0 + cc0 * cc1;
				end loop;
				ramres(s*8 +j) <= ac0/8.0; 				--results
				wait for 1 ps;
			end loop;	 
		end loop; 	 
		wait on indataready2;
	end process;			
	
	
	--	CLK64<= indataready ; 
	
	DATA_OUTPUT:process(CLK,RST,START)
		
		--	variable delay: integer;
	begin				
		if	 RST='1' or START='1'  then
			startfix<=false;
		elsif  START='0' and START'event  then 		 
			startfix<=true;
		end if;	
		
		if	 RST='1' or START='1' then	
			eoutput<=false;
			startdel<=false;
			delay<=0;
		elsif rising_edge(CLK) and startd2 then 	
			if en='1' then
				startdel<=(delay=LATENCY);   --momemt of 1 st result ready
				delay<=delay+1;
				if startdel then 	  
					eoutput<=true;	 
				end if;			   
			end if;
		end if;
		
		
		if	 RST='1' or START='1' then	
			cycle<=0; 
			readyi<=false;
		elsif rising_edge(CLK) and eoutput  then 	
			if en='1' then
				cycle<=(cycle+1) mod 64;   
			end if;
		end if;						 
		
		readyi<= cycle = 63 or startdel;			 -- 63
		if readyi then READY<= '1' ; else  READY<= '0'; end if;	   
		
		
		if RST='1' or STARTDel then
			index<=0;
		elsif CLK='1' and CLK'event and eoutput  then	--
			if en='1' then
							
				index<=(index+1) mod 64;		 	 
			end if;
		end if;			
		
		
		
	end process;			 
	
		
	process(clk,rst)
		begin			  	
			if RST='1' or STARTDel then	
				DATAOUT<= (others => '0');
			elsif CLK='1' and CLK'event and eoutput  then	--	
				if en='1' then
					DATAOUT<=CONV_STD_LOGIC_VECTOR(INTEGER(	tmpar2(index)),12);		 -- 12	
					DATAOUTi<=CONV_STD_LOGIC_VECTOR(INTEGER(	ramt((index-14) mod 64)),12);		 -- 16
				end if;
			end if;			
		end process;
	
	
	
	RESULT_ARRAY: process(readyi,CLK)
	begin											 
		if CLK='1' and CLK'event and readyi then 		 
			if en='1' then
				tmpar2<=tmpar1;	   
			end if;
		end if;
	end process	;
	
	DELAYED:process ( indataready2,START,RESET) --delay for 128 cycles
	begin		
		if START='1' or RESET='1' then
			startd2<=false;
			startd1<=false;
		elsif  indataready2 and  indataready2'event then		 
			if en='1' then
				for i in 0 to 63 loop
					tmpar1(i)<=ramres(i)*2.0;	--SCALING  !!!
				end loop;
				startd2<=startd1;
				startd1<=STARTFIX;	
			end if;
		end if;
	end process;
	
	
	
end DCT_BEH;
