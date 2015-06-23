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


library IEEE;
use IEEE.STD_LOGIC_1164.all;	
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_SIGNED.all;

entity LPF3x8 is
	port(
		CLK : in STD_LOGIC;
		RST : in STD_LOGIC;									   
		EF : in STD_LOGIC;	
		FREQ : in STD_LOGIC_VECTOR(11 downto 0);
		DI : in STD_LOGIC_VECTOR(15 downto 0);
		DO : out STD_LOGIC_VECTOR(15 downto 0)
		);
end LPF3x8;


architecture WAVE3x8 of LPF3x8 is	  
	component  DELAY is
		generic(nn:natural;--data width
			l:natural:=8); --FIFO length
		port(
			CLK : in STD_LOGIC;
			CE: in STD_LOGIC;							--shift enable
			D : in STD_LOGIC_VECTOR(nn-1 downto 0);	--Data in
			Q : out STD_LOGIC_VECTOR(nn-1 downto 0)	--Data out
			);
	end component;	   
	component  Calculator is
		port(CLK : in STD_LOGIC;
			RST : in STD_LOGIC;
			EF : in STD_LOGIC;
			F : in STD_LOGIC_VECTOR(11 downto 0);
			A0 : out STD_LOGIC_VECTOR(11 downto 0);
			A1 : out STD_LOGIC_VECTOR(11 downto 0);
			B1 : out STD_LOGIC_VECTOR(11 downto 0);
			SH : out STD_LOGIC_VECTOR(3 downto 0));
	end component;
	constant cc:integer:=(3+4)mod 6;
	signal st,st2,st3:natural range 0 to 7; 
	signal ce:std_logic;  
	signal did:std_logic_vector(15 downto 0);
	signal dd1,dd2,dod:std_logic_vector(18 downto 0);
	signal tt2,tt2d1,tt2d2,t2z2i:std_logic_vector(20 downto 0):=(others=>'0');
	signal	t3,t2,t1:std_logic_vector(17+11+1 downto 0):=(others=>'0');
	signal a0,a1,b1, a0d,a1d,b1d:std_logic_vector(11 downto 0):=(others=>'0');
	signal doi:std_logic_vector(18 downto 0); 
	signal doii:std_logic_vector(19 downto 0); 
	signal	d_z2:std_logic_vector(20 downto 0);
	
	signal	z2,z2i,z2d1,z2d2:std_logic_vector(20 downto 0);
	signal	tt2_z1,tt1i:std_logic_vector(21 downto 0);
	signal	z1,z1i,z1d1,z1d2,t1z1,tt1,d1_3,d1_4,d56_1,d78_1:std_logic_vector(21 downto 0);
	signal	z3,z3i,z3d1,z3d2,t3z3:std_logic_vector(19 downto 0);
	signal	d2_3,d2_4:std_logic_vector(20 downto 0);
	signal t2z2,t2z2d1,t2z2d2,t2z2_z3,tt3: std_logic_vector(19 downto 0);
	signal	z4,z4i:std_logic_vector(18 downto 0); 
	signal d3_3,d3_4:std_logic_vector(19 downto 0);
	signal d56_2:std_logic_vector(20 downto 0);
	signal d56_3:std_logic_vector(19 downto 0);
	signal d78_2:std_logic_vector(20 downto 0);
	signal d78_3:std_logic_vector(19 downto 0);
	signal d4_30,d4_40, d4_3,d4_4,d56_4,d78_4:std_logic_vector(18 downto 0);
	signal sel56_1,sel56_2,sel78_1,sel78_2:std_logic;
	signal f: STD_LOGIC_VECTOR(11 downto 0);
	signal fn: STD_LOGIC_VECTOR(8 downto 0);
	signal sh: STD_LOGIC_VECTOR(3 downto 0); 
	signal prob,prob2,prob3,prob4:integer:=0;
	
	constant zy:std_logic_vector(1 downto 0):="00"; 
	--коэффициенты фильтров		 
	--	signal b1_3,a1_3,a0_3, b1_4,a1_4,a0_4:std_logic_vector(15 downto 0);
	
	--bez rassota koefficientow	
	constant b1_1:std_logic_vector(11 downto 0):=
	CONV_STD_LOGIC_VECTOR(integer(0.5317*2048.0),12);
	constant a1_1:std_logic_vector(11 downto 0):=
	CONV_STD_LOGIC_VECTOR(integer(-0.440918*2048.0),12);
	constant a0_1:std_logic_vector(11 downto 0):=
	CONV_STD_LOGIC_VECTOR(integer(0.2462*2048.0),12);	
	--	constant b1_2:std_logic_vector(11 downto 0):=
	--	CONV_STD_LOGIC_VECTOR(integer(0.405*2048.0),12);
	--	constant a1_2:std_logic_vector(11 downto 0):=
	--	CONV_STD_LOGIC_VECTOR(integer(-0.1807*2048.0),12);
	--	constant a0_2:std_logic_vector(11 downto 0):=
	--	CONV_STD_LOGIC_VECTOR(integer(0.1041*2048.0),12);
	--	constant b1_3:std_logic_vector(11 downto 0):=
	--		CONV_STD_LOGIC_VECTOR(integer(0.427*2048.0),12);
	--		constant a1_3:std_logic_vector(11 downto 0):=
	--		CONV_STD_LOGIC_VECTOR(integer(-0.1922*2048.0),12);
	--		constant a0_3:std_logic_vector(11 downto 0):=
	--		CONV_STD_LOGIC_VECTOR(integer(0.1221*2048.0),12);
	--		constant b1_4:std_logic_vector(11 downto 0):=
	--		CONV_STD_LOGIC_VECTOR(integer(0.427*2048.0),12);
	--		constant a1_4:std_logic_vector(11 downto 0):=
	--		CONV_STD_LOGIC_VECTOR(integer(-0.1922*2048.0),12);
	--		constant a0_4:std_logic_vector(11 downto 0):=
	--		CONV_STD_LOGIC_VECTOR(integer(0.1221*2048.0),12);
	--		constant b1_5:std_logic_vector(11 downto 0):=
	--		CONV_STD_LOGIC_VECTOR(integer(0.427*2048.0),12);
	--		constant a1_5:std_logic_vector(11 downto 0):=
	--		CONV_STD_LOGIC_VECTOR(integer(-0.1922*2048.0),12);
	--		constant a0_5:std_logic_vector(11 downto 0):=
	--		CONV_STD_LOGIC_VECTOR(integer(0.1221*2048.0),12);
	--		constant b1_6:std_logic_vector(11 downto 0):=
	--		CONV_STD_LOGIC_VECTOR(integer(0.427*2048.0),12);
	--		constant a1_6:std_logic_vector(11 downto 0):=
	--		CONV_STD_LOGIC_VECTOR(integer(-0.1922*2048.0),12);
	--		constant a0_6:std_logic_vector(11 downto 0):=
	--		CONV_STD_LOGIC_VECTOR(integer(0.1221*2048.0),12);
	--		constant b1_7:std_logic_vector(11 downto 0):=
	--		CONV_STD_LOGIC_VECTOR(integer(0.507*2048.0),12);
	--		constant a1_7:std_logic_vector(11 downto 0):=
	--		CONV_STD_LOGIC_VECTOR(integer(-0.662*2048.0),12);
	--		constant a0_7:std_logic_vector(11 downto 0):=
	--		CONV_STD_LOGIC_VECTOR(integer(0.314*2048.0),12);
	--		constant b1_8:std_logic_vector(11 downto 0):=
	--		CONV_STD_LOGIC_VECTOR(integer(0.507*2048.0),12);
	--		constant a1_8:std_logic_vector(11 downto 0):=
	--		CONV_STD_LOGIC_VECTOR(integer(-0.662*2048.0),12);
	--		constant a0_8:std_logic_vector(11 downto 0):=
	--		CONV_STD_LOGIC_VECTOR(integer(0.314*2048.0),12);
	
	signal	a0_x,a1_x,b1_x:std_logic_vector(11 downto 0);
	constant c17: std_logic_vector(11 downto 0):=X"440"; 
	constant c15: std_logic_vector(9 downto 0):="0011110000"; --уст.f при 0.25
	constant c3: std_logic_vector(11 downto 0):="000000101000"; 
	constant c150: std_logic_vector(9 downto 0):="0011100010"; --уст.f при 0.25
	
