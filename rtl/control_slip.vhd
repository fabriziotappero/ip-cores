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

entity CONTROL is
	generic	(	ifft:INTEGER:=0;	     
		rams:INTEGER:=2;
		n:INTEGER:=8;  -- 6,7,8,9,10,11
		slip:INTEGER;
		reall:INTEGER:= 0  --wch. mass: 0 -complex 1 - 2 realnych
		);
	port (
		CLK: in STD_LOGIC;
		RST: in STD_LOGIC;
		CE: in STD_LOGIC;	  
		START: in STD_LOGIC;
		DATAE: in STD_LOGIC;
		OVERF: in STD_LOGIC;     
		FFTRDY: out STD_LOGIC;
		READY: out STD_LOGIC;
		WE: out STD_LOGIC;
		WEI: out STD_LOGIC;
		WEM: out STD_LOGIC;    
		WERES: out STD_LOGIC;    
		--HRES: out STD_LOGIC;    
		INITOVERF:   out STD_LOGIC;    
		--		SEL: out STD_LOGIC;									  -- 0 -fromDIRE,DIIM, 1 - DMRE,DMIM 
		ODDC:	  out STD_LOGIC;
		EVEN: out STD_LOGIC;			 --0- 0th bank 1- 1st bank -for DIRE,DIIM
		DIV2: out STD_LOGIC; 
		ZWR: out STD_LOGIC;	
		ZWI: out STD_LOGIC;	  
		SELW: out STD_LOGIC;	  --0 -twiddle 1 - window
		SIGNRE:	 out STD_LOGIC;	
		MODE: out STD_LOGIC_VECTOR (1 downto 0); 
		EXP: out STD_LOGIC_VECTOR (3 downto 0);
		ADDRR: out STD_LOGIC_VECTOR (n - 1 downto 0); -- data reading address   
		ADDRWIN: out STD_LOGIC_VECTOR (n - 1 downto 0);--input data writing address 
		ADDRWM: out STD_LOGIC_VECTOR (n - 1 downto 0) ;--working data writing address 
		ADDRRES: out STD_LOGIC_VECTOR (n - 1 downto 0);--result address    
		ADDRROM :out STD_LOGIC_VECTOR(n- 2 downto 0)
		);
end CONTROL;



architecture CONTROL_slip of CONTROL is
	
	constant NN: INTEGER:=2**n;   
	constant lat: INTEGER:=7; --latency
	constant lat2: INTEGER:=7; --latency in butterflies       
	constant one:INTEGER:=2**(n-1);    
	constant onehalf:INTEGER:=2**(n-2);
	signal   strt,iarrdy,iarrdy1,go,god,god2,DATAED: STD_LOGIC;     
	signal fftfly,infly,resfly:   STD_LOGIC; --FFT run flag,input flag,result fag
	signal resrdy, resrdy2,idatardy:   STD_LOGIC; --FFT result ready flag
	signal fftend,FFTRDYi:   STD_LOGIC; --FFT end flag
	signal enditera:STD_LOGIC; --end of iteration 
	signal incbfly:         STD_LOGIC; -- +1 to reading data address     
	signal incbflyw:         STD_LOGIC; -- +1 to writing data address     
	signal startitera: STD_LOGIC; -- iteration start
	signal startiterad1: STD_LOGIC; -- iteration start  
	signal startiterad0: STD_LOGIC; -- iteration start
	signal ODDCi:   STD_LOGIC; -- 1 when odd clock cycle         
	signal startiterad2: STD_LOGIC;     --delayed iteration start
	signal wefft: STD_LOGIC;     --we fft data
	signal addrwid,	addrwidi	:STD_LOGIC_VECTOR(n-1 downto 0);  --I. data writing address
	signal invaddr:STD_LOGIC_VECTOR(n-1 downto 0);--inverse writing address
	signal itera:STD_LOGIC_VECTOR(n-1 downto 0); --iteration number           
	signal 	ADDRRi:  STD_LOGIC_VECTOR (n-1 downto 0); --data reading address
	signal 	ADDRwosst,addrrwin:  STD_LOGIC_VECTOR (n-1 downto 0); --data reading address
	signal 	ADDRWi:  STD_LOGIC_VECTOR (n-1 downto 0); --data writimg address
	signal 	addres0,addres1:	STD_LOGIC_VECTOR (n-1 downto 0);
	signal	resnum,resnumi:STD_LOGIC_VECTOR (n-1 downto 0);			
	signal 	ADDRWwin,ADDRwwini,ADDRwnd:  STD_LOGIC_VECTOR (n-1 downto 0); --data writimg address
	signal 	ADDRF:  STD_LOGIC_VECTOR (n-2 downto 0); --data writing address
	signal 	bflies:  STD_LOGIC_VECTOR (n downto 0); --butterfly counter
	signal startiterad:       STD_LOGIC_VECTOR (lat downto 1);  
	signal incaddrf:STD_LOGIC_VECTOR(n-2 downto 0);    -- increment to the factor address
	signal 	EXPi:  STD_LOGIC_VECTOR (3 downto 0);     
	signal ADDRROMi :STD_LOGIC_VECTOR (n-2 downto 0); 
	signal	WERESULTi,wed:  STD_LOGIC;    
	signal irdy:STD_LOGIC_VECTOR (1 downto 0);
	signal ird,winend,wewin:  STD_LOGIC;    
	signal inflyd,resflyd:STD_LOGIC_VECTOR (15 downto 0);	
	signal fwd,fwdd,resend,resfld,wereswosst:STD_LOGIC;
	constant nulls:STD_LOGIC_VECTOR (n-2 downto 0):=(others=>'0');
