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

entity RAM1X_2 is	
	generic(width : INTEGER;
		n:INTEGER;	  -- 6,7,8,9,10,11
		v2:INTEGER:=1);  
	port (
		CLK: in STD_LOGIC;
		RST: in STD_LOGIC; 
		CE: in STD_LOGIC;
		WE: in STD_LOGIC;                    
		INITOVERF:    in STD_LOGIC;    
		ADDRW: in STD_LOGIC_VECTOR (n downto 0);  
		ADDRR: in STD_LOGIC_VECTOR (n downto 0);  
		SEL: in STD_LOGIC;									  -- 0 -fromDIRE,DIIM, 1 - DMRE,DMIM
		RESRAM:  in STD_LOGIC;   
		DIRE: in STD_LOGIC_VECTOR (width-1 downto 0);
		DIIM: in STD_LOGIC_VECTOR (width-1 downto 0);
		DMRE: in STD_LOGIC_VECTOR (width-1 downto 0);
		DMIM: in STD_LOGIC_VECTOR (width-1 downto 0);  
		OVERF:out  STD_LOGIC;
		DORE: out STD_LOGIC_VECTOR (width-1 downto 0);
		DOIM: out STD_LOGIC_VECTOR (width-1 downto 0)
		);
end RAM1X_2;


architecture RAM1X of RAM1X_2 is		 
	
	component RAMB4_S1_S1 is
		port (
			CLKA,CLKB: in STD_LOGIC;
			RSTA,RSTB: in STD_LOGIC;
			ENA,	ENB: in STD_LOGIC;
			WEA,	WEB: in STD_LOGIC;
			ADDRA,ADDRB: in STD_LOGIC_VECTOR (11 downto 0);
			DIA,DIB: in STD_LOGIC;
			DOA,DOB: out STD_LOGIC	);		 
	end component;
	component RAMB4_S2_S2 is
		port (
			CLKA,	CLKB,RSTA,RSTB,ENA,ENB,WEA,WEB: in STD_LOGIC;
			ADDRA,ADDRB: in STD_LOGIC_VECTOR (10 downto 0);
			DIA,DIB: in STD_LOGIC_VECTOR (1 downto 0);	   	
			DOA,DOB: out STD_LOGIC_VECTOR (1 downto 0)
			);
	end component;   
	component RAMB4_S4_S4 is
		port (
			CLKA,	CLKB,RSTA,RSTB,ENA,ENB,WEA,WEB: in STD_LOGIC;
			ADDRA,ADDRB: in STD_LOGIC_VECTOR (9 downto 0);
			DIA,DIB: in STD_LOGIC_VECTOR (3 downto 0);	   
			DOA,DOB: out STD_LOGIC_VECTOR (3 downto 0)
			);
	end component; 
	component RAMB4_S8_S8 is
		port (
			CLKA,	CLKB,RSTA,RSTB,ENA,ENB,WEA,WEB: in STD_LOGIC;
			ADDRA,ADDRB: in STD_LOGIC_VECTOR (8 downto 0);
			DIA,DIB: in STD_LOGIC_VECTOR (7 downto 0);	
			DOA,DOB: out STD_LOGIC_VECTOR (7 downto 0)
			);
	end component;
	component RAMB4_S16_S16 is
		port (
			CLKA,CLKB,RSTA,RSTB,ENA,ENB,WEA,WEB: in STD_LOGIC;
			ADDRA,ADDRB: in STD_LOGIC_VECTOR (7 downto 0);
			DIA,DIB	 : in STD_LOGIC_VECTOR (15 downto 0);
			DOA,DOB: out STD_LOGIC_VECTOR (15 downto 0)
			);
	end component;	  
	component   RAMB16_S18_S18 is
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
	end	component;
	
	--constant zeros: STD_LOGIC_VECTOR (width-iwidth-1 downto 0):=(others=>'0');
	signal EN,A10 : STD_LOGIC;        
	signal DIREi,DIIMi:    STD_LOGIC_VECTOR (width-1 downto 0);
	signal ADDRA8,ADDRB8:  STD_LOGIC_VECTOR (7 downto 0);
	signal ADDRA9,ADDRB9:  STD_LOGIC_VECTOR (8 downto 0);
	signal ADDRA10,ADDRB10:  STD_LOGIC_VECTOR (9 downto 0);
	signal ADDRA11,ADDRB11:  STD_LOGIC_VECTOR (10 downto 0);
	signal ADDRA12,ADDRB12:  STD_LOGIC_VECTOR (11 downto 0);
	signal	WE0,WE1,WEB,over:STD_LOGIC;
	Signal DIAR,DIB,DOA,DOBR,DOBR0,DOBR1:  STD_LOGIC_VECTOR (17 downto 0);
	Signal DIAI,DOBI,DOBI0,DOBI1:  STD_LOGIC_VECTOR (17 downto 0);
	
	
