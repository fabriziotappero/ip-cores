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
--		DESCRIPTION:
--
--	FUNCTION	 Fast Fourier Transform of
--                       N=16, 32, 64, 128, 256, 512, 1024, 2048 points,
--                       N= 2**n,
--                       ifft=0 forward FFT, =1 inverse FFT
--                       rams=1 - single data RAM, =2 dual data RAM
--                       input data width: iwidth = 8,...,16 bit   signed 
--      				       output   data width: owidth = 8,...,16 bit   signed     
--                       coefficient width : wwidth = 8,...,16 bit
--			            Synthesable for Virtex, SpartanII FPGAs. 
--             
--	FILES:		 ALFFT_Core_sli.vhd -this file
--               FFTDPATHi.vhd   - data path of the FFT butterfly       		 
--               CONTROL_i.vhd   - control unit       
--				      ROM_COSi.vhd   -	coefficient ROM
--				     RAMX_2.vhd   - data RAM block                  
--                  When redesign data RAM blocks
--                     the Core will fit another FPGA families
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~--

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;

entity ALFFT_Corei is          
	generic	(width: INTEGER:=8 	;   	-- output data width =8...16
		wwidth: INTEGER:=8;  			--  coefficient width =8...16  
		n:INTEGER:=7 ;
		v2:INTEGER:=1 ; -- 1 - Virtex2
		reall:INTEGER:= 0  --wch. mass: 0 -complex 1 - 2 realnych
		);  --4,5, 6,7,8,9,10,11   - transform length factor
	port (
		CLK: in STD_LOGIC;
		RST: in STD_LOGIC;
		CE: in STD_LOGIC; 
		START: in STD_LOGIC;
		FILTER: in STD_LOGIC_VECTOR (1 downto 0);		--0 -ne filtruet 1 - filtruet 2-+diff 3 +2diff
		L1:in STD_LOGIC_VECTOR (n-1 downto 0);		 -- tsastoty filtrow
		H1:in STD_LOGIC_VECTOR (n-1 downto 0);		 -- tsastoty filtrow
		L2:in STD_LOGIC_VECTOR (n-1 downto 0);
		H2:in STD_LOGIC_VECTOR (n-1 downto 0);
		DATAE: in STD_LOGIC;
		DATAIRE: in STD_LOGIC_VECTOR (width-1 downto 0);
		DATAIIM: in STD_LOGIC_VECTOR (width-1 downto 0);
		FFTRDY: out STD_LOGIC;
		READY: out STD_LOGIC;
		WERES: out STD_LOGIC;    
		ADDRRES: inout STD_LOGIC_VECTOR (n-1 downto 0);    
		DATAORE: out STD_LOGIC_VECTOR (width-1 downto 0);
		DATAOIM: out STD_LOGIC_VECTOR (width-1 downto 0);
		EXP: out STD_LOGIC_VECTOR (3 downto 0)	
		);
end ALFFT_Corei;

