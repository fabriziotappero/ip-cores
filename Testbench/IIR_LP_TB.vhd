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

library ieee;
use ieee.std_logic_arith.all;
use ieee.std_logic_signed.all;
use ieee.std_logic_1164.all;
use IEEE.MATH_REAL.all;

entity wave2x5_tb is
end wave2x5_tb;

architecture TB_ARCHITECTURE of wave2x5_tb is
	-- Component declaration of the tested unit
	component lpf3x8
		port(
			CLK : in std_logic;
			RST : in std_logic;
			EF : in STD_LOGIC;	
			FREQ : in STD_LOGIC_VECTOR(11 downto 0);
			DI : in std_logic_vector(15 downto 0);
			DO : out std_logic_vector(15 downto 0) );
	end component;	  
	
	component FilterTB is                
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
	end component ;
	
	signal CLK : std_logic:='1';
	signal RST,ena,ef : std_logic;
	signal DI : std_logic_vector(15 downto 0);
	signal RNG : std_logic_vector(1 downto 0);
	signal Fre : std_logic_vector(7 downto 0);
	signal DO : std_logic_vector(15 downto 0);
	constant ze:std_logic_vector(15 downto 0):=(others=>'0');
	constant one:std_logic_vector(15 downto 0):=(15=>'0',14=>'0',others=>'1');
	signal rersp,imrsp,reo,imo,freq,magn:integer;	
	signal reov,rerspv,imov,imrspv:std_logic_vector(15 downto 0); 
	signal logmagn,phase,er:real;	  
	signal f:std_logic_vector(11 downto 0); 
	signal nn:natural;	 
	signal n1,n2,n3:natural;
begin  
	er<=sqrt((1.2*1.2+1.0+1.5*1.5+0.6*0.6+0.3*0.3)/5.0);
	rst<='1', '0' after 1 ns;
	CLK<=(not CLK) after 5 ns;	--and not rst
	DI<= ze, one after 10 ns, ze after 20 ns;	
	ef<= '0', '1' after 25 ns, '0' after 55 ns;
	f<=X"a00"; 
	process(clk)
	variable s1,s2:integer:=33;
	variable u:real; 
	begin			 
		UNIFORM(s1,s2,u);
		nn<=integer(u*3.0+0.5); 
		if nn=1 then n1<=n1+1;
			elsif nn=2 then n2<=n2+1;
			elsif nn=3 then n3<=n3+1;  
				end if;
		end process;
	
	UUTr : LPF3x8
	port map (
		CLK => CLK,
		RST => RST,	
		Ef=>ef,	 
		freq=>f,
		DI => reov,--DI,--  
		DO => rerspv
		);
	UUTi : Lpf3x8
	port map (
		CLK => CLK,
		RST => RST,
		Ef=>ef,	 
		freq=>f,
		DI => imov,
		DO => imrspv
		);
	rersp<=conv_integer(signed(rerspv));
	imrsp<=conv_integer(signed(imrspv));
	reov<=conv_std_logic_vector(reo,16);
	imov<=conv_std_logic_vector(imo,16);
	
	UTB: FilterTB generic map(fsampl=> 1000, 
		fstrt=>00,
		deltaf=>2,
		maxdelay=>100,
		slowdown=>8,
		magnitude=>32767.0/1.0	)
	port map(CLK,RST,
		RERSP=>rersp,
		IMRSP=>imrsp,
		REO=>reo,
		IMO=>imo,
		FREQ=>freq,
		MAGN=>magn, 
		LOGMAGN=>logmagn, 
		PHASE=>phase,
		ENA=>ena
		);
	
	
	
end TB_ARCHITECTURE;

