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
--	FUNCTION	 FFT filter for FFT length of
--                       N= 64, 128, 256, 512, 1024, 2048 points,
--                       N= 2**n,
--                       ifft=0 forward FFT, =1 inverse FFT
--                       rams=1 - single data RAM, =2 dual data RAM
--                       input data width: iwidth = 8,...,16 bit   signed 
--      				       output   data width: owidth = 8,...,16 bit   signed     
--                       coefficient width : wwidth = 8,...,16 bit
--			            Synthesable for Virtex2, Spartan3 FPGAs. 
--             
--	FILES:		FFT_Filtr2.VHD -- this file
--             ALFFT_Core_slip.vhd - Slipping FFT with windowing
--               FFTDPATH.vhd   - data path of the FFT butterfly       		 
--               CONTROL.vhd   - control unit of FFT processor       
--				      ROM_COS.vhd   -	coefficient ROM
--				     RAM2X_2.vhd   -  dual data RAM block            
--              ALFFT_Core_sli.vhd - file of IFFT processor
--               FFTDPATHi.vhd   - data path of the IFFT butterfly       		 
--               CONTROL_i.vhd   - control unit of IFFT processor      
--				      ROM_COSi.vhd   -	coefficient ROM
--				     RAM1X_2.vhd   - data RAM block    
--             DENORM.vhd  -- denormalizer unit
--                  When redesign data RAM blocks
--                     the Core will fit another FPGA families
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~--

library IEEE;
use IEEE.std_logic_1164.all; 
Use	IEEE.std_logic_arith.all; 

entity FFT_FILTER2 is          
	generic	(
		iwidth: INTEGER:=8 	;		--  input data width =8...16
		owidth: INTEGER:=8 	;   	-- output data width =8...16
		wwidth: INTEGER:=8;  			--  coefficient width =8...16  
		n:INTEGER:=7 ;			-- 6,7,8,9,10,11   - transform length factor
		v2:INTEGER:=1 ; -- 1 - Virtex2
		reall:INTEGER:= 1  --wch. mass: 0 -complex 1 - 2 realnych
		);  
	port (
		CLK: in STD_LOGIC;
		RST: in STD_LOGIC;
		CE: in STD_LOGIC;	  -- выбор кристалла (разрешение СLK)
		START: in STD_LOGIC; -- импульс начального пуска
		DATAE: in STD_LOGIC; -- строб входных данных
		FILTER: in STD_LOGIC_VECTOR (1 downto 0);		--0 -ne filtruet 1 - filtruet 2-+diff 3 +2diff
		L1:in STD_LOGIC_VECTOR (n-1 downto 0); -- граница ФНЧ1
		H1:in STD_LOGIC_VECTOR (n-1 downto 0); -- граница ФВЧ1
		L2:in STD_LOGIC_VECTOR (n-1 downto 0); -- граница ФНЧ2
		H2:in STD_LOGIC_VECTOR (n-1 downto 0); -- граница ФВЧ2
		
		DATAIRE: in STD_LOGIC_VECTOR (iwidth-1 downto 0);--вход 1 фильтра
		DATAIIM: in STD_LOGIC_VECTOR (iwidth-1 downto 0);--вход 2 фильтра
		READY: out STD_LOGIC;		   --импульс начала вывода массива результата 
		DATAORE: out STD_LOGIC_VECTOR (owidth-1 downto 0);--выход 1 фильтра
		DATAOIM: out STD_LOGIC_VECTOR (owidth-1 downto 0);--выход 2 фильтра
		
		SPRDY: out STD_LOGIC;		--импульс начала вывода спектра
		WESP: out STD_LOGIC;	   -- строб отсчетов спектра
		SPRE: out STD_LOGIC_VECTOR (owidth-1 downto 0);--реальная часть спектров
		SPIM: out STD_LOGIC_VECTOR (owidth-1 downto 0);--мнимая часть спектров
		FREQ:out STD_LOGIC_VECTOR (n-1 downto 0); --номер бина
		SPEXP:out STD_LOGIC_VECTOR (3 downto 0)	  --порядок массива спектров
		);
end FFT_FILTER2;

