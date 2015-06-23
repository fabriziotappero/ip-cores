---------------------------------------------------------------------
----                                                             ----
----  FFT-based FIR Filter IP core                               ----
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
--
-- File        : fft_filter2_TB.vhd
-- Generated   : 08.08.05, 13:25
---------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;  
use IEEE.math_real.all;	 
use IEEE.std_logic_arith.all;


entity fft_filter2_tb is
	generic(
		iwidth : INTEGER := 16;
		owidth : INTEGER := 18;
		wwidth : INTEGER := 16;
		n : INTEGER := 10;
		v2 : INTEGER := 1;
		reall : INTEGER := 1;
		filtre:std_logic_vector(1 downto 0):="01");
end fft_filter2_tb;

architecture TB_ARCHITECTURE of fft_filter2_tb is
	constant tc:time:=12.5 ns;	-- clock period =1/Fclk	  
	constant fs:real:=2500.0 ; --sampling frequency Fs in kHz
	constant nd:natural:=32; -- Fclk=nd*Fs, nd>29	   
	constant df:real:=5.0;--19.5*4.0;  -- step of frequency in kHz to show the freq. characteristic
	constant f00:real:=00.0;	-- init frequency in kHz
	constant magn:real:=30000.0; -- input signal magnitude	  
	constant Fl1:real:=100.0; 	 -- low pass band
	constant Fh1:real:=200.0;	-- high pass band
	constant Fl2:real:=100.0; 	 -- low pass band
	constant Fh2:real:=200.0;	-- high pass band
	
	
	
	component fft_filter2
		generic(
			iwidth : INTEGER := 8;
			owidth : INTEGER := 8;
			wwidth : INTEGER := 8;
			n : INTEGER := 7;
			v2 : INTEGER := 1;
			reall : INTEGER := 0 );
		port(
			CLK : in std_logic;
			RST : in std_logic;
			CE : in std_logic;
			START : in std_logic;
			DATAE : in std_logic;
			FILTER : in std_logic_vector(1 downto 0);
			L1 : in std_logic_vector((n-1) downto 0);
			H1 : in std_logic_vector((n-1) downto 0);
			L2 : in std_logic_vector((n-1) downto 0);
			H2 : in std_logic_vector((n-1) downto 0);
			DATAIRE : in std_logic_vector((iwidth-1) downto 0);
			DATAIIM : in std_logic_vector((iwidth-1) downto 0);
			READY : out std_logic;
			DATAORE : out std_logic_vector((owidth-1) downto 0);
			DATAOIM : out std_logic_vector((owidth-1) downto 0);
			SPRDY: out STD_LOGIC;
			WESP: out STD_LOGIC;
			SPRE: out STD_LOGIC_VECTOR (owidth-1 downto 0);
			SPIM: out STD_LOGIC_VECTOR (owidth-1 downto 0);
			FREQ:out STD_LOGIC_VECTOR (n-1 downto 0);
			SPEXP:out STD_LOGIC_VECTOR (3 downto 0)	 ) ;
		
	end component;
	
	signal CLK : std_logic:='1';
	signal RST : std_logic:='1';
	signal CE : std_logic;
	signal START : std_logic;
	signal DATAE,rdyd : std_logic;
	signal FILTER : std_logic_vector(1 downto 0);
	signal L1 : std_logic_vector((n-1) downto 0);
	signal H1 : std_logic_vector((n-1) downto 0);
	signal L2 : std_logic_vector((n-1) downto 0);
	signal H2 : std_logic_vector((n-1) downto 0);
	signal DATAIRE : std_logic_vector((iwidth-1) downto 0);
	signal DATAIIM : std_logic_vector((iwidth-1) downto 0);
	--	signal READY : std_logic;
	signal DATAORE : std_logic_vector((owidth-1) downto 0);
	signal DATAOIM : std_logic_vector((owidth-1) downto 0);
	signal clk_ce : std_logic  := '1';
	signal DATA_IN,DATA_OUT,DATA_IN1,DATA_OUT1 : STD_LOGIC_VECTOR(15 downto 0) := x"0000";	  
	signal rs,rc,f0,res,reslog,f1,frequ:real:=0.0;  
	signal p,p1,p2,p3,p4,ENA,RDY : std_logic:='0';
	signal cnt,ct2:natural;		 
	signal ssc,scc,coun,freque:integer;	  
	constant a1:std_logic_vector((iwidth-1) downto 0):=
	CONV_STD_LOGIC_VECTOR(integer(0.99 * magn),iwidth);
	constant a0:std_logic_vector((iwidth-1) downto 0):=(others=>'0');
	constant nn:real:=real(2**n);
	
