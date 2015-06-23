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
--                       ifft=0 forward FFT,
--                       rams=1 - single data RAM, =2 dual data RAM
--                       input data width: iwidth = 8,...,16 bit   signed 
--      				       output   data width: owidth = 8,...,16 bit   signed     
--                       coefficient width : wwidth = 8,...,16 bit
--			            Synthesable for Virtex, SpartanII FPGAs. 
--              Slipping transform	with windowing
--	FILES:		 ALFFT_Core_slip.vhd -this file
--               FFTDPATH.vhd   - data path of the FFT butterfly       		 
--               CONTROL.vhd   - control unit       
--				      ROM_COS.vhd   -	coefficient ROM
--				     RAM2X_2.vhd   -  dual data RAM block                  
--                  When redesign data RAM blocks
--                     the Core will fit another FPGA families
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~--

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;

entity ALFFT_Core is          
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
end ALFFT_Core;

architecture ALFFT_CoreS of ALFFT_Core is      
	
	component  FFTDPATH is	
		generic	(	ifft: integer:=0;	
			width: integer :=8 	;		--  word width =8...16
			wwdth: integer:=7;  			--  coefficient width =7...15  
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
	
	component  ROM_COS is 						 
		generic(n: integer; --- FFT factor= 6,7,8,9,10,11
			wwdth: integer:=15;-- output word width =8...15  , cos>0
			wnd: integer);
		port  (	SELW:in STD_LOGIC;
			ADDRROM :in std_logic_vector(n-2 downto 0);
			COS : out std_logic_vector(wwdth-1 downto 0)
			);
	end component ;
	
	
	
	component RAM2X is	
		generic( 	iwidth : INTEGER;   
			width : INTEGER;
			n:INTEGER);  -- 6,7,8,9,10,11
		port (
			CLK: in STD_LOGIC;
			RST: in STD_LOGIC;    
			CE: in STD_LOGIC;
			WEI: in STD_LOGIC;          -- for input data
			WEM: in STD_LOGIC;        -- for intermediate data
			INITOVERF:    in STD_LOGIC;    
			ADDRWIN: in STD_LOGIC_VECTOR (n - 1 downto 0);  
			ADDRWM: in STD_LOGIC_VECTOR (n - 1 downto 0);  
			ADDRR: in STD_LOGIC_VECTOR (n - 1 downto 0);  
			EVEN: in STD_LOGIC;			 --0- 0th bank 1- 1st bank -for DIRE,DIIM
			DIRE: in STD_LOGIC_VECTOR (iwidth-1 downto 0);
			DIIM: in STD_LOGIC_VECTOR (iwidth-1 downto 0);
			DMRE: in STD_LOGIC_VECTOR (width-1 downto 0);
			DMIM: in STD_LOGIC_VECTOR (width-1 downto 0);   
			OVERF:out  STD_LOGIC;
			DORE: out STD_LOGIC_VECTOR (width-1 downto 0);
			DOIM: out STD_LOGIC_VECTOR (width-1 downto 0)
			);
	end component ;          
	component RAM2X2 is	
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
			INITOVERF:   in STD_LOGIC;     
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
	end component;	 
	
	component CONTROL is
		generic	(	ifft:INTEGER;--:=0;	   
			rams:INTEGER;--:=1;
			n:INTEGER;  -- 6,7,8,9,10,11
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
			SEL: out STD_LOGIC;									  -- 0 -fromDIRE,DIIM, 1 - DMRE,DMIM 
			ODDC:	  out STD_LOGIC;
			EVEN: out STD_LOGIC;			 --0- 0th bank 1- 1st bank -for DIRE,DIIM
			DIV2: out STD_LOGIC; 
			ZWR: out STD_LOGIC;	
			ZWI: out STD_LOGIC;	  
			SIGNRE:	 out STD_LOGIC;	 
			INITOVERF:   out STD_LOGIC;   
			SELW: out STD_LOGIC;	  --0 -twiddle 1 - window  
			MODE: out STD_LOGIC_VECTOR (1 downto 0); 
			EXP: out STD_LOGIC_VECTOR (3 downto 0);
			ADDRW: out STD_LOGIC_VECTOR (n - 1 downto 0);  
			ADDRR: out STD_LOGIC_VECTOR (n - 1 downto 0);  
			ADDRWIN: out STD_LOGIC_VECTOR (n - 1 downto 0);
			ADDRWM: out STD_LOGIC_VECTOR (n - 1 downto 0) ;
			ADDRRES: out STD_LOGIC_VECTOR (n - 1 downto 0);    
			ADDRROM :out STD_LOGIC_VECTOR(n- 2 downto 0)
			);
	end component ;        
	
	--constant zeros: STD_LOGIC_VECTOR (owidth-iwidth-1 downto 0):=(others=>'0');
	signal 	ODDC:	STD_LOGIC;      --Odd cycle
	signal	DIV2:  STD_LOGIC;             --Scaling factor
	signal		ZWR: STD_LOGIC;	
	signal		ZWI:  STD_LOGIC;	  
	signal		SIGNRE:	 STD_LOGIC;	
	signal		REDI:  STD_LOGIC_VECTOR (owidth-1 downto 0);
	signal		IMDI:  STD_LOGIC_VECTOR (owidth-1 downto 0);	  
	signal		WF:  STD_LOGIC_VECTOR (wwidth-2 downto 0);
	signal		REDO: STD_LOGIC_VECTOR (owidth-1 downto 0);
	signal		IMDO:  STD_LOGIC_VECTOR (owidth-1 downto 0);
	signal      OVERF: STD_LOGIC;       
	signal  	INITOVERF:     STD_LOGIC;    
	signal		WE:  STD_LOGIC;
	signal		WEI: STD_LOGIC;
	signal		WEM: STD_LOGIC;            
	signal		SEL,SELW:  STD_LOGIC;									  -- 0 -fromDIRE,DIIM, 1 - DMRE,DMIM 
	signal		EVEN:  STD_LOGIC;			 --0- 0th bank 1- 1st bank -for DIRE,DIIM
	signal		ADDRW: STD_LOGIC_VECTOR (n - 1 downto 0);  
	signal		ADDRR:  STD_LOGIC_VECTOR (n - 1 downto 0);  
	signal		ADDRWIN: STD_LOGIC_VECTOR (n - 1 downto 0);
	signal		ADDRWM: STD_LOGIC_VECTOR (n - 1 downto 0) ;
	signal		ADDRROM : STD_LOGIC_VECTOR(n- 2 downto 0);
	signal	    MODE: STD_LOGIC_VECTOR (1 downto 0); 
	signal DIRE,DIIM:    STD_LOGIC_VECTOR (iwidth-1 downto 0);
	signal	  sn01,sn02:integer;
	
begin                     
	
	DIRE<=DATAIRE;-- & zeros;
	DIIM<=DATAIIM;-- & zeros;
	
	
	U_PATH:  FFTDPATH 	
	generic	map(	ifft=>ifft,	
		width=>owidth-1,		--  word width =7...15
		wwdth=>wwidth-1,  			--  coefficient width =7...15  
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
	
	
	U_ROM:ROM_COS  						 
	generic map(n=>n, --- FFT factor= 6,7,8,9,10,11
		wwdth=>wwidth-1, -- output word width =8...15  , cos>0
		wnd=>wnd)
	port map (	 
		SELW=>selw,
		ADDRROM =>ADDRROM,
		COS =>WF);  
	
	--	CNTRL_SLIP0:if slip=0 generate	
	--		U_CNTRL:entity CONTROL(CONTROL) 
	--		generic	map(	ifft=>ifft,   
	--			rams=>rams,
	--			n=>n ,                   -- 6,7,8,9,10,11
	--			slip=>slip
	--			)
	--		port map(
	--			CLK=>CLK ,
	--			RST=> RST,
	--			CE=>CE ,	  
	--			START=>START ,
	--			DATAE=> DATAE,
	--			OVERF=> OVERF,  
	--			FFTRDY=>	FFTRDY,
	--			READY=> READY,
	--			WE=> WE,
	--			WEI=> WEI,
	--			WEM=> WEM, 
	--			INITOVERF=>INITOVERF,
	--			WERES=>WERES,  
	--			SEL=>SEL ,									  -- 0 -fromDIRE,DIIM, 1 - DMRE,DMIM 
	--			ODDC=>ODDC,
	--			EVEN=> EVEN,			 --0- 0th bank 1- 1st bank -for DIRE,DIIM
	--			DIV2=> DIV2, 
	--			ZWR=> ZWR,	
	--			ZWI=> ZWI,	  
	--			SIGNRE=>SIGNRE ,	 
	--			EXP=>EXP,
	--			ADDRW=> ADDRW,  
	--			ADDRR=> ADDRR,  
	--			ADDRWIN=>ADDRWIN,
	--			ADDRWM=> ADDRWM,
	--			ADDRRES=>ADDRRES,    
	--			ADDRROM =>ADDRROM
	--			);                                                  
	--	end generate;	
	
	--	CNTR_SLIP2: if slip=2 generate	
	U_CNTRL:entity CONTROL(CONTROL_SLIP) 
	generic	map(	ifft=>ifft,   
		rams=>rams,
		n=>n ,                   -- 6,7,8,9,10,11
		slip=>slip,
		reall=>reall
		)
	port map(
		CLK=>CLK ,
		RST=> RST,
		CE=>CE ,	  
		START=>START ,
		DATAE=> DATAE,
		OVERF=> OVERF,  
		FFTRDY=>	FFTRDY,
		READY=> READY,
		WE=> WE,
		WEI=> WEI,
		WEM=> WEM, 
		INITOVERF=>INITOVERF,
		WERES=>WERES,  
		--	SEL=>SEL ,	-- 0 -fromDIRE,DIIM, 1 - DMRE,DMIM 
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
		ADDRWIN=>ADDRWIN,
		ADDRWM=> ADDRWM,
		ADDRRES=>ADDRRES,    
		ADDRROM =>ADDRROM
		);                                                  
	--	end generate;
	
	--	RAM2: if rams=2 and slip=0 generate
	--		U_RAM:   RAM2X 	
	--		generic map( iwidth=>iwidth, 
	--			width =>owidth,
	--			n=>n		  -- 6,7,8,9,10,11
	--			--		,v2=>v2
	--			)  
	--		port map(
	--			CLK=>CLK ,
	--			RST=> RST,    
	--			CE=> CE,
	--			WEI=> WEI,          -- for input data
	--			WEM=> WEM,        -- for intermediate data
	--			ADDRWIN=> ADDRWIN,  
	--			ADDRWM=> ADDRWM,  
	--			ADDRR=> ADDRR,  
	--			EVEN=>EVEN ,			 --0- 0th bank 1- 1st bank -for DIRE,DIIM
	--			DIRE=>DIRE,
	--			DIIM=> DIIM,
	--			DMRE=> REDO,
	--			DMIM=> IMDO,   
	--			OVERF=> OVERF ,
	--			INITOVERF=>INITOVERF,
	--			DORE=>REDI,
	--			DOIM=> IMDI
	--			);
	--		
	--	end generate;      
	
	RAM2s: if rams=2 and slip=2 generate
		U_RAM:   RAM2X2 	
		generic map( iwidth=>iwidth, 
			width =>owidth,
			n=>n		  -- 6,7,8,9,10,11
			,v2=>v2
			)  
		port map(
			CLK=>CLK ,
			RST=> RST,    
			CE=> CE,
			WEI=> WEI,          -- for input data
			WEM=> WEM,        -- for intermediate data
			ADDRWIN=> ADDRWIN,  
			ADDRWM=> ADDRWM,  
			ADDRR=> ADDRR,  
			EVEN=>EVEN ,			 --0- 0th bank (Input) 1- 1st bank -for DIRE,DIIM
			DIRE=>DIRE,
			DIIM=> DIIM,
			DMRE=> REDO,
			DMIM=> IMDO,   
			OVERF=> OVERF ,
			INITOVERF=>INITOVERF,
			DORE=>REDI,
			DOIM=> IMDI
			);
		
	end generate;      
	
	DATAORE<=REDO ;
	DATAOIM<=IMDO ;
	sn01<=conv_integer(signed(redo));	
	sn02<=conv_integer(signed(imdo));	
	
	
end ALFFT_CoreS;
