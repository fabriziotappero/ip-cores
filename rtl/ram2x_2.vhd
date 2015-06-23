---------------------------------------------------------------------
----                                                             ----
----  FFT Filter IP core                                         ----
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
use IEEE.std_logic_unsigned.all;

entity RAM2X2 is	
	generic(  iwidth : INTEGER:=16;
		width : INTEGER:=16;
		n:INTEGER:=8;	  -- 6,7,8,9,10,11
		v2:INTEGER);    
	port (
		CLK: in STD_LOGIC;
		RST: in STD_LOGIC;    
		CE: in STD_LOGIC;
		WEI: in STD_LOGIC;          -- for input data
		WEM: in STD_LOGIC;        -- for intermediate data    
		INITOVERF:in STD_LOGIC;     
		ADDRWIN: in STD_LOGIC_VECTOR (n - 1 downto 0);  
		ADDRWM: in STD_LOGIC_VECTOR (n - 1 downto 0);  
		ADDRR: in STD_LOGIC_VECTOR (n - 1 downto 0);  
		EVEN: in STD_LOGIC;			 --0- 1th bank is read 1- 0tht bank -is read
		DIRE: in STD_LOGIC_VECTOR (iwidth-1 downto 0);
		DIIM: in STD_LOGIC_VECTOR (iwidth-1 downto 0);
		DMRE: in STD_LOGIC_VECTOR (width-1 downto 0);
		DMIM: in STD_LOGIC_VECTOR (width-1 downto 0);   
		OVERF:out  STD_LOGIC;
		DORE: out STD_LOGIC_VECTOR (width-1 downto 0);
		DOIM: out STD_LOGIC_VECTOR (width-1 downto 0)
		);
end RAM2X2   ;


architecture RAM2X_2 of RAM2X2 is		 
	
	component RAMB16_S18_S18 is
		port (DIA    : in STD_LOGIC_VECTOR (15 downto 0);
			DIB    : in STD_LOGIC_VECTOR (15 downto 0);
			DIPA    : in STD_LOGIC_VECTOR (1 downto 0);
			DIPB    : in STD_LOGIC_VECTOR (1 downto 0);
			ENA    : in STD_ULOGIC;
			ENB    : in STD_ULOGIC;
			WEA    : in STD_ULOGIC;
			WEB    : in STD_ULOGIC;
			SSRA   : in STD_ULOGIC;
			SSRB   : in STD_ULOGIC;
			CLKA   : in STD_ULOGIC;
			CLKB   : in STD_ULOGIC;
			ADDRA  : in STD_LOGIC_VECTOR (9 downto 0);
			ADDRB  : in STD_LOGIC_VECTOR (9 downto 0);
			DOA    : out STD_LOGIC_VECTOR (15 downto 0);
			DOB    : out STD_LOGIC_VECTOR (15 downto 0);
			DOPA    : out STD_LOGIC_VECTOR (1 downto 0);
			DOPB    : out STD_LOGIC_VECTOR (1 downto 0)
			); 
	end component ;
	signal EN : STD_LOGIC;   
	signal ADDRA100,ADDRA101,ADDRB10:  STD_LOGIC_VECTOR (9 downto 0);
	signal DIREi,DIIMi:    STD_LOGIC_VECTOR (width-1 downto 0);
	Signal DIAR,DIAMR,DIB,DOA,DOBR0,DOBR1:  STD_LOGIC_VECTOR (17 downto 0);
	Signal DIAI,DIAMI,DOBI0,DOBI1:  STD_LOGIC_VECTOR (17 downto 0);
	signal	WEA0,WEA1,WEB, WEIi,OVER:STD_LOGIC;
	constant nulls:STD_LOGIC_VECTOR (17 downto 0):=(others=>'0');
	