architecture ALFFT_CoreS of ALFFT_Corei is      
	
	component  FFTDPATHI is	
		generic	(width: integer :=8 	;		--  word width =8...16
			wwdth: integer:=7;  			--  coefficient width =7...15  
			reall:integer;
			V2:integer
			);
		port (
			CLK: in STD_LOGIC;
			RST: in STD_LOGIC;
			CE: in STD_LOGIC;	  
			ODDC:	  in STD_LOGIC;      --Odd cycle
			DIV2: in STD_LOGIC;             --Scaling factor
			ZWR: in STD_LOGIC;	
			ZWI: in STD_LOGIC;	  
			SIGNRE:	 in STD_LOGIC;	  		
			MODE: in STD_LOGIC_VECTOR (1 downto 0); 
			REDI: in STD_LOGIC_VECTOR (width downto 0);
			IMDI: in STD_LOGIC_VECTOR (width downto 0);	  
			WF: in STD_LOGIC_VECTOR (wwdth-1 downto 0);
			REDO: out STD_LOGIC_VECTOR (width downto 0);
			IMDO: out STD_LOGIC_VECTOR (width downto 0)
			);
	end  component;        
	
	component  ROM_COSi is 						 
		generic(n: integer; --- FFT factor= 6,7,8,9,10,11
			wwdth: integer:=15;-- output word width =8...15  , cos>0
			wnd: integer);
		port  (	SELW:in STD_LOGIC_vector(1 downto 0);
			ADDRROM :in std_logic_vector(n-2 downto 0);
			COS : out std_logic_vector(wwdth-1 downto 0)
			);
	end component ;
	
	
	
	
	
	component CONTROLi is
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
			RESRAM:   out STD_LOGIC;   
			SIGNRE:	 out STD_LOGIC;	 
			INITOVERF:   out STD_LOGIC;   
			SEL: out STD_LOGIC;	  -- 0 -fromDIRE,DIIM, 1 - DMRE,DMIM 
			SELW: out STD_LOGIC_vector(1 downto 0);	  --0 -twiddle 1 - window  
			MODE: out STD_LOGIC_VECTOR (1 downto 0); 
			EXP: out STD_LOGIC_VECTOR (3 downto 0);
			ADDRR: out STD_LOGIC_VECTOR (n  downto 0);  
			ADDRWM: out STD_LOGIC_VECTOR (n downto 0) ;
			ADDRRES: out STD_LOGIC_VECTOR (n - 1 downto 0);    
			ADDRROM :out STD_LOGIC_VECTOR(n- 2 downto 0)
			);
	end component ;   
	component  RAM1X_2 is	
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
			SEL: in STD_LOGIC;				-- 0 -fromDIRE,DIIM, 1 - DMRE,DMIM
			RESRAM:  in STD_LOGIC;   
			DIRE: in STD_LOGIC_VECTOR (width-1 downto 0);
			DIIM: in STD_LOGIC_VECTOR (width-1 downto 0);
			DMRE: in STD_LOGIC_VECTOR (width-1 downto 0);
			DMIM: in STD_LOGIC_VECTOR (width-1 downto 0);  
			OVERF:out  STD_LOGIC;
			DORE: out STD_LOGIC_VECTOR (width-1 downto 0);
			DOIM: out STD_LOGIC_VECTOR (width-1 downto 0)
			);
	end	 component;
	
	--constant zeros: STD_LOGIC_VECTOR (owidth-iwidth-1 downto 0):=(others=>'0');
	signal 	ODDC:	STD_LOGIC;      --Odd cycle
	signal	DIV2:  STD_LOGIC;             --Scaling factor
	signal		ZWR: STD_LOGIC;	
	signal		ZWI:  STD_LOGIC;	  
	signal		SIGNRE:	 STD_LOGIC;	
	signal		REDI:  STD_LOGIC_VECTOR (width-1 downto 0);
	signal		IMDI:  STD_LOGIC_VECTOR (width-1 downto 0);	  
	signal		WF:  STD_LOGIC_VECTOR (wwidth-2 downto 0);
	signal		REDO: STD_LOGIC_VECTOR (width-1 downto 0);
	signal		IMDO:  STD_LOGIC_VECTOR (width-1 downto 0);
	signal      OVERF: STD_LOGIC;       
	signal  	INITOVERF:     STD_LOGIC;    
	signal		WEI: STD_LOGIC;
	signal		WEM: STD_LOGIC;            
	signal		SEL:  STD_LOGIC;	  -- 0 -fromDIRE,DIIM, 1 - DMRE,DMIM 
	signal     SELW:STD_LOGIC_vector(1 downto 0);
	signal		EVEN:  STD_LOGIC;			 --0- 0th bank 1- 1st bank -for DIRE,DIIM
	signal		ADDRW: STD_LOGIC_VECTOR (n - 1 downto 0);  
	signal		ADDRR:  STD_LOGIC_VECTOR (n  downto 0);  
	signal		ADDRWM: STD_LOGIC_VECTOR (n  downto 0) ;
	signal		ADDRROM : STD_LOGIC_VECTOR(n- 2 downto 0);
	signal	    MODE: STD_LOGIC_VECTOR (1 downto 0); 
	signal	  sn11,sn12:integer;
	signal 			RESRAM:  STD_LOGIC;   

	
	signal DIRE,DIIM:    STD_LOGIC_VECTOR (width-1 downto 0);