begin 
	ce<='1';
	
	--sh<="0001" when f(11)='1' or f(10)='1' else
	--	"0010" when f(9)='1' else 
	--	"0100" when f(8)='1' else "1000";
	--	with sh select
	--	fn<=f(11 downto 3) when "0001",
	--	f(10 downto 2) when "0010",
	--	f(9 downto 1) when "0100",
	--	f(8 downto 0) when others; 
	--	
	--	RG_F:	process(CLK,RST) --frequency register and coefficient calculator
	--		variable a1n: std_logic_vector(9 downto 0);	
	--		variable a0n: std_logic_vector(11 downto 0);	
	--		variable a1_xi: std_logic_vector(12 downto 0);	
	--	begin
	--		if RST='1' then	  
	--			f<=(others=>'0');	
	--			b1_x<=(others=>'0');
	--			a1_x<=(others=>'0');
	--			a0_x<=(others=>'0');
	--			
	--		elsif rising_edge(CLK) then
	--			if EF='1' then
	--				f<=FREQ;
	--			end if;	 
	--			b1_x<= (signed(c17) - signed("000" & fn)); 	 
	--		--	if f(11)='1' then
	----				b1_x<=X"340";
	----			end if;
	--			
	--			if f(11)='1' or f(10)='1' then
	--				a1n:=('0'&fn) - c150;	--0th mode  	   
	--			else  
	--				a1n:=('0'&fn) - c15;	
	--			end if;
	--			--	if f(11)='1' or f(10)='1' then	
	--			--			a1_x<=SHL(signed( a1n & "000000")+ signed(a1n & "0000")+ signed(a1n & "000"),"01"); --уст.f при 0.125
	--			--		else   
	--			--			a1_x<=SHL(signed( a1n & "000000")+ signed(a1n & "0000")+ signed(a1n & "000"),"01"); --уст.f при 0.0625
	--			--			
	--			--		end if;
	--			a1_xi:=signed( a1n & "000")+ signed(a1n&'1' )+ signed(a1n); --уст.f при 0.125
	--			a1_x<=a1_xi(11 downto 0);
	--			a0n:= c3 - (a1_x(11)&a1_x(11)&a1_x(11 downto 2) + a1_x(11 downto 3)+
	--			a1_x(11 downto 5)); 
	--			a0_x<=a0n;
	--		end if;
	--	end process;
	
	U_C:Calculator port map(CLK,RST,
		EF =>EF,
		F =>FREQ,
		A0 =>a0_x,
		A1 =>a1_x,
		B1 =>b1_x,
		SH =>sh);	 
	
	--b1_3<=b1_x;
	--		a1_3<=a1_x;
	--		a0_3<=a0_x;
	--		b1_4<=b1_x;
	--		a1_4<=a1_x;
	--		a0_4<=a0_x;
	
	CT_ST:	process(CLK,RST) --phase counter
	begin
		if RST='1' then	  
			st<=0;	
		elsif rising_edge(CLK) then
			if st=7 then
				st<=0;
			else
				st<=st+1;
			end if;
		end if;
	end process;	   
	
	--		MUX_A0:with st select	--uncontrolled filters
	--		a0<=a0_1 when 4,
	--		a0_2 when 5,
	--		a0_3 when 6,
	--		a0_4 when 7,
	--		a0_5 when 0,
	--		a0_6 when 1,
	--		a0_7 when 2,
	--		a0_8 when others;
	--		MUX_A1:with st select
	--		a1<=a1_1 when 4,
	--		a1_2 when 5,
	--		a1_3 when 6,
	--		a1_4 when 7,
	--		a1_5 when 0,
	--		a1_6 when 1,
	--		a1_7 when 2,
	--		a1_8 when others;
	--		MUX_B:with st select
	--		b1<=b1_1 when 1,
	--		b1_2 when 2,
	--		b1_3 when 3,
	--		b1_4 when 4,
	--		b1_5 when 5,
	--		b1_6 when 6,
	--		b1_7 when 7,
	--		b1_8 when others;  
	
	MUX_A0: a0<=a0_x when (sh(0)='1') or	--and (st=4 or st=5 or st=6 or st=7)
	(sh(1)='1' and ( st=6 or st=7))  or
	(sh(2)='1' and ( st=0 or st=1))	or
	(sh(3)='1' and ( st=2 or st=3))	else a0_1;
	
	MUX_A1: a1<=a1_x when (sh(0)='1') or	 --and (st=4 or st=5 or st=6 or st=7)
	(sh(1)='1' and ( st=6 or st=7))  or
	(sh(2)='1' and ( st=0 or st=1))	or
	(sh(3)='1' and ( st=2 or st=3))	else a1_1;
	
	MUX_B1: b1<=b1_x when (sh(0)='1' ) or	 --and (st=1 or st=2 or st=3 or st=4)
	(sh(1)='1' and ( st=3 or st=4))  or
	(sh(2)='1' and ( st=5 or st=6))	or
	(sh(3)='1' and ( st=7 or st=0))	else b1_1;
	
	
	Wave2:process(CLK,RST)  
		variable dii:std_logic_vector(18 downto 0);
	begin
		if RST='1' then	  
			a1d	<=(others=>'0');
			b1d	<=(others=>'0');
			did	<=(others=>'0');
			dd1	<=(others=>'0');
			dd2	<=(others=>'0');
			z1d1	<=(others=>'0');
			z1d2	<=(others=>'0');
			z2d1	<=(others=>'0');
			z2d2	<=(others=>'0');
			tt2d1	<=(others=>'0');
			tt2d2	<=(others=>'0');
			--		tt1	<=(others=>'0');
			--		t1z1	<=(others=>'0');
			d_z2<=(others=>'0');
			tt2_z1<=(others=>'0'); 
		elsif rising_edge(CLK) then	 
			a1d<=a1;
			b1d<=b1;
			if st=0 then
				did<=DI;
			end if;
			if st=1 then
				dii:=did(15)&did&zy;
			else
				dii:= 	dod; --	(others=>'0');-- connecting a chain
			end if;
			dd1<=dii;
			dd2<=dd1;
			z1d1<=z1;
			z1d2<=z1d1;
			z2d1<=z2;
			z2d2<=z2d1;
			
			d_z2<=dii - z2;
			tt2<=dd2 + t2(28 downto 8); 	
			tt2d1<=tt2;
			tt2d2<=tt2d1;
			
			tt2_z1<=tt2(20)&tt2 - z1; 
			
		end if;
	end process;  		
	tt1i<=tt2d2(20)&tt2d2+ t1(28 downto 7); 
	tt1<=tt1i(21 downto 0);
	t1z1<=z1d2+ t1(27 downto 7);		
	
	
	MULR: process(CLK) -- multiplier registers
	begin
		if rising_edge(CLK) then   
			t1<=tt2_z1(21 downto 4)*a1d;
			t2<=d_z2(20 downto 3)*b1d;
			t3<=a0d*t2z2_z3(19 downto 2);
		end if;
	end process;	
	
	
	
	
	
	Wave1:	process(CLK,RST) -- wave stage of 1st order
	begin
		if RST='1' then	   
			a0d<=(others=>'0');
			t2z2	<=(others=>'0');
			t2z2d1	<=(others=>'0');
			t2z2d2	<=(others=>'0');
			t2z2_z3	<=(others=>'0');
			--tt3		<=(others=>'0');
			z3d1	<=(others=>'0');
			z3d2	<=(others=>'0');
			t3z3    <=(others=>'0');
			--	doi    <=(others=>'0');	
			DO	<=(others=>'0');
		elsif rising_edge(CLK) then
			t2z2<=t2z2i(19 downto 0); 	
			t2z2d1<=t2z2;
			t2z2d2<=t2z2d1;
			t2z2_z3<=t2z2 - z3;	 
			a0d<=a0;
			z3d1<=z3;
			z3d2<=z3d1;
			t3z3<=z3d2 + t3(28 downto 9);
			
			if st=6 then  -- st=7 
				DO<=doi(17 downto 2);  --result st=7- 1st stage
			end if;					    	 --  st=0 - 2nd stage...
			
		end if;
	end process; 
	t2z2i<=z2d2 + t2(28 downto 8);--+1; 	
	
	tt3<=t3(28 downto 9)+t2z2d2;--+1;	 
	
	doii<=SXT(z4,20) when ((sh(0)='1' or sh(1)='1') and (st=3 or st=4 or st=5 or st=6)) or
	(sh(2)='1' and (st=5 or st=6)) else	 --пропуск каскада
	SHR((z4+t3z3+1),"01");		--результат округленный  	   --+ LPF, - HPF	  
	--	doi<=SHR((z4+t3z3),"01");		  	   --+ LPF, - HPF	  
	doi<=doii(18 downto 0); 
	RG_DEL:process(CLK,RST) -- доп.задержки для 3 и 4 каскадов 
	begin
		if RST='1' then	  
			d1_4	<=(others=>'0');
			d2_4	<=(others=>'0');
			d3_4	<=(others=>'0');
			d4_4	<=(others=>'0');
			d4_40	<=(others=>'0');
			d1_3	<=(others=>'0');
			d2_3	<=(others=>'0');
			d3_3	<=(others=>'0');
			d4_30	<=(others=>'0');
			d4_3	<=(others=>'0');
		elsif rising_edge(CLK) then
			if st=(6+2)mod 8 or st=(6+3) mod 8 then	 --+2 - 3й каскад
				d1_3<=tt1;									  --4 th stage
				d2_3<=t1z1(20 downto 0);
				d3_3<=tt3;
				d1_4<=d1_3;
				d2_4<=d2_3;
				d3_4<=d3_3;
			elsif st=3+2 or st=(3+3) mod 8 then
				d4_30<=dd2;
				d4_3<=d4_30;	  --4 registers in chain
				d4_40<=d4_3;
				d4_4<=d4_40;
			end if;
			
		end if;
	end process;	
	
	sel56_1<='1' when st=((6+4) mod 8) or (st=((6+5) mod 8)) else '0';	
	sel56_2<='1' when st=((3+4) mod 8) or (st=((3+5) mod 8)) else '0';	
	sel78_1<='1' when st=((6+6) mod 8) or (st=((6+7) mod 8)) else '0';	
	sel78_2<='1' when st=((3+6) mod 8) or (st=((3+7) mod 8)) else '0';	
	DZ1_56:DELAY generic map(nn=>22,l=>6) --FIFO stages 5,6
	port map(CLK,sel56_1,					
		D => tt1,	
		Q => d56_1);	
	DZ2_56:DELAY generic map(nn=>21,l=>6) --FIFO stages 5,6
	port map(CLK,sel56_1,					
		D => t1z1(20 downto 0),	
		Q => d56_2);	
	DZ3_56:DELAY generic map(nn=>20,l=>6) --FIFO stages 5,6
	port map(CLK,sel56_1,					
		D => tt3,	
		Q => d56_3);	
	DZ4_56:DELAY generic map(nn=>19,l=>12) --FIFO stages 5,6
	port map(CLK,sel56_2,					
		D => dd2,	
		Q => d56_4);
	
	DZ1_78:DELAY generic map(nn=>22,l=>14) --FIFO stages 7,8
	port map(CLK,sel78_1,					
		D => tt1,	
		Q => d78_1);	
	DZ2_78:DELAY generic map(nn=>21,l=>14) --FIFO stages 7,8
	port map(CLK,sel78_1,					
		D => t1z1(20 downto 0),	
		Q => d78_2);	
	DZ3_78:DELAY generic map(nn=>20,l=>14) --FIFO stages 7,8
	port map(CLK,sel78_1,					
		D => tt3,	
		Q => d78_3);	
	DZ4_78:DELAY generic map(nn=>19,l=>28) --FIFO stages 7,8
	port map(CLK,sel78_2,					
		D => dd2,	
		Q => d78_4);
	
	--in sh=0 delays of 3,4st are detached
	st2<=7 when sh(0)='1' and ((st=(6+2) mod 8) or (st= (6+3)mod 8)) else st; 
	st3<=4 when sh(0)='1' and ((st=(3+2)) or (st= (3+3)mod 8)) else st;
	
	
	MXZ1:with st2 select
	z1i<=d1_4 when (6+2) mod 8|(6+3) mod 8,
	d56_1 when ((6+4) mod 8)|((6+5) mod 8),
	d78_1 when ((6+6) mod 8)|((6+7) mod 8),
	tt1 when others;  
	MXZ2:with st2 select
	z2i<=d2_4 when (6+2) mod 8|(6+3) mod 8,
	d56_2 when ((6+4) mod 8)|((6+5) mod 8),
	d78_2 when ((6+6) mod 8)|((6+7) mod 8),
	t1z1(20 downto 0) when others;  
	MXZ3:with st2 select
	z3i<=d3_4 when (6+2) mod 8|(6+3) mod 8,
	d56_3 when ((6+4) mod 8)|((6+5) mod 8),
	d78_3 when ((6+6) mod 8)|((6+7) mod 8),
	tt3 when others;  
	MXZ4:with st3 select
	z4i<=d4_4 when 3+2|(3+3) mod 8,
	d56_4 when ((3+4) mod 8)|((3+5) mod 8),
	d78_4 when ((3+6) mod 8)|((3+7) mod 8),
	dd2 when others;  
	
	DZ1:DELAY generic map(nn=>22,l=>4+2) --FIFO length=i+(period-6)
	port map(CLK,CE,						
		D => z1i,	--Data in
		Q => z1);	
	DZ2:DELAY generic map(nn=>21,l=>1+2) --FIFO length
	port map(CLK,CE,							--shift enable
		D => z2i,	--Data in
		Q => z2);		
	DZ3:DELAY generic map(nn=>20,l=>4+2) --FIFO length
	port map(CLK,CE,							--shift enable
		D => z3i,	--Data in
		Q => z3);		
	DZ4:DELAY generic map(nn=>19,l=>16+4) --FIFO length
	port map(CLK,CE,							--shift enable
		D => z4i,	--Data in
		Q => z4);		
	DD:DELAY generic map(nn=>19,l=>1+2) --FIFO length
	port map(CLK,CE,							--shift enable
		D => doi(18 downto 0),	--Data in
		Q => dod);	
	
	prob<=conv_integer(signed(tt2));
	prob2<=conv_integer(signed(tt1));
	prob3<=conv_integer(signed(d_z2));
	prob4<=conv_integer(signed(tt2_z1));
	
end WAVE3x8;