begin	
	--Writing at ADDRW address
	--	Reading at ADDRR address
	
	EN <= '1';		
	
	RDI:process(CLK,RST) --wchodnoj registr
	begin
		if RST='1' then      
			WEIi<='0';
			DIREi<=(others=>'0');     
			DIIMi<=(others=>'0');
		elsif CLK='1' and CLK'event then
			if CE='1' then       
				WEIi<=WEI;
				DIREi<=SXT(DIRE,width);--&nulls(width-iwidth-1 downto 0);
				DIIMi<=SXT(DIIM,width);--&nulls(width-iwidth-1 downto 0);
			end if;
		end if;
	end process;
	
	DIAR( width-1 downto 0)<= DIREi;
	DIAI( width-1 downto 0)<=DIIMi;
	DIAMR( width-1 downto 0)<= DMRE;
	DIAMI( width-1 downto 0)<=DMIM;
	ZEROD:	  for i in  width to 17 generate																		
		DIAR(i)<='0';	
		DIAI(i)<='0';
		DIAMR(i)<='0';	
		DIAMI(i)<='0';
	end generate;
	
	
	
	
	DIB<=(others=>'0');					  
	WEB<='0';
	
	
	
	ADDRA100(n-1 downto 0)<=ADDRWIN(n-1 downto 0);	
	ADDRA100(9 downto n)<=(others=>'0');		
	
	ADDRA101(n-1 downto 0)<=ADDRWM(n-1 downto 0); 
	ADDRA101(9 downto n)<=(others=>'0');	
	ADDRB10(n-1 downto 0)<=ADDRR(n-1 downto 0);
	ADDRB10(9 downto n)<=(others=>'0');	
	
	
	RAMD1024v2:	if 	  n<=10 and v2=1 generate		
		ADDRB10(n-1 downto 0)<=ADDRR(n-1 downto 0);
		-- input RAM	
		RAM1024I_R:   RAMB16_S18_S18 --RE- part	 
		port map (	     
			CLKA => CLK,  CLKB => CLK,SSRA => RST,SSRB => RST,
			WEA  => WEI, WEB  => WEB,ENA  => EN,ENB  => EN,  
			DIPA => DIAR(17 downto 16),
			DIPB => DIB(17 downto 16),
			DIA  => DIAR(15 downto 0),
			DIB  => DIB(15 downto 0),
			ADDRA => ADDRA100, ADDRB => ADDRB10,
			DOPA => open,--DOA2(17 downto 16),
			DOPB => DOBR0(17 downto 16),
			DOA  => open,--DOA2(15 downto 0),
			DOB  => DOBR0(15 downto 0)); 
		
		RAM1024I_I:   RAMB16_S18_S18	 
		port map (	     
			CLKA => CLK,  CLKB => CLK,SSRA => RST,SSRB => RST,
			WEA  => WEI, WEB  => WEB,ENA  => EN,ENB  => EN,  
			DIPA => DIAI(17 downto 16),
			DIPB => DIB(17 downto 16),
			DIA  => DIAI(15 downto 0),
			DIB  => DIB(15 downto 0),
			ADDRA => ADDRA100, ADDRB => ADDRB10,
			DOPA => open,--DOA2(17 downto 16),
			DOPB => DOBI0(17 downto 16),
			DOA  => open,--DOA2(15 downto 0),
			DOB  => DOBI0(15 downto 0));
		
		-- Working RAMs		
		RAM1024_R:   RAMB16_S18_S18	 --Re -part
		port map (	     
			CLKA => CLK,  CLKB => CLK,SSRA => RST,SSRB => RST,
			WEA  => WEM, WEB  => WEB,ENA  => EN,ENB  => EN,  
			DIPA => DIAMR(17 downto 16),
			DIPB => DIB(17 downto 16),
			DIA  => DIAMR(15 downto 0),
			DIB  => DIB(15 downto 0),
			ADDRA => ADDRA101, ADDRB => ADDRB10,
			DOPA => open,--DOA2(17 downto 16),
			DOPB => DOBR1(17 downto 16),
			DOA  => open,--DOA2(15 downto 0),
			DOB  => DOBR1(15 downto 0)); 
		
		RAM1024_I:   RAMB16_S18_S18	 
		port map (	     
			CLKA => CLK,  CLKB => CLK,SSRA => RST,SSRB => RST,
			WEA  => WEM, WEB  => WEB,ENA  => EN,ENB  => EN,  
			DIPA => DIAMI(17 downto 16),
			DIPB => DIB(17 downto 16),
			DIA  => DIAMI(15 downto 0),
			DIB  => DIB(15 downto 0),
			ADDRA => ADDRA101, ADDRB => ADDRB10,
			DOPA => open,--DOA2(17 downto 16),
			DOPB => DOBI1(17 downto 16),
			DOA  => open,--DOA2(15 downto 0),
			DOB  => DOBI1(15 downto 0));
	end generate;
	
	TOVERFR:process(CLK,RST,DMRE,DMIM)
	begin                              
		OVER<=  (DIAMR( width-1) xor  DIAMR( width-2)) or (DIAMR( width-1) xor  DIAMR( width-3)) 
		or (DIAMI( width-1) xor  DIAMI( width-2)) or (DIAMI( width-1) xor  DIAMI( width-3));
		if RST='1' then 
			OVERF<='0';
		elsif CLK='1' and CLK'event then
			if CE='1' then     
				if  INITOVERF='1' then
					OVERF<='0';
				elsif over='1' and WEM='1' then
					OVERF<='1';
				end if;
			end if;
		end if;
	end process;  
	
	DORE<=DOBR0(width-1 downto 0) when EVEN='0' else DOBR1(width-1 downto 0);  
	DOIM<=DOBI0(width-1 downto 0) when EVEN='0' else DOBI1(width-1 downto 0);  
	
	
end RAM2X_2;
