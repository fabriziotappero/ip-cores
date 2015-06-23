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
use IEEE.std_logic_unsigned.all;	
use IEEE.std_logic_arith.all;	

entity  CONTROLi is
	generic	(n:INTEGER;  -- 6,7,8,9,10,11
		reall:INTEGER:= 0  --wch. mass: 0 -complex 1 - 2 realnych
		);
	port (
		CLK: in STD_LOGIC;
		RST: in STD_LOGIC;
		CE: in STD_LOGIC;
		START: in STD_LOGIC;
		DATAE: in STD_LOGIC;
		OVERF: in STD_LOGIC;
		FILTER: in STD_LOGIC_VECTOR (1 downto 0);		--0 -ne filtruet 1 - filtruet 2-+diff 3 +2diff
		L1:in STD_LOGIC_VECTOR (n-1 downto 0);		 -- tsastoty filtrow
		H1:in STD_LOGIC_VECTOR (n-1 downto 0);		 -- tsastoty filtrow
		L2:in STD_LOGIC_VECTOR (n-1 downto 0);
		H2:in STD_LOGIC_VECTOR (n-1 downto 0);
		FFTRDY: out STD_LOGIC;
		READY: out STD_LOGIC;
		WEI: out STD_LOGIC;
		WEM: out STD_LOGIC;    
		WERES: out STD_LOGIC;
		ODDC:	  out STD_LOGIC;
		EVEN: out STD_LOGIC;			 --0- 0th bank 1- 1st bank -for DIRE,DIIM
		DIV2: out STD_LOGIC; 
		ZWR: out STD_LOGIC;	
		ZWI: out STD_LOGIC;	  
		SIGNRE:	 out STD_LOGIC;	 
		INITOVERF:   out STD_LOGIC;   
		RESRAM:   out STD_LOGIC;   
		SEL: out STD_LOGIC;	  -- 0 -fromDIRE,DIIM, 1 - DMRE,DMIM 
		SELW: out STD_LOGIC_vector(1 downto 0);	  --0 -twiddle 1 - window  
		MODE: out STD_LOGIC_VECTOR (1 downto 0); 
		EXP: out STD_LOGIC_VECTOR (3 downto 0);
		ADDRR: out STD_LOGIC_VECTOR (n  downto 0);  
		ADDRWM: out STD_LOGIC_VECTOR (n downto 0) ;
		ADDRRES: out STD_LOGIC_VECTOR (n - 1 downto 0);    
		ADDRROM :out STD_LOGIC_VECTOR(n- 2 downto 0)
		);
end CONTROLi;



architecture CONTROL_slip of CONTROLi is
	
	constant NN: INTEGER:=2**n;   
	constant lat: INTEGER:=6;--7; --latency
	constant lat2: INTEGER:=7; --latency in butterflies       
	constant one:INTEGER:=2**(n-1);    
	constant onehalf:INTEGER:=2**(n-2);
	signal   startd,strt,iarrdy,iarrdy1,go,god,god2,DATAED: STD_LOGIC;     
	signal fftfly,filt1fly,filt2fly,filt3fly,resfly:   STD_LOGIC; --FFT run flag,input flag,result fag
	signal resrdy, idatardy:   STD_LOGIC; --FFT result ready flag
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
	signal 	ADDRwosstw:  STD_LOGIC_VECTOR (n-1 downto 0); --data reading address
	signal 	ADDRWi:  STD_LOGIC_VECTOR (n-1 downto 0); --data writimg address
	signal 	addres0,addres1:	STD_LOGIC_VECTOR (n-1 downto 0);
	signal	resnum:STD_LOGIC_VECTOR (n-1 downto 0);			
	signal	resnumi:STD_LOGIC_VECTOR (n downto 0);			
	signal 	ADDRwf,addrwfi,addrrf,addrrfi,ctt,addrfilt:  STD_LOGIC_VECTOR (n-1 downto 0); --data writimg address
	signal addrfilt1,addrfilt2: STD_LOGIC_VECTOR (4 downto 0);
	signal 	ADDRF:  STD_LOGIC_VECTOR (n-2 downto 0); --data writing address
	signal 	bflies:  STD_LOGIC_VECTOR (n downto 0); --butterfly counter
	signal startiterad:       STD_LOGIC_VECTOR (15 downto 0);  
	signal incaddrf:STD_LOGIC_VECTOR(n-2 downto 0);    -- increment to the factor address
	signal 	EXPi:  STD_LOGIC_VECTOR (3 downto 0);     
	signal ADDRROMi,addrROMF :STD_LOGIC_VECTOR (n-2 downto 0); 
	signal	WERESULTi,wed,filtd:  STD_LOGIC;    
	signal irdy:STD_LOGIC_VECTOR (1 downto 0);
	signal ird,winend,wefilt,outp:  STD_LOGIC;    
	signal filt1flyd,filt2flyd,filt3flyd,resflyd:STD_LOGIC_VECTOR (15 downto 0);	
	signal fwd,fwdd,resend,wereswosst:STD_LOGIC; 
	signal filt1end,filt2end,filt3end:std_logic;
	constant nulls:STD_LOGIC_VECTOR (n-1 downto 0):=(others=>'0');
	constant ones:STD_LOGIC_VECTOR (n-1 downto 0):=(others=>'1');
	constant oneh:STD_LOGIC_VECTOR (n downto 0):=
	conv_std_logic_vector((nn),n+1);
	constant nullsaf:STD_LOGIC_VECTOR (n-6 downto 0):=(others=>'0');
