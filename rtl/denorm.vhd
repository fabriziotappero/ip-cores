
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
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~		
--     Data is shifted right and then written when is address is
--      betweenn  0100..0 and 1011..1


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;	  
use IEEE.std_logic_signed.all;	  

entity DENORM is	
	generic	(width: integer :=8	;	--  word width =8...24
		n:INTEGER:=7 ;
		satur:INTEGER:=1 ; --1 - usilenie s ogranicheniem 
		reall:INTEGER:= 0 ;
		v2:INTEGER:=1 );-- 1 - Virtex2
	port (
		CLK: in STD_LOGIC;
		RST: in STD_LOGIC;
		CE: in STD_LOGIC;	 
		DATAE: in STD_LOGIC;
		START: in STD_LOGIC;      -- 
		INIT: in STD_LOGIC;      -- 
		WERES: in STD_LOGIC; 
		SPRDY: in STD_LOGIC; 
		ADDRRES: in STD_LOGIC_VECTOR (n-1 downto 0);    
		EXPI: in STD_LOGIC_VECTOR (3 downto 0);	
		EXPF: in STD_LOGIC_VECTOR (3 downto 0);	
		REDI: in STD_LOGIC_VECTOR (width-1 downto 0);
		IMDI: in STD_LOGIC_VECTOR (width-1 downto 0);	  
		RDY: out STD_LOGIC;	
		REDO: out STD_LOGIC_VECTOR (width-1 downto 0);
		IMDO: out STD_LOGIC_VECTOR (width-1 downto 0)
		);
end DENORM;


architecture FFTDPATH_s of DENORM is  	  
	component  RAMB16_S36_S36 is
		port (DIA    : in STD_LOGIC_VECTOR (31 downto 0);
			DIB    : in STD_LOGIC_VECTOR (31 downto 0);
			DIPA    : in STD_LOGIC_VECTOR (3 downto 0);
			DIPB    : in STD_LOGIC_VECTOR (3 downto 0);
			ENA    : in STD_ULOGIC;
			ENB    : in STD_ULOGIC;
			WEA    : in STD_ULOGIC;
			WEB    : in STD_ULOGIC;
			SSRA   : in STD_ULOGIC;
			SSRB   : in STD_ULOGIC;
			CLKA   : in STD_ULOGIC;
			CLKB   : in STD_ULOGIC;
			ADDRA  : in STD_LOGIC_VECTOR (8 downto 0);
			ADDRB  : in STD_LOGIC_VECTOR (8 downto 0);
			DOA    : out STD_LOGIC_VECTOR (31 downto 0);
			DOB    : out STD_LOGIC_VECTOR (31 downto 0);
			DOPA    : out STD_LOGIC_VECTOR (3 downto 0);
			DOPB    : out STD_LOGIC_VECTOR (3 downto 0)
			); 
	end	component; 		 
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
	constant nulls:std_logic_vector(31 downto 0):=X"00000000"; 
	constant ones:std_logic_vector(n-1 downto 0):=(others=>'1'); 
	constant plus1:std_logic_vector(17 downto 0):="011111111111111111"; 
	constant minus1:std_logic_vector(17 downto 0):="100000000000000000"; 
	constant gnd:STD_LOGIC:='0'; 
	constant endaddrr:std_logic_vector(9 downto 0):=nulls(9-n downto 0)&ones; 
	constant endaddr:STD_LOGIC_VECTOR (9 downto 0):=
	conv_std_logic_vector((2**n-10),10);
	
	signal exp,expfi:std_logic_vector(3 downto 0);  
	signal DRES,DIMS:std_logic_vector(17 downto 0);  
	signal DRESS,DIMSS:std_logic_vector(18 downto 0);  
	signal DRE0,DIM0,DIMou,REDOi,REDOii,IMDOi,IMDOii:std_logic_vector(17 downto 0);  
	signal DRE0i,DIM0i,DRESi,DIMSi:std_logic_vector(31 downto 0);  
	signal D32,D32o:std_logic_vector(31 downto 0);  
	signal D4,D4o:std_logic_vector(3 downto 0);  
	signal ADDR:std_logic_vector(n-1 downto 0); 
	signal ADDRW,addrr:std_logic_vector(9 downto 0); 
	signal WEM,an:STD_LOGIC;
	
	
