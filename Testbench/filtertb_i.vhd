---------------------------------------------------------------------
----                                                             ----
----  IIR Filter IP core                                         ----
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
---------------------------------------------------------------------------------------------------
--
-- Description :            Testbench for digital filters
--
---------------------------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.all;          
use IEEE.MATH_REAL.all;

entity FilterTB is                
	generic(fsampl:integer := 2000; 
		fstrt: integer:=0;
		deltaf:integer:=20;
		maxdelay:integer:=100;
		slowdown:integer:=3;
		magnitude:real:=1000.0
		);
	port(
		CLK : in STD_LOGIC;
		RST : in STD_LOGIC;
		RERSP : in INTEGER;
		IMRSP : in INTEGER;
		REO : out INTEGER;
		IMO : out INTEGER;
		FREQ : out INTEGER;
		MAGN:out INTEGER; 
		LOGMAGN:out REAL; 
		PHASE: out REAL ;
		ENA: inout STD_LOGIC
		);
end FilterTB;              

architecture FilterTB of FilterTB is
	signal freqi,REOI,IMOI: integer;    
	signal nextf: STD_LOGIC;    
	signal rdy: STD_LOGIC; 
	signal  rdyd:std_logic; 
	signal phasei,phaseo: real;
begin        
	
	SINGEN:process (CLK,RST)
		variable phase:real:=0.0;
		variable i:integer:=0;
	begin                       
		if ( RST='1' ) then     
			REOi<=0;
			IMOi<=0;
			i:=0;                 
			phase:=0.0;   
			nextf<='0';
		elsif ( CLK='1' and CLK'event ) then          
			if ( ENA='1' ) then
				REOi<=integer(magnitude*COS(2.0*MATH_PI*phase ));
				IMOi<=integer(magnitude*SIN(2.0*MATH_PI*phase));
				phase:=    phase+real(freqi)/real(fsampl);
				i:=i+1;
				if ( i=maxdelay) then
					i:=0;                 
					phase:=0.0;        
					nextf<='1';
				else
					nextf<='0';
				end if;       
				if ( i>=maxdelay-4 and i<=maxdelay-1  ) then
					rdy<='1';
				else
					rdy<='0';
				end if;             
			end if;   
		end if;    
	end process;
	REO<=REOi;
	IMO<=IMOi;
	
	SLOWER:process(CLK,RST)
		variable i:integer:=0;
	begin                
		if ( RST='1' ) then
			i:=0;
			ENA<='0';
		elsif ( CLK='1' and CLK'event ) then
			i:=i+1;
			if ( i=slowdown) then
				i:=0;
				ENA<='1';
			else
				ENA<='0';
			end if;        
		end if;    
	end process;          
	
	NEW_FREQ:process(CLK,RST)
	begin    
		if ( RST='1') then
			freqi<=fstrt ;
		elsif ( CLK='1' and CLK'event ) then
			if ( ENA='1' and nextf='1') then
				freqi<=freqi+deltaf; 
			end if;                    
		end if;       
	end process;
	
	FREQ<=freqi;
	
	MEASURE:process(CLK,RST)          
		variable re,im,rei,imi,mag,phasei,phaseo: real:=0.0;
		variable ct:natural; 
	begin                
		if ( RST='1') then
			MAGN<=0; 
			LOGMAGN<=0.0; 
			PHASE<=0.0;
		elsif ( CLK='1' and CLK'event) then
			if ( ENA='1' ) then	 
				rdyd<=rdy;	 
				if	 rdy='1' then
					
					
					
					re:= real(RERSP)  ;	  
					im:= real(IMRSP) ;    
					rei:= real(REOi)  ;
					imi:= real(IMOi) ;
					if re=0.0 then re:=0.00000001; end if;
					if rei=0.0 then rei:=0.00000001; end if; 
					if rdyd='0' then
						mag:=SQRT(re*re+im*im);
						ct:=0;
					elsif rdyd='1' then 
						mag:=mag +	SQRT(re*re+im*im); 
						ct:=ct+1;
					end if;
					if ( mag=0.0) then
						mag:=0.01;  
					end if;
					if ct=3   then
						MAGN<=integer(mag/4.0);
						LOGMAGN<=20.0*LOG10(mag/magnitude/4.0); 
						PHASEi:=ARCTAN(imi,rei);         
						PHASEo:=ARCTAN(im,re);                             
						PHASE<=PHASEo-PHASEi; 
						if (PHASEo-PHASEi >math_pi) then
							PHASE<=PHASEo-PHASEi-2.0*math_pi;      
						else
							PHASE<=PHASEo-PHASEi; 
						end if;      
						if   (PHASEo-PHASEi < (- math_pi)) then
							PHASE<=PHASEo-PHASEi+2.0*math_pi;
						end if;	   								
					end if;
				end if;
			end if;
		end if;
	end process;
	
	
end FilterTB;