begin	
	--Writing at ADDRW address
	--	Reading at ADDRR address
	
	EN <= '1';		
	DIB<=(others=>'0');
	RDI:process(CLK,RST)
	begin
		if RST='1' then  
			DIREi<=(others=>'0');     
			DIIMi<=(others=>'0');
		elsif CLK='1' and CLK'event then
			if CE='1' then         
				DIREi<=DIRE;
				DIIMi<=DIIM;
			end if;
		end if;
	end process;
	--	DIREi<=DIRE;
	--				DIIMi<=DIIM;
	
	
	--	Virtex:if V2=0 generate
	--		ZEROD:	  for i in  width to 15 generate																	
	--			DIAR(i)<='0';	
	--			DIAI(i)<='0';	
	--		end generate;
	--		
	--		DIB<=(others=>'0');					  
	--		WEB<='0';
	--		
	--		RAMD256:	if 	 n=4 or n=5 or n=6 or n=7 or n=8 generate		
	--			EMPTYA4:if n=4 generate
	--				ADDRA8(7 downto 4) <= "0000";			
	--				ADDRB8(7 downto 4) <= "0000";
	--			end generate;	  
	--			
	--			EMPTYA5:if n=5 generate
	--				ADDRA8(7 downto 5) <= "000";			
	--				ADDRB8(7 downto 5) <= "000";
	--			end generate;	 
	--			
	--			EMPTYA6:if n=6 generate
	--				ADDRA8(6) <= '0';			
	--				ADDRB8(6) <= '0';	 
	--				ADDRA8(7) <= '0';			
	--				ADDRB8(7) <= '0';
	--			end generate;	   
	--			EMPTYA7:if n=7 generate
	--				ADDRA8(7) <= '0';			
	--				ADDRB8(7) <= '0';
	--			end generate;	
	--			
	--			ADDRA8(n-1 downto 0)<=ADDRW(n-1 downto 0);
	--			ADDRB8(n-1 downto 0)<=ADDRR(n-1 downto 0);
	--			
	--			
	--			RAM256_R:  RAMB4_S16_S16	
	--			port map(CLKA => CLK,CLKB => CLK,RSTA => RST,RSTB => RST,
	--				ENA => EN,ENB => EN,
	--				WEA =>WE,WEB => WEB,
	--				DOA => DOA, DOB => DOBR, 
	--				ADDRA => ADDRA8, ADDRB => ADDRB8,
	--				DIA => DIAR, DIB => DIB);		
	--			
	--			RAM256_I:  RAMB4_S16_S16	
	--			port map(CLKA => CLK,CLKB => CLK,RSTA => RST,RSTB => RST,
	--				ENA => EN,ENB => EN,
	--				WEA =>WE,WEB => WEB,
	--				DOA => DOA, DOB => DOBI, 
	--				ADDRA => ADDRA8, ADDRB => ADDRB8,
	--				DIA => DIAI, DIB => DIB);			
	--		end generate;							 
	--		
	--		RAMD512:	if 	  n=9 generate		
	--			
	--			ADDRA9(n-1 downto 0)<=ADDRW(n-1 downto 0);
	--			ADDRB9(n-1 downto 0)<=ADDRR(n-1 downto 0);
	--			
	--			RAMD9:for i in 0 to 1 generate
	--				
	--				RAM512_R:  RAMB4_S8_S8	
	--				port map(CLKA => CLK,CLKB => CLK,RSTA => RST,RSTB => RST,
	--					ENA => EN,ENB => EN,
	--					WEA =>WE,WEB => WEB,
	--					DOA => DOA(8*i+7 downto 8*i), DOB => DOBR(8*i+7 downto 8*i), 
	--					ADDRA => ADDRA9, ADDRB => ADDRB9,
	--					DIA => DIAR(8*i+7 downto 8*i), DIB => DIB(8*i+7 downto 8*i));		
	--				
	--				RAM512_I:  RAMB4_S8_S8	
	--				port map(CLKA => CLK,CLKB => CLK,RSTA => RST,RSTB => RST,
	--					ENA => EN,ENB => EN,
	--					WEA =>WE,WEB => WEB,
	--					DOA => DOA(8*i+7 downto 8*i), DOB => DOBI(8*i+7 downto 8*i), 
	--					ADDRA => ADDRA9, ADDRB => ADDRB9,
	--					DIA => DIAI(8*i+7 downto 8*i), DIB => DIB(8*i+7 downto 8*i));		
	--				
	--			end generate;   
	--			
	--		end generate;		
	--		
	--		RAMD1024:	if 	  n=10 generate		
	--			
	--			ADDRA10(n-1 downto 0)<=ADDRW(n-1 downto 0);
	--			ADDRB10(n-1 downto 0)<=ADDRR(n-1 downto 0);
	--			
	--			RAMD10:for i in 0 to 3 generate
	--				
	--				RAM1024_R:  RAMB4_S4_S4	
	--				port map(CLKA => CLK,CLKB => CLK,RSTA => RST,RSTB => RST,
	--					ENA => EN,ENB => EN,
	--					WEA =>WE,WEB => WEB,
	--					DOA => DOA(4*i+3 downto 4*i), DOB => DOBR(4*i+3 downto 4*i), 
	--					ADDRA => ADDRA10, ADDRB => ADDRB10,
	--					DIA => DIAR(4*i+3 downto 4*i), DIB => DIB(4*i+3 downto 4*i));		
	--				
	--				RAM1024_I:  RAMB4_S4_S4	
	--				port map(CLKA => CLK,CLKB => CLK,RSTA => RST,RSTB => RST,
	--					ENA => EN,ENB => EN,
	--					WEA =>WE,WEB => WEB,
	--					DOA => DOA(4*i+3 downto 4*i), DOB => DOBI(4*i+3 downto 4*i), 
	--					ADDRA => ADDRA10, ADDRB => ADDRB10,
	--					DIA => DIAI(4*i+3 downto 4*i), DIB => DIB(4*i+3 downto 4*i));		
	--				
	--			end generate;	
	--		end generate;
	--		
	--		RAMD2048:	if 	  n=11 generate		
	--			
	--			ADDRA11(n-1 downto 0)<=ADDRW(n-1 downto 0);
	--			ADDRB11(n-1 downto 0)<=ADDRR(n-1 downto 0);
	--			RAMD11:for i in 0 to 7 generate
	--				
	--				RAM2048_R:  RAMB4_S2_S2	
	--				port map(CLKA => CLK,CLKB => CLK,RSTA => RST,RSTB => RST,
	--					ENA => EN,ENB => EN,
	--					WEA =>WE,WEB => WEB,
	--					DOA => DOA(2*i+1 downto 2*i), DOB => DOBR(2*i+1 downto 2*i), 
	--					ADDRA => ADDRA11, ADDRB => ADDRB11,
	--					DIA => DIAR(2*i+1 downto 2*i), DIB => DIB(2*i+1 downto 2*i));	
	--				
	--				RAM2048_I:  RAMB4_S2_S2	
	--				port map(CLKA => CLK,CLKB => CLK,RSTA => RST,RSTB => RST,
	--					ENA => EN,ENB => EN,
	--					WEA =>WE,WEB => WEB,
	--					DOA => DOA(2*i+1 downto 2*i), DOB => DOBI(2*i+1 downto 2*i), 
	--					ADDRA => ADDRA11, ADDRB => ADDRB11,
	--					DIA => DIAI(2*i+1 downto 2*i), DIB => DIB(2*i+1 downto 2*i));	    			
	--				
	--			end generate;
	--		end generate;
	--	end generate;
	
	RAMD512v2:	if 	  n<=9 and v2=1 generate
		DIB<=(others=>'0');					  
		WEB<='0';
		ADDRB10(n downto 0)<=ADDRR(n downto 0);
		
		DIAR( width-1 downto 0)<= DMRE;
		DIAI( width-1 downto 0)<=DMIM;
		
		ADDRA10(n downto 0)<=ADDRW(n downto 0); 
		ADDRA10(9 downto n+1)<=(others=>'0');	
		ADDRB10(n downto 0)<=ADDRR(n downto 0);
		ADDRB10(9 downto n+1)<=(others=>'0');	
		
		
		-- Working RAMs		
		RAM1024_R:   RAMB16_S18_S18	 --Re -part
		port map (	     
			CLKA => CLK,  CLKB => CLK,SSRA => RST,SSRB => RESRAM,
			WEA  => WE, WEB  => WEB,ENA  => EN,ENB  => EN,  
			DIPA => DIAR(17 downto 16),
			DIPB => DIB(17 downto 16),
			DIA  => DIAR(15 downto 0),
			DIB  => DIB(15 downto 0),
			ADDRA => ADDRA10,
			ADDRB => ADDRB10,
			DOPA => open,--DOA2(17 downto 16),
			DOPB => DOBR(17 downto 16),
			DOA  => open,--DOA2(15 downto 0),
			DOB  => DOBR(15 downto 0)); 
		
		RAM1024_I:   RAMB16_S18_S18	 
		port map (	     
			CLKA => CLK,  CLKB => CLK,SSRA => RST,SSRB =>  RESRAM,
			WEA  => WE, WEB  => WEB,ENA  => EN,ENB  => EN,  
			DIPA => DIAI(17 downto 16),
			DIPB => DIB(17 downto 16),
			DIA  => DIAI(15 downto 0),
			DIB  => DIB(15 downto 0),
			ADDRA => ADDRA10, ADDRB => ADDRB10,
			DOPA => open,--DOA2(17 downto 16),
			DOPB => DOBI(17 downto 16),
			DOA  => open,--DOA2(15 downto 0),
			DOB  => DOBI(15 downto 0));
	end generate;
	
	RAMD1024v2:	if 	  n=10 and v2=1 generate	
		DIB<=(others=>'0');					  
		WEB<='0';
		
		ADDRB10<=ADDRR(n-1 downto 0);
		ADDRA10<=ADDRW(n-1 downto 0); 
		
		DIAR( width-1 downto 0)<= DMRE;
		DIAI( width-1 downto 0)<=DMIM;
		
		WE0<=WE when ADDRW(n)='0' else '0';
		WE1<=WE when ADDRW(n)='1' else '0';
		
		
		-- Working RAMs		
		RAM1024_R0:   RAMB16_S18_S18	 --Re -part
		port map (	     
			CLKA => CLK,  CLKB => CLK,SSRA => RST,SSRB =>  RESRAM,
			WEA  => WE0, WEB  => WEB,ENA  => EN,ENB  => EN,  
			DIPA => DIAR(17 downto 16),
			DIPB => DIB(17 downto 16),
			DIA  => DIAR(15 downto 0),
			DIB  => DIB(15 downto 0),
			ADDRA => ADDRA10,
			ADDRB => ADDRB10,
			DOPA => open,--DOA2(17 downto 16),
			DOPB => DOBR0(17 downto 16),
			DOA  => open,--DOA2(15 downto 0),
			DOB  => DOBR0(15 downto 0)); 
		
		RAM1024_I0:   RAMB16_S18_S18	 
		port map (	     
			CLKA => CLK,  CLKB => CLK,SSRA => RST,SSRB =>  RESRAM,
			WEA  => WE0, WEB  => WEB,ENA  => EN,ENB  => EN,  
			DIPA => DIAI(17 downto 16),
			DIPB => DIB(17 downto 16),
			DIA  => DIAI(15 downto 0),
			DIB  => DIB(15 downto 0),
			ADDRA => ADDRA10, ADDRB => ADDRB10,
			DOPA => open,--DOA2(17 downto 16),
			DOPB => DOBI0(17 downto 16),
			DOA  => open,--DOA2(15 downto 0),
			DOB  => DOBI0(15 downto 0));	 
		
		RAM1024_R1:   RAMB16_S18_S18	 --Re -part
		port map (	     
			CLKA => CLK,  CLKB => CLK,SSRA => RST,SSRB => RESRAM,
			WEA  => WE1, WEB  => WEB,ENA  => EN,ENB  => EN,  
			DIPA => DIAR(17 downto 16),
			DIPB => DIB(17 downto 16),
			DIA  => DIAR(15 downto 0),
			DIB  => DIB(15 downto 0),
			ADDRA => ADDRA10,
			ADDRB => ADDRB10,
			DOPA => open,--DOA2(17 downto 16),
			DOPB => DOBR1(17 downto 16),
			DOA  => open,--DOA2(15 downto 0),
			DOB  => DOBR1(15 downto 0)); 
		
		RAM1024_I1:   RAMB16_S18_S18	 
		port map (	     
			CLKA => CLK,  CLKB => CLK,SSRA => RST,SSRB => RESRAM,
			WEA  => WE1, WEB  => WEB,ENA  => EN,ENB  => EN,  
			DIPA => DIAI(17 downto 16),
			DIPB => DIB(17 downto 16),
			DIA  => DIAI(15 downto 0),
			DIB  => DIB(15 downto 0),
			ADDRA => ADDRA10, ADDRB => ADDRB10,
			DOPA => open,--DOA2(17 downto 16),
			DOPB => DOBI1(17 downto 16),
			DOA  => open,--DOA2(15 downto 0),
			DOB  => DOBI1(15 downto 0));
		
		TA:process(CLK,RST)begin
			if RST='1' then
				A10<='0';
			elsif rising_edge(CLK) then
				A10<=ADDRR(n);
			end if;
		end process;
		
		DOBR<=DOBR0 when A10='0' else DOBR1;
		DOBI<=DOBI0 when A10='0' else DOBI1;
		
	end generate;	
	
	
	TOVERFR:process(CLK,RST,DIAR,DIAI)
	begin  
		over<=  (DIAI( width-1) xor  DIAI( width-2)) or (DIAI( width-1) xor  DIAI( width-3)) 
		or (DIAR( width-1) xor  DIAR( width-2)) or (DIAR( width-1) xor  DIAR( width-3));
		
		if RST='1' then 
			OVERF<='0';
		elsif CLK='1' and CLK'event then
			if CE='1' then     
				if  INITOVERF='1' then
					OVERF<='0';
				elsif over='1' and WE='1' then
					OVERF<='1';
				end if;
			end if;
		end if;
	end process;
	
	
	
	DORE<=DOBR(width-1 downto 0)when SEL='0' else DIREi;  
	DOIM<=DOBI(width-1 downto 0)when SEL='0' else DIIMi;
	
	
	
end RAM1X;
