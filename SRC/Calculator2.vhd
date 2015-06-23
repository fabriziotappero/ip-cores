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
library IEEE;
use IEEE.STD_LOGIC_1164.all,
IEEE.STD_LOGIC_ARITH.all,IEEE.STD_LOGIC_SIGNED.ALL;

entity Calculator is
	port(CLK : in STD_LOGIC;
		RST : in STD_LOGIC;
		EF : in STD_LOGIC;
		F : in STD_LOGIC_VECTOR(11 downto 0);
		A0 : out STD_LOGIC_VECTOR(11 downto 0);
		A1 : out STD_LOGIC_VECTOR(11 downto 0);
		B1 : out STD_LOGIC_VECTOR(11 downto 0);
		SH : out STD_LOGIC_VECTOR(3 downto 0));
end Calculator;


architecture LPF2 of Calculator is
	
	Constant cb:std_logic_vector(11 downto 0):=X"440";
	Constant ca10:std_logic_vector(11 downto 0):=X"0e2"; --1 diap.
	Constant ca11:std_logic_vector(11 downto 0):=X"0f0";
	Constant ca0:std_logic_vector(11 downto 0):=X"028";	 
	signal a,c,sr,fi : std_logic_vector(11 downto 0);
	signal ac : std_logic_vector(2 downto 0);
	signal q : std_logic_vector(11 downto 0);
	signal st:	std_logic_vector(4 downto 0):="00000";
	type op_t is (add,sub,csubf,csuba);	-- addc, 
	signal op: op_t;
	signal we,wsr,shift,shiftr,eb1,ea1,ea0,esh,ea,ra:STD_logic;  
	signal shi:std_logic_vector(3 downto 0):="0001";
	signal shii:std_logic_vector(3 downto 0):="0001";
	signal fn:std_logic_vector(8 downto 0);
	
	
begin 	
	shi<="0001" when (fi(11)='1' or fi(10)='1') else
	"0010" when fi(9)='1' else 
	"0100" when fi(8)='1' else "1000";
	with shi select
	fn<=fi(11 downto 3) when "0001",
	fi(10 downto 2) when "0010",
	fi(9 downto 1) when "0100",
	fi(8 downto 0) when others; 
	
	
	
	ROM:with ac select
	c<=X"000" when	"000"|"100",
	cb when "001"|"101",
	ca11 when "010",
	ca10 when "110",
	ca0 when others;
	
	ALU:with op select
	q<=c - ('0'&fn) when csubf,
	a + sr when add,
	a - sr when sub,
	--	a + c  when addc,
	c - a when others;	   
	
	
	RR:process(CLK,rst)
	begin	
		if RST='1' then
			a<=X"000";
			sr<=X"000";
		elsif CLK'event and CLK='1' then  --CLK rising edge   
			if we='1' then	
				a <= q;	
			elsif ra='1' then
				a<=X"000";
			end if;
			if wsr='1' then
				sr<= a;
			elsif shift='1' then
				sr<=sr(10 downto 0)&'0';	
			elsif shiftr='1' then
				sr<=sr(11)&sr(11 downto 1);	
			end if;
		end if;
	end process;
	
	FSM:process(CLK,RST,st)
	begin		   
		if RST='1' then
			st<= "00000";  
		elsif CLK'event and CLK='1' then  --CLK rising edge 
			if EF='1' and st= "00000" then	
				st<= st+1;
			elsif st/= "00000" then	
				st<= st+1;
			end if;	 
		end if;
		op<=add;
		ea<='0';
		ra<='0';
		we<='0';
		eb1<='0';
		ea1<='0';ea0<='0';esh<='0';
		ac(1 downto 0)<="00";
		ac(2)<= shi(0);	
		shift<='0';	  
		shiftr<='0';	  
		wsr<='0';
		case st is
			when "00001" =>op<=add; esh<='1'; 
			when "00010" =>op<=csubf; eb1<='1'; ac(0)<='1';-- c0-f->b1
			when "00011" =>op<=csubf; we<='1';  ac(1)<='1';--c1-f->a
			when "00100" =>op<=csuba;we<='1';		--f-c1 ->a
			when "00101" =>op<=csuba;wsr<='1';		--f-c1 ->sr
			when "00110" =>op<=add; shift<='1';
			when "00111" =>op<=add; we<='1'; shift<='1';	-- a1+2a1->a
			when "01000" =>op<=add; shift<='1';	
			when "01001" =>op<=add; we<='1'; ea1<='1'; --a1+2a1+8a1->a1,a
			when "01010" =>op<=add; wsr<='1';       	 --a1+2a1+8a1->sr
			when "01011" =>op<=add; shiftr<='1';
			when "01100" =>op<=add; ra<='1'; shiftr<='1'; 	--	0->a
			when "01101" =>op<=add; we<='1'; shiftr<='1';	    --c1/4->a
			when "01110" =>op<=add; we<='1'; shiftr<='1';	--a1/4+a1/8->a
			when "01111" =>op<=add; shiftr<='1';
			when "10000" =>op<=add; we<='1';  -- a1/4+a1/8+a1/32->a
			when "10001" =>op<=csuba;we<='1';ea0<='1';ac(1)<='1';ac(0)<='1';--C0-a->a0
			when others=> null;
		end case;
		
		
	end process;
	
	
	
	ROUT:process(CLK,RST)
	begin		   
		if RST='1' then
			b1<= X"441";
			a1<= X"c79";
			a0<= X"1f8";  
			fi<= X"000";
			shii<="0001";	   --0-й режим
		elsif CLK'event and CLK='1' then  --CLK rising edge 
			if eb1='1' then	
				b1<= q;
			end if;
			if ea1='1' then	
				a1<= q;
			end if;if ea0='1' then	
				a0<= q;
			end if;
			if esh='1' then	 
				fi<=F;
			end if;	
			shii<= shi;
		end if;
	end process;	
	SH<=shii;
end LPF2;
