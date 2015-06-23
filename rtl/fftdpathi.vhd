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

-- AUTHORS	Volodymir Lepekha,		
--		Anatoli Sergyienko.
--HISTORY	:07.2005 mode added:
--           00 - multiply by window
--           01 - butterfly
--           10 - restore for real FFT	   
-- only for Virtex2 and later	
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~		



library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;	  

entity FFTDPATHI is	
	generic	(width: integer :=8 	;		--  word width =8...24
		Wwdth: integer:=7;  			--  coefficient width =7...15  
		reall:integer;
		V2:integer
		);
	port (
		CLK: in STD_LOGIC;
		RST: in STD_LOGIC;
		CE: in STD_LOGIC;	  
		ODDC: in STD_LOGIC;      --
		DIV2: in STD_LOGIC;             --Scaling factor
		ZWR: in STD_LOGIC;	
		ZWI: in STD_LOGIC;	  
		SIGNRE:	 in STD_LOGIC;	 
		MODE: in STD_LOGIC_VECTOR (1 downto 0);--00-umnozenie na okno, 01-FFT,10-wosstanowlenie 
		REDI: in STD_LOGIC_VECTOR (width downto 0);
		IMDI: in STD_LOGIC_VECTOR (width downto 0);	  
		WF: in STD_LOGIC_VECTOR (wwdth-1 downto 0);
		REDO: out STD_LOGIC_VECTOR (width downto 0);
		IMDO: out STD_LOGIC_VECTOR (width downto 0)
		);
end FFTDPATHI;


architecture FFTDPATH_s of FFTDPATHI is  	            
	
	constant zeros: STD_LOGIC_VECTOR (width-wwdth downto 0):=
	CONV_STD_LOGIC_VECTOR(0,width-wwdth+1);
	signal  ar,ai,ar3,ai3:	  STD_LOGIC_VECTOR (width-1 downto 0);
	signal  br1,bi1,br,bi,br2,bi2:	  STD_LOGIC_VECTOR (width-1 downto 0);
	signal renorm,imnorm,br4,bi4:	  STD_LOGIC_VECTOR (width-1 downto 0);
	signal ard,aid:	  STD_LOGIC_VECTOR (3 downto 0);
	signal wr,wr1:	  STD_LOGIC_VECTOR (wwdth-1 downto 0);	   
	signal prodrb,prodib: STD_LOGIC_VECTOR (width+wwdth downto 0);
	signal prodr1,prodi1: STD_LOGIC_VECTOR (width+wwdth-2 downto wwdth-2);
	signal prodr2,prodi2: STD_LOGIC_VECTOR (width+wwdth-1 downto wwdth-2);
	signal prodr,prodi,prodrd,prodid: STD_LOGIC_VECTOR (width downto 0);
	signal cr,ci:	  STD_LOGIC_VECTOR (width downto 0);
	signal dr,di:	  STD_LOGIC_VECTOR (width+2 downto 0);	 
	signal zwri,zwii,zwr1,zwi1,zwr2,zwi2,signrei,signre1,signre2: STD_LOGIC;
	
	