begin				 
	
	
	RC:process(CLK,RST)	  
		variable	exi:STD_LOGIC_VECTOR(4 downto 0);
	begin
		if RST='1' then 
			exp<="0000";
			expfi<="0000";
		elsif rising_edge(CLK) then	
			if SPRDY='1' then
				if reall=1 then
					expfi<=EXPF; 
				else
					expfi<=EXPF+2; 
				end if;
			end if;	
			exi:='0'&EXPI+ EXPFi;		--common exponent  
			--if exi(4)='1' then
			--				exi:="00000";
			--			end if;
			if INIT='1' then 
				
				EXP<=exi(3 downto 0);	
				
				
			end if;	
		end if;
	end process; 
	
	DRE0i<=SXT(REDI,32)	;
	DIM0i<=SXT(IMDI,32);   
	
	DRESi <= SHL(DRE0i,exp);
	DIMSi <= SHL(DIM0i,exp); 
	DRESs<=DRESi(20+n downto n+2);
	DIMSs<=DIMSi(20+n downto n+2);  
	
	SAT:if satur=1 generate
		DRES<= plus1 when DRESS(18)='0' and  DRESS(17)='1' else
		minus1 when DRESS(18)='1' and  DRESS(17)='0' else 
		DRESS(17 downto 0);
		DIMS<= plus1 when DIMSS(18)='0' and  DIMSS(17)='1' else
		minus1 when DIMSS(18)='1' and  DIMSS(17)='0' else 
		DIMSS(17 downto 0);
	end generate; 
	NSAT:if satur=0 generate
		DRES<= DRESS(17 downto 0);
		DIMS<=DIMSS(17 downto 0);
	end generate; 	
	
	
	D32<=DIMS(13 downto 0)&DRES;
	D4<=DIMS(17 downto 14);
	
	ADDR<=ADDRRES;
	ADR:process(addr) begin
		ADDRW<=(others=>'0');
		ADDRW(n-1)<=an;
		ADDRW(n-2)<=not ADDR(n-2);--	not ADDR(n-2);	
		ADDRW(n-3 downto 0)<=	ADDR(n-3 downto 0);	 
	end process; 
	WEM<=WERES when (ADDR(n-1) xor ADDR(n-2))='1' else '0';
	--WEM<=WERES when ADDR(n-1)='0' else '0';
	
	CTO:process(CLK,RST)  
		variable ea: std_logic_vector(9 downto 0);
	
	begin				 
		if reall=0 then
		ea:=endaddr;--"0000000000"; 
		else	
		ea:=endaddrr;
		end if;	
		
		if RST='1' then 
				RDY<='0';
			an<='0';
			addrr<=ea;
		elsif rising_edge(CLK) then
			if start ='1' then
				an<='1';
				addrr<=ea;--0000000000";		
			elsif  DATAE='1' then
				if addrr(n-1 downto 0)=nulls(n-1 downto 0) then--ones(n-1 downto 0) then
					addrr<=endaddrr;  
					RDY<='1';
				else 
						RDY<='0';
					addrr<=addrr-1;	  --adres tshtenija dla wydachi resultata
				end if;	 
			
			end if;
			if init='1' then
				an<=not an;
			end if;
			
		end if;
	end process; 
	
	
	
	RAM_V2_9:	 if V2=1 and n<=9 generate
		U_RAM512: RAMB16_S36_S36 
		port map (DIA=>D32,
			DIB  =>nulls,
			DIPA =>D4,
			DIPB =>nulls(3 downto 0),
			ENA  =>CE,
			ENB  =>CE,
			WEA  =>WEM,
			WEB  =>gnd,
			SSRA =>gnd,
			SSRB =>gnd,
			CLKA =>CLK,
			CLKB =>CLK,
			ADDRA =>ADDRW(8 downto 0),
			ADDRB =>ADDRR(8 downto 0),
			DOA  =>open,
			DOB   =>D32o, 
			DOPA  =>open,
			DOPB  =>d4o	);
		REDO<=  D32o(17 downto 18-width) ;
		DIMou<=  D4o  & D32o(31 downto 18);	
		IMDO<=	DIMOu(17 downto 18-width) ;	 
		
	end generate;
	
	RAM_V2_10:	 if V2=1 and n=10 generate
		U_RAM1024_0: RAMB16_S18_S18 
		port map (DIA=>DRES(15 downto 0),
			DIB  =>nulls(15 downto 0),
			DIPA =>DRES(17 downto 16),
			DIPB =>nulls(1 downto 0),
			ENA  =>CE,
			ENB  =>CE,
			WEA  =>WEM,
			WEB  =>gnd,
			SSRA =>gnd,
			SSRB =>gnd,
			CLKA =>CLK,
			CLKB =>CLK,
			ADDRA =>ADDRW,
			ADDRB =>ADDRR,
			DOA  =>open,
			DOB   =>REDOi(15 downto 0), 
			DOPA  =>open,
			DOPB  =>REDOi(17 downto 16));
		
		U_RAM1024_1:  RAMB16_S18_S18 
		port map (DIA=>DIMS(15 downto 0),
			DIB  =>nulls(15 downto 0),
			DIPA =>DIMS(17 downto 16),
			DIPB =>nulls(1 downto 0),
			ENA  =>CE,
			ENB  =>CE,
			WEA  =>WEM,
			WEB  =>gnd,
			SSRA =>gnd,
			SSRB =>gnd,
			CLKA =>CLK,
			CLKB =>CLK,
			ADDRA =>ADDRW,
			ADDRB =>ADDRR,
			DOA  =>open,
			DOB   =>IMDOi(15 downto 0), 
			DOPA  =>open,
			DOPB  =>IMDOi(17 downto 16));	
		
		
		
		REDO<=  REDOi(17 downto 18-width) ;
		IMDO<=  IMDOi(17 downto 18-width) ;
	end generate;
	
	
	
	
	
end FFTDPATH_s;