begin             
	
	
	
	
	CTRFILT1:process(CLK,RST,addrwfi,oddci)    -- data counter for reading/writing to multiply by window
		variable addrwfii:  STD_LOGIC_VECTOR (n-1 downto 0);
	begin
		if RST='1' then     
			addrwfi<=(others=>'0');	
			ctt<=(others=>'0');	
			addrfilt1<=(others=>'0');	
			addrfilt2<=(others=>'0');
			addrrfi<=(others=>'0');
			wefilt<='0';	 
			filt1end<='0'; -- koniec umnozenia na okno
			EVEN<='0';
			startd<='0'; 
			filtd<='0';	 
			addrROMF<=(others=>'0');
		elsif CLK='1' and CLK'event then
			if CE='1' then	   
				filtd<=filt2fly or  filt3fly;
				EVEN<=filt1fly;  
				filt1flyd<=filt1flyd(14 downto 0)& filt1fly ;	
				filt2flyd<=filt2flyd(14 downto 0)& filt2fly;	
				filt3flyd<=filt3flyd(14 downto 0)& filt3fly;	
				filt1end<='0'; 
				filt2end<='0'; 
				filt3end<='0';				
				startd<=START;
				if (START='0' and startd='1')
					or (filt1end='1' and FILTER="10") 
					or (filt2end='1' and FILTER="11")  then 	-- or FFTRDYi='1' 
					addrwfi<=(others=>'0');	
					ctt<=(others=>'0');	 
					if L1=nulls then 
						addrfilt1<="01000";
					else
						addrfilt1<="00000";
					end if;
					if L2=nulls then 
						addrfilt2<="01000";	
					else
						addrfilt2<="00000";		
					end if;
					addrrfi<=(others=>'0');
					wefilt<='0';	 
				elsif filt1fly='1' then
					if ODDCi='1' then
						ctt<=ctt+1;	 
						if ctt>=L1-5 and addrfilt1<8 then 
							addrfilt1<=addrfilt1+1;
						end if;					 
						if ctt>=H1-3 and addrfilt1<16 then 
							addrfilt1<=addrfilt1+1;
						end if;	
						
						
						if ctt>=L2-5 and addrfilt2<8 then 
							addrfilt2<=addrfilt2+1;
						end if;					 
						if ctt>=H2-3 and addrfilt2<16 then 
							addrfilt2<=addrfilt2+1;
						end if;	
					end if;	   
					if wefilt='1' then
						addrwfi<=addrwfi+1;--address zapisi 
					end if;
					if filt1flyd(2)='1' then
						wefilt<='1';
					end if;
					if	addrwf= nn-1  then
						filt1end<='1';	  --konec umnozenia na okno
					end if;	   
					if	addrwf= nn-1 or filt1end='1' then
						wefilt<='0';
					end if;
					
				elsif (filt2fly or  filt3fly)='1'   then	   --filtd='1'---------differenciator
					addrrfi<=addrrfi+1;				
					if wefilt='1' then
						addrwfi<=addrwfi+1;--address zapisi 
					end if;
					if (filt2flyd(3)='1')--and filt2fly='1') 
						or (filt3flyd(3)='1')--and filt3fly='1') 
						then
						wefilt<='1'; 
					end if;	
					if	addrwfi= nn-1 then 
						if filt2fly='1' then
							filt2end<='1';	  --konec umnozenia na okno
							wefilt<='0';
						elsif filt3fly='1' then
							filt3end<='1';
							wefilt<='0';	
						end if;
						
					end if;	
				end if;	
				addrROMF<=addrrfi(n-1 downto 1);
			end if;	  
		end if;		 
		
		   addrwfii:= addrwfi(0)&addrwfi(n-1 downto 1);
		
		if     (filt1fly='1' and reall=0)
			or (filt2fly='1' and reall=0)
			or (filt3fly='1' and reall=0 ) then
			for i in 0 to n-1 loop
				addrwf(i)<=addrwfii(n-i-1);   --2-th inverse writing address
			end loop;
		else  
			addrwf<=addrwfi;
		end if;
	end process;	
	addrrf<=addrrfi ;--when oddci='0'
	--	else not addrrfi; 
	
	addrfilt<=nullsaf & addrfilt1 when oddci='0'  --'1'
	else nullsaf & addrfilt2 ;
	
	
	
	
	
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
				startiterad<=startiterad(14 downto 0)&startitera; 
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
				if (START='0' and startd='1') or filt1end='1' or filt2end='1'or filt3end='1'
					or startitera='1' or FFTend='1' or resend='1' then  
					ODDCi<='0'; 
				else -- fftfly='1' or resfly='1' then
					ODDCi<= not ODDCi;
				end if;		 
			end if;
		end if;  
	end process;		
	
	ODDC<= ODDCi;
	
	CTRADDR:process(CLK,RST,addrri)  --FFT read counter        
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
					sum:='0'&ADDRRi+itera;      
					inc:= sum(n);
					ADDRRi<=sum(n-1 downto 0)+inc;
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
					sum:='0'&ADDRWi+itera;      
					inc:= sum(n);
					ADDRWi<=sum(n-1 downto 0)+inc;
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
					ADDRF<=ADDRF+incaddrf;
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
				if ADDRF=onehalf then    
					ZWR<='1';
				else
					ZWR<='0';
				end if; 
				
				if ADDRF=0 or resfly='1' then    
					ZWI<='1';
				else
					ZWI<='0';
				end if;            
				
				if ODDCi='1' then      --cosine address
					if ADDRF(n-2)='0' then
						ADDRROMi<='0'&ADDRF(n-3 downto 0);	    
						SIGNRE<='0';
					else
						ADDRROMi<=onehalf-('0'&ADDRF(n-3 downto 0));    
						SIGNRE<='1';
					end if;     
					
				else                                 -- sine address
					if ADDRF(n-2)='0' then
						ADDRROMi<=onehalf -('0'&ADDRF(n-3 downto 0));   
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
			resrdy<='0';
			
		elsif CLK='1' and CLK'event then
			if CE='1' then    
				resrdy<=  startitera and	itera(n-2);					
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
					bflies<=bflies+1;
				end if;           
				
				if idatardy ='1' and go ='0'   then
					FFTRDYi<='1';
				elsif bflies=nn + lat2 and enditera='0' then 
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
	
	
	CTWOSST:process(CLK,RST,addres0,addres1,oddci)  -- data counters for wosstanowlenija
		variable addrw:STD_LOGIC_VECTOR(n-1 downto 0);
	begin
		if RST='1' then     
			addres0<=(others=>'0');	
			addres1<=(others=>'0');
			resnumi<=(others=>'0');	 
			resend<='0';
			--	WERESwosst<='0';	
			RESRAM<='0';
		elsif CLK='1' and CLK'event then  
			
			if CE='1' then
				resend<='0';
				resflyd<=resflyd(14 downto 0)& resfly;	
				if (FILTER=0 and reall=1 and START='0' and startd = '1')
					or (FILTER=1 and filt1end='1'and reall=1)
					or (FILTER=2 and filt2end='1'and reall=1)
					or (FILTER=3 and filt3end='1'and reall=1)
					then 	
					RESRAM<='0';	
					addres0<=  (others=>'0');   
					addres1<= (others=>'0');  
					resnumi<=(others=>'0');	 
				elsif resfly='1' then
					if oddci='1' and resflyd(7)='1' then   --'1'
						addres0<=UNSIGNED(addres0)+1;    
						addres1<=UNSIGNED(addres1)-1;    
					end if;	 
					resnumi<=UNSIGNED(resnumi)+1;
					if resnumi=oneh then
						RESRAM<='1';
					end if;
				end if;	  
				if UNSIGNED(addres0)=nn/2 then
					resend<='1';
				end if;	  
				if (resflyd(7) and resfly)='0' then
					RESRAM<='0';	
				end if;
			end if;	
		end if;		 
		if	oddci='0' then
			addrw:= addres0;
		else 
			addrw:=	addres1;  
		end if;
		--2-ja inversija	
		if reall=1 then
			for i in 0 to n-1 loop
				addrwosstw(i)<=addrw(n-i-1);   --2-th inverse writing address
			end loop;
		else
			addrwosstw<=addrw;
		end if;
		
	end process; 			  
	WERESwosst<=resflyd(7) and resfly;
	
	resnum<=resnumi(n-1 downto 0);
	
	
	TTFFTFLY:process(CLK,RST,enditera) --triggers of the FFT running
	begin
		if RST='1' then	  
			filt1fly<='0';   
			filt2fly<='0';   
			filt3fly<='0';   
			resfly<='0';   
			fftfly<='0';      
			fftend<='0';	
			MODE<="00";		  
		elsif CLK='1' and CLK'event    then
			if CE='1' then	 
				if START='0' and startd = '1'then-- 
					if FILTER=0 then
						if reall=0 then	
							MODE<="01";	
							fftfly<='1';		
						else
							resfly<='1';
							MODE<="10";
						end if;
					else
						filt1fly<='1';
						MODE<="00";	
					end if;
				elsif filt1end='1' then
					filt1fly<='0';
					if FILTER=1 then
						if reall=0 then	
							MODE<="01";	
							fftfly<='1';		
						else
							resfly<='1';
							MODE<="10";
						end if;
					else
						filt2fly<='1';
						MODE<="11";
					end if;
				elsif filt2end='1' then	
					filt2fly<='0';
					if FILTER=2 then
						if reall=0 then
							MODE<="01";	
							fftfly<='1';
						else
							MODE<="10";	
							resfly<='1';
						end if;
					else
						filt3fly<='1';
						MODE<="11";	
					end if;	 
				elsif filt3end='1' then	
					filt3fly<='0'; 
					if reall=0 then
						MODE<="01";	
						fftfly<='1';
					else
						MODE<="10";	
						resfly<='1';
					end if;
				elsif resend='1' then
					resfly<='0';
					fftfly<='1';
					MODE<="01";	
				elsif FFTend='1' then
					fftfly<='0';
				end if;	  
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
				if ((FILTER=0 and start='0' and startd='1')
					or (FILTER=1 and filt1end='1')
					or (FILTER=2 and filt2end='1')
					or (FILTER=3 and filt3end='1'))	 then
					EXPi<=( 0 =>OVERF, others=>'0');      
					DIV2<= overf;
				elsif startitera='1' and (fftfly='1' or resfly='1')then 
					if OVERF = '1' then
						EXPi<=UNSIGNED(EXPi)+1;    
						DIV2<='1';    
					else 
						DIV2<='0';
					end if;  
				elsif 	FFTRDYi='1' then
					DIV2<='0';
				end if;
			end if;
		end if;   
	end process;  
	
	
	--WEI<=DATAE; 
	WEd<=DATAE; 
	
	
	
	
	FFTRDY<=	FFTRDYi  after 3 ns;
	startitera<=  '1' when (enditera='1' and FFTRDYi='0') 
	or (filt1end='1' and FILTER=1 and reall=0)
	or (filt2end='1' and FILTER=2 and reall=0 )
	or (filt3end='1' and FILTER=3 and reall=0)
	or (resend='1' and reall=1)
	else '0';	
	
	WEM<=wefilt when filt1fly='1' or filt2fly='1'or filt3fly='1'
	else wefft  when fftfly='1'
	else WERESwosst ;   
	
	
	
	WERES<=	WERESULTi after 1 ns;        
	ADDRRES<= ADDRWi when fftfly='1' and itera(n-1)='1' else (others=>'0'); 
	
	ADDRR<='1'& resnum  when resfly='1'
	else '1'& addrrf when filt2fly='1' or filt3fly='1' 	
	else '0'& ADDRRi ; 								   
	
	ADDRWM<= '0'&addrwf  when filt1fly='1'and FILTER=1  and reall=0 
	else '1'&addrwf  when filt3fly='1' or filt2fly='1'	or filt1fly='1' 
	else '0'&addrwosstw when resfly='1'
	else '0'& ADDRWi; 
	
	SEL<='1' when (FILTER="00" and reall=0 and fftfly ='1' and itera(0)='1')
	or(FILTER="00" and reall=1 and resfly ='1')
	or(FILTER/="00" and filt1fly='1')
	else '0';
	
	SELW<= "01" when filt1fly='1' else
	"10" when (Filt2fly or filt3fly)='1' else
	"00";	  
	
	INITOVERF<=startitera;-- and START;   
	
	ADDRROM<= addrfilt(n-2 downto 0) when filt1fly='1'
	else addrROMF when filt2fly='1' or filt3fly='1'
	else ADDRROMi(n-2 downto 0) when fftfly='1'
	else (others=>'0');-- when oddci='1'	else '1'&nulls(n-3 downto 0);
	
	READY<=resrdy  after 3 ns;
	
	EXP<=EXPi;    
	
end CONTROL_slip;