architecture ALFFT_CoreS of FFT_Filter2 is      
	
	component  ALFFT_Core is          
		generic	(	ifft: INTEGER:=0;	    --  0- forward FFT
			rams:INTEGER:=2;   -- 1,2
			iwidth: INTEGER:=8 	;		--  input data width =8...16
			owidth: INTEGER:=8 	;   	-- output data width =8...16
			wwidth: INTEGER:=8;  			--  coefficient width =8...16  
			n:INTEGER:=7 ;
			v2:INTEGER:=1 ; -- 1 - Virtex2
			slip:INTEGER:= 2; -- 2 -- skolzassij s perekrytiem 2 
			wnd:INTEGER:= 1 ; -- umnozaecca na okno 1 ,0 -bez umnozenija
			reall:INTEGER:= 0  --wch. mass: 0 -complex 1 - 2 realnych
			);  --4,5, 6,7,8,9,10,11   - transform length factor
		port (
			CLK: in STD_LOGIC;
			RST: in STD_LOGIC;
			CE: in STD_LOGIC;
			START: in STD_LOGIC;
			DATAE: in STD_LOGIC;
			DATAIRE: in STD_LOGIC_VECTOR (iwidth-1 downto 0);
			DATAIIM: in STD_LOGIC_VECTOR (iwidth-1 downto 0);
			FFTRDY: out STD_LOGIC;
			READY: out STD_LOGIC;
			WERES: out STD_LOGIC;    
			ADDRRES: out STD_LOGIC_VECTOR (n-1 downto 0);    
			DATAORE: out STD_LOGIC_VECTOR (owidth-1 downto 0);
			DATAOIM: out STD_LOGIC_VECTOR (owidth-1 downto 0);
			EXP: out STD_LOGIC_VECTOR (3 downto 0)	
			);
	end component;        
	
	component ALFFT_Corei is          
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
	end component ;
	component DENORM is	
		generic	(width: integer :=8	;	--  word width =8...24
			n:INTEGER:=7 ;
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
	end	component;
	
	signal		REDI:  STD_LOGIC_VECTOR (owidth-1 downto 0);
	signal		IMDI:  STD_LOGIC_VECTOR (owidth-1 downto 0);	  
	signal		REDO: STD_LOGIC_VECTOR (owidth-1 downto 0);
	signal		IMDO:  STD_LOGIC_VECTOR (owidth-1 downto 0);
	signal  	INITOVERF:     STD_LOGIC;    
	signal		WEspi:  STD_LOGIC;
	signal		sprdyi: STD_LOGIC;
	signal		WEres: STD_LOGIC;            
	signal		fftrdy,ifftrdy:  STD_LOGIC;									  -- 0 -fromDIRE,DIIM, 1 - DMRE,DMIM 
	signal		EVEN:  STD_LOGIC;			 --0- 0th bank 1- 1st bank -for DIRE,DIIM
	signal		ADDRW: STD_LOGIC_VECTOR (n - 1 downto 0);  
	signal	    MODE: STD_LOGIC_VECTOR (1 downto 0); 
	signal	   SPREi,SPIMi,DRE,DIM:STD_LOGIC_VECTOR (owidth-1 downto 0);
	signal    EXPF,EXPI:STD_LOGIC_VECTOR (3 downto 0);
	signal	   addrres,address: STD_LOGIC_VECTOR (n-1 downto 0); 
	signal DIRE,DIIM:    STD_LOGIC_VECTOR (iwidth-1 downto 0);
	constant vcc:STD_LOGIC:='1';  
	signal sno1,sno2,sno3:integer;
	
begin                     
	
	DIRE<=DATAIRE;-- & zeros;
	DIIM<=DATAIIM;-- & zeros;
	
	FFT_F:	 ALFFT_Core   
	generic map	(ifft=>0,	    --  0- forward FFT
		rams=>2,   -- 1,2
		iwidth=>iwidth,		--  input data width =8...16
		owidth=>owidth,   	-- output data width =8...16
		wwidth=>wwidth,  			--  coefficient width =8...16  
		n=>n,
		v2=>v2, -- 1 - Virtex2
		slip=> 2, -- 2 -- skolzassij s perekrytiem 2 
		wnd=> 1, -- umnozaecca na okno 1 ,0 -bez umnozenija
		reall=>reall  --wch. mass: 0 -complex 1 - 2 realnych
		)  --4,5, 6,7,8,9,10,11   - transform length factor
	port map (CLK,RST,CE,
		START=>START,
		DATAE=>DATAE,
		DATAIRE=>DIRE,
		DATAIIM=>DIIM,
		FFTRDY=>fftrdy,
		READY=>sprdyi,
		WERES=>wespi,    
		ADDRRES=>address,   
		DATAORE=>SPREi,
		DATAOIM=>SPIMi,
		EXP=>expf
		);	
		
		
		WESP<=wespi;	 -- spectr data output 
		SPRDY<=sprdyi;
		SPRE<=SPREi;
		SPIM<=SPIMi;
		SPEXP<=expf;
		FREQ<=address;
	
	FFT_I:	 ALFFT_Corei 
	generic map	(width=>owidth,   	-- output data width =8...16
		wwidth=>wwidth,  			--  coefficient width =8...16  
		n=>n,
		v2=>v2, -- 1 - Virtex2
		reall=>reall  --wch. mass: 0 -complex 1 - 2 realnych
		)  --4,5, 6,7,8,9,10,11   - transform length factor
	port map(CLK,RST,CE, 
		START=>sprdyi,
		FILTER=>FILTER,		--0 -ne filtruet 1 - filtruet 2-+diff 3 +2diff
		L1=>L1,		 -- tsastoty filtrow
		H1=>H1,		 -- tsastoty filtrow
		L2=>L2,
		H2=>H2,
		DATAE=>wespi,
		DATAIRE=>SPREi,
		DATAIIM=>SPIMi,
		FFTRDY=>open,
		READY=>ifftrdy,
		WERES=>weres,    
		ADDRRES=>addrres,   
		DATAORE=>DRE,
		DATAOIM=>DIM,
		EXP=>EXPi	
		);
	
	
	U_OUT: DENORM	
	generic	 map(width=>owidth,	--  word width =8...24
		n=>n,	 
		reall=>reall,
		v2=>v2)
	port map(CLK,RST,CE,	 
		DATAE=>DATAE,
		START=>start,
		INIT=> ifftrdy,
		WERES=>weres,    
		ADDRRES=>addrres,
		SPRDY=>SPRDYi,
		EXPI=>expi,	
		EXPF=>expf,	
		REDI=>DRE,
		IMDI=>DIM,	  
		RDY=>READY,	
		REDO=>REDO,
		IMDO=>IMDO
		);
	
	DATAORE<=REDO ;
	DATAOIM<=IMDO ;
	
	
end ALFFT_CoreS;