begin		  
	FILTER<=filtre; --01 prosto filter, 10 filter+differenc-r
	CE<='1'; -- bez zamedlenija
	
	l1<=conv_std_logic_vector(integer(1.0*Fl1*nn/fs),n);
	h1<=conv_std_logic_vector(integer(1.0*Fh1*nn/fs),n);
	l2<=conv_std_logic_vector(integer(1.0*Fl2*nn/fs),n);
	h2<=conv_std_logic_vector(integer(1.0*Fh2*nn/fs),n);
	
	rst <= '1','0' after 103 ns;
	clk <= not clk after 0.5*tc; --Generator sinchroserii
	start<='0', '1' after 104 ns,'0' after 104 ns + 2*tc; 
	QUANT:process(rst,CLK)
	begin				
		if rst='1' then cnt<=0;
		elsif rising_edge(CLK) then
			if cnt=	nd-1 then
				cnt<=0; ENA<='1' ;
			else
				cnt<=cnt+1;ENA<='0' ;
			end if;
		end if;
		
	end process;
	
	-- Unit Under Test port map
	UUT : fft_filter2
	generic map (
		iwidth => iwidth,
		owidth => owidth,
		wwidth => wwidth,
		n => n,
		v2 => v2,
		reall => reall
		)
	
	port map (CLK,RST,CE,
		START => START,
		DATAE => ENA,
		FILTER => FILTER,
		L1 => L1,
		H1 => H1,
		L2 => L2,
		H2 => H2,
		DATAIRE => DATA_In,
		DATAIIM => DATA_in1,
		READY => RDY,
		DATAORE =>DATAORE,
		DATAOIM =>DATAOIM
		);
	
	DATA_Out<=DATAORE(owidth-1 downto owidth-iwidth);
	DATA_Out1<=DATAOIM(owidth-1 downto owidth-iwidth);
	
	EPOCH:process	begin		
		--wait for 1500*tc*nd;
		loop
			p <= '0'; wait for (1024*nd-1)*tc;-- 0.25*1000 us;  p <= '1';   wait for 4*12.5 ns;
			p<='1'; wait for tc;
		end loop;
	end process;
	
	SINE_GEN:process(clk,rst)							   
		variable i : real; 						   
		variable j : integer;
	begin  
		if rst = '1' then	  
			ct2<=0;
			rs <= 0.0;	 
			i := 0.0; j := 0;		
			f0 <= f00;	  
			rdyd<='0';
		elsif clk = '1' and clk'event then	
			rdyd<=rdy;
			if RDY='1' and rdyd='0' then
				if ct2=1 then
					ct2<=0;
					f0 <= f0 + df;  f1 <= f0*2.5;
				else
					ct2<= ct2+1;	 	-- counter of even/odd FFT
				end if;
				
			end if;
			--	if p = '1' then f0 <= f0 + df;  f1 <= f0*2.5; end if;	
			
			rc <=  cos(f0 * 2.0 * math_pi * i/Fs); --0.0;----
			rs <=  sin(f0 * 2.0 * math_pi * i/Fs); 
			if ENA='1' then i:=i+1.0; end if;
		end if;
	end process;		 
	
	data_in1 <=(CONV_STD_LOGIC_VECTOR(integer(rs * magn),16));--others=>'0');-- ----
	data_in  <= CONV_STD_LOGIC_VECTOR(integer(rc * magn),16); -- when p = '1' else x"0000";
	--	data_in  <= CONV_STD_LOGIC_VECTOR(integer(0.9 * magn),16); -- when p = '1' else x"0000";
--		data_in<=a0, a1 after 0.01 us, a0 after 14 us, a1 after 30 us,a0 after 35 us,
--		a1 after 70 us, a0 after 74 us, a1 after 91 us,a0 after 105 us,
--		a1 after 120 us, a0 after 123 us, a1 after 141 us,a0 after 155 us;
	--		p1 <= transport p after 10 us;
	
	
	
	process(clk,rst)
		variable couni : integer := 0;
		variable ss,sc,sm0,r,rsum : real; 
	begin  
		if rst = '1' then
			reslog <= -100.0;
			res<=0.0;
		elsif clk = '1' and clk'event  then 
		
			if RDY='1' and rdyd='0'and ct2=1 then
				coun <= 0;	
				rsum:=0.0;
			end if;
			
			if coun /= 32 and ENA='1' then
				coun <= coun + 1; 
			end if;	
			
			if ENA='1' then 
				
				if coun >= 0 and coun < 30 then						
					
					ss := real(conv_integer(signed(data_out)))/magn; 
					sc := real(conv_integer(signed(data_out1)))/magn;	
					sm0 := ss*ss + sc*sc + 0.00000000000001;	--; --   
					r := 20.0 * log10(sqrt(sm0));  
					rsum := rsum + sm0;
				end if;		  
				
				if coun = 31 then
					res<= sqrt(rsum/30.0)  ;
					reslog <= 20.0 * log10(sqrt(rsum/30.0));  
					freque<=integer(f0-df);
				end if;
			end if;
		end if;
	end process;
	
	ssc <= (conv_integer(signed(data_out))); 
	scc <= (conv_integer(signed(data_out1)));
end TB_ARCHITECTURE;