begin                     
	
	DIRE<=DATAIRE;-- & zeros;
	DIIM<=DATAIIM;-- & zeros;
	
	
	U_PATH:  FFTDPATHI 	
	generic	map(width=>width-1,		--  word width =7...15
		wwdth=>wwidth-1,  			--  coefficient width =7...15  
		reall=>reall,
		V2=>v2
		)
	port map(
		CLK=>  CLK,
		RST=> RST, 
		CE=>  CE,
		MODE=>mode,
		ODDC=>ODDC,	    --Odd cycle
		DIV2=>    DIV2,           --Scaling factor
		ZWR=>  ZWR,	
		ZWI=>  	 ZWI, 
		SIGNRE=>SIGNRE,  	
		REDI=>REDI,
		IMDI=> IMDI,	  
		WF=> WF,
		REDO=>REDO,
		IMDO=>IMDO
		);              
	
	U_ROM:ROM_COSi  						 
	generic map(n=>n, --- FFT factor= 6,7,8,9,10,11
		wwdth=>wwidth-1, -- output word width =8...15  , cos>0
		wnd=>1 --okno blackmana
		)
	port map (	 
		SELW=>selw,
		ADDRROM =>ADDRROM,
		COS =>WF);  
	
	
	--	CNTR_SLIP2: if slip=2 generate	
	U_CNTRL: CONTROLi
	generic	map(n=>n ,                   -- 6,7,8,9,10,11
		reall=>reall
		)
	port map(
		CLK=>CLK ,
		RST=> RST,
		CE=>CE ,
		filter=>filter,		--0 -ne filtruet 1 - filtruet 2-+diff 3 +2diff
		L1=>L1,		 -- tsastoty filtrow
		H1=>H1,
		L2=>L2,
		H2=>H2,
		START=>START ,
		DATAE=> DATAE,
		OVERF=> OVERF,  
		FFTRDY=>	FFTRDY,
		READY=> READY,
		--	WEI=> WEI,
		WEM=> WEM,
		RESRAM=>RESRAM,   
		INITOVERF=>INITOVERF,
		WERES=>WERES,  
		SEL=>SEL ,	-- 0 -fromDIRE,DIIM, 1 - DMRE,DMIM 
		ODDC=>ODDC,	
		MODE=>mode,
		EVEN=> EVEN,			 --0- 0th bank 1- 1st bank -for DIRE,DIIM
		DIV2=> DIV2, 
		ZWR=> ZWR,	
		ZWI=> ZWI,
		SELW=>selw,
		SIGNRE=>SIGNRE ,	 
		EXP=>EXP,
		ADDRR=> ADDRR,  
		ADDRWM=> ADDRWM,
		ADDRRES=>ADDRRES,    
		ADDRROM =>ADDRROM
		);                                                  
	
	U_RAM:   RAM1X_2	
	generic map(
		width =>width,
		n=>n		  -- 6,7,8,9,10,11
		,v2=>v2
		)  
	port map(
		CLK=>CLK ,
		RST=> RST,    
		CE=> CE,
		WE=> WEM,          -- for input data
		ADDRW=> ADDRWM,  
		ADDRR=> ADDRR,
		SEL=>SEL,
		DIRE=>DIRE,
		RESRAM=>RESRAM,   
		DIIM=> DIIM,
		DMRE=> REDO,
		DMIM=> IMDO,   
		OVERF=> OVERF ,
		INITOVERF=>INITOVERF,
		DORE=>REDI,
		DOIM=> IMDI
		);
	
	
	
	DATAORE<=REDO ;
	DATAOIM<=IMDO ;	 
	
	sn11<=conv_integer(signed(redo));--when addrres(n-1)='0' else 0;	
	sn12<=conv_integer(signed(imdo));	
	
	
end ALFFT_CoreS;