begin             
	
	
	CTIDATA:process(CLK,RST)    -- data counter for input
	begin
		if RST='1' then     
			addrwidi<=(others=>'0');	
			addrwid<=(others=>'0');
			irdy<="00";	 
			ird<='0';
			idatardy<= '0';
		elsif CLK='1' and CLK'event then
			if CE='1' then 
				if START='1' then 	-- or FFTRDYi='1'
					addrwidi<=  (others=>'0');   
				elsif  DATAE='1' then	  --(strt='1' ) and or go='1'  or god2='1' 
					irdy<="00";
					if UNSIGNED(addrwidi)=NN-1 then
						addrwidi<=  (others=>'0');
						irdy<="10";
					else
						addrwidi<=UNSIGNED(addrwidi)+1;    
						
					end if;
					
					if UNSIGNED(addrwidi)=NN-1 then
						irdy<="10";
					elsif UNSIGNED(addrwidi)=NN/2-1 then
						irdy<="01";
					end if;
				end if;	
			end if; 
			ird<= irdy(0)or irdy(1);	
			idatardy<= (irdy(0)or irdy(1)) and not ird;
		end if;
	end process; 
	
	CTRIDAT_W:process(CLK,RST,addrwwini)    -- data counter for reading/writing to multiply by window
	begin
		if RST='1' then     
			addrrwin<=(others=>'0');	
			addrwnd<=(others=>'0');	
			addrwwini<=(others=>'0');
			wewin<='0';	 
			winend<='0';
			EVEN<='1';											  
			fwd<='1';  	
			fwdd<='1';	  
			winend<='0'; -- koniec umnozenia na okno
		elsif CLK='1' and CLK'event then
			if CE='1' then
				EVEN<=not infly;  
				fwdd<=fwd;
				inflyd<=inflyd(14 downto 0)& infly;	
				winend<='0';
				if iarrdy='1' then 	-- or FFTRDYi='1' 
					fwd<='1';
					addrrwin<=  irdy(0)& nulls ;   
					addrwwini<=(others=>'0');	
					addrwnd<=(others=>'0');	
				elsif infly='1' then
					addrrwin<=UNSIGNED(addrrwin)+1;
					if UNSIGNED(addrrwin(n-2 downto 0))= nn/2-2  then 
						fwd<='0';
					end if;
					if fwd='1' then
						addrwnd<=UNSIGNED(addrwnd)+1;--address okna   
					elsif fwdd='0' then  
						addrwnd<=UNSIGNED(addrwnd)-1;   
					end if;
					if	UNSIGNED(addrwnd)= nn-3 and fwd='0' then ---4
						winend<='1';	  --konec umnozenia na okno
					end if;	
				end if;
				if wewin='1' then	 --  inflyd(4)='1' 
					addrwwini<=UNSIGNED(addrwwini)+1;  
				end if;	 
				wewin<=inflyd(3);	--(4)
			end if;
		end if;	 
		for i in 0 to n-1 loop
			addrwwin(i)<=addrwwini(n-i-1); --addrwwini(i);--  --2-th inverse writing address
		end loop;
	end process; 	
	
	
	
	CTLAT:process(RST,CLK)      --delay on 1 LUT
	begin      
		if RST='1' then 
			startiterad1<='0'; 
			startiterad2<='0';   
		elsif CLK='1' and CLK'event then
			if CE='1' then       
				startiterad1<=startitera;  
				startiterad2<=startiterad0;
			end if;
		end if;  
	end process;     
	
	CTLATS:process(RST,CLK)      --delay on 1 LUT     
	begin      
		if CLK='1' and CLK'event then
			if CE='1' then       
				startiterad<=startiterad(lat-1 downto 1)&startitera; 
			end if;
		end if;        
	end process;
	startiterad0<=   startiterad(lat);     
	
	
	TODDC:process(CLK,RST)      --odd cycle	for FFT
	begin
		if RST='1' then
			ODDCi<='0';       
		elsif CLK='1' and CLK'event    then
			if CE='1' then      
				if startitera='1' or FFTend='1' or resend='1' then  
					ODDCi<='0'; 
				elsif fftfly='1' or resfly='1' then
					ODDCi<= not ODDCi;
				end if;		 
			end if;
		end if;  
	end process;		
	
	ODDC<= ODDCi;
	
	CTRADDR:process(CLK,RST,ADDRRi)  --FFT read counter        
		variable sum:STD_LOGIC_VECTOR (n downto 0);    
		variable inc:STD_LOGIC;
	begin      
		if RST='1' then           
			incbfly<='0';
			ADDRRi<=( others=>'0');  
		elsif CLK='1' and CLK'event then
			if CE='1' then  
				if startitera='1' then      
					ADDRRi<=( others=>'0');   
				elsif fftfly='1' then                               
					sum:=UNSIGNED('0'&ADDRRi)+UNSIGNED(itera);      
					inc:= sum(n);
					ADDRRi<=UNSIGNED(sum(n-1 downto 0))+inc;
					incbfly<=inc;
				end if;   
			end if;
		end if;   
	end process;           
	
	CTWADDR:process(CLK,RST,ADDRWi)  --FFT write counter       
		variable sum:STD_LOGIC_VECTOR (n downto 0);    
		variable inc:STD_LOGIC;
	begin      
		if RST='1' then           
			ADDRWi<=( others=>'0');  
		elsif CLK='1' and CLK'event then
			if CE='1' then  
				if startiterad2='1' then   
					ADDRWi<=( others=>'0');   
				elsif fftfly='1' then  
					sum:=UNSIGNED('0'&ADDRWi)+UNSIGNED(itera);      
					inc:= sum(n);
					ADDRWi<=UNSIGNED(sum(n-1 downto 0))+inc;
				end if;         
			end if;
		end if;   
	end process;                   
	
	LINCADDRF:process(itera)
	begin                     
		for i in 0 to n-2 loop
			incaddrf(i)<=itera(n-1-i);
		end loop;
	end process;          
	
	CTADDRF: process(CLK,RST)  --iteration counter               
	begin      
		if RST='1' then           
			ADDRF<=( others=>'0');  
		elsif CLK='1' and CLK'event then
			if CE='1' then  
				if startiterad1='1' then      
					ADDRF<=( others=>'0');   
				elsif fftfly='1' and incbfly = '1' then
					ADDRF<=UNSIGNED(ADDRF)+UNSIGNED(incaddrf);
				end if;   
			end if;
		end if;   
	end process;             
	
	
	
	FADDRROM:process(CLK,RST)
	begin
		if RST='1' then      
			SIGNRE<='0';
			ZWR<='0';
			ZWI<='0';
			ADDRROMi<=( others=>'0');  
		elsif CLK='1' and CLK'event then
			if CE='1' then           
				if UNSIGNED(ADDRF)=onehalf then    
					ZWR<='1';
				else
					ZWR<='0';
				end if; 
				
				if UNSIGNED(ADDRF)=0 or resfly='1' then    
					ZWI<='1';
				else
					ZWI<='0';
				end if;            
				
				if ODDCi='1' then      --cosine address
					if ADDRF(n-2)='0' then
						ADDRROMi<='0'&ADDRF(n-3 downto 0);	    
						SIGNRE<='0';
					else
						ADDRROMi<=onehalf-UNSIGNED('0'&ADDRF(n-3 downto 0));    
						SIGNRE<='1';
					end if;     
					
				else                                 -- sine address
					if ADDRF(n-2)='0' then
						ADDRROMi<=onehalf -UNSIGNED('0'&ADDRF(n-3 downto 0));   
					else
						ADDRROMi<='0'&ADDRF(n-3 downto 0);	
					end if;       
				end if;       
			end if;
		end if;   
	end process;     
	
	
	CTBFLIES:process(CLK,RST,bflies)  --butterfly counter               
	begin      
		if RST='1' then        
			wefft<='0';     
			enditera<='0';
			bflies<=( others=>'0');   
			WERESULTi<='0';     
			FFTRDYi<='0';
		elsif CLK='1' and CLK'event then
			if CE='1' then         
				
				if startiterad2='1' then   
					wefft<='1';         
					if  itera(n-1)='1'then
						WERESULTi<='1';    
					end if;
				end if;      
				
				if startitera='1' then  
					bflies<=( others=>'0');  
				elsif  fftfly='1'
					then
					bflies<=UNSIGNED(bflies)+1;
				end if;           
				
				if idatardy ='1' and go ='0'   then
					FFTRDYi<='1';
				elsif UNSIGNED(bflies)=nn + lat2 and enditera='0' then 
					enditera<='1'; 
					wefft<='0';
					WERESULTi<='0'; 
					if itera(n-1)='1' then
						FFTRDYi<='1';
					end if;
				else 
					enditera<='0';  
					FFTRDYi<='0';
				end if;  
			end if;
		end if;                       
	end process;           
	
	TIARRDY:process(CLK,RST)    --1st input data ready
	begin
		if RST='1' then     
			iarrdy<='0';    
			iarrdy1<='0';
			go<='0';   
			god<='0';    
			god2<='0';
		elsif CLK='1' and CLK'event then
			if CE='1' then 
				if START='1' then 
					iarrdy<='0';   
					iarrdy1<='0';   
					go<='0';
				elsif idatardy='1' then    
					iarrdy<='1';  
					go<='1';   
					god<='0';
					if go='0'
						then 
						iarrdy1<='1';
					end if;
					
				else 
					god2<=god;
					iarrdy<='0';     	
					iarrdy1<='0';    
					if   FFTRDYi='1' then
						god<='1'    ;
					end if;
				end if;
			end if; 
		end if;       
	end process;                      
	
	CTITERA:process(CLK,RST)  --iteration counter               
	begin      
		if RST='1' then 
			itera<=CONV_STD_LOGIC_VECTOR(1,n);  
		elsif CLK='1' and CLK'event then
			if CE='1' then               
				if  FFTRDYi='1' then
					itera<=CONV_STD_LOGIC_VECTOR(1,n);  
				elsif enditera='1' then
					itera<=itera(n-2 downto 0)&'0';
				end if;
			end if;
		end if;
	end process;     
	
	
	CTWOSST:process(CLK,RST)  -- data counters for wosstanowlenija
	begin
		if RST='1' then     
			addres0<=(others=>'0');	
			addres1<=(others=>'0');
			resnumi<=(others=>'0');	 
			resend<='0'; 
			resfld<='0';
			--	WERESwosst<='0';
		elsif CLK='1' and CLK'event then 
			resend<='0';
			if CE='1' then
				resflyd<=resflyd(14 downto 0)& resfly;	
				resfld<=resflyd(6);	
				
				if fftend='1' then 	-- or FFTRDYi='1'
					addres0<=  (others=>'0');   
					addres1<= (others=>'0');  -- conv_std_logic_vector(NN,n+1);
					resnumi<=(others=>'0');	 
					
				elsif resfly='1' then
					
					if oddci='1' then
						addres0<=UNSIGNED(addres0)+1;    
						addres1<=UNSIGNED(addres1)-1;    
					end if;		   
					
					if resfld='1' and resfly='1' then	
						resnumi<=UNSIGNED(resnumi)+1;    
					end if;	  
					if UNSIGNED(resnumi)=nn-2 then	  ---1
						resend<='1';
					end if;
				end if;	
			end if;
		end if;
	end process; 			  	
	
	WERESwosst<=resfld and resfly;
	addrwosst<=addres0 when oddci='1' else addres1(n-1 downto 0);
	resnum<=resnumi(0)&resnumi(n-1 downto 1);
	resrdy2<=resflyd(6) and not	resfld;
	
	TTFFTFLY:process(CLK,RST,enditera) --triggers of the FFT running
	begin
		if RST='1' then	  
			infly<='0';   
			resfly<='0';   
			fftfly<='0';      
			resrdy<='0';
			fftend<='0';	
			MODE<="00";
		elsif CLK='1' and CLK'event    then
			if CE='1' then
				if idatardy='1'then --iarrdy1='1'or FFTRDYi='1' then 
					infly<='1';	 
					MODE<="00";
				elsif winend='1' then
					infly<='0';
					fftfly<='1'; 
					MODE<="01";	
				elsif FFTend='1' then
					fftfly<='0';
					if reall=1 then
						resfly<='1';  
						MODE<="10";	
					end if;
				elsif resend='1' then
					resfly<='0';  	
					MODE<="00"; 
				end if;          
				resrdy<=  startiterad0 and itera(n-1);
			end if;
		end if;
		fftend<=  (enditera and itera(n-1)) ;
	end process;                                        
	
	REXP:  process(CLK,RST)  --exponent counter               
	begin      
		if RST='1' then           
			EXPi<=( others=>'0');
			DIV2<='0';
		elsif CLK='1' and CLK'event then
			if CE='1' then  
				if winend='1' then    
					EXPi<=( 0 =>OVERF, others=>'0');      
					DIV2<= OVERF;
				elsif enditera='1' or (fftend='1' and reall=1) then 
					if OVERF = '1' then
						EXPi<=UNSIGNED(EXPi)+1;    
						DIV2<='1';    
					else 
						DIV2<='0';
					end if; 
				elsif resend ='1' then   
					DIV2<='0';
				end if;
			end if;
		end if;   
	end process;  
	
	
	WEI<=DATAE; 
	WEd<=DATAE; 
	
	ADDRWIN<=addrwidi;
	
	
	
	FFTRDY<=	FFTRDYi  after 3 ns;
	startitera<=   (enditera and not FFTRDYi) or winend;	--  idatardy;--
	WEM<=wewin when infly='1'
	else(wefft  and  fftfly);   --  and not itera(n-1)
	
	
	
	WERES<=	WERESULTi when reall=0 else WERESwosst after 1 ns;        
	ADDRRES<= ADDRWi when fftfly='1' and reall=0 else resnum ; 
	
	ADDRR<=addrwosst  when resfly='1' else
	addrrwin when infly='1' else
	ADDRRi ; 
	
	ADDRWM<=addrwwin  when infly='1'
	else ADDRWi; 
	
	SELW<= not (FFTfly or resfly);	  
	
	INITOVERF<=startitera;-- and START;   
	
	ADDRROM<= addrwnd(n-2 downto 0) when infly='1'
	else ADDRROMi(n-2 downto 0) when fftfly='1'
	else (others=>'0');-- when oddci='1'	else '1'&nulls(n-3 downto 0);
	
	READY<=resrdy2 when reall=1 else resrdy  after 3 ns;
	
	EXP<=EXPi;    
	
end CONTROL_slip;