begin				   
	
	SHIFT:process(REDI,IMDI,DIV2)
	begin					  
		if DIV2='1' then
			renorm <=  REDI (width downto 1);
			imnorm <= IMDI (width downto 1);
		else
			renorm <= REDI(width-1 downto 0);
			imnorm <= IMDI(width-1 downto 0);
		end if;	   
	end process;
	
	RDELAY:process(CLK,RST)
	begin 
		if RST = '1' then
			wr <= (others =>'0'); 	  
			wr1 <= (others =>'0'); 	  
			ar <= (others =>'0'); 	 
			br <= (others =>'0'); 	 
			br1<= (others =>'0'); 	
			br2 <= (others =>'0'); 	 
			ar3 <= (others =>'0'); 	 
			br4 <= (others =>'0'); 	 
			ai <= (others =>'0'); 	
			bi <= (others =>'0'); 	 
			bi1<= (others =>'0'); 	
			bi2 <= (others =>'0'); 	 
			ai3 <= (others =>'0'); 	 
			bi4 <= (others =>'0'); 	 
		elsif CLK = '1' and CLK'event then	    	
			if CE = '1' then		 
				wr<=WF;		
				wr1<=wr;
				br2<=br1;
				bi2<=bi1;
				if ODDC='0' or mode="00" or mode="11" then
					ar<= renorm;  
					ar3<=ar;  
					br4<=br2;
					ai<= imnorm;  
					ai3<=ai;
					bi4<=bi2;	
				else
					br<= renorm; 
					br1<=br;
					bi<= imnorm;
					bi1<=bi;
				end if;
			end if;
		end if;
	end process;	 
	
	TTDELAY:process(CLK,RST)
	begin
		if RST='1' then
			zwri<='0';
			zwii<='0';
			zwr1<='0';
			zwi1<='0';
			zwr2<='0';
			zwi2<='0';
			signrei<='0';
			signre1<='0';
			signre2<='0'; 
		elsif CLK='1' and CLK'event then  
			if CE='1' then
				zwri<=ZWR;
				zwii<=ZWI;
				zwr1<=zwri;
				zwi1<=zwii;
				zwr2<=zwr1;
				zwi2<=zwi1;
				signrei<=SIGNRE;
				signre1<=signrei;
				signre2<=signre1; 	   
			end if;
		end if;
	end process;
	
	
	
	
	
	BLCK:if v2=1 generate	
		MPU_U:	process(CLK,RST)		
			variable prodr,prodi:STD_LOGIC_VECTOR(width+wwdth-2 downto 0);
			variable minusre,minusim:STD_LOGIC;
		begin
			if RST = '1' then
				prodrb <= (others =>'0'); 
				prodr2 <= (others =>'0'); 
				prodib <= (others =>'0'); 
				prodi2 <= (others =>'0'); 
				
			elsif CLK = '1' and CLK'event then	    	
				if CE = '1' then		  
					prodrb <= signed('0'& wr) * signed(ar);        
					prodib <= signed('0'& wr) * signed(ai);     
					
					prodr2<=prodrb(width+wwdth-1 downto wwdth-2);
					prodi2<=prodib(width+wwdth-1 downto wwdth-2);
				end if;				 
			end if;
		end process; 
	end generate;
	
	prodr<=prodr2( width+wwdth-1 downto wwdth-1);
	prodi<=prodi2( width+wwdth-1 downto wwdth-1);
	
	RPRODD: process(CLK,RST)
	begin
		
		if RST='1' then
			prodrd<=(others=>'0');
			prodid<=(others=>'0');
		elsif CLK='1' and CLK'event then
			if CE ='1' then
				if signre1='1' then
					prodrd<= - signed(prodr);		 
					prodid<= - signed(prodi);	
				else	 
					prodrd<=prodr;
					prodid<=prodi;
				end if;
			end if;
		end if;
	end process;	
	
	ACPROD:process(RST,CLK)
	begin			 
		if RST='1' then
			cr<=(others=>'0');
			ci<=(others=>'0');
		elsif CLK='1' and CLK'event then
			if CE ='1' and ODDC='0' then
				if zwi2='1' then
					cr <= ar3&'0';
					ci <= ai3&'0';
				elsif zwr2='1' then
					cr <= 0- signed(ai3&'0');
					ci <= ar3&'0';
				else-- if signre2='1' then
					--							cr<= 0- signed(prodrd)-signed(prodi);
					--							ci<= 0- signed(prodid)+signed(prodr);
					--						else
					cr<=  signed(prodrd)-signed(prodi);
					ci<=  signed(prodid)+signed(prodr);
					--	end if;
				end if;
			end if;
		end if;
	end process;			
	
	ABUTTERF:process(CLK,RST)
	begin		  	   
		if RST='1' then
			dr<=(others=>'0');
			di<=(others=>'0');
		elsif CLK='1' and CLK'event then
			if CE ='1' then	  	 
				case MODE is
					when "00" => dr<=prodr&"01";
					di<=prodI&"01" ;  
					when "11" =>		 -- *jW
					if ODDC='0' and reall=0 then
						dr<=0-signed(prodi&"01");  --posle n/2
						di<=prodr&"01" ;
					else	 
						dr<=prodi&"01";
						di<=0-signed(prodr&"00") ; -- do n/2
					end if;
					when "01" => --butterfly
					if ODDC='1' then                              --addition with rounding
						dr<=signed(br4&"01")+signed( cr(width)&cr&'1');
						di<=signed(bi4&"01")+signed( ci(width)&ci&'1');	 
					else
						dr<=signed(br4&"01")-signed( cr(width)&cr&'1');
						di<=signed(bi4&"01")-signed( ci(width)&ci&'1');		
					end if;	   
					
					when others=>	-- Wosstanowlenie
					if ODDC='1' then                              --addition with rounding
						dr<=signed(br4&"01")-signed( ci(width)&ci&'1');
						di<=signed(bi4&"01")+signed( cr(width)&cr&'1');	 
					else
						dr<=signed(br4&"01")+signed( ci(width)&ci&'1');
						di<=signed( cr(width)&cr&'1')- signed(bi4&"01");
					end if;		
				end case ;
			end if;	   
		end if;
	end process;
	
	REDO<=  dr(width+2 downto 2) ;
	IMDO<=  di(width+2 downto 2);
	
	
end FFTDPATH_s;
