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
-- Description :  FIFO delay
---------------------------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
--pragma translate_off   
use IEEE.VITAL_Timing.all; 
library UNISIM;
use UNISIM.VPKG.all; 
--pragma translate_on  

entity DELAY is
	generic(nn:natural:=16;--data width
		l:natural:=8); --FIFO length
	port(
		CLK : in STD_LOGIC;
		RST : in STD_LOGIC;	  	 
		SE: in STD_LOGIC;							--shift enable
		D : in STD_LOGIC_VECTOR(15 downto 0);	--Data in
		Q : out STD_LOGIC_VECTOR(15 downto 0)	--Data out
		);
end DELAY;


architecture SRL_E of DELAY is	 	
	
	component srl16e
		port(
			D : in std_ulogic;
			CLK : in std_ulogic;  
			CE : in std_ulogic;
			A0 : in std_ulogic;
			A1 : in std_ulogic;
			A2 : in std_ulogic;
			A3 : in std_ulogic;
			Q : out std_ulogic);
	end component;	
	constant len:std_logic_vector:=CONV_STD_LOGIC_VECTOR(l-1,6);
	constant a0:std_ulogic:=len(0);
	constant a1:std_ulogic:=len(1);
	constant a2:std_ulogic:=len(2);
	constant a3:std_ulogic:=len(3);
	constant a4:std_ulogic:=len(4);  
	constant a5:std_ulogic:=len(5);
	constant one:std_ulogic:='1';
	signal di1,di2,di3:std_logic_vector(nn-1 downto 0);
	
begin
	
	D16:if (a5 or a4)='0' generate	
		DEL0:for i in 0 to 15 generate
			U_SRL:srl16e port map( D=> D(i),CLK=>CLK,CE=>SE,
				A0=>a0,A1=>a1,A2=>a2,A3=>a3,Q=>Q(i));
		end generate;	  	   
	end generate;
	
	D32:if a5='0' and a4='1' generate	
		DEL1:for i in 0 to 15 generate
			U_SRL0:srl16e port map( D=> D(i),CLK=>CLK,CE=>SE,
			     A0=>one,A1=>one,A2=>one,A3=>one,Q=>di1(i)); 
			U_SRL1:srl16e port map( D=> di1(i),CLK=>CLK,CE=>SE,
			A0=>a0,A1=>a1,A2=>a2,A3=>a3,Q=>Q(i)); 
		end generate;
	end generate;
	D48:if a5='1' and a4='0' generate	
		DEL1:for i in 0 to 15 generate
			U_SRL0:srl16e port map( D=> D(i),CLK=>CLK,CE=>SE,
			     A0=>one,A1=>one,A2=>one,A3=>one,Q=>di1(i)); 
			U_SRL1:srl16e port map( D=> di1(i),CLK=>CLK,CE=>SE,
			     A0=>one,A1=>one,A2=>one,A3=>one,Q=>di2(i)); 
			U_SRL2:srl16e port map( D=> di2(i),CLK=>CLK,CE=>SE,
			A0=>a0,A1=>a1,A2=>a2,A3=>a3,Q=>Q(i)); 
		end generate;
	end generate;
	D64:if a5='1' and a4='1' generate	
		DEL1:for i in 0 to 15 generate
			U_SRL0:srl16e port map( D=> D(i),CLK=>CLK,CE=>SE,
			     A0=>one,A1=>one,A2=>one,A3=>one,Q=>di1(i)); 
			U_SRL1:srl16e port map( D=> di1(i),CLK=>CLK,CE=>SE,
			     A0=>one,A1=>one,A2=>one,A3=>one,Q=>di2(i)); 
			U_SRL2:srl16e port map( D=> di2(i),CLK=>CLK,CE=>SE,
			     A0=>one,A1=>one,A2=>one,A3=>one,Q=>di3(i)); 
			U_SRL3:srl16e port map( D=> di3(i),CLK=>CLK,CE=>SE,
			A0=>a0,A1=>a1,A2=>a2,A3=>a3,Q=>Q(i)); 
		end generate;
	end generate;
	
end SRL_E;
